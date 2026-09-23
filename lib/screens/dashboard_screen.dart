import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/trip_provider.dart';
import '../utils/formatters.dart';
import '../utils/unit_converter.dart';
import '../widgets/altitude_display.dart';
import '../widgets/gps_status_badge.dart';
import '../widgets/permission_dialog.dart';
import '../widgets/speed_display.dart';
import '../widgets/stat_card.dart';
import '../widgets/trip_controls.dart';

/// The primary Dashboard screen of SpeedAlt.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleGpsResolution(BuildContext context, TripProvider tripProvider) {
    PermissionDialog.show(
      context,
      status: tripProvider.state.gpsStatus,
      onRequestPermission: () => tripProvider.requestLocationPermission(),
      onOpenLocationSettings: () => tripProvider.openLocationSettings(),
      onOpenAppSettings: () => tripProvider.openAppSettings(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final tripProvider = context.watch<TripProvider>();
    final state = tripProvider.state;

    final speedUnit = settingsProvider.speedUnit;
    final altitudeUnit = settingsProvider.altitudeUnit;
    final distanceUnit = settingsProvider.distanceUnit;

    // Convert statistics for display
    final avgSpeed = UnitConverter.convertSpeed(state.averageSpeedMs, speedUnit);
    final maxSpeed = UnitConverter.convertSpeed(state.maxSpeedMs, speedUnit);
    final distance = UnitConverter.convertDistance(state.totalDistanceMeters, distanceUnit);
    final durationText = Formatters.formatDuration(state.tripDuration);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SpeedAlt'),
        actions: [
          if (state.gpsStatus.hasIssues)
            IconButton(
              icon: Icon(state.gpsStatus.icon, color: state.gpsStatus.color),
              tooltip: state.gpsStatus.label,
              onPressed: () => _handleGpsResolution(context, tripProvider),
            ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 24,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // 1. GPS Status Badge & Coordinates
                      GpsStatusBadge(
                        status: state.gpsStatus,
                        accuracyMeters: state.gpsAccuracyM,
                        latitude: state.latitude,
                        longitude: state.longitude,
                        altitudeUnit: altitudeUnit,
                        onStatusTap: state.gpsStatus.hasIssues
                            ? () => _handleGpsResolution(context, tripProvider)
                            : null,
                      ),

                      const Spacer(flex: 1),

                      // 2. MAIN SPEEDOMETER (Giant, ultra-legible speed display)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: SpeedDisplay(
                          currentSpeedMs: state.currentSpeedMs,
                          unit: speedUnit,
                          isTracking: state.isTracking,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // 3. ALTIMETER DISPLAY
                      AltitudeDisplay(
                        altitudeMeters: state.currentAltitudeM,
                        accuracyMeters: state.altitudeAccuracyM,
                        unit: altitudeUnit,
                      ),

                      const Spacer(flex: 1),

                      // 4. FOUR STATISTIC CARDS (Average, Max, Distance, Duration)
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Average Speed',
                              value: Formatters.formatStatSpeed(avgSpeed),
                              unit: speedUnit.label,
                              icon: Icons.speed_rounded,
                              iconColor: const Color(0xFF6366F1),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Maximum Speed',
                              value: Formatters.formatStatSpeed(maxSpeed),
                              unit: speedUnit.label,
                              icon: Icons.trending_up_rounded,
                              iconColor: Colors.deepOrangeAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatCard(
                              label: 'Distance',
                              value: Formatters.formatDistance(distance),
                              unit: distanceUnit.label,
                              icon: Icons.route_rounded,
                              iconColor: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatCard(
                              label: 'Duration',
                              value: durationText,
                              icon: Icons.timer_outlined,
                              iconColor: Colors.amber,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(flex: 2),

                      // 5. TRIP ACTION CONTROLS (START / PAUSE / STOP / RESET)
                      Padding(
                        padding: const EdgeInsets.only(top: 16, bottom: 8),
                        child: TripControls(
                          tripStatus: state.tripStatus,
                          onStart: () => tripProvider.startTrip(),
                          onPause: () => tripProvider.pauseTrip(),
                          onResume: () => tripProvider.resumeTrip(),
                          onStop: () => tripProvider.stopTrip(),
                          onReset: () => tripProvider.resetTrip(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
