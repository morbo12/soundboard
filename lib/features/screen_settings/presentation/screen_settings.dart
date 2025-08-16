import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/utils/responsive_utils.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_clean_cache.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_color_scheme.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/volume_system_config_widget.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_serial_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_spotify.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_jingle.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_volume.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_grid.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_music_upload_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: ResponsiveUtils.getWidth(context),
          child: ListView(
            children: [
              settingsHeaderText("Färgschema"),
              settingsHeader2Text(
                "Dessa är rekommenderade: greyLaw, aquaBlue, ebonyClay, outerSpace, blueWhale, sanJuanBlue, blueM3, purpleBrown",
              ),
              const MyColorScheme(),
              const Gap(10),

              settingsHeaderText("Bakgrundskanalens volym"),
              const Gap(2),
              const BackgroundVolume(),
              const Gap(10),

              settingsHeaderText("Deej Mixer Serial Port Settings"),
              settingsHeader2Text(
                "Configure the serial port connection for your Deej hardware mixer",
              ),
              const Gap(2),
              const SerialPortSettingsButton(),
              const Gap(10),
              settingsHeaderText("Volume Control & Deej Mappings"),
              settingsHeader2Text(
                "Configure volume control behavior and Deej hardware mappings",
              ),
              const Gap(2),
              const VolumeSystemConfigButton(),
              const Gap(10),
              settingsHeaderText("Text to Speech Settings"),
              settingsHeader2Text(
                "Configure Azure TTS settings for voice synthesis",
              ),
              const Gap(2),
              const TtsSettingsButton(),
              const Gap(10),

              settingsHeaderText("Spotify Configuration"),
              settingsHeader2Text(
                "Copy URL from Spotify. In playlist, goto ... -> Share -> Copy link",
              ),
              const Gap(2),
              const SettingsSpotify(),
              const Gap(10),

              settingsHeaderText("Grid Layout"),
              settingsHeader2Text(
                "Configure the layout and reset jingle assignments",
              ),
              const Gap(2),
              const GridSettingsSection(),
              const Gap(5),

              settingsHeaderText("Music Player"),
              settingsHeader2Text(
                "Upload and manage music files for the built-in music player",
              ),
              const Gap(2),
              const MusicUploadButton(),
              const Gap(10),
              settingsHeaderText("Jinglar"),
              settingsHeader2Text("Hantera jinglar och ljudfiler"),
              const Gap(2),
              const JingleSettings(),
              const Gap(5),

              settingsHeaderText("Rensa cache"),
              settingsHeader2Text("Raderar alla uppladdade jinglar från cache"),
              const Gap(2),
              const CleanCacheButton(),
              const Gap(10),
            ],
          ),
        ),
      ),
    );
  }

  Text settingsHeaderText(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
    );
  }

  Text settingsHeader2Text(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
    );
  }

  Text settingsDescriptionText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,

        // color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }
}
