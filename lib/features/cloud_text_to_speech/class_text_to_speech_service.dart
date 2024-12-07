import 'dart:io';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiocategory.dart';

final voicesProvider = StateProvider<VoicesSuccessMicrosoft>((ref) {
  return VoicesSuccessMicrosoft(voices: []);
});

class TextToSpeechService {
  final Ref ref;

  TextToSpeechService(this.ref);

  void initialize({
    required InitParamsMicrosoft microsoftParams,
  }) {
    TtsMicrosoft.init(
      params: microsoftParams,
      withLogs: true,
    );
    if (kDebugMode) {
      print(
          "TextToSpeechService initialized with Region: ${microsoftParams.region} and Key: ${microsoftParams.subscriptionKey}");
    }
  }

  Future<String> getTts({required String text, String? voice}) async {
    var cachedVoices = ref.read(voicesProvider);
    final myVoiceId = ref.read(voiceManagerProvider);

    if (cachedVoices.voices.isEmpty) {
      if (kDebugMode) {
        print("No voices in state!!!!!!");
      }
      // final VoicesSuccessMicrosoft voicesResponse =
      // await TtsMicrosoft.getVoices();
      ref.read(voicesProvider.notifier).state = await TtsMicrosoft.getVoices();
      // cachedVoices = ref.read(voicesProvider);
    } else {
      if (kDebugMode) {
        print("Voices are CACHED!!!!!!");
      }
    }
    if (kDebugMode) {
      print("Voice is: ${VoiceManager.getAzVoiceName(myVoiceId)}");
    }
    final selectedVoice = cachedVoices.voices.firstWhere(
      (element) =>
          element.code.toLowerCase() ==
          VoiceManager.getAzVoiceName(myVoiceId).toLowerCase(),
    );

    if (kDebugMode) {
      print("Calling Azure Text2Speech");
    }

    final params = TtsParamsMicrosoft(
      voice: selectedVoice,
      // audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
      audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
      text: text,
      rate: 'default',
      pitch: 'default',
    );

    final ttsResponse = await TtsMicrosoft.convertTts(params);

    if (kDebugMode) {
      print("Lineup audio is complete");
    }

    List<AudioFile> lineupFilePath = jingleManager.audioManager.audioInstances
        .where(
            (instance) => instance.audioCategory == AudioCategory.lineupJingle)
        .toList();

    File(lineupFilePath[0].filePath)
        .writeAsBytes(ttsResponse.audio, flush: true);

    if (kDebugMode) {
      print("Lineup audio FILE is complete");
    }

    return lineupFilePath[0].filePath;
  }

  Future<AudioSuccessMicrosoft> getTtsNoFile(
      {required String text, String? voice}) async {
    var cachedVoices = ref.read(voicesProvider);
    final myVoiceId = ref.read(voiceManagerProvider);

    // Ensure we have voices data before continuing
    if (cachedVoices.voices.isEmpty) {
      if (kDebugMode) {
        print("Fetching voices because cache is empty....");
      }
      final VoicesSuccessMicrosoft voicesResponse =
          await TtsMicrosoft.getVoices();
      ref.read(voicesProvider.notifier).state = voicesResponse;
      cachedVoices = ref.read(voicesProvider);
    }

    // Double-check if voices data is still null or empty (for some unexpected reason)
    if (cachedVoices.voices.isEmpty) {
      // Handle the error case here, perhaps throw an exception or return an error
      if (kDebugMode) {
        print("Failed to fetch voices!");
      }
      throw Exception("Failed to fetch voices data.");
    }

    if (kDebugMode) {
      print("Voices are available!");
    }
    if (kDebugMode) {
      print(
          "Select Voice is: ${VoiceManager.getAzVoiceName(myVoiceId)} from ID: $myVoiceId");
    }
    final selectedVoice = cachedVoices.voices.firstWhere(
      (element) =>
          element.code.toLowerCase() ==
          VoiceManager.getAzVoiceName(myVoiceId).toLowerCase(),
      orElse: () => throw Exception(
          "Voice not found."), // This ensures we handle the case when the voice is not found.
    );

    if (kDebugMode) {
      print("Calling Azure Text2Speech with voice: ${selectedVoice.code}");
    }

    final params = TtsParamsMicrosoft(
      voice: selectedVoice,
      audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
      text: text,
      rate: 'default',
      pitch: 'default',
    );

    final ttsResponse = await TtsMicrosoft.convertTts(params);

    return ttsResponse;
  }
}
