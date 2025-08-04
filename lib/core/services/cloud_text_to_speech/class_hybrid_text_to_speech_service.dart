import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/core/providers/auth_providers.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';

final voicesProvider = StateProvider<VoicesSuccessMicrosoft>((ref) {
  return VoicesSuccessMicrosoft(voices: []);
});

// Provider to determine which TTS service to use
final ttsServiceModeProvider = StateProvider<TtsServiceMode>((ref) {
  final settings = SettingsBox();
  // Use API if product key is configured, otherwise use Azure
  return settings.apiProductKey.isNotEmpty
      ? TtsServiceMode.soundboardApi
      : TtsServiceMode.azureDirect;
});

enum TtsServiceMode { azureDirect, soundboardApi }

class HybridTextToSpeechService {
  final Ref ref;
  final Logger logger = const Logger('HybridTextToSpeechService');

  HybridTextToSpeechService(this.ref);

  void initialize({required InitParamsMicrosoft microsoftParams}) {
    TtsMicrosoft.init(params: microsoftParams, withLogs: true);
    logger.d(
      "HybridTextToSpeechService initialized with Region: ${microsoftParams.region} and Key: ${microsoftParams.subscriptionKey}",
    );
  }

  Future<String> getTts({required String text, String? voice}) async {
    // Legacy method for compatibility - just return empty string
    // The real functionality is in getTtsNoFile
    await getTtsNoFile(text: text, voice: voice);
    return "";
  }

  Future<AudioSuccessMicrosoft> getTtsNoFile({
    required String text,
    String? voice,
  }) async {
    final mode = ref.read(ttsServiceModeProvider);

    switch (mode) {
      case TtsServiceMode.soundboardApi:
        return await _getSoundboardApiTts(text: text, voice: voice);
      case TtsServiceMode.azureDirect:
        return await _getAzureDirectTts(text: text, voice: voice);
    }
  }

  /// Get TTS using Soundboard API
  Future<AudioSuccessMicrosoft> _getSoundboardApiTts({
    required String text,
    String? voice,
  }) async {
    try {
      logger.i("Using Soundboard API for TTS");

      final soundboardTtsService = ref.read(soundboardTtsServiceProvider);
      final audioData = await soundboardTtsService.generateSpeech(text);

      if (audioData != null) {
        logger.i(
          "Successfully generated speech using Soundboard API (${audioData.length} bytes)",
        );

        // Create AudioSuccessMicrosoft with the Soundboard API audio data
        final audioSuccessMicrosoft = AudioSuccessMicrosoft(audio: audioData);

        logger.i(
          "Successfully created AudioSuccessMicrosoft with Soundboard API data",
        );
        return audioSuccessMicrosoft;
      } else {
        logger.e("Failed to generate speech using Soundboard API");
        throw Exception("Failed to generate speech using Soundboard API");
      }
    } catch (e, stackTrace) {
      logger.e("Error in Soundboard API TTS: $e", e, stackTrace);

      // Fallback to Azure if API fails
      logger.w("Falling back to Azure TTS");
      return await _getAzureDirectTts(text: text, voice: voice);
    }
  }

  /// Get TTS using direct Azure SDK (legacy method)
  Future<AudioSuccessMicrosoft> _getAzureDirectTts({
    required String text,
    String? voice,
  }) async {
    logger.i("Using Azure Direct SDK for TTS");

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
      orElse: () => throw Exception("Voice not found."),
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
    logger.i("Successfully generated speech using Azure Direct SDK");

    return ttsResponse;
  }

  /// Switch TTS service mode
  void switchMode(TtsServiceMode mode) {
    ref.read(ttsServiceModeProvider.notifier).state = mode;
    logger.i("TTS service mode switched to: $mode");
  }

  /// Get current TTS service mode
  TtsServiceMode getCurrentMode() {
    return ref.read(ttsServiceModeProvider);
  }
}

// Contains AI-generated edits.
