import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';
// Assume TeamPlayer is imported from the appropriate file

class LineupData extends ConsumerWidget {
  final double availableWidth;

  const LineupData({super.key, required this.availableWidth});

  static const double _smallFontSize = 10.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMatch = ref.watch(selectedMatchProvider);
    final selectedMatchLineup = ref.watch(lineupProvider);

    if (selectedMatch.matchId == 0) {
      return const Center(child: Text("No Data"));
    }

    final teamWidth =
        (availableWidth - 20) / 2; // 20 for the divider and padding

    return SizedBox(
      width: availableWidth,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamColumn(context, ref, selectedMatch.homeTeam,
              selectedMatchLineup.homeTeamPlayers, teamWidth),
          SizedBox(
              width: 10,
              height: 650,
              child: VerticalDivider(
                color: Theme.of(context).colorScheme.onInverseSurface,
              )),
          _buildTeamColumn(context, ref, selectedMatch.awayTeam,
              selectedMatchLineup.awayTeamPlayers, teamWidth),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(BuildContext context, WidgetRef ref, String teamName,
      List<TeamPlayer>? players, double width) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            teamName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildPlayerList(context, ref, players),
        ],
      ),
    );
  }

  Widget _buildPlayerList(
      BuildContext context, WidgetRef ref, List<TeamPlayer>? players) {
    if (players == null || players.isEmpty) {
      return const Center(child: Text("No players"));
    }
    final buttonStates = ref.watch(buttonStatesProvider);
    final Map<String, String> positionMapping = {
      'Målvakt': 'MV',
      'Forward': 'F',
      'Vänsterforward': 'VF',
      'Högerforward': 'HF',
      'Center': 'C',
      'Back': 'B',
      'Vänsterback': 'VB',
      'Högerback': 'HB',
    };
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final playerId = '${player.shirtNo}-${player.name}';
        final buttonState = buttonStates[playerId] ?? ButtonState.normal;
        Color getButtonColor() {
          switch (buttonState) {
            case ButtonState.normal:
              return Theme.of(context).colorScheme.surface;
            case ButtonState.selected:
              return Theme.of(context).colorScheme.primaryContainer;
            case ButtonState.longPressed:
              return Theme.of(context)
                  .colorScheme
                  .secondaryContainer; // You can change this to any color you prefer for long press
          }
        }

        Color getTextColor() {
          switch (buttonState) {
            case ButtonState.normal:
              return Theme.of(context).colorScheme.onSurface;
            case ButtonState.selected:
              return Theme.of(context).colorScheme.onPrimaryContainer;
            case ButtonState.longPressed:
              return Theme.of(context)
                  .colorScheme
                  .onSecondaryContainer; // Adjust this based on your long press color
          }
        }

        String getButtonStateText() {
          switch (buttonState) {
            case ButtonState.normal:
              return '';
            case ButtonState.selected:
              return 'MÅL';
            case ButtonState.longPressed:
              return 'ASSIST';
          }
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    SizedBox(
                      width: 20,
                      child: AutoSizeText(
                        '${positionMapping[player.position]?.padRight(10)}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: _smallFontSize,
                          fontWeight: FontWeight.normal,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getButtonColor(),
                        foregroundColor: getTextColor(),
                        padding:
                            EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      ),
                      onPressed: () {
                        ref
                            .read(buttonStatesProvider.notifier)
                            .toggleState(playerId);
                      },
                      onLongPress: () {
                        ref
                            .read(buttonStatesProvider.notifier)
                            .setLongPressedState(playerId);
                      },
                      child: Row(
                        children: [
                          AutoSizeText(
                            '${player.shirtNo}. ${player.name} ',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                              fontSize: _smallFontSize,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                          ),
                          AutoSizeText(
                            getButtonStateText(),
                            style: TextStyle(
                              color: Colors.lime,
                              fontSize: _smallFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: Theme.of(context).colorScheme.onInverseSurface,
      ),
    );
  }
}
