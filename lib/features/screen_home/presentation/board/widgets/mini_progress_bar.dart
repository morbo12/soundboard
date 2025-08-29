import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/audioplayers_providers.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/providers/audio_progress_provider.dart';
import 'package:soundboard/core/utils/logger.dart';

/// A mini progress bar widget that can be embedded in buttons
/// Shows progress for both specific jingles and category-only (random) buttons
class MiniProgressBar extends ConsumerWidget {
  final AudioFile? audioFile;
  final double height;
  final Logger logger = const Logger('MiniProgressBar');
  final Color? progressColor;
  final Color? backgroundColor;

  const MiniProgressBar({
    super.key,
    required this.audioFile,
    this.height = 4.0,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show progress if this jingle is currently playing
    final isPlaying = ref.watch(isJinglePlayingProvider(audioFile));
    ref.watch(currentPlayingJingleProvider);
    final currentChannel = ref.watch(currentJingleChannelProvider);

    // Debug logging with logger instead of print
    // if (audioFile != null) {
    //   logger.d('MiniProgressBar Debug:');
    //   logger.d(
    //     '  AudioFile: ${audioFile!.displayName} (${audioFile!.filePath})',
    //   );
    //   logger.d('  IsCategoryOnly: ${audioFile!.isCategoryOnly}');
    //   logger.d('  AudioCategory: ${audioFile!.audioCategory}');
    //   logger.d('  IsPlaying: $isPlaying');
    //   logger.d(
    //     '  CurrentJingle: ${currentJingle?.displayName} (${currentJingle?.filePath})',
    //   );
    //   logger.d('  CurrentJingleCategory: ${currentJingle?.audioCategory}');
    //   logger.d('  CurrentChannel: $currentChannel');
    // }

    if (!isPlaying || audioFile == null || currentChannel == null) {
      return const SizedBox.shrink();
    }

    Duration currentPosition = Duration.zero;
    Duration totalDuration = Duration.zero;

    if (currentChannel == 1) {
      currentPosition = ref.watch(currentposProviderC1);
      totalDuration = ref.watch(maxdurationProviderC1);
    } else if (currentChannel == 2) {
      currentPosition = ref.watch(currentposProviderC2);
      totalDuration = ref.watch(maxdurationProviderC2);
    }

    // Calculate progress (0.0 to 1.0)
    double progress = 0.0;
    if (totalDuration.inMilliseconds > 0) {
      progress = currentPosition.inMilliseconds / totalDuration.inMilliseconds;
      progress = progress.clamp(0.0, 1.0);
    }

    final theme = Theme.of(context);
    final effectiveProgressColor = progressColor ?? theme.colorScheme.primary;
    final effectiveBackgroundColor =
        backgroundColor ?? Colors.white.withValues(alpha: 0.3);

    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        borderRadius: BorderRadius.circular(height / 2),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: effectiveProgressColor,
              borderRadius: BorderRadius.circular(height / 2),
              boxShadow: [
                BoxShadow(
                  color: effectiveProgressColor.withValues(alpha: 0.3),
                  blurRadius: 2,
                  spreadRadius: 0.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Contains AI-generated edits.
