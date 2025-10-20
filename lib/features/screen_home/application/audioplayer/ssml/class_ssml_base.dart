// base_ssml_event.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/providers.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/providers.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'class_ssml_header.dart';

abstract class BaseSsmlEvent {
  final WidgetRef ref;
  final Logger logger;
  final NumberFormat formatter = NumberFormat("00");

  BaseSsmlEvent({required this.ref, required String loggerName})
    : logger = Logger(loggerName);

  /// Removes team suffix in the format ' (X)' where X is a capital letter
  String stripTeamSuffix(String teamName) =>
      teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');

  /// Wraps text with SSML prosody tags
  String wrapWithLang(String text, {String lang = 'sv-SE'}) =>
      "<lang xml:lang='$lang'>$text</lang>";

  /// Wraps text with SSML prosody tags
  String wrapWithProsody(
    String text, {
    String rate = 'medium',
    String pitch = 'medium',
  }) => "<prosody rate='$rate' pitch='$pitch'>$text</prosody>";

  /// Formats time in SSML format
  String formatTime(int minutes, int seconds) =>
      "<say-as interpret-as='time' format='hms'>"
      "${formatter.format(minutes)}:${formatter.format(seconds)}"
      "</say-as>";

  /// Wraps content with complete SSML speak tags
  String wrapWithSpeakTags(String content, {String language = 'sv-SE'}) =>
      SSMLHeader.wrapWithSpeakTags(content, language: language);

  /// Wraps content with SSML voice tags using the user's selected voice
  String wrapWithVoice(String content) {
    final selectedVoice = SettingsBox().azVoiceName;
    return "<voice name='$selectedVoice'>$content</voice>";
  }

  /// Shows a toast message
  Future<void> showToast(
    BuildContext context,
    String message, {
    bool isError = false,
  }) async {
    if (!context.mounted) return;

    FlutterToastr.show(
      message,
      context,
      duration: isError ? 8 : FlutterToastr.lengthLong,
      position: FlutterToastr.bottom,
      backgroundColor: isError ? Colors.red : Colors.black,
      textStyle: const TextStyle(color: Colors.white),
    );
  }

  /// Plays the announcement using TTS
  Future<void> playAnnouncement(String ssml) async {
    try {
      final textToSpeechService = ref.read(textToSpeechServiceProvider);
      final result = await textToSpeechService.getTtsNoFile(text: ssml);

      await _updateCharCount(ssml);

      final jingleManagerAsync = ref.read(jingleManagerProvider);
      final jingleManager = jingleManagerAsync.maybeWhen(
        data: (manager) => manager,
        orElse: () => throw Exception("JingleManager not available"),
      );

      await jingleManager.audioManager.playBytes(
        audio: result.audio.buffer.asUint8List(),
        ref: ref,
      );
    } catch (e, stackTrace) {
      logger.e('Failed to play announcement', e, stackTrace);
      throw AnnouncementException(_extractErrorMessage(e));
    }
  }

  /// Extracts a user-friendly error message from exceptions
  String _extractErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Try to extract JSON error message from TTS API
    if (errorString.contains('ttsapiexception') ||
        errorString.contains('status')) {
      final jsonMatch = RegExp(r'\{.*\}').firstMatch(error.toString());
      if (jsonMatch != null) {
        try {
          final decoded = json.decode(jsonMatch.group(0)!);
          if (decoded['message'] != null) {
            final message = decoded['message'] as String;
            if (decoded['details'] != null) {
              final details = decoded['details'] as Map;
              if (details['retryAfter'] != null) {
                return '$message. Försök igen efter: ${details['retryAfter']}';
              }
              if (details['used'] != null && details['limit'] != null) {
                return '$message (Använt: ${details['used']}/${details['limit']})';
              }
            }
            return message;
          }
        } catch (e) {
          logger.d('Failed to parse API error JSON: $e');
        }
      }
    }

    if (errorString.contains('monthly request quota exceeded') ||
        errorString.contains('quota exceeded')) {
      return 'Månadskvoten för TTS är överskriden. Försök igen nästa månad.';
    } else if (errorString.contains('quota') || errorString.contains('403')) {
      return 'Kvoten är överskriden. Vänligen kontrollera ditt konto.';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Åtkomst nekad. Kontrollera inställningarna.';
    } else if (errorString.contains('429') ||
        errorString.contains('rate limit')) {
      return 'För många förfrågningar. Försök igen om en stund.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Nätverksfel. Kontrollera internetanslutningen.';
    } else if (errorString.contains('voice not found')) {
      return 'Vald röst hittades inte. Välj en annan röst i inställningarna.';
    }

    return error.toString();
  }

  /// Updates the Azure character count
  Future<void> _updateCharCount(String text) async {
    ref.read(azCharCountProvider.notifier).state += text.length;
    SettingsBox().azCharCount += text.length;
    ;
  }

  /// Abstract methods that must be implemented by subclasses
  String formatContent();

  /// Returns the complete SSML announcement with voice and speak tags
  String formatAnnouncement() {
    final content = formatContent();
    final voiceWrapped = wrapWithVoice(content);
    return wrapWithSpeakTags(voiceWrapped);
  }

  Future<bool> getSay(BuildContext context);
}

/// Custom exception for announcement-related errors with user-friendly messages
class AnnouncementException implements Exception {
  final String message;
  AnnouncementException(this.message);

  @override
  String toString() => message;
}
