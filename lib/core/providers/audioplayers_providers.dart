import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final maxdurationProviderC1 = StateProvider<Duration>((ref) {
  return const Duration(seconds: 0);
});

final maxdurationProviderC2 = StateProvider<Duration>((ref) {
  return const Duration(seconds: 0);
});

final currentposProviderC1 = StateProvider<Duration>((ref) {
  return const Duration(seconds: 0);
});

final currentposProviderC2 = StateProvider<Duration>((ref) {
  return const Duration(seconds: 0);
});

final c1StateProvider = StateProvider<PlayerState>((ref) {
  return PlayerState.stopped;
});

final c2StateProvider = StateProvider<PlayerState>((ref) {
  return PlayerState.stopped;
});
