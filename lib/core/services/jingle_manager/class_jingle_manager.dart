// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:soundboard/core/constants/globals.dart';
import 'package:soundboard/core/constants/message_types.dart';
import 'package:soundboard/core/services/jingle_manager/class_filesystem_helper.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiomanager.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/utils/audio_metadata_parser.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:path/path.dart' as p;
import 'package:flutter/foundation.dart' show kDebugMode;

class JingleDirectories {
  static const String generic = "GenericJingles";
  static const String goal = "GoalJingles";
  static const String clap = "ClapJingles";
  static const String penalty = "PenaltyJingles";
  static const String special = "SpecialJingles";
  static const String goalHorn = "GoalHorn";
}

class JingleManager {
  late Directory genericJinglesDir;
  late Directory goalJinglesDir;
  late Directory clapJinglesDir;
  late Directory penaltyJinglesDir;
  late Directory specialJinglesDir;
  late Directory goalHornDir;
  List<AudioFile> audioFiles = [];
  final Logger logger = const Logger('JingleManager');

  AudioManager audioManager = AudioManager();
  final FileSystemHelper fileSystemHelper = FileSystemHelper();
  Function({required MessageType type, required String message})
  showMessageCallback;
  // Function(String) showErrorMessageCallback;

  JingleManager({
    required this.showMessageCallback,
    // required this.showErrorMessageCallback
  }) {
    logger.d("INIT: AudioSources 2");
  }

  Future<void> initialize() async {
    logger.d("Initializing DIRS");

    try {
      // Check for migration before initializing directories
      logger.d("Checking for migration");
      await _checkAndHandleMigration();
      logger.d("Migration checked");
      await _initializeDirectories();
      logger.d("Directories initialized");
      // Copy any bundled jingles from assets into the cache directories
      // so they are available alongside user-uploaded files
      await _copyBundledJinglesToCache();
      logger.d("Bundled jingles copied (if any)");
      // await _loadSpecialJingles();
      // logger.d("Special jingles loaded");
      await initializeJingleFilesDirs();

      // Successfully initialized, show a success toast message.
      showMessageCallback(
        type: MessageType.normal,
        message: "Jingles initialized successfully!",
      );
    } catch (e) {
      // Handle directory creation or file initialization errors.
      logger.d(e.toString());
      showMessageCallback(
        type: MessageType.error,
        message: "Error: Failed to initialize directories and files.",
      );
    }
  }

  Future<void> _checkAndHandleMigration() async {
    try {
      final oldDir = await fileSystemHelper.checkMigrationNeeded();
      if (oldDir != null) {
        // Show a dialog to the user asking if they want to migrate
        final shouldMigrate = await showDialog<bool>(
          context: navigatorKey.currentContext!,
          builder: (context) => AlertDialog(
            title: const Text('Migrate Cache Files'),
            content: const Text(
              'Version 0.4 uses a new cache directory. I found files from the previous version of the app and I can move them to the new cache directory. This is a one-time migration and will only happen once.\n\nIf you do not migrate, you need to upload your jingles again.\n\nWould you like to migrate them to the new version?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes'),
              ),
            ],
          ),
        );

        if (shouldMigrate == true) {
          // Perform the migration
          await fileSystemHelper.migrateFiles(oldDir);
          showMessageCallback(
            type: MessageType.normal,
            message: "Files migrated successfully!",
          );
        }
      }
    } catch (e) {
      logger.e("Error during migration check: $e");
      // Don't show error to user as this is not critical
    }
  }

  // Future<void> _loadSpecialJingles() async {
  //   try {
  //     final specialJingles = await AudioConfigurations.getSpecialJingles();
  //     for (var audioFile in specialJingles) {
  //       audioManager.addInstance(audioFile);
  //     }
  //   } catch (e) {
  //     logger.e("Error loading special jingles: $e");
  //     showMessageCallback(
  //       type: MessageType.error,
  //       message: "Error: Failed to load special jingles",
  //     );
  //   }
  // }

  Future<void> _initializeDirectories() async {
    try {
      genericJinglesDir = await fileSystemHelper.createDirectory(
        "GenericJingles",
      );
      goalJinglesDir = await fileSystemHelper.createDirectory("GoalJingles");
      penaltyJinglesDir = await fileSystemHelper.createDirectory(
        "PenaltyJingles",
      );
      clapJinglesDir = await fileSystemHelper.createDirectory("ClapJingles");
      specialJinglesDir = await fileSystemHelper.createDirectory(
        "SpecialJingles",
      );
      goalHornDir = await fileSystemHelper.createDirectory("GoalHorn");
    } catch (e) {
      logger.e("Error initializing directories: $e");
      showMessageCallback(
        type: MessageType.error,
        message: "Error: Failed to create directories",
      );
    }
  }

  /// Copies bundled jingles from assets/jingles/* into the corresponding
  /// cache directories on first run. Existing files are not overwritten.
  Future<void> _copyBundledJinglesToCache() async {
    try {
      // Load the asset manifest to list available assets
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifest = json.decode(manifestContent);

      logger.d("AssetManifest contains ${manifest.keys.length} entries");

      // Filter assets under assets/jingles/
      final assetPaths = manifest.keys
          .where((k) => k.startsWith('assets/jingles/'))
          .toList();

      if (assetPaths.isEmpty) {
        logger.d(
          "No bundled jingles found in assets/jingles/ via AssetManifest",
        );
        // In debug builds, fall back to scanning the local filesystem so
        // developers can iterate without a full rebuild.
        if (kDebugMode) {
          final devRoot = Directory('assets/jingles');
          if (await devRoot.exists()) {
            logger.d("Debug fallback: scanning local assets/jingles directory");
            await for (final entity in devRoot.list(recursive: true)) {
              if (entity is! File) continue;
              final rel = p.relative(entity.path, from: devRoot.path);
              final parts = rel.split(p.separator);
              if (parts.length < 2) continue;

              final subdir = parts.first.toLowerCase();
              final fileName = parts.sublist(1).join('/');

              Directory targetDir;
              switch (subdir) {
                case 'generic':
                  targetDir = genericJinglesDir;
                  break;
                case 'goal':
                  targetDir = goalJinglesDir;
                  break;
                case 'clap':
                  targetDir = clapJinglesDir;
                  break;
                case 'goalhorn':
                  targetDir = goalHornDir;
                  break;
                case 'penalty':
                  targetDir = penaltyJinglesDir;
                  break;
                case 'timeout':
                case 'powerup':
                case '1min':
                case 'threemin':
                case 'special':
                  targetDir = specialJinglesDir;
                  break;
                default:
                  targetDir = genericJinglesDir;
                  break;
              }

              final destPath = p.join(targetDir.path, p.basename(fileName));
              final destFile = File(destPath);
              if (await destFile.exists()) continue;

              await destFile.create(recursive: true);
              await entity.copy(destFile.path);
            }
            logger.d("Debug fallback: copied local assets if missing");
          } else {
            logger.d("Debug fallback root not found: ${devRoot.path}");
          }
        }
        return;
      }

      for (final assetPath in assetPaths) {
        // Determine the subdirectory (category indicator)
        // e.g., assets/jingles/generic/foo.mp3 -> generic
        final relative = assetPath.substring('assets/jingles/'.length);
        final parts = relative.split('/');
        if (parts.length < 2) continue; // Expect subdir + filename
        final subdir = parts.first.toLowerCase();
        final fileName = parts.sublist(1).join('/'); // support nested

        // Map subdir to target directory
        Directory? targetDir;
        switch (subdir) {
          case 'generic':
            targetDir = genericJinglesDir;
            break;
          case 'goal':
            targetDir = goalJinglesDir;
            break;
          case 'clap':
            targetDir = clapJinglesDir;
            break;
          case 'goalhorn':
            targetDir = goalHornDir;
            break;
          case 'penalty':
            targetDir = penaltyJinglesDir;
            break;
          // Special effects go into SpecialJingles
          case 'timeout':
          case 'powerup':
          case '1min':
          case 'threemin':
          case 'special':
            targetDir = specialJinglesDir;
            break;
          default:
            // Unknown subdir: place in Generic to avoid loss
            targetDir = genericJinglesDir;
            break;
        }

        final destPath = p.join(targetDir.path, p.basename(fileName));
        final destFile = File(destPath);

        if (await destFile.exists()) {
          // Don't overwrite user-updated files
          continue;
        }

        // Copy bytes from asset to file system
        final byteData = await rootBundle.load(assetPath);
        final bytes = byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        );
        await destFile.writeAsBytes(bytes, flush: true);
      }

      logger.d("Copied ${assetPaths.length} bundled jingles where missing");
    } catch (e) {
      // Non-fatal: if anything goes wrong, skip copying
      logger.w("Failed to copy bundled jingles: $e");
    }
  }

  Future<void> initializeJingleFilesDirs() async {
    try {
      // Create a list of maps to associate each directory with its AudioCategory
      List<Map<String, dynamic>> dirCategoryAssociations = [
        {
          'directory': genericJinglesDir,
          'category': AudioCategory.genericJingle,
        },
        {'directory': goalJinglesDir, 'category': AudioCategory.goalJingle},
        {
          'directory': penaltyJinglesDir,
          'category': AudioCategory.penaltyJingle,
        },
        {'directory': clapJinglesDir, 'category': AudioCategory.clapJingle},
        {
          'directory': specialJinglesDir,
          'category': AudioCategory.specialJingle,
        },
        {'directory': goalHornDir, 'category': AudioCategory.goalHorn},
      ];
      // Iterate over each association and initialize files accordingly
      for (var association in dirCategoryAssociations) {
        await fileSystemHelper.processFilesInDirectory(
          association['directory'],
          (File file) {
            // Use a simple approach to avoid async callback issues
            // We'll process metadata parsing in a separate step if needed
            final basicName = file.uri.pathSegments.last.split('.').first;
            audioManager.addInstance(
              AudioFile(
                filePath: file.path,
                displayName: basicName,
                audioCategory: association['category'],
              ),
            );
          },
        );
      }

      // Now post-process to get better display names
      await _enhanceDisplayNames();
    } catch (e) {
      logger.d("Error initializing Jingle files: $e");
      // Consider handling or reporting the error as appropriate.
    }
  }

  /// Enhance display names using metadata parser after initial loading
  Future<void> _enhanceDisplayNames() async {
    try {
      for (int i = 0; i < audioManager.audioInstances.length; i++) {
        final audioFile = audioManager.audioInstances[i];
        // Skip special jingles (they have predefined display names)
        if (audioFile.audioCategory == AudioCategory.goalHorn) continue;

        // Get enhanced display name
        final enhancedName = await AudioMetadataParser.getDisplayName(
          audioFile.filePath,
        );

        // Update the audio file with the enhanced name
        audioManager.audioInstances[i] = AudioFile(
          filePath: audioFile.filePath,
          displayName: enhancedName,
          audioCategory: audioFile.audioCategory,
          isCategoryOnly: audioFile.isCategoryOnly,
        );
      }
    } catch (e) {
      logger.w("Error enhancing display names: $e");
      // This is not critical, so we don't throw
    }
  }

  // void showErrorMessage(BuildContext context, String message) {
  //   FlutterToastr.show(message, context,
  //       duration: FlutterToastr.lengthLong,
  //       position: FlutterToastr.bottom,
  //       backgroundColor: Colors.red,
  //       textStyle: const TextStyle(color: Colors.white));
  // }

  // void showMessage(BuildContext context, String message) {
  //   FlutterToastr.show(message,
  //       duration: FlutterToastr.lengthLong,
  //       position: FlutterToastr.bottom,
  //       backgroundColor: Colors.green,
  //       textStyle: const TextStyle(color: Colors.white));
  // }
}

// Contains AI-generated edits.
