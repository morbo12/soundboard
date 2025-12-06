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
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  'Live Feed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(child: LiveEvents(scrollController: scrollController)),
          ],
        ),
      ),
    );
  }
}

// Contains AI-generated edits.
