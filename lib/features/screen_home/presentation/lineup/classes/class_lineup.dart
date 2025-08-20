import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/providers.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/providers.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';

import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiomanager.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup_data.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_new_notepad.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/providers/manual_lineup_providers.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/widgets/manual_lineup_entry_widget.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/widgets/manual_event_generator_widget.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';
// [Keep other imports...]

class Lineup extends ConsumerStatefulWidget {
  final double availableWidth;
  final double availableHeight;

  const Lineup({required this.availableWidth, required this.availableHeight});

  @override
  ConsumerState<Lineup> createState() => _LineupState();
}

class _LineupState extends ConsumerState<Lineup> {
  final Logger logger = const Logger('Lineup');

  @override
  Widget build(BuildContext context) {
    final selectedMatch = ref.watch(selectedMatchProvider);
    final isManualMode = ref.watch(isManualLineupModeProvider);
    final theme = Theme.of(context);

    return SizedBox(
      width: widget.availableWidth,
      height: widget.availableHeight,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: [
            // Mode Toggle Switch
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Manual Mode'),
                  Switch(
                    value: isManualMode,
                    onChanged: (value) {
                      ref.read(isManualLineupModeProvider.notifier).state =
                          value;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Only show header section in API mode (not manual mode)
            if (!isManualMode) ...[
              Expanded(
                flex: 1,
                child: SingleChildScrollView(
                  child: _buildHeader(theme, selectedMatch),
                ),
              ),
              _buildDivider(theme),
            ],
            Expanded(
              flex: 3,
              child: isManualMode
                  ? ManualLineupEntryWidget(
                      availableWidth: widget.availableWidth,
                      availableHeight: widget.availableHeight * 0.6,
                    )
                  : LineupData(
                      availableWidth: widget.availableWidth,
                      availableHeight: widget.availableHeight,
                    ),
            ),

            // Add Manual Event Generator at the bottom when in manual mode
            if (isManualMode) ...[
              _buildDivider(theme),
              Expanded(
                flex: 2,
                child: ManualEventGeneratorWidget(
                  availableWidth: widget.availableWidth,
                  availableHeight: widget.availableHeight * 0.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic selectedMatch) {
    final isManualMode = ref.watch(isManualLineupModeProvider);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(6.0),
      child: Column(
        children: [
          _buildPlayButton(theme, selectedMatch),
          // Only show the goal/penalty inputs in API mode (not manual mode)
          if (!isManualMode) ...[
            _buildDivider(theme),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: GoalInputWidget(team: "homeTeam")),
                Expanded(child: GoalInputWidget(team: "awayTeam")),
              ],
            ),
            _buildDivider(theme),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: PenaltyInputWidget(team: "homeTeam")),
                Expanded(child: PenaltyInputWidget(team: "awayTeam")),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayButton(ThemeData theme, dynamic selectedMatch) {
    return TextButton(
      onPressed: () => _handlePlayLineup(selectedMatch),
      onLongPress: () {
        final text = _getLineupText(selectedMatch);
        _showTextDialog(context, text);
      },
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

  String _getLineupText(dynamic selectedMatch) {
    final introText = _stripSsmlTags(selectedMatch.introSsml(ref));
    final homeTeamText = _stripSsmlTags(selectedMatch.homeTeamSsml(ref));
    final awayTeamText = _stripSsmlTags(selectedMatch.awayTeamSsml(ref));

    return "$introText\n\n$awayTeamText\n\n$homeTeamText";
  }

  String _stripSsmlTags(String text) {
    // Remove SSML/XML tags using regex
    return text.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  void _showTextDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lineup Announcement Text'),
        content: SingleChildScrollView(child: Text(text)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _handlePlayLineup(dynamic selectedMatch) async {
    try {
      // Debug: Check the lineup data before generating SSML
      final lineupData = ref.read(effectiveLineupProvider);
      logger.d("[_handlePlayLineup] Lineup matchId: ${lineupData.matchId}");
      logger.d(
        "[_handlePlayLineup] Home team players count: ${lineupData.homeTeamPlayers.length}",
      );
      logger.d(
        "[_handlePlayLineup] Away team players count: ${lineupData.awayTeamPlayers.length}",
      );

      // Get the jingle manager from provider
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      final jingleManager = await jingleManagerAsync.when(
        data: (manager) => manager,
        loading: () => throw Exception('JingleManager not loaded'),
        error: (error, stack) => throw Exception('JingleManager error: $error'),
      );

      final textToSpeechService = ref.read(textToSpeechServiceProvider);
      // final speech =
      //     await textToSpeechService.getTtsNoFile(text: selectedMatch.ssml);

      final welcomeTTS = await textToSpeechService.getTtsNoFile(
        text: selectedMatch.introSsml(ref),
      );
      final homeTeamTTS = await textToSpeechService.getTtsNoFile(
        text: selectedMatch.homeTeamSsml(ref),
      );
      final awayTeamTTS = await textToSpeechService.getTtsNoFile(
        text: selectedMatch.awayTeamSsml(ref),
      );

      ref.read(azCharCountProvider.notifier).state +=
          selectedMatch.generateSsml(ref).length as int;
      SettingsBox().azCharCount +=
          selectedMatch.generateSsml(ref).length as int;

      // Play background music

      logger.d("[_handlePlayLineup] Starting background music");

      // Find specific AwayJingle by name for background music
      final awayJingle = jingleManager.audioManager.audioInstances
          .where(
            (instance) =>
                instance.audioCategory == AudioCategory.specialJingle &&
                instance.displayName == 'AwayJingle',
          )
          .firstOrNull;

      if (awayJingle != null) {
        await jingleManager.audioManager.playAudio(
          AudioCategory.specialJingle,
          ref,
          shortFade: true,
          isBackgroundMusic: true,
        );
      }

      // wait for 10 seconds

      logger.d("[_handlePlayLineup] Waiting 7 seconds");

      await Future.delayed(const Duration(seconds: 7));

      // Play welcome message

      logger.d("[_handlePlayLineup] Playing welcome message");

      await jingleManager.audioManager.playBytesAndWait(
        audio: welcomeTTS.audio.buffer.asUint8List(),
        ref: ref,
      );

      // Play away team lineup with background music

      logger.d("[_handlePlayLineup] Playing Away team background music");

      await jingleManager.audioManager.playBytesAndWait(
        audio: awayTeamTTS.audio.buffer.asUint8List(),
        ref: ref,
      );

      // wait for 10 seconds

      logger.d("[_handlePlayLineup] Waiting 2 seconds");

      await Future.delayed(const Duration(seconds: 2));

      // Stop all audio
      // await jingleManager.audioManager.stopAll(ref);

      logger.d("[_handlePlayLineup] Fading out background music");

      await jingleManager.audioManager.fadeOutNoStop(
        ref,
        AudioChannel.channel1,
      );

      logger.d("[_handlePlayLineup] Stopping channel2");

      await jingleManager.audioManager.channel2.stop();

      // Play home team lineup with background music

      logger.d("[_handlePlayLineup] Playing Home team background music");

      // Find specific HomeJingle by name for background music
      final homeJingle = jingleManager.audioManager.audioInstances
          .where(
            (instance) =>
                instance.audioCategory == AudioCategory.specialJingle &&
                instance.displayName == 'HomeJingle',
          )
          .firstOrNull;

      if (homeJingle != null) {
        await jingleManager.audioManager.playAudio(
          AudioCategory.specialJingle,
          ref,
          shortFade: true,
          isBackgroundMusic: true,
        );
      }

      // wait for 10 seconds
      logger.d("[_handlePlayLineup] Waiting 10 seconds");

      await Future.delayed(const Duration(seconds: 10));

      // Play home team lineup with background music

      logger.d("[_handlePlayLineup] Playing Home team lineup");

      await jingleManager.audioManager.playBytesAndWait(
        audio: homeTeamTTS.audio.buffer.asUint8List(),
        ref: ref,
      );

      // wait for 10 seconds

      logger.d("[_handlePlayLineup] Waiting 5 seconds");

      await Future.delayed(const Duration(seconds: 5));

      // Stop all audio

      logger.d("[_handlePlayLineup] Stopping all audio");

      await jingleManager.audioManager.stopAll(ref);

      // await jingleManager.audioManager
      //     .playBytes(audio: speech.audio.buffer.asUint8List(), ref: ref);
    } catch (e) {
      logger.d("Error generating audio: $e");
      // You might want to show an error message to the user here
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
