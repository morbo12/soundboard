// lib/utils/logger.dart
import 'package:flutter/foundation.dart';

enum LogLevel { verbose, debug, info, warning, error, nothing }

class Logger {
  final String tag;
  static LogLevel level = kDebugMode ? LogLevel.verbose : LogLevel.warning;

  const Logger(this.tag);

  void v(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.verbose, message, error, stackTrace);
  }

  void d(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.debug, message, error, stackTrace);
  }

  void i(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.info, message, error, stackTrace);
  }

  void w(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.warning, message, error, stackTrace);
  }

  void e(String message, [Object? error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, error, stackTrace);
  }

  void _log(LogLevel msgLevel, String message,
      [Object? error, StackTrace? stackTrace]) {
    if (msgLevel.index < level.index) return;

    final DateTime now = DateTime.now();
    final String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}";
    final String prefix = "$formattedTime [$tag] ${getLevelTag(msgLevel)}:";

    debugPrint('$prefix $message');
    if (error != null) debugPrint('$prefix Error: $error');
    if (stackTrace != null) debugPrint('$prefix StackTrace: $stackTrace');
  }

  String getLevelTag(LogLevel level) {
    switch (level) {
      case LogLevel.verbose:
        return 'V';
      case LogLevel.debug:
        return 'D';
      case LogLevel.info:
        return 'I';
      case LogLevel.warning:
        return 'W';
      case LogLevel.error:
        return 'E';
      default:
        return '?';
    }
  }

  // Configure global log level
  static void setLogLevel(LogLevel newLevel) {
    level = newLevel;
  }
}
