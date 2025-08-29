import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/config_providers.dart';
import 'package:soundboard/core/utils/logger.dart';

class SettingsApiProductKey extends ConsumerStatefulWidget {
  const SettingsApiProductKey({super.key});

  @override
  ConsumerState<SettingsApiProductKey> createState() =>
      _SettingsApiProductKeyState();
}

class _SettingsApiProductKeyState extends ConsumerState<SettingsApiProductKey> {
  Timer? _debounce;
  final Logger logger = const Logger('SettingsApiProductKey');
  final TextEditingController _ctrlProductKey = TextEditingController();
  final SettingsBox _settingsBox = SettingsBox();

  @override
  void initState() {
    super.initState();
    _ctrlProductKey.text = _settingsBox.apiProductKey;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrlProductKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasKey = _settingsBox.apiProductKey.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            onPressed: () => _showProductKeyDialog(context),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'API Product Key',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      hasKey ? 'Key configured' : 'Not configured',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer.withValues(alpha: 204),
                      ),
                    ),
                  ],
                ),
                Icon(
                  hasKey ? Icons.check_circle : Icons.warning,
                  color: hasKey
                      ? Colors.green
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showProductKeyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Product Key Configuration'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your Soundboard API product key to enable text-to-speech functionality.',
                style: TextStyle(fontSize: 14),
              ),
              const Gap(16),
              TextField(
                controller: _ctrlProductKey,
                decoration: const InputDecoration(
                  enabledBorder: OutlineInputBorder(),
                  border: OutlineInputBorder(),
                  labelText: "Product Key",
                  hintText: "SOUND-ABC123-DEF456",
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                ),
                onChanged: (text) {
                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 1000), () {
                    _settingsBox.apiProductKey = text;
                    // Update the reactive provider
                    ref.read(apiProductKeyProvider.notifier).updateApiKey(text);
                    _showRestartMessage(context);
                    setState(() {});
                  });
                },
              ),
              const Gap(16),
              const Text(
                'How to get a product key:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Gap(8),
              const Text(
                '1. Visit the Soundboard API website\n'
                '2. Create an account or sign in\n'
                '3. Purchase a subscription plan\n'
                '4. Copy the product key from your dashboard\n'
                '5. Paste it in the field above',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _settingsBox.apiProductKey = _ctrlProductKey.text;
              // Update the reactive provider
              ref
                  .read(apiProductKeyProvider.notifier)
                  .updateApiKey(_ctrlProductKey.text);
              Navigator.of(context).pop();
              _showRestartMessage(context);
              setState(() {});
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showRestartMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: const Text(
          "Application restart may be required for changes to take effect.",
        ),
        elevation: 5,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// Contains AI-generated edits.
