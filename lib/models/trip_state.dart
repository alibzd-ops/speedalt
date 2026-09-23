import 'gps_status.dart';

enum TripStatus {
  idle,
  running,
  paused,
  stopped,
}

/// Represents the active state of GPS speed, altitude, and trip metrics.
class TripState {
  final TripStatus tripStatus;
  final GpsStatus gpsStatus;
  final double currentSpeedMs;
  final double maxSpeedMs;
  final double averageSpeedMs;
  final double? currentAltitudeM;
  final double? altitudeAccuracyM;
  final double totalDistanceMeters;
  final Duration tripDuration;
  final Duration movingDuration;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracyM;

  const TripState({
    this.tripStatus = TripStatus.idle,
    this.gpsStatus = GpsStatus.searching,
    this.currentSpeedMs = 0.0,
    this.maxSpeedMs = 0.0,
    this.averageSpeedMs = 0.0,
    this.currentAltitudeM,
    this.altitudeAccuracyM,
    this.totalDistanceMeters = 0.0,
    this.tripDuration = Duration.zero,
    this.movingDuration = Duration.zero,
    this.latitude,
    this.longitude,
    this.gpsAccuracyM,
  });

  bool get isTracking => tripStatus == TripStatus.running;
  bool get isPaused => tripStatus == TripStatus.paused;
  bool get isStopped => tripStatus == TripStatus.stopped;
  bool get isIdle => tripStatus == TripStatus.idle;

  bool get isAltitudeAccuracyPoor =>
      altitudeAccuracyM != null && altitudeAccuracyM! > 25.0;

  TripState copyWith({
    TripStatus? tripStatus,
    GpsStatus? gpsStatus,
    double? currentSpeedMs,
    double? maxSpeedMs,
    double? averageSpeedMs,
    double? currentAltitudeM,
    double? altitudeAccuracyM,
    double? totalDistanceMeters,
    Duration? tripDuration,
    Duration? movingDuration,
    double? latitude,
    double? longitude,
    double? gpsAccuracyM,
    bool clearCoordinates = false,
  }) {
    return TripState(
      tripStatus: tripStatus ?? this.tripStatus,
      gpsStatus: gpsStatus ?? this.gpsStatus,
      currentSpeedMs: currentSpeedMs ?? this.currentSpeedMs,
      maxSpeedMs: maxSpeedMs ?? this.maxSpeedMs,
      averageSpeedMs: averageSpeedMs ?? this.averageSpeedMs,
      currentAltitudeM: currentAltitudeM ?? this.currentAltitudeM,
      altitudeAccuracyM: altitudeAccuracyM ?? this.altitudeAccuracyM,
      totalDistanceMeters: totalDistanceMeters ?? this.totalDistanceMeters,
      tripDuration: tripDuration ?? this.tripDuration,
      movingDuration: movingDuration ?? this.movingDuration,
      latitude: clearCoordinates ? null : (latitude ?? this.latitude),
      longitude: clearCoordinates ? null : (longitude ?? this.longitude),
      gpsAccuracyM: clearCoordinates ? null : (gpsAccuracyM ?? this.gpsAccuracyM),
    );
  }

  /// Initial idle state.
  static const initial = TripState();
}
