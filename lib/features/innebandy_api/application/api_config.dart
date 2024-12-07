import 'package:flutter/foundation.dart';

class APIConfig {
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
  static const int sendTimeout = 30000; // 30 seconds

  static const int maxRetries = 3;
  static const int retryDelay = 1000; // 1 second

  static void log(String message) {
    if (kDebugMode) {
      print(message);
    }
  }
}
