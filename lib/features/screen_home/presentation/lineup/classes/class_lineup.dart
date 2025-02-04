import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup_data.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_new_notepad.dart';
import 'package:soundboard/properties.dart';
// [Keep other imports...]

// Create an enum for event types
enum MatchEventType { goal, penalty }

class Lineup extends ConsumerStatefulWidget {
  final double availableWidth;
  final double availableHeight;

  const Lineup({required this.availableWidth, required this.availableHeight});

  @override
  ConsumerState<Lineup> createState() => _LineupState();
}

class _LineupState extends ConsumerState<Lineup> {
  // Controllers

  @override
  Widget build(BuildContext context) {
    final lineupSsml = ref.watch(lineupSsmlProvider);
    final selectedMatch = ref.read(selectedMatchProvider);
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.availableWidth,
      height: widget.availableHeight,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            _buildHeader(theme, lineupSsml, selectedMatch),
            _buildDivider(theme),
            LineupData(
                availableWidth: widget.availableWidth,
                availableHeight: widget.availableHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      ThemeData theme, String lineupSsml, dynamic selectedMatch) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          _buildPlayButton(theme, lineupSsml, selectedMatch),
          _buildDivider(theme),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: GoalInputWidget(team: "homeTeam")),
              Expanded(child: GoalInputWidget(team: "awayTeam")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayButton(
      ThemeData theme, String lineupSsml, dynamic selectedMatch) {
    return TextButton(
      onPressed: () => _handlePlayLineup(lineupSsml, selectedMatch),
      child: Text(
        "Lineup (Click to Play)",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
  }

  Future<void> _handlePlayLineup(
      String lineupSsml, dynamic selectedMatch) async {
    if (lineupSsml.isNotEmpty) {
      if (kDebugMode) {
        print("Lineup String Exists");
      }
      final textToSpeechService = ref.read(textToSpeechServiceProvider);
      final speech =
          await textToSpeechService.getTtsNoFile(text: lineupSsml.toString());

      ref.read(azCharCountProvider.notifier).state += lineupSsml.length;
      SettingsBox().azCharCount += lineupSsml.length;

      await jingleManager.audioManager
          .playBytes(audio: speech.audio.buffer.asUint8List(), ref: ref);
    } else {
      if (kDebugMode) {
        print("Generating Lineup String");
      }
      ref.read(lineupSsmlProvider.notifier).state =
          selectedMatch.generateSsml();
    }
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.surfaceTint),
      ),
    );
  }
}
