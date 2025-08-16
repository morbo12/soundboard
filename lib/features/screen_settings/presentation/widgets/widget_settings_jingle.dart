import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_all.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_jingle_management_button.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

class JingleSettings extends StatelessWidget {
  const JingleSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: JingleManagementButton(
                directoryName: "GenericJingles",
                audioCategory: AudioCategory.genericJingle,
              ),
            ),
            const Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "GoalJingles",
                audioCategory: AudioCategory.goalJingle,
              ),
            ),
            const Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "ClapJingles",
                audioCategory: AudioCategory.clapJingle,
              ),
            ),
          ],
        ),
        const Gap(5),
        Row(
          children: [
            Expanded(
              child: JingleManagementButton(
                directoryName: "SpecialJingles",
                audioCategory: AudioCategory.specialJingle,
              ),
            ),
            const Gap(5),
            Expanded(
              child: JingleManagementButton(
                directoryName: "GoalHorn",
                audioCategory: AudioCategory.goalHorn,
              ),
            ),
            const Gap(5),
            const Expanded(child: SizedBox()), // Empty space for alignment
          ],
        ),
        const Gap(10),
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
