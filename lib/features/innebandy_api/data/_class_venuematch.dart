// import 'dart:convert';

// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:soundboard/features/innebandy_api/application/api_client.dart';
// import 'package:soundboard/features/innebandy_api/application/match_service.dart';
// import 'package:soundboard/features/innebandy_api/data/class_intermediate_results.dart';
// import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';

// // IbyVenueMatch selectedMatch = IbyVenueMatch(
// //   matchId: 0,
// //   categoryName: 'Ingen match vald',
// //   competitionName: 'Ingen match vald',
// //   matchNo: '0',
// //   matchDateTime: '2023-11-25T10:00:00',
// //   homeTeam: 'N/A',
// //   awayTeam: 'N/A',
// //   awayTeamLogotypeUrl: '',
// //   homeTeamLogotypeUrl: '',
// //   seasonId: 0,
// //   venue: '0',
// //   referee1: '',
// //   referee2: '',
// //   matchStatus: 0,
// // );

// // Define a StateProvider for IbyVenueMatch.
// final selectedMatchProvider = StateProvider<IbyVenueMatch>((ref) {
//   // Initialize with default values.
//   return IbyVenueMatch(
//     matchId: 0,
//     categoryName: 'Ingen match vald',
//     competitionName: 'Ingen match vald',
//     matchNo: '0',
//     matchDateTime: '2023-11-25T10:00:00',
//     homeTeam: 'N/A',
//     awayTeam: 'N/A',
//     awayTeamLogotypeUrl: '',
//     homeTeamLogotypeUrl: '',
//     seasonId: 0,
//     venue: '0',
//     referee1: '',
//     referee2: '',
//     matchStatus: 0,
//   );
// });

// IbyVenueMatch venueMatchFromJson(String str) =>
//     IbyVenueMatch.fromJson(json.decode(str));

// class IbyVenueMatch {
//   IbyVenueMatch({
//     required this.matchId,
//     required this.matchNo,
//     this.seasonId,
//     this.categoryName,
//     required this.competitionName,
//     required this.homeTeam,
//     required this.awayTeam,
//     required this.matchDateTime,
//     this.venue,
//     this.referee1,
//     this.referee2,
//     this.awayTeamLogotypeUrl,
//     this.homeTeamLogotypeUrl,
//     this.results,
//     this.events,
//     this.round,
//     this.roundName,
//     required this.matchStatus,
//     this.goalsHomeTeam,
//     this.goalsAwayTeam,
//     this.intermediateResults,
//     this.lastMatchChange,
//     this.lastMatchChangeComment,
//     this.competitionLogotypeUrl,
//     this.finalResultCreatedTs,
//     this.broadcastUrl,
//     this.ticketUrl,
//     this.arrangingAssociation,
//     this.note,
//     this.matchTimeMissing,
//     this.postponed,
//     this.abandoned,
//     this.cancelled,
//     this.extendedMatchInformation,
//     this.homeTeamShirtColor,
//     this.homeTeamAltShirtColor,
//     this.awayTeamShirtColor,
//     this.awayTeamAltShirtColor,
//     this.timeStamp,
//     this.createdTs,
//     this.updatedTs,
//     this.spectators,
//     this.matchDescription,
//   });

//   int matchId;
//   String matchNo;
//   int? seasonId;
//   String? categoryName;
//   String competitionName;
//   String homeTeam;
//   String awayTeam;
//   String matchDateTime;
//   String? venue;
//   String? referee1;
//   String? referee2;
//   String? awayTeamLogotypeUrl;
//   String? homeTeamLogotypeUrl;
//   List<dynamic>? results;
//   List<MatchEvent>? events;
//   int? round;
//   String? roundName;
//   int matchStatus;
//   int? goalsHomeTeam;
//   int? goalsAwayTeam;
//   List<IntermediateResult>? intermediateResults;
//   String? lastMatchChange;
//   String? lastMatchChangeComment;
//   String? competitionLogotypeUrl;
//   String? finalResultCreatedTs;
//   String? broadcastUrl;
//   String? ticketUrl;
//   String? arrangingAssociation;
//   String? note;
//   bool? matchTimeMissing;
//   bool? postponed;
//   bool? abandoned;
//   bool? cancelled;
//   dynamic extendedMatchInformation;
//   String? homeTeamShirtColor;
//   String? homeTeamAltShirtColor;
//   String? awayTeamShirtColor;
//   String? awayTeamAltShirtColor;
//   String? timeStamp;
//   String? createdTs;
//   String? updatedTs;
//   dynamic spectators;
//   dynamic matchDescription;
//   IbyMatchLineup? lineup;

//   factory IbyVenueMatch.fromJson(Map<String, dynamic> json) => IbyVenueMatch(
//         matchId: json["MatchID"],
//         matchNo: json["MatchNo"],
//         seasonId: json["SeasonID"],
//         categoryName: json["CategoryName"],
//         competitionName: json["CompetitionName"],
//         homeTeam: json["HomeTeam"],
//         awayTeam: json["AwayTeam"],
//         matchDateTime: json["MatchDateTime"],
//         venue: json["Venue"],
//         referee1: json["Referee1"] ?? 'N/A',
//         referee2: json["Referee2"] ?? 'N/A',
//         awayTeamLogotypeUrl: json["AwayTeamLogotypeUrl"],
//         homeTeamLogotypeUrl: json["HomeTeamLogotypeUrl"],
//         results: json["Results"],
//         events: json["Events"] != null
//             ? List<MatchEvent>.from(
//                 json["Events"].map((event) => MatchEvent.fromJson(event)),
//               )
//             : null,
//         round: json["Round"],
//         roundName: json["RoundName"],
//         matchStatus: json["MatchStatus"],
//         goalsHomeTeam: json["GoalsHomeTeam"],
//         goalsAwayTeam: json["GoalsAwayTeam"],
//         intermediateResults: json["IntermediateResults"] != null
//             ? List<IntermediateResult>.from(
//                 json["IntermediateResults"]
//                     .map((result) => IntermediateResult.fromJson(result)),
//               )
//             : null,
//         lastMatchChange: json["LastMatchChange"],
//         lastMatchChangeComment: json["LastMatchChangeComment"],
//         competitionLogotypeUrl: json["CompetitionLogotypeUrl"],
//         finalResultCreatedTs: json["FinalResultCreatedTS"],
//         broadcastUrl: json["BroadcastUrl"],
//         ticketUrl: json["TicketUrl"],
//         arrangingAssociation: json["ArrangingAssociation"],
//         note: json["Note"],
//         matchTimeMissing: json["MatchTimeMissing"],
//         postponed: json["Postponed"],
//         abandoned: json["Abandoned"],
//         cancelled: json["Cancelled"],
//         extendedMatchInformation: json["ExtendedMatchInformation"],
//         homeTeamShirtColor: json["HomeTeamShirtColor"],
//         homeTeamAltShirtColor: json["HomeTeamAltShirtColor"],
//         awayTeamShirtColor: json["AwayTeamShirtColor"],
//         awayTeamAltShirtColor: json["AwayTeamAltShirtColor"],
//         timeStamp: json["TimeStamp"],
//         createdTs: json["CreatedTS"],
//         updatedTs: json["UpdatedTS"],
//         spectators: json["Spectators"],
//         matchDescription: json["MatchDescription"],
//       );

//   Future<void> fetchLineup() async {
//     // Assuming you have a function getLineupByMatchId that makes the API call.
//     lineup = await getLineupByMatchId(matchId);
//   }

//   Future<IbyMatchLineup> getLineupByMatchId(int matchId) async {
//     if (kDebugMode) {
//       print("_getLineup");
//     }

//     final apiClient = APIClient();
//     final matchService = MatchService(apiClient);

//     // final apiService = APIService();
//     // final accessToken = await apiService.getAccessToken();
//     // if (kDebugMode) {
//     //   print("SettingsScreenStateSeason: $accessToken");
//     // }
//     IbyMatchLineup lineup =
//         await matchService.getLineupOfMatch(matchId: matchId);
//     return lineup;
//   }

//   IntermediateResult? getResultForPeriod(int period) {
//     if (intermediateResults == null) return null;
//     return intermediateResults!.firstWhere(
//       (result) => result.period == period,
//       orElse: () => IntermediateResult(
//         matchID: matchId,
//         period: period,
//         goalsHomeTeam: 0,
//         goalsAwayTeam: 0,
//       ),
//     );
//   }

//   String generateSsml() {
//     String ssml;
//     if (lineup == null) {
//       // ssml =
//       // '<speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" version="1.0" xml:lang="en-US">\n<lang xml:lang="sv-SE">';
//       // ssml += '<mstts:express-as style="sports_commentary">';
//       ssml = _generateTestSsml();
//       // ssml += "</mstts:express-as></lang></speak>";
//     } else {
//       // ssml =
//       // '<speak xmlns="http://www.w3.org/2001/10/synthesis" xmlns:mstts="http://www.w3.org/2001/mstts" xmlns:emo="http://www.w3.org/2009/10/emotionml" version="1.0" xml:lang="sv-SE">\n<lang xml:lang="sv-SE">';

//       ssml = _generateWelcomeMessage();
//       ssml += _generateHomeTeamLineup();
//       ssml += _generateAwayTeamLineup();
//       ssml += _generateRefereeMessage();
//       // ssml += "</lang></speak>";
//     }
//     return ssml;
//   }

//   String _generateTestSsml() {
//     String testssml = """
// Välkomna till Testhallen!
// <break time="500ms" />
// Testlaget hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan testlag blå och testlag vit
// Nummer 11, <say-as interpret-as='name'>Noah Zetterholm</say-as>,
// Nummer <lang xml:lang="sv-SE">27</lang>, <say-as interpret-as='name'>Eddie Rylin</say-as>,
// Nummer 42, <say-as interpret-as='name'>Henry Dahlström</say-as>,
// Nummer 82, <say-as interpret-as='name'>Liam Sandberg</say-as>,
// Välkomna! Testtext är nu slut
// """;
//     return testssml;
//   }

//   String _generateWelcomeMessage() {
//     return """
//     Välkomna till $venue!
//     <break time="1000ms" />
//     $homeTeam hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan $homeTeam och $awayTeam
//     <break time="1000ms" />
//     """;
//   }

//   String _generateHomeTeamLineup() {
//     String ssml = "$homeTeam ställer upp med följande spelare,";
//     String homeGoalie = "Dagens målvakt är inte inlagd i truppen,\n";
//     for (TeamPlayer player in lineup!.homeTeamPlayers) {
//       if (player.position == "Målvakt") {
//         homeGoalie =
//             "Dagens målvakt är <say-as interpret-as='name'>${player.name}</say-as>,\n";
//       } else {
//         ssml +=
//             "Nummer ${player.shirtNo}, <say-as interpret-as='name'>${player.name}</say-as>,\n";
//       }
//     }
//     ssml += homeGoalie;
//     ssml += "<break time=\"500ms\" />\n";
//     ssml += "Ledare för $homeTeam är,";
//     for (TeamTeamPerson teamPerson in lineup!.homeTeamTeamPersons) {
//       ssml += "<say-as interpret-as='name'>${teamPerson.name}</say-as>,\n";
//     }
//     ssml += "<break time=\"1000ms\" />\n";
//     return ssml;
//   }

//   String _generateAwayTeamLineup() {
//     String ssml = "${lineup!.awayTeam} ställer upp med följande spelare,\n";
//     String awayGoalie = "Dagens målvakt är inte inlagd i truppen,\n";
//     for (TeamPlayer player in lineup!.awayTeamPlayers) {
//       if (player.position == "Målvakt") {
//         awayGoalie =
//             "Dagens målvakt är <say-as interpret-as='name'>${player.name}</say-as>,\n";
//       } else {
//         ssml += player.shirtNo == null
//             ? "<say-as interpret-as='name'>${player.name}</say-as>,\n"
//             : "Nummer ${player.shirtNo}, <say-as interpret-as='name'>${player.name}</say-as>,\n";
//       }
//     }
//     ssml += awayGoalie;
//     ssml += "<break time=\"500ms\" />\n";
//     ssml += "Ledare för ${lineup!.awayTeam} är,";
//     for (TeamTeamPerson teamPerson in lineup!.awayTeamTeamPersons) {
//       ssml += "<say-as interpret-as='name'>${teamPerson.name}</say-as>,\n";
//     }
//     ssml += "<break time=\"1000ms\" />\n";
//     return ssml;
//   }

//   String _generateRefereeMessage() {
//     return "Domare i denna match är,,\n$referee1 och $referee2\n";
//   }
// }
