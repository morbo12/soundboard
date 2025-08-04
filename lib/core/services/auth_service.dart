import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/device_id_manager.dart';
import 'package:soundboard/core/utils/logger.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

final authTokenProvider = StateProvider<String?>((ref) => null);

class AuthService {
  final Ref ref;
  final Logger logger = const Logger('AuthService');

  AuthService(this.ref);

  String get baseUrl {
    final settings = SettingsBox();
    return settings.apiBaseUrl;
  }

  Future<bool> authenticate() async {
    try {
      final settings = SettingsBox();
      final productKey = settings.apiProductKey;

      // Get or generate device ID
      final deviceId = DeviceIdManager.getDeviceId();

      if (productKey.isEmpty) {
        logger.w('No product key configured');
        return false;
      }

      logger.i('Authenticating with device ID: ${deviceId.substring(0, 8)}...');

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productKey': productKey, 'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final accessToken = data['tokens']['accessToken'];
          final expiresIn = data['tokens']['expiresIn'] as int;

          // Store token and expiry
          settings.apiToken = accessToken;
          settings.apiTokenExpiry = DateTime.now().add(
            Duration(
              seconds: expiresIn - 300,
            ), // Refresh 5 minutes before expiry
          );

          logger.d('Authentication successful');
          return true;
        }
      }

      logger.e(
        'Authentication failed: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e, stackTrace) {
      logger.e('Authentication error', e, stackTrace);
      return false;
    }
  }

  Future<String?> getValidToken() async {
    final settings = SettingsBox();

    // Check if we have a stored token and it's not expired
    final storedToken = settings.apiToken;
    final tokenExpiry = settings.apiTokenExpiry;

    if (storedToken.isNotEmpty && DateTime.now().isBefore(tokenExpiry)) {
      return storedToken;
    }

    // Token is expired or missing, authenticate again
    final success = await authenticate();
    return success ? settings.apiToken : null;
  }

  Future<bool> validateProductKey(String productKey) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/validate-key'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productKey': productKey}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true && data['valid'] == true;
      }

      return false;
    } catch (e, stackTrace) {
      logger.e('Product key validation error', e, stackTrace);
      return false;
    }
  }

  void clearAuth() {
    final settings = SettingsBox();
    settings.apiToken = "";
    settings.apiTokenExpiry = DateTime.utc(2024, 1, 1);
  }
}

// Contains AI-generated edits.
