import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  Future<Directory> getCacheDirectory() async {
    return await getApplicationCacheDirectory();
  }

  Future<int> calculateCacheSize(Directory cacheDir) async {
    int totalSize = 0;
    if (await cacheDir.exists()) {
      try {
        await for (final FileSystemEntity entity
            in cacheDir.list(recursive: true)) {
          if (entity is File) {
            try {
              totalSize += await entity.length();
            } catch (e) {
              // Handle file access errors
              if (kDebugMode) {
                print("Error accessing file ${entity.path}: $e");
              }
            }
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error listing directory contents: $e");
        }
      }
    }
    return totalSize;
  }

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

  Future<bool> clearCache(Directory cacheDir) async {
    try {
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        return true;
      }
      return false;
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting cache directory: $e");
      }
      return false;
    }
  }
}
