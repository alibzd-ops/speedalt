import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'providers/settings_provider.dart';
import 'providers/trip_provider.dart';
import 'screens/main_nav_screen.dart';
import 'services/ad_service.dart';
import 'services/altimeter_service.dart';
import 'services/location_service.dart';
import 'services/settings_service.dart';
import 'services/wakelock_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize AdMob service in background
  await AdService.instance.initialize();

  // Lock orientation to portrait by default for vehicle mount & driving ergonomics
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize persistent settings service
  final settingsService = await SettingsService.initialize();
  final locationService = LocationService();
  final altimeterService = AltimeterService();
  final wakelockService = WakelockService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsService),
        ),
        ChangeNotifierProxyProvider<SettingsProvider, TripProvider>(
          create: (context) => TripProvider(
            locationService: locationService,
            altimeterService: altimeterService,
            wakelockService: wakelockService,
            settingsProvider: context.read<SettingsProvider>(),
          ),
          update: (context, settingsProvider, previousTripProvider) {
            return previousTripProvider ??
                TripProvider(
                  locationService: locationService,
                  altimeterService: altimeterService,
                  wakelockService: wakelockService,
                  settingsProvider: settingsProvider,
                );
          },
        ),
      ],
      child: const SpeedAltApp(),
    ),
  );
}

class SpeedAltApp extends StatelessWidget {
  const SpeedAltApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'SpeedAlt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settingsProvider.flutterThemeMode,
      home: const MainNavScreen(),
    );
  }
}
