// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:soundboard/core/providers/volume_providers.dart';
// import 'package:soundboard/core/providers/deej_providers.dart';
// import 'package:soundboard/core/properties.dart';
// import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager.dart';
// import 'package:soundboard/core/utils/logger.dart';
// import 'package:soundboard/core/utils/platform_utils.dart';
// import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';

// /// Service that manages volume updates for both Windows audio mixer and UI sliders
// class VolumeControlService {
//   final Logger logger = const Logger('VolumeControlService');
//   final MixerManager _mixerManager = MixerManager();
//   final Ref _ref;

//   VolumeControlService(this._ref);

//   /// Updates volume for a mapped process or UI slider
//   ///
//   /// [deejSliderIdx] - The index of the Deej slider (0-3)
//   /// [volumePercent] - Volume as percentage (0.0 to 1.0)
//   Future<void> updateVolumeFromDeej(
//     int deejSliderIdx,
//     double volumePercent,
//   ) async {
//     if (!PlatformUtils.isWindows) return;

//     try {
//       // Get the mapping for this Deej slider
//       final mapping = SettingsBox().getMappingForDeejSlider(deejSliderIdx);

//       if (mapping == null) {
//         logger.d('No mapping found for Deej slider $deejSliderIdx');
//         return;
//       }

//       // Update the corresponding UI slider provider
//       await _updateUISlider(mapping.uiSliderIdx, volumePercent);

//       // If there's a process mapping, also update the Windows mixer
//       if (mapping.processName.isNotEmpty) {
//         await _updateProcessVolume(mapping.processName, volumePercent);
//       }

//       logger.d(
//         'Updated volume for Deej slider $deejSliderIdx -> UI slider ${mapping.uiSliderIdx}, '
//         'process: ${mapping.processName}, volume: ${(volumePercent * 100).toStringAsFixed(0)}%',
//       );
//     } catch (e) {
//       logger.e('Error updating volume from Deej: $e');
//     }
//   }

//   /// Updates volume from UI slider interaction
//   ///
//   /// [uiSliderIdx] - The UI slider index (0=Master, 1=P1, 2=P2, 3=P3, 4=AudioPlayer C1, 5=AudioPlayer C2)
//   /// [volumePercent] - Volume as percentage (0.0 to 1.0)
//   Future<void> updateVolumeFromUI(int uiSliderIdx, double volumePercent) async {
//     if (!PlatformUtils.isWindows) return;

//     try {
//       // Check if Deej is connected
//       final isDeejConnected = _ref.read(deejConnectionStatusProvider);

//       // Always update the UI slider provider for regular sliders (0-3)
//       // For AudioPlayer channels (4-5), only update if Deej is NOT connected
//       if (uiSliderIdx <= 3) {
//         await _updateUISlider(uiSliderIdx, volumePercent);
//       } else if (!isDeejConnected) {
//         // AudioPlayer channels (4-5) are only controlled when Deej is disconnected
//         await _updateUISlider(uiSliderIdx, volumePercent);
//       }

//       // If Deej is NOT connected, also handle Windows mixer updates and AudioPlayer channel updates
//       if (!isDeejConnected) {
//         // Find if this UI slider has any process mappings (only for regular sliders 0-3)
//         if (uiSliderIdx <= 3) {
//           final mappings = SettingsBox().sliderMappings
//               .where((m) => m.uiSliderIdx == uiSliderIdx)
//               .toList();

//           // Update all mapped processes
//           for (final mapping in mappings) {
//             if (mapping.processName.isNotEmpty) {
//               await _updateProcessVolume(mapping.processName, volumePercent);
//             }
//           }

//           // Special handling for Master slider (idx 0) - always update master volume
//           if (uiSliderIdx == 0) {
//             await _updateMasterVolume(volumePercent);
//           }

//           logger.d(
//             'Updated volume from UI slider $uiSliderIdx (Deej disconnected): '
//             'volume: ${(volumePercent * 100).toStringAsFixed(0)}%, '
//             'mapped processes: ${mappings.map((m) => m.processName).join(", ")}',
//           );
//         }
//       } else {
//         // Deej IS connected - check if we should still handle some Windows processes
//         if (uiSliderIdx <= 3) {
//           // For Master slider, always update master volume even when Deej is connected
//           // This allows the Master slider to work independently of Deej mappings
//           if (uiSliderIdx == 0) {
//             await _updateMasterVolume(volumePercent);
//             logger.d(
//               'Updated master volume from UI (Deej connected): ${(volumePercent * 100).toStringAsFixed(0)}%',
//             );
//           }
//         }
//       }
//     } catch (e) {
//       logger.e('Error updating volume from UI: $e');
//     }
//   }

//   /// Updates the appropriate UI slider provider
//   Future<void> _updateUISlider(int uiSliderIdx, double volumePercent) async {
//     switch (uiSliderIdx) {
//       case 0: // Master
//         _ref.read(mainVolumeProvider.notifier).updateVolume(volumePercent);
//         SettingsBox().mainVolume = volumePercent;
//         break;
//       case 1: // P1
//         _ref.read(p1VolumeProvider.notifier).updateVolume(volumePercent);
//         SettingsBox().p1Volume = volumePercent;
//         break;
//       case 2: // P2
//         _ref.read(p2VolumeProvider.notifier).updateVolume(volumePercent);
//         SettingsBox().p2Volume = volumePercent;
//         break;
//       case 3: // P3
//         _ref.read(p3VolumeProvider.notifier).updateVolume(volumePercent);
//         SettingsBox().p3Volume = volumePercent;
//         break;
//       case 4: // AudioPlayer Channel 1
//         await _updateAudioPlayerChannel(1, volumePercent);
//         break;
//       case 5: // AudioPlayer Channel 2
//         await _updateAudioPlayerChannel(2, volumePercent);
//         break;
//       default:
//         logger.w('Unknown UI slider index: $uiSliderIdx');
//     }
//   }

//   /// Updates volume for a specific process in Windows audio mixer
//   Future<void> _updateProcessVolume(
//     String processName,
//     double volumePercent,
//   ) async {
//     try {
//       // Special handling for master volume
//       if (processName.toLowerCase() == 'master') {
//         await _updateMasterVolume(volumePercent);
//         return;
//       }

//       // Get all processes and find matching ones
//       final mixerList = await _mixerManager.getMixerList();
//       final matchingProcesses = mixerList
//           .where(
//             (process) => process.processPath.toLowerCase().contains(
//               processName.toLowerCase(),
//             ),
//           )
//           .toList();

//       // Update volume for all matching processes
//       for (final process in matchingProcesses) {
//         await _mixerManager.setApplicationVolume(
//           process.processId,
//           volumePercent,
//         );
//         logger.d(
//           'Set volume for process ${process.processPath} (ID: ${process.processId}) '
//           'to ${(volumePercent * 100).toStringAsFixed(0)}%',
//         );
//       }

//       if (matchingProcesses.isEmpty) {
//         logger.d('No running processes found matching "$processName"');
//       }
//     } catch (e) {
//       logger.e('Error updating process volume for $processName: $e');
//     }
//   }

//   /// Updates the Windows master volume
//   Future<void> _updateMasterVolume(double volumePercent) async {
//     try {
//       await _mixerManager.setMasterVolume(volumePercent);
//       logger.d(
//         'Set master volume to ${(volumePercent * 100).toStringAsFixed(0)}%',
//       );
//     } catch (e) {
//       logger.e('Error updating master volume: $e');
//     }
//   }

//   /// Updates the volume for a specific AudioPlayer channel
//   Future<void> _updateAudioPlayerChannel(
//     int channelNumber,
//     double volumePercent,
//   ) async {
//     try {
//       // Check if Deej is connected to determine control method
//       final isDeejConnected = _ref.read(deejConnectionStatusProvider);

//       if (isDeejConnected) {
//         // When Deej is connected, only update the provider values
//         // The AudioPlayer volume will be controlled by AudioManager when audio starts
//         if (channelNumber == 1) {
//           _ref.read(c1VolumeProvider.notifier).updateVolume(volumePercent);
//           SettingsBox().c1InitialVolume = volumePercent;
//           logger.d(
//             'Updated C1 provider to ${(volumePercent * 100).toStringAsFixed(0)}% (Deej control)',
//           );
//         } else if (channelNumber == 2) {
//           _ref.read(c2VolumeProvider.notifier).updateVolume(volumePercent);
//           SettingsBox().c2InitialVolume = volumePercent;
//           logger.d(
//             'Updated C2 provider to ${(volumePercent * 100).toStringAsFixed(0)}% (Deej control)',
//           );
//         }
//       } else {
//         // When Deej is NOT connected, directly control AudioPlayer
//         // Get the JingleManager via provider
//         final jingleManagerAsync = _ref.read(jingleManagerProvider);
//         await jingleManagerAsync.when(
//           data: (jingleManager) async {
//             final audioManager = jingleManager.audioManager;

//             // Update the AudioPlayer channel volume directly
//             if (channelNumber == 1) {
//               await audioManager.channel1.setVolume(volumePercent);
//               _ref.read(c1VolumeProvider.notifier).updateVolume(volumePercent);
//               // Persist the volume setting
//               SettingsBox().c1InitialVolume = volumePercent;
//               logger.d(
//                 'Set AudioPlayer Channel 1 volume to ${(volumePercent * 100).toStringAsFixed(0)}% (UI control)',
//               );
//             } else if (channelNumber == 2) {
//               await audioManager.channel2.setVolume(volumePercent);
//               _ref.read(c2VolumeProvider.notifier).updateVolume(volumePercent);
//               // Persist the volume setting
//               SettingsBox().c2InitialVolume = volumePercent;
//               logger.d(
//                 'Set AudioPlayer Channel 2 volume to ${(volumePercent * 100).toStringAsFixed(0)}% (UI control)',
//               );
//             }
//           },
//           loading: () async {
//             logger.w(
//               'JingleManager not yet initialized, cannot update AudioPlayer channel volume',
//             );
//           },
//           error: (error, stackTrace) async {
//             logger.e(
//               'Error accessing JingleManager for AudioPlayer channel update: $error',
//             );
//           },
//         );
//       }
//     } catch (e) {
//       logger.e('Error updating AudioPlayer channel $channelNumber volume: $e');
//     }
//   }

//   /// Initialize the mixer manager
//   Future<void> initialize() async {
//     if (!PlatformUtils.isWindows) return;
//     try {
//       await _mixerManager.initialize();
//       logger.d('VolumeControlService initialized');
//     } catch (e) {
//       logger.e('Error initializing VolumeControlService: $e');
//     }
//   }
// }

// /// Provider for the volume control service
// final volumeControlServiceProvider = Provider<VolumeControlService>((ref) {
//   final service = VolumeControlService(ref);
//   // Initialize the service when first accessed
//   service.initialize();
//   return service;
// });

// // Contains AI-generated edits.
