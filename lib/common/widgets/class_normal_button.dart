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
          elevation: 0,
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

    return MouseRegion(
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
            child: LayoutBuilder(
              builder: (context, constraints) {
                List<String> parts = widget.primaryText.split(" - ");
                return FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: constraints.maxWidth,
                    child: parts.length > 1
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
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
                              AutoSizeText(
                                parts[1].trim(),
                                textAlign: TextAlign.center,
                                minFontSize: 12,
                                maxFontSize: 22,
                                maxLines: 1,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    179,
                                  ),
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
                            style: theme.textTheme.titleLarge?.copyWith(
                              height: 1.2,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
