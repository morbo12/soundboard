// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/widgets/mini_progress_bar.dart';

class LargeButton extends ConsumerStatefulWidget {
  final String primaryText;
  final String secondaryText;
  final Function()? onTap;
  final ButtonStyle? style;
  // final bool? isDisabled;
  // final bool? isSelected;
  final int? noLines;
  final AudioFile? audioFile; // Add AudioFile parameter for progress tracking

  const LargeButton({
    super.key,
    required this.primaryText,
    required this.onTap,
    required this.secondaryText,
    this.style,
    // this.isDisabled,
    // this.isSelected,
    this.noLines,
    this.audioFile,
  });

  @override
  ConsumerState<LargeButton> createState() => LargeButtonState();
}

class LargeButtonState extends ConsumerState<LargeButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Base style using Material 3 tokens
    ButtonStyle baseStyle = TextButton.styleFrom(
      foregroundColor: colorScheme.onPrimaryContainer,
      backgroundColor: colorScheme.primaryContainer,
      minimumSize: const Size(0, 100),
      textStyle: theme.textTheme.titleLarge,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );

    // Determine which style to use
    ButtonStyle? buttonStyle = baseStyle;
    if (widget.style != null) {
      buttonStyle = widget.style!.merge(baseStyle);
    }

    return Expanded(
      child: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: 100, // Ensure minimum height
            child: ElevatedButton(
              onPressed: widget.onTap,
              style: buttonStyle,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.primaryText,
                      maxLines: widget.noLines ?? 2,
                      textAlign: TextAlign.center,
                    ),
                    if (widget.secondaryText != "N/A") ...[
                      const SizedBox(height: 4),
                      Text(
                        widget.secondaryText,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          // Progress bar overlay
          if (widget.audioFile != null)
            Positioned(
              bottom: 8,
              left: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: MiniProgressBar(audioFile: widget.audioFile, height: 6),
              ),
            ),
        ],
      ),
    );
  }
}
