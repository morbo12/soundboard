import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/serialport_manager/class_serialport_provider_win32.dart';

/// Provider that tracks the Deej analog board connection status
final deejConnectionStatusProvider = Provider<bool>((ref) {
  final serialPortManager = ref.watch(serialPortManagerWin32Provider);
  return serialPortManager.isConnected;
});

// Contains AI-generated edits.
