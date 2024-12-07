import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiocategory.dart';

class Row1Ratata extends ConsumerWidget {
  const Row1Ratata({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Button to play 'RATATA' jingle
      Button(
        isSelected: true,
        onTap: () {
          // playJingle(audioSources.ratataFile);
          if (kDebugMode) {
            print(jingleManager.audioManager.audioInstances.first.filePath);
          }
          jingleManager.audioManager.playAudio(AudioCategory.ratataJingle, ref);
        },
        primaryText: 'RATATA',
        secondaryText: '(60s)',
      ),
      const Gap(10),
      // Button to play a random clap jingle
      Button(
        isSelected: true,
        noLines: 2,
        onTap: () {
          jingleManager.audioManager
              .playAudio(AudioCategory.clapJingle, ref, random: true);
        },
        primaryText: 'KLAPPA\nHÄNDERNA',
        secondaryText: 'N/A',
      ),
      const Gap(10),
      // Button to play a random generic jingle
      Button(
        isSelected: true,
        onTap: () {
          jingleManager.audioManager
              .playAudio(AudioCategory.genericJingle, ref, random: true);
        },
        primaryText: 'JINGLE',
        secondaryText: '(random)',
      ),
    ]);
  }
}
