// Provider for SerialPortManagerWin32
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/serialport_manager/class_serialport_manager_win32.dart';

// Provider for SerialPortManagerWin32
final serialPortManagerWin32Provider = Provider<SerialPortManagerWin32>((ref) {
  return SerialPortManagerWin32(ref: ref);
});
