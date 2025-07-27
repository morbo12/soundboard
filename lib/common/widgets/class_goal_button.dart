import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common/widgets/button_with_progress.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/audioplayer_func.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/providers/audio_progress_provider.dart';

final Logger logger = const Logger("goal_button");

class GoalButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<GoalButton> createState() => GoalButtonState();
}

class GoalButtonState extends ConsumerState<GoalButton> {
  // Category-only audio file for tracking goal jingle progress
  static final _goalAudioFile = AudioFile(
    filePath: '',
    displayName: 'Goal Jingle',
    audioCategory: AudioCategory.goalJingle,
    isCategoryOnly: true,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    ButtonStyle baseStyle =
        TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surfaceContainerLow,
          minimumSize: const Size(0, 100),
          textStyle: theme.textTheme.titleLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ).copyWith(
          // Add state layer colors
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.onSurface.withAlpha(20);
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onSurface.withAlpha(31);
            }
            return null;
          }),
        );
    // Goal button style (MÅL)
    ButtonStyle goalStyle = baseStyle.copyWith(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF9CD67D)),
      foregroundColor: WidgetStateProperty.all(const Color(0xFF20281B)),
      textStyle: WidgetStateProperty.all(theme.textTheme.headlineLarge),
    );

    return Expanded(
      child: ButtonWithProgress(
        audioFile: _goalAudioFile,
        progressColor: const Color(
          0xFF20281B,
        ), // Dark green to match button text
        backgroundColor: const Color(
          0xFF9CD67D,
        ).withValues(alpha: 0.3), // Light green matching button
        child: ElevatedButton(
          onPressed: () {
            logger.d("GOAL was pressed");
            // Update the lastPressedButtonProvider for category-only tracking
            ref.read(lastPressedButtonProvider.notifier).state = _goalAudioFile;
            playGoal2(ref);
          },
          style: goalStyle,
          child: const Text("MÅL", textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
