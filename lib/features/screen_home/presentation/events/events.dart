// events_section.dart
import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/events/classes/class_live_events.dart';

class EventsSection extends StatelessWidget {
  final ScrollController scrollController;
  final double width;

  const EventsSection({
    super.key,
    required this.scrollController,
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
            width: 20.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),

          // Provide proper constraints for LiveEvents
          Expanded(child: LiveEvents(scrollController: scrollController)),
        ],
      ),
    );
  }
}

// Contains AI-generated edits.
