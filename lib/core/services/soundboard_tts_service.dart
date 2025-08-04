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
  Future<Uint8List?> generateSpeech(String text) async {
    try {
      // Get valid JWT token
      final token = await _authService.getValidToken();
      if (token == null) {
        _logger.e('No valid authentication token available');
        return null;
      }

      final voiceName = _settings.azVoiceName;
      _logger.i(
        'Generating speech for text: "${text.substring(0, text.length.clamp(0, 50))}", voice: $voiceName',
      );

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

      // Make HTTP request
      final response = await http.post(uri, headers: headers, body: body);

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
          return null;
        }
      } else if (response.statusCode == 401) {
        _logger.w('Authentication failed, clearing token');
        _authService.clearAuth();
        return null;
      } else {
        _logger.e(
          'TTS request failed with status ${response.statusCode}: ${response.body}',
        );
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e('Error generating speech: $e', stackTrace);
      return null;
    }
  }

  /// Get available voices from the API
  Future<List<String>?> getAvailableVoices() async {
    try {
      final token = await _authService.getValidToken();
      if (token == null) {
        _logger.e('No valid authentication token available');
        return null;
      }

      final uri = Uri.parse('${_settings.apiBaseUrl}/api/tts/voices');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      _logger.d('Fetching available voices from: $uri');

      final response = await http.get(uri, headers: headers);

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
        _logger.w('Authentication failed, clearing token');
        _authService.clearAuth();
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
