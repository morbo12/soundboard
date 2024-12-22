import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

class UploadButtonToSingle extends StatefulWidget {
  final AudioFile audiofile; // Updated to be more descriptive

  const UploadButtonToSingle(
      {super.key, required this.audiofile}); // Updated constructor

  @override
  UploadButtonToSingleState createState() => UploadButtonToSingleState();
}

class UploadButtonToSingleState extends State<UploadButtonToSingle> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);

  Future<void> _copyFileToDestination(String? filePath) async {
    if (filePath == null) return;

    final File sourceFile = File(filePath);

    try {
      await sourceFile.copy(widget.audiofile.filePath);
      if (kDebugMode) {
        print("File copied to $widget.audiofile.filePath");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Failed to copy file: $e");
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
        // Invoke the file picker UI function
        showMaterialFilePicker(
          context: context,
          fileType: FileType.custom,
          allowedExtensions:
              Platform.isWindows ? ['mp3', 'flac'] : ['mp3', 'flac', 'ogg'],
          onChanged: (value) async {
            // Check if mounted is needed here, depends on what showMaterialFilePicker does
            if (!mounted) return;
            selectedPath.value = value.path;
            if (kDebugMode) {
              print("VALUE: ${value.path}");
            }
            final allowedExtensions = ['.mp3', '.flac'];
            // If not a zip file, directly copy the file
            if (allowedExtensions
                .any((ext) => value.path!.toLowerCase().endsWith(ext))) {
              await _copyFileToDestination(selectedPath.value);
            }
            jingleManager.initialize();
          },
        );
      },
      secondaryText: 'N/A',
      primaryText: widget.audiofile.displayName,
    );
  }
}
