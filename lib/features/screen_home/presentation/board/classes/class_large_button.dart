import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class LargeButton extends StatefulWidget {
  final String primaryText;
  final Function()? onTap;
  final ButtonStyle? style;
  final bool? isDisabled;
  final bool? isSelected;

  const LargeButton({
    super.key,
    required this.primaryText,
    required this.onTap,
    this.style,
    this.isDisabled,
    this.isSelected,
  });

  @override
  LargeButtonState createState() => LargeButtonState();
}

class LargeButtonState extends State<LargeButton> {
  @override
  Widget build(BuildContext context) {
    ButtonStyle? buttonStyle;
    ButtonStyle normalButtonStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surface,
      minimumSize: const Size(0, 100),
      textStyle: const TextStyle(fontSize: 24),
      padding: EdgeInsets.zero,
    );

    ButtonStyle selectedButtonStyle = normalButtonStyle.copyWith(
      backgroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).colorScheme.primaryContainer,
      ),
      foregroundColor: WidgetStateProperty.all<Color>(
        Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );

    ButtonStyle disabledButtonStyle = normalButtonStyle.copyWith(
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0x14C4DFFF)),
      foregroundColor: WidgetStateProperty.all<Color>(const Color(0x61DFEBFB)),
    );

    // No style was provided, use default
    if (widget.style == null) {
      buttonStyle = normalButtonStyle;
    } else {
      buttonStyle = widget.style;
    }

    // Button has no style provided and is not "selected"
    if (widget.style == null && widget.isSelected == true) {
      buttonStyle = selectedButtonStyle;
    }

    // Button has no style provided and is "disabled"
    if (widget.style == null && widget.isDisabled == true) {
      buttonStyle = disabledButtonStyle;
    }

    return TextButton(
      onPressed: widget.isDisabled == true ? null : widget.onTap,
      style: buttonStyle,
      child: LayoutBuilder(
        builder: (context, constraints) {
          List<String> parts = widget.primaryText.split(" - ");
          return FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: constraints.maxWidth,
              child:
                  parts.length > 1
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
                            style: const TextStyle(
                              // fontSize: 24,
                              // height: 1.1,
                              // fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AutoSizeText(
                            parts[1].trim(),
                            textAlign: TextAlign.center,
                            minFontSize: 12,
                            maxFontSize: 22,
                            maxLines: 1,
                            style: const TextStyle(
                              // fontWeight: FontWeight.w500,
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
                        style: const TextStyle(
                          // fontSize: 26,
                          // height: 1.1,
                          // fontWeight: FontWeight.w600,
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}
