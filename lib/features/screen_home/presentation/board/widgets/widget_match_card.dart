import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/features/screen_home/presentation/board/widgets/matchstatus.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/core/services/innebandy_api/presentation/providers/standings_provider.dart';
import 'package:soundboard/core/services/innebandy_api/presentation/providers/player_statistics_provider.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'standings_dialog.dart';

class MatchCard extends ConsumerWidget {
  final IbyMatch match;

  const MatchCard({Key? key, required this.match}) : super(key: key);

  Widget _buildTeamLogo(
    String? url,
    String fallbackText,
    BuildContext context,
  ) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          fallbackText,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 16,
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }

  void _showStandings(BuildContext context, WidgetRef ref) {
    final standings = ref.read(standingsProvider);
    if (standings != null) {
      showDialog(
        context: context,
        builder: (context) =>
            StandingsDialog(competitionName: match.competitionName),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No standings data available'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Checks if standings data is available
  bool _hasStandingsData(WidgetRef ref) {
    final standings = ref.watch(standingsProvider);
    return standings != null && standings.standingsRows.isNotEmpty;
  }

  /// Checks if player statistics data is available
  bool _hasPlayerStatistics(WidgetRef ref) {
    final playerStats = ref.watch(playerStatisticsProvider);
    return playerStats != null && playerStats.playerStatisticsRows.isNotEmpty;
  }

  /// Checks if lineup data is available and has players
  bool _hasLineupData(WidgetRef ref) {
    final lineup = ref.watch(lineupProvider);
    return lineup.matchId != 0 &&
        (lineup.homeTeamPlayers.isNotEmpty ||
            lineup.awayTeamPlayers.isNotEmpty);
  }

  /// Checks if match has events data
  bool _hasEventsData() {
    return match.events != null && match.events!.isNotEmpty;
  }

  /// Builds stats availability indicators
  Widget _buildStatsIndicators(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final indicators = <Widget>[];

    // Standings indicator
    if (_hasStandingsData(ref)) {
      indicators.add(
        Tooltip(
          message: 'Standings available',
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withAlpha(204),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.leaderboard,
              size: 12,
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
      );
    }

    // Player statistics indicator
    if (_hasPlayerStatistics(ref)) {
      indicators.add(
        Tooltip(
          message: 'Player statistics available',
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withAlpha(204),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.bar_chart,
              size: 12,
              color: theme.colorScheme.onSecondary,
            ),
          ),
        ),
      );
    }

    // Lineup indicator
    if (_hasLineupData(ref)) {
      indicators.add(
        Tooltip(
          message: 'Team lineups available',
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withAlpha(204),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.people,
              size: 12,
              color: theme.colorScheme.onTertiary,
            ),
          ),
        ),
      );
    }

    // Events indicator
    if (_hasEventsData()) {
      indicators.add(
        Tooltip(
          message: 'Match events available',
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withAlpha(204),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.event_note,
              size: 12,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      );
    }

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: indicators
          .map(
            (indicator) => Padding(
              padding: const EdgeInsets.only(right: 4),
              child: indicator,
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final statusText =
        StatusDescriptions.descriptions[match.matchStatus] ?? 'N/A';
    final statusColor = match.matchStatus == 2
        ? theme.colorScheme.tertiary
        : match.matchStatus == 1
        ? theme.colorScheme.secondary
        : theme.colorScheme.primary;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainer,
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showStandings(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header: Competition and Match Number
              Row(
                children: [
                  Expanded(
                    child: Text(
                      match.competitionName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '#${match.matchNo}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              // Stats indicators row
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 4),
                child: Row(
                  children: [
                    _buildStatsIndicators(context, ref),
                    const Spacer(),
                  ],
                ),
              ),
              // Date and Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.yMd().format(
                      DateTime.parse(match.matchDateTime),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat.Hm().format(DateTime.parse(match.matchDateTime)),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Teams Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        _buildTeamLogo(
                          match.homeTeamLogotypeUrl,
                          match.homeTeam.substring(0, 1),
                          context,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            match.homeTeam,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: Text(
                      'vs',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Text(
                            match.awayTeam,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTeamLogo(
                          match.awayTeamLogotypeUrl,
                          match.awayTeam.substring(0, 1),
                          context,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Status Row
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.sports_hockey, size: 14, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      statusText,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// Contains AI-generated edits.
