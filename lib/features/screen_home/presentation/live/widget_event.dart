import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
import 'package:soundboard/features/screen_home/presentation/live/events/event_card.dart';
import 'events/event_period.dart';

const double containerWidth = 250;

class EventWidget extends StatefulWidget {
  final MatchEvent data;
  const EventWidget({super.key, required this.data});

  @override
  State<EventWidget> createState() => _EventWidgetState();
}

class _EventWidgetState extends State<EventWidget> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.data.matchEventTypeID) {
      case MatchEventType.mal:
        return EventCard(data: widget.data);
      case MatchEventType.utvisning:
        return EventCard(data: widget.data);
      case MatchEventType.periodslut:
      case MatchEventType.periodstart:
        return PeriodEvent(data: widget.data);
      case MatchEventType.malvaktIn:
        return EventCard(data: widget.data);
      case MatchEventType.straffmal:
        return EventCard(data: widget.data);
      case MatchEventType.timeoutBorta:
      case MatchEventType.timeoutHemma:
        return EventCard(data: widget.data);
      default:
        return const Text("");
    }
  }
}
