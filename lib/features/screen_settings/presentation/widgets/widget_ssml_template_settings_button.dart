import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_ssml_template_settings.dart';

/// Button widget to open SSML template settings
class SsmlTemplateSettingsButton extends StatelessWidget {
  const SsmlTemplateSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SsmlTemplateSettings()),
        );
      },
      icon: const Icon(Icons.edit_document),
      label: const Text('Edit SSML Templates'),
    );
  }
}
