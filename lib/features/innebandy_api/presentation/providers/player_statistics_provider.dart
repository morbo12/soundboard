import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/player_statistics.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';

/// Provider that holds the current player statistics data
final playerStatisticsProvider = StateProvider<PlayerStatistics?>(
  (ref) => null,
);

/// Provider that filters player statistics to only include players from teams in the current match
final filteredPlayerStatisticsProvider = Provider<PlayerStatistics?>((ref) {
  final playerStats = ref.watch(playerStatisticsProvider);
  final selectedMatch = ref.watch(selectedMatchProvider);
  
  if (playerStats == null || selectedMatch == null) {
    return playerStats;
  }
  
  // Get the team IDs from the current match
  final homeTeamId = selectedMatch.homeTeamId;
  final awayTeamId = selectedMatch.awayTeamId;
  
  // Filter player statistics to only include players from the teams in the current match
  final filteredRows = playerStats.playerStatisticsRows
      .where((player) => player.teamId == homeTeamId || player.teamId == awayTeamId)
      .toList();
  
  return PlayerStatistics(playerStatisticsRows: filteredRows);
});
