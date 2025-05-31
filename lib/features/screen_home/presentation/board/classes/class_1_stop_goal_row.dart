import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common/widgets/class_large_button.dart';
import 'package:soundboard/features/jingle_manager/application/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/audioplayer_func.dart';
import 'package:soundboard/utils/logger.dart';

class StopGoalRow extends ConsumerWidget {
  const StopGoalRow({super.key});

  final Logger logger = const Logger('StopGoalRow');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        LargeButton(
          noLines: 1,
          onTap: () {
            logger.d("STOP was pressed");
            final jingleManagerAsync = ref.read(jingleManagerProvider);
            jingleManagerAsync.whenData((jingleManager) {
              jingleManager.audioManager.stopAll(ref);
            });
          },
          primaryText: 'STOP',
          secondaryText: 'N/A',
        ),
        const Gap(10),
        // Button to play goal audio
        LargeButton(
          noLines: 1,
          onTap: () {
            logger.d("GOAL was pressed");
            playGoal2(ref);
          },
          primaryText: 'MÅL',
          secondaryText: 'N/A',
        ),
      ],
    );
  }
}
