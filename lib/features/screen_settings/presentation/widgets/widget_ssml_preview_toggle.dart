import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/config_providers.dart';

/// Widget for toggling SSML preview feature in settings
class SsmlPreviewToggle extends ConsumerWidget {
  const SsmlPreviewToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = SettingsBox();
    final isEnabled = ref.watch(ssmlPreviewEnabledProvider);

    return SwitchListTile(
      title: const Text('Enable SSML Preview'),
      subtitle: const Text(
        'Show SSML content in an editable dialog before sending to TTS engine',
      ),
      value: isEnabled,
      onChanged: (value) {
        settings.enableSsmlPreview = value;
        ref.read(ssmlPreviewEnabledProvider.notifier).state = value;
      },
      secondary: const Icon(Icons.edit_note),
    );
  }
}
