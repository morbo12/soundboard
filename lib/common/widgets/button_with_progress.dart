import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common/widgets/blinking_play_indicator.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/widgets/mini_progress_bar.dart';

/// A wrapper widget that adds a progress bar and play indicator to any button widget
class ButtonWithProgress extends ConsumerWidget {
  final Widget child;
  final AudioFile? audioFile;
  final double progressBarHeight;
  final double bottomPadding;
  final double sidePadding;
  final double indicatorSize;
  final bool showPlayIndicator;
  final Color? progressColor;
  final Color? backgroundColor;

  const ButtonWithProgress({
    super.key,
    required this.child,
    this.audioFile,
    this.progressBarHeight = 6.0,
    this.bottomPadding = 4.0,
    this.sidePadding = 8.0,
    this.indicatorSize = 8.0,
    this.showPlayIndicator = true,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) => LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight.isFinite
                  ? constraints.maxHeight
                  : null,
              child: child,
            ),
            // Blinking play indicator on the left side
            if (showPlayIndicator)
              Positioned(
                left: 6.0,
                top: 6.0,
                child: BlinkingPlayIndicator(
                  size: indicatorSize,
                  audioFile: audioFile,
                ),
              ),
            // Progress bar at the bottom
            Positioned(
              bottom: bottomPadding,
              left: showPlayIndicator ? indicatorSize + 8.0 : sidePadding,
              right: sidePadding,
              child: MiniProgressBar(
                audioFile: audioFile,
                height: progressBarHeight,
                progressColor: progressColor,
                backgroundColor: backgroundColor,
              ),
            ),
          ],
        ),
      ),
      loading: () => child,
      error: (error, stack) => child,
    );
  }
}

// Contains AI-generated edits.
