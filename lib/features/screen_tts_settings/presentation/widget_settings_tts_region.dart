import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/cloud_text_to_speech/class_azure_region.dart';
import 'package:soundboard/properties.dart';

class SettingsTtsRegion extends ConsumerStatefulWidget {
  const SettingsTtsRegion({
    super.key,
  });

  @override
  ConsumerState<SettingsTtsRegion> createState() => _SettingsTtsRegionState();
}

class _SettingsTtsRegionState extends ConsumerState<SettingsTtsRegion> {
  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      print(SettingsBox().azRegionId);
    }
    final myRegionId = ref.watch(regionManagerProvider);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () => showMaterialScrollPicker<String>(
                    title: "Välj region",
                    context: context,
                    items: AzureRegionManager().getRegionsList(),
                    onChanged: (value) {
                      ref.read(regionManagerProvider.notifier).state =
                          AzureRegionManager().getIdByName(value);
                      SettingsBox().azRegionId =
                          AzureRegionManager().getIdByName(value);

                      ScaffoldMessenger.of(context)
                          .showMaterialBanner(MaterialBanner(
                        content: const Text(
                            "Omstart av applikationen krävs för att ändringarna ska slå igenom."),
                        elevation: 5,
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentMaterialBanner();
                            },
                            child: const Text("OK"),
                          ),
                        ],
                      ));
                    },
                    selectedItem: AzureRegionManager().getNameById(myRegionId),
                  ),
              child: AutoSizeText(
                AzureRegionManager().getNameById(myRegionId),
                textAlign: TextAlign.center,
              )),
        ),
      ],
    );
  }
}
