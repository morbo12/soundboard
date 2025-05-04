// ssml_goal_event.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match_event.dart';
import 'class_ssml_base.dart';

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
    "kvitterar ställningen till",
  ];

  static const List<String> firstGoal = [
    "går upp i ledning med",
    "tar ledningen med",
    "gör första målet i matchen med",
    "tar ledningen i matchen med",
  ];
}

class SsmlGoalEvent extends BaseSsmlEvent {
  final IbyMatchEvent matchEvent;
  final Random _random = Random();

  SsmlGoalEvent({required super.ref, required this.matchEvent})
    : super(loggerName: 'SsmlGoalEvent');

  @override
  String formatAnnouncement() {
    return _addProsodyVariation(_formatGoalAnnouncement());
  }

  String _formatGoalAnnouncement() {
    final teamName = stripTeamSuffix(matchEvent.matchTeamName);
    final phrase = _selectGoalPhrase();
    final scorer = _formatScorer();
    final assist = _formatAssist();
    final time = _formatEventTime();

    return '''
      $teamName $phrase 
      <say-as interpret-as='cardinal'>${matchEvent.goalsHomeTeam}</say-as>-<say-as interpret-as='cardinal'>${matchEvent.goalsAwayTeam}</say-as>, 
      $scorer. 
      ${assist.isNotEmpty ? '$assist. ' : ''}
      Tid: $time
    '''.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _selectGoalPhrase() {
    final totalGoals = matchEvent.goalsHomeTeam + matchEvent.goalsAwayTeam;
    final goalDifference = _calculateGoalDifference();

    if (totalGoals == 1) {
      return _getRandomPhrase(GoalPhrases.firstGoal);
    }

    if (goalDifference > 1) {
      return _getRandomPhrase(GoalPhrases.increaseMoreThanOne);
    } else if (goalDifference == 1) {
      return _getRandomPhrase(GoalPhrases.increaseOne);
    } else if (goalDifference == 0) {
      return _getRandomPhrase(GoalPhrases.equal);
    } else {
      return _getRandomPhrase(GoalPhrases.reduce);
    }
  }

  int _calculateGoalDifference() {
    final isHomeTeam = _isHomeTeam();
    return isHomeTeam
        ? matchEvent.goalsHomeTeam - matchEvent.goalsAwayTeam
        : matchEvent.goalsAwayTeam - matchEvent.goalsHomeTeam;
  }

  bool _isHomeTeam() {
    final selectedMatch = ref.read(selectedMatchProvider);
    return matchEvent.matchTeamName == selectedMatch.homeTeam;
  }

  String _getRandomPhrase(List<String> phrases) =>
      phrases[_random.nextInt(phrases.length)];

  String _formatScorer() {
    if (matchEvent.playerName == "Självmål") {
      return "genom självmål";
    }

    return '''
      målskytt nummer 
      <say-as interpret-as='cardinal'>${matchEvent.playerShirtNo}</say-as>, 
      <say-as interpret-as='name'>${matchEvent.playerName}</say-as>
    '''.trim();
  }

  String _formatAssist() {
    if (matchEvent.playerAssistShirtNo == null) return '';

    return '''
      Assist av nummer 
      <say-as interpret-as='cardinal'>${matchEvent.playerAssistShirtNo}</say-as>, 
      <say-as interpret-as='name'>${matchEvent.playerAssistName}</say-as>
    '''.trim();
  }

  String _formatEventTime() {
    return formatTime(matchEvent.minute, matchEvent.second);
  }

  String _addProsodyVariation(String text) {
    final variations = ['excited', 'cheerful', 'friendly'];

    return '''
      <mstts:express-as style='${variations[_random.nextInt(variations.length)]}'>
        ${wrapWithProsody(text)}
      </mstts:express-as>
    '''.trim();
  }

  @override
  Future<bool> getSay(BuildContext context) async {
    try {
      final announcement = formatAnnouncement();
      logger.d("Announcement: $announcement");

      await showToast(context, announcement);
      await playAnnouncement(announcement);

      return true;
    } catch (e, stackTrace) {
      logger.e('Failed to process goal announcement', e, stackTrace);
      await showToast(
        context,
        "Ett fel uppstod vid målannonsering",
        isError: true,
      );
      return false;
    }
  }

  // Helper method for testing SSML output
  void testAnnouncement() {
    final announcement = formatAnnouncement();
    logger.d('Generated SSML announcement: $announcement');
  }
}
