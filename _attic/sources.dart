// // ignore_for_file: use_build_context_synchronously

// import 'dart:async';
// import 'dart:io';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_toastr/flutter_toastr.dart';
// import 'package:overlay_loading_progress/overlay_loading_progress.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:soundboard/features/settings/application/func_download_jingles.dart';

// class AudioSources {
//   late Directory genericJinglesDir;
//   late Directory goalJinglesDir;
//   late Directory clapJinglesDir;

//   late List<FileSystemEntity> genericJingles;
//   late List<FileSystemEntity> goalJingles;
//   late List<FileSystemEntity> clapJingles;

//   late List<File> ratataFile;
//   late List<File> lineupFile;
//   late List<File> valuesFile;
//   late List<File> hornFile;
//   late List<File> lineupBackground;
//   late List<File> oneMin;
//   late List<File> threeMin;
//   late List<File> timeout;

//   AudioSources(BuildContext context) {
//     if (kDebugMode) {
//       print("INIT: AudioSources");
//     }
//     initialize(context);
//   }

//   Future<void> initialize(BuildContext context) async {
//     bool? shouldDownloadFiles = false;
//     if (kDebugMode) {
//       print("Initializing DIRS");
//     }
//     try {
//       Directory externalStorage = await getApplicationCacheDirectory();
//       genericJinglesDir =
//           Directory("${externalStorage.path}/io.soundboard/GenericJingles/");
//       goalJinglesDir =
//           Directory("${externalStorage.path}/io.soundboard/GoalJingles/");
//       clapJinglesDir =
//           Directory("${externalStorage.path}/io.soundboard/clapJingles/");

//       // Check if directories exist, if not, ask the user to download the files.
//       if (!await genericJinglesDir.exists() ||
//           !await goalJinglesDir.exists() ||
//           !await clapJinglesDir.exists()) {
//         shouldDownloadFiles = await _showDownloadPopup(context);
//         if (shouldDownloadFiles == true) {
//           await _downloadFiles(context);
//         }
//       }

//       // Initialize the files after directories are set up.
//       initializeJingleFiles(context);
//       initializeSoundboardFiles(context);
//       // Successfully initialized, show a success toast message.
//       FlutterToastr.show("Files loaded successfully!", context,
//           duration: FlutterToastr.lengthLong,
//           position: FlutterToastr.bottom,
//           backgroundColor: Colors.green,
//           textStyle: const TextStyle(color: Colors.white));
//     } catch (e) {
//       // Handle directory creation or file initialization errors.
//       if (kDebugMode) {
//         print(e);
//       }
//       showErrorMessage(
//         context,
//         "Error: Failed to initialize directories and files.",
//       );
//     }
//   }

//   Future<bool?> _showDownloadPopup(BuildContext context) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Download Jingles'),
//           content: const Text(
//               'Did not find any audio files.\nDo you want to download the base files?\n(App might crash and have limited functionallity)'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true);
//               },
//               child: const Text('Download'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false);
//               },
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Future<void> _downloadFiles(BuildContext context) async {
//     try {
//       OverlayLoadingProgress.start(
//         context,
//         barrierDismissible: false,
//         widget: Container(
//           height: 100,
//           width: 100,
//           color: Colors.black38,
//           child: const Center(
//             child: CircularProgressIndicator(),
//           ),
//         ),
//       );
//       await downloadExternalJingles();
//       OverlayLoadingProgress.stop();
//       FlutterToastr.show("Files downloaded successfully!", context,
//           duration: FlutterToastr.lengthLong,
//           position: FlutterToastr.bottom,
//           backgroundColor: Colors.green,
//           textStyle: const TextStyle(color: Colors.white));
//     } catch (e) {
//       // Handle the error here, log it, or show the error message to the client.
//       if (kDebugMode) {
//         print(e);
//       }
//       FlutterToastr.show("Error: Failed to download the files.", context,
//           duration: FlutterToastr.lengthLong,
//           position: FlutterToastr.bottom,
//           backgroundColor: Colors.red,
//           textStyle: const TextStyle(color: Colors.white));
//     }
//   }

//   Future<void> initializeJingleFiles(BuildContext context) async {
//     try {
//       genericJingles = genericJinglesDir.listSync();
//       goalJingles = goalJinglesDir.listSync() + genericJingles;
//       clapJingles = clapJinglesDir.listSync();
//     } catch (e) {
//       // Handle jingle file initialization errors.
//       if (kDebugMode) {
//         print(e);
//       }
//       showErrorMessage(
//         context,
//         "Error: Failed to initialize jingle files.",
//       );
//     }
//   }

//   Future<void> initializeSoundboardFiles(BuildContext context) async {
//     try {
//       String basePath = (await getApplicationCacheDirectory()).path;
//       // Was getApplicationSupportDirectory
//       ratataFile = [File("$basePath/io.soundboard/ratata.mp3")];
//       lineupFile = [File("$basePath/io.soundboard/lineup.mp3")];
//       valuesFile = [File("$basePath/io.soundboard/PlayerValues.mp3")];
//       hornFile = [File("$basePath/io.soundboard/goalHorn.mp3")];
//       lineupBackground = [
//         File("$basePath/io.soundboard/lineup-background.mp3")
//       ];
//       oneMin = [File("$basePath/io.soundboard/1min.mp3")];
//       threeMin = [File("$basePath/io.soundboard/3min.mp3")];
//       timeout = [File("$basePath/io.soundboard/timeout.mp3")];
//     } catch (e) {
//       // Handle soundboard file initialization errors.
//       if (kDebugMode) {
//         print(e);
//       }
//       showErrorMessage(
//         context,
//         "Error: Failed to initialize soundboard audio files.",
//       );
//     }
//   }

//   void showErrorMessage(BuildContext context, String message) {
//     FlutterToastr.show(message, context,
//         duration: FlutterToastr.lengthLong,
//         position: FlutterToastr.bottom,
//         backgroundColor: Colors.red,
//         textStyle: const TextStyle(color: Colors.white));
//   }
// }
