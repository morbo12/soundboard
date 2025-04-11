import 'package:flutter/foundation.dart';

@immutable
class MatchSetupState {
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final int selectedVenue;
  final int selectedFederation;

  const MatchSetupState({
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    required this.selectedVenue,
    required this.selectedFederation,
  });

  MatchSetupState copyWith({
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    int? selectedVenue,
    int? selectedFederation,
  }) {
    return MatchSetupState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedVenue: selectedVenue ?? this.selectedVenue,
      selectedFederation: selectedFederation ?? this.selectedFederation,
    );
  }
}
