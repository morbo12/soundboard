import 'package:flutter/material.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'widget_match_row_1.dart';
import 'widget_match_selector_button.dart';
import 'widget_match_title_row.dart';
import 'widget_matchreferee.dart';
import 'widget_match_row_2.dart';

class MatchButton2 extends StatefulWidget {
  final IbyMatch match;
  final bool? readonly;

  const MatchButton2({super.key, required this.match, this.readonly});

  @override
  State<MatchButton2> createState() => _MatchButtonState();
}

class _MatchButtonState extends State<MatchButton2> {
  @override
  Widget build(BuildContext context) {
    const double fontSize = 10;
    Color normalColorText = Theme.of(context).colorScheme.onSecondaryContainer;

    TextStyle styleNormal = TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.normal,
        color: normalColorText);

    return DefaultTextStyle(
      style: styleNormal,
      child: Column(
        children: [
          MatchTitleRow(match: widget.match),
          MatchRow1(match: widget.match),
          MatchRow2(match: widget.match),
          MatchReferee(
            match: widget.match,
            readonly: widget.readonly,
          ),
          widget.readonly == false
              ? MatchSelectorButton(match: widget.match)
              : const Row(
                  children: [
                    Text(""),
                  ],
                ),
        ],
      ),
    );
  }
}
