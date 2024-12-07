import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiocategory.dart';

void playGoal2(WidgetRef ref) async {
  // Play horn
  jingleManager.audioManager.channel1.stop();
  jingleManager.audioManager.channel2.stop();
  jingleManager.audioManager.playHorn(ref); // wait for 1500ms and play a jingle
  await Future.delayed(const Duration(milliseconds: 1500), () async {
    jingleManager.audioManager.playAudio(AudioCategory.goalJingle, ref,
        random: true, shortFade: false);
  });
}

// void playLineup(String lineupFile) async {
//   try {
//     // Play background
//     jingleManager.audioManager
//         .playBackgroundMusic(); // wait for 1500ms and play a jingle
//     await Future.delayed(
//       const Duration(milliseconds: 750),
//       () async {
//         jingleManager.audioManager.playOneNoRef(AudioCategory.lineupJingle);
//       },
//     );
//     // jingleManager.audioManager.stopAll();
//   } catch (e) {
//     if (kDebugMode) {
//       print('Error during audio playback: $e');
//     }
//     // Handle the error accordingly
//   }
// }
