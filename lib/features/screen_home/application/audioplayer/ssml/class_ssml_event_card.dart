import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';
import 'class_ssml_goalevent.dart';
import 'class_ssml_penaltyevent.dart';

class EventCardSsml {
  final dynamic data;
  final WidgetRef ref;
  EventCardSsml({required this.ref, required this.data});
  // final BuildContext context;

  String getEventText(BuildContext context) {
    String string = "";
    ref.read(selectedMatchProvider);
    // final lineupSsml = ref.read(lineupSsmlProvider);

    switch (data.matchEventTypeId) {
      case MatchEventType.utvisning:
        SsmlPenaltyEvent(ref: ref, matchEvent: data).getSay(context);
      case MatchEventType.straffmal:
      case MatchEventType.mal:
        SsmlGoalEvent(ref: ref, matchEvent: data).getSay(context);
    }
    return string;
  }
}
