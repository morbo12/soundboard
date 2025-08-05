import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/utils/platform_utils.dart';
import 'package:soundboard/core/services/volume_control_service_v2.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/data/deej_config.dart';
import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager.dart';
import 'package:win32audio/win32audio.dart';

/// Service that handles deej processing with proper separation of concerns
class DeejProcessorService {
  final Logger logger = const Logger('DeejProcessorService');
  final VolumeControlServiceV2 _volumeControlService;
  final DeejConfig _config;
  final MixerManager _mixerManager = MixerManager();

  // State management
  int lastKnownNumSliders = 0;
  List<double> currentSliderPercentValues = [];
  List<ProcessVolume> mixerList = [];
  bool _isInitialized = false;

  // Regular expression for validating input lines
  static final RegExp expectedLinePattern = RegExp(
    r'^\d{0,4}\|\d{0,4}\|\d{0,4}\|\d{0,4}$',
  );

  DeejProcessorService({
    required VolumeControlServiceV2 volumeControlService,
    required DeejConfig config,
  }) : _volumeControlService = volumeControlService,
       _config = config;

  /// Initialize the deej processor service
  Future<void> initialize() async {
    if (!PlatformUtils.isWindows) {
      logger.d(
        'DeejProcessor: Windows-specific features not available on this platform',
      );
      return;
    }

    if (_isInitialized) {
      logger.d('DeejProcessor: Already initialized');
      return;
    }

    try {
      await _mixerManager.initialize();
      mixerList = await _mixerManager.getMixerList();
      _isInitialized = true;
      logger.i('DeejProcessor: Successfully initialized');
    } catch (e) {
      logger.e('DeejProcessor: Failed to initialize: $e');
      rethrow;
    }
  }

  /// Process a line of serial data from the deej device
  void processLine(String line) {
    if (!PlatformUtils.isWindows || !_isInitialized) return;

    // Trim CRLF from the line
    line = line.trim();

    // Validate the input line format
    if (!expectedLinePattern.hasMatch(line)) {
      logger.d('Malformed line from serial, ignoring: $line');
      return;
    }

    // Split on pipe (|) to get slider values
    List<String> splitLine = line.split('|');
    int numSliders = splitLine.length;

    // Update slider count if needed
    if (numSliders != lastKnownNumSliders) {
      logger.i('Detected sliders: $numSliders');
      lastKnownNumSliders = numSliders;
      currentSliderPercentValues = List.filled(numSliders, -1.0);
    }

    for (int sliderIdx = 0; sliderIdx < splitLine.length; sliderIdx++) {
      // Convert string value to integer
      int number;
      try {
        number = int.parse(splitLine[sliderIdx]);
      } catch (e) {
        logger.w('Failed to parse slider value: ${splitLine[sliderIdx]}');
        continue;
      }

      // Convert to percentage (0-1) from 0-100 range
      double percent = number / 100.0;
      if (percent < 0) percent = 0;
      if (percent > 1) percent = 1;

      // Apply noise reduction - only update if the value has changed significantly
      if ((currentSliderPercentValues[sliderIdx] - percent).abs() >
          _config.noiseReductionLevel) {
        currentSliderPercentValues[sliderIdx] = percent;
        _updateVolume(sliderIdx, percent);
      }
    }
  }

  /// Update volume for a specific slider
  void _updateVolume(int sliderIdx, double percent) {
    if (!PlatformUtils.isWindows || !_isInitialized) return;

    try {
      // Apply slider inversion if configured
      final adjustedPercent = _config.invertSliders ? 1.0 - percent : percent;

      // Use the volume control service to update volume from deej input
      _volumeControlService.updateVolumeFromDeej(sliderIdx, adjustedPercent);

      if (_config.verbose) {
        logger.d(
          'Updated volume for Deej slider $sliderIdx to ${(adjustedPercent * 100).toStringAsFixed(0)}%',
        );
      }
    } catch (e) {
      logger.e('Error updating volume for slider $sliderIdx: $e');
    }
  }

  /// Get current slider values
  List<double> get sliderValues =>
      List.unmodifiable(currentSliderPercentValues);

  /// Get number of detected sliders
  int get numSliders => lastKnownNumSliders;

  /// Check if the service is initialized
  bool get isInitialized => _isInitialized;

  /// Dispose of resources
  void dispose() {
    if (!PlatformUtils.isWindows) return;

    // Clean up any resources if needed
    _isInitialized = false;
    logger.d('DeejProcessor: Disposed');
  }
}

/// Provider for DeejProcessorService with proper async initialization
final deejProcessorServiceProvider = FutureProvider<DeejProcessorService>((
  ref,
) async {
  // Create VolumeControlServiceV2 instance
  final volumeControlService = VolumeControlServiceV2(ref);
  final config = ref.watch(deejConfigProvider);

  final service = DeejProcessorService(
    volumeControlService: volumeControlService,
    config: config,
  );

  await service.initialize();

  // Ensure proper disposal
  ref.onDispose(() => service.dispose());

  return service;
});

// Contains AI-generated edits.
