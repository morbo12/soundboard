import 'package:flutter/material.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

class MatchTitleRow extends StatelessWidget {
  const MatchTitleRow({super.key, required this.match});
  final IbyVenueMatch match;

  @override
  Widget build(BuildContext context) {
    const double fontSize = 13;

    TextStyle styleBoldContainer = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSecondaryContainer);

    return Column(
      children: [
        Container(
          // Top row with rounded corners
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(match.competitionName, style: styleBoldContainer),
              // Text("${maxWidth}"),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            border:
                Border.all(color: Theme.of(context).colorScheme.surfaceTint),
          ),
        ),
      ],
    );
  }
}
