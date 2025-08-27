import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

class JingleManagementButton extends ConsumerStatefulWidget {
  final String directoryName;
  final AudioCategory audioCategory;

  const JingleManagementButton({
    super.key,
    required this.directoryName,
    required this.audioCategory,
  });

  @override
  ConsumerState<JingleManagementButton> createState() =>
      _JingleManagementButtonState();
}

class _JingleManagementButtonState
    extends ConsumerState<JingleManagementButton> {
  final Logger logger = const Logger('JingleManagementButton');

  Future<void> _copyFileToDestination(List<File>? files) async {
    if (files == null) return;

    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir = Directory(
      '${appSupportDir.path}/${widget.directoryName}',
    );

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
        logger.d("Jingle file copied to $targetPath");
        hasSuccessfulUploads = true;

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Jingle file "$fileName" uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        logger.e("Failed to copy jingle file: $e");
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

    // Trigger jingle manager refresh if any files were successfully uploaded
    if (hasSuccessfulUploads) {
      ref.read(jingleManagerProvider.notifier).reinitialize();
      logger.d("Triggered jingle manager refresh after successful uploads");
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
          logger.d("Jingle file upload cancelled");
        },
      );
    } catch (e) {
      logger.e("Error during jingle file upload: $e");
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

  Future<void> _showJingleManager() async {
    try {
      final Directory appSupportDir = await getApplicationCacheDirectory();
      final Directory jingleDir = Directory(
        '${appSupportDir.path}/${widget.directoryName}',
      );

      // Create directory if it doesn't exist
      if (!await jingleDir.exists()) {
        await jingleDir.create(recursive: true);
      }

      final files = jingleDir
          .listSync()
          .where(
            (file) =>
                file is File &&
                (file.path.toLowerCase().endsWith('.mp3') ||
                    file.path.toLowerCase().endsWith('.flac') ||
                    file.path.toLowerCase().endsWith('.ogg') ||
                    file.path.toLowerCase().endsWith('.wav') ||
                    file.path.toLowerCase().endsWith('.m4a')),
          )
          .cast<File>()
          .toList();

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('${widget.directoryName} Manager'),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: Column(
                children: [
                  // Upload button at the top
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        Navigator.of(context).pop(); // Close dialog
                        await _handleUpload();
                        _showJingleManager(); // Reopen to show new files
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Files'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimaryContainer,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // File list
                  Expanded(
                    child: files.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No jingle files found',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap "Upload Files" to add some',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: files.length,
                            itemBuilder: (context, index) {
                              final file = files[index];
                              final fileName = Platform.isWindows
                                  ? file.path.split('\\').last
                                  : file.path.split('/').last;
                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.music_note,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSecondaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    fileName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${(file.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                    ),
                                    onPressed: () async {
                                      final shouldDelete = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete File'),
                                          content: Text(
                                            'Are you sure you want to delete "$fileName"?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () => Navigator.of(
                                                context,
                                              ).pop(true),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: Theme.of(
                                                  context,
                                                ).colorScheme.error,
                                              ),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (shouldDelete == true) {
                                        await file.delete();
                                        ref
                                            .read(
                                              jingleManagerProvider.notifier,
                                            )
                                            .reinitialize();
                                        Navigator.of(context).pop();
                                        _showJingleManager(); // Refresh the dialog
                                      }
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
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
      logger.e("Error showing jingle manager: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading jingle manager: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        final jingleCount = jingleManager.audioManager.audioInstances
            .where((element) => element.audioCategory == widget.audioCategory)
            .length;

        return _buildModernCard(context, jingleCount, _showJingleManager);
      },
      loading: () => _buildModernCard(context, 0, null, isLoading: true),
      error: (error, stack) =>
          _buildModernCard(context, 0, null, hasError: true),
    );
  }

  Widget _buildModernCard(
    BuildContext context,
    int fileCount,
    VoidCallback? onTap, {
    bool isLoading = false,
    bool hasError = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get category-specific styling
    final categoryInfo = _getCategoryInfo();

    String statusText = isLoading
        ? "Loading..."
        : hasError
        ? "Error"
        : "($fileCount files)";

    Color containerColor = hasError
        ? colorScheme.errorContainer
        : categoryInfo['containerColor'];

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [containerColor, containerColor.withAlpha(200)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: categoryInfo['iconColor'],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryInfo['icon'],
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.directoryName,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: hasError
                            ? colorScheme.onErrorContainer
                            : categoryInfo['textColor'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${categoryInfo['description']} $statusText',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: hasError
                            ? colorScheme.onErrorContainer.withAlpha(200)
                            : categoryInfo['textColor'].withAlpha(200),
                      ),
                    ),
                    if (!isLoading && !hasError) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildFeatureChip(context, 'Upload'),
                          const SizedBox(width: 8),
                          _buildFeatureChip(context, 'Manage'),
                          const SizedBox(width: 8),
                          _buildFeatureChip(
                            context,
                            categoryInfo['formatChip'],
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (!isLoading) ...[
                Icon(
                  hasError ? Icons.error : Icons.arrow_forward_ios,
                  color: hasError
                      ? colorScheme.onErrorContainer
                      : categoryInfo['textColor'],
                ),
              ] else ...[
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getCategoryInfo() {
    final colorScheme = Theme.of(context).colorScheme;

    switch (widget.audioCategory) {
      case AudioCategory.goalJingle:
        return {
          'icon': Icons.sports_soccer,
          'iconColor': const Color(0xFF4CAF50), // Green for goals
          'containerColor': Color.alphaBlend(
            const Color(0xFF4CAF50).withAlpha(100),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Goal celebration sounds',
          'formatChip': 'Audio Files',
        };
      case AudioCategory.clapJingle:
        return {
          'icon': Icons.front_hand,
          'iconColor': const Color(0xFF2196F3), // Blue for clap
          'containerColor': Color.alphaBlend(
            const Color(0xFF2196F3).withAlpha(100),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Crowd clapping sounds',
          'formatChip': 'Audio Files',
        };
      case AudioCategory.specialJingle:
        return {
          'icon': Icons.star,
          'iconColor': const Color(0xFFE6B422), // Yellow/Gold for special
          'containerColor': Color.alphaBlend(
            const Color(0xFFE6B422).withAlpha(100),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Special event sounds',
          'formatChip': 'Audio Files',
        };
      case AudioCategory.goalHorn:
        return {
          'icon': Icons.campaign,
          'iconColor': const Color(0xFFFF5722), // Red/Orange for horn
          'containerColor': Color.alphaBlend(
            const Color(0xFFFF5722).withAlpha(100),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Air horn celebrations',
          'formatChip': 'Audio Files',
        };
      case AudioCategory.penaltyJingle:
        return {
          'icon': Icons.warning,
          'iconColor': const Color(0xFFFF9800), // Orange for penalty
          'containerColor': Color.alphaBlend(
            const Color(0xFFFF9800).withAlpha(100),
            colorScheme.primaryContainer,
          ),
          'textColor': colorScheme.onPrimaryContainer,
          'description': 'Penalty notification sounds',
          'formatChip': 'Audio Files',
        };
      default:
        return {
          'icon': Icons.music_note,
          'iconColor': colorScheme.primary,
          'containerColor': colorScheme.secondaryContainer,
          'textColor': colorScheme.onSecondaryContainer,
          'description': 'Jingle sounds',
          'formatChip': 'Audio Files',
        };
    }
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
}
