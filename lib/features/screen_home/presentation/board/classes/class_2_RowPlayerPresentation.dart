import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common/widgets/class_large_button.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

class RowPlayerPresentation extends ConsumerWidget {
  const RowPlayerPresentation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button to play 'RATATA' jingle
        LargeButton(
          isSelected: true,
          onTap: () {
            final jingleManagerAsync = ref.read(jingleManagerProvider);
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
        const Gap(10),
        // Button to play a random clap jingle
        LargeButton(
          isSelected: true,
          noLines: 2,
          onTap: () {
            final jingleManagerAsync = ref.read(jingleManagerProvider);
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
      ],
    );
  }
}
