import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
import 'package:soundboard/properties.dart';

class Team {
  static const String home = "hemmalaget";
  static const String away = "bortalaget";
}

class SsmlGoalEvent {
  final WidgetRef ref;
  final IbyMatchEvent matchEvent;
  SsmlGoalEvent({
    required this.matchEvent,
    required this.ref,
  });
  final NumberFormat formatter = NumberFormat("00");

  String whichTeamScored(ref) {
    final selectedMatch = ref.read(selectedMatchProvider);
    return (matchEvent.matchTeamName == selectedMatch.homeTeam)
        ? Team.home
        : Team.away;
  }

  String assistOrNot() {
    return matchEvent.playerAssistShirtNo != null
        ? "Assist av nummer <say-as interpret-as='number'>${matchEvent.playerAssistShirtNo}</say-as>, <say-as interpret-as='name'>${matchEvent.playerAssistName}</say-as>"
        : "";
  }

  String whatWasTheTime() {
    return matchEvent.minute != 0
        ? "${formatter.format(matchEvent.minute)}:${formatter.format(matchEvent.second)}"
        : "${formatter.format(matchEvent.second)} sekunder";
  }

  String randomSaying(
      {required int goalsHomeTeam, required int goalsAwayTeam}) {
    List<String> reduce = [
      "reducerar till",
      "minskar underläget till",
      "minskar siffrorna till",
    ];
    List<String> increaseMoreThanOne = [
      "utökar ledningen till",
      "bygger på försprånget till",
      "drar ifrån ytterligare till",
      "ökar på till",
      "förstärker ledningen med",
    ];
    List<String> increaseOne = [
      "går upp i ledning med",
      "tar ledningen i matchen",
      "går upp i ledning",
      "vänder och tar ledningen",
    ];

    List<String> equal = [
      "utjämnar till",
      "sätter ställningen till",
      "kvitterar ställningen till"
    ];
    // Lista för första målet i matchen
    List<String> firstGoal = [
      "går upp i ledning med",
      "tar ledningen med",
      "gör första målet i matchen med",
      "tar ledningen i matchen med",
    ];
    String say = "gör";
    String team = whichTeamScored(ref);
    int totalGoals = matchEvent.goalsHomeTeam + matchEvent.goalsAwayTeam;
    int goalDifference = team == "hemmalaget"
        ? matchEvent.goalsHomeTeam - matchEvent.goalsAwayTeam
        : matchEvent.goalsAwayTeam - matchEvent.goalsHomeTeam;

    if (totalGoals == 1) {
      // Specialfall för 1-0 eller 0-1
      say = firstGoal[Random().nextInt(firstGoal.length)];
    } else {
      if (goalDifference > 1) {
        say = increaseMoreThanOne[Random().nextInt(increaseMoreThanOne.length)];
      } else if (goalDifference == 1) {
        say = increaseOne[Random().nextInt(increaseOne.length)];
      } else if (goalDifference == 0) {
        say = equal[Random().nextInt(equal.length)];
      } else if (goalDifference < 1) {
        say = reduce[Random().nextInt(reduce.length)];
      }
    }
    return say;
  }

  String stripTeamSuffix(String teamName) {
    return teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');
  }

  whoScored() {
    String makerOfGoal;
    if (matchEvent.playerName != "Självmål") {
      makerOfGoal =
          "målskytt nummer ${matchEvent.playerShirtNo}, <say-as interpret-as='name'>${matchEvent.playerName}</say-as>.";
    } else {
      makerOfGoal = "genom självmål.";
    }

    return makerOfGoal;
  }

  Future<bool> getSay(BuildContext context) async {
    // String say = matchEvent.matchTeamName;
    String say = "${stripTeamSuffix(matchEvent.matchTeamName)} ${randomSaying(
      goalsHomeTeam: matchEvent.goalsHomeTeam,
      goalsAwayTeam: matchEvent.goalsAwayTeam,
    )} <say-as interpret-as='number'>${matchEvent.goalsHomeTeam}</say-as>${matchEvent.goalsHomeTeam == 1 && matchEvent.goalsHomeTeam == 1 ? "," : ""} <say-as interpret-as='number'>${matchEvent.goalsAwayTeam}</say-as>, ${whoScored()} ${assistOrNot()}. Tid: <say-as interpret-as='duration' format='ms'>${whatWasTheTime()}</say-as>";

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

    return true;
  }
}
