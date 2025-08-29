// Provider for SerialPortManagerWin32
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/serialport_manager/class_serialport_manager_win32.dart';

// Provider for SerialPortManagerWin32 with proper disposal handling
final serialPortManagerWin32Provider = Provider<SerialPortManagerWin32>((ref) {
  final manager = SerialPortManagerWin32(ref: ref);

  // Register a callback to handle app lifecycle changes for disposal
  // This will be called when the app is terminated or when providers are reset
  ref.onDispose(() {
    manager.dispose();
  });

  return manager;
});
