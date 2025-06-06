// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:soundboard/core/constants/globals.dart';
import 'package:soundboard/core/constants/message_types.dart';
import 'package:soundboard/core/services/jingle_manager/class_filesystem_helper.dart';
import 'package:soundboard/core/services/jingle_manager/class_static_audiofiles.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiomanager.dart';
import 'package:soundboard/core/utils/logger.dart';

class JingleDirectories {
  static const String generic = "GenericJingles";
  static const String goal = "GoalJingles";
  static const String clap = "ClapJingles";
  static const String lineup = "LineupJingles";
}

class JingleManager {
  late Directory genericJinglesDir;
  late Directory goalJinglesDir;
  late Directory clapJinglesDir;
  late Directory lineupJinglesDir;
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
      await _loadAudioConfigurations();
      logger.d("Audio configurations loaded");
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

  Future<void> _loadAudioConfigurations() async {
    try {
      List<Map<String, dynamic>> audioFileConfigurations =
          await AudioConfigurations.getAudioFileConfigurations();
      for (var config in audioFileConfigurations) {
        AudioFile audioFile = AudioFile(
          filePath: config['filePath'],
          displayName: config['displayName'],
          audioCategory: config['audioCategory'],
        );
        audioFiles.add(audioFile);
      }
      // Initialize the files after directories are set up.
      for (var audioFile in audioFiles) {
        // You can process each AudioFile as needed here
        // For instance, add them to your AudioManager
        audioManager.addInstance(audioFile);
      }
    } catch (e) {
      logger.e("Error loading audio configurations: $e");
      showMessageCallback(
        type: MessageType.error,
        message: "Error: Failed to load audio files",
      );
    }
  }

  Future<void> _initializeDirectories() async {
    try {
      genericJinglesDir = await fileSystemHelper.createDirectory(
        "GenericJingles",
      );
      goalJinglesDir = await fileSystemHelper.createDirectory("GoalJingles");
      clapJinglesDir = await fileSystemHelper.createDirectory("ClapJingles");
      lineupJinglesDir = await fileSystemHelper.createDirectory(
        "LineupJingles",
      );
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
          'directory': lineupJinglesDir,
          'category': AudioCategory.lineupBackgroundJingle,
        },
      ];
      // Iterate over each association and initialize files accordingly
      for (var association in dirCategoryAssociations) {
        await fileSystemHelper.processFilesInDirectory(
          association['directory'],
          (File file) => audioManager.addInstance(
            AudioFile(
              filePath: file.path,
              displayName: file.uri.pathSegments.last.split('.').first,
              audioCategory: association['category'],
            ),
          ),
        );
      }
    } catch (e) {
      logger.d("Error initializing Jingle files: $e");
      // Consider handling or reporting the error as appropriate.
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
