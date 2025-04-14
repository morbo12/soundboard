// import 'dart:async';
// import 'package:flutter_libserialport/flutter_libserialport.dart';
// import 'package:soundboard/utils/logger.dart';
// import 'package:soundboard/properties.dart';
// import 'package:soundboard/features/screen_home/application/deej_processor/class_serial_processor.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class SerialPortManager {
//   final Logger logger = const Logger('SerialPortManager');
//   final SerialProcessor _serialProcessor;
//   final Ref ref;

//   // Serial port state
//   List<SerialPort> portList = [];
//   SerialPort? _serialPort;
//   SerialPortReader? _serialPortReader;
//   bool _isSerialConnected = false;
//   bool _isSerialReconnecting = false;

//   // Timers
//   Timer? _serialReconnectTimer;
//   static const int _serialReconnectIntervalSeconds = 5;

//   SerialPortManager({required this.ref})
//     : _serialProcessor = SerialProcessor(ref) {
//     _initSerialPort();
//   }

//   void _initSerialPort() {
//     // Find available ports
//     _refreshPortList();

//     // Connect to the port if auto-connect is enabled
//     if (SettingsBox().serialAutoConnect &&
//         SettingsBox().serialPortName.isNotEmpty) {
//       connectToSerialPort();
//     }
//   }

//   void _refreshPortList() {
//     try {
//       portList =
//           SerialPort.availablePorts.map((name) => SerialPort(name)).toList();
//       logger.d('Found ${portList.length} serial ports');
//     } catch (e) {
//       logger.d('Error refreshing port list: $e');
//       portList = [];
//     }
//   }

//   void connectToSerialPort() {
//     final portName = SettingsBox().serialPortName;
//     SerialPort? targetPort;

//     try {
//       targetPort = portList.firstWhere((port) => port.name == portName);
//     } catch (e) {
//       // If no matching port is found, use the first available port or null
//       logger.d(
//         'Configured port $portName not found, falling back to first available port',
//       );
//       targetPort = portList.isNotEmpty ? portList.first : null;
//     }

//     if (targetPort != null) {
//       _serialPort = targetPort;
//       _openSerialPort();
//     } else {
//       logger.d('No suitable serial port found for connection');
//       _startSerialReconnectTimer();
//     }
//   }

//   void _startSerialReconnectTimer() {
//     if (_isSerialReconnecting) return;

//     _isSerialReconnecting = true;
//     _serialReconnectTimer = Timer.periodic(
//       const Duration(seconds: _serialReconnectIntervalSeconds),
//       (timer) {
//         if (!_isSerialConnected) {
//           logger.d('Attempting to reconnect to serial port...');
//           _refreshPortList();
//           connectToSerialPort();
//         } else {
//           _serialReconnectTimer?.cancel();
//           _isSerialReconnecting = false;
//         }
//       },
//     );
//   }

//   void _openSerialPort() {
//     if (_serialPort == null || _isSerialConnected) return;

//     try {
//       if (_serialPort!.open(mode: SerialPortMode.read)) {
//         SerialPortConfig config = _serialPort!.config;

//         // Configure port settings from saved preferences
//         config.baudRate = SettingsBox().serialBaudRate;
//         config.bits = SettingsBox().serialDataBits;
//         config.stopBits = SettingsBox().serialStopBits;
//         config.parity = SettingsBox().serialParity;
//         config.cts = 0;
//         config.rts = 0;
//         config.xonXoff = 0;

//         _serialPort!.config = config;

//         if (_serialPort!.isOpen) {
//           _isSerialConnected = true;
//           _isSerialReconnecting = false;
//           logger.d('${_serialPort!.name} opened!');

//           // Create reader and listen for data
//           _serialPortReader = SerialPortReader(_serialPort!);

//           _serialPortReader!.stream.listen(
//             (data) {
//               _serialProcessor.processStream(Stream.value(data));
//             },
//             onError: (error) {
//               if (error is SerialPortError) {
//                 logger.d(
//                   'Serial error: ${error.message}, code: ${error.errorCode}',
//                 );
//                 _handleSerialDisconnect();
//               }
//             },
//             onDone: () {
//               _handleSerialDisconnect();
//             },
//           );
//         }
//       } else {
//         logger.d('Failed to open serial port');
//         _handleSerialDisconnect();
//       }
//     } catch (e) {
//       logger.d('Error opening serial port: $e');
//       _handleSerialDisconnect();
//     }
//   }

//   void _handleSerialDisconnect() {
//     _isSerialConnected = false;
//     _startSerialReconnectTimer();
//   }

//   void closeSerialPort() {
//     if (_serialPort != null && _serialPort!.isOpen) {
//       try {
//         _serialPortReader?.close();
//         _serialPort!.close();
//         logger.d('${_serialPort!.name} closed!');
//       } catch (e) {
//         logger.d('Error closing serial port: $e');
//       } finally {
//         _isSerialConnected = false;
//       }
//     }
//   }

//   bool get isConnected => _isSerialConnected;

//   void dispose() {
//     _serialReconnectTimer?.cancel();
//     closeSerialPort();
//   }

//   // Public methods for connection control
//   void connect() {
//     if (!_isSerialConnected) {
//       connectToSerialPort();
//     }
//   }

//   void disconnect() {
//     if (_isSerialConnected) {
//       closeSerialPort();
//     }
//   }
// }
