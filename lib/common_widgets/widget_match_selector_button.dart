// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:soundboard/features/innebandy_api/application/api_client_provider.dart';
// import 'package:soundboard/features/innebandy_api/application/match_service.dart';
// import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
// import 'package:soundboard/features/innebandy_api/data/class_match.dart';

// class MatchSelectorButton extends ConsumerStatefulWidget {
//   const MatchSelectorButton({super.key, required this.match});
//   final IbyMatch match;

//   @override
//   ConsumerState<MatchSelectorButton> createState() =>
//       _MatchSelectorButtonState();
// }

// class _MatchSelectorButtonState extends ConsumerState<MatchSelectorButton> {
//   void _getMatch(int matchID) async {
//     // final apiClient = APIClient();
//     final apiClient = ref.watch(apiClientProvider);

//     final matchService = MatchService(apiClient);
//     final match = await matchService.getMatch(matchId: matchID);

//     ref.read(selectedMatchProvider.notifier).state = match;
//     // await ref.read(selectedMatchProvider.notifier).state.fetchLineup(ref);
//     await match.fetchLineup(ref);
//     // ref.read(lineupProvider.notifier).state = match.lineup!;

//     ref.read(lineupProvider.notifier).state =
//         await match.getLineupByMatchId(matchID, ref);
//     // ref.read(lineupSsmlProvider.notifier).state = match.generateSsml();
//   }

//   @override
//   Widget build(BuildContext context) {
//     Color normalColor = Theme.of(context).colorScheme.secondaryContainer;
//     final selectedMatch = ref.watch(selectedMatchProvider);

//     // Check if this button's match is selected based on matchId
//     final isSelected = widget.match.matchId == selectedMatch.matchId;

//     return Container(
//       decoration: BoxDecoration(
//           color: normalColor,
//           borderRadius: const BorderRadius.only(
//               bottomLeft: Radius.circular(10),
//               bottomRight: Radius.circular(10))),
//       padding: const EdgeInsets.all(1),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           ElevatedButton(
//             onPressed: () {
//               _getMatch(widget.match.matchId);
//             },
//             style: ElevatedButton.styleFrom(
//               padding: const EdgeInsets.only(left: 40, right: 40),
//               foregroundColor: isSelected
//                   ? Theme.of(context).colorScheme.onSecondaryContainer
//                   : Theme.of(context).colorScheme.onSurface,
//               backgroundColor: isSelected
//                   ? Theme.of(context).colorScheme.tertiaryContainer
//                   : Theme.of(context).colorScheme.surfaceContainerHighest,
//               // side: BorderSide(
//               //     width: 2,
//               //     color: Theme.of(context).colorScheme.surfaceContainer)
//             ),
//             child: Text(isSelected ? "VALD" : "VÄLJ"),
//           ),
//         ],
//       ),
//     );
//   }
// }
