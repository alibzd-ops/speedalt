import 'package:flutter/material.dart';
import '../models/trip_state.dart';

/// Primary action controls at the bottom of the dashboard (START, PAUSE, STOP, RESUME, RESET).
class TripControls extends StatelessWidget {
  final TripStatus tripStatus;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onStop;
  final VoidCallback onReset;

  const TripControls({
    super.key,
    required this.tripStatus,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    required this.onStop,
    required this.onReset,
  });

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Reset current trip data?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'This will clear your current distance, duration, and maximum speed readings.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      onReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (tripStatus) {
      case TripStatus.idle:
        // Large Primary START button
        return SizedBox(
          width: double.infinity,
          height: 60,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: isDark ? const Color(0xFF00E5FF) : const Color(0xFF0284C7),
              foregroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              elevation: 4,
            ),
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow_rounded, size: 28),
            label: const Text(
              'START',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        );

      case TripStatus.running:
        // Dual controls: PAUSE & STOP
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton.tonalIcon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.amber.withValues(alpha: 0.2),
                    foregroundColor: Colors.amber.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onPause,
                  icon: const Icon(Icons.pause_rounded, size: 24),
                  label: const Text(
                    'PAUSE',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onStop,
                  icon: const Icon(Icons.stop_rounded, size: 24),
                  label: const Text(
                    'STOP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        );

      case TripStatus.paused:
        // Dual controls: RESUME & STOP
        return Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onResume,
                  icon: const Icon(Icons.play_arrow_rounded, size: 24),
                  label: const Text(
                    'RESUME',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: onStop,
                  icon: const Icon(Icons.stop_rounded, size: 24),
                  label: const Text(
                    'STOP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        );

      case TripStatus.stopped:
        // After STOP: Keep frozen statistics and provide RESET button
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: isDark ? Colors.white : const Color(0xFF0F172A),
              side: BorderSide(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                width: 1.5,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => _confirmReset(context),
            icon: const Icon(Icons.refresh_rounded, size: 24),
            label: const Text(
              'RESET TRIP',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        );
    }
  }
}
