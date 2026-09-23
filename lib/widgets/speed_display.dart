import 'package:flutter/material.dart';
import '../utils/formatters.dart';
import '../utils/unit_converter.dart';

/// The central visual element of the SpeedAlt dashboard: Large, high-visibility current speed.
class SpeedDisplay extends StatelessWidget {
  final double currentSpeedMs;
  final SpeedUnit unit;
  final bool isTracking;

  const SpeedDisplay({
    super.key,
    required this.currentSpeedMs,
    required this.unit,
    required this.isTracking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final convertedSpeed = UnitConverter.convertSpeed(currentSpeedMs, unit);
    final speedText = Formatters.formatSpeed(convertedSpeed);

    // Primary speed color: Vibrant in dark mode, deep slate in light mode
    final speedColor = isDark
        ? const Color(0xFF00E5FF) // Electric Cyan
        : const Color(0xFF0F172A); // Slate 900

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Giant speed number
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            speedText,
            style: TextStyle(
              fontSize: 108,
              fontWeight: FontWeight.w900,
              height: 0.95,
              letterSpacing: -4,
              color: speedColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Unit label (km/h or mph)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            unit.label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }
}
