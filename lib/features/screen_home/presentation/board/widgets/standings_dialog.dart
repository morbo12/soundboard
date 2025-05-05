import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/domain/entities/player_statistics.dart';
import 'package:soundboard/features/innebandy_api/presentation/providers/player_statistics_provider.dart';
import 'package:soundboard/features/innebandy_api/presentation/providers/standings_provider.dart';

class StandingsDialog extends ConsumerWidget {
  final String competitionName;

  const StandingsDialog({super.key, required this.competitionName});

  Widget _buildLastGamesIndicator(List<int> lastGames, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children:
          lastGames.map((result) {
            Color boxColor;
            switch (result) {
              case 6: // Win
                boxColor = Colors.green;
                break;
              case 4: // Draw
                boxColor = Colors.grey.shade600;
                break;
              case 1: // Loss
                boxColor = Colors.red;
                break;
              default:
                boxColor = Colors.grey;
            }
            return Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: boxColor.withAlpha(230),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final standings = ref.watch(standingsProvider);
    final playerStats = ref.watch(filteredPlayerStatisticsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    competitionName,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DefaultTabController(
              length: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Standings'),
                      Tab(text: 'Player Statistics'),
                    ],
                    labelColor: theme.colorScheme.primary,
                    unselectedLabelColor: theme.colorScheme.onSurface
                        .withOpacity(0.6),
                    indicatorColor: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: TabBarView(
                      children: [
                        // Standings Tab
                        _buildStandingsTab(context, standings, theme),
                        // Player Statistics Tab
                        _buildPlayerStatsTab(context, playerStats, theme, ref),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStandingsTab(
    BuildContext context,
    dynamic standings,
    ThemeData theme,
  ) {
    if (standings == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Add explanation of standings
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Text(
              'S: Spelade matcher, V: Vunna matcher, O: Oavgjorda, F: Förluster, GM: Gjorda mål, IM: Insläppta mål, P: Poäng, Senaste 5: Form under de 5 senaste matcherna',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(color: theme.colorScheme.primary.withOpacity(0.3)),
          Table(
            columnWidths: const {
              0: FixedColumnWidth(32), // Position
              1: FlexColumnWidth(3), // Team
              2: FixedColumnWidth(32), // Played
              3: FixedColumnWidth(32), // Won
              4: FixedColumnWidth(32), // Draw
              5: FixedColumnWidth(32), // Lost
              6: FixedColumnWidth(32), // Points
              7: FixedColumnWidth(64), // Goals
              8: FixedColumnWidth(40), // GD
              9: FixedColumnWidth(80), // Last Games
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                ),
                children: [
                  _buildHeaderCell(context, '#'),
                  _buildHeaderCell(context, 'Team'),
                  _buildHeaderCell(context, 'S'),
                  _buildHeaderCell(context, 'V'),
                  _buildHeaderCell(context, 'O'),
                  _buildHeaderCell(context, 'F'),
                  _buildHeaderCell(context, 'Pts'),
                  _buildHeaderCell(context, 'GM-IM'),
                  _buildHeaderCell(context, '+/-'),
                  _buildHeaderCell(context, 'Senaste 5'),
                ],
              ),
              ...standings.standingsRows.asMap().entries.map((entry) {
                final index = entry.key;
                final row = entry.value;
                final isStrikethrough = row.teamStatusId == 5;
                return TableRow(
                  decoration: BoxDecoration(
                    color:
                        index.isEven
                            ? theme.colorScheme.surface
                            : theme.colorScheme.surfaceVariant.withAlpha(3),
                  ),
                  children: [
                    _buildCell(
                      context,
                      '${row.position}',
                      isStrikethrough: isStrikethrough,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: Row(
                        children: [
                          if (row.teamLogotypeUrl.isNotEmpty)
                            Image.network(
                              row.teamLogotypeUrl,
                              width: 20,
                              height: 20,
                              errorBuilder:
                                  (_, __, ___) => const SizedBox(width: 20),
                            ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              row.teamName,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                decoration:
                                    isStrikethrough
                                        ? TextDecoration.lineThrough
                                        : null,
                                decorationThickness: 3.0,
                                decorationStyle: TextDecorationStyle.solid,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildCell(
                      context,
                      '${row.totalMatches}',
                      isStrikethrough: isStrikethrough,
                    ),
                    _buildCell(
                      context,
                      '${row.totalWins}',
                      isStrikethrough: isStrikethrough,
                    ),
                    _buildCell(
                      context,
                      '${row.totalDraws}',
                      isStrikethrough: isStrikethrough,
                    ),
                    _buildCell(
                      context,
                      '${row.totalLosses}',
                      isStrikethrough: isStrikethrough,
                    ),
                    _buildCell(
                      context,
                      '${row.points}',
                      isStrikethrough: isStrikethrough,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    _buildCell(
                      context,
                      '${row.totalGoalsScored}-${row.totalGoalsAgainst}',
                      isStrikethrough: isStrikethrough,
                    ),
                    _buildCell(
                      context,
                      '${row.scoringDiff}',
                      isStrikethrough: isStrikethrough,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 4,
                      ),
                      child: _buildLastGamesIndicator(row.lastGames, theme),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerStatsTab(
    BuildContext context,
    PlayerStatistics? playerStats,
    ThemeData theme,
    WidgetRef ref,
  ) {
    if (playerStats == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Sort by points (descending)
    final filteredStats = List<PlayerStatisticsRow>.from(
      playerStats.playerStatisticsRows,
    );
    filteredStats.sort((a, b) => b.points.compareTo(a.points));

    // Group by team
    final Map<int, List<PlayerStatisticsRow>> statsByTeam = {};
    for (var player in filteredStats) {
      if (!statsByTeam.containsKey(player.teamId)) {
        statsByTeam[player.teamId] = [];
      }
      statsByTeam[player.teamId]!.add(player);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Add explanation of statistics
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            child: Text(
              'Ma: Spelade matcher, Må: Gjorda mål, Ass: Målgivande passningar, Utv: Utvisningsminuter, P: Poäng',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Divider(color: theme.colorScheme.primary.withOpacity(0.3)),
          ...statsByTeam.entries.map((entry) {
            final teamPlayers = entry.value;
            final teamName =
                teamPlayers.isNotEmpty
                    ? teamPlayers.first.teamName
                    : 'Unknown Team';

            // Take only top 5 players per team
            final topPlayers = teamPlayers.take(5).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    teamName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(3), // Player
                    1: FixedColumnWidth(40), // GP
                    2: FixedColumnWidth(40), // G
                    3: FixedColumnWidth(40), // A
                    4: FixedColumnWidth(40), // Pts
                    5: FixedColumnWidth(40), // PIM
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(25),
                      ),
                      children: [
                        _buildHeaderCell(context, 'Spelare'),
                        _buildHeaderCell(context, 'Ma'),
                        _buildHeaderCell(context, 'Må'),
                        _buildHeaderCell(context, 'Ass'),
                        _buildHeaderCell(context, 'P'),
                        _buildHeaderCell(context, 'Utv'),
                      ],
                    ),
                    ...topPlayers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      return TableRow(
                        decoration: BoxDecoration(
                          color:
                              index.isEven
                                  ? theme.colorScheme.surface
                                  : theme.colorScheme.surfaceVariant.withAlpha(
                                    3,
                                  ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 4,
                            ),
                            child: Text(
                              player.playerName,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          _buildCell(context, '${player.matchesPlayed}'),
                          _buildCell(context, '${player.goalsScored}'),
                          _buildCell(context, '${player.assists}'),
                          _buildCell(
                            context,
                            '${player.points}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          _buildCell(context, '${player.penaltyMinutes}'),
                        ],
                      );
                    }).toList(),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: Theme.of(
          context,
        ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCell(
    BuildContext context,
    String text, {
    bool isStrikethrough = false,
    TextStyle? style,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
          decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          decorationThickness: 3.0,
          decorationStyle: TextDecorationStyle.solid,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
