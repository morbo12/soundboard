import 'dart:core';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_clean_cache.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_color_scheme.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_serial_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_spotify.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_jingle.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_volume.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
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
              // settingsHeaderText("Default mainvolym"),
              // // settingsHeader2Text("Sätt volymen för main"),
              // MainVolume(),
              // const Gap(2),
              // settingsHeaderText("Mainvolym för TTS"),
              // // settingsHeader2Text("Sätt volymen för TTS"),
              // TtsVolume(),
              // const Gap(2),
              settingsHeaderText("Kanalens volym för bakgrund"),
              // settingsHeader2Text("Sätt volymen för bakgrundsmusik"),
              const Gap(2),
              const BackgroundVolume(),
              const Gap(5),

              settingsHeaderText("Deej Mixer Serial Port Settings"),
              settingsHeader2Text(
                "Configure the serial port connection for your Deej hardware mixer",
              ),
              const Gap(2),
              const SerialPortSettingsButton(),
              const Gap(10),

              settingsHeaderText("Spotify Configuration"),
              settingsHeader2Text(
                "Copy URL from Spotify. In playlist, goto ... -> Share -> Copy link",
              ),
              const Gap(2),
              const SettingsSpotify(),
              const Gap(10),
              settingsHeaderText("Ladda upp jinglar"),
              settingsHeader2Text(
                "Antingen välj en eller flera flac eller mp3-filer.",
              ),
              const Gap(2),
              JingleSettings(),
              const Gap(5),
              settingsHeaderText("Ladda upp enskilda jinglar"),
              settingsHeader2Text(
                "Ladda upp en flac eller mp3-fil som kopplas till funktionen",
              ),
              const Gap(2),
              JingleSingleSettings(),
              const Gap(5),

              // settingsHeaderText("Ladda upp en komplett struktur"),
              // settingsHeader2Text(
              //     "Ladda upp samtliga filer i en och samma zip-fil"),
              // const Gap(2),
              // JingleAllSettings(),
              // const Gap(5),
              settingsHeaderText(
                "!!! DANGER - Clean jingle cache - DANGER !!!",
              ),
              settingsHeader2Text("Deletes all uploaded jingles from cache"),
              const Gap(2),
              const CleanCacheButton(),
            ],
          ),
        ),
      ),
    );
  }

  Text settingsHeaderText(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 19,
        fontWeight: FontWeight.bold,
        // color: Theme.of(context).colorScheme.onBackground,
      ),
    );
  }

  Text settingsHeader2Text(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.normal,
        // color: Theme.of(context).colorScheme.onBackground,
      ),
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
