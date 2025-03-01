// Enhanced version with more options
import 'package:flutter/material.dart';

class VerticalDividerWidget extends StatelessWidget {
  final double width;
  final double thickness;
  final Color? color;
  final double height;
  final EdgeInsets padding;
  final bool useThemeColor;

  const VerticalDividerWidget({
    super.key,
    this.width = 2.0,
    this.thickness = 2.0,
    this.color,
    this.height = 24.0,
    this.padding = EdgeInsets.zero,
    this.useThemeColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        child: VerticalDivider(
          width: width,
          thickness: thickness,
          color: useThemeColor
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : color ?? Colors.white,
        ),
      ),
    );
  }
}
