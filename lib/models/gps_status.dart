import 'package:flutter/material.dart';

/// Represents the status of the device's GPS / Location service.
enum GpsStatus {
  searching('Searching for GPS...', Colors.amber, Icons.gps_not_fixed_rounded),
  ready('GPS Ready', Color(0xFF10B981), Icons.gps_fixed_rounded), // Emerald green
  poorSignal('Poor GPS Signal', Colors.deepOrangeAccent, Icons.gps_off_rounded),
  disabled('Location Disabled', Colors.redAccent, Icons.location_disabled_rounded),
  permissionDenied('Permission Denied', Colors.redAccent, Icons.location_off_rounded),
  permissionPermanentlyDenied('Permission Required', Colors.redAccent, Icons.settings_rounded);

  final String label;
  final Color color;
  final IconData icon;

  const GpsStatus(this.label, this.color, this.icon);

  bool get isReady => this == GpsStatus.ready;
  bool get isSearching => this == GpsStatus.searching;
  bool get hasIssues => this == GpsStatus.disabled ||
      this == GpsStatus.permissionDenied ||
      this == GpsStatus.permissionPermanentlyDenied;
}
