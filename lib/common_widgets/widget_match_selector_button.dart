import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/application/api_client.dart';
import 'package:soundboard/features/innebandy_api/application/match_service.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

class MatchSelectorButton extends ConsumerStatefulWidget {
  const MatchSelectorButton({super.key, required this.match});
  final IbyVenueMatch match;

  @override
  ConsumerState<MatchSelectorButton> createState() =>
      _MatchSelectorButtonState();
}

class _MatchSelectorButtonState extends ConsumerState<MatchSelectorButton> {
  void _getMatch(int matchID) async {
    final apiClient = APIClient();
    final matchService = MatchService(apiClient);
    final match = await matchService.getMatch(matchId: matchID);

    ref.read(selectedMatchProvider.notifier).state = match;
    ref.read(lineupProvider.notifier).state =
        await match.getLineupByMatchId(matchID);
    ref.read(lineupSsmlProvider.notifier).state = match.generateSsml();
  }

  @override
  Widget build(BuildContext context) {
    Color normalColor = Theme.of(context).colorScheme.secondaryContainer;
    final selectedMatch = ref.watch(selectedMatchProvider);

    return Container(
      decoration: BoxDecoration(
          color: normalColor,
          // border: Border.all(width: 2, color: Colors.white),
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10))),
      padding: const EdgeInsets.all(1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              _getMatch(widget.match.matchId);
              // selectedMatch = widget.match;
              // print(selectedMatch.matchId);
              // super.setState(() {});
              // setState(() {});
            },
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.only(left: 40, right: 40),
                foregroundColor: widget.match == selectedMatch
                    ? Theme.of(context).colorScheme.onSecondaryContainer
                    : Theme.of(context).colorScheme.onPrimary,
                backgroundColor: widget.match == selectedMatch
                    ? Theme.of(context).colorScheme.tertiaryContainer
                    : normalColor,
                side: BorderSide(
                    width: 2,
                    color: Theme.of(context).colorScheme.surfaceTint)),
            child: Text(widget.match == selectedMatch ? "VALD" : "VÄLJ"),
          ),
        ],
      ),
    );
  }
}
