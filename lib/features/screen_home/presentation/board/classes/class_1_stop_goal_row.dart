import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_button.dart';
import 'package:soundboard/constants/globals.dart';
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
        Button(
          noLines: 1,
          onTap: () {
            logger.d("STOP was pressed");
            jingleManager.audioManager.stopAll(ref);
          },
          primaryText: 'STOP',
          secondaryText: 'N/A',
        ),
        const Gap(10),
        // Button to play goal audio
        Button(
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
