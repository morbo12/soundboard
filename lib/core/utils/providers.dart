import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_mainvolume.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_system_mainvolume.dart';
import 'package:soundboard/core/properties.dart';

final lineupFileProvider = StateProvider<String>((ref) {
  return "";
});
final azCharCountProvider = StateProvider<int>(
  (ref) => SettingsBox().azCharCount,
);

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

// final mainStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

// final sbStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

// final jpStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

// final spoStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

final voicesProvider = StateProvider<VoicesSuccessUniversal>((ref) {
  return VoicesSuccessUniversal(voices: [], code: 200, reason: "N/A");
});

final mainVolumeProvider =
    StateNotifierProvider<SystemVolumeNotifier, SystemVolume>(
      (ref) =>
          SystemVolumeNotifier(SystemVolume(vol: SettingsBox().mainVolume)),
    );

final p1VolumeProvider =
    StateNotifierProvider<SystemVolumeNotifier, SystemVolume>(
      (ref) => SystemVolumeNotifier(SystemVolume(vol: SettingsBox().p1Volume)),
    );

final p2VolumeProvider =
    StateNotifierProvider<SystemVolumeNotifier, SystemVolume>(
      (ref) => SystemVolumeNotifier(SystemVolume(vol: SettingsBox().p2Volume)),
    );

final p3VolumeProvider =
    StateNotifierProvider<SystemVolumeNotifier, SystemVolume>(
      (ref) => SystemVolumeNotifier(SystemVolume(vol: SettingsBox().p3Volume)),
    );

final c1VolumeProvider = StateNotifierProvider<VolumeNotifier, Volume>(
  (ref) => VolumeNotifier(Volume(vol: SettingsBox().c1InitialVolume)),
);

final c2VolumeProvider = StateNotifierProvider<VolumeNotifier, Volume>(
  (ref) => VolumeNotifier(Volume(vol: SettingsBox().c2InitialVolume)),
);

final c1ColorProvider = StateProvider<Color>((ref) {
  return const Color(0xffe3e2e6);
});

final c2ColorProvider = StateProvider<Color>((ref) {
  return const Color(0xffe3e2e6);
});

final colorThemeProvider = StateProvider<FlexScheme>((ref) {
  return FlexScheme.greyLaw;
});
