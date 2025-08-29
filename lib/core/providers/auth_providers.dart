import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/auth_service.dart';
import 'package:soundboard/core/services/soundboard_tts_service.dart';

// Provider for the authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

// Provider for the Soundboard TTS service
final soundboardTtsServiceProvider = Provider<SoundboardTtsService>((ref) {
  final authService = ref.read(authServiceProvider);
  return SoundboardTtsService(authService);
});

// Provider for authentication token state
final authTokenProvider = StateProvider<String?>((ref) {
  return null;
});

// Provider for available voices from the API
final apiVoicesProvider = FutureProvider<List<String>?>((ref) async {
  final ttsService = ref.read(soundboardTtsServiceProvider);
  return await ttsService.getAvailableVoices();
});

// Provider for connection status
final apiConnectionStatusProvider = FutureProvider<bool>((ref) async {
  final ttsService = ref.read(soundboardTtsServiceProvider);
  return await ttsService.testConnection();
});

// Contains AI-generated edits.
