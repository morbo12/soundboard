// lineup_section.dart
import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup.dart';

class LineupSection extends StatelessWidget {
  const LineupSection({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
