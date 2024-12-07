import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/properties.dart';

final selectedVenueProvider = StateProvider<int>((ref) {
  return SettingsBox().venueId;
});

final selectedFederationProvider = StateProvider<int>((ref) {
  return SettingsBox().federationId;
});
