import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../utils/logger.dart';
import '../../services/profile_service.dart';

class FileSystemHelper {
  static final _logger = const Logger('FileSystemHelper');

  // Old app ID path component
  static const String _oldAppId = 'io.lyxell';
  // New app ID path component
  static const String _newAppId = 'eu.fbtools';

  // Profile ID for current context (null means legacy mode)
  String? _currentProfileId;

  /// Set the current profile ID for this FileSystemHelper instance
  void setProfileId(String? profileId) {
    _currentProfileId = profileId;
    _logger.d('Profile ID set to: $profileId');
  }

  /// Get the current profile ID
  String? get currentProfileId => _currentProfileId;

  /// Check if we should use profile-scoped directories
  /// Returns true only if:
  /// 1. A profile ID is set, AND
  /// 2. There are multiple profiles (multi-profile mode is enabled)
  bool _shouldUseProfileScoping() {
    if (_currentProfileId == null) {
      return false; // No profile ID means legacy mode
    }
    
    // Check if there are multiple profiles
    final profileService = ProfileService();
    final isMultiProfile = profileService.isMultiProfileMode();
    
    _logger.d('Profile scoping check: profileId=$_currentProfileId, multiProfile=$isMultiProfile');
    return isMultiProfile;
  }

  // Gets the old application cache directory path
  Future<String?> _getOldCacheDirectoryPath() async {
    final Directory appCacheDir = await getApplicationCacheDirectory();
    final String cachePath = appCacheDir.path;
    // Replace the new app ID with old app ID in the path
    if (cachePath.contains(_newAppId)) {
      return cachePath.replaceAll(_newAppId, _oldAppId);
    }
    return null;
  }

  // Check if migration is needed and return old directory if it exists and has files
  Future<Directory?> checkMigrationNeeded() async {
    final Directory newCacheDir = await getApplicationCacheDirectory();
    final String? oldCachePath = await _getOldCacheDirectoryPath();

    if (oldCachePath == null) return null;

    final Directory oldCacheDir = Directory(oldCachePath);

    // If new directory has files, no migration needed
    if (await _hasFiles(newCacheDir)) {
      return null;
    }

    // If old directory exists and has files, migration might be needed
    if (await oldCacheDir.exists() && await _hasFiles(oldCacheDir)) {
      return oldCacheDir;
    }

    return null;
  }

  // Helper method to check if a directory has any files
  Future<bool> _hasFiles(Directory directory) async {
    if (!await directory.exists()) return false;
    await for (final _ in directory.list(followLinks: false)) {
      return true;
    }
    return false;
  }

  // Migrate files from old directory to new directory
  Future<void> migrateFiles(Directory oldDir) async {
    final Directory newDir = await getApplicationCacheDirectory();

    try {
      await _migrateDirectoryContents(oldDir, newDir);

      // After moving all files, try to delete the old directory
      try {
        await oldDir.delete(recursive: true);
      } catch (e) {
        // Ignore errors if we can't delete the old directory
        _logger.w('Could not delete old directory', e);
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to migrate files', e, stackTrace);
      rethrow;
    }
  }

  // Helper method to recursively migrate directory contents
  Future<void> _migrateDirectoryContents(
    Directory sourceDir,
    Directory targetDir,
  ) async {
    _logger.d(
      'Migrating directory contents from ${sourceDir.path} to ${targetDir.path}',
    );

    // Create target directory if it doesn't exist
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
      _logger.d('Created target directory: ${targetDir.path}');
    }

    // Get all entities from the source directory
    await for (final entity in sourceDir.list(followLinks: false)) {
      final String relativePath = path.relative(
        entity.path,
        from: sourceDir.path,
      );
      final String targetPath = path.join(targetDir.path, relativePath);

      if (entity is File) {
        // Move file to new location
        final File newFile = File(targetPath);
        try {
          await entity.rename(newFile.path);
          _logger.d('Moved file: $relativePath');
        } catch (e) {
          _logger.e('Failed to move file: $relativePath', e);
          rethrow;
        }
      } else if (entity is Directory) {
        // Recursively handle subdirectory
        await _migrateDirectoryContents(entity, Directory(targetPath));
      }
    }
  }

  // Gets the application cache directory and appends the specified subdirectory.
  // Creates it if it doesn't exist.
  // Uses profile-scoped paths ONLY if multi-profile mode is enabled (2+ profiles)
  // Otherwise uses legacy root-level paths for backward compatibility
  Future<Directory> createDirectory(String subDirName) async {
    final Directory appCacheDir = await getApplicationCacheDirectory();
    
    String dirPath;
    if (_shouldUseProfileScoping()) {
      // Multi-profile mode: AppCache/profiles/{profileId}/{subDirName}
      dirPath = path.join(
        appCacheDir.path,
        'profiles',
        _currentProfileId!,
        subDirName,
      );
      _logger.d('Using profile-scoped path: $dirPath');
    } else {
      // Single-profile mode (backward compatible): AppCache/{subDirName}
      dirPath = path.join(appCacheDir.path, subDirName);
      _logger.d('Using legacy path: $dirPath');
    }
    
    final Directory specifiedDir = Directory(dirPath);
    if (!await specifiedDir.exists()) {
      await specifiedDir.create(recursive: true);
      _logger.d('Created directory: $dirPath');
    }
    return specifiedDir;
  }

  // Lists all files in the given directory.
  List<FileSystemEntity> listFilesInDirectory(Directory directory) {
    return directory.listSync();
  }

  // Checks if a directory exists.
  Future<bool> directoryExists(Directory directory) async {
    return await directory.exists();
  }

  // A new method to process files in a directory with a given action
  Future<void> processFilesInDirectory(
    Directory directory,
    dynamic Function(File) fileAction,
  ) async {
    if (await directoryExists(directory)) {
      await for (final file in directory.list(followLinks: false)) {
        if (file is File) {
          final result = fileAction(file);
          // If the result is a Future, await it
          if (result is Future) {
            await result;
          }
        }
      }
    }
  }
}
