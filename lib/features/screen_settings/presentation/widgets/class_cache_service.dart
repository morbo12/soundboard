import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/utils/logger.dart';

class CacheService {
  final logger = const Logger('CacheService');

  /// Returns the application's cache directory
  Future<Directory> getCacheDirectory() async {
    return await getApplicationCacheDirectory();
  }

  /// Calculates the total size of files in the given cache directory
  Future<int> calculateCacheSize(Directory cacheDir) async {
    if (!await cacheDir.exists()) return 0;

    int totalSize = 0;
    try {
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await _safeGetFileSize(entity);
        }
      }
    } catch (e) {
      logger.d("Error listing directory contents: $e");
    }

    return totalSize;
  }

  /// Safely gets a file's size, handling exceptions
  Future<int> _safeGetFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      logger.d("Error accessing file ${file.path}: $e");
      return 0;
    }
  }

  /// Formats byte size to human-readable string
  String formatBytes(int bytes) {
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    if (bytes == 0) return '0 B';

    int i = 0;
    double number = bytes.toDouble();
    while (number >= 1024 && i < suffixes.length - 1) {
      number /= 1024;
      i++;
    }

    return '${number.toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Clears the given cache directory
  Future<bool> clearCache(Directory cacheDir) async {
    try {
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      logger.d("Error deleting cache directory: $e");
      return false;
    }
  }
}
