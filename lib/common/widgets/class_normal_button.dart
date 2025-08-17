import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NormalButton extends StatefulWidget {
  final String primaryText;
  final Function()? onTap;
  final ButtonStyle? style;
  final bool? isDisabled;
  final bool? isSelected;

  const NormalButton({
    super.key,
    required this.primaryText,
    required this.onTap,
    this.style,
    this.isDisabled,
    this.isSelected,
  });

  @override
  NormalButtonState createState() => NormalButtonState();
}

class NormalButtonState extends State<NormalButton> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Base style using Material 3 tokens
    ButtonStyle baseStyle =
        ElevatedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surfaceContainerLow,
          minimumSize: const Size(double.infinity, 100),
          maximumSize: const Size(double.infinity, double.infinity),
          textStyle: theme.textTheme.titleLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ).copyWith(
          // Add state layer colors
          overlayColor: WidgetStatePropertyAll(
            colorScheme.onSurface.withAlpha(20),
          ),
        );

    // Selected state style
    ButtonStyle selectedStyle = baseStyle.copyWith(
      backgroundColor: WidgetStatePropertyAll(colorScheme.primaryContainer),
      foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
    );

    // Disabled style
    ButtonStyle disabledStyle = baseStyle.copyWith(
      backgroundColor: WidgetStatePropertyAll(
        colorScheme.onSurface.withAlpha(30),
      ),
      foregroundColor: WidgetStatePropertyAll(
        colorScheme.onSurface.withAlpha(97),
      ),
    );

    // Determine which style to use
    ButtonStyle? buttonStyle = widget.style;
    if (buttonStyle == null) {
      if (widget.isDisabled == true) {
        buttonStyle = disabledStyle;
      } else if (widget.isSelected == true) {
        buttonStyle = selectedStyle;
      } else {
        buttonStyle = baseStyle;
      }
    }

    return ElevatedButton(
      onPressed: widget.isDisabled == true ? null : widget.onTap,
      style: buttonStyle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Support both " - " and "\n" for splitting text into dual lines
          List<String> parts;
          if (widget.primaryText.contains('\n')) {
            parts = widget.primaryText.split('\n');
          } else {
            parts = widget.primaryText.split(" - ");
          }

          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: constraints.maxWidth.isFinite
                  ? constraints.maxWidth
                  : null,
              child: parts.length > 1
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // First line (main text)
                        AutoSizeText(
                          parts[0].trim(),
                          textAlign: TextAlign.center,
                          minFontSize: 12,
                          maxFontSize: 24,
                          maxLines: 1,
                          style: theme.textTheme.titleLarge?.copyWith(
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Second line (could be subtitle or "(Random)")
                        AutoSizeText(
                          parts[1].trim(),
                          textAlign: TextAlign.center,
                          minFontSize: 12,
                          maxFontSize: parts[1].trim() == '(Random)' ? 18 : 22,
                          maxLines: 1,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withAlpha(179),
                          ),
                        ),
                      ],
                    )
                  : AutoSizeText(
                      widget.primaryText,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      minFontSize: 12,
                      maxFontSize: 26,
                      style: theme.textTheme.titleLarge?.copyWith(height: 1.2),
                    ),
            ),
          );
        },
      ),
    );
  }
}

// Contains AI-generated edits.
