import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_arena.dart';
import 'package:soundboard/features/innebandy_api/data/providers.dart';
import 'package:soundboard/properties.dart';

class VenueSelector extends ConsumerStatefulWidget {
  const VenueSelector({super.key});

  @override
  ConsumerState<VenueSelector> createState() => _VenueSelectorState();
}

class _VenueSelectorState extends ConsumerState<VenueSelector> {
  @override
  Widget build(BuildContext context) {
    // Use Lyckeby as default
    // final selectedVenue = ref.watch(selectedVenueProvider);
    // ref.read(selectedVenueProvider.notifier).state =
    //     ArenasInStockholm.getIdByName("Lyckeby Sporthall");
    final venueID = ref.watch(selectedVenueProvider);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => showMaterialScrollPicker<String>(
              title: "Välj hall",
              context: context,
              items: ArenasInStockholm.getFacilitiesList(),
              onChanged: (value) {
                ref.read(selectedVenueProvider.notifier).state =
                    ArenasInStockholm.getIdByName(value);
                SettingsBox().venueId = ArenasInStockholm.getIdByName(value);
              },
              selectedItem: ArenasInStockholm.getNameById(venueID),
            ),
            child: venueID != 0
                ? AutoSizeText(
                    ArenasInStockholm.getNameById(venueID),
                    textAlign: TextAlign.center,
                  )
                : const AutoSizeText(
                    "Välj Anläggning",
                    // minFontSize: 24,
                  ),
          ),
        ),
      ],
    );
  }
}
