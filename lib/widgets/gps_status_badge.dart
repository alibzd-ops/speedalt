import 'package:flutter/material.dart';
import '../models/gps_status.dart';
import '../utils/formatters.dart';
import '../utils/unit_converter.dart';

/// Displays GPS connectivity status badge, accuracy, and current latitude/longitude coordinates.
class GpsStatusBadge extends StatelessWidget {
  final GpsStatus status;
  final double? accuracyMeters;
  final double? latitude;
  final double? longitude;
  final AltitudeUnit altitudeUnit;
  final VoidCallback? onStatusTap;

  const GpsStatusBadge({
    super.key,
    required this.status,
    required this.accuracyMeters,
    required this.latitude,
    required this.longitude,
    required this.altitudeUnit,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final formattedAccuracy = Formatters.formatAccuracy(accuracyMeters, altitudeUnit);
    final formattedLat = Formatters.formatLatitude(latitude);
    final formattedLon = Formatters.formatLongitude(longitude);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161B22) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // GPS Status Row + Accuracy
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Status chip (tappable if issue exists to prompt permissions/settings)
              InkWell(
                onTap: onStatusTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: status.color,
                          boxShadow: [
                            BoxShadow(
                              color: status.color.withValues(alpha: 0.5),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        status.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : const Color(0xFF334155),
                        ),
                      ),
                      if (status.hasIssues) ...[
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 10, color: status.color),
                      ],
                    ],
                  ),
                ),
              ),

              // Accuracy
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    size: 14,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'GPS Accuracy: $formattedAccuracy',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Divider(height: 12, thickness: 0.5),

          // Coordinates Row (Latitude & Longitude)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.explore_outlined,
                    size: 13,
                    color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lat: $formattedLat',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Text(
                'Lon: $formattedLon',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
