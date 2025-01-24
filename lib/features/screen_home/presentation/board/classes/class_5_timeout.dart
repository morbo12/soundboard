import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';

class Row3timeout extends ConsumerWidget {
  const Row3timeout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button to play the '1 min' audio
        Button(
          isSelected: true,
          onTap: () async {
            jingleManager.audioManager
                .playAudio(AudioCategory.oneminJingle, ref);
          },
          primaryText: '1 min',
          secondaryText: 'kvar på period',
        ),
        const Gap(10),
        Button(
          isSelected: true,
          onTap: () async {
            jingleManager.audioManager
                .playAudio(AudioCategory.timeoutJingle, ref);
          },
          primaryText: 'Timeout',
          secondaryText: '(45s)',
        ),

        const Gap(10),
        // Button to play the '3 min' audio
        Button(
          isSelected: true,
          onTap: () {
            jingleManager.audioManager
                .playAudio(AudioCategory.threeminJingle, ref);
          },
          primaryText: '3 min',
          secondaryText: 'kvar på match',
        ),
      ],
    );
  }
}
