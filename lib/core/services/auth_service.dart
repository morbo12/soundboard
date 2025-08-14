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

  // Determine API base URL from the product key format.
  // Convention: Keys starting with "SOUND-DEV-" use the DEV API, otherwise PROD.
  String _resolveBaseUrlFromKey(String productKey) {
    final key = productKey.trim().toUpperCase();
    const prodUrl = 'https://soundboard-api.fbtoolseu.workers.dev';
    const devUrl = 'https://soundboard-api-dev.fbtoolseu.workers.dev';
    if (key.startsWith('SOUND-DEV-')) return devUrl;
    return prodUrl;
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

      final effectiveBaseUrl = _resolveBaseUrlFromKey(productKey);

      final response = await http.post(
        Uri.parse('$effectiveBaseUrl/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'productKey': productKey, 'deviceId': deviceId}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final accessToken = data['tokens']['accessToken'] as String?;
          final refreshToken = data['tokens']['refreshToken'] as String?;
          final expiresIn = data['tokens']['expiresIn'] as int;

          // Store token and expiry
          if (accessToken != null) settings.apiToken = accessToken;
          if (refreshToken != null) settings.apiRefreshToken = refreshToken;
          // Persist the effective base URL so other services use the correct API
          settings.apiBaseUrl = effectiveBaseUrl;
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

    // Try refresh flow first if we have a refresh token
    final refreshed = await refreshAccessToken();
    if (refreshed) {
      return settings.apiToken;
    }

    // Fallback: Token is expired or missing, authenticate again
    final success = await authenticate();
    return success ? settings.apiToken : null;
  }

  /// Refresh an expired access token using refreshToken
  Future<bool> refreshAccessToken() async {
    try {
      final settings = SettingsBox();
      final refreshToken = settings.apiRefreshToken;
      if (refreshToken.isEmpty) {
        logger.w('No refresh token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccessToken =
              data['accessToken'] as String? ??
              data['tokens']?['accessToken'] as String?;
          final newRefreshToken =
              data['refreshToken'] as String? ??
              data['tokens']?['refreshToken'] as String?;
          final expiresIn =
              (data['expiresIn'] as int?) ??
              (data['tokens']?['expiresIn'] as int?) ??
              900;

          if (newAccessToken != null) settings.apiToken = newAccessToken;
          if (newRefreshToken != null)
            settings.apiRefreshToken = newRefreshToken;
          settings.apiTokenExpiry = DateTime.now().add(
            Duration(seconds: expiresIn - 300),
          );

          logger.d('Access token refreshed successfully');
          return true;
        }
      } else if (response.statusCode == 401) {
        logger.w('Refresh token invalid, clearing auth');
        clearAuth();
        return false;
      }

      logger.e(
        'Token refresh failed: ${response.statusCode} - ${response.body}',
      );
      return false;
    } catch (e, stackTrace) {
      logger.e('Token refresh error', e, stackTrace);
      return false;
    }
  }

  Future<bool> validateProductKey(String productKey) async {
    try {
      final effectiveBaseUrl = _resolveBaseUrlFromKey(productKey);
      final response = await http.post(
        Uri.parse('$effectiveBaseUrl/api/auth/validate-key'),
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
    settings.apiRefreshToken = "";
  }
}

// Contains AI-generated edits.
