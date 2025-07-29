import 'dart:async';
import 'package:serial_port_win32/serial_port_win32.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/class_serial_processor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/utils/platform_utils.dart';

class SerialPortManagerWin32 {
  final Logger logger = const Logger('SerialPortManagerWin32');
  SerialProcessor? _serialProcessor;
  final Ref ref;

  // Static reference to current instance for hot reload cleanup
  static SerialPortManagerWin32? _currentInstance;

  // Serial port state
  List<PortInfo> portList = [];
  SerialPort? _serialPort;
  bool _isSerialConnected = false;
  bool _isSerialReconnecting = false;
  bool _explicitlyDisconnected = false;
  // Timers
  Timer? _serialReconnectTimer;
  static const int _serialReconnectIntervalSeconds = 5;

  SerialPortManagerWin32({required this.ref}) {
    // Dispose any previous instance during hot reload
    _currentInstance?.dispose();
    _currentInstance = this;

    if (PlatformUtils.isWindows) {
      // Initialize asynchronously - initialization will happen when needed
      _initSerialPort();
    } else {
      logger.d(
        'SerialPortManagerWin32: Windows-specific features not available on this platform',
      );
    }
  }

  /// Initialize the serial processor with proper async setup
  Future<void> _initializeSerialProcessor() async {
    if (_serialProcessor != null) return; // Already initialized

    try {
      _serialProcessor = SerialProcessor(ref);
      await _serialProcessor!.initialize();
      logger.i(
        'SerialPortManagerWin32: SerialProcessor initialized successfully',
      );
    } catch (e) {
      logger.e(
        'SerialPortManagerWin32: Failed to initialize SerialProcessor: $e',
      );
    }
  }

  void _initSerialPort() {
    if (!PlatformUtils.isWindows) return;
    // Find available ports
    _refreshPortList();

    // Connect to the port if auto-connect is enabled
    if (SettingsBox().serialAutoConnect &&
        SettingsBox().serialPortName.isNotEmpty) {
      connectToSerialPort();
    }
  }

  void _refreshPortList() {
    if (!PlatformUtils.isWindows) return;
    try {
      portList = SerialPort.getPortsWithFullMessages();
      logger.d('Found ${portList.length} serial ports');
    } catch (e) {
      logger.d('Error refreshing port list: $e');
      portList = [];
    }
  }

  void connectToSerialPort() {
    if (!PlatformUtils.isWindows) return;
    final portName = SettingsBox().serialPortName;
    PortInfo? targetPort;

    try {
      targetPort = portList.firstWhere((port) => port.portName == portName);
    } catch (e) {
      // If no matching port is found, use the first available port or null
      logger.d(
        'Configured port $portName not found, falling back to first available port',
      );
      targetPort = portList.isNotEmpty ? portList.first : null;
    }

    if (targetPort != null) {
      _serialPort = SerialPort(
        targetPort.portName,
        openNow: false,
        ByteSize: SettingsBox().serialDataBits,
        BaudRate: SettingsBox().serialBaudRate,
      );
      _openSerialPort();
    } else {
      logger.d('No suitable serial port found for connection');
      _startSerialReconnectTimer();
    }
  }

  void _startSerialReconnectTimer() {
    if (!PlatformUtils.isWindows) return;
    if (_isSerialReconnecting || _explicitlyDisconnected) return;

    _isSerialReconnecting = true;
    _serialReconnectTimer = Timer.periodic(
      const Duration(seconds: _serialReconnectIntervalSeconds),
      (timer) {
        if (!_isSerialConnected && !_explicitlyDisconnected) {
          logger.d('Attempting to reconnect to serial port...');
          _refreshPortList();
          connectToSerialPort();
        } else {
          _serialReconnectTimer?.cancel();
          _isSerialReconnecting = false;
        }
      },
    );
  }

  void _openSerialPort() {
    if (!PlatformUtils.isWindows) return;
    if (_serialPort == null || _isSerialConnected) return;

    try {
      _serialPort!.open();

      if (_serialPort!.isOpened) {
        _isSerialConnected = true;
        _isSerialReconnecting = false;
        logger.d('${_serialPort!.portName} opened!');

        // Initialize the serial processor before starting to listen
        _initializeSerialProcessor()
            .then((_) {
              // Start listening for data after processor is initialized
              _startListening();
            })
            .catchError((error) {
              logger.e('Failed to initialize serial processor: $error');
              _handleSerialDisconnect();
            });
      } else {
        logger.d('Failed to open serial port');
        _handleSerialDisconnect();
      }
    } catch (e) {
      logger.d('Error opening serial port: $e');
      _handleSerialDisconnect();
    }
  }

  void _startListening() {
    if (!PlatformUtils.isWindows) return;
    if (_serialPort == null || !_serialPort!.isOpened) return;

    // Start a periodic timer to read data
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      if (!_serialPort!.isOpened) {
        timer.cancel();
        return;
      }

      try {
        final data = await _serialPort!.readBytes(
          1024,
          timeout: const Duration(milliseconds: 50),
        );
        if (data.isNotEmpty) {
          _serialProcessor?.processStream(Stream.value(data));
        }
      } catch (e) {
        logger.d('Error reading from serial port: $e');
        _handleSerialDisconnect();
      }
    });
  }

  void _handleSerialDisconnect() {
    if (!PlatformUtils.isWindows) return;
    _isSerialConnected = false;
    _startSerialReconnectTimer();
  }

  void closeSerialPort() {
    if (!PlatformUtils.isWindows) return;
    if (_serialPort != null && _serialPort!.isOpened) {
      try {
        _serialPort!.close();
        logger.d('${_serialPort!.portName} closed!');
      } catch (e) {
        logger.d('Error closing serial port: $e');
      } finally {
        _isSerialConnected = false;
        _explicitlyDisconnected = true;
      }
    }
  }

  bool get isConnected => PlatformUtils.isWindows ? _isSerialConnected : false;

  void dispose() {
    if (!PlatformUtils.isWindows) return;
    _serialReconnectTimer?.cancel();
    closeSerialPort();

    // Clear static reference if this is the current instance
    if (_currentInstance == this) {
      _currentInstance = null;
    }
  }

  // Public methods for connection control
  void connect() {
    if (!PlatformUtils.isWindows) return;
    if (!_isSerialConnected) {
      _explicitlyDisconnected = false;
      connectToSerialPort();
    }
  }

  void disconnect() {
    if (!PlatformUtils.isWindows) return;
    if (_isSerialConnected) {
      _explicitlyDisconnected = true;
      closeSerialPort();
    }
  }
}
