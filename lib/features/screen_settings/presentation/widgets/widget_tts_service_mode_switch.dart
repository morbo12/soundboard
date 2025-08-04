import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_hybrid_text_to_speech_service.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';

class TtsServiceModeSwitch extends ConsumerStatefulWidget {
  const TtsServiceModeSwitch({super.key});

  @override
  ConsumerState<TtsServiceModeSwitch> createState() =>
      _TtsServiceModeSwitchState();
}

class _TtsServiceModeSwitchState extends ConsumerState<TtsServiceModeSwitch> {
  static const Logger _logger = Logger('TtsServiceModeSwitch');

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(ttsServiceModeProvider);
    final settings = SettingsBox();
    final hasApiKey = settings.apiProductKey.isNotEmpty;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TTS Service Mode',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Azure Direct Mode
            RadioListTile<TtsServiceMode>(
              title: const Text('Azure Direct SDK'),
              subtitle: const Text('Direct connection to Azure TTS (Legacy)'),
              value: TtsServiceMode.azureDirect,
              groupValue: currentMode,
              onChanged: (value) {
                if (value != null) {
                  _changeMode(value);
                }
              },
              secondary: const Icon(Icons.cloud),
            ),

            // Soundboard API Mode
            RadioListTile<TtsServiceMode>(
              title: const Text('Soundboard API'),
              subtitle: Text(
                hasApiKey
                    ? 'Use Soundboard API (Recommended)'
                    : 'Use Soundboard API (API key required)',
              ),
              value: TtsServiceMode.soundboardApi,
              groupValue: currentMode,
              onChanged: hasApiKey
                  ? (value) {
                      if (value != null) {
                        _changeMode(value);
                      }
                    }
                  : null,
              secondary: Icon(Icons.api, color: hasApiKey ? null : Colors.grey),
            ),

            if (!hasApiKey) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Configure an API key to enable Soundboard API mode',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Current status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getModeColor(currentMode).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getModeColor(currentMode).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getModeIcon(currentMode),
                    color: _getModeColor(currentMode),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Active: ${_getModeDisplayName(currentMode)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: _getModeColor(currentMode),
                          ),
                        ),
                        Text(
                          _getModeDescription(currentMode),
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeMode(TtsServiceMode mode) {
    ref.read(ttsServiceModeProvider.notifier).state = mode;
    _logger.i('TTS service mode changed to: $mode');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('TTS service switched to ${_getModeDisplayName(mode)}'),
        backgroundColor: _getModeColor(mode),
      ),
    );
  }

  Color _getModeColor(TtsServiceMode mode) {
    switch (mode) {
      case TtsServiceMode.azureDirect:
        return Colors.blue;
      case TtsServiceMode.soundboardApi:
        return Colors.green;
    }
  }

  IconData _getModeIcon(TtsServiceMode mode) {
    switch (mode) {
      case TtsServiceMode.azureDirect:
        return Icons.cloud;
      case TtsServiceMode.soundboardApi:
        return Icons.api;
    }
  }

  String _getModeDisplayName(TtsServiceMode mode) {
    switch (mode) {
      case TtsServiceMode.azureDirect:
        return 'Azure Direct SDK';
      case TtsServiceMode.soundboardApi:
        return 'Soundboard API';
    }
  }

  String _getModeDescription(TtsServiceMode mode) {
    switch (mode) {
      case TtsServiceMode.azureDirect:
        return 'Using legacy Azure TTS with WebM audio';
      case TtsServiceMode.soundboardApi:
        return 'Using Soundboard API with MP3/WAV audio';
    }
  }
}

// Contains AI-generated edits.
