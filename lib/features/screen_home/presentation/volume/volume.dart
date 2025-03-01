// events_section.dart
import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/volume/classes/class_column_volume.dart';

class VolumeSection extends StatelessWidget {
  final double width;

  const VolumeSection({
    super.key,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          VerticalDivider(
            thickness: 1.0,
            width: 0.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          ColumnVolume(),
        ],
      ),
    );
  }
}
