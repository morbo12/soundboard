import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/widget_settings_tts_region.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/widget_settings_tts_voice.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/widget_settings_tts_servicekey.dart';

class SettingsTtsScreen extends ConsumerStatefulWidget {
  const SettingsTtsScreen({super.key});

  @override
  SettingsTtsScreenState createState() => SettingsTtsScreenState();
}

class SettingsTtsScreenState extends ConsumerState<SettingsTtsScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement restart app
    // final restartApp = ref.watch(restartAppProvider);
    int azCharCount = ref.watch(azCharCountProvider);
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: ScreenSizeUtil.getWidth(context),
          child: ListView(
            children: [
              const Gap(10),
              settingsHeaderText("Antal tecken kvar att använda"),
              Text((DefaultConstants().azCharCountLimit - azCharCount)
                  .toString()),
              const Gap(10),
              settingsHeaderText("Text to speech konfiguration"),
              settingsHeader2Text(
                "Du behöver ett konto hos Azure för att använda denna funktion.",
              ),
              const Gap(10),
              settingsHeaderText("Välj röst"),
              const Gap(5),
              const SettingsTtsVoice(),
              settingsHeaderText("Välj Region"),
              const Gap(5),
              const SettingsTtsRegion(),
              settingsHeaderText("Ange Azure service key för Text To Speech"),
              const Gap(10),
              const SettingsTtsServiceKey(),
              const Gap(10),
              // TODO: Implement restart app
              // MaterialButton(
              //   onPressed: restartApp,
              //   child: const Text("Restart app"),
              // )
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
