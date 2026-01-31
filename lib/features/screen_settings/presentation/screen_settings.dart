import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_clean_cache.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_color_scheme.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/volume_system_config_widget.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_serial_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_spotify.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_volume.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_grid.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_jingles_manager.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_ssml_preview_toggle.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_ssml_template_settings_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_ai_model_selector.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_api_features_overview.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_language_selector.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_premium_badge.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_usage_stats_toggle.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_sponsor_kiosk_settings.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_profile_management.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  final List<_SettingsSection> _sections = [
    _SettingsSection(
      titleKey: 'settings.sections.appearance',
      icon: Icons.palette_outlined,
      selectedIcon: Icons.palette,
    ),
    _SettingsSection(
      titleKey: 'settings.sections.audio_hardware',
      icon: Icons.equalizer_outlined,
      selectedIcon: Icons.equalizer,
    ),
    _SettingsSection(
      titleKey: 'settings.sections.text_to_speech',
      icon: Icons.record_voice_over_outlined,
      selectedIcon: Icons.record_voice_over,
    ),
    _SettingsSection(
      titleKey: 'settings.sections.content_media',
      icon: Icons.library_music_outlined,
      selectedIcon: Icons.library_music,
    ),
    _SettingsSection(
      titleKey: 'settings.sections.api_premium',
      icon: Icons.workspace_premium_outlined,
      selectedIcon: Icons.workspace_premium,
    ),
    _SettingsSection(
      titleKey: 'settings.sections.system',
      icon: Icons.settings_applications_outlined,
      selectedIcon: Icons.settings_applications,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            // Use default theme background for better alignment
            // backgroundColor: colorScheme.surface,
            indicatorColor: colorScheme.primaryContainer,
            destinations: _sections.map((section) {
              return NavigationRailDestination(
                icon: Icon(section.icon),
                selectedIcon: Icon(section.selectedIcon),
                label: Text(
                  l10n.translate(section.titleKey),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n
                        .translate(_sections[_selectedIndex].titleKey)
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Gap(20),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: ListView(
                        key: ValueKey<int>(_selectedIndex),
                        children: _buildContent(_selectedIndex),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(int index) {
    final l10n = context.l10n;

    switch (index) {
      case 0: // Appearance
        return [
          const LanguageSelector(),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.color_scheme.title'),
            description: l10n.translate(
              'settings.items.color_scheme.description',
            ),
            child: const MyColorScheme(),
          ),
        ];
      case 1: // Audio & Hardware
        return [
          _buildSettingItem(
            title: l10n.translate('settings.items.background_volume.title'),
            description: l10n.translate(
              'settings.items.background_volume.description',
            ),
            child: const BackgroundVolume(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.deej_serial_port.title'),
            description: l10n.translate(
              'settings.items.deej_serial_port.description',
            ),
            child: const SerialPortSettingsButton(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate(
              'settings.items.volume_control_mappings.title',
            ),
            description: l10n.translate(
              'settings.items.volume_control_mappings.description',
            ),
            child: const VolumeSystemConfigButton(),
          ),
        ];
      case 2: // Text to Speech
        return [
          _buildSettingItem(
            title: l10n.translate('settings.items.tts_settings.title'),
            description: l10n.translate(
              'settings.items.tts_settings.description',
            ),
            child: const TtsSettingsButton(),
          ),
          const Gap(20),
          buildPremiumSettingItem(
            context: context,
            title: l10n.translate('settings.items.ai_model.title'),
            description: l10n.translate('settings.items.ai_model.description'),
            child: AiModelSelector(),
            isPremium: true,
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.ssml_preview.title'),
            description: l10n.translate(
              'settings.items.ssml_preview.description',
            ),
            child: const SsmlPreviewToggle(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.ssml_templates.title'),
            description: l10n.translate(
              'settings.items.ssml_templates.description',
            ),
            child: const SsmlTemplateSettingsButton(),
          ),
        ];
      case 3: // Content & Media
        return [
          _buildSettingItem(
            title: l10n.translate('settings.items.spotify_configuration.title'),
            description: l10n.translate(
              'settings.items.spotify_configuration.description',
            ),
            child: const SettingsSpotify(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.grid_layout.title'),
            description: l10n.translate(
              'settings.items.grid_layout.description',
            ),
            child: const GridSettingsSection(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.jingles_manager.title'),
            description: l10n.translate(
              'settings.items.jingles_manager.description',
            ),
            child: const JinglesManagerWidget(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.sponsor_kiosk.title'),
            description: l10n.translate(
              'settings.items.sponsor_kiosk.description',
            ),
            child: const SponsorKioskSettings(),
          ),
        ];
      case 4: // API & Premium
        return [
          _buildSettingItem(
            title: l10n.translate('settings.items.api_premium_features.title'),
            description: l10n.translate(
              'settings.items.api_premium_features.description',
            ),
            child: ApiFeaturesSectionWidget(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.usage_statistics.title'),
            description: l10n.translate(
              'settings.items.usage_statistics.description',
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                UsageStatsToggle(),
                SizedBox(height: 8),
                UsageStatsDiagnostics(),
              ],
            ),
          ),
        ];
      case 5: // System
        return [
          _buildSettingItem(
            title: l10n.translate('settings.items.profile_management.title'),
            description: l10n.translate(
              'settings.items.profile_management.description',
            ),
            child: const ProfileManagementWidget(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: l10n.translate('settings.items.clear_cache.title'),
            description: l10n.translate(
              'settings.items.clear_cache.description',
            ),
            child: const CleanCacheButton(),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildSettingItem({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 0,
      // Use a standard surface variant color for better theme alignment
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Gap(4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(16),
            child,
          ],
        ),
      ),
    );
  }
}

class _SettingsSection {
  final String titleKey;
  final IconData icon;
  final IconData selectedIcon;

  _SettingsSection({
    required this.titleKey,
    required this.icon,
    required this.selectedIcon,
  });
}
