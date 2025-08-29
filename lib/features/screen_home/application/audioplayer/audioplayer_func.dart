import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiomanager.dart';

void playGoal2(WidgetRef ref) async {
  const Logger logger = Logger('playGoal2');

  // Get the jingle manager from provider
  final jingleManagerAsync = ref.read(jingleManagerProvider);
  await jingleManagerAsync.when(
    data: (jingleManager) async {
      // Stop both channels first
      jingleManager.audioManager.channel1.stop();
      jingleManager.audioManager.channel2.stop();

      // Play horn (uses channel2 per static channel assignment)
      jingleManager.audioManager.playHorn(ref);

      // Wait for 1500ms then cross-fade to jingle
      await Future.delayed(const Duration(milliseconds: 1500), () async {
        logger.d("[playGoal2] Starting cross-fade to jingle");

        // Begin fade-out of horn on channel2 while starting jingle on channel1
        // This creates a smooth cross-fade between channels
        jingleManager.audioManager.fadeOutNoStop(ref, AudioChannel.channel2);

        // Play jingle on channel1 with goal jingles using short fade for smoother transition
        jingleManager.audioManager.playAudio(
          AudioCategory.goalJingle,
          ref,
          random: true,
          shortFade: true, // Use short fade for smoother cross-fade
        );
      });
    },
    loading: () async {
      logger.w("JingleManager not loaded yet");
    },
    error: (error, stack) async {
      logger.e("Error accessing JingleManager: $error");
    },
  );
}
