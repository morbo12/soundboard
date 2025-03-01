import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';

class UploadButtonToDir extends StatefulWidget {
  final String directoryName; // Updated to be more descriptive

  const UploadButtonToDir(
      {super.key, required this.directoryName}); // Updated constructor

  @override
  UploadButtonToDirState createState() => UploadButtonToDirState();
}

class UploadButtonToDirState extends State<UploadButtonToDir> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);

  // Future<void> _unzipFile({required String? file}) async {
  //   final Directory appSupportDir = await getApplicationCacheDirectory();
  //   final Directory targetDir = Directory(
  //       '${appSupportDir.path}/${widget.directoryName}'); // Create target directory

  //   if (!await targetDir.exists()) {
  //     await targetDir.create(
  //         recursive: true); // Ensure the target directory exists
  //   }

  //   if (kDebugMode) {
  //     print("Extracting files to $targetDir");
  //   }

  //   try {
  //     await extractFileToDisk(
  //         file!, targetDir.path); // Updated to use target directory
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

  Future<void> _copyFileToDestination(List<File>? files) async {
    if (files == null) return;

    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir =
        Directory('${appSupportDir.path}/${widget.directoryName}');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    for (var sourceFile in files) {
      // final File sourceFile = File(file);
      final String targetPath = Platform.isWindows
          ? '${targetDir.path}/${sourceFile.path.split('\\').last}'
          : '${targetDir.path}/${sourceFile.path.split('/').last}';

      try {
        await sourceFile.copy(targetPath);
        if (kDebugMode) {
          print("File copied to $targetPath");
        }
      } catch (e) {
        if (kDebugMode) {
          print("Failed to copy file: $e");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        fixedSize: const Size.fromHeight(100),
        // side: BorderSide(
        // width: 1, color: Theme.of(context).colorScheme.primaryContainer),
      ),
      noLines: 1,
      isSelected: true,
      onTap: () async {
        pickFile(
          allowedExtensions:
              Platform.isWindows ? ['mp3', 'flac'] : ['mp3', 'flac', 'ogg'],
          allowMultiple: true,
          onMultipleFilesSelected: (files) async {
            if (!mounted) return;

            if (kDebugMode) {
              print("VALUE: $files");
            }

            // Copy the files to destination
            await _copyFileToDestination(files);

            jingleManager.initialize();
          },
          onError: (errorMessage) {
            // Handle error, maybe show a snackbar
          },
          onCancelled: () {
            // Handle cancellation if needed
          },
        );
      },
      secondaryText: 'N/A',
      primaryText:
          widget.directoryName, // Use directory name for the button text
    );
  }
}
