import 'dart:convert';
import 'dart:typed_data';
import 'package:soundboard/features/screen_home/application/deej_processor/class_serial_IO.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/deej_processor_service.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SerialProcessor {
  // Buffer to accumulate incoming data
  StringBuffer _buffer = StringBuffer();
  final Logger logger = const Logger('SerialProcessor');

  // SerialIO instance for handling serial communication
  // and processing slider values
  SerialIO? _serialIO;
  AsciiDecoder asciiDecoder = const AsciiDecoder(allowInvalid: true);
  final Ref ref;

  SerialProcessor(this.ref);

  /// Initialize with DeejProcessorService
  Future<void> initialize() async {
    try {
      final deejProcessorService = await ref.read(
        deejProcessorServiceProvider.future,
      );
      _serialIO = SerialIO(deejProcessorService: deejProcessorService);
      logger.i('SerialProcessor: Initialized with DeejProcessorService');
    } catch (e) {
      logger.e('SerialProcessor: Failed to initialize: $e');
      rethrow;
    }
  }

  void processStream(Stream<Uint8List> stream) {
    if (_serialIO == null) {
      logger.w('SerialProcessor: Not initialized, cannot process stream');
      return;
    }

    stream.listen(
      (data) {
        // Uint8List raw = data;
        String utf = asciiDecoder.convert(data);

        // Append new data to buffer
        _buffer.write(utf);

        // Check if buffer contains the EOL character
        while (_buffer.toString().contains('\n')) {
          // Split at first '#' character
          var parts = _buffer.toString().split('\n');
          // Get the complete message (everything before the '#')
          String completeMessage = parts[0].trim();
          // logger.d('Found a EOL: ${completeMessage}');

          // Process the complete message
          _serialIO!.handleLine(completeMessage);

          // Update buffer with remaining data (if any)
          _buffer.clear();
          if (parts.length > 1) {
            _buffer.write(parts.sublist(1).join('\n'));
          }
        }
      },
      onError: (error) {
        logger.e('Error: $error');
      },
      onDone: () {
        // Handle any remaining data in buffer if needed
        if (_buffer.isNotEmpty) {
          // print('Remaining unprocessed data: ${_buffer.toString()}');
        }
      },
    );
  }
}

// Contains AI-generated edits.
