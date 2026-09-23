import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_settings.dart';
import '../utils/unit_converter.dart';

/// Service responsible for loading and storing user preferences locally.
class SettingsService {
  static const String _keySpeedUnit = 'speed_alt_speed_unit';
  static const String _keyAltitudeUnit = 'speed_alt_altitude_unit';
  static const String _keyDistanceUnit = 'speed_alt_distance_unit';
  static const String _keyThemeMode = 'speed_alt_theme_mode';
  static const String _keyKeepScreenAwake = 'speed_alt_keep_screen_awake';
  static const String _keyGpsSmoothing = 'speed_alt_gps_smoothing';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Factory constructor to initialize with SharedPreferences instance.
  static Future<SettingsService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return SettingsService(prefs);
  }

  /// Loads stored user settings or returns sensible defaults.
  UserSettings loadSettings() {
    final speedUnitIndex = _prefs.getInt(_keySpeedUnit);
    final altitudeUnitIndex = _prefs.getInt(_keyAltitudeUnit);
    final distanceUnitIndex = _prefs.getInt(_keyDistanceUnit);
    final themeModeIndex = _prefs.getInt(_keyThemeMode);
    final keepScreenAwake = _prefs.getBool(_keyKeepScreenAwake) ?? true;
    final gpsSmoothingIndex = _prefs.getInt(_keyGpsSmoothing);

    return UserSettings(
      speedUnit: speedUnitIndex != null && speedUnitIndex < SpeedUnit.values.length
          ? SpeedUnit.values[speedUnitIndex]
          : SpeedUnit.kmh,
      altitudeUnit: altitudeUnitIndex != null && altitudeUnitIndex < AltitudeUnit.values.length
          ? AltitudeUnit.values[altitudeUnitIndex]
          : AltitudeUnit.meters,
      distanceUnit: distanceUnitIndex != null && distanceUnitIndex < DistanceUnit.values.length
          ? DistanceUnit.values[distanceUnitIndex]
          : DistanceUnit.kilometers,
      themeMode: themeModeIndex != null && themeModeIndex < AppThemeMode.values.length
          ? AppThemeMode.values[themeModeIndex]
          : AppThemeMode.system,
      keepScreenAwake: keepScreenAwake,
      gpsSmoothing: gpsSmoothingIndex != null && gpsSmoothingIndex < GpsSmoothing.values.length
          ? GpsSmoothing.values[gpsSmoothingIndex]
          : GpsSmoothing.normal,
    );
  }

  /// Saves the complete user settings object.
  Future<void> saveSettings(UserSettings settings) async {
    await Future.wait([
      _prefs.setInt(_keySpeedUnit, settings.speedUnit.index),
      _prefs.setInt(_keyAltitudeUnit, settings.altitudeUnit.index),
      _prefs.setInt(_keyDistanceUnit, settings.distanceUnit.index),
      _prefs.setInt(_keyThemeMode, settings.themeMode.index),
      _prefs.setBool(_keyKeepScreenAwake, settings.keepScreenAwake),
      _prefs.setInt(_keyGpsSmoothing, settings.gpsSmoothing.index),
    ]);
  }
}
