import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_all.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_jingle_management_button.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

class JingleSettings extends StatelessWidget {
  const JingleSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: JingleManagementButton(
                directoryName: "GenericJingles",
                audioCategory: AudioCategory.genericJingle,
              ),
            ),
            Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "GoalJingles",
                audioCategory: AudioCategory.goalJingle,
              ),
            ),
            Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "ClapJingles",
                audioCategory: AudioCategory.clapJingle,
              ),
            ),
          ],
        ),
        Gap(5),
        Row(
          children: [
            Expanded(
              child: JingleManagementButton(
                directoryName: "SpecialJingles",
                audioCategory: AudioCategory.specialJingle,
              ),
            ),
            Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "GoalHorn",
                audioCategory: AudioCategory.goalHorn,
              ),
            ),
            Gap(5),
            Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "PenaltyJingles",
                audioCategory: AudioCategory.penaltyJingle,
              ),
            ),
          ],
        ),
        Gap(10),
      ],
    );
  }
}

class JingleAllSettings extends StatelessWidget {
  const JingleAllSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(children: [Expanded(child: UploadButtonAll())]);
  }
}

// Contains AI-generated edits.
