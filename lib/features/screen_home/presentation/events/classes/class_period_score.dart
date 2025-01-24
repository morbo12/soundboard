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
    final hasResults = match.intermediateResults != null &&
        match.intermediateResults!.length > period;

    return Expanded(
      child: TextButton(
        onPressed: hasResults
            ? () => SsmlPeriodEvent(period: period, ref: ref).getSay(context)
            : null,
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
                // fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              hasResults
                  ? "${match.intermediateResults!.elementAt(period).goalsHomeTeam} - ${match.intermediateResults!.elementAt(period).goalsAwayTeam}"
                  : "",
            ),
          ],
        ),
      ),
    );
  }
}
