/// Supported measurement units for Speed, Altitude, and Distance.
enum SpeedUnit {
  kmh('km/h'),
  mph('mph');

  final String label;
  const SpeedUnit(this.label);
}

enum AltitudeUnit {
  meters('m'),
  feet('ft');

  final String label;
  const AltitudeUnit(this.label);
}

enum DistanceUnit {
  kilometers('km'),
  miles('mi');

  final String label;
  const DistanceUnit(this.label);
}

/// Robust and pure conversion utility methods.
class UnitConverter {
  UnitConverter._();

  // Constants for precise conversions
  static const double msToKmhFactor = 3.6;
  static const double msToMphFactor = 2.2369362920544;
  static const double metersToFeetFactor = 3.2808398950131;
  static const double kmToMilesFactor = 0.62137119223733;

  /// Converts meters per second (m/s) to kilometers per hour (km/h).
  static double msToKmh(double ms) {
    if (ms <= 0.0) return 0.0;
    return ms * msToKmhFactor;
  }

  /// Converts meters per second (m/s) to miles per hour (mph).
  static double msToMph(double ms) {
    if (ms <= 0.0) return 0.0;
    return ms * msToMphFactor;
  }

  /// Converts meters to feet.
  static double metersToFeet(double meters) {
    return meters * metersToFeetFactor;
  }

  /// Converts feet to meters.
  static double feetToMeters(double feet) {
    return feet / metersToFeetFactor;
  }

  /// Converts meters to kilometers.
  static double metersToKm(double meters) {
    if (meters <= 0.0) return 0.0;
    return meters / 1000.0;
  }

  /// Converts meters to miles.
  static double metersToMiles(double meters) {
    if (meters <= 0.0) return 0.0;
    return (meters / 1000.0) * kmToMilesFactor;
  }

  /// Converts kilometers to miles.
  static double kmToMiles(double km) {
    if (km <= 0.0) return 0.0;
    return km * kmToMilesFactor;
  }

  /// Converts miles to kilometers.
  static double milesToKm(double miles) {
    if (miles <= 0.0) return 0.0;
    return miles / kmToMilesFactor;
  }

  /// Converts speed in m/s to the selected [SpeedUnit].
  static double convertSpeed(double ms, SpeedUnit unit) {
    switch (unit) {
      case SpeedUnit.kmh:
        return msToKmh(ms);
      case SpeedUnit.mph:
        return msToMph(ms);
    }
  }

  /// Converts altitude in meters to the selected [AltitudeUnit].
  static double convertAltitude(double meters, AltitudeUnit unit) {
    switch (unit) {
      case AltitudeUnit.meters:
        return meters;
      case AltitudeUnit.feet:
        return metersToFeet(meters);
    }
  }

  /// Converts distance in meters to the selected [DistanceUnit].
  static double convertDistance(double meters, DistanceUnit unit) {
    switch (unit) {
      case DistanceUnit.kilometers:
        return metersToKm(meters);
      case DistanceUnit.miles:
        return metersToMiles(meters);
    }
  }
}
