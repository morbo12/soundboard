// board_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common_widgets/widget_match.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_2_RowPlayerPresentation.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_0_player_progress_bar.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_3_ratata.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_4_lineup.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_5_timeout.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_1_stop_goal_row.dart';

class BoardSection extends ConsumerWidget {
  final double width;

  const BoardSection({super.key, required this.width});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMatch = ref.watch(selectedMatchProvider);

    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  width: ScreenSizeUtil.getWidth(
                    context,
                    maxWidth: ScreenSizeUtil.getSoundboardSize(context),
                  ),
                  child: MatchButton2(match: selectedMatch, readonly: true),
                ),
                const PlayerProgressBar(),
                const Gap(10),
                const StopGoalRow(),
                const Gap(10),
                const RowPlayerPresentation(),
                const Gap(10),
                const Row1Ratata(),
                const Gap(10),
                const Row2lineup(),
                const Gap(10),
                const Row3timeout(),
                const Gap(10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
