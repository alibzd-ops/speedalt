import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../models/gps_status.dart';
import '../models/user_settings.dart';

/// Clean data class representing a validated, filtered location update.
class FilteredLocationData {
  final double currentSpeedMs;
  final double? altitudeM;
  final double? altitudeAccuracyM;
  final double distanceDeltaMeters;
  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final bool isStationary;
  final bool isValidForMaxSpeed;
  final DateTime timestamp;

  const FilteredLocationData({
    required this.currentSpeedMs,
    this.altitudeM,
    this.altitudeAccuracyM,
    required this.distanceDeltaMeters,
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    required this.isStationary,
    required this.isValidForMaxSpeed,
    required this.timestamp,
  });
}

/// Service managing GPS permissions, location streams, and strict data quality filtering.
class LocationService {
  // Max realistic speed threshold: ~500 km/h (138.8 m/s) to drop absurd GPS teleportation spikes.
  static const double maxRealisticSpeedMs = 138.8;

  // Max realistic acceleration threshold: ~15 m/s² (~54 km/h per second)
  static const double maxRealisticAccelerationMs2 = 15.0;

  Position? _lastValidPosition;
  double _lastFilteredSpeedMs = 0.0;
  DateTime? _lastTimestamp;

  /// Resets internal filtering memory for a new session.
  void resetFilter() {
    _lastValidPosition = null;
    _lastFilteredSpeedMs = 0.0;
    _lastTimestamp = null;
  }

  /// Checks the current location service and permission status.
  Future<GpsStatus> checkStatus() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return GpsStatus.disabled;
    }

    final permission = await Geolocator.checkPermission();
    switch (permission) {
      case LocationPermission.denied:
        return GpsStatus.permissionDenied;
      case LocationPermission.deniedForever:
        return GpsStatus.permissionPermanentlyDenied;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        return GpsStatus.searching;
      case LocationPermission.unableToDetermine:
        return GpsStatus.permissionDenied;
    }
  }

  /// Requests foreground location permission from the OS.
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Opens the device OS location settings.
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Opens the app settings page in the device OS.
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Creates a responsive, high-accuracy position stream.
  Stream<Position> getPositionStream() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 0, // Continuous stream for instantaneous speed readings
    );
    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Filters and validates raw GPS readings according to user settings and physics heuristics.
  FilteredLocationData? processPosition(
    Position position,
    GpsSmoothing smoothing,
  ) {
    final now = position.timestamp;
    final accuracy = position.accuracy;

    // Reject positions with impossible coordinates
    if (position.latitude < -90.0 ||
        position.latitude > 90.0 ||
        position.longitude < -180.0 ||
        position.longitude > 180.0) {
      return null;
    }

    // Reject readings where accuracy is worse than threshold
    if (accuracy > smoothing.accuracyThresholdMeters) {
      return null;
    }

    double rawSpeed = position.speed;
    final timeDelta = _lastTimestamp != null
        ? now.difference(_lastTimestamp!).inMilliseconds / 1000.0
        : 1.0;

    // Fallback: calculate speed from geographic distance if GPS speed is negative/unsupported
    if (rawSpeed < 0 && _lastValidPosition != null && timeDelta > 0.3) {
      final distance = Geolocator.distanceBetween(
        _lastValidPosition!.latitude,
        _lastValidPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      rawSpeed = distance / timeDelta;
    }

    // Clamp negative speeds to 0
    if (rawSpeed < 0 || rawSpeed.isNaN || rawSpeed.isInfinite) {
      rawSpeed = 0.0;
    }

    // Check for impossible sudden speed spike (teleportation or severe glitch)
    bool isSpike = false;
    if (rawSpeed > maxRealisticSpeedMs) {
      isSpike = true;
    } else if (_lastTimestamp != null && timeDelta > 0.1) {
      final acceleration = (rawSpeed - _lastFilteredSpeedMs).abs() / timeDelta;
      if (acceleration > maxRealisticAccelerationMs2 && rawSpeed > 10.0) {
        // Unrealistic acceleration jump
        isSpike = true;
      }
    }

    if (isSpike) {
      // Retain previous filtered speed, don't allow spike to pollute stats
      rawSpeed = _lastFilteredSpeedMs;
    }

    // Apply stationary threshold: stabilize at 0 instead of 1-3 km/h GPS noise
    final isStationary = rawSpeed < smoothing.stationaryCutoffMs;
    final double finalSpeed = isStationary ? 0.0 : rawSpeed;

    // Smooth speed slightly using simple weighted average for needle/number stability
    final double smoothedSpeed = isStationary
        ? 0.0
        : (_lastFilteredSpeedMs * 0.3 + finalSpeed * 0.7);

    // Calculate travelled distance delta
    double distanceDelta = 0.0;
    if (_lastValidPosition != null && !isStationary) {
      final calculatedDistance = Geolocator.distanceBetween(
        _lastValidPosition!.latitude,
        _lastValidPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // Prevent GPS drift: ignore tiny movements when stationary or within accuracy jitter
      if (calculatedDistance >= 1.5 && calculatedDistance <= (rawSpeed * timeDelta + accuracy)) {
        distanceDelta = calculatedDistance;
      }
    }

    _lastValidPosition = position;
    _lastFilteredSpeedMs = smoothedSpeed;
    _lastTimestamp = now;

    // Allow maximum speed update only if reading is reliable and not a spike
    final bool isValidForMax = !isSpike && accuracy <= smoothing.accuracyThresholdMeters;

    return FilteredLocationData(
      currentSpeedMs: smoothedSpeed,
      altitudeM: position.altitude.isNaN ? null : position.altitude,
      altitudeAccuracyM: position.altitudeAccuracy > 0 ? position.altitudeAccuracy : null,
      distanceDeltaMeters: distanceDelta,
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: accuracy,
      isStationary: isStationary,
      isValidForMaxSpeed: isValidForMax,
      timestamp: now,
    );
  }
}
