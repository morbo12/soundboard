import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/properties.dart';

class SsmlPeriodEvent {
  // final IbyMatch data;
  final NumberFormat formatter = NumberFormat("0");
  final WidgetRef ref;
  int period = 0;
  late final selectedMatch;

  SsmlPeriodEvent({
    required this.ref,
    // required this.data,
    required this.period,
  }) {
    selectedMatch = ref.read(selectedMatchProvider);
  }

  String stripTeamSuffix(String teamName) {
    return teamName.replaceAll(RegExp(r' \([A-Z]\)'), '');
  }

  String whoIsInLead() {
    if (selectedMatch.goalsHomeTeam! > selectedMatch.goalsAwayTeam!) {
      return "<prosody rate='slow' pitch='medium'><say-as interpret-as='number'>${selectedMatch.goalsHomeTeam}</say-as> <say-as interpret-as='number'>${selectedMatch.goalsAwayTeam}</say-as></prosody> till ${stripTeamSuffix(selectedMatch.homeTeam)}.";
    } else if (selectedMatch.goalsHomeTeam! < selectedMatch.goalsAwayTeam!) {
      return "<prosody rate='slow' pitch='medium'><say-as interpret-as='number'>${selectedMatch.goalsAwayTeam}</say-as> <say-as interpret-as='number'>${selectedMatch.goalsHomeTeam}</say-as></prosody> till ${stripTeamSuffix(selectedMatch.awayTeam)}.";
    } else {
      // Om antalet mål är lika för båda lagen
      return "oavgjort ${selectedMatch.goalsHomeTeam}-${selectedMatch.goalsAwayTeam}.";
    }
  }

  String whoWonIntermediate() {
    final hasIntermediateResults = selectedMatch.intermediateResults != null &&
        selectedMatch.intermediateResults!.length > period;
    if (hasIntermediateResults) {
      final periodResult = selectedMatch.intermediateResults![period];
      // return "${periodResult.goalsHomeTeam} - ${periodResult.goalsAwayTeam}";
    } else {
      return "<say-as interpret-as='number'>0</say-as> <say-as interpret-as='number'>0</say-as>.";
    }

    // Kontrollerar vem som vann eller om det blev oavgjort
    if (selectedMatch.intermediateResults!
            .elementAt(this.period)
            .goalsHomeTeam >
        selectedMatch.intermediateResults!
            .elementAt(this.period)
            .goalsAwayTeam) {
      // Hemmalaget vann perioden
      return "<say-as interpret-as='number'>${selectedMatch.intermediateResults!.elementAt(this.period).goalsHomeTeam}</say-as> <say-as interpret-as='number'>${selectedMatch.intermediateResults!.elementAt(this.period).goalsAwayTeam}</say-as> till ${stripTeamSuffix(selectedMatch.homeTeam)}.";
    } else if (selectedMatch.intermediateResults!
            .elementAt(this.period)
            .goalsAwayTeam >
        selectedMatch.intermediateResults!
            .elementAt(this.period)
            .goalsHomeTeam) {
      // Bortalaget vann perioden
      return "<say-as interpret-as='number'>${selectedMatch.intermediateResults!.elementAt(this.period).goalsAwayTeam}</say-as> <say-as interpret-as='number'>${selectedMatch.intermediateResults!.elementAt(this.period).goalsHomeTeam}</say-as> till ${stripTeamSuffix(selectedMatch.awayTeam)}.";
    } else {
      // Om antalet mål är lika för båda lagen
      return "oavgjort <say-as interpret-as='number'>${selectedMatch.intermediateResults!.elementAt(this.period).goalsHomeTeam}</say-as> <say-as interpret-as='number'>${selectedMatch.intermediateResults!.elementAt(this.period).goalsAwayTeam}</say-as>.";
    }
  }

  // <hemma/bortalaget> vinner perioden med x-y. Ställningen i matchen efter x perioder är 1-0
  // Perioden slutar 2-1 till hemmalaget. Ställnigen efter den x:a periden är x-y

  Future<bool> getSay(BuildContext context) async {
    // String say = selectedMatch.matchTeamName;
    final String intermediateOrFinal =
        this.period == 2 ? "Matchen slutar" : "Ställningen i matchen är";
    String say =
        "<mstts:express-as style='exited'>Perioden slutar ${whoWonIntermediate()}. <break time='500ms'/>${intermediateOrFinal} ${whoIsInLead()}</mstts:express-as>";
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

    return true;
  }
}
