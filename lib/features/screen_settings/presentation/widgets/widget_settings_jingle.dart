import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/common/widgets/buttons/modern_jingle_upload_button.dart';

class JingleSettings extends StatelessWidget {
  const JingleSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        // Modern unified upload interface
        ModernJingleUploadButton(),
        Gap(16),
      ],
    );
  }
}
