import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/audioplayer_func.dart';

class StopGoalRow extends ConsumerWidget {
  const StopGoalRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Button(
          noLines: 1,
          onTap: () {
            if (kDebugMode) {
              print("Foo");
            } // playerStop();
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
            playGoal2(ref);
          },
          primaryText: 'MÅL',
          secondaryText: 'N/A',
        ),
      ],
    );
  }
}
