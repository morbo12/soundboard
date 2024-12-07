import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_federations.dart';
import 'package:soundboard/features/innebandy_api/data/providers.dart';
import 'package:soundboard/properties.dart';

class FederationSelector extends ConsumerStatefulWidget {
  const FederationSelector({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FederationSelectorState();
}

class _FederationSelectorState extends ConsumerState<FederationSelector> {
  @override
  Widget build(BuildContext context) {
    // Use Lyckeby as default
    // final selectedVenue = ref.watch(selectedVenueProvider);
    // ref.read(selectedVenueProvider.notifier).state =
    //     ArenasInStockholm.getIdByName("Lyckeby Sporthall");
    final federationId = ref.watch(selectedFederationProvider);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => showMaterialScrollPicker<String>(
              title: "Välj förbund",
              context: context,
              items: Federation.getFacilitiesList(),
              onChanged: (value) {
                ref.read(selectedVenueProvider.notifier).state =
                    Federation.getIdByName(value);
                SettingsBox().federationId = Federation.getIdByName(value);
              },
              selectedItem: Federation.getNameById(federationId),
            ),
            child: federationId != 0
                ? AutoSizeText(
                    Federation.getNameById(federationId),
                    textAlign: TextAlign.center,
                  )
                : const AutoSizeText(
                    "Välj förbund",
                    // minFontSize: 24,
                  ),
          ),
        ),
      ],
    );
  }
}
