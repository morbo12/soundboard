import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common/widgets/dialogs/hotkey_assignment_dialog.dart';
import 'package:soundboard/core/services/hotkey_service.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/logger.dart';

final Logger logger = const Logger("stop_button");

class StopButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<StopButton> createState() => StopButtonState();
}

class StopButtonState extends ConsumerState<StopButton> {
  static const String _buttonId = 'stop_button';

  @override
  void initState() {
    super.initState();

    // Register hotkey callback after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotkeyService = ref.read(hotkeyServiceProvider);
      hotkeyService.registerCallback(_buttonId, _triggerStop);
    });
  }

  void _triggerStop() {
    logger.d("STOP triggered via hotkey");
    final jingleManagerAsync = ref.read(jingleManagerProvider);
    jingleManagerAsync.whenData((jingleManager) {
      jingleManager.audioManager.stopAll(ref);
    });
  }

  Future<void> _showHotkeyDialog() async {
    logger.d("Stop button long pressed - showing hotkey dialog");

    final result = await showHotkeyAssignmentDialog(
      context: context,
      buttonId: _buttonId,
      buttonName: 'Stop Button (STOP)',
    );

    if (result != null && mounted) {
      // Assign the hotkey with our callback
      final hotkeyService = ref.read(hotkeyServiceProvider);
      await hotkeyService.assignHotkey(_buttonId, result, _triggerStop);
      setState(() {}); // Trigger rebuild to show hotkey in UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hotkeyService = ref.watch(hotkeyServiceProvider);
    final assignedHotkey = hotkeyService.getHotkey(_buttonId);

    // Base style using Material 3 tokens
    // Consolidated stop button style using Material 3 tokens
    final ButtonStyle stopStyle =
        TextButton.styleFrom(
          foregroundColor: colorScheme.onErrorContainer,
          backgroundColor: colorScheme.errorContainer,
          minimumSize: const Size(0, 100),
          textStyle: theme.textTheme.headlineMedium,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ).copyWith(
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.hovered)) {
              return colorScheme.onErrorContainer.withAlpha(20);
            }
            if (states.contains(WidgetState.pressed)) {
              return colorScheme.onErrorContainer.withAlpha(31);
            }
            return null;
          }),
        );

    return Expanded(
      child: GestureDetector(
        onLongPress: _showHotkeyDialog,
        child: ElevatedButton(
          onPressed: () {
            logger.d("STOP was pressed");
            _triggerStop();
          },
          style: stopStyle,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("STOP", textAlign: TextAlign.center),
              if (assignedHotkey != null) ...[
                const SizedBox(height: 4),
                Text(
                  HotkeyUtils.formatForDisplay(assignedHotkey),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
