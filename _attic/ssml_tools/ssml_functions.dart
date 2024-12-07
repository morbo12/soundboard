// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:soundboard/features/innebandy_api/data/class_arena.dart';
// import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
// import 'package:soundboard/features/innebandy_api/data/providers.dart';
// import 'package:soundboard/constants/team_constants.dart';
// import '../innebandy_api/application/api_service.dart';

// String genSsmlTest({required WidgetRef ref}) {
//   final selectedMatch = ref.read(selectedMatchProvider);
//   final selectedVenue = ref.read(selectedVenueProvider);

//   // String ssml = """<speak version='1.0' xml:lang='sv-SE'>
// // <voice xml:lang='sv-SE' xml:gender='Female' name='sv-SE-SofieNeural'>
//   String testssml = """
// Välkomna till ${ArenasInStockholm.getNameById(selectedVenue)}!
// <break time="1000ms" />
// ${selectedMatch.homeTeam} hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan testlag blå och testlag vit
// Välkomna! Testtext är nu slut
// """;
//   return testssml;
// }

// String genSsml({
//   required WidgetRef ref,
//   // required IbyVenueMatch match,
//   // required IbyMatchLineup? lineup}
// }) {
//   final selectedMatch = ref.read(selectedMatchProvider);
//   final selectedVenue = ref.read(selectedVenueProvider);

//   // String ssml = """<speak version='1.0' xml:lang='sv-SE'>
// // <voice xml:lang='sv-SE' xml:gender='Female' name='sv-SE-SofieNeural'>
//   String ssml = """
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
//   ssml += "${selectedMatch.referee1}";
//   ssml += " och ";
//   ssml += "${selectedMatch.referee2}\n";
//   // ssml += "</voice></speak>\n";

//   // dev.log(ssml.toString());
//   return ssml;
// }

// // Future<IbyMatchLineup> getLineup({required IbyVenueMatch match}) async {
// //   if (kDebugMode) {
// //     print("_getLineup");
// //   }
// //   final apiService = APIService();
// //   final accessToken = await apiService.getAccessToken();
// //   if (kDebugMode) {
// //     print("SettingsScreenStateSeason: $accessToken");
// //   }
// //   IbyMatchLineup lineup = await apiService.getLineupOfMatch(
// //       accessToken: accessToken.accessToken, matchId: match.matchId);
// //   return lineup;
// //   // print("Length is : ${matches.length}");
// //   // inspect(lineup);
// //   // setState(() {});
// // }

//   // String ssml = genSsml(match: selectedMatch, lineup: lineup);
