import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundboard/core/services/innebandy_api/domain/entities/arena.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/federation.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/screen_match/application/match_setup_service.dart';
import 'package:soundboard/features/screen_match/data/models/match_setup_state.dart';
import 'package:soundboard/core/properties.dart';

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

/// State notifier for managing the match setup state.
///
/// Handles all state updates for the match setup process, including:
/// - Date selection
/// - Venue selection
/// - Federation selection
/// - Loading states
/// - Error states
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

  /// Updates the selected date and resets loading/error states.
  void updateDate(DateTime date) {
    state = state.copyWith(selectedDate: date, isLoading: false, error: null);
  }

  /// Updates the selected venue and resets loading/error states.
  void updateVenue(int venueId) {
    state = state.copyWith(
      selectedVenue: venueId,
      isLoading: false,
      error: null,
    );
  }

  /// Updates the selected federation and resets loading/error states.
  void updateFederation(int federationId) {
    state = state.copyWith(
      selectedFederation: federationId,
      isLoading: false,
      error: null,
    );
  }

  /// Sets the loading state.
  void setLoading(bool isLoading) {
    state = state.copyWith(isLoading: isLoading, error: null);
  }

  /// Sets the error state.
  void setError(String? error) {
    state = state.copyWith(isLoading: false, error: error);
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

/// Represents a federation with its ID and name.
class FederationItem {
  final int id;
  final String name;

  FederationItem({required this.id, required this.name});
}

/// Represents a venue with its ID and name.
class VenueItem {
  final int id;
  final String name;

  VenueItem({required this.id, required this.name});
}
