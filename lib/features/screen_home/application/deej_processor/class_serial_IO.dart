// filepath: c:\Users\lars\flutter_code\soundboard_new\lib\features\screen_home\application\deej_processor\class_serial_IO.dart
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/deej_processor_service.dart';

/// Legacy SerialIO class - now delegates to DeejProcessorService
/// This class maintains backward compatibility while using the new service architecture
class SerialIO {
  final Logger logger = const Logger('SerialIO');
  final DeejProcessorService _deejProcessorService;

  SerialIO({required DeejProcessorService deejProcessorService})
    : _deejProcessorService = deejProcessorService;

  /// Process a line of serial data
  void handleLine(String line) {
    _deejProcessorService.processLine(line);
  }

  /// Get current slider values
  List<double> get currentSliderPercentValues =>
      _deejProcessorService.sliderValues;

  /// Get number of detected sliders
  int get lastKnownNumSliders => _deejProcessorService.numSliders;

  /// Dispose of resources
  void dispose() {
    // Disposal is handled by the service provider
    logger.d('SerialIO: Dispose called (handled by service)');
  }
}

// Contains AI-generated edits.
