import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/utils/logger.dart';

class UploadButtonToDir extends StatefulWidget {
  final String directoryName; // Updated to be more descriptive

  const UploadButtonToDir({
    super.key,
    required this.directoryName,
  }); // Updated constructor

  @override
  UploadButtonToDirState createState() => UploadButtonToDirState();
}

class UploadButtonToDirState extends State<UploadButtonToDir> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);
  final Logger logger = const Logger('UploadButtonToDir');

  Future<void> _copyFileToDestination(List<File>? files) async {
    if (files == null) return;

    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir = Directory(
      '${appSupportDir.path}/${widget.directoryName}',
    );

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }
    for (var sourceFile in files) {
      // final File sourceFile = File(file);
      final String targetPath =
          Platform.isWindows
              ? '${targetDir.path}/${sourceFile.path.split('\\').last}'
              : '${targetDir.path}/${sourceFile.path.split('/').last}';

      try {
        await sourceFile.copy(targetPath);
        logger.d("File copied to $targetPath");
      } catch (e) {
        logger.d("Failed to copy file: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tmp_category =
        widget.directoryName == "GenericJingles"
            ? AudioCategory.genericJingle
            : widget.directoryName == "GoalJingles"
            ? AudioCategory.goalJingle
            : widget.directoryName == "ClapJingles"
            ? AudioCategory.clapJingle
            : AudioCategory.awayTeamJingle;

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

            logger.d("VALUE: $files");

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
      secondaryText:
          "(${jingleManager.audioManager.audioInstances.where((element) => element.audioCategory == tmp_category).length.toString()})",

      primaryText:
          widget.directoryName, // Use directory name for the button text
    );
  }
}
