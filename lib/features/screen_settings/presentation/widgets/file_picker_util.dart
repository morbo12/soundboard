// file_picker_utils.dart
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

Future<void> pickFile({
  required List<String> allowedExtensions,
  Function(String filePath)? onFileSelected,
  Function(List<File> files)? onMultipleFilesSelected,
  bool allowMultiple = false,
  Function(String errorMessage)? onError,
  VoidCallback? onCancelled,
}) async {
  try {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
      allowMultiple: allowMultiple,
    );

    if (result != null) {
      if (allowMultiple && onMultipleFilesSelected != null) {
        // Handle multiple files
        List<File> files = result.paths
            .where((path) => path != null)
            .map((path) => File(path!))
            .toList();

        if (kDebugMode) {
          print("Selected files: ${files.length}");
        }

        onMultipleFilesSelected(files);
      } else if (!allowMultiple &&
          onFileSelected != null &&
          result.files.isNotEmpty) {
        // Handle single file
        final filePath = result.files.first.path;
        if (filePath != null) {
          if (kDebugMode) {
            print("Selected file: $filePath");
          }

          onFileSelected(filePath);
        }
      }
    } else {
      // User canceled the picker
      if (kDebugMode) {
        print("File picking cancelled by user");
      }

      if (onCancelled != null) {
        onCancelled();
      }
    }
  } catch (e) {
    final errorMessage = "Error picking file: $e";
    if (kDebugMode) {
      print(errorMessage);
    }

    if (onError != null) {
      onError(errorMessage);
    }
  }
}
