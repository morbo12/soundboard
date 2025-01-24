import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
import 'package:soundboard/properties.dart';

class Row2lineup extends ConsumerWidget {
  const Row2lineup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // lineupFile = ref.watch(lineupFileProvider);
    final lineupSsml = ref.watch(lineupSsmlProvider);
    final selectedMatch = ref.read(selectedMatchProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Button to play the lineup audio
        // Button(
        //   onTap: () async {
        //     if (lineupSsml.isNotEmpty) {
        //       if (kDebugMode) {
        //         print("Lineup String Exists");
        //       }
        //       final textToSpeechService = ref.read(textToSpeechServiceProvider);
        //       final speech = await textToSpeechService.getTtsNoFile(
        //           text: lineupSsml.toString());
        //       ref.read(azCharCountProvider.notifier).state += lineupSsml.length;

        //       SettingsBox().azCharCount += lineupSsml
        //           .length; // TODO: Should check if getTts was successful
        //       await jingleManager.audioManager.playBytes(
        //           audio: speech.audio.buffer.asUint8List(), ref: ref);
        //     } else {
        //       if (kDebugMode) {
        //         print("Generating Linup String");
        //       }
        //       ref.read(lineupSsmlProvider.notifier).state =
        //           selectedMatch.generateSsml();
        //     }
        //     // print("Lineup SSML: $lineupSsml");
        //     // playLineup(lineupFile);
        //   },
        //   primaryText: lineupSsml.isNotEmpty ? 'Play Lineup' : 'Generate\nSSML',
        //   secondaryText: lineupSsml.isNotEmpty ? '(2min)' : 'N/A',
        //   noLines: lineupSsml.isNotEmpty ? 2 : 1,
        //   isDisabled: false,
        //   isSelected: true,
        // ),

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
        // Button to play the 'Värdegrund' audio
        Button(
          noLines: 1,
          isSelected: true,
          // isDisabled: false,
          onTap: () {
            jingleManager.audioManager
                .playAudio(AudioCategory.powerupJingle, ref);
          },
          primaryText: 'Fulltalig',
          secondaryText: 'N/A',
        ),
        const Gap(10),
        Button(
          noLines: 1,
          isSelected: true,
          // isDisabled: false,
          onTap: () {
            jingleManager.audioManager
                .playAudio(AudioCategory.penaltyJingle, ref);
          },
          primaryText: 'Utvisning',
          secondaryText: 'N/A',
        ),
      ],
    );
  }
}
