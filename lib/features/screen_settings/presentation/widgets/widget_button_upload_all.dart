import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common/widgets/class_large_button.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';

class UploadButtonAll extends ConsumerStatefulWidget {
  const UploadButtonAll({super.key}); // Updated constructor

  @override
  ConsumerState<UploadButtonAll> createState() => UploadButtonToDirState();
}

class UploadButtonToDirState extends ConsumerState<UploadButtonAll> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);
  final Logger logger = const Logger('UploadButtonAll');
  Future<void> _unzipFile({required String? file}) async {
    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir = Directory(
      appSupportDir.path,
    ); // Create target directory

    if (!await targetDir.exists()) {
      await targetDir.create(
        recursive: true,
      ); // Ensure the target directory exists
    }

    logger.d("Extracting files to $targetDir");

    try {
      await extractFileToDisk(
        file!,
        targetDir.path,
      ); // Updated to use target directory
    } catch (e) {
      logger.d(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    return LargeButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
        backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        fixedSize: const Size.fromHeight(100),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Less round corners
        ),
      ),
      noLines: 1,

      onTap: () async {
        pickFile(
          allowedExtensions: ['zip'],
          onFileSelected: (filePath) async {
            if (!mounted) return;

            selectedPath.value = filePath;

            if (filePath.endsWith('.zip')) {
              await _unzipFile(file: selectedPath.value);
            }

            ref.read(jingleManagerProvider.notifier).reinitialize();
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
