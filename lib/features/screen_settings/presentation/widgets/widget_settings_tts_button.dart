import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_azure_region.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_voice.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_region.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_servicekey.dart';

class TtsSettingsButton extends ConsumerStatefulWidget {
  const TtsSettingsButton({super.key});

  @override
  ConsumerState<TtsSettingsButton> createState() => _TtsSettingsButtonState();
}

class _TtsSettingsButtonState extends ConsumerState<TtsSettingsButton> {
  @override
  Widget build(BuildContext context) {
    // Get current settings for button display
    final voiceName = VoiceManager.getNameById(SettingsBox().azVoiceId);
    final regionName = AzureRegionManager().getNameById(
      SettingsBox().azRegionId,
    );
    final hasKey = SettingsBox().azTtsKey.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            onPressed: () => _showSettingsBottomSheet(context),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TTS Voice: $voiceName',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      'Region: $regionName | Key: ${hasKey ? "Configured" : "Not configured"}',
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
                  Icons.settings,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Text to Speech Settings",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Voice Selection",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SettingsTtsVoice(),
                    const Gap(16),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Region Selection",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SettingsTtsRegion(),
                    const Gap(16),

                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Azure Service Key",
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SettingsTtsServiceKey(),
                    const Gap(16),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
