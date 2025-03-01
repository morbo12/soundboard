import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
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
    final venueID = ref.watch(selectedVenueProvider);

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => _selectVenue(context),
            child: venueID != 0
                ? AutoSizeText(
                    ArenasInStockholm.getNameById(venueID),
                    textAlign: TextAlign.center,
                  )
                : const AutoSizeText(
                    "Välj Anläggning",
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ],
    );
  }

  void _selectVenue(BuildContext context) {
    final venueList = ArenasInStockholm.getFacilitiesList();
    final currentVenueId = ref.read(selectedVenueProvider);

    showModalBottomSheet(
      context: context,
      builder: (context) => ListView.builder(
        itemCount: venueList.length,
        itemBuilder: (context, index) {
          final venue = venueList[index];
          final isSelected =
              ArenasInStockholm.getIdByName(venue) == currentVenueId;

          return ListTile(
            title: Text(venue),
            selected: isSelected,
            onTap: () {
              final id = ArenasInStockholm.getIdByName(venue);
              ref.read(selectedVenueProvider.notifier).state = id;
              SettingsBox().venueId = id;
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
