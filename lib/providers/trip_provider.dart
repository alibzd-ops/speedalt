import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/gps_status.dart';
import '../models/trip_state.dart';
import '../services/ad_service.dart';
import '../services/altimeter_service.dart';
import '../services/location_service.dart';
import '../services/wakelock_service.dart';
import 'settings_provider.dart';

/// Provider managing active GPS trip tracking, metrics calculation, and lifecycle.
class TripProvider with ChangeNotifier, WidgetsBindingObserver {
  final LocationService locationService;
  final AltimeterService altimeterService;
  final WakelockService wakelockService;
  final SettingsProvider settingsProvider;

  TripState _state = TripState.initial;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _tripTimer;

  // Active trip calculation accumulators
  double _distanceAccumulatorMeters = 0.0;
  double _maxSpeedMs = 0.0;
  int _tripSeconds = 0;
  int _movingSeconds = 0;
  final List<LatLng> _routeCoordinates = [];

  TripProvider({
    required this.locationService,
    required this.altimeterService,
    required this.wakelockService,
    required this.settingsProvider,
  }) {
    WidgetsBinding.instance.addObserver(this);
    initGps();
  }

  TripState get state => _state;

  /// Checks initial GPS permission and starts passive monitoring.
  Future<void> initGps() async {
    final status = await locationService.checkStatus();
    _state = _state.copyWith(gpsStatus: status);
    notifyListeners();

    if (status == GpsStatus.searching || status == GpsStatus.ready) {
      _startPositionStream();
    }
  }

  /// Requests user permission for foreground location.
  Future<LocationPermission> requestLocationPermission() async {
    final permission = await locationService.requestPermission();
    await initGps();
    return permission;
  }

  /// Opens system location settings.
  Future<void> openLocationSettings() async {
    await locationService.openLocationSettings();
  }

  /// Opens app settings in device settings.
  Future<void> openAppSettings() async {
    await locationService.openAppSettings();
  }

  /// Starts listening to device GPS stream.
  void _startPositionStream() {
    _positionSubscription?.cancel();
    _positionSubscription = locationService.getPositionStream().listen(
      _onPositionUpdate,
      onError: (error) {
        _state = _state.copyWith(gpsStatus: GpsStatus.poorSignal);
        notifyListeners();
      },
    );
  }

  /// Handles incoming GPS position update from device.
  void _onPositionUpdate(Position position) {
    final smoothing = settingsProvider.gpsSmoothing;
    final processed = locationService.processPosition(position, smoothing);

    // Determine current GPS status based on accuracy
    GpsStatus currentStatus = GpsStatus.ready;
    if (position.accuracy > smoothing.accuracyThresholdMeters) {
      currentStatus = GpsStatus.poorSignal;
    }

    // Process altitude through altimeter service
    final altReading = altimeterService.getReading(position);
    final altitudeM = altReading?.altitudeMeters ?? position.altitude;
    final altAccuracy = altReading?.accuracyMeters ?? position.altitudeAccuracy;
    final heading = position.heading >= 0 ? position.heading : null;

    if (processed == null) {
      _state = _state.copyWith(
        gpsStatus: currentStatus,
        gpsAccuracyM: position.accuracy,
        heading: heading,
      );
      notifyListeners();
      return;
    }

    // If trip is actively running, accumulate trip metrics
    if (_state.isTracking) {
      _distanceAccumulatorMeters += processed.distanceDeltaMeters;

      if (processed.isValidForMaxSpeed && processed.currentSpeedMs > _maxSpeedMs) {
        _maxSpeedMs = processed.currentSpeedMs;
      }

      // Add to route coordinates breadcrumbs if moved enough
      final currentLatLng = LatLng(processed.latitude, processed.longitude);
      if (_routeCoordinates.isEmpty) {
        _routeCoordinates.add(currentLatLng);
      } else {
        final lastPoint = _routeCoordinates.last;
        final dLat = (currentLatLng.latitude - lastPoint.latitude).abs();
        final dLng = (currentLatLng.longitude - lastPoint.longitude).abs();
        // Record coordinate if moved at least ~3 meters
        if (dLat > 0.00003 || dLng > 0.00003) {
          _routeCoordinates.add(currentLatLng);
        }
      }

      // Calculate average speed based on moving time, or total time if early in trip
      double avgSpeedMs = 0.0;
      if (_movingSeconds > 0) {
        avgSpeedMs = _distanceAccumulatorMeters / _movingSeconds;
      } else if (_tripSeconds > 0 && _distanceAccumulatorMeters > 0) {
        avgSpeedMs = _distanceAccumulatorMeters / _tripSeconds;
      }

      _state = _state.copyWith(
        gpsStatus: currentStatus,
        currentSpeedMs: processed.currentSpeedMs,
        maxSpeedMs: _maxSpeedMs,
        averageSpeedMs: avgSpeedMs,
        currentAltitudeM: altitudeM,
        altitudeAccuracyM: altAccuracy > 0 ? altAccuracy : null,
        totalDistanceMeters: _distanceAccumulatorMeters,
        latitude: processed.latitude,
        longitude: processed.longitude,
        gpsAccuracyM: processed.accuracyMeters,
        heading: heading,
        routeTrail: List.unmodifiable(_routeCoordinates),
      );
    } else if (_state.isStopped) {
      // While stopped, freeze trip stats (speed, max, avg, distance, duration)
      // but update passive altitude and coordinates for user awareness
      _state = _state.copyWith(
        gpsStatus: currentStatus,
        currentAltitudeM: altitudeM,
        altitudeAccuracyM: altAccuracy > 0 ? altAccuracy : null,
        latitude: processed.latitude,
        longitude: processed.longitude,
        gpsAccuracyM: processed.accuracyMeters,
        heading: heading,
      );
    } else {
      // Idle or paused: update passive current speed, altitude and coordinates
      _state = _state.copyWith(
        gpsStatus: currentStatus,
        currentSpeedMs: _state.isPaused ? 0.0 : processed.currentSpeedMs,
        currentAltitudeM: altitudeM,
        altitudeAccuracyM: altAccuracy > 0 ? altAccuracy : null,
        latitude: processed.latitude,
        longitude: processed.longitude,
        gpsAccuracyM: processed.accuracyMeters,
        heading: heading,
      );
    }

    notifyListeners();
  }

  /// Starts a new trip session.
  Future<void> startTrip() async {
    // Ensure permission is granted
    final status = await locationService.checkStatus();
    if (status.hasIssues) {
      await requestLocationPermission();
    }

    locationService.resetFilter();
    _startPositionStream();

    _distanceAccumulatorMeters = 0.0;
    _maxSpeedMs = 0.0;
    _tripSeconds = 0;
    _movingSeconds = 0;
    _routeCoordinates.clear();

    _state = _state.copyWith(
      tripStatus: TripStatus.running,
      currentSpeedMs: 0.0,
      maxSpeedMs: 0.0,
      averageSpeedMs: 0.0,
      totalDistanceMeters: 0.0,
      tripDuration: Duration.zero,
      movingDuration: Duration.zero,
      routeTrail: const [],
    );
    notifyListeners();

    _startTripTimer();

    // Trigger AdMob interstitial ad & start 90s interval
    AdService.instance.startTripAdSchedule();

    if (settingsProvider.keepScreenAwake) {
      await wakelockService.enable();
    }
  }

  /// Pauses the active trip session.
  Future<void> pauseTrip() async {
    if (!_state.isTracking) return;

    _tripTimer?.cancel();
    AdService.instance.stopTripAdSchedule();

    _state = _state.copyWith(
      tripStatus: TripStatus.paused,
      currentSpeedMs: 0.0,
    );
    notifyListeners();

    await wakelockService.reset();
  }

  /// Resumes the paused trip session.
  Future<void> resumeTrip() async {
    if (!_state.isPaused) return;

    _state = _state.copyWith(tripStatus: TripStatus.running);
    notifyListeners();

    _startTripTimer();
    AdService.instance.startTripAdSchedule();

    if (settingsProvider.keepScreenAwake) {
      await wakelockService.enable();
    }
  }

  /// Stops tracking and freezes final session statistics on screen.
  Future<void> stopTrip() async {
    _tripTimer?.cancel();
    AdService.instance.stopTripAdSchedule();

    _state = _state.copyWith(
      tripStatus: TripStatus.stopped,
      currentSpeedMs: 0.0,
    );
    notifyListeners();

    await wakelockService.reset();
  }

  /// Clears current trip statistics after user confirmation.
  void resetTrip() {
    _tripTimer?.cancel();
    AdService.instance.stopTripAdSchedule();
    locationService.resetFilter();

    _distanceAccumulatorMeters = 0.0;
    _maxSpeedMs = 0.0;
    _tripSeconds = 0;
    _movingSeconds = 0;
    _routeCoordinates.clear();

    _state = _state.copyWith(
      tripStatus: TripStatus.idle,
      currentSpeedMs: 0.0,
      maxSpeedMs: 0.0,
      averageSpeedMs: 0.0,
      totalDistanceMeters: 0.0,
      tripDuration: Duration.zero,
      movingDuration: Duration.zero,
      routeTrail: const [],
    );
    notifyListeners();
  }

  /// Starts the 1-second interval timer for trip duration.
  void _startTripTimer() {
    _tripTimer?.cancel();
    _tripTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.isTracking) {
        _tripSeconds++;
        if (_state.currentSpeedMs > 0.5) {
          _movingSeconds++;
        }

        _state = _state.copyWith(
          tripDuration: Duration(seconds: _tripSeconds),
          movingDuration: Duration(seconds: _movingSeconds),
        );
        notifyListeners();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Gracefully handle app interruption
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      if (wakelockService.isEnabled) {
        wakelockService.reset();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_state.isTracking && settingsProvider.keepScreenAwake) {
        wakelockService.enable();
      }
      initGps();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tripTimer?.cancel();
    _positionSubscription?.cancel();
    AdService.instance.stopTripAdSchedule();
    wakelockService.reset();
    super.dispose();
  }
}
