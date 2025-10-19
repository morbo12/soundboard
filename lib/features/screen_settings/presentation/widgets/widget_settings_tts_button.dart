import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_azure_region.dart';
import 'package:soundboard/core/services/cloud_text_to_speech/class_hybrid_text_to_speech_service.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_voice.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_api_tts_voice.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_region.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_servicekey.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_api_key.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_api_test.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_tts_service_mode_switch.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_device_info.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_device_id_display.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_api_usage.dart';

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

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.indigo.shade100, Colors.indigo.shade50],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showSettingsBottomSheet(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.record_voice_over,
                    color: Colors.indigo.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'TTS Voice: $voiceName',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: hasKey ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hasKey ? 'CONFIGURED' : 'SETUP',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Region: $regionName | Key: ${hasKey ? "Configured" : "Not configured"}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.indigo.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.settings, color: Colors.indigo.shade700, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const TtsSettingsDialog(),
    );
  }
}

class TtsSettingsDialog extends ConsumerStatefulWidget {
  const TtsSettingsDialog({super.key});

  @override
  ConsumerState<TtsSettingsDialog> createState() => _TtsSettingsDialogState();
}

class _TtsSettingsDialogState extends ConsumerState<TtsSettingsDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentMode = ref.watch(ttsServiceModeProvider);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Text to Speech Settings"),
          const Gap(8),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Configuration'),
              Tab(text: 'API Usage'),
            ],
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.6,
        child: TabBarView(
          controller: _tabController,
          children: [
            // Configuration Tab
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Service Provider Selection (always shown)
                  _buildSectionHeader(context, "Service Provider"),
                  const Gap(8),
                  const TtsServiceModeSwitch(),
                  const Gap(24),

                  // Voice Configuration (context-sensitive)
                  _buildSectionHeader(context, "Voice Configuration"),
                  const Gap(8),
                  if (currentMode == TtsServiceMode.azureDirect) ...[
                    const SettingsTtsVoice(),
                    const Gap(16),
                    _buildSubHeader(context, "Region"),
                    const Gap(8),
                    const SettingsTtsRegion(),
                  ] else ...[
                    const SettingsApiTtsVoice(),
                  ],
                  const Gap(24),

                  // API Configuration (context-sensitive)
                  if (currentMode == TtsServiceMode.azureDirect) ...[
                    _buildSectionHeader(context, "Azure Service Key"),
                    const Gap(8),
                    const SettingsTtsServiceKey(),
                    const Gap(24),
                  ] else ...[
                    _buildSectionHeader(context, "Soundboard API Key"),
                    const Gap(8),
                    const SettingsApiProductKey(),
                    const Gap(24),

                    // Device Registration (only for Soundboard API)
                    _buildSectionHeader(context, "Device Registration"),
                    const Gap(8),
                    const DeviceIdDisplayWidget(),
                    const Gap(24),
                  ],

                  // Testing & Status (always shown)
                  _buildSectionHeader(context, "Testing & Status"),
                  const Gap(8),
                  const ApiTestWidget(),

                  // Device Information (always shown, but only general info for Azure)
                  if (currentMode == TtsServiceMode.azureDirect) ...[
                    const Gap(24),
                    _buildSectionHeader(context, "System Information"),
                    const Gap(8),
                    const DeviceInfoWidget(),
                  ],
                ],
              ),
            ),
            // API Usage Tab
            const SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: ApiUsageWidget(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
    );
  }
}
