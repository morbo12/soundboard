import 'dart:io';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
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

    final ttsResponse = await TtsMicrosoft.convertTts(params);
    logger.d("Lineup audio is complete");

    final jingleManagerAsync = ref.read(jingleManagerProvider);
    final jingleManager = jingleManagerAsync.maybeWhen(
      data: (manager) => manager,
      orElse: () => throw Exception("JingleManager not available"),
    );

    List<AudioFile> lineupFilePath = jingleManager.audioManager.audioInstances
        .where(
          (instance) => instance.audioCategory == AudioCategory.lineupJingle,
        )
        .toList();

    File(
      lineupFilePath[0].filePath,
    ).writeAsBytes(ttsResponse.audio, flush: true);

    logger.d("Lineup audio FILE is complete");

    return lineupFilePath[0].filePath;
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

    final params = TtsParamsMicrosoft(
      voice: selectedVoice,
      audioFormat: AudioOutputFormatMicrosoft.Webm24Khz16Bit24KbpsMonoOpus,
      text: text,
      rate: 'default',
      pitch: 'default',
    );

    final ttsResponse = await TtsMicrosoft.convertTts(params);

    return ttsResponse;
  }
}
