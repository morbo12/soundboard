import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: _handleZipUpload,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                colorScheme.tertiaryContainer,
                colorScheme.tertiaryContainer.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF673AB7), // Deep purple for zip
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.archive, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bulk Upload',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onTertiaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Upload a ZIP file with all jingle categories',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onTertiaryContainer.withAlpha(200),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFeatureChip(context, 'ZIP Archive'),
                        const SizedBox(width: 8),
                        _buildFeatureChip(context, 'Auto Extract'),
                        const SizedBox(width: 8),
                        _buildFeatureChip(context, 'All Categories'),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.upload_file, color: colorScheme.onTertiaryContainer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> _handleZipUpload() async {
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
  }
}
