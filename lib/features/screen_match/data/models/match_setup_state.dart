import 'package:flutter/foundation.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition_type.dart';

enum MatchFetchMode {
  venue,
  competition;

  String get displayName {
    switch (this) {
      case MatchFetchMode.venue:
        return 'Anläggning';
      case MatchFetchMode.competition:
        return 'Tävling/Turnering';
    }
  }
}

@immutable
class MatchSetupState {
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final int selectedVenue;
  final int selectedFederation;
  final MatchFetchMode matchFetchMode;
  final CompetitionType competitionType;
  final int? selectedCompetitionId;

  const MatchSetupState({
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    required this.selectedVenue,
    required this.selectedFederation,
    this.matchFetchMode = MatchFetchMode.venue,
    this.competitionType = CompetitionType.competition,
    this.selectedCompetitionId,
  });

  MatchSetupState copyWith({
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    int? selectedVenue,
    int? selectedFederation,
    MatchFetchMode? matchFetchMode,
    CompetitionType? competitionType,
    int? selectedCompetitionId,
  }) {
    return MatchSetupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      selectedFederation: selectedFederation ?? this.selectedFederation,
      matchFetchMode: matchFetchMode ?? this.matchFetchMode,
      competitionType: competitionType ?? this.competitionType,
      selectedCompetitionId:
          selectedCompetitionId ?? this.selectedCompetitionId,
    );
  }
}
