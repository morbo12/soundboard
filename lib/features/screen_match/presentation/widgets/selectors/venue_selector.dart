import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

class VenueSelector extends ConsumerWidget {
  const VenueSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final venues = ref.watch(venuesProvider);
    final selectedVenue = ref.watch(matchSetupStateProvider).selectedVenue;

    return DropdownButton<int>(
      value: selectedVenue,
      isExpanded: true,
      items:
          venues.map((venue) {
            return DropdownMenuItem<int>(
              value: venue.id,
              child: Text(venue.name),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(matchSetupStateProvider.notifier).updateVenue(value);
        }
      },
    );
  }
}
