import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_custom_tts.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/common/models/enum_goaltypes.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';

// mock
class TtsDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final TextEditingController textController = TextEditingController();
    final CustomTtsEvent ssmlEvent = CustomTtsEvent(ref: ref);

    // Get selected player IDs for goal, assist, penalty
    final buttonStates = ref.read(GoalTypeStatesProvider);
    final lineup = ref.read(lineupProvider);
    String? goalPlayer;
    String? assistPlayer;
    String? penaltyPlayer;

    // Helper to get player name from playerId
    String? getPlayerName(String? playerId) {
      if (playerId == null || playerId.isEmpty) return null;
      final allPlayers = [...lineup.homeTeamPlayers, ...lineup.awayTeamPlayers];
      final found = allPlayers.firstWhere(
        (p) => '${p.shirtNo}-${p.name}' == playerId,
        orElse: () => TeamPlayer(name: '', shirtNo: 0),
      );
      return found.name;
    }

    buttonStates.forEach((playerId, state) {
      if (state == GoalTypeState.goal) goalPlayer = getPlayerName(playerId);
      if (state == GoalTypeState.assist) assistPlayer = getPlayerName(playerId);
      if (state == GoalTypeState.penalty)
        penaltyPlayer = getPlayerName(playerId);
    });

    // Count selected types
    final selectedTypes = buttonStates.values.toSet();
    final isGoalOrAssist =
        selectedTypes.contains(GoalTypeState.goal) ||
        selectedTypes.contains(GoalTypeState.assist);
    final isPenalty = selectedTypes.contains(GoalTypeState.penalty);
    final numSelected = [
      goalPlayer,
      assistPlayer,
      penaltyPlayer,
    ].where((e) => e != null && e.isNotEmpty).length;

    // Expanded word map with multiple templates and placeholders
    final Map<String, List<String>> wordMap = {
      'Goal': [
        'Mål av {goalPlayer}!',
        'Mål av {goalPlayer}, assisterad av {assistPlayer}!',
        '{goalPlayer} gör mål för hemmalaget!',
        '{goalPlayer} nätar!',
      ],
      'Assist': [
        'Assist av {assistPlayer}!',
        '{assistPlayer} med en fin framspelning!',
        '{assistPlayer} assisterar till målet!',
      ],
    };

    // Determine the single selected player (for penalty templates if only one is selected)
    String? singleSelectedPlayer;
    if (numSelected == 1) {
      singleSelectedPlayer = goalPlayer ?? assistPlayer ?? penaltyPlayer;
    }

    // Penalty suggestions using PenaltyTypes
    List<String> penaltyTemplates = [];
    if (singleSelectedPlayer?.isNotEmpty == true) {
      // Show top 6 most common penalties as suggestions
      final commonPenalties = PenaltyTypes.penaltyTypes.take(6);
      for (final penalty in commonPenalties) {
        penaltyTemplates.add(
          '{penaltyPlayer} utvisad för ${penalty.name.toLowerCase()} (${penalty.penaltyTime}).',
        );
      }
      // Add a generic template
      penaltyTemplates.add('Utvisning på {penaltyPlayer}!');
    }

    // Helper to fill placeholders with selected names
    String fillTemplate(String template) {
      return template
          .replaceAll('{goalPlayer}', goalPlayer ?? '[Spelare]')
          .replaceAll('{assistPlayer}', assistPlayer ?? '[Spelare]')
          .replaceAll(
            '{penaltyPlayer}',
            singleSelectedPlayer ?? penaltyPlayer ?? '[Spelare]',
          );
    }

    // Build the list of chips to show based on context
    List<Widget> buildChips() {
      final List<Widget> chips = [];
      // If two players are selected, only show goal/assist
      if (isGoalOrAssist && numSelected == 2) {
        for (final entry in wordMap.entries) {
          for (final template in entry.value) {
            if (entry.key == 'Goal' && goalPlayer == null) continue;
            if (entry.key == 'Assist' && assistPlayer == null) continue;
            chips.add(
              ActionChip(
                label: Text(fillTemplate(template)),
                tooltip: entry.key,
                onPressed: () {
                  textController.text = fillTemplate(template);
                },
              ),
            );
          }
        }
        return chips;
      }
      // If one player is selected, show both goal/assist and penalty
      if (numSelected == 1) {
        for (final entry in wordMap.entries) {
          for (final template in entry.value) {
            if (entry.key == 'Goal' && goalPlayer == null) continue;
            if (entry.key == 'Assist' && assistPlayer == null) continue;
            chips.add(
              ActionChip(
                label: Text(fillTemplate(template)),
                tooltip: entry.key,
                onPressed: () {
                  textController.text = fillTemplate(template);
                },
              ),
            );
          }
        }
        for (final template in penaltyTemplates) {
          chips.add(
            ActionChip(
              label: Text(fillTemplate(template)),
              tooltip: 'Penalty',
              onPressed: () {
                textController.text = fillTemplate(template);
              },
            ),
          );
        }
        return chips;
      }
      // If nothing is selected, show all as fallback
      for (final entry in wordMap.entries) {
        for (final template in entry.value) {
          chips.add(
            ActionChip(
              label: Text(fillTemplate(template)),
              tooltip: entry.key,
              onPressed: () {
                textController.text = fillTemplate(template);
              },
            ),
          );
        }
      }
      for (final template in penaltyTemplates) {
        chips.add(
          ActionChip(
            label: Text(fillTemplate(template)),
            tooltip: 'Penalty',
            onPressed: () {
              textController.text = fillTemplate(template);
            },
          ),
        );
      }
      return chips;
    }

    // TODO: Integrate AI-based sentence generation for dynamic and context-aware suggestions.
    // This method will be used to generate suggestions using an AI model in the future.
    Future<List<String>> generateAISuggestions({
      String? goalPlayer,
      String? assistPlayer,
      String? penaltyPlayer,
      String? eventType, // e.g., 'goal', 'assist', 'penalty'
    }) async {
      // Placeholder for AI integration
      // Example: Call an AI service or local model to generate suggestions
      return [];
    }

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Custom TTS Announcement'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(spacing: 8, runSpacing: 4, children: buildChips()),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                decoration: const InputDecoration(
                  hintText: 'Enter text to announce',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  final announcement = ssmlEvent.wrapWithProsody(
                    textController.text,
                  );
                  await ssmlEvent.showToast(context, announcement);
                  await ssmlEvent.playAnnouncement(announcement);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Announce'),
            ),
          ],
        );
      },
    );
  }
}
