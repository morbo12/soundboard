// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:soundboard/features/home_screen/presentation/class_event_widget.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

// import 'class_coaliecard.dart';

// class GoalieEvent extends StatelessWidget {
//   GoalieEvent({super.key, required this.data});
//   final MatchEvent data;
//   final NumberFormat formatter = NumberFormat("00");

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceAround,
//       mainAxisSize: MainAxisSize.max,
//       children: [
//         // Check if there is any tile needed for homeTeam
//         data.matchTeamName == selectedMatch.homeTeam
//             ? CoalieCard(data: data)
//             : const SizedBox(
//                 height: 20,
//                 width: containerWidth,
//               ),
//         AutoSizeText(
//             style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             "${formatter.format(data.minute)}:${formatter.format(data.second)}"),
//         // Check if there is any tile needed for awayTeam
//         data.matchTeamName == selectedMatch.awayTeam
//             ? CoalieCard(data: data)
//             : const SizedBox(
//                 height: 20,
//                 width: containerWidth,
//               )
//       ],
//     );
//   }
// }
