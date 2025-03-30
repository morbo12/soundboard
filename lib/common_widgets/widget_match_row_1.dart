import 'package:auto_size_text/auto_size_text.dart';
// import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';

class MatchRow1 extends StatelessWidget {
  const MatchRow1({super.key, required this.match});
  final IbyMatch match;

  @override
  Widget build(BuildContext context) {
    Color normalColor = Theme.of(context).colorScheme.secondaryContainer;

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
                  match.matchNo,
                  // style: styleTitle,
                ),
              ),
              const Text("|"),
              // const Spacer(),
              Expanded(
                child: AutoSizeText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  DateFormat.yMd().format(DateTime.parse(match.matchDateTime)),
                  // style: styleTitle,
                ),
              ),
              // const Spacer(),
              const Text("|"),
              // const Spacer(),
              Expanded(
                child: AutoSizeText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  DateFormat.Hm().format(DateTime.parse(match.matchDateTime)),
                  // style: styleTitle,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.surfaceTint)),
        ),
      ],
    );
  }
}
