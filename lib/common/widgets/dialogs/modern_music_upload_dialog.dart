import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/music_player/data/music_player_provider.dart';

/// Modern unified music upload dialog with bulk selection and management
class ModernMusicUploadDialog extends ConsumerStatefulWidget {
  const ModernMusicUploadDialog({super.key});

  @override
  ConsumerState<ModernMusicUploadDialog> createState() =>
      _ModernMusicUploadDialogState();
}

class _ModernMusicUploadDialogState
    extends ConsumerState<ModernMusicUploadDialog> {
  final Logger _logger = const Logger('ModernMusicUploadDialog');

  // Track upload progress and bulk selection
  final List<String> _uploadProgress = [];
  bool _isUploading = false;
  final Set<String> _selectedFiles = <String>{};
  bool _isSelectionMode = false;

  Color get _categoryColor {
    final colorScheme = Theme.of(context).colorScheme;
    return Color.alphaBlend(
      const Color(0xFF9C27B0).withAlpha(128),
      colorScheme.primaryContainer,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.library_music, color: colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Music Manager'),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category header with info
              Card(
                color: _categoryColor.withAlpha(100),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _categoryColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.library_music,
                          color: colorScheme.onPrimaryContainer,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Background Music',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Music files for lineup presentations and background ambiance',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Upload area
              Expanded(child: _buildUploadArea(context)),

              // Action buttons
              const SizedBox(height: 16),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context) {
    return Column(
      children: [
        // Upload button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleFileUpload(),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload Music Files'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Supported formats info
        Wrap(
          spacing: 4,
          children: [
            Chip(
              label: const Text('.mp3'),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: const Text('.flac'),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            if (!Platform.isWindows) ...[
              Chip(
                label: const Text('.ogg'),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHigh,
                labelStyle: Theme.of(context).textTheme.bodySmall,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
            Chip(
              label: const Text('.wav'),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: const Text('.m4a'),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHigh,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Existing files list
        Expanded(child: _buildExistingFiles(context)),
      ],
    );
  }

  Widget _buildExistingFiles(BuildContext context) {
    return FutureBuilder<List<File>>(
      future: _getMusicFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading files: ${snapshot.error}'));
        }

        final files = snapshot.data ?? [];

        if (files.isEmpty) {
          return _buildEmptyState(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilesHeader(context, files.length),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return _buildFileCard(context, file);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilesHeader(BuildContext context, int totalFiles) {
    final theme = Theme.of(context);
    final selectedCount = _selectedFiles.length;

    if (_isSelectionMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.checklist, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              'Selection Mode: $selectedCount of $totalFiles selected',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        'Music Files ($totalFiles)',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_music,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No music files uploaded',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload some music files to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, File file) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileName = Platform.isWindows
        ? file.path.split('\\').last
        : file.path.split('/').last;
    final isSelected = _selectedFiles.contains(file.path);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: isSelected ? colorScheme.primaryContainer.withAlpha(100) : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isSelectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleFileSelection(file.path),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _categoryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.library_music,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ],
        ),
        title: Text(fileName, style: theme.textTheme.titleSmall),
        subtitle: FutureBuilder<int>(
          future: file.length(),
          builder: (context, snapshot) {
            final size = snapshot.data ?? 0;
            return Text(
              '${(size / 1024 / 1024).toStringAsFixed(2)} MB',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            );
          },
        ),
        trailing: _isSelectionMode
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteConfirmation(context, file);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ],
              ),
        onTap: _isSelectionMode ? () => _toggleFileSelection(file.path) : null,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final selectedCount = _selectedFiles.length;

    if (_isSelectionMode) {
      return FutureBuilder<List<File>>(
        future: _getMusicFiles(),
        builder: (context, snapshot) {
          final totalFiles = snapshot.data?.length ?? 0;
          final allSelected = selectedCount == totalFiles && totalFiles > 0;

          return Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _exitSelectionMode(),
                icon: const Icon(Icons.close),
                label: const Text('Cancel'),
              ),
              const SizedBox(width: 8),
              if (totalFiles > 0) ...[
                OutlinedButton.icon(
                  onPressed: allSelected
                      ? () => _deselectAllFiles()
                      : () => _selectAllFiles(),
                  icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
                  label: Text(allSelected ? 'Deselect All' : 'Select All'),
                ),
              ],
              if (selectedCount > 0) ...[
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => _deleteSelectedFiles(),
                  icon: const Icon(Icons.delete),
                  label: Text('Delete ($selectedCount)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          );
        },
      );
    } else {
      return Row(
        children: [
          OutlinedButton.icon(
            onPressed: _isUploading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: _isUploading ? null : () => _enterSelectionMode(),
            icon: const Icon(Icons.checklist),
            label: const Text('Select'),
          ),
        ],
      );
    }
  }

  // Bulk selection methods
  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
      _selectedFiles.clear();
    });
  }

  void _exitSelectionMode() {
    setState(() {
      _isSelectionMode = false;
      _selectedFiles.clear();
    });
  }

  void _toggleFileSelection(String filePath) {
    setState(() {
      if (_selectedFiles.contains(filePath)) {
        _selectedFiles.remove(filePath);
      } else {
        _selectedFiles.add(filePath);
      }
    });
  }

  Future<void> _selectAllFiles() async {
    final files = await _getMusicFiles();
    setState(() {
      for (final file in files) {
        _selectedFiles.add(file.path);
      }
    });
  }

  void _deselectAllFiles() {
    setState(() {
      _selectedFiles.clear();
    });
  }

  Future<void> _deleteSelectedFiles() async {
    if (_selectedFiles.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Files'),
        content: Text(
          'Are you sure you want to delete ${_selectedFiles.length} selected files?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      int deletedCount = 0;
      for (final filePath in _selectedFiles) {
        try {
          final file = File(filePath);
          if (await file.exists()) {
            await file.delete();
            deletedCount++;
          }
        } catch (e) {
          _logger.e("Error deleting file $filePath: $e");
        }
      }

      // Refresh playlist and exit selection mode
      final refreshNotifier = ref.read(playlistRefreshProvider.notifier);
      refreshNotifier.state = refreshNotifier.state + 1;
      _exitSelectionMode();

      if (mounted) {
        setState(() {}); // Refresh the file list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $deletedCount music files'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, File file) async {
    final fileName = Platform.isWindows
        ? file.path.split('\\').last
        : file.path.split('/').last;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Music File'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await file.delete();
        final refreshNotifier = ref.read(playlistRefreshProvider.notifier);
        refreshNotifier.state = refreshNotifier.state + 1;

        if (mounted) {
          setState(() {}); // Refresh the file list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Deleted "$fileName"'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        _logger.e("Error deleting file: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete "$fileName": $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleFileUpload() async {
    setState(() {
      _isUploading = true;
      _uploadProgress.clear();
    });

    try {
      pickFile(
        allowedExtensions: Platform.isWindows
            ? ['mp3', 'flac', 'wav', 'm4a']
            : ['mp3', 'flac', 'ogg', 'wav', 'm4a'],
        allowMultiple: true,
        onMultipleFilesSelected: (files) async {
          await _copyFilesToDestination(files);
        },
        onError: (errorMessage) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Upload error: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    } catch (e) {
      _logger.e("Error during file upload: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _copyFilesToDestination(List<File> files) async {
    final Directory appSupportDir = await getApplicationCacheDirectory();
    final Directory targetDir = Directory('${appSupportDir.path}/Music');

    if (!await targetDir.exists()) {
      await targetDir.create(recursive: true);
    }

    bool hasSuccessfulUploads = false;

    for (final file in files) {
      try {
        final fileName = file.path.split('/').last.split('\\').last;
        final targetPath = '${targetDir.path}/$fileName';

        await file.copy(targetPath);

        setState(() {
          _uploadProgress.add(fileName);
        });

        hasSuccessfulUploads = true;
        _logger.d("Successfully copied $fileName to $targetPath");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully uploaded: $fileName'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        final fileName = file.path.split('/').last.split('\\').last;
        _logger.e("Failed to copy music file: $e");
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

    // Trigger playlist refresh and UI update if any files were successfully uploaded
    if (hasSuccessfulUploads) {
      final refreshNotifier = ref.read(playlistRefreshProvider.notifier);
      refreshNotifier.state = refreshNotifier.state + 1;
      _logger.d("Triggered playlist refresh after successful uploads");

      // Force a UI refresh with a small delay to ensure files are visible
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      }
    }
  }

  Future<List<File>> _getMusicFiles() async {
    try {
      final Directory appSupportDir = await getApplicationCacheDirectory();
      final Directory musicDir = Directory('${appSupportDir.path}/Music');

      if (!await musicDir.exists()) {
        return [];
      }

      return musicDir
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
    } catch (e) {
      _logger.e("Error loading music files: $e");
      return [];
    }
  }
}
