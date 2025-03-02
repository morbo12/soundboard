// First, create a separate widget for the period scores to better manage the state
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_periodevent.dart';
import 'package:soundboard/features/screen_home/presentation/events/classes/class_divider.dart';

class PeriodScores extends ConsumerWidget {
  const PeriodScores({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMatch = ref.watch(selectedMatchProvider);

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                "Score",
              ),
              Text(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  // fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                "${selectedMatch.goalsHomeTeam} - ${selectedMatch.goalsAwayTeam}",
              ),
            ],
          ),
        ),
        const VerticalDividerWidget(
          useThemeColor: true,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        _buildPeriodButton(context, ref, 0, selectedMatch),
        const VerticalDividerWidget(
          useThemeColor: true,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        _buildPeriodButton(context, ref, 1, selectedMatch),
        const VerticalDividerWidget(
          useThemeColor: true,
          padding: EdgeInsets.symmetric(horizontal: 8.0),
        ),
        _buildPeriodButton(context, ref, 2, selectedMatch),
      ],
    );
  }

  Widget _buildPeriodButton(
      BuildContext context, WidgetRef ref, int period, IbyMatch match) {
    // Check if intermediate results exist and have data for this period
    final hasIntermediateResults = match.intermediateResults != null &&
        match.intermediateResults!.length > period;

    // Safely get the period score text
    String getPeriodScore() {
      if (hasIntermediateResults) {
        final periodResult = match.intermediateResults![period];
        return "${periodResult.goalsHomeTeam} - ${periodResult.goalsAwayTeam}";
      }
      return "0 - 0";
    }

    return Expanded(
      child: TextButton(
        onPressed: () =>
            SsmlPeriodEvent(period: period, ref: ref).getSay(context),
        child: Column(
          children: [
            Text(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              "P ${period + 1}",
            ),
            Text(
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              getPeriodScore(),
            ),
          ],
        ),
      ),
    );
  }
}
