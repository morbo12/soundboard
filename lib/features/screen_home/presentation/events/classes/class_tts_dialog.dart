import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_custom_tts.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_color_state_notifier.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/common/models/enum_goaltypes.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';
import 'package:soundboard/core/services/ai_sentence_service.dart';
import 'package:soundboard/core/services/auth_service.dart';

// mock
class TtsDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final TextEditingController textController = TextEditingController();
    final CustomTtsEvent ssmlEvent = CustomTtsEvent(ref: ref);
    final Logger logger = const Logger('TtsDialog');

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

    final selectedTypes = buttonStates.values.toSet();
    final isGoalOrAssist =
        selectedTypes.contains(GoalTypeState.goal) ||
        selectedTypes.contains(GoalTypeState.assist);
    final numSelected = [
      goalPlayer,
      assistPlayer,
      penaltyPlayer,
    ].where((e) => e != null && e.isNotEmpty).length;

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

    String? singleSelectedPlayer;
    if (numSelected == 1) {
      singleSelectedPlayer = goalPlayer ?? assistPlayer ?? penaltyPlayer;
    }

    List<String> penaltyTemplates = [];
    if (singleSelectedPlayer?.isNotEmpty == true) {
      final commonPenalties = PenaltyTypes.penaltyTypes.take(6);
      for (final penalty in commonPenalties) {
        penaltyTemplates.add(
          '{penaltyPlayer} utvisad för ${penalty.name.toLowerCase()} (${penalty.penaltyTime}).',
        );
      }
      penaltyTemplates.add('Utvisning på {penaltyPlayer}!');
    }

    String fillTemplate(String template) {
      return template
          .replaceAll('{goalPlayer}', goalPlayer ?? '[Spelare]')
          .replaceAll('{assistPlayer}', assistPlayer ?? '[Spelare]')
          .replaceAll(
            '{penaltyPlayer}',
            singleSelectedPlayer ?? penaltyPlayer ?? '[Spelare]',
          );
    }

    // AI integration via Soundboard backend API (uses same auth as TTS)
    final authService = ref.read(authServiceProvider);
    final aiService = AiSentenceService(authService);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Move state variables outside the builder closure to persist state across rebuilds
        List<String> aiSuggestions = [];
        bool aiLoading = false;
        String? aiError;
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> fetchAISuggestions() async {
              setState(() {
                aiLoading = true;
                aiError = null;
              });
              try {
                final prompt = _buildAIPrompt(
                  goalPlayer,
                  assistPlayer,
                  penaltyPlayer,
                );
                final suggestions = await aiService.generateSentences(
                  prompt: prompt,
                );
                // Defensive: filter out nulls and non-strings
                setState(() {
                  aiSuggestions = suggestions
                      .whereType<String>()
                      .where((s) => s.trim().isNotEmpty)
                      .toList();
                  aiLoading = false;
                });
              } catch (e) {
                setState(() {
                  aiError = e.toString();
                  aiLoading = false;
                });
              }
            }

            List<Widget> buildChips() {
              final List<Widget> chips = [];
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

            return AlertDialog(
              title: const Text('Custom TTS Announcement'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(spacing: 8, runSpacing: 4, children: buildChips()),
                  const SizedBox(height: 12),
                  if (aiSuggestions.isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: aiSuggestions
                          .map(
                            (s) => ActionChip(
                              label: Text(s),
                              tooltip: 'AI',
                              onPressed: () {
                                textController.text = s;
                              },
                            ),
                          )
                          .toList(),
                    ),
                  if (aiLoading)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (aiError != null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'AI error: $aiError',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      icon: const Icon(Icons.auto_awesome),
                      label: const Text('AI-förslag'),
                      onPressed: aiLoading ? null : fetchAISuggestions,
                    ),
                  ),
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
                      try {
                        // Build complete SSML structure like GoalEvent does
                        final content = ssmlEvent.wrapWithProsody(
                          textController.text,
                        );
                        final voiceWrapped = ssmlEvent.wrapWithVoice(content);
                        final announcement = ssmlEvent.wrapWithSpeakTags(
                          voiceWrapped,
                        );

                        logger.d("SSML Announcement: $announcement");

                        // Show plain text to user, but send SSML to TTS
                        await ssmlEvent.showToast(context, textController.text);
                        await ssmlEvent.playAnnouncement(announcement);

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      } catch (e, stackTrace) {
                        logger.e(
                          'Failed to play custom TTS announcement',
                          e,
                          stackTrace,
                        );
                        if (context.mounted) {
                          await ssmlEvent.showToast(
                            context,
                            'Failed to play announcement: ${e.toString()}',
                            isError: true,
                          );
                        }
                      }
                    }
                  },
                  child: const Text('Announce'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Helper to build a prompt for the AI model
  static String _buildAIPrompt(
    String? goalPlayer,
    String? assistPlayer,
    String? penaltyPlayer,
  ) {
    if (goalPlayer != null && assistPlayer != null) {
      return 'Skriv en svensk sportkommentator-mening för ett mål av $goalPlayer, assisterad av $assistPlayer.';
    } else if (goalPlayer != null) {
      return 'Skriv en svensk sportkommentator-mening för ett mål av $goalPlayer.';
    } else if (penaltyPlayer != null) {
      return 'Skriv en svensk sportkommentator-mening för en utvisning på $penaltyPlayer.';
    } else {
      return 'Skriv en svensk sportkommentator-mening för en innebandymatch.';
    }
  }
}

// Contains AI-generated edits.
