import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiomanager.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup_data.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_new_notepad.dart';
import 'package:soundboard/properties.dart';
import 'package:soundboard/utils/logger.dart';

// Add the loading state provider
final isLoadingProvider = StateProvider<bool>((ref) => false);

class Lineup extends ConsumerStatefulWidget {
  final double availableWidth;
  final double availableHeight;

  const Lineup({required this.availableWidth, required this.availableHeight});

  @override
  ConsumerState<Lineup> createState() => _LineupState();
}

class _LineupState extends ConsumerState<Lineup> {
  final List<String> loadingMessages = [
    "Warming up the virtual vocal cords...",
    "Teaching robots to sing...",
    "Composing your audio masterpiece...",
    "Converting text to sweet melodies...",
    "Preparing your lineup announcement...",
    "Tuning the digital microphone...",
    "Getting the virtual crowd excited...",
    "Clearing throat (beep boop)...",
    "Loading commentary powers...",
    "Summoning the sports announcer spirit...",
  ];
  final Logger logger = const Logger('Lineup');

  int currentMessageIndex = 0;
  Timer? messageRotationTimer;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    messageRotationTimer?.cancel();
    super.dispose();
  }

  void startMessageRotation() {
    currentMessageIndex = 0;
    messageRotationTimer?.cancel();
    messageRotationTimer = Timer.periodic(const Duration(milliseconds: 2000), (
      timer,
    ) {
      setState(() {
        currentMessageIndex =
            (currentMessageIndex + 1) % loadingMessages.length;
      });
    });
  }

  void stopMessageRotation() {
    messageRotationTimer?.cancel();
    messageRotationTimer = null;
  }

  @override
  Widget build(BuildContext context) {
    final selectedMatch = ref.watch(selectedMatchProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: widget.availableHeight,
              maxWidth: widget.availableWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(theme, selectedMatch),
                  _buildDivider(theme),
                  LineupData(
                    availableWidth: widget.availableWidth,
                    availableHeight: widget.availableHeight,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isLoading)
          Container(
            width: widget.availableWidth,
            height: widget.availableHeight,
            color: Colors.black54,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.5),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      loadingMessages[currentMessageIndex],
                      key: ValueKey<int>(currentMessageIndex),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, dynamic selectedMatch) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
      ),
      padding: const EdgeInsets.all(6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPlayButton(theme, selectedMatch),
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
      ),
    );
  }

  Widget _buildPlayButton(ThemeData theme, dynamic selectedMatch) {
    return TextButton(
      onPressed: () => _handlePlayLineup(selectedMatch),
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

  Future<void> _handlePlayLineup(dynamic selectedMatch) async {
    // Show loading indicator and start message rotation
    ref.read(isLoadingProvider.notifier).state = true;
    startMessageRotation();

    try {
      final textToSpeechService = ref.read(textToSpeechServiceProvider);
      // final speech =
      //     await textToSpeechService.getTtsNoFile(text: selectedMatch.ssml);

      final welcomeTTS = await textToSpeechService.getTtsNoFile(
        text: selectedMatch.introSsml,
      );
      final homeTeamTTS = await textToSpeechService.getTtsNoFile(
        text: selectedMatch.homeTeamSsml,
      );
      final awayTeamTTS = await textToSpeechService.getTtsNoFile(
        text: selectedMatch.awayTeamSsml,
      );

      stopMessageRotation();
      ref.read(isLoadingProvider.notifier).state = false;

      ref.read(azCharCountProvider.notifier).state +=
          selectedMatch.ssml.length as int;
      SettingsBox().azCharCount += selectedMatch.ssml.length as int;

      // Play background music

      logger.d("[_handlePlayLineup] Starting background music");

      await jingleManager.audioManager.playAudio(
        AudioCategory.awayTeamJingle,
        ref,
        shortFade: true,
        isBackgroundMusic: true,
      );

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

      await jingleManager.audioManager.playAudio(
        AudioCategory.homeTeamJingle,
        ref,
        shortFade: true,
        isBackgroundMusic: true,
      );

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
    } finally {
      // Stop message rotation and hide loading indicator
      stopMessageRotation();
      ref.read(isLoadingProvider.notifier).state = false;
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
