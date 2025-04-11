// // import 'dart:ffi';
// import 'dart:io';

// import 'package:http/http.dart' as http;
// import 'dart:convert';
// // import 'dart:developer' as dev;
// // import 'api_service.dart';

// // Needs accessToken
// class Season {
//   String url = "https://api.innebandy.se/v2/api/seasons";
//   // String token;

//   // Season(this.token);

//   Future fetch() async {
//     var response = await http.get(
//       Uri.parse(url),
//       headers: {HttpHeaders.authorizationHeader: "Bearer  $this.token"},
//     );
//     if (response.statusCode == 200) {
//       var data = jsonDecode(
//         response.body,
//       ).where((val) => val["IsCurrentSeason"] == true);
//       // dev.log('access token is -> $data');
//       final id = data.first["SeasonID"];
//       print('id is -> $id');
//       return id;
//     } else {
//       throw Exception("Could not fetch URL");
//     }
//   }
// }
