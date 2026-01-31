import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:soundboard/core/utils/logger.dart';

/// Manages profile-specific audio file directories
/// 
/// Directory structure:
/// AppCacheDirectory/
/// ├── profiles/
/// │   ├── {profile-id-1}/
/// │   │   ├── GenericJingles/
/// │   │   ├── GoalJingles/
/// │   │   ├── ClapJingles/
/// │   │   ├── PenaltyJingles/
/// │   │   ├── SpecialJingles/
/// │   │   └── GoalHorn/
/// │   ├── {profile-id-2}/
/// │   └── ...
/// └── legacy/ (for backward compatibility - old root-level jingles)
///     ├── GenericJingles/
///     ├── GoalJingles/
///     └── ...
class ProfileAudioManager {
  static const _logger = Logger('ProfileAudioManager');
  
  static const String profilesDir = 'profiles';
  static const String legacyDir = 'legacy';
  
  // Audio subdirectory names
  static const List<String> audioSubdirectories = [
    'GenericJingles',
    'GoalJingles',
    'ClapJingles',
    'PenaltyJingles',
    'SpecialJingles',
    'GoalHorn',
  ];

  /// Get the base profiles directory
  static Future<Directory> getProfilesBaseDir() async {
    final appCacheDir = await getApplicationCacheDirectory();
    final profilesDir = Directory(path.join(appCacheDir.path, ProfileAudioManager.profilesDir));
    if (!await profilesDir.exists()) {
      await profilesDir.create(recursive: true);
    }
    return profilesDir;
  }

  /// Get the audio directory for a specific profile
  static Future<Directory> getProfileAudioDir(String profileId) async {
    final profilesBase = await getProfilesBaseDir();
    final profileDir = Directory(path.join(profilesBase.path, profileId));
    if (!await profileDir.exists()) {
      await profileDir.create(recursive: true);
    }
    return profileDir;
  }

  /// Get a specific audio subdirectory for a profile
  static Future<Directory> getProfileAudioSubdir(
    String profileId,
    String subdirName,
  ) async {
    final profileDir = await getProfileAudioDir(profileId);
    final subdir = Directory(path.join(profileDir.path, subdirName));
    if (!await subdir.exists()) {
      await subdir.create(recursive: true);
    }
    return subdir;
  }

  /// Initialize all audio subdirectories for a profile
  static Future<void> initializeProfileAudioDirs(String profileId) async {
    _logger.d('Initializing audio directories for profile: $profileId');
    
    for (final subdirName in audioSubdirectories) {
      await getProfileAudioSubdir(profileId, subdirName);
    }
    
    _logger.d('Audio directories initialized for profile: $profileId');
  }

  /// Copy all audio files from one profile to another
  static Future<void> copyProfileAudio(
    String sourceProfileId,
    String targetProfileId,
  ) async {
    _logger.d('Copying audio from $sourceProfileId to $targetProfileId');
    
    try {
      final sourceDir = await getProfileAudioDir(sourceProfileId);
      final targetDir = await getProfileAudioDir(targetProfileId);

      // Copy each subdirectory
      for (final subdirName in audioSubdirectories) {
        final sourceSubdir = Directory(path.join(sourceDir.path, subdirName));
        final targetSubdir = Directory(path.join(targetDir.path, subdirName));

        if (await sourceSubdir.exists()) {
          await _copyDirectory(sourceSubdir, targetSubdir);
        }
      }

      _logger.d('Audio copied successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to copy profile audio', e, stackTrace);
      rethrow;
    }
  }

  /// Delete all audio files for a profile
  static Future<void> deleteProfileAudio(String profileId) async {
    _logger.d('Deleting audio for profile: $profileId');
    
    try {
      final profileDir = await getProfileAudioDir(profileId);
      
      if (await profileDir.exists()) {
        await profileDir.delete(recursive: true);
        _logger.d('Audio deleted successfully for profile: $profileId');
      } else {
        _logger.d('Profile audio directory does not exist: $profileId');
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to delete profile audio', e, stackTrace);
      rethrow;
    }
  }

  /// Check if legacy audio files exist (pre-profile system)
  static Future<bool> hasLegacyAudioFiles() async {
    final appCacheDir = await getApplicationCacheDirectory();
    
    // Check for any jingle directories at the root level
    for (final subdirName in audioSubdirectories) {
      final dir = Directory(path.join(appCacheDir.path, subdirName));
      if (await dir.exists()) {
        // Check if directory has any files
        await for (final entity in dir.list(followLinks: false)) {
          if (entity is File) {
            _logger.d('Found legacy audio files in: $subdirName');
            return true;
          }
        }
      }
    }
    
    return false;
  }

  /// Migrate legacy audio files to a specific profile
  static Future<void> migrateLegacyAudioToProfile(String profileId) async {
    _logger.d('Migrating legacy audio to profile: $profileId');
    
    try {
      final appCacheDir = await getApplicationCacheDirectory();
      final profileDir = await getProfileAudioDir(profileId);

      int filesMoved = 0;

      // Move each subdirectory
      for (final subdirName in audioSubdirectories) {
        final sourceDir = Directory(path.join(appCacheDir.path, subdirName));
        final targetDir = Directory(path.join(profileDir.path, subdirName));

        if (await sourceDir.exists()) {
          _logger.d('Migrating directory: $subdirName');
          
          // Ensure target directory exists
          if (!await targetDir.exists()) {
            await targetDir.create(recursive: true);
          }

          // Move all files
          await for (final entity in sourceDir.list(followLinks: false)) {
            if (entity is File) {
              final fileName = path.basename(entity.path);
              final targetFile = File(path.join(targetDir.path, fileName));
              
              try {
                await entity.rename(targetFile.path);
                filesMoved++;
                _logger.d('Moved: $fileName');
              } catch (e) {
                _logger.w('Failed to move file: $fileName', e);
                // Try copying instead
                try {
                  await entity.copy(targetFile.path);
                  await entity.delete();
                  filesMoved++;
                  _logger.d('Copied and deleted: $fileName');
                } catch (copyError) {
                  _logger.e('Failed to copy file: $fileName', copyError);
                }
              }
            }
          }

          // Delete the now-empty source directory
          try {
            if (await sourceDir.exists()) {
              final isEmpty = await sourceDir.list().isEmpty;
              if (isEmpty) {
                await sourceDir.delete();
                _logger.d('Deleted empty legacy directory: $subdirName');
              }
            }
          } catch (e) {
            _logger.w('Failed to delete legacy directory: $subdirName', e);
          }
        }
      }

      _logger.d('Legacy migration complete. Files moved: $filesMoved');
    } catch (e, stackTrace) {
      _logger.e('Failed to migrate legacy audio', e, stackTrace);
      rethrow;
    }
  }

  /// Helper method to copy directory contents
  static Future<void> _copyDirectory(Directory source, Directory target) async {
    if (!await target.exists()) {
      await target.create(recursive: true);
    }

    await for (final entity in source.list(followLinks: false)) {
      final entityName = path.basename(entity.path);
      
      if (entity is File) {
        final targetFile = File(path.join(target.path, entityName));
        await entity.copy(targetFile.path);
        _logger.d('Copied file: $entityName');
      } else if (entity is Directory) {
        final targetSubdir = Directory(path.join(target.path, entityName));
        await _copyDirectory(entity, targetSubdir);
      }
    }
  }

  /// Get the count of audio files in a profile directory
  static Future<int> getProfileAudioFileCount(String profileId) async {
    int count = 0;
    
    try {
      final profileDir = await getProfileAudioDir(profileId);
      
      if (await profileDir.exists()) {
        await for (final entity in profileDir.list(recursive: true, followLinks: false)) {
          if (entity is File) {
            count++;
          }
        }
      }
    } catch (e) {
      _logger.w('Failed to count audio files for profile: $profileId', e);
    }
    
    return count;
  }
}
