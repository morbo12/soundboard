// home_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/presentation/board/board.dart';
import 'package:soundboard/features/screen_home/presentation/events/events.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/lineup.dart';
import 'package:soundboard/features/screen_home/presentation/volume/volume.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
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
            return Row(
              children: [
                const BoardSection(width: 400),
                if (Platform.isWindows) ...[
                  const VolumeSection(
                    width: 100,
                  ),
                  EventsSection(
                    scrollController: scrollController,
                    width: 350,
                  ),
                  VerticalDivider(
                    thickness: 1.0,
                    width: 2.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  const LineupSection(), // 502 = 400 + 100 + 2
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
