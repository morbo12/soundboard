// import 'dart:io';
// import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:soundboard/constants/globals.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiocategory.dart';

// String lineupFile = '';

// // Assume voicesProvider is defined as a StateProvider
// final voicesProvider = StateProvider<VoicesSuccessMicrosoft>((ref) {
//   // Initialize with an empty list or provide default values as needed
//   return VoicesSuccessMicrosoft(voices: []);
// });

// Future<String> getTts({required WidgetRef ref, required String text}) async {
//   // Read the cached voices from the state
//   var cachedVoices = ref.read(voicesProvider);

//   // Check if voices are already available in the state
//   if (cachedVoices.voices.isEmpty) {
//     print("No vocices in state!!!!!!");
//     // Fetch voices only if not available in the state
//     final VoicesSuccessMicrosoft voicesResponse =
//         await TtsMicrosoft.getVoices();

//     // Update the Riverpod state with the fetched voices
//     ref.read(voicesProvider.notifier).state = voicesResponse;
//     cachedVoices = ref.read(voicesProvider);
//   } else {
//     print("Voices are CACHED!!!!!!");
//   }
//   // await Future.delayed(
//   //   const Duration(milliseconds: 5000),
//   //   () async {
//   //     print("foo");
//   //   },
//   // );

//   // Retrieve the selected voice from the cached voices
//   final selectedVoice = cachedVoices.voices.firstWhere(
//     (element) => element.code.toLowerCase() == "sv-se-sofieneural",
//   );

//   // Update the voiceProvider state with the selected voice
//   // ref.read(voiceProvider.notifier).state = selectedVoice;

//   // Debugging: Print the cached voices
//   // inspect(ref.read(voiceProvider));

//   if (kDebugMode) {
//     print("Calling Azure Text2Speech");
//   }

//   // Use the cached voice from voiceProvider
//   TtsParamsMicrosoft params = TtsParamsMicrosoft(
//     voice: selectedVoice,
//     audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
//     text: text,
//   );

//   final ttsResponse = await TtsMicrosoft.convertTts(params);

//   if (kDebugMode) {
//     print("Lineup audio is complete");
//   }

//   List<AudioFile> lineupFilePath = jingleManager.audioManager.audioInstances
//       .where((instance) => instance.audioCategory == AudioCategory.lineupJingle)
//       .toList();

//   File(lineupFilePath[0].filePath).writeAsBytes(ttsResponse.audio, flush: true);

//   if (kDebugMode) {
//     print("Lineup audio FILE is complete");
//   }

//   return lineupFilePath[0].filePath;
// }

// Future<AudioSuccessMicrosoft> getTtsNoFile(
//     {required WidgetRef ref, required String text}) async {
//   var cachedVoices = ref.read(voicesProvider);

//   // final VoicesSuccessMicrosoft voicesResponse = await TtsMicrosoft.getVoices();
//   // inspect(voicesResponse.voices[0]);
//   // final voice = voicesResponse.voices
//   //     .where((element) => element.code == "sv-SE-MattiasNeural")
//   //     .toList(growable: false)
//   //     .first;
// // Check if voices are already available in the state
//   if (cachedVoices.voices.isEmpty) {
//     print("No vocices in state!!!!!!");
//     // Fetch voices only if not available in the state
//     final VoicesSuccessMicrosoft voicesResponse =
//         await TtsMicrosoft.getVoices();

//     // Update the Riverpod state with the fetched voices
//     ref.read(voicesProvider.notifier).state = voicesResponse;
//     cachedVoices = ref.read(voicesProvider);
//   } else {
//     print("Voices are CACHED!!!!!!");
//   }

//   // Retrieve the selected voice from the cached voices
//   final selectedVoice = cachedVoices.voices.firstWhere(
//     (element) => element.code.toLowerCase() == "sv-se-mattiasneural",
//   );
//   if (kDebugMode) {
//     print("Calling Azure Text2Speech");
//   }
//   TtsParamsMicrosoft params = TtsParamsMicrosoft(
//       voice: selectedVoice,
//       audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
//       text: text);
//   final ttsResponse = await TtsMicrosoft.convertTts(params);
//   // print(ttsResponse);

//   return ttsResponse;
// }
