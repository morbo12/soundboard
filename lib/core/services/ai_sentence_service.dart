import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Service for generating sports announcement sentences using the Soundboard API.
///
/// The Soundboard backend exposes `/api/ai/chat` and `/api/ai/completions` and
/// requires a Bearer token. This service uses the app's `AuthService` to obtain
/// a valid token and forwards the chat completion request to the backend. This keeps
/// API keys out of the client and reuses the same auth flow as the TTS service.
///
/// The API follows OpenAI Chat Completions format with `choices` array in response.
class AiSentenceService {
  static const Logger _logger = Logger('AiSentenceService');
  final AuthService _authService;
  final SettingsBox _settings = SettingsBox();

  AiSentenceService(this._authService);

  /// Generates a list of sports announcement sentences.
  ///
  /// The Soundboard API follows OpenAI Chat Completions format and returns
  /// a single completion in choices[0].message.content. We return a list
  /// with one element. Multiple suggestions would require multiple API calls
  /// or backend support for multiple choices.
  Future<List<String>> generateSentences({
    required String prompt,
    int n = 4,
    double temperature = 0.4,
    int maxTokens = 2000,
    String systemPrompt =
        'Du är en lågmäld, professionell svensk sportkommentator i ett sekretariat på en innebandymatch. Ditt enda uppdrag är att sakligt och tydligt annonsera mål, assist eller utvisning, alltid med aktuell matchtid. Använd aldrig slang eller onödiga utrop. Variera formulering och meningsbyggnad mellan varje förslag, så att de skiljer sig tydligt från varandra. Skapa alltid två exampel på mål och två för utvisning. Exempel på rätt stil: "Nummer 10 Pelle Karlsson gör 2-0 till hemmalaget. Tiden 10:45", "Nummer 22 Foo Bar utvisas 2 minuter för slag", "Hemmalaget gör 3-0, mål av nummer 11 Morris F, assist av nummer 6 Charlie L".',
  }) async {
    try {
      final token = await _authService.getValidToken();
      if (token == null) {
        throw Exception('No valid auth token available for AI request');
      }

      final uri = Uri.parse('${_settings.apiBaseUrl}/api/ai/chat');
      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final body = jsonEncode({
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': prompt},
        ],
        'model': _settings.aiModel,
        'temperature': temperature,
        'maxTokens': maxTokens,
      });

      _logger.d('Requesting AI chat completion from: $uri');
      _logger.d('Request body: $body');

      http.Response response = await http.post(
        uri,
        headers: headers,
        body: body,
      );

      // If unauthorized, try token refresh and retry once
      if (response.statusCode == 401) {
        _logger.w('AI chat completion returned 401 — attempting token refresh');
        final refreshed = await _authService.refreshAccessToken();
        if (refreshed) {
          final newToken = await _authService.getValidToken();
          if (newToken != null) {
            final retryHeaders = {
              ...headers,
              'Authorization': 'Bearer $newToken',
            };
            response = await http.post(uri, headers: retryHeaders, body: body);
          }
        }
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      _logger.d('AI response: $data');

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final choices = data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final firstChoice = choices[0] as Map<String, dynamic>;
            final message = firstChoice['message'] as Map<String, dynamic>?;
            if (message != null && message['content'] != null) {
              final content = message['content'];

              // Handle string content
              if (content is String) {
                return [content];
              }

              // Handle list of output objects with 'text' field
              if (content is List) {
                final texts = <String>[];
                for (final item in content) {
                  if (item is Map && item['text'] != null) {
                    texts.add(item['text'].toString());
                  } else if (item is String) {
                    texts.add(item);
                  }
                }
                if (texts.isNotEmpty) {
                  return texts;
                }
              }

              // Handle single output object with 'text' field
              if (content is Map && content['text'] != null) {
                return [content['text'].toString()];
              }
            }
          }
          _logger.e(
            'AI response missing expected choices/message: ${response.body}',
          );
          throw Exception('AI response missing expected choices/message');
        } else {
          final errorMessage = data['message'] as String? ?? 'Unknown error';
          final errorDetails = data['details'];
          _logger.e(
            'AI request failed: $errorMessage (details: $errorDetails)',
          );
          throw Exception('AI request failed: $errorMessage');
        }
      } else {
        final errorMessage = data['message'] as String? ?? 'Unknown error';
        final status = data['status'] as int? ?? response.statusCode;
        _logger.e('AI request failed with status $status: $errorMessage');
        throw Exception('AI request failed: $status $errorMessage');
      }
    } catch (e, st) {
      _logger.e('Error generating AI suggestions: $e', st);
      rethrow;
    }
  }
}

// Contains AI-generated edits.
