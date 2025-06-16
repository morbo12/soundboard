import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/volume_providers.dart';
import 'package:soundboard/core/providers/deej_providers.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/utils/platform_utils.dart';

/// Service that manages volume updates for both Windows audio mixer and UI sliders
class VolumeControlService {
  final Logger logger = const Logger('VolumeControlService');
  final MixerManager _mixerManager = MixerManager();
  final Ref _ref;

  VolumeControlService(this._ref);

  /// Updates volume for a mapped process or UI slider
  ///
  /// [deejSliderIdx] - The index of the Deej slider (0-3)
  /// [volumePercent] - Volume as percentage (0.0 to 1.0)
  Future<void> updateVolumeFromDeej(
    int deejSliderIdx,
    double volumePercent,
  ) async {
    if (!PlatformUtils.isWindows) return;

    try {
      // Get the mapping for this Deej slider
      final mapping = SettingsBox().getMappingForDeejSlider(deejSliderIdx);

      if (mapping == null) {
        logger.d('No mapping found for Deej slider $deejSliderIdx');
        return;
      }

      // Update the corresponding UI slider provider
      await _updateUISlider(mapping.uiSliderIdx, volumePercent);

      // If there's a process mapping, also update the Windows mixer
      if (mapping.processName.isNotEmpty) {
        await _updateProcessVolume(mapping.processName, volumePercent);
      }

      logger.d(
        'Updated volume for Deej slider $deejSliderIdx -> UI slider ${mapping.uiSliderIdx}, '
        'process: ${mapping.processName}, volume: ${(volumePercent * 100).toStringAsFixed(0)}%',
      );
    } catch (e) {
      logger.e('Error updating volume from Deej: $e');
    }
  }

  /// Updates volume from UI slider interaction
  ///
  /// [uiSliderIdx] - The UI slider index (0=Master, 1=P1, 2=P2, 3=P3)
  /// [volumePercent] - Volume as percentage (0.0 to 1.0)
  Future<void> updateVolumeFromUI(int uiSliderIdx, double volumePercent) async {
    if (!PlatformUtils.isWindows) return;

    try {
      // Check if Deej is connected
      final isDeejConnected = _ref.read(deejConnectionStatusProvider);

      // Always update the UI slider provider
      await _updateUISlider(uiSliderIdx, volumePercent);

      // If Deej is NOT connected, also handle Windows mixer updates
      if (!isDeejConnected) {
        // Find if this UI slider has any process mappings
        final mappings = SettingsBox().sliderMappings
            .where((m) => m.uiSliderIdx == uiSliderIdx)
            .toList();

        // Update all mapped processes
        for (final mapping in mappings) {
          if (mapping.processName.isNotEmpty) {
            await _updateProcessVolume(mapping.processName, volumePercent);
          }
        }

        // Special handling for Master slider (idx 0) - update master volume
        if (uiSliderIdx == 0) {
          await _updateMasterVolume(volumePercent);
        }

        logger.d(
          'Updated volume from UI slider $uiSliderIdx (Deej disconnected): '
          'volume: ${(volumePercent * 100).toStringAsFixed(0)}%, '
          'mapped processes: ${mappings.map((m) => m.processName).join(", ")}',
        );
      }
    } catch (e) {
      logger.e('Error updating volume from UI: $e');
    }
  }

  /// Updates the appropriate UI slider provider
  Future<void> _updateUISlider(int uiSliderIdx, double volumePercent) async {
    switch (uiSliderIdx) {
      case 0: // Master
        _ref.read(mainVolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().mainVolume = volumePercent;
        break;
      case 1: // P1
        _ref.read(p1VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().p1Volume = volumePercent;
        break;
      case 2: // P2
        _ref.read(p2VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().p2Volume = volumePercent;
        break;
      case 3: // P3
        _ref.read(p3VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().p3Volume = volumePercent;
        break;
      default:
        logger.w('Unknown UI slider index: $uiSliderIdx');
    }
  }

  /// Updates volume for a specific process in Windows audio mixer
  Future<void> _updateProcessVolume(
    String processName,
    double volumePercent,
  ) async {
    try {
      // Special handling for master volume
      if (processName.toLowerCase() == 'master') {
        await _updateMasterVolume(volumePercent);
        return;
      }

      // Get all processes and find matching ones
      final mixerList = await _mixerManager.getMixerList();
      final matchingProcesses = mixerList
          .where(
            (process) => process.processPath.toLowerCase().contains(
              processName.toLowerCase(),
            ),
          )
          .toList();

      // Update volume for all matching processes
      for (final process in matchingProcesses) {
        await _mixerManager.setApplicationVolume(
          process.processId,
          volumePercent,
        );
        logger.d(
          'Set volume for process ${process.processPath} (ID: ${process.processId}) '
          'to ${(volumePercent * 100).toStringAsFixed(0)}%',
        );
      }

      if (matchingProcesses.isEmpty) {
        logger.d('No running processes found matching "$processName"');
      }
    } catch (e) {
      logger.e('Error updating process volume for $processName: $e');
    }
  }

  /// Updates the Windows master volume
  Future<void> _updateMasterVolume(double volumePercent) async {
    try {
      await _mixerManager.setMasterVolume(volumePercent);
      logger.d(
        'Set master volume to ${(volumePercent * 100).toStringAsFixed(0)}%',
      );
    } catch (e) {
      logger.e('Error updating master volume: $e');
    }
  }

  /// Initialize the mixer manager
  Future<void> initialize() async {
    if (!PlatformUtils.isWindows) return;
    try {
      await _mixerManager.initialize();
      logger.d('VolumeControlService initialized');
    } catch (e) {
      logger.e('Error initializing VolumeControlService: $e');
    }
  }
}

/// Provider for the volume control service
final volumeControlServiceProvider = Provider<VolumeControlService>((ref) {
  final service = VolumeControlService(ref);
  // Initialize the service when first accessed
  service.initialize();
  return service;
});

// Contains AI-generated edits.
