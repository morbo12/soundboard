import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundboard/core/services/innebandy_api/domain/entities/arena.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition_type.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/federation.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';
import 'package:soundboard/features/screen_match/application/match_setup_service.dart';
import 'package:soundboard/features/screen_match/data/models/match_setup_state.dart';
import 'package:soundboard/features/screen_match/data/mockup/match_mockup_data.dart';
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
    // Persist venue selection to settings
    final settingsBox = SettingsBox();
    settingsBox.venueId = venueId;
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

  /// Updates the match fetch mode (venue or competition).
  void updateMatchFetchMode(MatchFetchMode mode) {
    state = state.copyWith(matchFetchMode: mode, isLoading: false, error: null);
  }

  /// Updates the competition type (competition or tournament).
  void updateCompetitionType(CompetitionType type) {
    state = state.copyWith(
      competitionType: type,
      selectedCompetitionId: null, // Reset selection when type changes
      isLoading: false,
      error: null,
    );
  }

  /// Updates the selected competition/tournament ID.
  void updateCompetitionId(int? competitionId) {
    state = state.copyWith(
      selectedCompetitionId: competitionId,
      isLoading: false,
      error: null,
    );
  }
}

/// Provider for the list of available matches.
/// In debug mode, always includes a mockup match at the top of the list for showcase purposes.
final matchesProvider = StateProvider<List<IbyMatch>>((ref) {
  if (kDebugMode) {
    return [MatchMockupData.getMockupMatch()];
  }
  return [];
});

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

/// Represents a competition or tournament with its ID and name.
class CompetitionItem {
  final int id;
  final String name;

  CompetitionItem({required this.id, required this.name});
}
