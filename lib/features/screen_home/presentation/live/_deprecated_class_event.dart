// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

// import 'events/event_card.dart';
// import 'helpers/class_event_width.dart';

// class Event extends ConsumerWidget {
//   Event({super.key, required this.data});
//   final MatchEvent data;
//   final NumberFormat formatter = NumberFormat("00");

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final selectedMatch = ref.watch(selectedMatchProvider);

//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         EventCard(data: data)

//         // // Check if there is any tile needed for homeTeam
//         // data.matchTeamName == selectedMatch.homeTeam
//         //     ? EventCard(data: data)
//         //     : SizedBox(
//         //         height: 20,
//         //         width:
//         //             ContainerWidthCalculator.calculateContainerWidth(context),
//         //       ),
//         // AutoSizeText(
//         //     style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//         //     "${formatter.format(data.minute)}:${formatter.format(data.second)}"),
//         // // Check if there is any tile needed for awayTeam
//         // data.matchTeamName == selectedMatch.awayTeam
//         //     ? EventCard(data: data)
//         //     : SizedBox(
//         //         height: 20,
//         //         width:
//         //             ContainerWidthCalculator.calculateContainerWidth(context),
//         //       )
//       ],
//     );
//   }
// }
