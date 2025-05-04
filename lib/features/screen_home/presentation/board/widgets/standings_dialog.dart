import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            if (standings == null)
              const Center(child: CircularProgressIndicator())
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(32), // Position
                      1: FlexColumnWidth(3), // Team
                      2: FixedColumnWidth(32), // Played
                      3: FixedColumnWidth(32), // Won
                      4: FixedColumnWidth(32), // Draw
                      5: FixedColumnWidth(32), // Lost
                      6: FixedColumnWidth(32), // Points
                      7: FixedColumnWidth(64), // Goals
                      8: FixedColumnWidth(32), // GD
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
                          _buildHeaderCell(context, 'P'),
                          _buildHeaderCell(context, 'W'),
                          _buildHeaderCell(context, 'D'),
                          _buildHeaderCell(context, 'L'),
                          _buildHeaderCell(context, 'Pts'),
                          _buildHeaderCell(context, 'Goals'),
                          _buildHeaderCell(context, 'GD'),
                          _buildHeaderCell(context, 'Form'),
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
                                    : theme.colorScheme.surfaceVariant
                                        .withAlpha(3),
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
                                          (_, __, ___) =>
                                              const SizedBox(width: 20),
                                    ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      row.teamName,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            decoration:
                                                isStrikethrough
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                            decorationThickness: 3.0,
                                            decorationStyle:
                                                TextDecorationStyle.solid,
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
                              child: _buildLastGamesIndicator(
                                row.lastGames,
                                theme,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
          ],
        ),
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
