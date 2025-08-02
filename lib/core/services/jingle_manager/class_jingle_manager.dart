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

class JingleDirectories {
  static const String generic = "GenericJingles";
  static const String goal = "GoalJingles";
  static const String clap = "ClapJingles";
  static const String special = "SpecialJingles";
  static const String goalHorn = "GoalHorn";
}

class JingleManager {
  late Directory genericJinglesDir;
  late Directory goalJinglesDir;
  late Directory clapJinglesDir;
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

  Future<void> initializeJingleFilesDirs() async {
    try {
      // Create a list of maps to associate each directory with its AudioCategory
      List<Map<String, dynamic>> dirCategoryAssociations = [
        {
          'directory': genericJinglesDir,
          'category': AudioCategory.genericJingle,
        },
        {'directory': goalJinglesDir, 'category': AudioCategory.goalJingle},
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
