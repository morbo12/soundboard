// home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/presentation/board/board.dart';
import 'package:soundboard/features/screen_home/presentation/events/events.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/lineup.dart';

/// Main screen that displays the soundboard interface.
///
/// The layout is responsive and adapts to different screen sizes:
/// - On Android: Uses a single column layout with full width
/// - On Windows: Uses a multi-column layout with dynamic widths
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (context, constraints) {
            // On Android, use a single column layout with full width BoardSection
            if (Platform.isAndroid) {
              return BoardSection(width: constraints.maxWidth);
            }

            // Calculate widths for Windows layout
            final totalWidth = constraints.maxWidth;

            // Define fixed maximum widths for each section
            const maxBoardWidth = 400.0;
            const maxVolumeWidth = 120.0;
            const maxEventsWidth = 400.0;

            // Define minimum widths for each section
            const minBoardWidth = 280.0;
            const minVolumeWidth = 80.0;
            const minEventsWidth = 240.0;
            const minLineupWidth = 280.0;

            // Calculate widths for the first three sections
            final boardWidth =
                totalWidth *
                0.3.clamp(
                  minBoardWidth / totalWidth,
                  maxBoardWidth / totalWidth,
                );
            final volumeWidth =
                totalWidth *
                0.1.clamp(
                  minVolumeWidth / totalWidth,
                  maxVolumeWidth / totalWidth,
                );
            final eventsWidth =
                totalWidth *
                0.25.clamp(
                  minEventsWidth / totalWidth,
                  maxEventsWidth / totalWidth,
                );

            // Calculate remaining width for lineup section
            final usedWidth = boardWidth + volumeWidth + eventsWidth;
            final lineupWidth = (totalWidth - usedWidth).clamp(
              minLineupWidth,
              double.infinity,
            );

            return Row(
              children: [
                BoardSection(width: boardWidth),
                // VolumeSection(width: volumeWidth),
                EventsSection(
                  scrollController: scrollController,
                  width: eventsWidth,
                ),
                LineupSection(width: lineupWidth),
              ],
            );
          },
        ),
      ),
    );
  }
}
