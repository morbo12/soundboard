import 'package:soundboard/core/providers/volume_providers.dart';
import 'package:soundboard/core/providers/deej_providers.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/utils/platform_utils.dart';
import 'package:soundboard/core/models/volume_system_config.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';

/// New Volume Control Service with separated Deej connected/disconnected logic
class VolumeControlServiceV2 {
  final Logger logger = const Logger('VolumeControlServiceV2');
  final MixerManager _mixerManager = MixerManager();
  final dynamic _ref; // Accept either WidgetRef or Ref<Object?>

  VolumeControlServiceV2(this._ref);

  /// Updates volume from UI slider interaction
  /// This is called when user moves sliders in the UI
  Future<void> updateVolumeFromUI(int uiSliderIdx, double volumePercent) async {
    if (!PlatformUtils.isWindows) return;

    try {
      final isDeejConnected = _ref.read(deejConnectionStatusProvider);

      if (isDeejConnected) {
        // When Deej is connected, UI sliders should not control anything directly
        // Only update the provider for visual feedback
        await _updateUISliderProvider(uiSliderIdx, volumePercent);
        logger.d(
          'UI slider $uiSliderIdx updated for visual feedback only (Deej connected)',
        );
      } else {
        // When Deej is disconnected, use the UI slider configuration
        await _handleUISliderWhenDeejDisconnected(uiSliderIdx, volumePercent);
      }
    } catch (e) {
      logger.e('Error updating volume from UI: $e');
    }
  }

  /// Updates volume from Deej hardware
  /// This is called when Deej hardware sends volume updates
  Future<void> updateVolumeFromDeej(
    int deejSliderIdx,
    double volumePercent,
  ) async {
    if (!PlatformUtils.isWindows) return;

    try {
      final config = SettingsBox().volumeSystemConfig;

      // Find the mapping for this Deej slider
      final mapping = config.deejMappings
          .where((m) => m.deejSliderIdx == deejSliderIdx)
          .firstOrNull;

      if (mapping == null) {
        logger.d('No mapping found for Deej slider $deejSliderIdx');
        return;
      }

      await _handleDeejMapping(mapping, volumePercent);

      logger.d(
        'Updated volume from Deej slider $deejSliderIdx -> ${mapping.target.displayName}, '
        'volume: ${(volumePercent * 100).toStringAsFixed(0)}%',
      );
    } catch (e) {
      logger.e('Error updating volume from Deej: $e');
    }
  }

  /// Handles UI slider changes when Deej is disconnected
  Future<void> _handleUISliderWhenDeejDisconnected(
    int uiSliderIdx,
    double volumePercent,
  ) async {
    // Update the provider first
    await _updateUISliderProvider(uiSliderIdx, volumePercent);

    // Handle based on slider type
    switch (uiSliderIdx) {
      case 0: // Master
        await _updateMasterVolume(volumePercent);
        logger.d(
          'Updated master volume from UI: ${(volumePercent * 100).toStringAsFixed(0)}%',
        );
        break;
      case 4: // AudioPlayer C1
      case 5: // AudioPlayer C2
        // C1/C2 UI sliders are for visualization only when Deej disconnected
        // AudioPlayer channels will use max volume when playing
        logger.d(
          'AudioPlayer channel ${uiSliderIdx == 4 ? 'C1' : 'C2'} slider updated for visualization only',
        );
        break;
      default:
        logger.d('UI slider $uiSliderIdx has no action when Deej disconnected');
    }
  }

  /// Handles a Deej mapping action
  Future<void> _handleDeejMapping(
    DeejHardwareMapping mapping,
    double volumePercent,
  ) async {
    switch (mapping.target) {
      case DeejTarget.master:
        await _updateUISliderProvider(
          0,
          volumePercent,
        ); // Update Master provider
        await _updateMasterVolume(volumePercent);
        break;

      case DeejTarget.externalProcess:
        if (mapping.processName != null && mapping.processName!.isNotEmpty) {
          await _updateProcessVolume(mapping.processName!, volumePercent);
        }
        break;

      case DeejTarget.audioPlayerC1:
        logger.d(
          'Deej mapping: Updating AudioPlayer C1 to ${(volumePercent * 100).toStringAsFixed(0)}%',
        );
        await _updateAudioPlayerChannel(1, volumePercent);
        break;

      case DeejTarget.audioPlayerC2:
        logger.d(
          'Deej mapping: Updating AudioPlayer C2 to ${(volumePercent * 100).toStringAsFixed(0)}%',
        );
        await _updateAudioPlayerChannel(2, volumePercent);
        break;
    }
  }

  /// Updates the UI slider provider for visual feedback
  Future<void> _updateUISliderProvider(
    int uiSliderIdx,
    double volumePercent,
  ) async {
    switch (uiSliderIdx) {
      case 0: // Master
        _ref.read(mainVolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().mainVolume = volumePercent;
        break;
      case 4: // AudioPlayer Channel 1
        _ref.read(c1VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().c1InitialVolume = volumePercent;
        break;
      case 5: // AudioPlayer Channel 2
        _ref.read(c2VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().c2InitialVolume = volumePercent;
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

  /// Updates the volume for a specific AudioPlayer channel
  Future<void> _updateAudioPlayerChannel(
    int channelNumber,
    double volumePercent,
  ) async {
    try {
      // Always update the provider for AudioPlayer channels when controlled by Deej
      if (channelNumber == 1) {
        _ref.read(c1VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().c1InitialVolume = volumePercent;
      } else if (channelNumber == 2) {
        _ref.read(c2VolumeProvider.notifier).updateVolume(volumePercent);
        SettingsBox().c2InitialVolume = volumePercent;
      }

      // Update the actual AudioPlayer volume for any currently playing audio
      try {
        final audioManagerAsync = _ref.read(audioManagerProvider);
        if (audioManagerAsync.hasValue) {
          final audioManager = audioManagerAsync.value;
          logger.d(
            'Calling AudioManager.updateChannelVolume for C$channelNumber',
          );
          await audioManager.updateChannelVolume(
            _ref,
            channelNumber,
            volumePercent,
          );
        } else if (audioManagerAsync.isLoading) {
          logger.d(
            'AudioManager not ready (loading) - volume will be applied when audio plays',
          );
        } else if (audioManagerAsync.hasError) {
          logger.e('AudioManager error: ${audioManagerAsync.error}');
        } else {
          logger.w('AudioManager in unknown state');
        }
      } catch (e) {
        logger.w(
          'Could not update live AudioPlayer volume - will be applied on next playback: $e',
        );
      }

      logger.d(
        'Updated AudioPlayer C$channelNumber volume to ${(volumePercent * 100).toStringAsFixed(0)}%',
      );
    } catch (e) {
      logger.e('Error updating AudioPlayer channel volume: $e');
    }
  }

  /// Gets the target volume for an AudioPlayer channel
  /// Returns max volume when Deej disconnected, provider volume when connected and mapped
  double getAudioPlayerTargetVolume(int channelNumber) {
    final isDeejConnected = _ref.read(deejConnectionStatusProvider);

    if (!isDeejConnected) {
      // When Deej is disconnected, AudioPlayer channels use max volume
      return 1.0;
    } else {
      // When Deej is connected, check if channel is mapped and use provider volume
      final config = SettingsBox().volumeSystemConfig;
      final targetToCheck = channelNumber == 1
          ? DeejTarget.audioPlayerC1
          : DeejTarget.audioPlayerC2;

      final isMapped = config.deejMappings.any(
        (m) => m.target == targetToCheck,
      );

      if (isMapped) {
        // Use provider volume when mapped to Deej
        final provider = channelNumber == 1
            ? c1VolumeProvider
            : c2VolumeProvider;
        return _ref.read(provider).vol;
      } else {
        // Use max volume when Deej connected but not mapped
        return 1.0;
      }
    }
  }
}

// Contains AI-generated edits.
