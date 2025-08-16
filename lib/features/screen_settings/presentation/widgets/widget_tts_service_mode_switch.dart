import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_hybrid_text_to_speech_service.dart';
import 'package:soundboard/core/providers/config_providers.dart';
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
    final apiKey = ref.watch(
      apiProductKeyProvider,
    ); // Watch API key for reactive updates
    final hasApiKey =
        apiKey.isNotEmpty; // Use watched API key instead of settings

    // Listen to changes in settings to rebuild when API key is updated
    ref.listen(ttsServiceModeProvider, (previous, next) {
      if (mounted) setState(() {});
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Service options
        ..._buildServiceOptions(context, currentMode, hasApiKey),

        // Helper text for API key configuration
        if (currentMode == TtsServiceMode.soundboardApi && !hasApiKey)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 16),
            child: Text(
              '⚠️ Configure your Soundboard API key in the API Configuration section below to use this service',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.orange.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _buildServiceOptions(
    BuildContext context,
    TtsServiceMode currentMode,
    bool hasApiKey,
  ) {
    return [
      _buildServiceOption(
        context: context,
        title: 'Soundboard API',
        subtitle: 'High-quality voices with MP3/WAV audio',
        value: TtsServiceMode.soundboardApi,
        currentMode: currentMode,
        isEnabled: true, // Always allow selection
        isRecommended: true,
        hasApiKey: hasApiKey,
        onChanged: _changeMode,
      ),
      const SizedBox(height: 4),
      _buildServiceOption(
        context: context,
        title: 'Azure Direct SDK',
        subtitle: 'Legacy direct Azure connection with WebM audio',
        value: TtsServiceMode.azureDirect,
        currentMode: currentMode,
        isEnabled: true,
        isRecommended: false,
        hasApiKey: true, // Azure doesn't need this distinction
        onChanged: _changeMode,
      ),
    ];
  }

  Widget _buildServiceOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required TtsServiceMode value,
    required TtsServiceMode currentMode,
    required bool isEnabled,
    required bool isRecommended,
    required bool hasApiKey,
    required void Function(TtsServiceMode)? onChanged,
  }) {
    final needsApiKey = value == TtsServiceMode.soundboardApi && !hasApiKey;

    return RadioListTile<TtsServiceMode>(
      title: Row(
        children: [
          Text(title),
          if (isRecommended) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Text(
                'RECOMMENDED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
          if (needsApiKey) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Text(
                'API KEY REQUIRED',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.orange.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
      subtitle: Text(
        needsApiKey
            ? '$subtitle (Configure API key after selection)'
            : subtitle,
      ),
      value: value,
      groupValue: currentMode,
      onChanged: isEnabled
          ? (newValue) => newValue != null ? onChanged!(newValue) : null
          : null,
      secondary: Icon(
        value == TtsServiceMode.soundboardApi
            ? Icons.api
            : Icons.cloud_outlined,
        color: needsApiKey ? Colors.orange : null,
      ),
    );
  }

  void _changeMode(TtsServiceMode mode) {
    ref.read(ttsServiceModeProvider.notifier).state = mode;
    _logger.i('TTS service mode changed to: $mode');

    final serviceName = mode == TtsServiceMode.soundboardApi
        ? 'Soundboard API'
        : 'Azure Direct SDK';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to $serviceName'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// Contains AI-generated edits.
