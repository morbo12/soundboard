import 'package:soundboard/core/services/innebandy_api/core/config/api_constants.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition_type.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition_with_matches.dart';

import 'api_client.dart';

class CompetitionService {
  final APIClient _apiClient;

  CompetitionService(this._apiClient);

  /// Fetches competitions or tournaments for a given season and federation
  Future<List<Competition>> getCompetitions({
    required int seasonId,
    required int federationId,
    required CompetitionType type,
  }) async {
    final path = type == CompetitionType.competition
        ? APIConstants.competitions
        : APIConstants.tournaments;

    final finalPath = path
        .replaceAll('{seasonId}', seasonId.toString())
        .replaceAll('{federationId}', federationId.toString());

    final response = await _apiClient.authenticatedGet(finalPath);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Competition.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch ${type.displayName.toLowerCase()}: ${response.statusCode}',
      );
    }
  }

  /// Fetches a competition category with all its matches and standings.
  /// This is used for tournaments which return everything in one call.
  Future<List<CompetitionWithMatches>> getCompetitionCategoryWithMatches({
    required int seasonId,
    required int competitionCategoryId,
  }) async {
    final path = APIConstants.competitionCategoryWithMatches
        .replaceAll('{seasonId}', seasonId.toString())
        .replaceAll(
          '{competitionCategoryId}',
          competitionCategoryId.toString(),
        );

    final response = await _apiClient.authenticatedGet(path);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => CompetitionWithMatches.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to fetch competition category with matches: ${response.statusCode}',
      );
    }
  }
}
