import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/innebandy_api/data/class_federations.dart';
import 'package:soundboard/features/innebandy_api/data/class_arena.dart';
import 'package:soundboard/features/innebandy_api/data/class_match.dart';
import 'package:soundboard/features/screen_match/application/match_setup_service.dart';
import 'package:soundboard/features/screen_match/data/models/match_setup_state.dart';
import 'package:soundboard/properties.dart';

final matchSetupServiceProvider = Provider((ref) => MatchSetupService(ref));

final matchSetupStateProvider =
    StateNotifierProvider<MatchSetupStateNotifier, MatchSetupState>((ref) {
      final settingsBox = SettingsBox();
      return MatchSetupStateNotifier(
        ref,
        initialVenue: settingsBox.venueId,
        initialFederation: settingsBox.federationId,
      );
    });

class MatchSetupStateNotifier extends StateNotifier<MatchSetupState> {
  final Ref ref;

  MatchSetupStateNotifier(
    this.ref, {
    required int initialVenue,
    required int initialFederation,
  }) : super(
         MatchSetupState(
           selectedDate: DateTime.now(),
           selectedVenue: initialVenue,
           selectedFederation: initialFederation,
         ),
       );

  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void updateVenue(int venueId) {
    state = state.copyWith(selectedVenue: venueId);
  }

  void updateFederation(int federationId) {
    state = state.copyWith(selectedFederation: federationId);
  }
}

final matchesProvider = StateProvider<List<IbyMatch>>((ref) => []);

final federationsProvider = Provider<List<FederationItem>>((ref) {
  return Federation.federations.entries
      .map((entry) => FederationItem(id: entry.key, name: entry.value))
      .toList();
});

final venuesProvider = Provider<List<VenueItem>>((ref) {
  return ArenasInStockholm.facilities.entries
      .map((entry) => VenueItem(id: entry.key, name: entry.value))
      .toList();
});

class FederationItem {
  final int id;
  final String name;

  FederationItem({required this.id, required this.name});
}

class VenueItem {
  final int id;
  final String name;

  VenueItem({required this.id, required this.name});
}
