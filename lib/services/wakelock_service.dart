import 'dart:developer' as developer;
import 'package:wakelock_plus/wakelock_plus.dart';

/// Service to keep the screen awake during active trips.
class WakelockService {
  bool _isWakelockEnabled = false;

  bool get isEnabled => _isWakelockEnabled;

  /// Enables device wakelock safely.
  Future<void> enable() async {
    try {
      await WakelockPlus.enable();
      _isWakelockEnabled = true;
    } catch (e) {
      developer.log('Failed to enable wakelock: $e', name: 'WakelockService');
    }
  }

  /// Disables device wakelock safely.
  Future<void> disable() async {
    try {
      await WakelockPlus.disable();
      _isWakelockEnabled = false;
    } catch (e) {
      developer.log('Failed to disable wakelock: $e', name: 'WakelockService');
    }
  }

  /// Restores normal screen behavior if enabled.
  Future<void> reset() async {
    if (_isWakelockEnabled) {
      await disable();
    }
  }
}
