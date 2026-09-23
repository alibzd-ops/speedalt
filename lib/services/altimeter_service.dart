import 'package:geolocator/geolocator.dart';

enum AltimeterSourceType {
  gps('GPS'),
  barometer('Barometer (Pressure)');

  final String label;
  const AltimeterSourceType(this.label);
}

/// Reading model produced by an altimeter source.
class AltimeterReading {
  final double altitudeMeters;
  final double? accuracyMeters;
  final AltimeterSourceType sourceType;

  const AltimeterReading({
    required this.altitudeMeters,
    this.accuracyMeters,
    required this.sourceType,
  });
}

/// Pluggable interface for altimeter sources.
/// Allows optional future barometer sensor integration without altering UI logic.
abstract class IAltimeterSource {
  AltimeterSourceType get type;
  bool get isAvailable;
  AltimeterReading? processPosition(Position position);
}

/// Primary GPS-based altimeter source using device satellite telemetry.
class GpsAltimeterSource implements IAltimeterSource {
  @override
  AltimeterSourceType get type => AltimeterSourceType.gps;

  @override
  bool get isAvailable => true;

  @override
  AltimeterReading? processPosition(Position position) {
    // Return GPS altitude and vertical accuracy
    final alt = position.altitude;
    if (alt.isNaN || alt.isInfinite) return null;

    return AltimeterReading(
      altitudeMeters: alt,
      accuracyMeters: position.altitudeAccuracy > 0 ? position.altitudeAccuracy : null,
      sourceType: AltimeterSourceType.gps,
    );
  }
}

/// Coordinator service managing altimeter reading retrieval.
class AltimeterService {
  final IAltimeterSource _primarySource;
  final IAltimeterSource? _secondarySource;

  AltimeterService({
    IAltimeterSource? primarySource,
    this._secondarySource,
  }) : _primarySource = primarySource ?? GpsAltimeterSource();

  /// Retrieves an altitude reading from the best available source.
  AltimeterReading? getReading(Position position) {
    if (_secondarySource != null && _secondarySource.isAvailable) {
      final reading = _secondarySource.processPosition(position);
      if (reading != null) return reading;
    }
    return _primarySource.processPosition(position);
  }
}
