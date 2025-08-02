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
    audioCategory: AudioCategory.specialJingle,
    isCategoryOnly: false, // Changed to false since we want specific jingle
  );

  static final _homeTeamAudioFile = AudioFile(
    filePath: '',
    displayName: 'Home Team Background',
    audioCategory: AudioCategory.specialJingle,
    isCategoryOnly: false, // Changed to false since we want specific jingle
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
                  // Find specific AwayJingle by name
                  final awayJingle = jingleManager.audioManager.audioInstances
                      .where(
                        (instance) =>
                            instance.audioCategory ==
                                AudioCategory.specialJingle &&
                            instance.displayName == 'AwayJingle',
                      )
                      .firstOrNull;

                  if (awayJingle != null) {
                    jingleManager.audioManager.playAudioFile(
                      awayJingle,
                      ref,
                      shortFade: true,
                    );
                  }
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
                  // Find specific HomeJingle by name
                  final homeJingle = jingleManager.audioManager.audioInstances
                      .where(
                        (instance) =>
                            instance.audioCategory ==
                                AudioCategory.specialJingle &&
                            instance.displayName == 'HomeJingle',
                      )
                      .firstOrNull;

                  if (homeJingle != null) {
                    jingleManager.audioManager.playAudioFile(
                      homeJingle,
                      ref,
                      shortFade: true,
                    );
                  }
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
