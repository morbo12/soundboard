import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:soundboard/features/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/utils/logger.dart';

class SettingsTtsVoice extends ConsumerStatefulWidget {
  const SettingsTtsVoice({super.key});

  @override
  ConsumerState<SettingsTtsVoice> createState() => _SettingsTtsVoiceState();
}

class _SettingsTtsVoiceState extends ConsumerState<SettingsTtsVoice> {
  final Logger logger = const Logger('SettingsTtsVoice');

  @override
  Widget build(BuildContext context) {
    logger.d("Azure Voice ID: ${SettingsBox().azVoiceId}");

    final myVoiceId = ref.watch(voiceManagerProvider);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _showVoicePicker(context, ref, myVoiceId),
            child: AutoSizeText(
              VoiceManager.getNameById(myVoiceId),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  void _showVoicePicker(BuildContext context, WidgetRef ref, int myVoiceId) {
    final voiceList = VoiceManager.getVoiceList();
    final selectedVoice = VoiceManager.getNameById(myVoiceId);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Välj röst",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: voiceList.length,
                itemBuilder: (context, index) {
                  final voice = voiceList[index];
                  return ListTile(
                    title: Text(voice),
                    selected: voice == selectedVoice,
                    onTap: () {
                      // Update the selected voice
                      final voiceId = VoiceManager.getIdByName(voice);
                      ref.read(voiceManagerProvider.notifier).state = voiceId;
                      SettingsBox().azVoiceId = voiceId;

                      // Show a success message
                      FlutterToastr.show(
                        "Röst uppdaterad VALUE: $voice",
                        context,
                        duration: FlutterToastr.lengthLong,
                        position: FlutterToastr.bottom,
                        backgroundColor: Colors.green,
                        textStyle: const TextStyle(color: Colors.white),
                      );

                      // Close the bottom sheet
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
