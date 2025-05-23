import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/ssml/class_ssml_custom_tts.dart';

class TtsDialog {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final TextEditingController textController = TextEditingController();
    final CustomTtsEvent ssmlEvent = CustomTtsEvent(ref: ref);

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Custom TTS Announcement'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter text to announce',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (textController.text.isNotEmpty) {
                  final announcement = ssmlEvent.wrapWithProsody(
                    textController.text,
                  );
                  await ssmlEvent.showToast(context, announcement);
                  await ssmlEvent.playAnnouncement(announcement);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text('Announce'),
            ),
          ],
        );
      },
    );
  }
}
