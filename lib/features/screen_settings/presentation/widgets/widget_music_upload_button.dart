import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common/widgets/class_large_button.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/music_player/data/music_player_provider.dart';

class MusicUploadButton extends ConsumerStatefulWidget {
  const MusicUploadButton({super.key});

  @override
  ConsumerState<MusicUploadButton> createState() => _MusicUploadButtonState();
}

class _MusicUploadButtonState extends ConsumerState<MusicUploadButton> {
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);
  final Logger logger = const Logger('MusicUploadButton');

  Future<void> _copyFileToDestination(List<File>? files) async {
    if (files == null) return;

    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir = Directory('${appSupportDir.path}/Music');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    bool hasSuccessfulUploads = false;

    for (var sourceFile in files) {
      final String fileName = Platform.isWindows
          ? sourceFile.path.split('\\').last
          : sourceFile.path.split('/').last;
      final String targetPath = '${targetDir.path}/$fileName';

      try {
        await sourceFile.copy(targetPath);
        logger.d("Music file copied to $targetPath");
        hasSuccessfulUploads = true;

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Music file "$fileName" uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        logger.e("Failed to copy music file: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload "$fileName": $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Trigger playlist refresh if any files were successfully uploaded
    if (hasSuccessfulUploads) {
      final refreshNotifier = ref.read(playlistRefreshProvider.notifier);
      refreshNotifier.state = refreshNotifier.state + 1;
      logger.d("Triggered playlist refresh after successful uploads");
    }
  }

  Future<void> _handleUpload() async {
    try {
      pickFile(
        allowedExtensions: Platform.isWindows
            ? ['mp3', 'flac']
            : ['mp3', 'flac', 'ogg'],
        allowMultiple: true,
        onMultipleFilesSelected: (files) async {
          if (!mounted) return;
          await _copyFileToDestination(files);
        },
        onError: (errorMessage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error during upload: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        onCancelled: () {
          logger.d("Music file upload cancelled");
        },
      );
    } catch (e) {
      logger.e("Error during music file upload: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during upload: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showMusicFiles() async {
    try {
      final Directory appSupportDir = await getApplicationCacheDirectory();
      final Directory musicDir = Directory('${appSupportDir.path}/Music');

      if (!await musicDir.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No music directory found. Upload some music first!',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      final files = musicDir
          .listSync()
          .where(
            (file) =>
                file is File &&
                (file.path.toLowerCase().endsWith('.mp3') ||
                    file.path.toLowerCase().endsWith('.flac') ||
                    file.path.toLowerCase().endsWith('.wav') ||
                    file.path.toLowerCase().endsWith('.m4a')),
          )
          .cast<File>()
          .toList();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Uploaded Music Files'),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: files.isEmpty
                  ? const Center(child: Text('No music files found'))
                  : ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final fileName = Platform.isWindows
                            ? file.path.split('\\').last
                            : file.path.split('/').last;
                        return ListTile(
                          leading: const Icon(Icons.music_note),
                          title: Text(fileName),
                          subtitle: Text(
                            '${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await file.delete();
                              Navigator.of(context).pop();
                              _showMusicFiles(); // Refresh the dialog
                            },
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      logger.e("Error showing music files: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading music files: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: LargeButton(
            primaryText: "Upload Music",
            secondaryText: "MP3, FLAC",
            onTap: _handleUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onSecondaryContainer,
              fixedSize: const Size.fromHeight(100),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: LargeButton(
            primaryText: "Manage Music",
            secondaryText: "View/Delete",
            onTap: _showMusicFiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
              foregroundColor: Theme.of(
                context,
              ).colorScheme.onTertiaryContainer,
              fixedSize: const Size.fromHeight(100),
            ),
          ),
        ),
      ],
    );
  }
}

// Contains AI-generated edits.
