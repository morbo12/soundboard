// ssml_penalty_event.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';
import 'class_ssml_base.dart';

class PenaltyTemplates {
  static final List<
    String Function(
      String time,
      String period,
      String number,
      String name,
      String team,
      String penalty,
    )
  >
  templates = [
    // Standard format
    (time, period, number, name, team, penalty) => '''
      Nummer $number, $name 
      i $team utvisas $penalty. 
      Tid: <say-as interpret-as='duration' format='ms'>$time</say-as>
    ''',

    // Time-first format
    (time, period, number, name, team, penalty) => '''
      Vid <say-as interpret-as='duration' format='ms'>$time</say-as> i $period
      utvisas nummer $number, $name 
      i $team för $penalty
    ''',

    // Team-focused format
    (time, period, number, name, team, penalty) => '''
      $team får en utvisning. 
      $penalty på nummer $number, $name.
      Tid: <say-as interpret-as='duration' format='ms'>$time</say-as>
    ''',
  ];
}

class SsmlPenaltyEvent extends BaseSsmlEvent {
  final IbyMatchEvent matchEvent;
  final Random _random = Random();

  SsmlPenaltyEvent({required super.ref, required this.matchEvent})
    : super(loggerName: 'SsmlPenaltyEvent');

  @override
  String formatAnnouncement() {
    _validateEventData();
    return _formatPenaltyAnnouncement();
  }

  void _validateEventData() {
    if (matchEvent.playerShirtNo == null || matchEvent.playerShirtNo! <= 0) {
      throw ValidationException('Invalid player number');
    }
    if (matchEvent.playerName.trim().isEmpty) {
      throw ValidationException('Player name is required');
    }
    if (matchEvent.matchTeamName.trim().isEmpty) {
      throw ValidationException('Team name is required');
    }
  }

  String _formatPenaltyAnnouncement() {
    final time = _formatTime();
    final teamName = stripTeamSuffix(matchEvent.matchTeamName);
    final penaltyInfo = _getPenaltyInfo();

    final templateIndex = _random.nextInt(PenaltyTemplates.templates.length);
    final template = PenaltyTemplates.templates[templateIndex];

    final announcement = template(
      time,
      matchEvent.periodName,
      matchEvent.playerShirtNo.toString(),
      matchEvent.playerName,
      teamName,
      penaltyInfo,
    );

    return _addProsodyVariation(
      _addRandomPauses(announcement.trim().replaceAll(RegExp(r'\s+'), ' ')),
    );
  }

  String _formatTime() {
    if (matchEvent.minute == 0) {
      return formatter.format(matchEvent.second);
    }
    return '${formatter.format(matchEvent.minute)}:${formatter.format(matchEvent.second)}';
  }

  String _getPenaltyInfo() {
    final penaltyInfo = PenaltyTypes.getPenaltyInfo(matchEvent.penaltyCode);
    if (penaltyInfo['time'] == "Unknown") {
      return penaltyInfo['name'] ?? 'okänd utvisning';
    }
    return "${penaltyInfo['time']} för ${penaltyInfo['name']}";
  }

  String _addProsodyVariation(String text) {
    final rates = ['slow', 'medium', 'fast'];
    final pitches = ['low', 'medium', 'high'];

    return wrapWithProsody(
      text,
      rate: rates[_random.nextInt(rates.length)],
      pitch: pitches[_random.nextInt(pitches.length)],
    );
  }

  String _addRandomPauses(String text) {
    if (!text.contains('.')) return text;

    return text
        .split('.')
        .where((s) => s.trim().isNotEmpty)
        .map((sentence) {
          final pauseLength = _random.nextInt(300) + 200;
          return '${sentence.trim()}. <break time="${pauseLength}ms"/>';
        })
        .join(' ');
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
      logger.e('Failed to process penalty announcement', e, stackTrace);
      await showToast(
        context,
        "Ett fel uppstod vid utvisningsannonsering",
        isError: true,
      );
      return false;
    }
  }
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
