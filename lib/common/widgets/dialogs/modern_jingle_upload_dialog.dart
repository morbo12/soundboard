import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Modern unified jingle upload dialog with tabbed interface
class ModernJingleUploadDialog extends ConsumerStatefulWidget {
  const ModernJingleUploadDialog({super.key});

  @override
  ConsumerState<ModernJingleUploadDialog> createState() =>
      _ModernJingleUploadDialogState();
}

class _ModernJingleUploadDialogState
    extends ConsumerState<ModernJingleUploadDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Logger _logger = const Logger('ModernJingleUploadDialog');
  
  // Track upload progress for each category
  final Map<AudioCategory, List<String>> _uploadProgress = {};
  final Map<AudioCategory, bool> _isUploading = {};
  
  // Track bulk selection for each category
  final Map<AudioCategory, Set<String>> _selectedFiles = {};
  final Map<AudioCategory, bool> _isSelectionMode = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: AudioCategory.values.length, vsync: this);
    
    // Initialize progress tracking
    for (final category in AudioCategory.values) {
      _uploadProgress[category] = [];
      _isUploading[category] = false;
      _selectedFiles[category] = <String>{};
      _isSelectionMode[category] = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(BuildContext context, AudioCategory category) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (category) {
      case AudioCategory.specialJingle:
      case AudioCategory.goalHorn:
      case AudioCategory.penaltyJingle:
        return Color.alphaBlend(
          const Color(0xFFE6B422).withAlpha(128),
          colorScheme.primaryContainer,
        );
      case AudioCategory.goalJingle:
        return Color.alphaBlend(
          const Color(0xFF4CAF50).withAlpha(128),
          colorScheme.primaryContainer,
        );
      case AudioCategory.genericJingle:
        return colorScheme.primaryContainer;
      case AudioCategory.clapJingle:
        return colorScheme.tertiaryContainer;
    }
  }

  IconData _getCategoryIcon(AudioCategory category) {
    switch (category) {
      case AudioCategory.specialJingle:
        return Icons.star;
      case AudioCategory.goalJingle:
        return Icons.sports_soccer;
      case AudioCategory.goalHorn:
        return Icons.campaign;
      case AudioCategory.penaltyJingle:
        return Icons.warning;
      case AudioCategory.genericJingle:
        return Icons.music_note;
      case AudioCategory.clapJingle:
        return Icons.pan_tool;
    }
  }

  String _formatCategoryName(AudioCategory category) {
    final name = category.toString().split('.').last;
    return name.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    ).trim().split(' ').map((word) => 
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  String _getCategoryDirectoryName(AudioCategory category) {
    switch (category) {
      case AudioCategory.genericJingle:
        return "GenericJingles";
      case AudioCategory.goalJingle:
        return "GoalJingles";
      case AudioCategory.clapJingle:
        return "ClapJingles";
      case AudioCategory.specialJingle:
        return "SpecialJingles";
      case AudioCategory.goalHorn:
        return "GoalHorn";
      case AudioCategory.penaltyJingle:
        return "PenaltyJingles";
    }
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
              Icon(Icons.cloud_upload, color: colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Upload Jingles'),
            ],
          ),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: AudioCategory.values.map((category) => Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_getCategoryIcon(category), size: 18),
                  const SizedBox(width: 8),
                  Text(_formatCategoryName(category)),
                ],
              ),
            )).toList(),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: AudioCategory.values.map((category) =>
            _buildCategoryUploadTab(context, category)
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildCategoryUploadTab(BuildContext context, AudioCategory category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryColor = _getCategoryColor(context, category);
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header with info
          Card(
            color: categoryColor.withAlpha(100),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getCategoryIcon(category),
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
                          _formatCategoryName(category),
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCategoryDescription(category),
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
          Expanded(
            child: _buildUploadArea(context, category),
          ),

          // Action buttons
          const SizedBox(height: 16),
          _buildActionButtons(context, category),
        ],
      ),
    );
  }

  Widget _buildUploadArea(BuildContext context, AudioCategory category) {
    return Column(
      children: [
        // Upload button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleFileUpload(category),
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Upload Files'),
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
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            Chip(
              label: const Text('.flac'),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
              labelStyle: Theme.of(context).textTheme.bodySmall,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            if (!Platform.isWindows) ...[
              Chip(
                label: const Text('.ogg'),
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                labelStyle: Theme.of(context).textTheme.bodySmall,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        
        // Existing files list
        Expanded(
          child: _buildExistingFiles(context, category),
        ),
      ],
    );
  }

  Widget _buildExistingFiles(BuildContext context, AudioCategory category) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        final existingFiles = jingleManager.audioManager.audioInstances
            .where((audio) => audio.audioCategory == category)
            .toList();

        if (existingFiles.isEmpty) {
          return _buildEmptyState(context, category);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilesHeader(context, category, existingFiles.length),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: existingFiles.length,
                itemBuilder: (context, index) {
                  final file = existingFiles[index];
                  return _buildFileCard(context, file);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Text('Error loading files: $error'),
      ),
    );
  }

  Widget _buildFilesHeader(BuildContext context, AudioCategory category, int totalFiles) {
    final theme = Theme.of(context);
    final isSelectionMode = _isSelectionMode[category] ?? false;
    final selectedCount = _selectedFiles[category]?.length ?? 0;

    if (isSelectionMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.checklist,
              size: 20,
              color: theme.colorScheme.primary,
            ),
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
        'Existing Files ($totalFiles)',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  Widget _buildEmptyState(BuildContext context, AudioCategory category) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No files in this category',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload some audio files to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, dynamic audioFile) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelectionMode = _isSelectionMode[audioFile.audioCategory] ?? false;
    final isSelected = _selectedFiles[audioFile.audioCategory]?.contains(audioFile.filePath) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: isSelected ? colorScheme.primaryContainer.withAlpha(100) : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (value) => _toggleFileSelection(audioFile.audioCategory, audioFile.filePath),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getCategoryColor(context, audioFile.audioCategory),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.music_note,
                color: colorScheme.onPrimaryContainer,
                size: 20,
              ),
            ),
          ],
        ),
        title: Text(
          audioFile.displayName,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          audioFile.filePath.split('/').last.split('\\').last,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isSelectionMode ? null : PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'delete') {
              _showDeleteConfirmation(context, audioFile);
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
        onTap: isSelectionMode 
          ? () => _toggleFileSelection(audioFile.audioCategory, audioFile.filePath)
          : null,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AudioCategory category) {
    final isUploading = _isUploading[category] ?? false;
    final isSelectionMode = _isSelectionMode[category] ?? false;
    final selectedCount = _selectedFiles[category]?.length ?? 0;

    if (isSelectionMode) {
      // Get total file count for "Select All" logic
      final jingleManagerAsync = ref.watch(jingleManagerProvider);
      final totalFiles = jingleManagerAsync.whenOrNull(
        data: (jingleManager) => jingleManager.audioManager.audioInstances
            .where((audio) => audio.audioCategory == category)
            .length,
      ) ?? 0;
      
      final allSelected = selectedCount == totalFiles && totalFiles > 0;

      // Selection mode buttons
      return Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => _exitSelectionMode(category),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          if (totalFiles > 0) ...[
            OutlinedButton.icon(
              onPressed: allSelected 
                ? () => _deselectAllFiles(category)
                : () => _selectAllFiles(category),
              icon: Icon(allSelected ? Icons.deselect : Icons.select_all),
              label: Text(allSelected ? 'Deselect All' : 'Select All'),
            ),
          ],
          if (selectedCount > 0) ...[
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: () => _deleteSelectedFiles(category),
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
    } else {
      // Normal mode buttons
      return Row(
        children: [
          OutlinedButton.icon(
            onPressed: isUploading ? null : () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
          ),
          const Spacer(),
          OutlinedButton.icon(
            onPressed: isUploading ? null : () => _enterSelectionMode(category),
            icon: const Icon(Icons.checklist),
            label: const Text('Select'),
          ),
        ],
      );
    }
  }

  String _getCategoryDescription(AudioCategory category) {
    switch (category) {
      case AudioCategory.genericJingle:
        return 'General purpose jingles for any occasion';
      case AudioCategory.goalJingle:
        return 'Celebration sounds for goals and victories';
      case AudioCategory.clapJingle:
        return 'Applause and crowd reaction sounds';
      case AudioCategory.specialJingle:
        return 'Special effects and unique audio clips';
      case AudioCategory.goalHorn:
        return 'Horn sounds for goal celebrations';
      case AudioCategory.penaltyJingle:
        return 'Audio cues for penalties and infractions';
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, dynamic audioFile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${audioFile.displayName}"?'),
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
      await _deleteFile(audioFile);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deleted "${audioFile.displayName}"'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _deleteFile(dynamic audioFile) async {
    try {
      final file = File(audioFile.filePath);
      if (await file.exists()) {
        await file.delete();
      }
      
      // Refresh the jingle manager to update the UI
      ref.read(jingleManagerProvider.notifier).reinitialize();
      _logger.d("Deleted file: ${audioFile.filePath}");
    } catch (e) {
      _logger.e("Error deleting file: $e");
    }
  }

  // Bulk selection methods
  void _enterSelectionMode(AudioCategory category) {
    setState(() {
      _isSelectionMode[category] = true;
      _selectedFiles[category] = <String>{};
    });
  }

  void _exitSelectionMode(AudioCategory category) {
    setState(() {
      _isSelectionMode[category] = false;
      _selectedFiles[category]?.clear();
    });
  }

  void _toggleFileSelection(AudioCategory category, String filePath) {
    setState(() {
      final selectedFiles = _selectedFiles[category] ??= <String>{};
      if (selectedFiles.contains(filePath)) {
        selectedFiles.remove(filePath);
      } else {
        selectedFiles.add(filePath);
      }
    });
  }

  void _selectAllFiles(AudioCategory category) {
    final jingleManagerAsync = ref.read(jingleManagerProvider);
    jingleManagerAsync.whenData((jingleManager) {
      final existingFiles = jingleManager.audioManager.audioInstances
          .where((audio) => audio.audioCategory == category)
          .toList();
      
      setState(() {
        final selectedFiles = _selectedFiles[category] ??= <String>{};
        for (final file in existingFiles) {
          selectedFiles.add(file.filePath);
        }
      });
    });
  }

  void _deselectAllFiles(AudioCategory category) {
    setState(() {
      _selectedFiles[category]?.clear();
    });
  }

  Future<void> _deleteSelectedFiles(AudioCategory category) async {
    final selectedFiles = _selectedFiles[category];
    if (selectedFiles == null || selectedFiles.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Files'),
        content: Text('Are you sure you want to delete ${selectedFiles.length} selected files?'),
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
      for (final filePath in selectedFiles) {
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

      // Refresh the jingle manager and exit selection mode
      ref.read(jingleManagerProvider.notifier).reinitialize();
      _exitSelectionMode(category);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted $deletedCount files'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _handleFileUpload(AudioCategory category) async {
    setState(() {
      _isUploading[category] = true;
      _uploadProgress[category] = [];
    });

    try {
      pickFile(
        allowedExtensions: Platform.isWindows
            ? ['mp3', 'flac']
            : ['mp3', 'flac', 'ogg'],
        allowMultiple: true,
        onMultipleFilesSelected: (files) async {
          await _copyFilesToDestination(files, category);
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
          _isUploading[category] = false;
        });
      }
    }
  }

  Future<void> _copyFilesToDestination(List<File> files, AudioCategory category) async {
    final directoryName = _getCategoryDirectoryName(category);
    bool hasSuccessfulUploads = false;

    for (final file in files) {
      try {
        final fileName = file.path.split('/').last.split('\\').last;
        final cacheDirectory = await getApplicationCacheDirectory();
        final destinationPath = '${cacheDirectory.path}/$directoryName/$fileName';
        final destinationFile = File(destinationPath);
        await destinationFile.parent.create(recursive: true);
        await file.copy(destinationPath);

        setState(() {
          _uploadProgress[category]?.add(fileName);
        });

        hasSuccessfulUploads = true;
        _logger.d("Successfully copied $fileName to $destinationPath");

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
        _logger.e("Failed to copy jingle file: $e");
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
      _logger.d("Triggered jingle manager refresh after successful uploads");
      
      // Force a UI refresh with a small delay to ensure files are visible
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        setState(() {});
      }
    }
  }
}
