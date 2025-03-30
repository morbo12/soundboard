// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class Button extends StatefulWidget {
  final String primaryText;
  final String secondaryText;
  final Function()? onTap;
  final ButtonStyle? style;
  final bool? isDisabled;
  final bool? isSelected;
  final int? noLines;

  const Button({
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
  ButtonState createState() => ButtonState();
}

class ButtonState extends State<Button> {
  @override
  Widget build(BuildContext context) {
    ButtonStyle? buttonStyle;
    ButtonStyle normalbuttonStyle = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      backgroundColor: Theme.of(context).colorScheme.surface,
      // fixedSize: const Size.fromHeight(100),
      minimumSize: const Size(0, 100),
      textStyle: const TextStyle(fontSize: 24),
    );

    ButtonStyle selectedButtonStyle = normalbuttonStyle.copyWith(
        backgroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.primaryContainer),
        foregroundColor: WidgetStateProperty.all<Color>(
            Theme.of(context).colorScheme.onPrimaryContainer));

    ButtonStyle goalButtonStyle = normalbuttonStyle.copyWith(
      // backgroundColor: WidgetStateProperty.all<Color>(Color(0xFF00513B))
      backgroundColor: WidgetStateProperty.all<Color>(const Color(0xFF9CD67D)),
      foregroundColor: WidgetStateProperty.all<Color>(const Color(0xFF20281B)),
      textStyle:
          WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 48)),
    );

    ButtonStyle stopButtonStyle = normalbuttonStyle.copyWith(
      backgroundColor: WidgetStateProperty.all<Color>(
          Theme.of(context).colorScheme.errorContainer),
      foregroundColor: WidgetStateProperty.all<Color>(
          Theme.of(context).colorScheme.onErrorContainer),
      textStyle:
          WidgetStateProperty.all<TextStyle>(const TextStyle(fontSize: 48)),
    );

    ButtonStyle disabledButtonStyle = normalbuttonStyle.copyWith(
        backgroundColor:
            WidgetStateProperty.all<Color>(const Color(0x14C4DFFF)),
        foregroundColor:
            WidgetStateProperty.all<Color>(const Color(0x61DFEBFB)));

    // No style was provided, use default
    if (widget.style == null) {
      buttonStyle = normalbuttonStyle;
    } else {
      buttonStyle = widget.style;
    }

    // Button has no style provided and is not "selected"
    if (widget.style == null && widget.isSelected == true) {
      buttonStyle = selectedButtonStyle;
    }

    // Is it a MÅL button?
    if (widget.primaryText == "MÅL") {
      buttonStyle = goalButtonStyle;
    }

    // Is it a STOP button
    if (widget.primaryText == "STOP") {
      buttonStyle = stopButtonStyle;
    }

    // Button has no style provided and is "disabled"
    if (widget.style == null && widget.isDisabled == true) {
      // isButtonDisabled = true;
      buttonStyle = disabledButtonStyle;
    }

    return Expanded(
        child: TextButton(
      onPressed: widget.isDisabled == true ? null : widget.onTap,
      style: buttonStyle,
      child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            children: [
              Text(
                widget.primaryText,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
              widget.secondaryText != "N/A"
                  ? Text(
                      widget.secondaryText,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: (normalbuttonStyle.textStyle
                                    ?.resolve({})?.fontSize ??
                                28.0) *
                            0.70,
                      ),
                    )
                  : Container(),
            ],
          )),
    ));
  }
}
