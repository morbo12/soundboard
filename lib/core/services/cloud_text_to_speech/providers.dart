import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_text_to_speech_service.dart';

final textToSpeechServiceProvider = Provider<TextToSpeechService>((ref) {
  return TextToSpeechService(ref);
});
