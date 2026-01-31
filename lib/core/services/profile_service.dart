import 'package:hive/hive.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Service for managing team profiles
/// Handles CRUD operations and profile switching
class ProfileService {
  static const Logger _logger = Logger('ProfileService');
  static const String _boxName = 'team_profiles';
  static const String _activeProfileKey = 'active_profile_id';

  Box<TeamProfile>? _profileBox;
  Box<String>? _settingsBox;

  /// Singleton
  static final ProfileService _instance = ProfileService._();
  factory ProfileService() => _instance;
  ProfileService._();

  /// Initialize the profile service
  Future<void> initialize() async {
    try {
      _profileBox = await Hive.openBox<TeamProfile>(_boxName);
      _settingsBox = await Hive.openBox<String>('profile_settings');
      _logger.d('ProfileService initialized');
      
      // Create a default profile if none exist
      if (_profileBox!.isEmpty) {
        await _createDefaultProfile();
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize ProfileService', e, stackTrace);
      rethrow;
    }
  }

  /// Creates a default profile from current settings
  Future<TeamProfile> _createDefaultProfile() async {
    _logger.d('Creating default profile');
    
    final defaultProfile = TeamProfile(
      name: 'Default Team',
      description: 'Default team profile',
      isDefault: true,
      gridColumns: 6,
      gridRows: 5,
    );

    await _profileBox!.put(defaultProfile.id, defaultProfile);
    await setActiveProfile(defaultProfile.id);
    
    _logger.d('Default profile created: ${defaultProfile.id}');
    return defaultProfile;
  }

  /// Get all profiles
  List<TeamProfile> getAllProfiles() {
    if (_profileBox == null) {
      _logger.w('ProfileBox not initialized');
      return [];
    }
    
    final profiles = _profileBox!.values.toList();
    // Sort by lastUsed, most recent first
    profiles.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return profiles;
  }

  /// Get profile by ID
  TeamProfile? getProfile(String id) {
    if (_profileBox == null) {
      _logger.w('ProfileBox not initialized');
      return null;
    }
    return _profileBox!.get(id);
  }

  /// Get the currently active profile
  TeamProfile? getActiveProfile() {
    final activeId = _settingsBox?.get(_activeProfileKey);
    if (activeId == null) {
      _logger.w('No active profile set');
      // Return first available profile or create default
      final profiles = getAllProfiles();
      if (profiles.isNotEmpty) {
        return profiles.first;
      }
      return null;
    }
    return getProfile(activeId);
  }

  /// Get the active profile ID
  String? getActiveProfileId() {
    return _settingsBox?.get(_activeProfileKey);
  }

  /// Set the active profile
  Future<void> setActiveProfile(String profileId) async {
    if (_settingsBox == null) {
      _logger.w('Settings box not initialized');
      return;
    }

    final profile = getProfile(profileId);
    if (profile == null) {
      _logger.w('Profile not found: $profileId');
      return;
    }

    await _settingsBox!.put(_activeProfileKey, profileId);
    
    // Update lastUsed timestamp
    profile.markAsUsed();
    await _profileBox!.put(profileId, profile);
    
    _logger.d('Active profile set to: $profileId (${profile.name})');
  }

  /// Create a new profile
  Future<TeamProfile> createProfile({
    required String name,
    String description = '',
    TeamProfile? copyFrom,
  }) async {
    if (_profileBox == null) {
      throw Exception('ProfileBox not initialized');
    }

    TeamProfile newProfile;
    
    if (copyFrom != null) {
      // Copy settings from existing profile
      newProfile = copyFrom.copyWith(
        name: name,
        description: description,
      );
    } else {
      // Create new profile with defaults
      newProfile = TeamProfile(
        name: name,
        description: description,
      );
    }

    await _profileBox!.put(newProfile.id, newProfile);
    _logger.d('Profile created: ${newProfile.id} (${newProfile.name})');
    
    return newProfile;
  }

  /// Update an existing profile
  Future<void> updateProfile(TeamProfile profile) async {
    if (_profileBox == null) {
      throw Exception('ProfileBox not initialized');
    }

    await _profileBox!.put(profile.id, profile);
    _logger.d('Profile updated: ${profile.id} (${profile.name})');
  }

  /// Delete a profile
  Future<bool> deleteProfile(String profileId) async {
    if (_profileBox == null) {
      throw Exception('ProfileBox not initialized');
    }

    final profile = getProfile(profileId);
    if (profile == null) {
      _logger.w('Profile not found: $profileId');
      return false;
    }

    // Don't delete if it's the only profile
    if (_profileBox!.length <= 1) {
      _logger.w('Cannot delete the only profile');
      return false;
    }

    // If deleting the active profile, switch to another one
    if (getActiveProfileId() == profileId) {
      final profiles = getAllProfiles();
      final otherProfile = profiles.firstWhere((p) => p.id != profileId);
      await setActiveProfile(otherProfile.id);
    }

    await _profileBox!.delete(profileId);
    _logger.d('Profile deleted: $profileId (${profile.name})');
    
    return true;
  }

  /// Get profile count
  int getProfileCount() {
    return _profileBox?.length ?? 0;
  }

  /// Check if a profile name already exists
  bool profileNameExists(String name, {String? excludeId}) {
    if (_profileBox == null) return false;
    
    return _profileBox!.values.any((profile) => 
      profile.name.toLowerCase() == name.toLowerCase() && 
      profile.id != excludeId
    );
  }

  /// Export a profile to JSON
  Map<String, dynamic> exportProfile(String profileId) {
    final profile = getProfile(profileId);
    if (profile == null) {
      throw Exception('Profile not found: $profileId');
    }

    return {
      'name': profile.name,
      'description': profile.description,
      'colorTheme': profile.colorTheme,
      'sponsorEnabled': profile.sponsorEnabled,
      'mainSponsor': profile.mainSponsor,
      'otherSponsors': profile.otherSponsors,
      'kioskEnabled': profile.kioskEnabled,
      'kioskMessage': profile.kioskMessage,
      'homeJingleFilePath': profile.homeJingleFilePath,
      'awayJingleFilePath': profile.awayJingleFilePath,
      'gridColumns': profile.gridColumns,
      'gridRows': profile.gridRows,
      'ssmlWelcomeTemplate': profile.ssmlWelcomeTemplate,
      'ssmlLineupTemplate': profile.ssmlLineupTemplate,
      'ssmlRefereeTemplate': profile.ssmlRefereeTemplate,
      'azVoiceName': profile.azVoiceName,
      'ttsVolume': profile.ttsVolume,
      'backgroundVolumeLevel': profile.backgroundVolumeLevel,
      'mainVolume': profile.mainVolume,
      'spotifyUri': profile.spotifyUri,
      'spotifyUrl': profile.spotifyUrl,
      'jingleAssignments': profile.jingleAssignments,
    };
  }

  /// Import a profile from JSON
  Future<TeamProfile> importProfile(Map<String, dynamic> json) async {
    final profile = TeamProfile(
      name: json['name'] ?? 'Imported Profile',
      description: json['description'] ?? '',
      colorTheme: json['colorTheme'],
      sponsorEnabled: json['sponsorEnabled'] ?? false,
      mainSponsor: json['mainSponsor'] ?? '',
      otherSponsors: (json['otherSponsors'] as List?)?.cast<String>() ?? [],
      kioskEnabled: json['kioskEnabled'] ?? false,
      kioskMessage: json['kioskMessage'] ?? '',
      homeJingleFilePath: json['homeJingleFilePath'] ?? '',
      awayJingleFilePath: json['awayJingleFilePath'] ?? '',
      gridColumns: json['gridColumns'] ?? 6,
      gridRows: json['gridRows'] ?? 5,
      ssmlWelcomeTemplate: json['ssmlWelcomeTemplate'],
      ssmlLineupTemplate: json['ssmlLineupTemplate'],
      ssmlRefereeTemplate: json['ssmlRefereeTemplate'],
      azVoiceName: json['azVoiceName'],
      ttsVolume: json['ttsVolume'] ?? 1.0,
      backgroundVolumeLevel: json['backgroundVolumeLevel'] ?? 0.5,
      mainVolume: json['mainVolume'] ?? 1.0,
      spotifyUri: json['spotifyUri'],
      spotifyUrl: json['spotifyUrl'],
      jingleAssignments: json['jingleAssignments'] ?? {},
    );

    await _profileBox!.put(profile.id, profile);
    _logger.d('Profile imported: ${profile.id} (${profile.name})');
    
    return profile;
  }

  /// Close the service
  Future<void> close() async {
    await _profileBox?.close();
    await _settingsBox?.close();
    _logger.d('ProfileService closed');
  }
}
