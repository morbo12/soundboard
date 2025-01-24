import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/innebandy_api/data/class_lineup.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/innebandy_api/data/class_match_event.dart';
// import 'package:soundboard/features/innebandy_api/data/class_matchevent.dart';
// import 'package:soundboard/features/innebandy_api/data/class_venuematch.dart';
import 'package:soundboard/features/screen_home/presentation/lineup/classes/class_lineup_data.dart';
import 'package:soundboard/properties.dart';

class Lineup extends ConsumerStatefulWidget {
  final double availableWidth;

  const Lineup({super.key, required double this.availableWidth});

  @override
  ConsumerState<Lineup> createState() => _LineupState();
}

class _LineupState extends ConsumerState<Lineup> {
  bool streamerRunning = false;
  late IbyMatch updatedMatch;
  late List<IbyMatchEvent> matchEventList;
  late int liveindex;
  TextEditingController _controller = TextEditingController();
  bool _showError = false;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // final selectedMatch = ref.watch(selectedMatchProvider);
    final lineupSsml = ref.watch(lineupSsmlProvider);
    final selectedMatch = ref.read(selectedMatchProvider);

    return SizedBox(
      width: widget.availableWidth,
      child: Padding(
        padding: const EdgeInsets.only(left: 5.0, top: 5.0, right: 5.0),
        child: Column(
          children: [
            // Header for Matchhändelser
            Container(
              // Top row with rounded corners
              // width: maxWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              padding: const EdgeInsets.all(6.0),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () async {
                                if (lineupSsml.isNotEmpty) {
                                  if (kDebugMode) {
                                    print("Lineup String Exists");
                                  }
                                  final textToSpeechService =
                                      ref.read(textToSpeechServiceProvider);
                                  final speech =
                                      await textToSpeechService.getTtsNoFile(
                                          text: lineupSsml.toString());
                                  ref
                                      .read(azCharCountProvider.notifier)
                                      .state += lineupSsml.length;

                                  SettingsBox().azCharCount += lineupSsml
                                      .length; // TODO: Should check if getTts was successful
                                  await jingleManager.audioManager.playBytes(
                                      audio: speech.audio.buffer.asUint8List(),
                                      ref: ref);
                                } else {
                                  if (kDebugMode) {
                                    print("Generating Linup String");
                                  }
                                  ref.read(lineupSsmlProvider.notifier).state =
                                      selectedMatch.generateSsml();
                                }
                                // print("Lineup SSML: $lineupSsml");
                                // playLineup(lineupFile);
                              },
                              child: Text(
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer),
                                  "Play Lineup"),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Theme.of(context).colorScheme.surfaceTint),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                isDense: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                filled: true,
                                counterText: '',
                              ),
                              textAlign: TextAlign.center,
                              controller: _controller,
                              maxLength: 4,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              style: TextStyle(
                                fontSize: 18,
                                color: _showError
                                    ? Colors.red
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                              ),
                              onTap: () {
                                _controller.clear();
                              },
                              onChanged: (value) {
                                if (value.length >= 3) {
                                  String minutes =
                                      value.substring(0, value.length - 2);
                                  String seconds =
                                      value.substring(value.length - 2);

                                  int minutesInt = int.parse(minutes);
                                  int secondsInt = int.parse(seconds);

                                  if (minutesInt > 20) {
                                    setState(() {
                                      _showError = true;
                                    });
                                    _flashRedAndClear();
                                    return;
                                  }
                                  if (secondsInt > 59) secondsInt = 59;

                                  String formattedTime =
                                      '$minutesInt:${secondsInt.toString().padLeft(2, '0')}';

                                  _controller.value = TextEditingValue(
                                    text: formattedTime,
                                    selection: TextSelection.collapsed(
                                        offset: formattedTime.length),
                                  );
                                  setState(() {
                                    _showError = false;
                                  });
                                  ;
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Line under header
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                    color: Theme.of(context).colorScheme.surfaceTint),
              ),
            ),
            LineupData(availableWidth: widget.availableWidth)
          ],
        ),
      ),
    );
  }

  void _flashRedAndClear() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _showError = false;
        _controller.clear();
      });
    });
  }
}
