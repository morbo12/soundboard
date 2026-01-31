import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/services/profile_service.dart';

/// Provider for the ProfileService singleton
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Provider for the currently active profile
final activeProfileProvider = StateProvider<TeamProfile?>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getActiveProfile();
});

/// Provider for all profiles
final allProfilesProvider = StateProvider<List<TeamProfile>>((ref) {
  final profileService = ref.watch(profileServiceProvider);
  return profileService.getAllProfiles();
});

/// Simple counter provider to trigger UI updates when profiles change
final profileChangeCounterProvider = StateProvider<int>((ref) => 0);
