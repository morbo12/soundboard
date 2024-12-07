import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:soundboard/features/cloud_text_to_speech/class_azure_voice.dart';
import 'package:soundboard/properties.dart';

class SettingsTtsVoice extends ConsumerStatefulWidget {
  const SettingsTtsVoice({
    super.key,
  });

  @override
  ConsumerState<SettingsTtsVoice> createState() => _SettingsTtsVoiceState();
}

class _SettingsTtsVoiceState extends ConsumerState<SettingsTtsVoice> {
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(SettingsBox().azVoiceId);
    }
    final myVoiceId = ref.watch(voiceManagerProvider);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () => showMaterialScrollPicker<String>(
                    title: "Välj röst",
                    context: context,
                    items: VoiceManager.getVoiceList(),
                    onChanged: (value) {
                      ref.read(voiceManagerProvider.notifier).state =
                          VoiceManager.getIdByName(value);
                      SettingsBox().azVoiceId = VoiceManager.getIdByName(value);

                      FlutterToastr.show(
                          "Röst uppdaterad VALUE: $value", context,
                          duration: FlutterToastr.lengthLong,
                          position: FlutterToastr.bottom,
                          backgroundColor: Colors.green,
                          textStyle: const TextStyle(color: Colors.white));
                    },
                    selectedItem: VoiceManager.getNameById(myVoiceId),
                  ),
              child: AutoSizeText(
                VoiceManager.getNameById(myVoiceId),
                textAlign: TextAlign.center,
              )),
        ),
      ],
    );
  }
}
