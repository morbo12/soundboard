import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_button_upload_all.dart';
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

        // Optional: Keep the "Upload All" button for backward compatibility
        Text(
          'Alternative Upload Methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          ),
        ),
        Gap(8),
        JingleAllSettings(),
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
