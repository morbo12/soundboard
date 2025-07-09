import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';

class MatchEventColors {
  final int matchEventTypeID;

  MatchEventColors(this.matchEventTypeID);

  Color getTileColor(BuildContext context) {
    switch (matchEventTypeID) {
      case MatchEventType.mal:
        return Theme.of(context).colorScheme.primaryContainer;
      case MatchEventType.utvisning:
        return Color.lerp(
          Theme.of(context).colorScheme.errorContainer,
          Colors.pink.shade100,
          0.5,
        )!.withAlpha(200);

      case MatchEventType.malvaktIn:
      case MatchEventType.malvaktUt:
        return Theme.of(context).colorScheme.secondaryContainer;
      case MatchEventType.missadStraff:
      case MatchEventType.straffmal:
        return Theme.of(context).colorScheme.inverseSurface;
      default:
        return Theme.of(context).colorScheme.tertiaryContainer;
    }
  }

  Color getTextColor(BuildContext context) {
    switch (matchEventTypeID) {
      case MatchEventType.mal:
        return Theme.of(context).colorScheme.onPrimaryContainer;
      case MatchEventType.utvisning:
        return Theme.of(context).colorScheme.onErrorContainer;
      case MatchEventType.malvaktIn:
      case MatchEventType.malvaktUt:
        return Theme.of(context).colorScheme.onSecondaryContainer;
      case MatchEventType.missadStraff:
      case MatchEventType.straffmal:
        return Theme.of(context).colorScheme.onInverseSurface;
      default:
        return Theme.of(context).colorScheme.onTertiaryContainer;
    }
  }
}
