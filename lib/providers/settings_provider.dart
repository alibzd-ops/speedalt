import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/settings_service.dart';
import '../utils/unit_converter.dart';

/// Provider managing application settings and theme state.
class SettingsProvider with ChangeNotifier {
  final SettingsService _settingsService;
  late UserSettings _settings;

  SettingsProvider(this._settingsService) {
    _settings = _settingsService.loadSettings();
  }

  UserSettings get settings => _settings;
  SpeedUnit get speedUnit => _settings.speedUnit;
  AltitudeUnit get altitudeUnit => _settings.altitudeUnit;
  DistanceUnit get distanceUnit => _settings.distanceUnit;
  AppThemeMode get themeMode => _settings.themeMode;
  bool get keepScreenAwake => _settings.keepScreenAwake;
  GpsSmoothing get gpsSmoothing => _settings.gpsSmoothing;

  ThemeMode get flutterThemeMode => _settings.themeMode.mode;

  void updateSettings(UserSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
    _settingsService.saveSettings(_settings);
  }

  void setSpeedUnit(SpeedUnit unit) {
    updateSettings(_settings.copyWith(speedUnit: unit));
  }

  void setAltitudeUnit(AltitudeUnit unit) {
    updateSettings(_settings.copyWith(altitudeUnit: unit));
  }

  void setDistanceUnit(DistanceUnit unit) {
    updateSettings(_settings.copyWith(distanceUnit: unit));
  }

  void setThemeMode(AppThemeMode mode) {
    updateSettings(_settings.copyWith(themeMode: mode));
  }

  void setKeepScreenAwake(bool keepAwake) {
    updateSettings(_settings.copyWith(keepScreenAwake: keepAwake));
  }

  void setGpsSmoothing(GpsSmoothing smoothing) {
    updateSettings(_settings.copyWith(gpsSmoothing: smoothing));
  }
}
