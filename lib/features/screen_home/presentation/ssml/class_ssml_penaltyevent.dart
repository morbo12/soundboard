import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/screen_home/presentation/live/data/class_penalty_type.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/properties.dart';

class SsmlPenaltyEvent {
  final MatchEvent matchEvent;
  final NumberFormat formatter = NumberFormat("0");
  final WidgetRef ref;

  SsmlPenaltyEvent({
    required this.ref,
    required this.matchEvent,
  });
  // data.matchTeamName == selectedMatch.awayTeam
  String whosEvent() {
    final selectedMatch = ref.read(selectedMatchProvider);
    return (matchEvent.matchTeamName == selectedMatch.homeTeam)
        ? "hemmalaget"
        : "bortalaget";
  }

  String homeOrAwayScore() {
    String score = "";
    if (whosEvent() == "bortalaget") {
      score = "${matchEvent.goalsAwayTeam} - ${matchEvent.goalsHomeTeam}";
    } else {
      score = "${matchEvent.goalsHomeTeam} - ${matchEvent.goalsAwayTeam}";
    }

    // if (matchEvent.goalsAwayTeam)
    return score;
  }

  String penaltyName() {
    Map<String, String> penaltyInfo =
        PenaltyTypes.getPenaltyInfo(matchEvent.penaltyCode);
    if (kDebugMode) {
      print("penaltyName: ${penaltyInfo['time']} för ${penaltyInfo['name']}");
    }
    String penaltyString = "";
    if (penaltyInfo['time'] != "Unknown") {
      penaltyString =
          "${penaltyInfo['time']} för <break time='200ms' /> ${penaltyInfo['name']}";
    }
    return penaltyString;
  }

  // Nummer z i <laget> utvisas x minuter för <penaltyname>
  // String who = whoScored(matchTeamName: matchEvent.matchTeamName);
  // Kvitterar
  // 1-0 till hemmalaget – målskytt nr 12 Pelle Karlsson – assist nr 11 Kent Persson och 9 Sven Hansson – Tid 11:04.
  // <lag> <händelse> med <1-0,0-1>
  String whatWasTheTime() {
    return matchEvent.minute != 0
        ? "${formatter.format(matchEvent.minute)}:${formatter.format(matchEvent.second)}"
        : "${formatter.format(matchEvent.second)} sekunder";
  }

  Future<bool> getSay(BuildContext context) async {
    // String say = matchEvent.matchTeamName;
    String say =
        "Nummer ${matchEvent.playerShirtNo}, ${matchEvent.playerName} i ${whosEvent()} utvisas ${penaltyName()}. Tid: <say-as interpret-as='duration' format='ms'>${whatWasTheTime()}</say-as> ";
    if (kDebugMode) {
      print("SAY: $say");
    }
    FlutterToastr.show(say, context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor: Colors.black,
        textStyle: const TextStyle(color: Colors.white));
    final textToSpeechService = ref.read(textToSpeechServiceProvider);
    final ssml = await textToSpeechService.getTtsNoFile(text: say);
    ref.read(azCharCountProvider.notifier).state += say.length;
    SettingsBox().azCharCount +=
        say.length; // TODO: Should check if getTts was successful

    // await eventAudioPlayer.setVolume(1.0);
    await jingleManager.audioManager
        .playBytes(audio: ssml.audio.buffer.asUint8List(), ref: ref);
    // eventAudioPlayer.stop();
    // eventAudioPlayer.release();

    return true;
  }

// Nybro IF tar ledningen med 1-0. Målskytt utan assistans nummer 24 Peter Eriksson. Tid 12.14

  List<String> goalSays = [
    "<hemmalag> utökar ledningen till x-y, mål av <person>",
    "Mål av <person>, <lag> leder med x-y",
  ];
}
