import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win32audio/win32audio.dart';
import 'package:soundboard/core/utils/platform_utils.dart';

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

  SerialIO({required this.config, required this.ref}) {
    if (PlatformUtils.isWindows) {
      _initialize();
    } else {
      logger.d(
        'SerialIO: Windows-specific features not available on this platform',
      );
    }
  }

  Future<void> _initialize() async {
    if (!PlatformUtils.isWindows) return;
    await _mixerManager.initialize();
    mixerList = await _mixerManager.getMixerList();
  }

  void handleLine(String line) {
    if (!PlatformUtils.isWindows) return;
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

      // Convert to percentage (0-100)
      double percent = number / 1023.0;
      if (percent < 0) percent = 0;
      if (percent > 1) percent = 1;

      // Only update if the value has changed significantly
      if ((currentSliderPercentValues[sliderIdx] - percent).abs() > 0.01) {
        currentSliderPercentValues[sliderIdx] = percent;
        _updateVolume(sliderIdx, percent);
      }
    }
  }

  void _updateVolume(int sliderIdx, double percent) {
    if (!PlatformUtils.isWindows) return;
    try {
      // Get the process ID for this slider from config
      int processId = config.getProcessIdForSlider(sliderIdx);
      if (processId != -1) {
        _mixerManager.setApplicationVolume(processId, percent);
        logger.d(
          'Set volume for process $processId to ${(percent * 100).toStringAsFixed(0)}%',
        );
      }
    } catch (e) {
      logger.e('Error updating volume: $e');
    }
  }

  void dispose() {
    if (!PlatformUtils.isWindows) return;
    // Clean up any resources if needed
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

  int getProcessIdForSlider(int sliderIdx) {
    // Implementation of getProcessIdForSlider method
    // This is a placeholder and should be implemented based on your specific requirements
    return -1; // Placeholder return, actual implementation needed
  }
}
