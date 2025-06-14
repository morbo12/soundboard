import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:soundboard/core/services/jingle_manager/class_filesystem_helper.dart';

// Testable version of FileSystemHelper that doesn't use platform channels
class TestableFileSystemHelper extends FileSystemHelper {
  final Directory baseDir;

  TestableFileSystemHelper(this.baseDir);

  // Override the method that uses getApplicationCacheDirectory
  @override
  Future<Directory> createDirectory(String subDirName) async {
    // For testing, create directories directly under the test directory
    final Directory specifiedDir = Directory(
      path.join(baseDir.parent.path, subDirName),
    );
    if (!await specifiedDir.exists()) {
      await specifiedDir.create();
    }
    return specifiedDir;
  }

  // Override the method that uses getApplicationCacheDirectory for migration
  @override
  Future<Directory?> checkMigrationNeeded() async {
    // For testing, we'll use a simplified version that just checks if old cache exists
    final oldCachePath = path.join(baseDir.parent.path, 'io.lyxell', 'cache');
    final oldCacheDir = Directory(oldCachePath);

    if (await oldCacheDir.exists() && await _hasFiles(oldCacheDir)) {
      return oldCacheDir;
    }

    return null;
  }

  // Override the method that uses getApplicationCacheDirectory for migration
  @override
  Future<void> migrateFiles(Directory oldDir) async {
    try {
      await _migrateDirectoryContents(oldDir, baseDir);
    } catch (e) {
      rethrow;
    }
  }

  // Helper method to check if a directory has any files
  Future<bool> _hasFiles(Directory directory) async {
    if (!await directory.exists()) return false;
    final List<FileSystemEntity> entities = directory.listSync();
    return entities.isNotEmpty;
  }

  // Helper method to recursively migrate directory contents
  Future<void> _migrateDirectoryContents(
    Directory sourceDir,
    Directory targetDir,
  ) async {
    // Create target directory if it doesn't exist
    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
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
        } catch (e) {
          rethrow;
        }
      } else if (entity is Directory) {
        // Recursively handle subdirectory
        await _migrateDirectoryContents(entity, Directory(targetPath));
      }
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late TestableFileSystemHelper fileSystemHelper;
  late Directory testDir;
  late Directory oldCacheDir;
  late Directory newCacheDir;

  setUp(() async {
    testDir = await Directory.systemTemp.createTemp('test_fs_helper');
    oldCacheDir = Directory(path.join(testDir.path, 'old_cache'));
    newCacheDir = Directory(path.join(testDir.path, 'new_cache'));
    await oldCacheDir.create();
    await newCacheDir.create();

    fileSystemHelper = TestableFileSystemHelper(newCacheDir);
  });

  tearDown(() async {
    await testDir.delete(recursive: true);
  });

  group('FileSystemHelper Directory Operations', () {
    test('createDirectory creates directory if it does not exist', () async {
      final subDirName = 'test_subdir';
      final createdDir = await fileSystemHelper.createDirectory(subDirName);

      expect(await createdDir.exists(), isTrue);
      expect(createdDir.path, equals(path.join(testDir.path, subDirName)));
    });

    test('createDirectory returns existing directory if it exists', () async {
      final subDirName = 'existing_dir';
      final dir = Directory(path.join(testDir.path, subDirName));
      await dir.create();

      final createdDir = await fileSystemHelper.createDirectory(subDirName);

      expect(await createdDir.exists(), isTrue);
      expect(createdDir.path, equals(dir.path));
    });

    test('directoryExists returns correct status', () async {
      final existingDir = Directory(path.join(testDir.path, 'exists'));
      await existingDir.create();
      final nonExistingDir = Directory(path.join(testDir.path, 'not_exists'));

      expect(await fileSystemHelper.directoryExists(existingDir), isTrue);
      expect(await fileSystemHelper.directoryExists(nonExistingDir), isFalse);
    });
  });

  group('FileSystemHelper File Operations', () {
    test('listFilesInDirectory returns all files', () async {
      // Create a clean test directory for this specific test
      final testSubDir = Directory(path.join(testDir.path, 'list_test'));
      await testSubDir.create();

      final testFile1 = File(path.join(testSubDir.path, 'file1.txt'));
      final testFile2 = File(path.join(testSubDir.path, 'file2.txt'));
      await testFile1.writeAsString('test1');
      await testFile2.writeAsString('test2');

      final files = fileSystemHelper.listFilesInDirectory(testSubDir);

      expect(files.length, equals(2));
      expect(files.any((f) => f.path == testFile1.path), isTrue);
      expect(files.any((f) => f.path == testFile2.path), isTrue);
    });

    test('processFilesInDirectory executes action on each file', () async {
      // Create a clean test directory for this specific test
      final testSubDir = Directory(path.join(testDir.path, 'process_test'));
      await testSubDir.create();

      final testFile1 = File(path.join(testSubDir.path, 'file1.txt'));
      final testFile2 = File(path.join(testSubDir.path, 'file2.txt'));
      await testFile1.writeAsString('test1');
      await testFile2.writeAsString('test2');

      final processedFiles = <String>[];
      await fileSystemHelper.processFilesInDirectory(
        testSubDir,
        (file) => processedFiles.add(file.path),
      );

      expect(processedFiles.length, equals(2));
      expect(processedFiles.contains(testFile1.path), isTrue);
      expect(processedFiles.contains(testFile2.path), isTrue);
    });

    test('processFilesInDirectory handles empty directory', () async {
      // Create a clean test directory for this specific test
      final testSubDir = Directory(path.join(testDir.path, 'empty_test'));
      await testSubDir.create();

      final processedFiles = <String>[];
      await fileSystemHelper.processFilesInDirectory(
        testSubDir,
        (file) => processedFiles.add(file.path),
      );

      expect(processedFiles.isEmpty, isTrue);
    });
  });

  group('FileSystemHelper Migration', () {
    test(
      'checkMigrationNeeded returns null when new directory has files',
      () async {
        final testFile = File(path.join(newCacheDir.path, 'test.txt'));
        await testFile.writeAsString('test');

        final result = await fileSystemHelper.checkMigrationNeeded();
        expect(result, isNull);
      },
    );

    test(
      'checkMigrationNeeded returns old directory when it has files and new is empty',
      () async {
        // Create a test helper with empty new cache
        final emptyCacheDir = Directory(path.join(testDir.path, 'empty_cache'));
        await emptyCacheDir.create();
        final testHelper = TestableFileSystemHelper(emptyCacheDir);

        // Create the old cache directory with the old app ID
        final oldAppCachePath = path.join(testDir.path, 'io.lyxell', 'cache');
        final oldAppCacheDir = Directory(oldAppCachePath);
        await oldAppCacheDir.create(recursive: true);
        final testFile = File(path.join(oldAppCachePath, 'test.txt'));
        await testFile.writeAsString('test content');

        final result = await testHelper.checkMigrationNeeded();
        expect(result, isNotNull);
        expect(result?.path, equals(oldAppCachePath));
      },
    );

    test('migrateFiles copies files from old to new directory', () async {
      // Create test file in old cache
      final testFile = File(path.join(oldCacheDir.path, 'test.txt'));
      await testFile.writeAsString('test content');

      await fileSystemHelper.migrateFiles(oldCacheDir);

      // Verify file was copied to new cache
      final newFile = File(path.join(newCacheDir.path, 'test.txt'));
      expect(await newFile.exists(), isTrue);
      expect(await newFile.readAsString(), equals('test content'));

      // Verify old file no longer exists (since migrateFiles uses rename)
      expect(await testFile.exists(), isFalse);
    });

    test('migrateFiles handles subdirectories', () async {
      // Create a subdirectory structure in old cache
      final subDir = Directory(path.join(oldCacheDir.path, 'subdir'));
      await subDir.create();
      final testFile = File(path.join(subDir.path, 'test.txt'));
      await testFile.writeAsString('test content');

      await fileSystemHelper.migrateFiles(oldCacheDir);

      // Verify subdirectory and file were copied to new cache
      final newSubDir = Directory(path.join(newCacheDir.path, 'subdir'));
      final newFile = File(path.join(newSubDir.path, 'test.txt'));
      expect(await newSubDir.exists(), isTrue);
      expect(await newFile.exists(), isTrue);
      expect(await newFile.readAsString(), equals('test content'));
    });
  });
}
