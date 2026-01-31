import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/services/profile_service.dart';
import 'package:soundboard/core/utils/logger.dart';

const Logger _logger = Logger('ProfileProviders');

/// Provider for the ProfileService singleton
final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

/// Provider for the list of all profiles
final profileListProvider = StateNotifierProvider<ProfileListNotifier, List<TeamProfile>>((ref) {
  return ProfileListNotifier(ref.read(profileServiceProvider));
});

class ProfileListNotifier extends StateNotifier<List<TeamProfile>> {
  final ProfileService _profileService;

  ProfileListNotifier(this._profileService) : super([]) {
    _loadProfiles();
  }

  void _loadProfiles() {
    state = _profileService.getAllProfiles();
  }

  Future<void> refresh() async {
    _loadProfiles();
  }

  Future<TeamProfile> createProfile({
    required String name,
    String description = '',
    TeamProfile? copyFrom,
  }) async {
    final profile = await _profileService.createProfile(
      name: name,
      description: description,
      copyFrom: copyFrom,
    );
    _loadProfiles();
    return profile;
  }

  Future<void> updateProfile(TeamProfile profile) async {
    await _profileService.updateProfile(profile);
    _loadProfiles();
  }

  Future<bool> deleteProfile(String profileId) async {
    final success = await _profileService.deleteProfile(profileId);
    if (success) {
      _loadProfiles();
    }
    return success;
  }
}

/// Provider for the currently active profile
final currentProfileProvider = StateNotifierProvider<CurrentProfileNotifier, TeamProfile?>((ref) {
  return CurrentProfileNotifier(ref.read(profileServiceProvider));
});

class CurrentProfileNotifier extends StateNotifier<TeamProfile?> {
  final ProfileService _profileService;

  CurrentProfileNotifier(this._profileService) : super(null) {
    _loadCurrentProfile();
  }

  void _loadCurrentProfile() {
    state = _profileService.getActiveProfile();
  }

  Future<void> setProfile(String profileId) async {
    await _profileService.setActiveProfile(profileId);
    _loadCurrentProfile();
  }

  void refresh() {
    _loadCurrentProfile();
  }
}

/// Provider for profile switching state (loading indicator)
final profileSwitchingProvider = StateProvider<bool>((ref) => false);

/// Provider to check if profile name exists
final profileNameExistsProvider = Provider.family<bool, ({String name, String? excludeId})>((ref, params) {
  final service = ref.read(profileServiceProvider);
  return service.profileNameExists(params.name, excludeId: params.excludeId);
});

/// Legacy providers for backward compatibility
@Deprecated('Use currentProfileProvider instead')
final activeProfileProvider = StateProvider<TeamProfile?>((ref) {
  return ref.watch(currentProfileProvider);
});

@Deprecated('Use profileListProvider instead')
final allProfilesProvider = StateProvider<List<TeamProfile>>((ref) {
  return ref.watch(profileListProvider);
});

/// Simple counter provider to trigger UI updates when profiles change
final profileChangeCounterProvider = StateProvider<int>((ref) => 0);

