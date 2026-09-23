import 'package:flutter/material.dart';
import '../utils/unit_converter.dart';

enum AppThemeMode {
  system('System', ThemeMode.system),
  light('Light', ThemeMode.light),
  dark('Dark', ThemeMode.dark);

  final String label;
  final ThemeMode mode;
  const AppThemeMode(this.label, this.mode);
}

enum GpsSmoothing {
  normal('Normal', 35.0, 0.8), // Accuracy threshold 35m, low-speed cutoff 0.8 m/s (~2.9 km/h)
  highAccuracy('High Accuracy', 20.0, 1.0); // Accuracy threshold 20m, low-speed cutoff 1.0 m/s (~3.6 km/h)

  final String label;
  final double accuracyThresholdMeters;
  final double stationaryCutoffMs;
  const GpsSmoothing(this.label, this.accuracyThresholdMeters, this.stationaryCutoffMs);
}

/// Immutable user settings model.
class UserSettings {
  final SpeedUnit speedUnit;
  final AltitudeUnit altitudeUnit;
  final DistanceUnit distanceUnit;
  final AppThemeMode themeMode;
  final bool keepScreenAwake;
  final GpsSmoothing gpsSmoothing;

  const UserSettings({
    this.speedUnit = SpeedUnit.kmh,
    this.altitudeUnit = AltitudeUnit.meters,
    this.distanceUnit = DistanceUnit.kilometers,
    this.themeMode = AppThemeMode.system,
    this.keepScreenAwake = true,
    this.gpsSmoothing = GpsSmoothing.normal,
  });

  UserSettings copyWith({
    SpeedUnit? speedUnit,
    AltitudeUnit? altitudeUnit,
    DistanceUnit? distanceUnit,
    AppThemeMode? themeMode,
    bool? keepScreenAwake,
    GpsSmoothing? gpsSmoothing,
  }) {
    return UserSettings(
      speedUnit: speedUnit ?? this.speedUnit,
      altitudeUnit: altitudeUnit ?? this.altitudeUnit,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      themeMode: themeMode ?? this.themeMode,
      keepScreenAwake: keepScreenAwake ?? this.keepScreenAwake,
      gpsSmoothing: gpsSmoothing ?? this.gpsSmoothing,
    );
  }
}
