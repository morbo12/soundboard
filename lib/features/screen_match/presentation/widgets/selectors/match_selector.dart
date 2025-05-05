import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:soundboard/features/innebandy_api/data/datasources/remote/api_client_provider.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/match_service.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/player_statistics_service.dart';
import 'package:soundboard/features/innebandy_api/data/datasources/remote/standings_service.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/innebandy_api/presentation/providers/player_statistics_provider.dart';
import 'package:soundboard/features/innebandy_api/presentation/providers/standings_provider.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

/// Widget for displaying and selecting matches from a list.
///
/// This widget:
/// - Displays a scrollable list of matches
/// - Shows match details including teams, competition, date, and venue
/// - Handles match selection and lineup fetching
/// - Provides visual feedback for selected matches
class MatchSelector extends ConsumerWidget {
  /// Creates a new instance of [MatchSelector].
  const MatchSelector({super.key});

  /// Fetches detailed match information and lineup when a match is selected.
  ///
  /// This method:
  /// 1. Fetches the complete match details
  /// 2. Updates the selected match in the state
  /// 3. Fetches the lineup for the selected match
  /// 4. Updates the lineup in the state
  ///
  /// [matchID] is the unique identifier of the selected match.
  Future<void> _getMatch(WidgetRef ref, int matchID) async {
    final apiClient = ref.watch(apiClientProvider);
    final matchService = MatchService(apiClient);
    final standingsService = StandingsService(apiClient);
    final playerStatisticsService = PlayerStatisticsService(apiClient);
    final match = await matchService.getMatch(matchId: matchID);

    // Update the selected match in the provider
    ref.read(selectedMatchProvider.notifier).state = match;
    await match.fetchLineup(ref);
    ref.read(lineupProvider.notifier).state = await match.getLineupByMatchId(
      matchID,
      ref,
    );
    // Fetch standings for the given match
    ref.read(standingsProvider.notifier).state = await standingsService
        .getCurrentStandings(match, ref);

    // Fetch player statistics for the given match
    ref.read(playerStatisticsProvider.notifier).state =
        await playerStatisticsService.getPlayerStatisticsFromMatch(match, ref);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final matches = ref.watch(matchesProvider);

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            title: Text(
              '${match.homeTeam} vs ${match.awayTeam} (${match.competitionName})',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${DateFormat.yMd(Localizations.localeOf(context).toString()).format(DateTime.parse(match.matchDateTime))} - ${match.venue ?? "Unknown venue"}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            onTap: () {
              _getMatch(ref, match.matchId);
            },
            tileColor: theme.colorScheme.surfaceContainerHighest.withAlpha(77),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      },
    );
  }
}
