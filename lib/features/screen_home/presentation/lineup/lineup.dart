// lineup_section.dart
import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup.dart';

class LineupSection extends StatelessWidget {
  final double width;

  const LineupSection({super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Lineup(
            availableWidth: constraints.maxWidth,
            availableHeight: constraints.maxHeight,
          );
        },
      ),
    );
  }
}
