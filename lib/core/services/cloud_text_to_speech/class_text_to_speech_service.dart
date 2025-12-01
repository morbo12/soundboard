import 'dart:io';

import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/core/utils/logger.dart';

final voicesProvider = StateProvider<VoicesSuccessMicrosoft>((ref) {
  return VoicesSuccessMicrosoft(voices: []);
});

class TextToSpeechService {
  final Ref ref;
  final Logger logger = const Logger('TextToSpeechService');

  TextToSpeechService(this.ref);

  void initialize({required InitParamsMicrosoft microsoftParams}) {
    TtsMicrosoft.init(params: microsoftParams, withLogs: true);
    logger.d(
      "TextToSpeechService initialized with Region: ${microsoftParams.region} and Key: ${microsoftParams.subscriptionKey}",
    );
  }

  Future<String> getTts({required String text, String? voice}) async {
    var cachedVoices = ref.read(voicesProvider);
    final myVoiceId = ref.read(voiceManagerProvider);

    if (cachedVoices.voices.isEmpty) {
      logger.d("No voices in state!!!!!!");

      // final VoicesSuccessMicrosoft voicesResponse =
      // await TtsMicrosoft.getVoices();
      ref.read(voicesProvider.notifier).state = await TtsMicrosoft.getVoices();
      // cachedVoices = ref.read(voicesProvider);
    } else {
      logger.d("Voices are CACHED!!!!!!");
    }
    logger.d("Voice is: ${VoiceManager.getAzVoiceName(myVoiceId)}");

    final selectedVoice = cachedVoices.voices.firstWhere(
      (element) =>
          element.code.toLowerCase() ==
          VoiceManager.getAzVoiceName(myVoiceId).toLowerCase(),
    );

    logger.d("Calling Azure Text2Speech");

    final params = TtsParamsMicrosoft(
      voice: selectedVoice,
      // audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
      audioFormat: AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3,
      text: text,
      rate: 'default',
      pitch: 'default',
    );

    await TtsMicrosoft.convertTts(params);
    logger.d("Lineup audio is complete");

    // TODO: Lineup functionality has been removed in refactoring
    // This method needs to be redesigned based on new requirements

    logger.d("TTS audio processing complete");

    // TODO: This method needs to be redesigned after lineup functionality removal
    // For now, returning an empty string to prevent errors
    return "";
  }

  Future<AudioSuccessMicrosoft> getTtsNoFile({
    required String text,
    String? voice,
  }) async {
    var cachedVoices = ref.read(voicesProvider);
    final myVoiceId = ref.read(voiceManagerProvider);

    // Ensure we have voices data before continuing
    if (cachedVoices.voices.isEmpty) {
      logger.d("Fetching voices because cache is empty....");

      final VoicesSuccessMicrosoft voicesResponse =
          await TtsMicrosoft.getVoices();
      ref.read(voicesProvider.notifier).state = voicesResponse;
      cachedVoices = ref.read(voicesProvider);
    }

    // Double-check if voices data is still null or empty (for some unexpected reason)
    if (cachedVoices.voices.isEmpty) {
      // Handle the error case here, perhaps throw an exception or return an error

      logger.d("Failed to fetch voices!");

      throw Exception("Failed to fetch voices data.");
    }

    logger.d("Voices are available!");

    logger.d(
      "Select Voice is: ${VoiceManager.getAzVoiceName(myVoiceId)} from ID: $myVoiceId",
    );

    final selectedVoice = cachedVoices.voices.firstWhere(
      (element) =>
          element.code.toLowerCase() ==
          VoiceManager.getAzVoiceName(myVoiceId).toLowerCase(),
      orElse: () => throw Exception(
        "Voice not found.",
      ), // This ensures we handle the case when the voice is not found.
    );

    logger.d("Calling Azure Text2Speech with voice: ${selectedVoice.code}");

    final audioFormat = Platform.isMacOS
        ? AudioOutputFormatMicrosoft.audio48Khz192kBitrateMonoMp3
        : AudioOutputFormatMicrosoft.Webm24Khz16Bit24KbpsMonoOpus;

    final params = TtsParamsMicrosoft(
      voice: selectedVoice,
      audioFormat: audioFormat,
      text: text,
      rate: 'default',
      pitch: 'default',
    );

    final ttsResponse = await TtsMicrosoft.convertTts(params);

    return ttsResponse;
  }
}
