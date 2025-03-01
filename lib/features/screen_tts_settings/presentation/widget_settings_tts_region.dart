import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
              onPressed: () => _showRegionPicker(context, ref, myRegionId),
              child: AutoSizeText(
                AzureRegionManager().getNameById(myRegionId),
                textAlign: TextAlign.center,
              )),
        ),
      ],
    );
  }

  void _showRegionPicker(BuildContext context, WidgetRef ref, int myRegionId) {
    final regionList = AzureRegionManager().getRegionsList();
    final selectedRegion = AzureRegionManager().getNameById(myRegionId);

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
                "Välj region",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: regionList.length,
                itemBuilder: (context, index) {
                  final region = regionList[index];
                  return ListTile(
                    title: Text(region),
                    selected: region == selectedRegion,
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    onTap: () {
                      // Update the selected region
                      final regionId = AzureRegionManager().getIdByName(region);
                      ref.read(regionManagerProvider.notifier).state = regionId;
                      SettingsBox().azRegionId = regionId;

                      // Close the bottom sheet
                      Navigator.pop(context);

                      // Show the material banner for restart notification
                      ScaffoldMessenger.of(context).showMaterialBanner(
                        MaterialBanner(
                          content: const Text(
                            "Omstart av applikationen krävs för att ändringarna ska slå igenom.",
                          ),
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
                        ),
                      );
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
