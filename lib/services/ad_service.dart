import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Configuration for Google AdMob IDs.
/// Uses official Google test IDs by default to protect developer accounts from invalid traffic flags.
/// Live production IDs can be set here or injected via environment variables.
class AdConfig {
  // Official Google AdMob Test App IDs
  static const String testIosAppId = 'ca-app-pub-3940256099942544~1458692019';
  static const String testAndroidAppId = 'ca-app-pub-3940256099942544~3347511713';

  // Official Google AdMob Test Banner IDs
  static const String testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  // Official Google AdMob Test Interstitial IDs
  static const String testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';

  // Production Ad Unit IDs (defaults to test IDs unless overridden)
  static String get bannerAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment('ADMOB_IOS_BANNER_ID', defaultValue: testIosBannerId);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment('ADMOB_ANDROID_BANNER_ID', defaultValue: testAndroidBannerId);
    }
    return '';
  }

  static String get interstitialAdUnitId {
    if (kIsWeb) return '';
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const String.fromEnvironment('ADMOB_IOS_INTERSTITIAL_ID', defaultValue: testIosInterstitialId);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return const String.fromEnvironment('ADMOB_ANDROID_INTERSTITIAL_ID', defaultValue: testAndroidInterstitialId);
    }
    return '';
  }
}

/// Service managing AdMob initialization, banner ads, and periodic/trip interstitial ads.
class AdService {
  static final AdService instance = AdService._internal();
  AdService._internal();

  bool _isInitialized = false;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  Timer? _periodicAdTimer;

  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.android);

  /// Initializes Google Mobile Ads SDK and pre-loads the first interstitial ad.
  Future<void> initialize() async {
    if (!isSupported) return;
    try {
      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadInterstitialAd();
    } catch (e) {
      debugPrint('[AdService] MobileAds initialization failed: $e');
    }
  }

  /// Loads an Interstitial Ad in background.
  void loadInterstitialAd() {
    if (!isSupported || !_isInitialized || _isInterstitialLoading || _interstitialAd != null) {
      return;
    }

    _isInterstitialLoading = true;
    final adUnitId = AdConfig.interstitialAdUnitId;
    if (adUnitId.isEmpty) {
      _isInterstitialLoading = false;
      return;
    }

    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoading = false;
          _setupInterstitialCallbacks(ad);
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdService] InterstitialAd failed to load: ${error.message}');
          _interstitialAd = null;
          _isInterstitialLoading = false;
        },
      ),
    );
  }

  void _setupInterstitialCallbacks(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Preload next interstitial ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdService] InterstitialAd failed to show: ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
      },
    );
  }

  /// Shows the cached Interstitial Ad if available, or pre-loads if not ready.
  void showInterstitialAd({VoidCallback? onDismissed}) {
    if (!isSupported || !_isInitialized) {
      onDismissed?.call();
      return;
    }

    if (_interstitialAd != null) {
      if (onDismissed != null) {
        final originalDismissed = _interstitialAd!.fullScreenContentCallback?.onAdDismissedFullScreenContent;
        _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            originalDismissed?.call(ad);
            onDismissed();
          },
          onAdFailedToShowFullScreenContent: (ad, error) {
            ad.dispose();
            _interstitialAd = null;
            loadInterstitialAd();
            onDismissed();
          },
        );
      }
      _interstitialAd!.show();
      _interstitialAd = null;
    } else {
      loadInterstitialAd();
      onDismissed?.call();
    }
  }

  /// Starts the periodic interstitial ad schedule for active trips:
  /// 1. Shows interstitial ad right at trip start.
  /// 2. Sets up a repeating 90-second timer to show ads while the trip is running.
  void startTripAdSchedule() {
    // Show ad at start
    showInterstitialAd();

    // Start 90-second repeating timer
    _periodicAdTimer?.cancel();
    _periodicAdTimer = Timer.periodic(const Duration(seconds: 90), (timer) {
      debugPrint('[AdService] 90s interval reached, triggering interstitial ad');
      showInterstitialAd();
    });
  }

  /// Cancels the periodic interstitial ad schedule when trip stops or pauses.
  void stopTripAdSchedule() {
    _periodicAdTimer?.cancel();
    _periodicAdTimer = null;
  }
}
