import 'dart:async';

import 'package:soundboard/utils/logger.dart';

class SerialIO {
  // Logger instance - using logger package for Flutter
  final Logger logger = const Logger('SerialIO');

  // Configuration class reference
  final DeejConfig config;

  // State variables
  int lastKnownNumSliders = 0;
  List<double> currentSliderPercentValues = [];

  // Stream controllers for slider move events
  final List<StreamController<SliderMoveEvent>> _sliderMoveControllers = [];

  // Regular expression for validating input lines
  static final RegExp expectedLinePattern = RegExp(
    r'^\d{1,4}\|\d{1,4}\|\d{1,4}\|\d{1,4}$',
  );

  SerialIO({required this.config});

  void handleLine(String line) {
    // Validate the input line format
    if (!expectedLinePattern.hasMatch(line)) {
      logger.d('Malformed line from serial, ignoring: $line');
      return;
    }

    // Trim CRLF from the line
    line = line.trimRight();

    // Split on pipe (|) to get slider values
    List<String> splitLine = line.split('|');
    int numSliders = splitLine.length;

    // Update slider count if needed
    if (numSliders != lastKnownNumSliders) {
      logger.i('Detected sliders: $numSliders');
      lastKnownNumSliders = numSliders;
      currentSliderPercentValues = List.filled(numSliders, -1.0);
    }

    // Process slider values and generate move events
    List<SliderMoveEvent> moveEvents = [];

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

        final moveEvent = SliderMoveEvent(
          sliderId: sliderIdx,
          percentValue: normalizedScalar,
        );

        moveEvents.add(moveEvent);

        if (config.verbose) {
          logger.d('Slider moved: $moveEvent');
        }
      }
    }

    // Broadcast move events to all listeners
    if (moveEvents.isNotEmpty) {
      for (var controller in _sliderMoveControllers) {
        for (var moveEvent in moveEvents) {
          controller.add(moveEvent);
        }
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

  // Method to add new slider move listener
  StreamSubscription<SliderMoveEvent> addSliderMoveListener(
    void Function(SliderMoveEvent) onMove,
  ) {
    final controller = StreamController<SliderMoveEvent>();
    _sliderMoveControllers.add(controller);
    return controller.stream.listen(onMove);
  }

  // Cleanup method
  void dispose() {
    for (var controller in _sliderMoveControllers) {
      controller.close();
    }
    _sliderMoveControllers.clear();
  }
}

// Data class for slider move events
class SliderMoveEvent {
  final int sliderId;
  final double percentValue;

  SliderMoveEvent({required this.sliderId, required this.percentValue});

  @override
  String toString() =>
      'SliderMoveEvent(sliderId: $sliderId, percentValue: $percentValue)';
}

// Configuration class
class DeejConfig {
  final bool invertSliders;
  final bool verbose;
  final double noiseReductionLevel;

  DeejConfig({
    this.invertSliders = false,
    this.verbose = false,
    this.noiseReductionLevel = 0.01,
  });
}
