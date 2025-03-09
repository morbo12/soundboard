import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/properties.dart';
import 'package:soundboard/utils/logger.dart';

class PenaltyAnnouncements {
  static final List<
      String Function(
        String time,
        String period,
        String number,
        String name,
        String team,
        String penalty,
      )> templates = [
    // Template 0: Original
    (time, period, number, name, team, penalty) => '''
      Nummer $number, $name 
      i $team utvisas $penalty. 
      Tid: <say-as interpret-as='duration' format='ms'>$time</say-as>
    ''',

    // Template 1: Time first
    (time, period, number, name, team, penalty) => '''
      <say-as interpret-as='duration' format='ms'>$time</say-as> i $period utvisas 
      nummer $number, $name 
      i $team för $penalty
    ''',

    // Template 2: Team focus
    (time, period, number, name, team, penalty) => '''
      $team får en utvisning. 
      $penalty på nummer $number, $name.
      Tid: <say-as interpret-as='duration' format='ms'>$time</say-as>
    ''',

    // Template 3: Period focus
    (time, period, number, name, team, penalty) => '''
      I $period, vid <say-as interpret-as='duration' format='ms'>$time</say-as>,
      utvisas nummer $number, $name i $team. 
      Utvisningen är $penalty
    ''',
  ];
}

class SsmlPenaltyEvent {
  final IbyMatchEvent matchEvent;
  final NumberFormat formatter = NumberFormat("0");
  final WidgetRef ref;
  final Logger logger = const Logger('SsmlPenaltyEvent');
  final Random _random = Random();

  SsmlPenaltyEvent({
    required this.ref,
    required this.matchEvent,
  });
  // data.matchTeamName == selectedMatch.awayTeam
  String whosEvent() {
    final selectedMatch = ref.read(selectedMatchProvider);
    return (matchEvent.matchTeamName == selectedMatch.homeTeam)
        ? "hemmalaget"
        : "bortalaget";
  }

  String homeOrAwayScore() {
    String score = "";
    if (whosEvent() == "bortalaget") {
      score = "${matchEvent.goalsAwayTeam} - ${matchEvent.goalsHomeTeam}";
    } else {
      score = "${matchEvent.goalsHomeTeam} - ${matchEvent.goalsAwayTeam}";
    }

    // if (matchEvent.goalsAwayTeam)
    return score;
  }

  String penaltyName() {
    Map<String, String> penaltyInfo =
        PenaltyTypes.getPenaltyInfo(matchEvent.penaltyCode);
    logger.d("penaltyName: ${penaltyInfo['time']} för ${penaltyInfo['name']}");

    String penaltyString = "";
    if (penaltyInfo['time'] != "Unknown") {
      penaltyString =
          "${penaltyInfo['time']} för <break time='200ms' /> ${penaltyInfo['name']}";
    }
    return penaltyString;
  }

  // Nummer z i <laget> utvisas x minuter för <penaltyname>
  // String who = whoScored(matchTeamName: matchEvent.matchTeamName);
  // Kvitterar
  // 1-0 till hemmalaget – målskytt nr 12 Pelle Karlsson – assist nr 11 Kent Persson och 9 Sven Hansson – Tid 11:04.
  // <lag> <händelse> med <1-0,0-1>
  String whatWasTheTime() {
    return matchEvent.minute != 0
        ? "${formatter.format(matchEvent.minute)}:${formatter.format(matchEvent.second)}"
        : "${formatter.format(matchEvent.second)} sekunder";
  }

  String stripTeamSuffix(String teamName) {
    return teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');
  }

  /// Helper function to format player information
  ({String number, String name}) _formatPlayerInfo() {
    return (
      number: matchEvent.playerShirtNo.toString(),
      name: matchEvent.playerName.trim(),
    );
  }

  /// Formats time with optional variations
  String _formatTime() {
    if (matchEvent.minute == 0) {
      return '${formatter.format(matchEvent.second)} sekunder';
    }

    final minutes = formatter.format(matchEvent.minute);
    final seconds = formatter.format(matchEvent.second);

    // Randomly choose between different time formats
    final timeFormats = [
      '$minutes:$seconds',
      '$minutes minuter och $seconds sekunder',
      '$minutes och $seconds',
    ];

    return timeFormats[_random.nextInt(timeFormats.length)];
  }

  /// Adds prosody variations for more natural speech
  String _addProsodyVariation(String text) {
    final rates = ['slow', 'medium', 'fast'];
    final pitches = ['low', 'medium', 'high'];

    return '''
      <prosody rate="${rates[_random.nextInt(rates.length)]}" 
               pitch="${pitches[_random.nextInt(pitches.length)]}">
        $text
      </prosody>
    ''';
  }

  /// Formats the penalty announcement with SSML markup
  String _formatAnnouncement() {
    final playerInfo = _formatPlayerInfo();
    final teamName = stripTeamSuffix(matchEvent.matchTeamName);
    final penalty = penaltyName();
    final time = _formatTime();
    // Select random template
    final templateIndex =
        _random.nextInt(PenaltyAnnouncements.templates.length);
    final template = PenaltyAnnouncements.templates[templateIndex];
    logger.d('Selected template: $templateIndex');
    // Add variation to announcement with optional pause breaks
    final announcement = template(
      time,
      matchEvent.periodName,
      playerInfo.number,
      playerInfo.name,
      teamName,
      penalty,
    );
    // Clean up whitespace and add random pauses
    return _addRandomPauses(
        announcement.trim().replaceAll(RegExp(r'\s+'), ' '));
  }

  /// Adds random SSML pauses to make the announcement more natural
  String _addRandomPauses(String text) {
    if (!text.contains('.')) return text;

    return text.split('.').where((s) => s.trim().isNotEmpty).map((sentence) {
      final pauseLength = _random.nextInt(300) + 200; // 200-500ms pause
      return '${sentence.trim()}. <break time="${pauseLength}ms"/>';
    }).join(' ');
  }

  /// Validates the event data before processing
  void _validateEventData() {
    if (matchEvent.playerShirtNo! <= 0) {
      throw ValidationException('Invalid player number');
    }
    if (matchEvent.playerName.trim().isEmpty) {
      throw ValidationException('Player name is required');
    }
    if (matchEvent.matchTeamName.trim().isEmpty) {
      throw ValidationException('Team name is required');
    }
  }

  /// Plays the announcement audio using the text-to-speech service
  Future<void> _playAnnouncement(String announcement) async {
    try {
      final textToSpeechService = ref.read(textToSpeechServiceProvider);
      final ssml = await textToSpeechService.getTtsNoFile(text: announcement);

      if (ssml.audio.buffer.lengthInBytes == 0) {
        throw Exception('Received empty audio buffer from TTS service');
      }

      await jingleManager.audioManager.playBytes(
        audio: ssml.audio.buffer.asUint8List(),
        ref: ref,
      );
    } catch (e, stackTrace) {
      logger.e('Failed to play announcement', e, stackTrace);
      rethrow; // Rethrow to handle in the calling function
    }
  }

  /// Updates the Azure character count for billing/monitoring
  Future<void> _updateCharCount(String announcement) async {
    try {
      final charCount = announcement.length;
      ref.read(azCharCountProvider.notifier).state += charCount;

      // Update persistent storage
      final settings = SettingsBox();
      await settings.updateAzureCharCount(
        settings.azCharCount + charCount,
      );
    } catch (e, stackTrace) {
      logger.e('Failed to update character count', e, stackTrace);
      // Consider whether to rethrow or handle silently
    }
  }

  /// Modified getSay function using the helper methods
  Future<bool> getSay(BuildContext context) async {
    try {
      // Validate input data
      _validateEventData();

      // Format and process the announcement
      final announcement = _formatAnnouncement();
      await _showToast(context, announcement);
      await _playAnnouncement(announcement);
      await _updateCharCount(announcement);

      return true;
    } catch (e, stackTrace) {
      logger.e('Failed to process penalty announcement', e, stackTrace);
      await _showToast(context, "Failed to announce penalty", isError: true);

      return false;
    }
  }

  /// Shows a toast message with the announcement text
  Future<void> _showToast(
    BuildContext context,
    String announcement, {
    bool isError = false,
    Color? backgroundColor,
  }) async {
    try {
      FlutterToastr.show(
        announcement,
        context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor:
            backgroundColor ?? (isError ? Colors.red : Colors.black),
        textStyle: const TextStyle(color: Colors.white),
      );
    } catch (e, stackTrace) {
      logger.e('Failed to show toast: Error', e, stackTrace);
      // Consider whether to rethrow or handle silently
    }
  }
// Nybro IF tar ledningen med 1-0. Målskytt utan assistans nummer 24 Peter Eriksson. Tid 12.14

  List<String> goalSays = [
    "<hemmalag> utökar ledningen till x-y, mål av <person>",
    "Mål av <person>, <lag> leder med x-y",
  ];
}

/// Custom exception for validation errors
class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

/// Extension for SettingsBox to handle Azure character count updates
extension SettingsBoxExtension on SettingsBox {
  Future<void> updateAzureCharCount(int newCount) async {
    azCharCount = newCount;
    // Add any additional persistence logic here
  }
}
