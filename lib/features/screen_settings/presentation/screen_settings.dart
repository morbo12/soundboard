import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
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

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _selectedIndex = 0;

  final List<_SettingsSection> _sections = [
    _SettingsSection(
      title: 'Appearance',
      icon: Icons.palette_outlined,
      selectedIcon: Icons.palette,
    ),
    _SettingsSection(
      title: 'Audio & Hardware',
      icon: Icons.equalizer_outlined,
      selectedIcon: Icons.equalizer,
    ),
    _SettingsSection(
      title: 'Text to Speech',
      icon: Icons.record_voice_over_outlined,
      selectedIcon: Icons.record_voice_over,
    ),
    _SettingsSection(
      title: 'Content & Media',
      icon: Icons.library_music_outlined,
      selectedIcon: Icons.library_music,
    ),
    _SettingsSection(
      title: 'System',
      icon: Icons.settings_applications_outlined,
      selectedIcon: Icons.settings_applications,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                  section.title,
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
                    _sections[_selectedIndex].title.toUpperCase(),
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
    switch (index) {
      case 0: // Appearance
        return [
          _buildSettingItem(
            title: "Color Scheme",
            description:
                "Choose a color theme for the application. Recommended: greyLaw, aquaBlue, ebonyClay.",
            child: const MyColorScheme(),
          ),
        ];
      case 1: // Audio & Hardware
        return [
          _buildSettingItem(
            title: "Background Volume",
            description: "Adjust the volume level for the background channel.",
            child: const BackgroundVolume(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: "Deej Mixer Serial Port",
            description:
                "Configure the serial port connection for your Deej hardware mixer.",
            child: const SerialPortSettingsButton(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: "Volume Control & Mappings",
            description:
                "Configure volume control behavior and Deej hardware mappings.",
            child: const VolumeSystemConfigButton(),
          ),
        ];
      case 2: // Text to Speech
        return [
          _buildSettingItem(
            title: "TTS Settings",
            description: "Configure Azure TTS settings for voice synthesis.",
            child: const TtsSettingsButton(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: "SSML Preview",
            description: "Enable editing SSML before sending to TTS engine.",
            child: const SsmlPreviewToggle(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: "SSML Templates",
            description:
                "Customize templates for welcome, lineup, and referee announcements.",
            child: const SsmlTemplateSettingsButton(),
          ),
        ];
      case 3: // Content & Media
        return [
          _buildSettingItem(
            title: "Spotify Configuration",
            description:
                "Copy URL from Spotify. In playlist, goto ... -> Share -> Copy link.",
            child: const SettingsSpotify(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: "Grid Layout",
            description: "Configure the layout and reset jingle assignments.",
            child: const GridSettingsSection(),
          ),
          const Gap(20),
          _buildSettingItem(
            title: "Jingles Manager",
            description:
                "Upload music files, manage jingles, and configure lineup jingles.",
            child: const JinglesManagerWidget(),
          ),
        ];
      case 4: // System
        return [
          _buildSettingItem(
            title: "Clear Cache",
            description: "Delete all uploaded jingles from the local cache.",
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
  final String title;
  final IconData icon;
  final IconData selectedIcon;

  _SettingsSection({
    required this.title,
    required this.icon,
    required this.selectedIcon,
  });
}
