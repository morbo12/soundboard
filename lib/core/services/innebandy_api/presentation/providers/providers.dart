import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/properties.dart';

final selectedVenueProvider = StateProvider<int>((ref) {
  return SettingsBox().venueId;
});

final selectedFederationProvider = StateProvider<int>((ref) {
  return SettingsBox().federationId;
});
