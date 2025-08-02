import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_all.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_to_dir.dart';

class JingleSettings extends StatelessWidget {
  JingleSettings({super.key});

  final List<String> directoryNames = [
    "GenericJingles",
    "GoalJingles",
    "ClapJingles",
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Row(
          children: [
            Expanded(child: UploadButtonToDir(directoryName: "GenericJingles")),
            Gap(5),
            Expanded(child: UploadButtonToDir(directoryName: "GoalJingles")),
            Gap(5),
            Expanded(child: UploadButtonToDir(directoryName: "ClapJingles")),
          ],
        ),
        const Gap(5),
        const Row(
          children: [
            Expanded(child: UploadButtonToDir(directoryName: "SpecialJingles")),
            Gap(5),
            Expanded(child: UploadButtonToDir(directoryName: "GoalHorn")),
          ],
        ),
        const Gap(10),
        // All jingle categories now use directory-based upload
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
