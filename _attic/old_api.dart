// import 'package:dart_date/dart_date.dart';
// import 'dart:core';

// enum Endpoint {
//   startKit,
//   seasons,
//   venue,
// }

// class API {
//   static const String host = "api.innebandy.se";
//   static const int port = 443;

//   // static const String host = "localhost";
//   // static const int port = 3000;
//   // API({@required this.apiKey});
//   // factory API.sandbox() => API(apiKey: APIKeys.ncovSandboxKey);

//   Uri tokenUri() => Uri(
//         host: host,
//         path: '/StatsAppApi/api/startkit',
//         port: port,
//         scheme: 'https',
//       );
//   Uri endpointUri(Endpoint endpoint) => Uri(
//         host: host,
//         port: port,
//         scheme: 'https',
//         path: _paths[endpoint],
//       );
//   Uri seasonUri(Endpoint endpoint) => Uri(
//       host: host,
//       port: port,
//       scheme: 'https',
//       path: "/v2/api/seasons",
//       queryParameters: {"\$filter": "IsCurrentSeason eq true"});

//   Uri venueUri(int seasonID, int venueID, String date) {
//     DateTime dt = DateTime.parse(date);
//     return Uri(
//         host: host,
//         port: port,
//         scheme: 'https',
//         path: "/v2/api/seasons/$seasonID/venues/$venueID/matches",
//         queryParameters: {
//           "\$filter": "MatchDateTime eq ${dt.format("yyyy-MM-dd")}",
//           "\$orderby": "MatchDateTime"
//         });
//   }

//   Uri lineupUri(int matchId) => Uri(
//         host: host,
//         port: port,
//         scheme: 'https',
//         path: "v2/api/matches/$matchId/lineups",
//       );

//   Uri matchUri(int matchId) => Uri(
//         host: host,
//         port: port,
//         scheme: 'https',
//         path: "v2/api/matches/$matchId",
//       );

//   final Map<Endpoint, String> _paths = {
//     Endpoint.seasons: '/v2/api/seasons?\$filter=IsCurrentSeason eq true',
//     Endpoint.startKit: "/StatsAppApi/api/startkit",
//     // Endpoint.venue: "/v2/api/seasons/${seasonID}/venues/${venueID}/matches",
//   };
// }

// // https://api.innebandy.se/v2/api/seasons/40/venues/3455/matches?$filter=MatchDateTime eq 2023-03-12
