import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/core/config/api_constants.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/pregame_stats.dart';
import 'package:soundboard/core/services/innebandy_api/presentation/providers/pregame_stats_provider.dart';
import 'api_client.dart';

class PregameStatsService {
  final APIClient _apiClient;

  PregameStatsService(this._apiClient);

  /// Fetches pregame statistics for a given match ID
  Future<PregameStats> getPregameStats(int matchId, WidgetRef ref) async {
    final path = APIConstants.pregameStats.replaceAll(
      '{matchId}',
      matchId.toString(),
    );

    final response = await _apiClient.authenticatedGet(path);
    if (response.statusCode == 200) {
      final pregameStats = PregameStats.fromJson(response.data);
      // Update the pregame stats provider
      ref.read(pregameStatsProvider.notifier).state = pregameStats;
      return pregameStats;
    } else {
      throw Exception("Failed to get pregame statistics");
    }
  }

  /// Convenience method to get pregame statistics from a match object
  Future<PregameStats> getPregameStatsFromMatch(
    IbyMatch match,
    WidgetRef ref,
  ) async {
    return getPregameStats(match.matchId, ref);
  }
}
