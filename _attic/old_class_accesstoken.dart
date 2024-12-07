// import 'dart:convert';
// import 'package:soundboard/features/innebandy_api/application/old_api.dart';

// AccessTokenData token = AccessTokenData(
//   accessToken: "",
//   accessTokenExpiration: "2010-01-01T00:00:00.000000+01:00",
//   apiRoot: "",
//   statusCode: 0,
//   reasonPhrase: null,
//   facebookAppId: "",
// );

// class AccessTokenData {
//   final String accessToken;
//   final String accessTokenExpiration;
//   final String apiRoot;
//   final int statusCode;
//   final String? reasonPhrase;
//   final String facebookAppId;
//   final api = API();

//   AccessTokenData({
//     required this.accessToken,
//     required this.accessTokenExpiration,
//     required this.apiRoot,
//     required this.statusCode,
//     this.reasonPhrase,
//     required this.facebookAppId,
//   });

//   // Factory method to create an instance of AccessTokenData from a JSON map
//   factory AccessTokenData.fromJson(Map<String, dynamic> json) {
//     return AccessTokenData(
//       accessToken: json['accessToken'],
//       accessTokenExpiration: json['accessTokenExpiration'],
//       apiRoot: json['apiRoot'],
//       statusCode: json['statusCode'],
//       reasonPhrase: json['reasonPhrase'],
//       facebookAppId: json['facebookAppId'],
//     );
//   }

//   // Factory method to create an instance of AccessTokenData from a JSON string
//   factory AccessTokenData.fromJsonString(String jsonString) {
//     final Map<String, dynamic> json = jsonDecode(jsonString);
//     return AccessTokenData.fromJson(json);
//   }
// }
