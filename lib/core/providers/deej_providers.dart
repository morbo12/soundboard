import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/serialport_manager/class_serialport_provider_win32.dart';

/// StateNotifier that tracks the Deej analog board connection status
class DeejConnectionNotifier extends StateNotifier<bool> {
  DeejConnectionNotifier(this._ref) : super(false) {
    // Initial state check
    _updateConnectionStatus();

    // Set up a periodic check for connection status changes
    // Note: This is a simple approach - in a production app you'd want
    // the SerialPortManager to notify changes via callbacks
    _startMonitoring();
  }

  final Ref _ref;
  Timer? _monitoringTimer;

  void _startMonitoring() {
    // Simple polling approach - check every 2 seconds
    _monitoringTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _updateConnectionStatus();
      } else {
        timer.cancel();
      }
    });
  }

  void _updateConnectionStatus() {
    try {
      final serialPortManager = _ref.read(serialPortManagerWin32Provider);
      final newStatus = serialPortManager.isConnected;

      if (mounted && state != newStatus) {
        state = newStatus;
      }
    } catch (e) {
      // Handle the case where the provider might be disposed
      if (mounted) {
        state = false;
      }
    }
  }

  /// Manually trigger a connection status check
  void checkStatus() {
    if (mounted) {
      _updateConnectionStatus();
    }
  }

  @override
  void dispose() {
    _monitoringTimer?.cancel();
    super.dispose();
  }
}

/// Provider that tracks the Deej analog board connection status with auto-dispose for proper cleanup
final deejConnectionStatusProvider =
    StateNotifierProvider.autoDispose<DeejConnectionNotifier, bool>((ref) {
      return DeejConnectionNotifier(ref);
    });

// Contains AI-generated edits.
