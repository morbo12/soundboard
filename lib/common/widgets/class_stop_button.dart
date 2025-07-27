import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/logger.dart';

final Logger logger = const Logger("stop_button");

class StopButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<StopButton> createState() => StopButtonState();
}

class StopButtonState extends ConsumerState<StopButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

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
      child: ElevatedButton(
        onPressed: () {
          logger.d("STOP was pressed");

          jingleManagerAsync.whenData((jingleManager) {
            jingleManager.audioManager.stopAll(ref);
          });
        },
        style: stopStyle,
        child: const Text("STOP", textAlign: TextAlign.center),
      ),
    );
  }
}
