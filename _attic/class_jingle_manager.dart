// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_toastr/flutter_toastr.dart';
// import 'package:overlay_loading_progress/overlay_loading_progress.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:soundboard/features/home_screen/application/audioplayer/data/class_audio.dart';
// import 'package:soundboard/features/home_screen/application/audioplayer/data/class_audiocategory.dart';
// import 'package:soundboard/features/home_screen/application/audioplayer/data/class_audiomanager.dart';
// import 'package:soundboard/features/settings/application/func_download_jingles.dart';

// class JingleManager {
//   AudioManager audioManager = AudioManager();
//   Initializer initializer = Initializer();

//   JingleManager() {
//     initializer.initialize();
//   }
// }

// class ErrorHandler extends StatelessWidget {
//   String e;
//   ErrorHandler({super.key, required this.e});
//   static void handleError(Object e) {
//     // Handle the error here, log it, or show the error message to the client.
//     if (kDebugMode) {
//       print(e);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     // Show an error message to the user
//     return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
//       content: Text("Error: $e"),
//     ));
//   }
// }

// class Initializer {
//   Future<void> initialize() async {
//     try {
//       // Create directories for jingles and soundboard files
//       Directory externalStorage = await getApplicationCacheDirectory();

//       genericJinglesDir =
//           Directory("${externalStorage.path}/io.soundboard/GenericJingles/");
//       await genericJinglesDir.create();

//       goalJinglesDir =
//           Directory("${externalStorage.path}/io.soundboard/GoalJingles/");
//       await goalJinglesDir.create();

//       clapJinglesDir =
//           Directory("${externalStorage.path}/io.soundboard/clapJingles/");
//       await clapJinglesDir.create();

//       // Download jingle files
//       await downloadExternalJingles();

//       // Add jingle files to the audio manager
//       for (var genericJingleFile in genericJinglesDir.listSync()) {
//         AudioFile jingleFile = AudioFile(genericJingleFile.path);
//         audioManager.addInstance(jingleFile);
//       }

//       // Add soundboard files to the audio manager
//       String basePath = (await getApplicationCacheDirectory()).path;
//       // Was getApplicationSupportDirectory
//       for (var soundboardFile in [
//         'ratata.mp3',
//         'lineup.mp3',
//         'PlayerValues.mp3',
//         'goalHorn.mp3',
//         'lineup-background.mp3',
//         '1min.mp3',
//         '3min.mp3',
//         'timeout.mp3'
//       ]) {
//         AudioFile soundboardJingleFile =
//             AudioFile("$basePath/io.soundboard/$soundboardFile");
//         audioManager.addInstance(soundboardJingleFile);
//       }
//     } catch (e) {
//       ErrorHandler.handleError(e);
//     }
//   }
// }
