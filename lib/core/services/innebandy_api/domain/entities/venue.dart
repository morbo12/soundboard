// import 'dart:ffi';
import 'dart:io';

import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:developer' as dev;
// import './class_auth.dart';

// Needs accessToken
class Venue {
  String url = "https://api.innebandy.se/v2/api/seasons/";
  String token;
  int seasonid;
  int venueid;
  DateTime date;

  Venue(
      {required this.token,
      required this.seasonid,
      required this.venueid,
      required this.date});

  Future fetch() async {
    var response = await http
        .get(Uri.parse("$url/$seasonid/venues/$venueid/matches"), headers: {
      HttpHeaders.authorizationHeader: "Bearer  $token",
    });
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception("Could not fetch URL");
    }
  }
}
