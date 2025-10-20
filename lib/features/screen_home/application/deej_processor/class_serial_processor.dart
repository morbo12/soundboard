import 'dart:convert';
import 'dart:typed_data';
import 'package:soundboard/features/screen_home/application/deej_processor/class_serial_IO.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/deej_processor_service.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SerialProcessor {
  // Buffer to accumulate incoming data
  StringBuffer _buffer = StringBuffer();
  // Binary data buffer for protocol detection and parsing
  List<int> _binaryBuffer = [];
  final Logger logger = const Logger('SerialProcessor');

  // Protocol detection state
  bool _isBinaryProtocol = false;
  bool _protocolDetected = false;

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
        // Auto-detect protocol if not yet determined
        if (!_protocolDetected) {
          _binaryBuffer.addAll(data);
          _detectProtocol();
        }

        // Route to appropriate processor based on detected protocol
        if (_protocolDetected) {
          if (_isBinaryProtocol) {
            // For binary protocol, always add new data to binary buffer
            _binaryBuffer.addAll(data);
            _processBinaryData();
          } else {
            // For text protocol, process data directly (no need for binary buffer)
            _processTextData(data);
          }
        }
      },
      onError: (error) {
        logger.e('Error: $error');
      },
      onDone: () {
        // Handle any remaining data in buffers if needed
        if (_buffer.isNotEmpty) {
          logger.d('Remaining text data: ${_buffer.toString()}');
        }
        if (_binaryBuffer.isNotEmpty) {
          logger.d('Remaining binary data: ${_binaryBuffer.length} bytes');
        }
      },
    );
  }

  /// Detect whether incoming data is binary or text protocol
  void _detectProtocol() {
    // Need at least 2 bytes to detect binary protocol header (0x85 0xA7)
    if (_binaryBuffer.length >= 2) {
      if (_binaryBuffer[0] == 0x85 && _binaryBuffer[1] == 0xA7) {
        _isBinaryProtocol = true;
        logger.i(
          'SerialProcessor: Detected binary protocol - using binary decoder',
        );
      } else {
        _isBinaryProtocol = false;
        logger.i(
          'SerialProcessor: Detected text protocol - using text decoder',
        );
        // Clear binary buffer since we won't need it for text protocol
        _binaryBuffer.clear();
      }
      _protocolDetected = true;
    }
  }

  /// Process text-based data (existing format)
  void _processTextData(Uint8List data) {
    String utf = asciiDecoder.convert(data);

    // Append new data to buffer
    _buffer.write(utf);

    // Check if buffer contains the EOL character
    while (_buffer.toString().contains('\n')) {
      // Split at first newline character
      var parts = _buffer.toString().split('\n');
      // Get the complete message (everything before the newline)
      String completeMessage = parts[0].trim();

      // Process the complete message
      _serialIO!.handleLine(completeMessage);

      // Update buffer with remaining data (if any)
      _buffer.clear();
      if (parts.length > 1) {
        _buffer.write(parts.sublist(1).join('\n'));
      }
    }
  }

  /// Process binary protocol data
  void _processBinaryData() {
    // Process complete binary messages
    while (_hasBinaryMessage()) {
      final message = _extractBinaryMessage();
      if (message != null) {
        _parseBinaryMessage(message);
      }
    }
  }

  /// Check if we have a complete binary message
  bool _hasBinaryMessage() {
    // Look for message termination (0x0D 0x0A)
    for (int i = 0; i < _binaryBuffer.length - 1; i++) {
      if (_binaryBuffer[i] == 0x0D && _binaryBuffer[i + 1] == 0x0A) {
        return true;
      }
    }

    // Debug: Show buffer contents if we can't find termination
    if (_binaryBuffer.length > 20) {
      final hexStr = _binaryBuffer
          .take(20)
          .map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}')
          .join(' ');
      logger.d(
        'SerialProcessor: No termination found in ${_binaryBuffer.length} bytes. First 20 bytes: $hexStr',
      );
    }

    return false;
  }

  /// Extract a complete binary message from buffer
  List<int>? _extractBinaryMessage() {
    // Find message end (0x0D 0x0A)
    for (int i = 0; i < _binaryBuffer.length - 1; i++) {
      if (_binaryBuffer[i] == 0x0D && _binaryBuffer[i + 1] == 0x0A) {
        // Extract message including termination
        final message = _binaryBuffer.sublist(0, i + 2);
        // Remove processed data from buffer
        _binaryBuffer = _binaryBuffer.sublist(i + 2);
        return message;
      }
    }
    return null;
  }

  /// Parse binary protocol message
  void _parseBinaryMessage(List<int> message) {
    logger.d(
      'SerialProcessor: Parsing binary message of ${message.length} bytes',
    );

    // Skip header bytes (0x85 0xA7) if present
    int pos = 0;
    if (message.length >= 2 && message[0] == 0x85 && message[1] == 0xA7) {
      pos = 2;
    }

    String textPart = '';
    Map<String, double> sliderValues = {};
    String currentSlider = '';

    while (pos < message.length - 2) {
      // -2 for termination bytes
      int byte = message[pos];

      // Check for separator (0xA7) or value bytes
      if (byte == 0xA7) {
        // Separator - process accumulated text
        if (textPart.isNotEmpty && currentSlider.isNotEmpty) {
          // Previous slider is complete, reset for next
          textPart = '';
          currentSlider = '';
        }
        pos++;
      } else if (byte >= 0x20 && byte <= 0x7E) {
        // ASCII printable character - part of slider name
        textPart += String.fromCharCode(byte);

        // Check if we have a complete slider identifier
        if (textPart.startsWith('slider') && textPart.length > 6) {
          final sliderMatch = RegExp(r'slider(\d+)').firstMatch(textPart);
          if (sliderMatch != null) {
            currentSlider = 'slider${sliderMatch.group(1)}';
            // Reset text part to prepare for next element
            textPart = '';
          }
        }
        pos++;
      } else {
        // Value byte(s)
        if (currentSlider.isNotEmpty) {
          double value = _decodeValue(message, pos);
          int bytesConsumed = _getValueBytesConsumed(message, pos);

          sliderValues[currentSlider] = value;
          logger.d('SerialProcessor: $currentSlider = $value');

          pos += bytesConsumed;
          currentSlider = ''; // Reset for next slider
        } else {
          pos++; // Skip unknown byte
        }
      }
    }

    // Send parsed values to SerialIO
    if (sliderValues.isNotEmpty) {
      _sendSliderValues(sliderValues);
    }
  }

  /// Decode value from binary data starting at position
  double _decodeValue(List<int> data, int pos) {
    if (pos >= data.length) return 0.0;

    int value = data[pos];

    // Check for extended encoding (0xCD prefix)
    if (value == 0xCD && pos + 2 < data.length) {
      // Extended 16-bit encoding: CD + high byte + low byte
      int high = data[pos + 1];
      int low = data[pos + 2];
      value = (high << 8) | low;
      logger.d(
        'SerialProcessor: Extended encoding - high:$high low:$low value:$value',
      );
    }

    // Convert to 0.0-1.0 range (assuming max value is 1023)
    return value / 1023.0;
  }

  /// Get number of bytes consumed for value at position
  int _getValueBytesConsumed(List<int> data, int pos) {
    if (pos >= data.length) return 1;

    // Check for extended encoding (0xCD prefix)
    if (data[pos] == 0xCD) {
      return 3; // CD + high byte + low byte
    }
    return 1; // Simple single byte
  }

  /// Send slider values to SerialIO in text format
  void _sendSliderValues(Map<String, double> sliderValues) {
    // DeejProcessorService expects format: "19|0|0|6" (values 0-100, pipe-separated)
    // Convert from 0.0-1.0 range to 0-100 range and sort by slider number

    // Sort sliders by number (slider1, slider2, etc.)
    final sortedEntries = sliderValues.entries.toList()
      ..sort((a, b) {
        final aNum = int.tryParse(a.key.replaceAll('slider', '')) ?? 0;
        final bNum = int.tryParse(b.key.replaceAll('slider', '')) ?? 0;
        return aNum.compareTo(bNum);
      });

    // Convert to expected format: just values 0-100 separated by pipes
    final formattedValues = sortedEntries
        .map((e) => (e.value * 100).round().toString())
        .join('|');

    logger.d('SerialProcessor: Sending formatted values: $formattedValues');
    _serialIO!.handleLine(formattedValues);
  }
}

// Contains AI-generated edits.
