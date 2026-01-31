import 'package:hive/hive.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/utils/profile_audio_manager.dart';
import 'package:soundboard/core/properties.dart';

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
    _logger.d('Creating default profile from current settings');
    
    final defaultProfile = createProfileFromCurrentSettings(
      name: 'Default Profile',
      description: 'Migrated from existing settings',
    );

    await _profileBox!.put(defaultProfile.id, defaultProfile);
    await setActiveProfile(defaultProfile.id);
    
    _logger.d('Default profile created: ${defaultProfile.id}');
    return defaultProfile;
  }

  /// Create a TeamProfile from current SettingsBox values
  TeamProfile createProfileFromCurrentSettings({
    required String name,
    String description = '',
  }) {
    final settings = SettingsBox();
    
    return TeamProfile(
      name: name,
      description: description,
      colorTheme: settings.myColorTheme,
      sponsorEnabled: settings.sponsorEnabled,
      mainSponsor: settings.mainSponsor,
      otherSponsors: settings.otherSponsors,
      kioskEnabled: settings.kioskEnabled,
      kioskMessage: settings.kioskMessage,
      homeJingleFilePath: settings.homeJingleFilePath,
      awayJingleFilePath: settings.awayJingleFilePath,
      gridColumns: settings.gridColumns,
      gridRows: settings.gridRows,
      ssmlWelcomeTemplate: settings.ssmlWelcomeTemplate,
      ssmlLineupTemplate: settings.ssmlLineupTemplate,
      ssmlRefereeTemplate: settings.ssmlRefereeTemplate,
      azVoiceName: settings.azVoiceName,
      ttsVolume: settings.ttsVolume,
      backgroundVolumeLevel: settings.backgroundVolumeLevel,
      mainVolume: settings.mainVolume,
      p1Volume: settings.p1Volume,
      p2Volume: settings.p2Volume,
      p3Volume: settings.p3Volume,
      spotifyUri: settings.spotifyUri,
      spotifyUrl: settings.spotifyUrl,
      musicPlayerInitialVolume: settings.musicPlayerInitialVolume,
      apiProductKey: settings.apiProductKey,
      apiDeviceId: settings.apiDeviceId,
      azTtsKey: settings.azTtsKey,
      azVoiceId: settings.azVoiceId,
      azRegionId: settings.azRegionId,
      venueId: settings.venueId,
      federationId: settings.federationId,
      serialPortName: settings.serialPortName,
      serialBaudRate: settings.serialBaudRate,
      serialAutoConnect: settings.serialAutoConnect,
      isDefault: false,
      // Note: jingleAssignments will be loaded separately from grid config
    );
  }

  /// Apply a profile's settings to SettingsBox
  void applyProfileToSettings(TeamProfile profile) {
    _logger.d('Applying profile ${profile.name} to SettingsBox');
    
    final settings = SettingsBox();
    
    // Apply all settings
    if (profile.colorTheme != null) {
      settings.myColorTheme = profile.colorTheme!;
    }
    settings.sponsorEnabled = profile.sponsorEnabled;
    settings.mainSponsor = profile.mainSponsor;
    settings.otherSponsors = profile.otherSponsors;
    settings.kioskEnabled = profile.kioskEnabled;
    settings.kioskMessage = profile.kioskMessage;
    settings.homeJingleFilePath = profile.homeJingleFilePath;
    settings.awayJingleFilePath = profile.awayJingleFilePath;
    settings.gridColumns = profile.gridColumns;
    settings.gridRows = profile.gridRows;
    
    if (profile.ssmlWelcomeTemplate != null) {
      settings.ssmlWelcomeTemplate = profile.ssmlWelcomeTemplate!;
    }
    if (profile.ssmlLineupTemplate != null) {
      settings.ssmlLineupTemplate = profile.ssmlLineupTemplate!;
    }
    if (profile.ssmlRefereeTemplate != null) {
      settings.ssmlRefereeTemplate = profile.ssmlRefereeTemplate!;
    }
    if (profile.azVoiceName != null) {
      settings.azVoiceName = profile.azVoiceName!;
    }
    
    settings.ttsVolume = profile.ttsVolume;
    settings.backgroundVolumeLevel = profile.backgroundVolumeLevel;
    settings.mainVolume = profile.mainVolume;
    settings.p1Volume = profile.p1Volume;
    settings.p2Volume = profile.p2Volume;
    settings.p3Volume = profile.p3Volume;
    
    if (profile.spotifyUri != null) {
      settings.spotifyUri = profile.spotifyUri!;
    }
    if (profile.spotifyUrl != null) {
      settings.spotifyUrl = profile.spotifyUrl!;
    }
    settings.musicPlayerInitialVolume = profile.musicPlayerInitialVolume;
    
    settings.apiProductKey = profile.apiProductKey;
    settings.apiDeviceId = profile.apiDeviceId;
    settings.azTtsKey = profile.azTtsKey;
    settings.azVoiceId = profile.azVoiceId;
    settings.azRegionId = profile.azRegionId;
    settings.venueId = profile.venueId;
    settings.federationId = profile.federationId;
    settings.serialPortName = profile.serialPortName;
    settings.serialBaudRate = profile.serialBaudRate;
    settings.serialAutoConnect = profile.serialAutoConnect;
    
    _logger.d('Profile settings applied successfully');
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
    
    // Only handle profile-scoped audio when we NOW have multiple profiles
    // This triggers the switch from single-profile (legacy paths) to multi-profile mode
    final willBeMultiProfile = getProfileCount() > 1;
    
    if (willBeMultiProfile) {
      _logger.d('Multi-profile mode activated - initializing profile-scoped audio');
      
      // Initialize audio directories for the new profile
      try {
        await ProfileAudioManager.initializeProfileAudioDirs(newProfile.id);
        _logger.d('Audio directories initialized for profile: ${newProfile.id}');
        
        // If copying from another profile, copy audio files
        if (copyFrom != null) {
          _logger.d('Copying audio files from ${copyFrom.id} to ${newProfile.id}');
          
          // First, check if source profile has audio at legacy location
          // If so, it needs to be migrated before copying
          final hasLegacy = await ProfileAudioManager.hasLegacyAudioFiles();
          if (hasLegacy) {
            _logger.d('Migrating legacy audio to source profile before copying');
            await ProfileAudioManager.migrateLegacyAudioToProfile(copyFrom.id);
          }
          
          await ProfileAudioManager.copyProfileAudio(copyFrom.id, newProfile.id);
          _logger.d('Audio files copied successfully');
        }
      } catch (e, stackTrace) {
        _logger.e('Failed to handle audio files for new profile', e, stackTrace);
        // Don't throw - profile is already created, just log the error
      }
    } else {
      _logger.d('Single profile mode - using legacy audio paths');
    }
    
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

    // Only delete profile-scoped audio if we're currently in multi-profile mode
    // (If going from 2 profiles to 1, the remaining profile will use legacy paths)
    if (isMultiProfileMode()) {
      try {
        _logger.d('Deleting audio files for profile: $profileId');
        await ProfileAudioManager.deleteProfileAudio(profileId);
        _logger.d('Audio files deleted successfully');
      } catch (e, stackTrace) {
        _logger.e('Failed to delete audio files for profile', e, stackTrace);
        // Continue with profile deletion even if audio cleanup fails
      }
    } else {
      _logger.d('Last profile being deleted - will revert to single-profile mode with legacy paths');
    }

    await _profileBox!.delete(profileId);
    _logger.d('Profile deleted: $profileId (${profile.name})');
    
    return true;
  }

  /// Get profile count
  int getProfileCount() {
    return _profileBox?.length ?? 0;
  }

  /// Check if multi-profile mode is enabled
  /// Returns true if there are 2 or more profiles
  bool isMultiProfileMode() {
    return getProfileCount() > 1;
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
      'p1Volume': profile.p1Volume,
      'p2Volume': profile.p2Volume,
      'p3Volume': profile.p3Volume,
      'spotifyUri': profile.spotifyUri,
      'spotifyUrl': profile.spotifyUrl,
      'musicPlayerInitialVolume': profile.musicPlayerInitialVolume,
      'apiProductKey': profile.apiProductKey,
      'apiDeviceId': profile.apiDeviceId,
      'azTtsKey': profile.azTtsKey,
      'azVoiceId': profile.azVoiceId,
      'azRegionId': profile.azRegionId,
      'venueId': profile.venueId,
      'federationId': profile.federationId,
      'serialPortName': profile.serialPortName,
      'serialBaudRate': profile.serialBaudRate,
      'serialAutoConnect': profile.serialAutoConnect,
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
      gridColumns: json['gridColumns'] ?? 3,
      gridRows: json['gridRows'] ?? 4,
      ssmlWelcomeTemplate: json['ssmlWelcomeTemplate'],
      ssmlLineupTemplate: json['ssmlLineupTemplate'],
      ssmlRefereeTemplate: json['ssmlRefereeTemplate'],
      azVoiceName: json['azVoiceName'],
      ttsVolume: json['ttsVolume'] ?? 0.3,
      backgroundVolumeLevel: json['backgroundVolumeLevel'] ?? 0.1,
      mainVolume: json['mainVolume'] ?? 0.3,
      p1Volume: json['p1Volume'] ?? 0.3,
      p2Volume: json['p2Volume'] ?? 0.3,
      p3Volume: json['p3Volume'] ?? 0.3,
      spotifyUri: json['spotifyUri'],
      spotifyUrl: json['spotifyUrl'],
      musicPlayerInitialVolume: json['musicPlayerInitialVolume'] ?? 0.1,
      apiProductKey: json['apiProductKey'] ?? '',
      apiDeviceId: json['apiDeviceId'] ?? '',
      azTtsKey: json['azTtsKey'] ?? 'NoKey',
      azVoiceId: json['azVoiceId'] ?? 1,
      azRegionId: json['azRegionId'] ?? 2,
      venueId: json['venueId'] ?? 3455,
      federationId: json['federationId'] ?? 8,
      serialPortName: json['serialPortName'] ?? '',
      serialBaudRate: json['serialBaudRate'] ?? 9600,
      serialAutoConnect: json['serialAutoConnect'] ?? false,
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
