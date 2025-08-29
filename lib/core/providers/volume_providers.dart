import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_mainvolume.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_system_mainvolume.dart';

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

final musicPlayerVolumeProvider = StateNotifierProvider<VolumeNotifier, Volume>(
  (ref) => VolumeNotifier(Volume(vol: SettingsBox().musicPlayerInitialVolume)),
);
