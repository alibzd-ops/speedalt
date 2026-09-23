import 'unit_converter.dart';

/// Formatter utilities for UI presentation.
class Formatters {
  Formatters._();

  /// Formats duration as HH:MM:SS (e.g. 00:34:18)
  static String formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Formats speed as a large, readable integer string (e.g. "72" or "0").
  static String formatSpeed(double speed) {
    if (speed.isNaN || speed.isInfinite || speed <= 0.0) {
      return '0';
    }
    // Round to nearest whole number for dashboard legibility
    return speed.round().toString();
  }

  /// Formats speed with one decimal for statistic cards if needed (e.g. "61.4").
  static String formatStatSpeed(double speed) {
    if (speed.isNaN || speed.isInfinite || speed <= 0.0) {
      return '0';
    }
    return speed.toStringAsFixed(1);
  }

  /// Formats altitude as a rounded integer (e.g. "845").
  static String formatAltitude(double? altitude) {
    if (altitude == null || altitude.isNaN || altitude.isInfinite) {
      return '--';
    }
    return altitude.round().toString();
  }

  /// Formats distance with one decimal place (e.g. "28.4").
  static String formatDistance(double distance) {
    if (distance.isNaN || distance.isInfinite || distance <= 0.0) {
      return '0.0';
    }
    return distance.toStringAsFixed(1);
  }

  /// Formats GPS accuracy (e.g. "±5 m" or "±16 ft").
  static String formatAccuracy(double? accuracyMeters, AltitudeUnit unit) {
    if (accuracyMeters == null || accuracyMeters.isNaN || accuracyMeters.isInfinite) {
      return '±--';
    }
    final converted = UnitConverter.convertAltitude(accuracyMeters, unit);
    return '±${converted.round()} ${unit.label}';
  }

  /// Formats latitude coordinate string with N/S hemisphere.
  static String formatLatitude(double? lat) {
    if (lat == null) return '--';
    final direction = lat >= 0 ? 'N' : 'S';
    return '${lat.abs().toStringAsFixed(4)}° $direction';
  }

  /// Formats longitude coordinate string with E/W hemisphere.
  static String formatLongitude(double? lon) {
    if (lon == null) return '--';
    final direction = lon >= 0 ? 'E' : 'W';
    return '${lon.abs().toStringAsFixed(4)}° $direction';
  }
}
