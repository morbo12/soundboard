import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common/widgets/button_with_progress.dart';
import 'package:soundboard/common/widgets/class_large_button.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/providers/audio_progress_provider.dart';

class RowPlayerPresentation extends ConsumerWidget {
  RowPlayerPresentation({super.key});

  // Define the category-only audio files as constants
  static final _awayTeamAudioFile = AudioFile(
    filePath: '',
    displayName: 'Away Team Background',
    audioCategory: AudioCategory.awayTeamJingle,
    isCategoryOnly: true,
  );

  static final _homeTeamAudioFile = AudioFile(
    filePath: '',
    displayName: 'Home Team Background',
    audioCategory: AudioCategory.homeTeamJingle,
    isCategoryOnly: true,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: ButtonWithProgress(
            audioFile: _awayTeamAudioFile,
            child: LargeButton(
              onTap: () {
                // Update the lastPressedButtonProvider for category-only tracking
                ref.read(lastPressedButtonProvider.notifier).state =
                    _awayTeamAudioFile;

                jingleManagerAsync.whenData((jingleManager) {
                  jingleManager.audioManager.playAudio(
                    AudioCategory.awayTeamJingle,
                    ref,
                    shortFade: true,
                    isBackgroundMusic: true,
                  );
                });
              },
              primaryText: 'Bakgrund\nBortalag',
              secondaryText: 'N/A',
            ),
          ),
        ),
        const Gap(10),
        // Button to play a random clap jingle
        Expanded(
          child: ButtonWithProgress(
            audioFile: _homeTeamAudioFile,
            child: LargeButton(
              onTap: () {
                // Update the lastPressedButtonProvider for category-only tracking
                ref.read(lastPressedButtonProvider.notifier).state =
                    _homeTeamAudioFile;

                jingleManagerAsync.whenData((jingleManager) {
                  jingleManager.audioManager.playAudio(
                    AudioCategory.homeTeamJingle,
                    ref,
                    shortFade: true,
                    isBackgroundMusic: true,
                  );
                });
              },
              primaryText: 'Bakgrund\nHemmalag',
              secondaryText: 'N/A',
            ),
          ),
        ),
      ],
    );
  }
}

// Contains AI-generated edits.
