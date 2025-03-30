// ssml_period_event.dart
import 'package:flutter/material.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_intermediate.dart';
import 'class_ssml_base.dart';

class SsmlPeriodEvent extends BaseSsmlEvent {
  final int period;
  late final dynamic selectedMatch;

  SsmlPeriodEvent({required super.ref, required this.period})
    : super(loggerName: 'SsmlPeriodEvent') {
    selectedMatch = ref.read(selectedMatchProvider);
  }

  @override
  String formatAnnouncement() {
    final intermediateOrFinal =
        period == 3 ? "Matchen slutar" : "Ställningen i matchen är";

    return wrapWithProsody(
      "Perioden slutar ${_formatPeriodResult()} "
      "<break time='300ms'/>${intermediateOrFinal} "
      "<break strength='weak'/>${_formatMatchScore()}",
    );
  }

  String _formatMatchScore() {
    final homeGoals = selectedMatch.goalsHomeTeam!;
    final awayGoals = selectedMatch.goalsAwayTeam!;

    if (homeGoals > awayGoals) {
      return _formatScore(
        homeScore: homeGoals,
        awayScore: awayGoals,
        teamName: selectedMatch.homeTeam,
      );
    } else if (homeGoals < awayGoals) {
      return _formatScore(
        homeScore: awayGoals,
        awayScore: homeGoals,
        teamName: selectedMatch.awayTeam,
      );
    }

    return "<prosody rate='medium'>oavgjort <say-as interpret-as='number'>"
        "$homeGoals</say-as> <say-as interpret-as='number'>$awayGoals</say-as>.</prosody>";
  }

  String _formatScore({
    required int homeScore,
    required int awayScore,
    required String teamName,
  }) {
    return "<prosody rate='medium'><say-as interpret-as='number'>$homeScore</say-as> "
        "<say-as interpret-as='number'>$awayScore</say-as> till ${stripTeamSuffix(teamName)}.</prosody>";
  }

  String _formatPeriodResult() {
    final periodResult = _getPeriodResult();

    if (periodResult.goalsHomeTeam > periodResult.goalsAwayTeam) {
      return _formatScore(
        homeScore: periodResult.goalsHomeTeam,
        awayScore: periodResult.goalsAwayTeam,
        teamName: selectedMatch.homeTeam,
      );
    } else if (periodResult.goalsAwayTeam > periodResult.goalsHomeTeam) {
      return _formatScore(
        homeScore: periodResult.goalsAwayTeam,
        awayScore: periodResult.goalsHomeTeam,
        teamName: selectedMatch.awayTeam,
      );
    }

    return "<prosody rate='medium'>oavgjort, <say-as interpret-as='number'>"
        "${periodResult.goalsHomeTeam}</say-as> <say-as interpret-as='number'>"
        "${periodResult.goalsAwayTeam}</say-as>.</prosody>";
  }

  IbyMatchIntermediateResult _getPeriodResult() {
    final hasIntermediateResults =
        selectedMatch.intermediateResults != null &&
        selectedMatch.intermediateResults!.isNotEmpty;

    if (!hasIntermediateResults) {
      return IbyMatchIntermediateResult(
        period: period,
        goalsHomeTeam: 0,
        goalsAwayTeam: 0,
        matchId: 0,
      );
    }

    return selectedMatch.intermediateResults.firstWhere(
      (result) => result.period == period,
      orElse:
          () => IbyMatchIntermediateResult(
            period: period,
            goalsHomeTeam: 0,
            goalsAwayTeam: 0,
            matchId: 0,
          ),
    );
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
      logger.e('Failed to process period announcement', e, stackTrace);
      await showToast(
        context,
        "Ett fel uppstod vid periodannonsering",
        isError: true,
      );
      return false;
    }
  }
}
