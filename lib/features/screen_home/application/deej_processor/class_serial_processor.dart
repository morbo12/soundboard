import 'dart:convert';
import 'dart:typed_data';
import 'package:soundboard/features/screen_home/application/deej_processor/class_serial_IO.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SerialProcessor {
  // Buffer to accumulate incoming data
  StringBuffer _buffer = StringBuffer();
  final Logger logger = const Logger('SerialProcessor');

  final config = DeejConfig(
    invertSliders: false,
    verbose: true,
    noiseReductionLevel: 0.02,
  );
  // SerialIO instance for handling serial communication
  // and processing slider values
  late final SerialIO serialIO;
  AsciiDecoder asciiDecoder = const AsciiDecoder(allowInvalid: true);
  final Ref ref;

  SerialProcessor(this.ref) {
    serialIO = SerialIO(config: config, ref: ref);
  }

  void processStream(Stream<Uint8List> stream) {
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
          serialIO.handleLine(completeMessage);

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
