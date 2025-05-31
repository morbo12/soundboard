// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LargeButton extends StatefulWidget {
  final String primaryText;
  final String secondaryText;
  final Function()? onTap;
  final ButtonStyle? style;
  final bool? isDisabled;
  final bool? isSelected;
  final int? noLines;

  const LargeButton({
    super.key,
    required this.primaryText,
    required this.onTap,
    required this.secondaryText,
    this.style,
    this.isDisabled,
    this.isSelected,
    this.noLines,
  });

  @override
  LargeButtonState createState() => LargeButtonState();
}

class LargeButtonState extends State<LargeButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Base style using Material 3 tokens
    ButtonStyle baseStyle =
        TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surface,
          minimumSize: const Size(0, 100),
          textStyle: theme.textTheme.titleLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          elevation: 1,
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

    // Selected state style
    ButtonStyle selectedStyle = baseStyle.copyWith(
      backgroundColor: WidgetStateProperty.all(colorScheme.primaryContainer),
      foregroundColor: WidgetStateProperty.all(colorScheme.onPrimaryContainer),
    );

    // Goal button style (MÅL)
    ButtonStyle goalStyle = baseStyle.copyWith(
      backgroundColor: WidgetStateProperty.all(const Color(0xFF9CD67D)),
      foregroundColor: WidgetStateProperty.all(const Color(0xFF20281B)),
      textStyle: WidgetStateProperty.all(theme.textTheme.headlineLarge),
    );

    // Stop button style
    ButtonStyle stopStyle = baseStyle.copyWith(
      backgroundColor: WidgetStateProperty.all(colorScheme.errorContainer),
      foregroundColor: WidgetStateProperty.all(colorScheme.onErrorContainer),
      textStyle: WidgetStateProperty.all(theme.textTheme.headlineMedium),
    );

    // Disabled style
    ButtonStyle disabledStyle = baseStyle.copyWith(
      backgroundColor: WidgetStateProperty.all(
        colorScheme.onSurface.withAlpha(31),
      ),
      foregroundColor: WidgetStateProperty.all(
        colorScheme.onSurface.withAlpha(97),
      ),
    );

    // Determine which style to use
    ButtonStyle? buttonStyle = widget.style;
    if (buttonStyle == null) {
      if (widget.isDisabled == true) {
        buttonStyle = disabledStyle;
      } else if (widget.primaryText == "MÅL") {
        buttonStyle = goalStyle;
      } else if (widget.primaryText == "STOP") {
        buttonStyle = stopStyle;
      } else if (widget.isSelected == true) {
        buttonStyle = selectedStyle;
      } else {
        buttonStyle = baseStyle;
      }
    }

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              boxShadow: [
                if (_isHovered && !(widget.isDisabled ?? false))
                  BoxShadow(
                    color: colorScheme.shadow.withAlpha(26),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
              ],
            ),
            child: ElevatedButton(
              onPressed: widget.isDisabled == true ? null : widget.onTap,
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
        ),
      ),
    );
  }
}
