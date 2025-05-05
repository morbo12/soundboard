import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundboard/features/innebandy_api/core/config/api_constants.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/player_statistics.dart';
import 'package:soundboard/features/innebandy_api/presentation/providers/player_statistics_provider.dart';
import 'api_client.dart';

class PlayerStatisticsService {
  final APIClient _apiClient;

  PlayerStatisticsService(this._apiClient);

  /// Fetches player statistics for a given competition ID
  Future<PlayerStatistics> getPlayerStatistics(
    int? competitionId,
    WidgetRef ref,
  ) async {
    final path = APIConstants.playerStatistics.replaceAll(
      '{competitionId}',
      competitionId.toString(),
    );

    final response = await _apiClient.authenticatedGet(path);
    if (response.statusCode == 200) {
      final playerStatistics = PlayerStatistics.fromJson(response.data);
      // Update the player statistics provider
      ref.read(playerStatisticsProvider.notifier).state = playerStatistics;
      return playerStatistics;
    } else {
      throw Exception("Failed to get player statistics");
    }
  }

  /// Convenience method to get player statistics from a match object
  Future<PlayerStatistics> getPlayerStatisticsFromMatch(
    IbyMatch match,
    WidgetRef ref,
  ) async {
    return getPlayerStatistics(match.competitionId, ref);
  }
}
