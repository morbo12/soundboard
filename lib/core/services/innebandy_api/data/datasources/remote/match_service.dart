import 'package:intl/intl.dart';

import 'package:soundboard/core/services/innebandy_api/core/config/api_constants.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';

import 'api_client.dart';

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
        "\$filter": "MatchDateTime eq ${DateFormat('yyyy-MM-dd').format(dt)}",
        "\$orderby": "MatchDateTime",
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
    final path = APIConstants.matchLineup.replaceAll(
      '{matchId}',
      matchId.toString(),
    );
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

  Future<List<IbyMatch>> getMatchesInCompetition({
    required int competitionId,
    String? date,
  }) async {
    final path = APIConstants.competitionMatches.replaceAll(
      '{competitionId}',
      competitionId.toString(),
    );

    Map<String, dynamic>? queryParameters;
    if (date != null) {
      DateTime dt = DateTime.parse(date);
      queryParameters = {
        "\$filter": "MatchDateTime eq ${DateFormat('yyyy-MM-dd').format(dt)}",
        "\$orderby": "MatchDateTime",
      };
    }

    final response = await _apiClient.authenticatedGet(
      path,
      queryParameters: queryParameters,
    );

    if (response.statusCode == 200) {
      return (response.data as List)
          .map((json) => IbyMatch.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to get matches in competition");
    }
  }
}
