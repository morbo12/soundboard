import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Service for Text-to-Speech using the Soundboard API
class SoundboardTtsService {
  static const Logger _logger = Logger('SoundboardTtsService');
  final AuthService _authService;
  final SettingsBox _settings = SettingsBox();

  SoundboardTtsService(this._authService);

  /// Generate speech audio from text using the Soundboard API
  /// Returns binary audio data (MP3/WAV) that can be played directly
  /// Throws TtsApiException on error instead of returning null
  Future<Uint8List> generateSpeech(String text) async {
    try {
      // Get valid JWT token
      final token = await _authService.getValidToken();
      if (token == null) {
        _logger.e('No valid authentication token available');
        throw TtsApiException(
          statusCode: 401,
          message: 'No valid authentication token available',
        );
      }

      final voiceName = _settings.azVoiceName;
      _logger.i(
        'Generating speech for text: "${text.substring(0, text.length.clamp(0, 50))}", voice: $voiceName',
      );

      // Log full SSML for debugging TTS issues
      _logger.d('Full SSML text to be sent:\n$text');

      // Prepare request
      final uri = Uri.parse('${_settings.apiBaseUrl}/api/tts/synthesize');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'audio/webm', // Request WebM format
      };

      final body = jsonEncode({
        'text': text,
        'voice': voiceName,
        'format': 'webm-24khz-16bit-mono-opus', // Use WebM Opus format
        'isSsml': true, // Enable SSML processing
      });

      _logger.d('Making TTS request to: $uri');
      _logger.d('Request body: $body');

      // Make HTTP request
      http.Response response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        // Check content type to ensure we got audio
        final contentType = response.headers['content-type'] ?? '';
        if (contentType.startsWith('audio/')) {
          _logger.i(
            'Successfully generated speech audio (${response.bodyBytes.length} bytes)',
          );
          return response.bodyBytes;
        } else {
          _logger.e('Unexpected content type: $contentType');
          throw TtsApiException(
            statusCode: 200,
            message: 'Unexpected content type: $contentType (expected audio/*)',
          );
        }
      } else if (response.statusCode == 401) {
        _logger.w('Authentication failed (401). Attempting token refresh...');
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          final newToken = await _authService.getValidToken();
          if (newToken != null) {
            final retryHeaders = {
              ...headers,
              'Authorization': 'Bearer $newToken',
            };
            response = await http.post(uri, headers: retryHeaders, body: body);
            if (response.statusCode == 200 &&
                (response.headers['content-type'] ?? '').startsWith('audio/')) {
              _logger.i(
                'Successfully generated speech audio after token refresh (${response.bodyBytes.length} bytes)',
              );
              return response.bodyBytes;
            }
          }
        }
        _logger.w('Token refresh failed or retry unsuccessful. Clearing auth.');
        _authService.clearAuth();
        throw TtsApiException(
          statusCode: 401,
          message: 'Authentication failed and token refresh unsuccessful',
        );
      } else {
        final errorBody = response.body;
        _logger.e(
          'TTS request failed with status ${response.statusCode}: $errorBody',
        );
        throw TtsApiException(
          statusCode: response.statusCode,
          message: errorBody,
        );
      }
    } catch (e, stackTrace) {
      _logger.e('Error generating speech: $e', stackTrace);
      if (e is TtsApiException) {
        rethrow;
      }
      throw TtsApiException(
        statusCode: 0,
        message: 'Network or client error: $e',
      );
    }
  }

  /// Get available voices from the API
  Future<List<String>?> getAvailableVoices() async {
    try {
      final uri = Uri.parse('${_settings.apiBaseUrl}/api/tts/voices');
      // Voices endpoint may be public; try without auth first
      Map<String, String> headers = {'Content-Type': 'application/json'};

      _logger.d('Fetching available voices from: $uri');

      http.Response response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('voices')) {
          final voicesData = data['voices'] as List;
          final voices = voicesData
              .map((voice) => voice['name'] as String)
              .toList();
          _logger.i('Retrieved ${voices.length} available voices');
          return voices;
        } else {
          _logger.e('Unexpected response format for voices');
          return null;
        }
      } else if (response.statusCode == 401) {
        // Some deployments might require auth for voices; try with token and refresh if needed
        _logger.w('Voices endpoint requires auth. Trying with token...');
        final token = await _authService.getValidToken();
        if (token != null) {
          headers = {...headers, 'Authorization': 'Bearer $token'};
          response = await http.get(uri, headers: headers);
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data is Map && data.containsKey('voices')) {
              final voicesData = data['voices'] as List;
              final voices = voicesData
                  .map((voice) => voice['name'] as String)
                  .toList();
              _logger.i('Retrieved ${voices.length} available voices (auth)');
              return voices;
            }
          } else if (response.statusCode == 401) {
            _logger.w('Auth for voices failed. Attempting token refresh...');
            final refreshed = await _authService.refreshAccessToken();
            if (refreshed) {
              final newToken = await _authService.getValidToken();
              if (newToken != null) {
                headers['Authorization'] = 'Bearer $newToken';
                response = await http.get(uri, headers: headers);
                if (response.statusCode == 200) {
                  final data = jsonDecode(response.body);
                  if (data is Map && data.containsKey('voices')) {
                    final voicesData = data['voices'] as List;
                    final voices = voicesData
                        .map((voice) => voice['name'] as String)
                        .toList();
                    _logger.i(
                      'Retrieved ${voices.length} available voices (after refresh)',
                    );
                    return voices;
                  }
                }
              }
            }
          }
        }
        _logger.w('Unable to fetch voices due to authentication issues.');
        return null;
      } else {
        _logger.e(
          'Voices request failed with status ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Error fetching voices: $e', stackTrace);
      return null;
    }
  }

  /// Test the connection to the API
  Future<bool> testConnection() async {
    try {
      final token = await _authService.getValidToken();
      if (token == null) {
        return false;
      }

      final uri = Uri.parse('${_settings.apiBaseUrl}/api/health');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(uri, headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Connection test failed: $e');
      return false;
    }
  }
}

/// Exception thrown when TTS API returns an error
class TtsApiException implements Exception {
  final int statusCode;
  final String message;

  TtsApiException({required this.statusCode, required this.message});

  @override
  String toString() =>
      'TtsApiException(status: $statusCode, message: $message)';
}

// Contains AI-generated edits.
