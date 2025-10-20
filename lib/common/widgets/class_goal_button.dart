import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common/widgets/button_with_progress.dart';
import 'package:soundboard/common/widgets/dialogs/hotkey_assignment_dialog.dart';
import 'package:soundboard/core/services/hotkey_service.dart';
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
  static const String _buttonId = 'goal_button';

  // Category-only audio file for tracking goal jingle progress
  static final _goalAudioFile = AudioFile(
    filePath: '',
    displayName: 'Goal Jingle',
    audioCategory: AudioCategory.goalJingle,
    isCategoryOnly: true,
  );

  @override
  void initState() {
    super.initState();

    // Register hotkey callback after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotkeyService = ref.read(hotkeyServiceProvider);
      hotkeyService.registerCallback(_buttonId, _triggerGoal);
    });
  }

  void _triggerGoal() {
    logger.d("GOAL triggered via hotkey");
    ref.read(lastPressedButtonProvider.notifier).state = _goalAudioFile;
    playGoal2(ref);
  }

  Future<void> _showHotkeyDialog() async {
    logger.d("Goal button long pressed - showing hotkey dialog");

    final result = await showHotkeyAssignmentDialog(
      context: context,
      buttonId: _buttonId,
      buttonName: 'Goal Button (MÅL)',
    );

    if (result != null && mounted) {
      // Assign the hotkey with our callback
      final hotkeyService = ref.read(hotkeyServiceProvider);
      await hotkeyService.assignHotkey(_buttonId, result, _triggerGoal);
      setState(() {}); // Trigger rebuild to show hotkey in UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hotkeyService = ref.watch(hotkeyServiceProvider);
    final assignedHotkey = hotkeyService.getHotkey(_buttonId);

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
        child: GestureDetector(
          onLongPress: _showHotkeyDialog,
          child: ElevatedButton(
            onPressed: () {
              logger.d("GOAL was pressed");
              _triggerGoal();
            },
            style: goalStyle,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("MÅL", textAlign: TextAlign.center),
                if (assignedHotkey != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    HotkeyUtils.formatForDisplay(assignedHotkey),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: const Color(0xFF20281B).withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
