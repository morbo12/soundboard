import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/utils/logger.dart';

class UploadButtonAll extends StatefulWidget {
  const UploadButtonAll({super.key}); // Updated constructor

  @override
  UploadButtonToDirState createState() => UploadButtonToDirState();
}

class UploadButtonToDirState extends State<UploadButtonAll> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);
  final Logger logger = const Logger('UploadButtonAll');
  Future<void> _unzipFile({required String? file}) async {
    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir =
        Directory(appSupportDir.path); // Create target directory

    if (!await targetDir.exists()) {
      await targetDir.create(
          recursive: true); // Ensure the target directory exists
    }

    logger.d("Extracting files to $targetDir");

    try {
      await extractFileToDisk(
          file!, targetDir.path); // Updated to use target directory
    } catch (e) {
      logger.d(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Button(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        fixedSize: const Size.fromHeight(100),
        // side: BorderSide(
        // width: 1, color: Theme.of(context).colorScheme.primaryContainer),
      ),
      noLines: 1,
      isSelected: true,
      onTap: () async {
        pickFile(
          allowedExtensions: ['zip'],
          onFileSelected: (filePath) async {
            if (!mounted) return;

            selectedPath.value = filePath;

            if (filePath.endsWith('.zip')) {
              await _unzipFile(file: selectedPath.value);
            }

            jingleManager.initialize();
          },
          onError: (errorMessage) {
            // Handle error, maybe show a snackbar
          },
        );
      },
      secondaryText: 'N/A',
      primaryText:
          "Ladda upp en zip med samtliga filer", // Use directory name for the button text
    );
  }
}
