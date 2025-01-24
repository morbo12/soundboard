import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:dart_date/dart_date.dart';

import 'api_client.dart';
import 'api_constants.dart';

class MatchService {
  final APIClient _apiClient;

  MatchService(this._apiClient);

  Future<List<IbyMatch>> getMatchesInVenue({
    required int seasonId,
    required int venueId,
    required String date,
  }) async {
    final path = APIConstants.venueMatches
        .replaceAll('{venueId}', venueId.toString())
        .replaceAll('{seasonId}', seasonId.toString());
    DateTime dt = DateTime.parse(date);
    final response = await _apiClient.authenticatedGet(
      path,
      queryParameters: {
        "\$filter": "MatchDateTime eq ${dt.format("yyyy-MM-dd")}",
        "\$orderby": "MatchDateTime"
      },
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => IbyMatch.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to get matches in venue");
    }
  }

  Future<IbyMatchLineup> getLineupOfMatch({required int matchId}) async {
    final path =
        APIConstants.matchLineup.replaceAll('{matchId}', matchId.toString());
    final response = await _apiClient.authenticatedGet(path);

    if (response.statusCode == 200) {
      return IbyMatchLineup.fromJson(response.data);
    } else {
      throw Exception("Failed to get match lineup");
    }
  }

  Future<IbyMatch> getMatch({required int matchId}) async {
    final path = APIConstants.match.replaceAll('{matchId}', matchId.toString());
    final response = await _apiClient.authenticatedGet(path);

    if (response.statusCode == 200) {
      return IbyMatch.fromJson(response.data);
    } else {
      throw Exception("Failed to get match");
    }
  }
}
