import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../models/gps_status.dart';
import '../providers/settings_provider.dart';
import '../providers/trip_provider.dart';
import '../utils/formatters.dart';
import '../utils/unit_converter.dart';

/// Interactive world map screen showing real-time GPS location, direction, route breadcrumbs, and floating telemetry HUD.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  final MapController _mapController = MapController();
  bool _autoFollowUser = true;
  bool _useDarkStyle = true;
  double _currentZoom = 15.0;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.4).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _recenter(double lat, double lng) {
    setState(() {
      _autoFollowUser = true;
    });
    _mapController.move(LatLng(lat, lng), _currentZoom);
  }

  void _zoomIn() {
    _currentZoom = (_currentZoom + 1).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  void _zoomOut() {
    _currentZoom = (_currentZoom - 1).clamp(3.0, 18.0);
    _mapController.move(_mapController.camera.center, _currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    final tripProvider = context.watch<TripProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final tripState = tripProvider.state;

    final lat = tripState.latitude;
    final lng = tripState.longitude;
    final hasLocation = lat != null && lng != null;
    final currentPos = hasLocation ? LatLng(lat, lng) : const LatLng(39.9334, 32.8597); // Turkey default

    // Auto-follow user camera movement
    if (hasLocation && _autoFollowUser) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(currentPos, _mapController.camera.zoom);
        }
      });
    }

    final speedUnit = settingsProvider.speedUnit;
    final altUnit = settingsProvider.altitudeUnit;
    final distUnit = settingsProvider.distanceUnit;

    final speedVal = UnitConverter.convertSpeed(tripState.currentSpeedMs, speedUnit);
    final altVal = tripState.currentAltitudeM != null
        ? UnitConverter.convertAltitude(tripState.currentAltitudeM!, altUnit)
        : null;
    final distVal = UnitConverter.convertDistance(tripState.totalDistanceMeters, distUnit);

    final formattedSpeed = Formatters.formatSpeed(speedVal);
    final formattedAlt = Formatters.formatAltitude(altVal);
    final formattedDist = Formatters.formatDistance(distVal);

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: Stack(
        children: [
          // 1. Flutter Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: currentPos,
              initialZoom: _currentZoom,
              minZoom: 3.0,
              maxZoom: 18.0,
              onPositionChanged: (pos, hasGesture) {
                if (hasGesture && _autoFollowUser) {
                  setState(() {
                    _autoFollowUser = false;
                  });
                }
              },
            ),
            children: [
              // Tile Layer (Dark Matter or OpenStreetMap)
              TileLayer(
                urlTemplate: _useDarkStyle
                    ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
                    : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.bzdstudio.hizolcer',
              ),

              // Breadcrumb Route Trail
              if (tripState.routeTrail.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    // Outer glow
                    Polyline(
                      points: tripState.routeTrail,
                      color: AppTheme.darkPrimary.withAlpha(70),
                      strokeWidth: 8.0,
                    ),
                    // Core line
                    Polyline(
                      points: tripState.routeTrail,
                      color: AppTheme.darkPrimary,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),

              // Accuracy Circle
              if (hasLocation && tripState.gpsAccuracyM != null && tripState.gpsAccuracyM! < 200)
                CircleLayer(
                  circles: [
                    CircleMarker(
                      point: currentPos,
                      radius: math.min(tripState.gpsAccuracyM! * 0.8, 80.0),
                      useRadiusInMeter: false,
                      color: AppTheme.darkPrimary.withAlpha(30),
                      borderColor: AppTheme.darkPrimary.withAlpha(120),
                      borderStrokeWidth: 1.5,
                    ),
                  ],
                ),

              // User Location & Bearing Marker
              if (hasLocation)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPos,
                      width: 60,
                      height: 60,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Radar pulse wave
                              Container(
                                width: 36 * _pulseAnimation.value,
                                height: 36 * _pulseAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.darkPrimary.withAlpha(
                                    ((1.4 - _pulseAnimation.value) * 120).clamp(0, 255).toInt(),
                                  ),
                                ),
                              ),
                              // Core indicator with bearing
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.darkCard,
                                  border: Border.all(color: AppTheme.darkPrimary, width: 2.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.darkPrimary.withAlpha(150),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: tripState.heading != null
                                      ? Transform.rotate(
                                          angle: (tripState.heading! * math.pi / 180),
                                          child: const Icon(
                                            Icons.navigation_rounded,
                                            size: 20,
                                            color: AppTheme.darkPrimary,
                                          ),
                                        )
                                      : Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppTheme.darkPrimary,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // 2. Top Floating Telemetry HUD
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withAlpha(230),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.darkPrimary.withAlpha(80), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(150),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Speed Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HIZ',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedSpeed,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.darkPrimary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              speedUnit.label,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Divider
                    Container(height: 32, width: 1, color: Colors.white12),

                    // Altitude Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'RAKIM',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedAlt,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkSecondary,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              altUnit.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Divider
                    Container(height: 32, width: 1, color: Colors.white12),

                    // Distance Display
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'MESAFE',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              formattedDist,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontFeatures: [FontFeature.tabularFigures()],
                              ),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              distUnit.label,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Waiting for GPS Overlay
          if (!hasLocation && tripState.gpsStatus != GpsStatus.ready)
            Positioned(
              bottom: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.darkCard.withAlpha(240),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orangeAccent.withAlpha(150)),
                ),
                child: const Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.orangeAccent),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Hassas GPS konumu aranıyor...',
                        style: TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 4. Map Action Buttons (Right Side)
          Positioned(
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Style switch
                _buildMapFab(
                  icon: _useDarkStyle ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined,
                  tooltip: _useDarkStyle ? 'Açık Harita' : 'Karanlık Harita',
                  onTap: () {
                    setState(() {
                      _useDarkStyle = !_useDarkStyle;
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Zoom In
                _buildMapFab(
                  icon: Icons.add,
                  tooltip: 'Yakınlaştır',
                  onTap: _zoomIn,
                ),
                const SizedBox(height: 8),

                // Zoom Out
                _buildMapFab(
                  icon: Icons.remove,
                  tooltip: 'Uzaklaştır',
                  onTap: _zoomOut,
                ),
                const SizedBox(height: 10),

                // Recenter & Auto-Follow User
                _buildMapFab(
                  icon: _autoFollowUser ? Icons.gps_fixed : Icons.gps_not_fixed,
                  tooltip: 'Konumuma Odaklan',
                  isActive: _autoFollowUser,
                  onTap: () {
                    if (hasLocation) {
                      _recenter(lat, lng);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapFab({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: AppTheme.darkCard.withAlpha(230),
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? AppTheme.darkPrimary : Colors.white24,
          width: isActive ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isActive ? AppTheme.darkPrimary.withAlpha(80) : Colors.black45,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 22,
          color: isActive ? AppTheme.darkPrimary : Colors.white,
        ),
        tooltip: tooltip,
        onPressed: onTap,
      ),
    );
  }
}
