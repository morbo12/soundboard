import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_clean_cache.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_color_scheme.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_serial_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_spotify.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_jingle.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_volume.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_tts_button.dart';

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
          width: ScreenSizeUtil.getWidth(context),
          child: ListView(
            children: [
              settingsHeaderText("Färgschema"),
              settingsHeader2Text(
                "Dessa är rekommenderade: greyLaw, aquaBlue, ebonyClay, outerSpace, blueWhale, sanJuanBlue, blueM3, purpleBrown",
              ),
              const MyColorScheme(),
              const Gap(10),

              settingsHeaderText("Kanalens volym för bakgrund"),
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

              settingsHeaderText("Jinglar"),
              settingsHeader2Text("Hantera jinglar och ljudfiler"),
              const Gap(2),
              JingleSettings(),
              const Gap(5),
              settingsHeaderText("Enskilda jinglar"),
              settingsHeader2Text(
                "Ladda upp en flac eller mp3-fil som kopplas till funktionen",
              ),
              const Gap(2),
              JingleSingleSettings(),
              const Gap(10),

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
