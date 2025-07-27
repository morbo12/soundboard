import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common/widgets/class_goal_button.dart';
import 'package:soundboard/common/widgets/class_stop_button.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

class StopGoalRow extends ConsumerWidget {
  const StopGoalRow({super.key});

  final Logger logger = const Logger('StopGoalRow');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        // Get the goal horn AudioFile for progress tracking
        final goalHorn = jingleManager.audioManager.audioInstances
            .where((audio) => audio.audioCategory == AudioCategory.hornJingle)
            .firstOrNull;

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StopButton(),
            // LargeButton(
            //   noLines: 1,
            //   onTap: () {
            //     logger.d("STOP was pressed");
            //     jingleManager.audioManager.stopAll(ref);
            //   },
            //   primaryText: 'STOP',
            //   secondaryText: 'N/A',
            // ),
            const Gap(10),
            GoalButton(),
            // Button to play goal audio
            // LargeButton(
            //   noLines: 1,
            //   audioFile: goalHorn, // Pass the goal horn for progress tracking
            //   onTap: () {
            //     logger.d("GOAL was pressed");
            //     playGoal2(ref);
            //   },
            //   primaryText: 'MÅL',
            //   secondaryText: 'N/A',
            // ),
          ],
        );
      },
      loading: () => const Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Expanded(child: Center(child: CircularProgressIndicator()))],
      ),
      error: (error, stack) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [Expanded(child: Center(child: Text('Error: $error')))],
      ),
    );
  }
}
