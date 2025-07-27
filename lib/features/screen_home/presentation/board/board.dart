// board_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_0_player_progress_bar.dart';

import 'package:soundboard/features/screen_home/presentation/board/classes/class_1_stop_goal_row.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_2_RowPlayerPresentation.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_section.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_horizontal_volume_control.dart';
import 'package:soundboard/features/music_player/presentation/mini_music_player.dart';

class BoardSection extends ConsumerWidget {
  final double width;

  const BoardSection({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const MiniMusicPlayer(),
                const Gap(10),
                const HorizontalVolumeControl(),
                const Gap(10),
                const PlayerProgressBar(),
                const Gap(10),
                const StopGoalRow(),
                const Gap(10),
                RowPlayerPresentation(),
                const Gap(10),
                const JingleGridSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
