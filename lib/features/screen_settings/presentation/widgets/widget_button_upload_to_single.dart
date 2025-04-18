import 'dart:io';
import 'package:flutter/material.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/utils/logger.dart';

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
  final Logger logger = const Logger('UploadButtonToSingle');

  Future<void> _copyFileToDestination(String? filePath) async {
    if (filePath == null) return;

    final File sourceFile = File(filePath);

    try {
      await sourceFile.copy(widget.audiofile.filePath);
      logger.d("File copied to $widget.audiofile.filePath");
    } catch (e) {
      logger.d("Failed to copy file: $e");
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
          onFileSelected: (filePath) async {
            if (!mounted) return;

            selectedPath.value = filePath;

            final validExtensions = ['.mp3', '.flac'];
            if (Platform.isAndroid || Platform.isIOS || Platform.isLinux) {
              validExtensions.add('.ogg');
            }

            if (validExtensions
                .any((ext) => filePath.toLowerCase().endsWith(ext))) {
              await _copyFileToDestination(selectedPath.value);
            }

            jingleManager.initialize();
          },
          onError: (errorMessage) {
            // Handle error, maybe show a snackbar
          },
        );
      },
      secondaryText: 'N/A',
      primaryText: widget.audiofile.displayName,
    );
  }
}
