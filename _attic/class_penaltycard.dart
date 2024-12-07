// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:soundboard/constants/class_colors.dart';
// import 'package:soundboard/features/home_screen/presentation/class_eventtypes.dart';
// import 'package:soundboard/features/home_screen/presentation/class_event_widget.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

// import 'class_clippertriangle.dart';

// class PenaltyCard extends StatelessWidget {
//   const PenaltyCard({super.key, required this.data});
//   final MatchEvent data;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: containerWidth,
//       child: Row(
//         children: [
//           data.matchTeamName == selectedMatch.awayTeam
//               ? LeftTriangle(
//                   matchEventTypeID: data.matchEventTypeID,
//                 )
//               : const Text(""),
//           SizedBox(
//             width: containerWidth - 20,
//             child: ListTile(
//               tileColor:
//                   MatchEventColors(data.matchEventTypeID).getColor(context),
//               shape: RoundedRectangleBorder(
//                 side: BorderSide(
//                     color: Theme.of(context).colorScheme.onSecondaryContainer,
//                     width: 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               leading: AutoSizeText.rich(
//                 textAlign: TextAlign.left,
//                 maxLines: 2,
//                 // style: const TextStyle(fontSize: defaultTextSize),
//                 TextSpan(
//                   children: <TextSpan>[
//                     TextSpan(
//                       text:
//                           "${MatchEventTypes.getEventName(data.matchEventTypeID)}\n",
//                       style: const TextStyle(
//                           fontSize: 12, fontWeight: FontWeight.bold),
//                     ),
//                     data.matchEventTypeID == 1
//                         ? TextSpan(
//                             text:
//                                 "${data.goalsHomeTeam} - ${data.goalsAwayTeam}",
//                             style: const TextStyle(
//                                 fontSize: 12, fontWeight: FontWeight.normal),
//                           )
//                         : const TextSpan(),
//                   ],
//                 ),
//               ),
//               title: AutoSizeText(
//                 maxLines: 1,
//                 style: const TextStyle(fontSize: 12),
//                 textAlign: TextAlign.left,
//                 "${data.playerShirtNo}. ${data.playerName}",
//               ),
//               subtitle: AutoSizeText(
//                   maxLines: 1,
//                   style:
//                       const TextStyle(fontSize: 8, fontStyle: FontStyle.italic),
//                   textAlign: TextAlign.left,
//                   data.penaltyName),
//             ),
//           ),
//           data.matchTeamName == selectedMatch.homeTeam
//               ? RightTriangle(
//                   matchEventTypeID: data.matchEventTypeID,
//                 )
//               : const Text(""),
//         ],
//       ),
//     );
//   }
// }
