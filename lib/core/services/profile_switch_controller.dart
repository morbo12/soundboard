import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/profile_providers.dart';
import 'package:soundboard/core/services/profile_service.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_config_notifier.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_grid_jingle_config.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

const Logger _logger = Logger('ProfileSwitchController');

/// Controller for switching between profiles
/// Handles stopping audio, applying settings, and reloading configurations
class ProfileSwitchController {
  final WidgetRef ref;
  final ProfileService profileService;

  ProfileSwitchController({
    required this.ref,
    required this.profileService,
  });

  /// Main method to switch to a different profile
  /// Returns true if successful, false otherwise
  Future<bool> switchToProfile(String profileId) async {
    _logger.d('Starting profile switch to: $profileId');

    try {
      // 1. Get the target profile
      final targetProfile = profileService.getProfile(profileId);
      if (targetProfile == null) {
        _logger.e('Profile not found: $profileId');
        return false;
      }

      // 2. Save current profile state before switching
      await _saveCurrentProfileState();

      // 3. Stop all audio playback
      await _stopAllAudio();

      // 4. Apply new profile settings to SettingsBox
      _applyProfileSettings(targetProfile);

      // 5. Reload grid configuration
      await _applyGridConfiguration(targetProfile);

      // 6. Update active profile in ProfileService
      await profileService.setActiveProfile(profileId);

      // 7. Reinitialize JingleManager with new profile ID
      await _reinitializeJingleManager(profileId);

      // 8. Notify providers
      _notifyProvidersOfSwitch();

      _logger.d('Profile switch completed successfully');
      return true;
    } catch (e, stackTrace) {
      _logger.e('Error switching profile', e, stackTrace);
      return false;
    }
  }

  /// Save the current profile's state (grid config, etc.)
  Future<void> _saveCurrentProfileState() async {
    try {
      final currentProfile = profileService.getActiveProfile();
      if (currentProfile == null) {
        _logger.w('No current profile to save');
        return;
      }

      _logger.d('Saving current profile state: ${currentProfile.name}');

      // Get current grid configuration
      final gridConfig = await _getCurrentGridConfiguration();

      // Update profile with current grid assignments
      final updatedProfile = currentProfile.copyWith(
        jingleAssignments: gridConfig,
        gridColumns: SettingsBox().gridColumns,
        gridRows: SettingsBox().gridRows,
      );

      await profileService.updateProfile(updatedProfile);
      _logger.d('Current profile state saved');
    } catch (e, stackTrace) {
      _logger.e('Error saving current profile state', e, stackTrace);
      // Continue with switch even if save fails
    }
  }

  /// Get current grid configuration as JSON
  Future<Map<String, dynamic>> _getCurrentGridConfiguration() async {
    try {
      final gridState = ref.read(jingleGridConfigProvider);
      final Map<String, dynamic> gridConfig = {};

      gridState.forEach((position, audioFile) {
        if (audioFile != null) {
          final config = GridJingleConfig.fromAudioFile(audioFile);
          if (config != null) {
            gridConfig[position.toString()] = config.toJson();
          }
        }
      });

      return gridConfig;
    } catch (e, stackTrace) {
      _logger.e('Error getting current grid configuration', e, stackTrace);
      return {};
    }
  }

  /// Stop all audio playback on both channels
  Future<void> _stopAllAudio() async {
    _logger.d('Stopping all audio playback');

    try {
      // Get JingleManager AsyncValue
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      
      // Access AudioManager through JingleManager
      await jingleManagerAsync.whenData((jingleManager) async {
        final audioManager = jingleManager.audioManager;
        
        // Stop both channels
        await audioManager.channel1.stop();
        await audioManager.channel2.stop();
        
        _logger.d('All audio stopped successfully');
      }).value;
    } catch (e, stackTrace) {
      _logger.e('Error stopping audio', e, stackTrace);
      // Continue with profile switch even if audio stop fails
    }
  }

  /// Apply profile settings to SettingsBox
  void _applyProfileSettings(TeamProfile profile) {
    _logger.d('Applying profile settings: ${profile.name}');
    
    // Use ProfileService's method to apply settings
    profileService.applyProfileToSettings(profile);
    
    _logger.d('Profile settings applied');
  }

  /// Apply grid configuration from profile
  Future<void> _applyGridConfiguration(TeamProfile profile) async {
    _logger.d('Applying grid configuration');

    try {
      // Update grid size
      final gridNotifier = ref.read(gridSettingsProvider.notifier);
      gridNotifier.updateSettings(profile.gridColumns, profile.gridRows);

      // Load grid jingle assignments
      final jingleGridNotifier = ref.read(jingleGridConfigProvider.notifier);
      
      if (profile.jingleAssignments.isEmpty) {
        _logger.d('No jingle assignments in profile, clearing grid');
        await jingleGridNotifier.clearAllAssignments();
        return;
      }

      // Build new grid state from profile assignments
      final Map<int, AudioFile?> newGridState = {};
      
      for (final entry in profile.jingleAssignments.entries) {
        try {
          final position = int.parse(entry.key);
          final configJson = entry.value as Map<String, dynamic>;
          final config = GridJingleConfig.fromJson(configJson);
          final audioFile = await config.toAudioFile();
          
          if (audioFile != null) {
            newGridState[position] = audioFile;
          }
        } catch (e) {
          _logger.w('Error parsing grid assignment at ${entry.key}: $e');
          continue;
        }
      }

      // Apply all assignments
      for (final entry in newGridState.entries) {
        await jingleGridNotifier.assignJingle(entry.key, entry.value!);
      }

      _logger.d('Grid configuration applied with ${newGridState.length} assignments');
    } catch (e, stackTrace) {
      _logger.e('Error applying grid configuration', e, stackTrace);
    }
  }

  /// Notify providers that profile has switched
  void _notifyProvidersOfSwitch() {
    _logger.d('Notifying providers of profile switch');

    // Refresh current profile provider
    ref.read(currentProfileProvider.notifier).refresh();

    // Increment profile change counter to trigger UI updates
    final counter = ref.read(profileChangeCounterProvider);
    ref.read(profileChangeCounterProvider.notifier).state = counter + 1;

    _logger.d('Providers notified');
  }

  /// Reinitialize JingleManager with new profile ID
  Future<void> _reinitializeJingleManager(String profileId) async {
    try {
      _logger.d('Reinitializing JingleManager for profile: $profileId');
      
      // Get the JingleManager notifier
      final jingleManagerNotifier = ref.read(jingleManagerProvider.notifier);
      
      // Reinitialize with the new profile ID
      await jingleManagerNotifier.reinitializeWithProfile(profileId);
      
      _logger.d('JingleManager reinitialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Error reinitializing JingleManager', e, stackTrace);
      // Don't throw - this is not critical enough to fail the entire switch
    }
  }
}
