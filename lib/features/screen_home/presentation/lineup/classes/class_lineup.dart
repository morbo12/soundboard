import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  int currentMessageIndex = 0;
  Timer? messageRotationTimer;

  @override
  void dispose() {
    messageRotationTimer?.cancel();
    super.dispose();
  }

  void startMessageRotation() {
    currentMessageIndex = 0;
    messageRotationTimer?.cancel();
    messageRotationTimer =
        Timer.periodic(const Duration(milliseconds: 2000), (timer) {
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
    final lineupSsml = ref.watch(lineupSsmlProvider);
    final selectedMatch = ref.read(selectedMatchProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final theme = Theme.of(context);

    return Stack(
      children: [
        SizedBox(
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
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
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

      // Show loading indicator and start message rotation
      ref.read(isLoadingProvider.notifier).state = true;
      startMessageRotation();

      try {
        final textToSpeechService = ref.read(textToSpeechServiceProvider);
        final speech =
            await textToSpeechService.getTtsNoFile(text: lineupSsml.toString());

        ref.read(azCharCountProvider.notifier).state += lineupSsml.length;
        SettingsBox().azCharCount += lineupSsml.length;

        await jingleManager.audioManager
            .playBytes(audio: speech.audio.buffer.asUint8List(), ref: ref);
      } catch (e) {
        if (kDebugMode) {
          print("Error generating audio: $e");
        }
        // You might want to show an error message to the user here
      } finally {
        // Stop message rotation and hide loading indicator
        stopMessageRotation();
        ref.read(isLoadingProvider.notifier).state = false;
      }
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
