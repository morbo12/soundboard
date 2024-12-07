import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:soundboard/constants/matchstatus.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

class MatchReferee extends StatelessWidget {
  const MatchReferee({super.key, required this.match, this.readonly});
  final IbyVenueMatch match;
  final bool? readonly;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: readonly == true
              ? const BorderRadius.only(
                  bottomLeft: Radius.circular(10),
                  bottomRight: Radius.circular(10))
              : BorderRadius.zero),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: AutoSizeText(
              textAlign: TextAlign.center,
              maxLines: 1,
              match.referee1 as String,
            ),
          ),
          Expanded(
              child: AutoSizeText(
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  StatusDescriptions.descriptions[match.matchStatus] ?? "N/A")),
          Expanded(
            child: AutoSizeText(
              textAlign: TextAlign.center,
              maxLines: 1,
              match.referee2 as String,
            ),
          )
        ],
      ),
    );
  }
}
