import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/unit_converter.dart';

/// Altimeter widget displaying current altitude and vertical accuracy indicator.
class AltitudeDisplay extends StatelessWidget {
  final double? altitudeMeters;
  final double? accuracyMeters;
  final AltitudeUnit unit;

  const AltitudeDisplay({
    super.key,
    required this.altitudeMeters,
    required this.accuracyMeters,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final convertedAltitude = altitudeMeters != null
        ? UnitConverter.convertAltitude(altitudeMeters!, unit)
        : null;
    final altitudeText = Formatters.formatAltitude(convertedAltitude);

    final isAccuracyPoor = accuracyMeters != null && accuracyMeters! > 25.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF161B22)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.terrain_rounded,
            size: 24,
            color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Altitude',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    altitudeText,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    unit.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  if (isAccuracyPoor) ...[
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Altitude accuracy is currently low',
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline_rounded, size: 12, color: Colors.amber),
                            SizedBox(width: 4),
                            Text(
                              'Low precision',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
