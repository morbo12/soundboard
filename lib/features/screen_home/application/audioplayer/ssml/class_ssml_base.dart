// base_ssml_event.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/providers.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/providers.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';

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
      duration: FlutterToastr.lengthLong,
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
      rethrow;
    }
  }

  /// Updates the Azure character count
  Future<void> _updateCharCount(String text) async {
    ref.read(azCharCountProvider.notifier).state += text.length;
    SettingsBox().azCharCount += text.length;
    ;
  }

  /// Abstract methods that must be implemented by subclasses
  String formatAnnouncement();
  Future<bool> getSay(BuildContext context);
}
