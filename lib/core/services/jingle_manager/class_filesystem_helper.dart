import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../utils/logger.dart';

class FileSystemHelper {
  static final _logger = const Logger('FileSystemHelper');

  // Old app ID path component
  static const String _oldAppId = 'io.lyxell';
  // New app ID path component
  static const String _newAppId = 'eu.fbapps';

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
    final List<FileSystemEntity> entities = directory.listSync();
    return entities.isNotEmpty;
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
    final List<FileSystemEntity> entities = sourceDir.listSync();

    for (final entity in entities) {
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
  Future<Directory> createDirectory(String subDirName) async {
    final Directory appCacheDir = await getApplicationCacheDirectory();
    final Directory specifiedDir = Directory(
      '${appCacheDir.path}/$subDirName/',
    );
    if (!await specifiedDir.exists()) {
      await specifiedDir.create();
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
    Function(File) fileAction,
  ) async {
    if (await directoryExists(directory)) {
      final List<FileSystemEntity> files = directory.listSync();
      for (final file in files) {
        if (file is File) {
          fileAction(file);
        }
      }
    }
  }
}
