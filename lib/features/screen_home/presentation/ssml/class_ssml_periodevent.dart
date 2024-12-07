import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/properties.dart';

class SsmlPeriodEvent {
  final MatchEvent matchEvent;
  final NumberFormat formatter = NumberFormat("0");
  final WidgetRef ref;

  SsmlPeriodEvent({
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

  String whoIsInLead() {
    final selectedMatch = ref.read(selectedMatchProvider);
    if (selectedMatch.goalsHomeTeam! > selectedMatch.goalsAwayTeam!) {
      return "${selectedMatch.goalsHomeTeam}-${selectedMatch.goalsAwayTeam} till hemmalaget.";
    } else if (selectedMatch.goalsHomeTeam! < selectedMatch.goalsAwayTeam!) {
      return "${selectedMatch.goalsAwayTeam}-${selectedMatch.goalsHomeTeam} till bortalaget.";
    } else {
      // Om antalet mål är lika för båda lagen
      return "oavgjort ${selectedMatch.goalsHomeTeam}-${selectedMatch.goalsAwayTeam}.";
    }
  }

  String whoWonIntermediate() {
    // Kontrollerar vem som vann eller om det blev oavgjort
    if (matchEvent.goalsHomeTeam > matchEvent.goalsAwayTeam) {
      return "${matchEvent.goalsHomeTeam}-${matchEvent.goalsAwayTeam} till hemmalaget.";
    } else if (matchEvent.goalsHomeTeam < matchEvent.goalsAwayTeam) {
      return "${matchEvent.goalsAwayTeam}-${matchEvent.goalsHomeTeam} till bortalaget.";
    } else {
      // Om antalet mål är lika för båda lagen
      return "oavgjort ${matchEvent.goalsHomeTeam}-${matchEvent.goalsAwayTeam}.";
    }
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

  // <hemma/bortalaget> vinner perioden med x-y. Ställningen i matchen efter x perioder är 1-0
  // Perioden slutar 2-1 till hemmalaget. Ställnigen efter den x:a periden är x-y

  Future<bool> getSay(BuildContext context) async {
    // String say = matchEvent.matchTeamName;
    String say =
        "Perioden slutar ${whoWonIntermediate()}. Ställningen i matchen är ${whoIsInLead()}";
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
    SettingsBox().azCharCount += say.length;
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
