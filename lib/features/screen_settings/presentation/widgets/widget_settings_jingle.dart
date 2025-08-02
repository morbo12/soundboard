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
            UploadButtonToDir(directoryName: "GenericJingles"),
            Gap(5),
            UploadButtonToDir(directoryName: "GoalJingles"),
            Gap(5),
            UploadButtonToDir(directoryName: "ClapJingles"),
          ],
        ),
        const Gap(5),
        const Row(
          children: [
            UploadButtonToDir(directoryName: "SpecialJingles"),
            Gap(5),
            UploadButtonToDir(directoryName: "GoalHorn"),
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
    return const Row(children: [UploadButtonAll()]);
  }
}

// Contains AI-generated edits.
