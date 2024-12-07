import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_all.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_to_dir.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_to_single.dart';

class JingleSettings extends StatelessWidget {
  JingleSettings({super.key});

  final List<String> directoryNames = [
    "GenericJingles",
    "GoalJingles",
    "ClapJingles",
    "IntroJingles",
    "LineupJingles"
  ];

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            UploadButtonToDir(directoryName: "GenericJingles"),
            Gap(5),
            UploadButtonToDir(directoryName: "GoalJingles"),
            Gap(5),
            UploadButtonToDir(directoryName: "ClapJingles"),
          ],
        ),
        Gap(5),
        Row(
          children: [
            UploadButtonToDir(directoryName: "IntroJingles"),
            Gap(5),
            UploadButtonToDir(directoryName: "LineupJingles")
          ],
        ),
      ],
    );
  }
}

class JingleSingleSettings extends StatelessWidget {
  JingleSingleSettings({super.key});

  final List<String> displayNames = [
    "GoalHorn",
    "Ratata",
    "PowerUp",
    "Penalty",
    "OneMin",
    "ThreeMin",
    "Lineup",
    "Timeout",
    "HomeTeam",
    "AwayTeam"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(
        children: [
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "GoalHorn")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "Ratata")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "PowerUp")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "Penalty")),
        ],
      ),
      const Gap(5),
      Row(
        children: [
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "OneMin")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "ThreeMin")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "Lineup")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances
                  .firstWhere((element) => element.displayName == "Timeout"))
        ],
      ),
      const Gap(5),
      Row(
        children: [
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances.firstWhere(
                  (element) => element.displayName == "HomeJingle")),
          const Gap(5),
          UploadButtonToSingle(
              audiofile: jingleManager.audioManager.audioInstances.firstWhere(
                  (element) => element.displayName == "AwayJingle")),
        ],
      ),
    ]);
  }
}

class JingleAllSettings extends StatelessWidget {
  const JingleAllSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(children: [UploadButtonAll()]);
  }
}
