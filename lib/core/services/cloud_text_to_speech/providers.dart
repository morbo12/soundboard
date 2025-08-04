import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_hybrid_text_to_speech_service.dart';

final textToSpeechServiceProvider = Provider<HybridTextToSpeechService>((ref) {
  return HybridTextToSpeechService(ref);
});
