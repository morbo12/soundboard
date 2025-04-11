import 'dart:typed_data';

import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:soundboard/utils/logger.dart';

class SerialPortManager {
  // Get available ports
  List<String> getAvailablePorts() {
    return SerialPort.availablePorts;
  }

  Logger logger = const Logger('SerialPortManager');

  // Configure and open a port
  SerialPort? configurePort(String portName) {
    try {
      final port = SerialPort(portName);

      // Configure port settings
      port.openReadWrite();
      port.config =
          SerialPortConfig()
            ..baudRate = 9600
            ..bits = 8
            ..stopBits = 1
            ..parity = SerialPortParity.none
            ..setFlowControl(SerialPortFlowControl.none);

      return port;
    } on SerialPortError catch (err) {
      logger.d('Error configuring port: ${err.message}');
      return null;
    }
  }

  // Write data to port
  void writeToPort(SerialPort port, List<int> data) {
    try {
      port.write(Uint8List.fromList(data));
    } on SerialPortError catch (err) {
      logger.d('Error writing to port: ${err.message}');
    }
  }

  // Read data from port
  List<int> readFromPort(SerialPort port, int length) {
    try {
      return port.read(length);
    } on SerialPortError catch (err) {
      logger.d('Error reading from port: ${err.message}');
      return [];
    }
  }

  // Close the port
  void closePort(SerialPort port) {
    try {
      port.close();
    } on SerialPortError catch (err) {
      logger.d('Error closing port: ${err.message}');
    }
  }
}
