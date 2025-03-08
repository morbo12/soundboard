import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
import 'package:soundboard/properties.dart';
import 'package:soundboard/utils/logger.dart';

class Team {
  static const String home = "hemmalaget";
  static const String away = "bortalaget";
}

class GoalPhrases {
  static const List<String> reduce = [
    "reducerar till",
    "minskar underläget till",
    "minskar siffrorna till",
  ];

  static const List<String> increaseMoreThanOne = [
    "utökar ledningen till",
    "bygger på försprånget till",
    "drar ifrån ytterligare till",
    "ökar på till",
    "förstärker ledningen med",
  ];

  static const List<String> increaseOne = [
    "går upp i ledning med",
    "tar ledningen i matchen",
    "går upp i ledning",
    "vänder och tar ledningen",
  ];

  static const List<String> equal = [
    "utjämnar till",
    "sätter ställningen till",
    "kvitterar ställningen till"
  ];

  static const List<String> firstGoal = [
    "går upp i ledning med",
    "tar ledningen med",
    "gör första målet i matchen med",
    "tar ledningen i matchen med",
  ];
}

class SpeechEmphasis {
  static const String STRONG = 'strong';
  static const String MODERATE = 'moderate';
  static const String REDUCED = 'reduced';

  static String wrap(String text, String level) =>
      '<emphasis level="$level">$text</emphasis>';
}

class SsmlGoalEvent {
  final WidgetRef ref;
  final IbyMatchEvent matchEvent;
  final NumberFormat formatter = NumberFormat("00");
  final Logger logger = const Logger('SsmlGoalEvent');
  final Random _random = Random();

  SsmlGoalEvent({
    required this.matchEvent,
    required this.ref,
  });

  String _whichTeamScored() {
    final selectedMatch = ref.read(selectedMatchProvider);
    return (matchEvent.matchTeamName == selectedMatch.homeTeam)
        ? Team.home
        : Team.away;
  }

  String _formatAssist() {
    if (matchEvent.playerAssistShirtNo == null) return '';

    return '''
      Assist av nummer 
      <say-as interpret-as='cardinal'>${matchEvent.playerAssistShirtNo}</say-as>, 
      <say-as interpret-as='name'>${matchEvent.playerAssistName}</say-as>
    '''
        .trim();
  }

  String _formatTime() {
    final time = matchEvent.minute != 0
        ? "${formatter.format(matchEvent.minute)}:${formatter.format(matchEvent.second)}"
        : "${formatter.format(matchEvent.second)} sekunder";

    return '<say-as interpret-as="time" format="hms">$time</say-as>';
  }

  String _selectRandomPhrase({
    required int goalsHomeTeam,
    required int goalsAwayTeam,
  }) {
    final team = _whichTeamScored();
    final totalGoals = goalsHomeTeam + goalsAwayTeam;
    final goalDifference = team == Team.home
        ? goalsHomeTeam - goalsAwayTeam
        : goalsAwayTeam - goalsHomeTeam;

    if (totalGoals == 1) {
      return GoalPhrases
          .firstGoal[_random.nextInt(GoalPhrases.firstGoal.length)];
    }

    if (goalDifference > 1) {
      return GoalPhrases.increaseMoreThanOne[
          _random.nextInt(GoalPhrases.increaseMoreThanOne.length)];
    } else if (goalDifference == 1) {
      return GoalPhrases
          .increaseOne[_random.nextInt(GoalPhrases.increaseOne.length)];
    } else if (goalDifference == 0) {
      return GoalPhrases.equal[_random.nextInt(GoalPhrases.equal.length)];
    } else {
      return GoalPhrases.reduce[_random.nextInt(GoalPhrases.reduce.length)];
    }
  }

  String _stripTeamSuffix(String teamName) {
    return teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');
  }

  String _formatScorer() {
    if (matchEvent.playerName == "Självmål") {
      return "genom självmål";
    }

    return '''
      målskytt nummer 
      <say-as interpret-as='cardinal'>${matchEvent.playerShirtNo}</say-as>, 
      <say-as interpret-as='name'>${matchEvent.playerName}</say-as>
    '''
        .trim();
  }

  String _formatAnnouncement() {
    final teamName = _stripTeamSuffix(matchEvent.matchTeamName);
    final phrase = _selectRandomPhrase(
      goalsHomeTeam: matchEvent.goalsHomeTeam,
      goalsAwayTeam: matchEvent.goalsAwayTeam,
    );
    final scorer = _formatScorer();
    final assist = _formatAssist();
    final time = _formatTime();

    return '''
      ${teamName} $phrase 
      <say-as interpret-as='cardinal'>${matchEvent.goalsHomeTeam}</say-as>-<say-as interpret-as='cardinal'>${matchEvent.goalsAwayTeam}</say-as>, 
      $scorer. 
      ${assist.isNotEmpty ? '$assist. ' : ''}
      Tid: $time
    '''
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<bool> getSay(BuildContext context) async {
    try {
      final announcement = _formatAnnouncement();
      logger.d("Announcement: $announcement");

      // Show toast
      FlutterToastr.show(
        announcement,
        context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(color: Colors.white),
      );

      // Generate and play audio
      final textToSpeechService = ref.read(textToSpeechServiceProvider);
      logger.d("Before TTS call");
      final ssml = await textToSpeechService.getTtsNoFile(text: announcement);
      logger.d("After TTS call");

      // Update character count
      ref.read(azCharCountProvider.notifier).state += announcement.length;
      SettingsBox().azCharCount += announcement.length;
      // Play audio
      await jingleManager.audioManager
          .playBytes(audio: ssml.audio.buffer.asUint8List(), ref: ref);

      return true;
    } catch (e, stackTrace) {
      logger.e('Failed to process goal announcement', e, stackTrace);

      FlutterToastr.show(
        'Ett fel uppstod vid målannonsering',
        context,
        backgroundColor: Colors.red,
        textStyle: const TextStyle(color: Colors.white),
      );

      return false;
    }
  }

  // Helper method for testing SSML output
  void testAnnouncement() {
    final announcement = _formatAnnouncement();
    logger.d('Generated SSML announcement: $announcement');
  }
}
