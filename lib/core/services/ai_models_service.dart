import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soundboard/core/models/ai_model.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Service for fetching available AI models from the Soundboard API.
///
/// The Soundboard backend exposes `/api/ai/models` which returns
/// a list of supported AI models. This requires a valid API product key
/// and authentication token.
class AiModelsService {
  static const Logger _logger = Logger('AiModelsService');
  final AuthService _authService;
  final SettingsBox _settings = SettingsBox();

  AiModelsService(this._authService);

  /// Fetches the list of available AI models from the API.
  ///
  /// Returns an empty list if:
  /// - No API product key is configured
  /// - Authentication fails
  /// - The API request fails
  ///
  /// Throws an exception if the API returns an error response.
  Future<List<AiModel>> fetchModels() async {
    // AI is only available if there is an API Product key
    if (_settings.apiProductKey.trim().isEmpty) {
      _logger.w('No API product key configured, AI models not available');
      return [];
    }

    try {
      final token = await _authService.getValidToken();
      if (token == null) {
        _logger.w('No valid auth token available for AI models request');
        return [];
      }

      final uri = Uri.parse('${_settings.apiBaseUrl}/api/ai/models');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      _logger.d('Fetching AI models from: $uri');

      http.Response response = await http.get(uri, headers: headers);

      // If unauthorized, try token refresh and retry once
      if (response.statusCode == 401) {
        _logger.w('AI models request returned 401 — attempting token refresh');
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          final newToken = await _authService.getValidToken();
          if (newToken != null) {
            final retryHeaders = {
              ...headers,
              'Authorization': 'Bearer $newToken',
            };
            response = await http.get(uri, headers: retryHeaders);
          }
        }
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _logger.d('AI models response: $data');

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final modelsList = data['models'] as List?;
          if (modelsList != null) {
            final models = modelsList
                .map((json) => AiModel.fromJson(json as Map<String, dynamic>))
                .toList();
            _logger.i('Fetched ${models.length} AI models');
            return models;
          }
          _logger.w('AI models response missing "models" array');
          return [];
        } else {
          final errorMessage = data['message'] as String? ?? 'Unknown error';
          _logger.e('AI models request failed: $errorMessage');
          throw Exception('AI models request failed: $errorMessage');
        }
      } else {
        final errorMessage = data['message'] as String? ?? 'Unknown error';
        final status = data['status'] as int? ?? response.statusCode;
        _logger.e(
          'AI models request failed with status $status: $errorMessage',
        );
        throw Exception('AI models request failed: $status $errorMessage');
      }
    } catch (e, st) {
      _logger.e('Error fetching AI models: $e', st);
      // Return empty list on error rather than throwing
      return [];
    }
  }
}
