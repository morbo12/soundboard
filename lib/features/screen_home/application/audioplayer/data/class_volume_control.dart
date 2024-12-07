// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
// import 'package:soundboard/constants/providers.dart';
// import 'package:soundboard/properties.dart';

// class VolumeControl {
//   static Future<void> setVolumeAndUpdateProvider(
//     double volume,
//     WidgetRef ref, {
//     AudioStream stream = AudioStream.music,
//   }) async {
//     // Set the system volume
//     await FlutterVolumeController.setVolume(volume, stream: stream);

//     // Update the provider
//     ref.read(mainVolumeProvider.notifier).updateVolume(volume);
//   }

//   static Future<void> setMainVolume(WidgetRef ref) async {
//     final mainVolume = SettingsBox().mainVolume;
//     await setVolumeAndUpdateProvider(mainVolume, ref);
//   }
// }
