import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_match_event_type.dart';
import 'package:soundboard/features/screen_home/presentation/ssml/class_ssml_periodevent.dart';
import 'class_ssml_goalevent.dart';
import 'class_ssml_penaltyevent.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';

class PreSsml {
  final MatchEvent data;
  final WidgetRef ref;
  PreSsml({required this.ref, required this.data});
  // final BuildContext context;

  String getEventText(BuildContext context) {
    String string = "";
    final selectedMatch = ref.read(selectedMatchProvider);
    // final lineupSsml = ref.read(lineupSsmlProvider);

    switch (data.matchEventTypeID) {
      case MatchEventType.utvisning:
        SsmlPenaltyEvent(ref: ref, matchEvent: data).getSay(context);
      case MatchEventType.straffmal:
      case MatchEventType.mal:
        SsmlGoalEvent(ref: ref, matchEvent: data).getSay(context);
      case MatchEventType.lineup:
        // SsmlLineupEvent(ref: ref, matchEvent: data).getSay(context);
        ref.read(lineupSsmlProvider.notifier).state =
            selectedMatch.generateSsml();
      case MatchEventType.periodslut:
        SsmlPeriodEvent(ref: ref, matchEvent: data).getSay(context);
    }
    return string;
    // @override
    // Widget build(BuildContext context) {
    //   switch (data.matchEventTypeID) {
    //     case MatchEventType.mal:
    //       print("SAY: ${SsmlGoalEvents(matchEvent: data).getRandomSay()}");

    //     case MatchEventType.utvisning:
    //       FlutterToastr.show(SsmlPenaltyEvent(matchEvent: data).getSay(), context,
    //           duration: FlutterToastr.lengthLong,
    //           position: FlutterToastr.bottom,
    //           backgroundColor: Colors.black,
    //           textStyle: const TextStyle(color: Colors.white));

    //     // default:
    //     // return const Text("");
    //   }
    //   return const Text("");
  }

  // @override
  // Widget build(BuildContext context) {
  //   String text = SsmlGoalEvents(matchEvent: data).getRandomSay();
  //   FlutterToastr.show("${text}", context,
  //       duration: FlutterToastr.lengthLong,
  //       position: FlutterToastr.bottom,
  //       backgroundColor: Colors.black,
  //       textStyle: const TextStyle(color: Colors.white));
  //   throw UnimplementedError();
  // }
}
