// import 'dart:async';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_toastr/flutter_toastr.dart';
// import 'package:intl/intl.dart';
// import 'package:soundboard/constants/globals.dart';
// import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
// import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

// class SsmlLineupEvent {
//   final MatchEvent matchEvent;
//   final NumberFormat formatter = NumberFormat("0");
//   final WidgetRef ref;

//   SsmlLineupEvent({
//     required this.ref,
//     required this.matchEvent,
//   });

//     final selectedMatch = ref.read(selectedMatchProvider);
//   final selectedVenue = ref.read(selectedVenueProvider);
  
// Future<String> genSsml(
 
// ssml = """
// Välkomna till ${ArenasInStockholm.getNameById(selectedVenue)}!
// <break time="1000ms" />""";
//   ssml +=
//       "${selectedMatch.homeTeam} hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan ${selectedMatch.homeTeam} och ";
//   ssml += "${selectedMatch.awayTeam}\n";
//   ssml += "<break time=\"1000ms\" />\n";
//   ssml += "${homeTeam[selectedVenue]} ställer upp med följande spelare,\n";

//   TeamPlayer player;
//   TeamTeamPerson teamPerson;
//   String homeGoalie = "Dagens målvakt är inte inlagd i truppen,\n";
//   String awayGoalie = "Dagens målvakt är inte inlagd i truppen,\n";

//   for (player in lineup.homeTeamPlayers) {
//     if (player.position == "Målvakt") {
//       homeGoalie =
//           "Dagens målvakt är <say-as interpret-as='name'>${player.name}</say-as>,\n";
//     } else {
//       ssml +=
//           "Nummer ${player.shirtNo}, <say-as interpret-as='name'>${player.name}</say-as>,\n";
//     }
//   }
//   ssml += homeGoalie;
//   ssml += "<break time=\"500ms\" />\n";
//   ssml += "Ledare för ${homeTeam[selectedVenue]} är,";

//   for (teamPerson in lineup.homeTeamTeamPersons) {
//     ssml += "<say-as interpret-as='name'>${teamPerson.name}</say-as>,\n";
//   }
//   ssml += "<break time=\"1000ms\" />\n";

//   ssml += "${lineup.awayTeam} ställer upp med följande spelare,\n";
//   for (player in lineup.awayTeamPlayers) {
//     if (player.position == "Målvakt") {
//       awayGoalie =
//           "Dagens målvakt är <say-as interpret-as='name'>${player.name}</say-as>,\n";
//     } else {
//       if (player.shirtNo == null) {
//         ssml += "<say-as interpret-as='name'>${player.name}</say-as>,\n";
//       } else {
//         ssml +=
//             "Nummer ${player.shirtNo}, <say-as interpret-as='name'>${player.name}</say-as>,\n";
//       }
//     }
//   }
//   ssml += awayGoalie;
//   ssml += "<break time=\"500ms\" />\n";
//   ssml += "Ledare för ${lineup.awayTeam} är,";

//   for (teamPerson in lineup.awayTeamTeamPersons) {
//     ssml += "<say-as interpret-as='name'>${teamPerson.name}</say-as>,\n";
//   }
//   ssml += "<break time=\"1000ms\" />\n";
//   ssml += "Domare i denna match är,,\n";
//   ssml += "${match.referee1}";
//   ssml += " och ";
//   ssml += "${match.referee2}\n";
//   // ssml += "</voice></speak>\n";

//   // dev.log(ssml.toString());
//   return ssml;

// }














//   Future<bool> getSay(BuildContext context) async {
//     // String say = matchEvent.matchTeamName;
//     String say =
//         "Nummer ${matchEvent.playerShirtNo}, ${matchEvent.playerName} i ${whosEvent()} utvisas ${penaltyName()}. Tid: <say-as interpret-as='duration' format='ms'>${whatWasTheTime()}</say-as> ";
//     if (kDebugMode) {
//       print("SAY: $say");
//     }
//     FlutterToastr.show(say, context,
//         duration: FlutterToastr.lengthLong,
//         position: FlutterToastr.bottom,
//         backgroundColor: Colors.black,
//         textStyle: const TextStyle(color: Colors.white));
//     final textToSpeechService = ref.read(textToSpeechServiceProvider);
//     final ssml = await textToSpeechService.getTtsNoFile(text: say);
//     // await eventAudioPlayer.setVolume(1.0);
//     await jingleManager.audioManager
//         .playBytes(audio: ssml.audio.buffer.asUint8List());
//     // eventAudioPlayer.stop();
//     // eventAudioPlayer.release();

//     return true;
//   }

// // Nybro IF tar ledningen med 1-0. Målskytt utan assistans nummer 24 Peter Eriksson. Tid 12.14

//   List<String> goalSays = [
//     "<hemmalag> utökar ledningen till x-y, mål av <person>",
//     "Mål av <person>, <lag> leder med x-y",
//   ];
// }
