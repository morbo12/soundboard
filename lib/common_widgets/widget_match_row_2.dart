import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';

class MatchRow2 extends StatelessWidget {
  const MatchRow2({super.key, required this.match});
  final IbyMatch match;

  @override
  Widget build(BuildContext context) {
    const double fontSize = 13;
    Color normalColor = Theme.of(context).colorScheme.secondaryContainer;
    Color normalColorText = Theme.of(context).colorScheme.onSecondaryContainer;
    TextStyle styleNormal = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: normalColorText);

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: normalColor,
          ),
          padding: const EdgeInsets.all(6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: AutoSizeText(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    match.homeTeam,
                    style: styleNormal.copyWith(
                        fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
              ),
              SizedBox(
                height: 17,
                child: Image.network(
                  match.homeTeamLogotypeUrl as String,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Text("");
                  },
                ),
              ),
              const Expanded(
                child: AutoSizeText(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  "vs.",
                ),
              ),
              SizedBox(
                height: 17,
                child: Image.network(
                  match.awayTeamLogotypeUrl as String,
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Text("");
                  },
                ),
              ),
              Expanded(
                child: AutoSizeText(
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    match.awayTeam,
                    style: styleNormal.copyWith(
                        fontWeight: FontWeight.bold, fontSize: fontSize + 2)),
              ),
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
