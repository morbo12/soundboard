import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager.dart';
import 'package:soundboard/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/properties.dart';
import 'package:win32audio/win32audio.dart';

class SerialIO {
  // Logger instance - using logger package for Flutter
  final Logger logger = const Logger('SerialIO');

  // Configuration class reference
  final DeejConfig config;
  final Ref ref;

  // State variables
  int lastKnownNumSliders = 0;
  List<double> currentSliderPercentValues = [];
  final MixerManager _mixerManager = MixerManager();
  List<ProcessVolume> mixerList = [];

  // Regular expression for validating input lines
  static final RegExp expectedLinePattern = RegExp(
    r'^\d{0,4}\|\d{0,4}\|\d{0,4}\|\d{0,4}$',
  );

  SerialIO({required this.config, required this.ref});

  void handleLine(String line) {
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

      // Validate first number's range
      if (sliderIdx == 0 && number > 1023) {
        logger.d('Got malformed line from serial, ignoring: $line');
        return;
      }

      // Convert to normalized float (0.0 to 1.0)
      double dirtyFloat = number / 1023.0;

      // Normalize the scalar to 2 decimal places
      double normalizedScalar = _normalizeScalar(dirtyFloat);

      // Invert if configured
      if (config.invertSliders) {
        normalizedScalar = 1.0 - normalizedScalar;
      }

      // Check if the change is significant
      if (_isSignificantlyDifferent(
        currentSliderPercentValues[sliderIdx],
        normalizedScalar,
        config.noiseReductionLevel,
      )) {
        // Update current value and create move event
        currentSliderPercentValues[sliderIdx] = normalizedScalar;
        _updateSliderProvider(sliderIdx, normalizedScalar);
      }
    }
  }

  // Helper function to normalize scalar to 2 decimal places
  double _normalizeScalar(double value) {
    return (value * 100).round() / 100;
  }

  // Helper function to check if the difference is significant
  bool _isSignificantlyDifferent(
    double currentValue,
    double newValue,
    double threshold,
  ) {
    return (currentValue - newValue).abs() > threshold;
  }

  // Method to get current slider values
  List<double> getCurrentSliderValues() {
    return List.from(currentSliderPercentValues);
  }

  // Method to update a specific slider's value
  void updateSliderValue(int sliderId, double value) {
    if (sliderId >= 0 && sliderId < currentSliderPercentValues.length) {
      currentSliderPercentValues[sliderId] = value;
      logger.d('Updated slider $sliderId to $value');
    }
  }

  // Method to update slider provider
  Future<void> _updateSliderProvider(
    int sliderIdx,
    double normalizedScalar,
  ) async {
    final mapping = SettingsBox().getMappingForDeejSlider(sliderIdx);
    mixerList = await _mixerManager.getMixerList();
    if (mapping == null) return;
    logger.d("Slider $sliderIdx is mapped to ${mapping.uiSliderIdx}");

    // Handle master volume case
    if (mapping.uiSliderIdx == 0) {
      await _mixerManager.setMasterVolume(normalizedScalar);
      ref.read(mainVolumeProvider.notifier).updateVolume(normalizedScalar);
      return;
    }

    // Handle process volume cases
    final process = mixerList.firstWhere(
      (element) =>
          element.processPath?.toLowerCase().endsWith(
            mapping.processName.toLowerCase(),
          ) ??
          false,
      orElse: () => ProcessVolume(),
    );

    if (process.processId != null) {
      await _mixerManager.setApplicationVolume(
        process.processId!,
        normalizedScalar,
      );
      logger.d(
        'Updated process ${process.processPath} (ID: ${process.processId}) to volume: $normalizedScalar',
      );
    } else {
      logger.d('Could not find process: ${mapping.processName}');
    }

    // Update the appropriate volume provider
    switch (mapping.uiSliderIdx) {
      case 1:
        ref.read(p1VolumeProvider.notifier).updateVolume(normalizedScalar);
        break;
      case 2:
        ref.read(p2VolumeProvider.notifier).updateVolume(normalizedScalar);
        break;
      case 3:
        ref.read(p3VolumeProvider.notifier).updateVolume(normalizedScalar);
        break;
    }
  }
}

// Configuration class
class DeejConfig {
  final bool invertSliders;
  final bool verbose;
  final double noiseReductionLevel;

  DeejConfig({
    this.invertSliders = false,
    this.verbose = false,
    this.noiseReductionLevel = 0.02,
  });
}
