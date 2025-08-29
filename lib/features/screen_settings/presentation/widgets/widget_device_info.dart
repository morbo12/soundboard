import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundboard/core/utils/device_id_manager.dart';
import 'package:soundboard/core/utils/logger.dart';

class DeviceInfoWidget extends StatelessWidget {
  const DeviceInfoWidget({super.key});

  static const Logger _logger = Logger('DeviceInfoWidget');

  @override
  Widget build(BuildContext context) {
    final deviceInfo = DeviceIdManager.getDeviceInfo();
    final deviceId = deviceInfo['deviceId'] ?? '';
    final deviceIdShort = deviceInfo['deviceIdShort'] ?? '';
    final platform = deviceInfo['platform'] ?? '';
    final username = deviceInfo['username'] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Device Information',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Device ID
            _buildInfoRow(
              context,
              icon: Icons.fingerprint,
              label: 'Device ID',
              value: deviceIdShort,
              fullValue: deviceId,
              copyable: true,
            ),

            const SizedBox(height: 8),

            // Platform
            _buildInfoRow(
              context,
              icon: Icons.computer,
              label: 'Platform',
              value: platform,
            ),

            const SizedBox(height: 8),

            // Username
            _buildInfoRow(
              context,
              icon: Icons.person,
              label: 'User',
              value: username,
            ),

            const SizedBox(height: 16),

            // Reset button (for troubleshooting)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _showResetDialog(context),
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Reset Device ID'),
                style: TextButton.styleFrom(foregroundColor: Colors.orange),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? fullValue,
    bool copyable = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
        ),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
        if (copyable) ...[
          IconButton(
            onPressed: () => _copyToClipboard(context, fullValue ?? value),
            icon: const Icon(Icons.copy, size: 16),
            tooltip: 'Copy full device ID',
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    _logger.i('Device ID copied to clipboard');
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Device ID'),
          content: const Text(
            'This will generate a new device ID. You may need to re-authenticate with the API.\n\n'
            'Are you sure you want to continue?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetDeviceId(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Reset'),
            ),
          ],
        );
      },
    );
  }

  void _resetDeviceId(BuildContext context) {
    try {
      DeviceIdManager.resetDeviceId();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Device ID has been reset. A new ID will be generated on next authentication.',
          ),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
        ),
      );

      _logger.i('Device ID reset by user');
    } catch (e) {
      _logger.e('Error resetting device ID: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error resetting device ID'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// Contains AI-generated edits.
