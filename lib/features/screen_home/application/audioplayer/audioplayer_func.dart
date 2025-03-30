import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
import 'package:soundboard/utils/logger.dart';

void playGoal2(WidgetRef ref) async {
  const Logger logger = Logger('playGoal2');

  // Play horn
  jingleManager.audioManager.channel1.stop();
  jingleManager.audioManager.channel2.stop();
  jingleManager.audioManager.playHorn(ref); // wait for 1500ms and play a jingle
  await Future.delayed(const Duration(milliseconds: 1500), () async {
    logger.d("[playGoal2] Waited for 1500ms");
    jingleManager.audioManager.playAudio(
      AudioCategory.goalJingle,
      ref,
      random: true,
      shortFade: false,
    );
  });
}
