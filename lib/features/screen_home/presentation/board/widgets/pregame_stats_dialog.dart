import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/pregame_stats.dart';
import 'package:soundboard/core/services/innebandy_api/presentation/providers/pregame_stats_provider.dart';

class PregameStatsDialog extends ConsumerWidget {
  final String homeTeam;
  final String awayTeam;

  const PregameStatsDialog({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pregameStats = ref.watch(pregameStatsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (pregameStats == null) {
      return AlertDialog(
        title: const Text('Förhandsstatistik'),
        content: const Text('Ingen förhandsstatistik tillgänglig'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Stäng'),
          ),
        ],
      );
    }

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Förhandsstatistik',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Team Rankings
                    if (pregameStats.homeTeamRanking != null ||
                        pregameStats.awayTeamRanking != null)
                      _buildRankingsCard(pregameStats, theme),

                    const SizedBox(height: 16),

                    // Last Meeting
                    if (pregameStats.homeTeamGoalsLastMeeting != null ||
                        pregameStats.awayTeamGoalsLastMeeting != null)
                      _buildLastMeetingCard(pregameStats, theme),

                    const SizedBox(height: 16),

                    // Head to Head
                    _buildHeadToHeadCard(pregameStats, theme),

                    const SizedBox(height: 16),

                    // Team Trends
                    _buildTrendsCard(pregameStats, theme),

                    const SizedBox(height: 16),

                    // Last Games
                    _buildLastGamesCard(pregameStats, theme),

                    const SizedBox(height: 16),

                    // Hot Players (only if available)
                    if (_hasHotPlayers(pregameStats))
                      _buildHotPlayersCard(pregameStats, theme),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _hasHotPlayers(PregameStats stats) {
    return (stats.homeHotPlayersBeforeGame != null &&
            stats.homeHotPlayersBeforeGame!.isNotEmpty) ||
        (stats.awayHotPlayersBeforeGame != null &&
            stats.awayHotPlayersBeforeGame!.isNotEmpty);
  }

  Widget _buildRankingsCard(PregameStats stats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tabellplacering',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildRankingItem(stats.homeTeam, stats.homeTeamRanking, theme),
                _buildRankingItem(stats.awayTeam, stats.awayTeamRanking, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingItem(String team, int? ranking, ThemeData theme) {
    return Column(
      children: [
        Text(
          team,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            ranking != null ? '#$ranking' : 'N/A',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLastMeetingCard(PregameStats stats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Senaste mötet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(stats.homeTeam, style: theme.textTheme.bodyLarge),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${stats.homeTeamGoalsLastMeeting ?? 0} - ${stats.awayTeamGoalsLastMeeting ?? 0}',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(stats.awayTeam, style: theme.textTheme.bodyLarge),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeadToHeadCard(PregameStats stats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inbördes möten',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildH2HItem(
                  stats.homeTeam,
                  stats.homeTeamMeetingWins,
                  'Vinster',
                  theme,
                ),
                _buildH2HItem('Oavgjort', stats.meetingDraws, '', theme),
                _buildH2HItem(
                  stats.awayTeam,
                  stats.awayTeamMeetingWins,
                  'Vinster',
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildH2HItem(
    String label,
    int value,
    String subtitle,
    ThemeData theme,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        if (subtitle.isNotEmpty)
          Text(subtitle, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildTrendsCard(PregameStats stats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Form (senaste matcherna)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrendItem(stats.homeTeam, stats.homeTeamTrend, theme),
                _buildTrendItem(stats.awayTeam, stats.awayTeamTrend, theme),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendItem(String team, int? trend, ThemeData theme) {
    final trendColor = trend != null
        ? (trend > 0
              ? Colors.green
              : trend < 0
              ? Colors.red
              : Colors.grey)
        : Colors.grey;

    final trendIcon = trend != null
        ? (trend > 0
              ? Icons.trending_up
              : trend < 0
              ? Icons.trending_down
              : Icons.trending_flat)
        : Icons.trending_flat;

    return Column(
      children: [
        Text(
          team,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(trendIcon, color: trendColor, size: 32),
            const SizedBox(width: 4),
            Text(
              trend != null ? '${trend > 0 ? '+' : ''}$trend' : 'N/A',
              style: theme.textTheme.titleLarge?.copyWith(
                color: trendColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLastGamesCard(PregameStats stats, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Senaste matcher',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: [
                _buildLastGamesRow(
                  stats.homeTeam,
                  stats.homeTeamLastGames,
                  theme,
                ),
                const SizedBox(height: 12),
                _buildLastGamesRow(
                  stats.awayTeam,
                  stats.awayTeamLastGames,
                  theme,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastGamesRow(String team, List<int> games, ThemeData theme) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            team,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 4,
            children: games
                .map(
                  (goals) => Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: _getGameResultColor(goals, theme),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        goals.toString(),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Color _getGameResultColor(int goals, ThemeData theme) {
    // Games with 6+ goals are typically wins (green)
    // Games with 1-3 goals are typically losses (red)
    // Games with 4-5 goals could be close games (orange)
    if (goals >= 6) {
      return Colors.green.shade700;
    } else if (goals >= 4) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  Widget _buildHotPlayersCard(PregameStats stats, ThemeData theme) {
    final hasHomePlayers =
        stats.homeHotPlayersBeforeGame != null &&
        stats.homeHotPlayersBeforeGame!.isNotEmpty;
    final hasAwayPlayers =
        stats.awayHotPlayersBeforeGame != null &&
        stats.awayHotPlayersBeforeGame!.isNotEmpty;

    if (!hasHomePlayers && !hasAwayPlayers) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Heta spelare',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (hasHomePlayers) ...[
              Text(
                stats.homeTeam,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...stats.homeHotPlayersBeforeGame!.map(
                (player) => _buildHotPlayerItem(player, theme),
              ),
              const SizedBox(height: 16),
            ],
            if (hasAwayPlayers) ...[
              Text(
                stats.awayTeam,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ...stats.awayHotPlayersBeforeGame!.map(
                (player) => _buildHotPlayerItem(player, theme),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHotPlayerItem(HotPlayer player, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(player.playerName, style: theme.textTheme.bodyMedium),
          ),
          _buildStatBadge('${player.goals}M', theme),
          const SizedBox(width: 4),
          _buildStatBadge('${player.assists}A', theme),
          const SizedBox(width: 4),
          _buildStatBadge('${player.points}P', theme),
        ],
      ),
    );
  }

  Widget _buildStatBadge(String text, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
