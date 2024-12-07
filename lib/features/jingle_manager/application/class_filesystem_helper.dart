import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileSystemHelper {
  // Gets the application cache directory and appends the specified subdirectory.
  // Creates it if it doesn't exist.
  Future<Directory> createDirectory(String subDirName) async {
    final Directory appCacheDir = await getApplicationCacheDirectory();
    final Directory specifiedDir =
        Directory('${appCacheDir.path}/$subDirName/');
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
      Directory directory, Function(File) fileAction) async {
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
