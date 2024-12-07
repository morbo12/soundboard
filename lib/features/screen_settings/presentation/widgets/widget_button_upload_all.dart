import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common_widgets/button.dart';
import 'package:soundboard/constants/globals.dart';

class UploadButtonAll extends StatefulWidget {
  const UploadButtonAll({super.key}); // Updated constructor

  @override
  UploadButtonToDirState createState() => UploadButtonToDirState();
}

class UploadButtonToDirState extends State<UploadButtonAll> {
  File? file;
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);

  Future<void> _unzipFile({required String? file}) async {
    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir =
        Directory(appSupportDir.path); // Create target directory

    if (!await targetDir.exists()) {
      await targetDir.create(
          recursive: true); // Ensure the target directory exists
    }

    if (kDebugMode) {
      print("Extracting files to $targetDir");
    }

    try {
      await extractFileToDisk(
          file!, targetDir.path); // Updated to use target directory
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
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
        // Invoke the file picker UI function
        showMaterialFilePicker(
          context: context,
          fileType: FileType.custom,
          allowedExtensions: ['zip'],
          onChanged: (value) async {
            // Check if mounted is needed here, depends on what showMaterialFilePicker does
            if (!mounted) return;
            selectedPath.value = value.path;
            if (kDebugMode) {
              print("VALUE: ${value.path}");
            }
            if (value.path!.endsWith('.zip')) {
              await _unzipFile(file: selectedPath.value);
            }
            jingleManager.initialize();
          },
        );
      },
      secondaryText: 'N/A',
      primaryText:
          "Ladda upp en zip med samtliga filer", // Use directory name for the button text
    );
  }
}
