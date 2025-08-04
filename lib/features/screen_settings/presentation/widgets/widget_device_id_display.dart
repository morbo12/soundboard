import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/utils/device_id_manager.dart';
import 'package:soundboard/core/utils/logger.dart';

class DeviceIdDisplayWidget extends ConsumerWidget {
  static const Logger _logger = Logger('DeviceIdDisplayWidget');

  const DeviceIdDisplayWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deviceId = DeviceIdManager.getDeviceId();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.phone_android,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Device ID',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Device ID display
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      deviceId,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _copyToClipboard(context, deviceId),
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy to clipboard',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info text
            Text(
              'This unique device ID is automatically generated and used for API authentication. It identifies your device to the Soundboard API.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _regenerateDeviceId(context),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Regenerate'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(context, deviceId),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String deviceId) {
    Clipboard.setData(ClipboardData(text: deviceId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Device ID copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
    _logger.i('Device ID copied to clipboard');
  }

  void _regenerateDeviceId(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Regenerate Device ID'),
        content: const Text(
          'This will generate a new device ID. You may need to re-authenticate with the API.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newDeviceId = DeviceIdManager.regenerateDeviceId();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'New device ID generated: ${newDeviceId.substring(0, 8)}...',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
              _logger.i('Device ID regenerated by user');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Regenerate'),
          ),
        ],
      ),
    );
  }
}

// Contains AI-generated edits.
