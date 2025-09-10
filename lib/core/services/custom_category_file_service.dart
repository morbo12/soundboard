import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/models/extended_audio_category.dart';

/// Service for managing custom category files
class CustomCategoryFileService {
  static const Logger _logger = Logger('CustomCategoryFileService');

  /// Get all audio files for a custom category
  static Future<List<File>> getFilesForCustomCategory(
    String customCategoryId,
  ) async {
    try {
      final cacheDirectory = await getApplicationCacheDirectory();
      final categoryDirectory = Directory(
        '${cacheDirectory.path}/Custom_$customCategoryId',
      );

      if (!await categoryDirectory.exists()) {
        _logger.d(
          'Category directory does not exist: ${categoryDirectory.path}',
        );
        return [];
      }

      final files = await categoryDirectory
          .list()
          .where((entity) => entity is File)
          .cast<File>()
          .where((file) => _isAudioFile(file.path))
          .toList();

      _logger.d(
        'Found ${files.length} audio files for custom category $customCategoryId',
      );
      return files;
    } catch (e) {
      _logger.e(
        'Error getting files for custom category $customCategoryId: $e',
      );
      return [];
    }
  }

  /// Get all audio files for any extended category
  static Future<List<File>> getFilesForCategory(
    ExtendedAudioCategory category,
  ) async {
    if (category is CustomAudioCategory) {
      return getFilesForCustomCategory(category.customId);
    } else {
      // For predefined categories, we'll use the existing jingle manager
      // This method is primarily for custom categories
      return [];
    }
  }

  /// Delete a file from a custom category
  static Future<bool> deleteFileFromCustomCategory(
    String customCategoryId,
    String fileName,
  ) async {
    try {
      final cacheDirectory = await getApplicationCacheDirectory();
      final filePath =
          '${cacheDirectory.path}/Custom_$customCategoryId/$fileName';
      final file = File(filePath);

      if (await file.exists()) {
        await file.delete();
        _logger.d('Deleted file: $filePath');
        return true;
      } else {
        _logger.w('File does not exist: $filePath');
        return false;
      }
    } catch (e) {
      _logger.e(
        'Error deleting file $fileName from custom category $customCategoryId: $e',
      );
      return false;
    }
  }

  /// Check if a file is an audio file based on extension
  static bool _isAudioFile(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['mp3', 'flac', 'ogg', 'wav', 'm4a'].contains(extension);
  }

  /// Get the cache directory path for a custom category
  static Future<String> getCategoryDirectoryPath(
    String customCategoryId,
  ) async {
    final cacheDirectory = await getApplicationCacheDirectory();
    return '${cacheDirectory.path}/Custom_$customCategoryId';
  }

  /// Ensure the directory exists for a custom category
  static Future<Directory> ensureCategoryDirectory(
    String customCategoryId,
  ) async {
    final cacheDirectory = await getApplicationCacheDirectory();
    final categoryDirectory = Directory(
      '${cacheDirectory.path}/Custom_$customCategoryId',
    );

    if (!await categoryDirectory.exists()) {
      await categoryDirectory.create(recursive: true);
      _logger.d('Created category directory: ${categoryDirectory.path}');
    }

    return categoryDirectory;
  }

  /// Get file count for a custom category
  static Future<int> getFileCount(String customCategoryId) async {
    final files = await getFilesForCustomCategory(customCategoryId);
    return files.length;
  }

  /// Delete all cached files for a custom category
  static Future<bool> deleteAllFilesForCustomCategory(
    String customCategoryId,
  ) async {
    try {
      final cacheDirectory = await getApplicationCacheDirectory();
      final categoryDirectory = Directory(
        '${cacheDirectory.path}/Custom_$customCategoryId',
      );

      if (await categoryDirectory.exists()) {
        await categoryDirectory.delete(recursive: true);
        _logger.d('Deleted all files for custom category $customCategoryId');
        return true;
      } else {
        _logger.d(
          'Directory does not exist for custom category $customCategoryId',
        );
        return true; // Consider it success if directory doesn't exist
      }
    } catch (e) {
      _logger.e(
        'Error deleting all files for custom category $customCategoryId: $e',
      );
      return false;
    }
  }

  /// Get formatted file size for a file
  static String getFormattedFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
