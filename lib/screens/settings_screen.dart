import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_settings.dart';
import '../providers/settings_provider.dart';
import '../utils/unit_converter.dart';
import 'about_screen.dart';

/// The Settings screen allowing unit customization, theme selection, wakelock, and GPS filters.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = context.watch<SettingsProvider>();
    final settings = settingsProvider.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Units
          _buildSectionHeader('MEASUREMENT UNITS'),
          Card(
            child: Column(
              children: [
                // Speed Unit
                ListTile(
                  leading: const Icon(Icons.speed_rounded),
                  title: const Text('Speed Unit', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: SegmentedButton<SpeedUnit>(
                    segments: const [
                      ButtonSegment(value: SpeedUnit.kmh, label: Text('km/h')),
                      ButtonSegment(value: SpeedUnit.mph, label: Text('mph')),
                    ],
                    selected: {settings.speedUnit},
                    onSelectionChanged: (selected) {
                      settingsProvider.setSpeedUnit(selected.first);
                    },
                  ),
                ),
                const Divider(height: 1),

                // Altitude Unit
                ListTile(
                  leading: const Icon(Icons.terrain_rounded),
                  title: const Text('Altitude Unit', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: SegmentedButton<AltitudeUnit>(
                    segments: const [
                      ButtonSegment(value: AltitudeUnit.meters, label: Text('meters')),
                      ButtonSegment(value: AltitudeUnit.feet, label: Text('feet')),
                    ],
                    selected: {settings.altitudeUnit},
                    onSelectionChanged: (selected) {
                      settingsProvider.setAltitudeUnit(selected.first);
                    },
                  ),
                ),
                const Divider(height: 1),

                // Distance Unit
                ListTile(
                  leading: const Icon(Icons.route_rounded),
                  title: const Text('Distance Unit', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: SegmentedButton<DistanceUnit>(
                    segments: const [
                      ButtonSegment(value: DistanceUnit.kilometers, label: Text('km')),
                      ButtonSegment(value: DistanceUnit.miles, label: Text('mi')),
                    ],
                    selected: {settings.distanceUnit},
                    onSelectionChanged: (selected) {
                      settingsProvider.setDistanceUnit(selected.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2: Display & Power
          _buildSectionHeader('DISPLAY & POWER'),
          Card(
            child: Column(
              children: [
                // Theme Mode
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme', style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: SegmentedButton<AppThemeMode>(
                    segments: const [
                      ButtonSegment(value: AppThemeMode.system, label: Text('System')),
                      ButtonSegment(value: AppThemeMode.light, label: Text('Light')),
                      ButtonSegment(value: AppThemeMode.dark, label: Text('Dark')),
                    ],
                    selected: {settings.themeMode},
                    onSelectionChanged: (selected) {
                      settingsProvider.setThemeMode(selected.first);
                    },
                  ),
                ),
                const Divider(height: 1),

                // Keep Screen Awake
                SwitchListTile(
                  secondary: const Icon(Icons.screen_lock_portrait_rounded),
                  title: const Text('Keep Screen Awake', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text(
                    'Prevents phone display from sleeping while tracking is active',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: settings.keepScreenAwake,
                  onChanged: (val) {
                    settingsProvider.setKeepScreenAwake(val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 3: GPS Data Quality
          _buildSectionHeader('GPS ACCURACY & NOISE FILTERING'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.tune_rounded),
                  title: const Text('GPS Smoothing', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    settings.gpsSmoothing == GpsSmoothing.normal
                        ? 'Balanced responsiveness and drift prevention'
                        : 'Strict filtering, ideal for open highways and high speed',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: SegmentedButton<GpsSmoothing>(
                    segments: const [
                      ButtonSegment(value: GpsSmoothing.normal, label: Text('Normal')),
                      ButtonSegment(value: GpsSmoothing.highAccuracy, label: Text('High')),
                    ],
                    selected: {settings.gpsSmoothing},
                    onSelectionChanged: (selected) {
                      settingsProvider.setGpsSmoothing(selected.first);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 4: Information
          _buildSectionHeader('ABOUT'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text('About SpeedAlt', style: TextStyle(fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AboutScreen()),
                );
              },
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
