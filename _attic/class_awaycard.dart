// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:flutter/material.dart';
// import 'package:soundboard/features/home_screen/presentation/class_eventtypes.dart';
// import 'package:soundboard/features/home_screen/presentation/event_card.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
// import 'package:soundboard/features/home_screen/presentation/class_clippertriangle.dart';

// class AwayCard extends StatelessWidget {
//   const AwayCard({super.key, required this.data});
//   final MatchEvent data;

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: containerWidth,
//       child: Row(
//         children: [
//           SizedBox(
//             width: 20,
//             child: ClipPath(
//               clipper: TriangleClipperLeft(),
//               child: Container(
//                 // width: 20,
//                 height: 30,
//                 color: data.matchEventTypeID == 2
//                     ? Theme.of(context).colorScheme.errorContainer
//                     : Theme.of(context).colorScheme.tertiaryContainer,
//               ),
//             ),
//           ),
//           SizedBox(
//             width: containerWidth - 20,
//             child: ListTile(
//               tileColor: data.matchEventTypeID == 2
//                   ? Theme.of(context).colorScheme.errorContainer
//                   : Theme.of(context).colorScheme.tertiaryContainer,
//               shape: RoundedRectangleBorder(
//                 side: BorderSide(
//                     color: Theme.of(context).colorScheme.onSecondaryContainer,
//                     width: 1),
//                 borderRadius: BorderRadius.circular(5),
//               ),
//               trailing: AutoSizeText.rich(
//                 textAlign: TextAlign.right,
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
//                   "Ass: ${data.playerAssistShirtNo}. ${data.playerAssistName}"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
