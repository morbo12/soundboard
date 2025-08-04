import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';

class DeviceIdManager {
  static const Logger _logger = Logger('DeviceIdManager');

  /// Generates a unique device ID for this installation
  /// Uses a combination of platform info and random data
  static String _generateDeviceId() {
    final random = Random.secure();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Create a unique string combining platform info and random data
    final uniqueString = [
      Platform.operatingSystem,
      Platform.operatingSystemVersion,
      timestamp.toString(),
      random.nextInt(999999).toString().padLeft(6, '0'),
      random.nextInt(999999).toString().padLeft(6, '0'),
    ].join('-');

    // Hash it to create a consistent format
    final bytes = sha256.convert(uniqueString.codeUnits).bytes;
    final deviceId = bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();

    // Take first 32 characters for a reasonable length
    return deviceId.substring(0, 32).toUpperCase();
  }

  /// Gets the device ID, generating one if it doesn't exist
  static String getDeviceId() {
    final settings = SettingsBox();
    String deviceId = settings.apiDeviceId;

    if (deviceId.isEmpty) {
      _logger.i('No device ID found, generating new one');
      deviceId = _generateDeviceId();
      settings.apiDeviceId = deviceId;
      _logger.i('Generated new device ID: ${deviceId.substring(0, 8)}...');
    } else {
      _logger.d('Using existing device ID: ${deviceId.substring(0, 8)}...');
    }

    return deviceId;
  }

  /// Forces regeneration of device ID (use with caution)
  static String regenerateDeviceId() {
    _logger.w('Regenerating device ID');
    final settings = SettingsBox();
    final newDeviceId = _generateDeviceId();
    settings.apiDeviceId = newDeviceId;
    _logger.i('Regenerated device ID: ${newDeviceId.substring(0, 8)}...');
    return newDeviceId;
  }

  /// Clears the stored device ID
  static void clearDeviceId() {
    _logger.w('Clearing device ID');
    final settings = SettingsBox();
    settings.apiDeviceId = "";
  }

  /// Reset the device ID (alias for clearDeviceId)
  static void resetDeviceId() {
    clearDeviceId();
  }

  /// Get device info for display purposes
  static Map<String, String> getDeviceInfo() {
    final deviceId = getDeviceId();

    return {
      'deviceId': deviceId,
      'deviceIdShort': '${deviceId.substring(0, 12)}...',
      'platform': Platform.operatingSystem,
      'platformVersion': Platform.operatingSystemVersion,
      'username':
          Platform.environment['USERNAME'] ??
          Platform.environment['USER'] ??
          'Unknown',
    };
  }
}

// Contains AI-generated edits.
