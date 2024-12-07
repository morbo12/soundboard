// // import 'dart:ffi';
// // ignore_for_file: unused_import

// import 'dart:io';
// import 'package:dart_date/dart_date.dart';
// import 'package:flutter/foundation.dart';
// import "package:http/http.dart" as http;
// import 'package:soundboard/constants/globals.dart';
// import 'dart:convert';
// import 'package:soundboard/features/innebandy_api/application/old_api.dart';
// import 'package:soundboard/features/innebandy_api/data/class_accesstoken.dart';
// import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';

// class APIService {
//   // String authUrl = "https://api.innebandy.se/StatsAppApi/api/startkit";
//   final api = API();
//   // Future get token => _token;

//   Future<AccessTokenData> getAccessToken() async {
//     final uri = api.endpointUri(Endpoint.startKit);

//     if (DateTime.now().isBefore(DateTime.parse(token.accessTokenExpiration))) {
//       if (kDebugMode) {
//         print(
//             "Token is NOT expired: NOW: ${DateTime.now()} - Token: ${token.accessTokenExpiration} ");
//       }
//       return token;
//     } else {
//       if (kDebugMode) {
//         print(
//             "Token is expired: NOW: ${DateTime.now()} - Token: ${token.accessTokenExpiration}  ");
//         print("URI: $uri");
//       }
//       final response = await http.get(uri);
//       if (response.statusCode == 200) {
//         if (kDebugMode) {
//           print(
//               'access token is -> ${json.decode(response.body)['accessToken']}');
//         }
//         token = AccessTokenData.fromJson(json.decode(response.body));
//         return token;
//       } else {
//         if (kDebugMode) {
//           print(
//               'Request ${api.tokenUri()} failed\nResponse: $response - CODE: $response.code');
//         }
//         throw response;
//       }
//     }
//   }

//   Future<int> getSeason({required String accessToken}) async {
//     final uri = api.seasonUri(Endpoint.seasons);
//     final response = await http.get(uri, headers: {
//       HttpHeaders.authorizationHeader: "Bearer $accessToken",
//     });
//     if (response.statusCode == 200) {
//       // var data = jsonDecode(response.body)
//       //     .where((val) => val["IsCurrentSeason"] == true);
//       var data = jsonDecode(response.body);
//       // if (kDebugMode) {
//       //   print('DATA -> $data');
//       // }
//       final seasonID = data.first["SeasonID"];
//       return seasonID;
//     } else {
//       throw response;
//     }
//   }

//   // Parse matches
//   List<IbyVenueMatch> parseMatch(String responseBody) {
//     final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
//     return parsed
//         .map<IbyVenueMatch>((json) => IbyVenueMatch.fromJson(json))
//         .toList();
//   }

//   Future<List<IbyVenueMatch>> getMatchesInVenue({
//     required String accessToken,
//     required int seasonId,
//     required int venueId,
//     required String date,
//   }) async {
//     final uri = api.venueUri(seasonId, venueId, date);
//     DateTime dt = DateTime.parse(date);
//     if (kDebugMode) {
//       print("Dateparsed: ${dt.format("yyyy-MM-dd")}");
//       print(uri);
//     }
//     final response = await http.get(uri, headers: {
//       HttpHeaders.authorizationHeader: "Bearer $accessToken",
//     });

//     if (response.statusCode == 200) {
//       return parseMatch(response.body);
//     } else {
//       throw Exception("Could not fetch URL");
//     }
//   }

//   // Parse Lineup
//   IbyMatchLineup parseLineup(String responseBody) {
//     final parsed = jsonDecode(responseBody); // .cast<Map<String, dynamic>>();
//     return parsed
//         .map<IbyMatchLineup>((json) => IbyMatchLineup.fromJson(json))
//         .toList();
//   }

//   Future<IbyMatchLineup> getLineupOfMatch({
//     required String accessToken,
//     required int matchId,
//   }) async {
//     final uri = api.lineupUri(matchId);
//     if (kDebugMode) {
//       print("LineupURI is: $uri");
//     }
//     final response = await http.get(uri, headers: {
//       HttpHeaders.authorizationHeader: "Bearer $accessToken",
//     });

//     if (response.statusCode == 200) {
//       if (kDebugMode) {
//         print("Return code was: ${response.statusCode}");
//       }
//       return matchFromJson(response.body);
//     } else {
//       throw Exception("Could not fetch URL ${response.statusCode}");
//     }
//   }
// //   Future<List<Match>> fetchLineup(DateTime date) async {
// //     print("Date: $date");
// //
// //     // Matches in Venue, filtered on selected date
// //     matches = await getMatchesInVenue(date);
// //     // var venue =
// //     // Venue(token: token, date: date, seasonid: currentSeason, venueid: 3455);
// //     // final venueData = await venue.fetch();
// //     print("Venue: $matches");
// //
// // // # Loop matches to find today's match
// //     final sDate = Date.parse(date.toIso8601String());
// //
// //     for (Match element in matches) {
// //       if (sDate.isSameDay(Date.parse(element.matchDateTime))) {
// //         print("MATCHED ${element.matchDateTime}");
// //
// //         todaysMatches.add(element);
// //       }
// //     }
// //     print("sDate is: $sDate");
// //     print(todaysMatches.length);
// //     // _selectMatch(todaysMatches);
// //     return todaysMatches;
// //   }

//   Future getEntpointData(
//       {required String accessToken, required Endpoint endpoint}) async {
//     final uri = api.endpointUri(endpoint);
//     final response = await http.get(uri, headers: {
//       HttpHeaders.authorizationHeader: "Bearer  $this.token",
//     });
//     if (response.statusCode == 200) {
//       if (kDebugMode) {
//         print(
//             'access token is -> ${json.decode(response.body)['accessToken']}');
//       }
//     } else {
//       throw response;
//     }
//   }

// // Parse matchdata
//   // IbyVenueMatch faadasdas(String responseBody) {
//   //   final parsed = jsonDecode(responseBody); // .cast<Map<String, dynamic>>();
//   //   return parsed
//   //       .map<IbyMatchLineup>((json) => IbyMatchLineup.fromJson(json))
//   //       .toList();
//   // }

//   Future<IbyVenueMatch> getMatch({
//     required String accessToken,
//     required int matchId,
//   }) async {
//     final uri = api.matchUri(matchId);
//     if (kDebugMode) {
//       print("getMatchURI is: $uri");
//     }
//     final response = await http.get(uri, headers: {
//       HttpHeaders.authorizationHeader: "Bearer $accessToken",
//     });

//     if (response.statusCode == 200) {
//       if (kDebugMode) {
//         print("Return code was: ${response.statusCode}");
//       }
//       return venueMatchFromJson(response.body);
//     } else {
//       throw Exception("Could not fetch URL ${response.statusCode}");
//     }
//   }
// }
