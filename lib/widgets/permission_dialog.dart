import 'package:flutter/material.dart';
import '../models/gps_status.dart';

/// Modal dialog providing user-friendly location permission rationale and resolution actions.
class PermissionDialog extends StatelessWidget {
  final GpsStatus status;
  final VoidCallback onRequestPermission;
  final VoidCallback onOpenLocationSettings;
  final VoidCallback onOpenAppSettings;

  const PermissionDialog({
    super.key,
    required this.status,
    required this.onRequestPermission,
    required this.onOpenLocationSettings,
    required this.onOpenAppSettings,
  });

  /// Displays the rationale or resolution modal.
  static Future<void> show(
    BuildContext context, {
    required GpsStatus status,
    required VoidCallback onRequestPermission,
    required VoidCallback onOpenLocationSettings,
    required VoidCallback onOpenAppSettings,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => PermissionDialog(
        status: status,
        onRequestPermission: () {
          Navigator.of(ctx).pop();
          onRequestPermission();
        },
        onOpenLocationSettings: () {
          Navigator.of(ctx).pop();
          onOpenLocationSettings();
        },
        onOpenAppSettings: () {
          Navigator.of(ctx).pop();
          onOpenAppSettings();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Location Permission';
    String message =
        'SpeedAlt uses your location to calculate speed, altitude and travelled distance.';
    String primaryButtonText = 'Allow Location';
    VoidCallback primaryAction = onRequestPermission;
    IconData icon = Icons.location_on_rounded;

    if (status == GpsStatus.disabled) {
      title = 'Location Services Disabled';
      message =
          'Please enable your device location (GPS) services in system settings so SpeedAlt can track your speed and altitude.';
      primaryButtonText = 'Open Location Settings';
      primaryAction = onOpenLocationSettings;
      icon = Icons.location_disabled_rounded;
    } else if (status == GpsStatus.permissionPermanentlyDenied) {
      title = 'Location Permission Required';
      message =
          'Location access is permanently denied. To enable speed and altitude tracking, please grant Location permissions in App Settings.';
      primaryButtonText = 'Open App Settings';
      primaryAction = onOpenAppSettings;
      icon = Icons.settings_rounded;
    } else if (status == GpsStatus.permissionDenied) {
      title = 'Location Access Needed';
      message =
          'SpeedAlt cannot compute your current speed, altitude, or distance without location permission. All GPS data stays strictly on your device.';
      primaryButtonText = 'Grant Permission';
      primaryAction = onRequestPermission;
      icon = Icons.lock_outline_rounded;
    }

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: const TextStyle(fontSize: 14, height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: primaryAction,
          child: Text(primaryButtonText),
        ),
      ],
    );
  }
}
