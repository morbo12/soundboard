import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/properties.dart';

/// Provider for sponsor enabled state
final sponsorEnabledProvider = StateProvider<bool>((ref) {
  return SettingsBox().sponsorEnabled;
});

/// Provider for main sponsor name
final mainSponsorProvider = StateProvider<String>((ref) {
  return SettingsBox().mainSponsor;
});

/// Provider for other sponsors list
final otherSponsorsProvider = StateProvider<List<String>>((ref) {
  return SettingsBox().otherSponsors;
});

/// Provider for kiosk enabled state
final kioskEnabledProvider = StateProvider<bool>((ref) {
  return SettingsBox().kioskEnabled;
});

/// Provider for kiosk message text
final kioskMessageProvider = StateProvider<String>((ref) {
  return SettingsBox().kioskMessage;
});
