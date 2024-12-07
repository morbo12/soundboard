// Dart and Flutter packages
import 'dart:io';
import 'package:flutter/material.dart'; // Core Flutter library for building UI.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart'; // Package for adding gap/spacing widgets.
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_RowPlayerPresentation.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_lineup.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_live_events.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_row1_ratata.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_row2_lineup.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_row3_timeout.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_column_volume.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_stop_goal_row.dart';

// Local files and features
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/common_widgets/widget_match.dart'; // Custom file for reusable match widget.
import 'package:soundboard/features/screen_home/presentation/classes/class_player_progress_bar.dart';

// HomeScreen widget class
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

// _HomeScreenState class (State class for HomeScreen widget)
class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Volume state variable

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    // ee: implement dispose
    // streamController.close();
    // scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // streamController.add(user);
    // userStream = streamController.stream;
    // print("SCROLLCONTROLLER: ${scrollController.position.pixels}");
  }

  // _scrollToBottom() {}

  @override
  Widget build(BuildContext context) {
    final selectedMatch = ref.watch(selectedMatchProvider);
    // final JingleManager jingleManager = JingleManager(context);
    // jingleManager.audioManager.setRef(ref);
    // final audioManager = AudioManager();
    // audioManager.setRef(ref);

    // Color normalColor = Theme.of(context).colorScheme.secondaryContainer;
    // Color normalColorText = Theme.of(context).colorScheme.onSecondaryContainer;
    // Scaffold widget as the root of the screen
    return SafeArea(
      child: Scaffold(
        // Body of the screen is centered
        body: LayoutBuilder(
          builder: (context, constraints) {
            // final totalWidth = constraints.maxWidth;
            // final isWindows = Platform.isWindows;

            return Row(
              children: [
                SizedBox(
                  width: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Column(children: [
                          SizedBox(
                            width: ScreenSizeUtil.getWidth(context,
                                maxWidth:
                                    ScreenSizeUtil.getSoundboardSize(context)),
                            child: MatchButton2(
                                match: selectedMatch, readonly: true),
                          ),
                          // const Gap(10),
                          const PlayerProgressBar(),
                          const Gap(10),
                          // Row containing action buttons
                          const StopGoalRow(),
                          const Gap(10),
                          RowPlayerPresentation(),
                          const Gap(10),
                          // Row containing buttons for playing jingles
                          const Row1Ratata(),
                          const Gap(10),
                          // Row containing buttons for specific actions
                          const Row2lineup(),
                          const Gap(10),
                          // Row containing buttons for specific actions
                          const Row3timeout(),
                          const Gap(10),
                        ]),
                      ),
                    ),
                  ),
                ),
                Platform.isWindows
                    ? SizedBox(
                        width: 100,
                        child: Row(
                          children: [
                            VerticalDivider(
                                thickness: 1.0,
                                width: 0.0,
                                color: Theme.of(context).colorScheme.onSurface),
                            ColumnVolume(),
                            VerticalDivider(
                                thickness: 1.0,
                                width: 0.0,
                                color: Theme.of(context).colorScheme.onSurface),
                          ],
                        ),
                      )
                    : Container(),
                Platform.isWindows
                    ? SizedBox(
                        width: 350,
                        child: LiveEvents(scrollController: scrollController))
                    : Container(),
                Platform.isWindows
                    ? VerticalDivider(
                        thickness: 1.0,
                        width: 2.0,
                        color: Theme.of(context).colorScheme.onSurface)
                    : Container(),
                Platform.isWindows
                    ? Expanded(child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Lineup(
                            availableWidth: constraints.maxWidth,
                          );
                        },
                      ))
                    : Container(),
              ],
            );
          },
        ),
      ),
    );
  }
}
