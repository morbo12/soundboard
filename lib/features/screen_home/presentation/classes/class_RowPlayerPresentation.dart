import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiocategory.dart';

class RowPlayerPresentation extends ConsumerWidget {
  const RowPlayerPresentation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      // Button to play 'RATATA' jingle
      Button(
        isSelected: true,
        onTap: () {
          jingleManager.audioManager.playAudio(
              AudioCategory.awayTeamJingle, ref,
              shortFade: true, isBackgroundMusic: true);
        },
        primaryText: 'Bakgrund\nBortalag',
        secondaryText: 'N/A',
      ),
      const Gap(10),
      // Button to play a random clap jingle
      Button(
        isSelected: true,
        noLines: 2,
        onTap: () {
          jingleManager.audioManager.playAudio(
              AudioCategory.homeTeamJingle, ref,
              shortFade: true, isBackgroundMusic: true);
        },
        primaryText: 'Bakgrund\nHemmalag',
        secondaryText: 'N/A',
      ),
    ]);
  }
}
