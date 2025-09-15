import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/file_picker_util.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/models/extended_audio_category.dart';
import 'package:soundboard/core/models/custom_category.dart';
import 'package:soundboard/core/providers/custom_category_providers.dart';
import 'package:soundboard/common/widgets/dialogs/custom_category_management_dialog.dart';
import 'package:soundboard/core/providers/custom_category_file_providers.dart';
import 'package:soundboard/core/models/custom_category_file.dart';

/// Extended jingle upload dialog that supports both predefined and custom categories
class ExtendedJingleUploadDialog extends ConsumerStatefulWidget {
  const ExtendedJingleUploadDialog({super.key});

  @override
  ConsumerState<ExtendedJingleUploadDialog> createState() =>
      _ExtendedJingleUploadDialogState();
}

class _ExtendedJingleUploadDialogState
    extends ConsumerState<ExtendedJingleUploadDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final Logger _logger = const Logger('ExtendedJingleUploadDialog');

  // Track upload progress for each category
  final Map<String, List<String>> _uploadProgress =
      {}; // Using category ID as key
  final Map<String, bool> _isUploading = {};

  // Track bulk selection for each category
  final Map<String, Set<String>> _selectedFiles = {};
  final Map<String, bool> _isSelectionMode = {};

  List<ExtendedAudioCategory> _allCategories = [];

  @override
  void initState() {
    super.initState();
    // Initialize a temporary controller to prevent errors
    _tabController = TabController(length: 1, vsync: this);
  }

  void _initializeTabsIfNeeded(List<CustomCategory> customCategories) {
    // Get predefined categories
    final predefinedCategories =
        ExtendedAudioCategoryUtils.getAllPredefinedCategories();

    // Convert custom categories
    final customCategoryExtended = customCategories
        .map(
          (cat) =>
              ExtendedAudioCategoryUtils.fromCustomCategory(cat.id, cat.name),
        )
        .toList();

    final newCategories = [...predefinedCategories, ...customCategoryExtended];
    final newTabCount = newCategories.length + 1; // +1 for manage tab

    // Check if we need to reinitialize tabs
    bool needsReinit = false;

    // Check if tab count changed
    if (_tabController.length != newTabCount) {
      needsReinit = true;
      _logger.d('Tab count changed: ${_tabController.length} -> $newTabCount');
    }

    // Check if category list changed (different number or different IDs)
    if (_allCategories.length != newCategories.length) {
      needsReinit = true;
      _logger.d(
        'Category count changed: ${_allCategories.length} -> ${newCategories.length}',
      );
    } else {
      // Check if any category IDs are different
      for (int i = 0; i < _allCategories.length; i++) {
        if (_allCategories[i].id != newCategories[i].id) {
          needsReinit = true;
          _logger.d(
            'Category changed at index $i: ${_allCategories[i].id} -> ${newCategories[i].id}',
          );
          break;
        }
      }
    }

    if (needsReinit) {
      _logger.d('Reinitializing tabs due to category changes');

      // Dispose old controller
      final oldIndex = _tabController.index;
      _tabController.dispose();

      // Create new controller
      _tabController = TabController(
        length: newTabCount,
        vsync: this,
        initialIndex: oldIndex < newTabCount ? oldIndex : 0,
      );

      _allCategories = newCategories;

      // Initialize progress tracking for new categories
      for (final category in _allCategories) {
        if (!_uploadProgress.containsKey(category.id)) {
          _uploadProgress[category.id] = [];
          _isUploading[category.id] = false;
          _selectedFiles[category.id] = <String>{};
          _isSelectionMode[category.id] = false;

          // Pre-load files for custom categories to ensure they're cached
          if (category is CustomAudioCategory) {
            Future.microtask(() {
              ref
                  .read(customCategoryFilesNotifierProvider.notifier)
                  .refreshCategory(category.customId);
            });
          }
        }
      }

      // Force a rebuild to ensure UI reflects the changes
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (category is PredefinedAudioCategory) {
      // Use existing color logic for predefined categories
      switch (category.category) {
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
    } else if (category is CustomAudioCategory) {
      // Use a default color for custom categories (could be extended to use category.colorHex)
      return Color.alphaBlend(
        const Color(0xFF9C27B0).withAlpha(128),
        colorScheme.primaryContainer,
      );
    }

    return colorScheme.primaryContainer;
  }

  IconData _getCategoryIcon(ExtendedAudioCategory category) {
    if (category is PredefinedAudioCategory) {
      switch (category.category) {
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
    } else if (category is CustomAudioCategory) {
      return Icons.folder_special; // Default icon for custom categories
    }

    return Icons.music_note;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen for changes in custom categories and force rebuild
    ref.listen<AsyncValue<List<CustomCategory>>>(customCategoriesProvider, (
      previous,
      next,
    ) {
      next.whenData((categories) {
        _logger.d(
          'Custom categories changed, rebuilding tabs: ${categories.length} categories',
        );
        if (mounted) {
          setState(() {});
        }
      });
    });

    // Get custom categories and initialize tabs reactively
    final customCategoriesAsync = ref.watch(customCategoriesProvider);

    return customCategoriesAsync.when(
      data: (customCategories) {
        // Initialize tabs based on current categories
        _initializeTabsIfNeeded(customCategories);

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
                tabs: [
                  // Tabs for all categories
                  ..._allCategories.map(
                    (category) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getCategoryIcon(category), size: 18),
                          const SizedBox(width: 8),
                          Text(category.displayName),
                        ],
                      ),
                    ),
                  ),
                  // Management tab
                  const Tab(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings, size: 18),
                        SizedBox(width: 8),
                        Text('Manage Categories'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: TabBarView(
              controller: _tabController,
              children: [
                // Category upload tabs
                ..._allCategories.map(
                  (category) => _buildCategoryUploadTab(context, category),
                ),
                // Management tab
                _buildManagementTab(context),
              ],
            ),
          ),
        );
      },
      loading: () => const Dialog.fullscreen(
        child: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (error, stackTrace) => Dialog.fullscreen(
        child: Scaffold(
          body: Center(child: Text('Error loading categories: $error')),
        ),
      ),
    );
  }

  Widget _buildCategoryUploadTab(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _getCategoryColor(context, category),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    color: colorScheme.primary,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.displayName,
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
          const SizedBox(height: 24),

          // Upload area
          Expanded(child: _buildUploadArea(context, category)),

          // Action buttons
          const SizedBox(height: 16),
          _buildActionButtons(context, category),
        ],
      ),
    );
  }

  Widget _buildUploadArea(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
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

        const SizedBox(height: 16),

        // Existing files list
        Expanded(child: _buildExistingFiles(context, category)),
      ],
    );
  }

  Widget _buildExistingFiles(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    if (category is PredefinedAudioCategory) {
      // Use existing jingle manager for predefined categories
      final jingleManagerAsync = ref.watch(jingleManagerProvider);
      return jingleManagerAsync.when(
        data: (jingleManager) {
          final existingFiles = jingleManager.audioManager.audioInstances
              .where((audio) => audio.audioCategory == category.category)
              .toList();

          if (existingFiles.isEmpty) {
            return _buildEmptyState(context, category);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilesHeader(context, category.id, existingFiles.length),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: existingFiles.length,
                  itemBuilder: (context, index) {
                    final file = existingFiles[index];
                    return _buildFileCard(context, file, category);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading files: $error')),
      );
    } else if (category is CustomAudioCategory) {
      // For custom categories, use the custom category file notifier provider
      final customCategoryFilesNotifier = ref.watch(
        customCategoryFilesNotifierProvider,
      );
      final customCategoryFilesAsync =
          customCategoryFilesNotifier[category.customId];

      if (customCategoryFilesAsync == null) {
        // If category not loaded yet, trigger load and show loading
        Future.microtask(() {
          ref
              .read(customCategoryFilesNotifierProvider.notifier)
              .refreshCategory(category.customId);
        });
        return const Center(child: CircularProgressIndicator());
      }

      return customCategoryFilesAsync.when(
        data: (customFiles) {
          if (customFiles.isEmpty) {
            return _buildEmptyState(context, category);
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFilesHeader(context, category.id, customFiles.length),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: customFiles.length,
                  itemBuilder: (context, index) {
                    final file = customFiles[index];
                    return _buildCustomFileCard(context, file, category);
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Error loading files: $error')),
      );
    } else {
      // Fallback for unknown category types
      return _buildEmptyState(context, category);
    }
  }

  Widget _buildFilesHeader(
    BuildContext context,
    String categoryId,
    int totalFiles,
  ) {
    final theme = Theme.of(context);
    final isSelectionMode = _isSelectionMode[categoryId] ?? false;
    final selectedCount = _selectedFiles[categoryId]?.length ?? 0;

    if (isSelectionMode) {
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
        'Existing Files ($totalFiles)',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      );
    }
  }

  Widget _buildEmptyState(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.music_note_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No files uploaded yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first audio files to get started',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFileCard(
    BuildContext context,
    dynamic audioFile,
    ExtendedAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryId = category.id;
    final isSelectionMode = _isSelectionMode[categoryId] ?? false;
    final isSelected =
        _selectedFiles[categoryId]?.contains(audioFile.filePath) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? colorScheme.primaryContainer.withAlpha(100) : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (value) =>
                    _toggleFileSelection(categoryId, audioFile.filePath),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
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
        title: Text(audioFile.displayName, style: theme.textTheme.titleSmall),
        subtitle: Text(
          audioFile.filePath.split('/').last.split('\\').last,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: isSelectionMode
            ? null
            : PopupMenuButton<String>(
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
            ? () => _toggleFileSelection(categoryId, audioFile.filePath)
            : null,
      ),
    );
  }

  Widget _buildCustomFileCard(
    BuildContext context,
    CustomCategoryFile file,
    CustomAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final categoryId = category.id;
    final isSelectionMode = _isSelectionMode[categoryId] ?? false;
    final isSelected =
        _selectedFiles[categoryId]?.contains(file.fileName) ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? colorScheme.primaryContainer.withAlpha(100) : null,
      child: ListTile(
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelectionMode) ...[
              Checkbox(
                value: isSelected,
                onChanged: (value) =>
                    _toggleFileSelection(categoryId, file.fileName),
              ),
              const SizedBox(width: 8),
            ],
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
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
          file.nameWithoutExtension,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              file.fileName,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${file.formattedSize} • ${file.extension.toUpperCase()}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withAlpha(160),
                fontSize: 11,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: isSelectionMode
            ? null
            : PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') {
                    _showDeleteCustomFileConfirmation(context, file, category);
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
            ? () => _toggleFileSelection(categoryId, file.fileName)
            : null,
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    final isUploading = _isUploading[category.id] ?? false;
    final isSelectionMode = _isSelectionMode[category.id] ?? false;
    final selectedCount = _selectedFiles[category.id]?.length ?? 0;

    if (isSelectionMode) {
      // Get total file count for "Select All" logic
      int totalFiles = 0;

      if (category is PredefinedAudioCategory) {
        final jingleManagerAsync = ref.watch(jingleManagerProvider);
        totalFiles =
            jingleManagerAsync.whenOrNull(
              data: (jingleManager) => jingleManager.audioManager.audioInstances
                  .where((audio) => audio.audioCategory == category.category)
                  .length,
            ) ??
            0;
      } else if (category is CustomAudioCategory) {
        final customCategoryFilesNotifier = ref.watch(
          customCategoryFilesNotifierProvider,
        );
        final customCategoryFilesAsync =
            customCategoryFilesNotifier[category.customId];
        totalFiles =
            customCategoryFilesAsync?.whenOrNull(
              data: (customFiles) => customFiles.length,
            ) ??
            0;
      }

      final allSelected = selectedCount == totalFiles && totalFiles > 0;

      // Selection mode buttons
      return Row(
        children: [
          OutlinedButton.icon(
            onPressed: () => _exitSelectionMode(category.id),
            icon: const Icon(Icons.close),
            label: const Text('Cancel'),
          ),
          const SizedBox(width: 8),
          if (totalFiles > 0) ...[
            OutlinedButton.icon(
              onPressed: allSelected
                  ? () => _deselectAllFiles(category.id)
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
            onPressed: isUploading
                ? null
                : () => _enterSelectionMode(category.id),
            icon: const Icon(Icons.checklist),
            label: const Text('Select'),
          ),
        ],
      );
    }
  }

  Widget _buildManagementTab(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Categories',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Text(
            'Create and manage your own sound categories to organize your audio files.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),

          // Create category button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showCreateCategoryDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New Category'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // List of existing custom categories
          Expanded(child: _buildCustomCategoriesList(context)),
        ],
      ),
    );
  }

  Widget _buildCustomCategoriesList(BuildContext context) {
    final customCategoriesAsync = ref.watch(customCategoriesProvider);

    return customCategoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  'No custom categories yet',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your first custom category to get started',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _buildCustomCategoryCard(context, category);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading custom categories: $error')),
    );
  }

  Widget _buildCustomCategoryCard(
    BuildContext context,
    CustomCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(
              int.parse(category.colorHex.replaceFirst('#', '0xFF')),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getIconFromName(category.iconName),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(category.name, style: theme.textTheme.titleSmall),
        subtitle: Text(
          category.description,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _showEditCategoryDialog(context, category);
                break;
              case 'delete':
                _showDeleteCategoryConfirmation(context, category);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
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
      ),
    );
  }

  String _getCategoryDescription(ExtendedAudioCategory category) {
    if (category is PredefinedAudioCategory) {
      switch (category.category) {
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
    } else if (category is CustomAudioCategory) {
      return 'Custom category created by user';
    }
    return 'Audio category';
  }

  IconData _getIconFromName(String iconName) {
    switch (iconName) {
      case 'music_note':
        return Icons.music_note;
      case 'star':
        return Icons.star;
      case 'sports_soccer':
        return Icons.sports_soccer;
      case 'campaign':
        return Icons.campaign;
      case 'warning':
        return Icons.warning;
      case 'pan_tool':
        return Icons.pan_tool;
      case 'folder_special':
        return Icons.folder_special;
      default:
        return Icons.music_note;
    }
  }

  Future<void> _handleFileUpload(ExtendedAudioCategory category) async {
    setState(() {
      _isUploading[category.id] = true;
      _uploadProgress[category.id] = [];
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
          _isUploading[category.id] = false;
        });
      }
    }
  }

  Future<void> _copyFilesToDestination(
    List<File> files,
    ExtendedAudioCategory category,
  ) async {
    final directoryName = category.directoryName;
    bool hasSuccessfulUploads = false;

    for (final file in files) {
      try {
        final fileName = file.path.split('/').last.split('\\').last;
        final cacheDirectory = await getApplicationCacheDirectory();
        final destinationPath =
            '${cacheDirectory.path}/$directoryName/$fileName';
        final destinationFile = File(destinationPath);
        await destinationFile.parent.create(recursive: true);
        await file.copy(destinationPath);

        setState(() {
          _uploadProgress[category.id]?.add(fileName);
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

    // Trigger jingle manager refresh if any files were successfully uploaded to predefined categories
    if (hasSuccessfulUploads && category is PredefinedAudioCategory) {
      ref.read(jingleManagerProvider.notifier).reinitialize();
      _logger.d("Triggered jingle manager refresh after successful uploads");
    }

    // Trigger custom category file refresh if any files were successfully uploaded to custom categories
    if (hasSuccessfulUploads && category is CustomAudioCategory) {
      ref
          .read(customCategoryFilesNotifierProvider.notifier)
          .refreshCategory(category.customId);
      _logger.d(
        "Triggered custom category file refresh after successful uploads",
      );
    }
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    dynamic audioFile,
  ) async {
    // Implement delete confirmation dialog for predefined categories
    // This will be similar to the existing implementation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text(
          'Are you sure you want to delete "${audioFile.displayName}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement deletion for predefined categories
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Deletion for predefined categories not yet implemented',
                  ),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteCustomFileConfirmation(
    BuildContext context,
    CustomCategoryFile file,
    CustomAudioCategory category,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await ref
            .read(customCategoryFilesNotifierProvider.notifier)
            .deleteFile(category.customId, file.fileName);

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully deleted "${file.fileName}"'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete "${file.fileName}"'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showCreateCategoryDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => const CustomCategoryManagementDialog(),
    );

    // Force a rebuild after the dialog is closed to ensure new categories are shown
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _showEditCategoryDialog(
    BuildContext context,
    CustomCategory category,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => CustomCategoryManagementDialog(category: category),
    );
  }

  Future<void> _showDeleteCategoryConfirmation(
    BuildContext context,
    CustomCategory category,
  ) async {
    bool deleteCachedFiles = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete Category'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete "${category.name}"? This will also delete all associated sound groups.',
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: deleteCachedFiles,
                onChanged: (value) {
                  setState(() {
                    deleteCachedFiles = value ?? false;
                  });
                },
                title: const Text('Delete cached audio files'),
                subtitle: const Text(
                  'Remove all uploaded files from device storage',
                ),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop({
                'confirmed': true,
                'deleteCachedFiles': deleteCachedFiles,
              }),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );

    if (result?['confirmed'] == true && context.mounted) {
      try {
        // Delete the category first
        await ref
            .read(customCategoriesProvider.notifier)
            .deleteCategory(category.id);

        // Delete cached files if requested
        if (result?['deleteCachedFiles'] == true) {
          final filesDeleted = await ref
              .read(customCategoryFilesNotifierProvider.notifier)
              .deleteAllFiles(category.id);
          if (context.mounted) {
            final message = filesDeleted
                ? 'Deleted category "${category.name}" and cached files'
                : 'Deleted category "${category.name}" (cached files could not be deleted)';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(message)));
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Deleted category "${category.name}"')),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting category: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  // Bulk selection methods
  void _enterSelectionMode(String categoryId) {
    setState(() {
      _isSelectionMode[categoryId] = true;
      _selectedFiles[categoryId] = <String>{};
    });
  }

  void _exitSelectionMode(String categoryId) {
    setState(() {
      _isSelectionMode[categoryId] = false;
      _selectedFiles[categoryId]?.clear();
    });
  }

  void _toggleFileSelection(String categoryId, String fileIdentifier) {
    setState(() {
      final selectedFiles = _selectedFiles[categoryId] ??= <String>{};
      if (selectedFiles.contains(fileIdentifier)) {
        selectedFiles.remove(fileIdentifier);
      } else {
        selectedFiles.add(fileIdentifier);
      }
    });
  }

  void _selectAllFiles(ExtendedAudioCategory category) {
    if (category is PredefinedAudioCategory) {
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      jingleManagerAsync.whenData((jingleManager) {
        final existingFiles = jingleManager.audioManager.audioInstances
            .where((audio) => audio.audioCategory == category.category)
            .toList();

        setState(() {
          final selectedFiles = _selectedFiles[category.id] ??= <String>{};
          for (final file in existingFiles) {
            selectedFiles.add(file.filePath);
          }
        });
      });
    } else if (category is CustomAudioCategory) {
      final customCategoryFilesNotifier = ref.read(
        customCategoryFilesNotifierProvider,
      );
      final customCategoryFilesAsync =
          customCategoryFilesNotifier[category.customId];

      customCategoryFilesAsync?.whenData((customFiles) {
        setState(() {
          final selectedFiles = _selectedFiles[category.id] ??= <String>{};
          for (final file in customFiles) {
            selectedFiles.add(file.fileName);
          }
        });
      });
    }
  }

  void _deselectAllFiles(String categoryId) {
    setState(() {
      _selectedFiles[categoryId]?.clear();
    });
  }

  Future<void> _deleteSelectedFiles(ExtendedAudioCategory category) async {
    final selectedFiles = _selectedFiles[category.id];
    if (selectedFiles == null || selectedFiles.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Selected Files'),
        content: Text(
          'Are you sure you want to delete ${selectedFiles.length} selected files?',
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

      if (category is PredefinedAudioCategory) {
        // Handle predefined category file deletion
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

        // Refresh the jingle manager
        ref.read(jingleManagerProvider.notifier).reinitialize();
      } else if (category is CustomAudioCategory) {
        // Handle custom category file deletion
        for (final fileName in selectedFiles) {
          try {
            final success = await ref
                .read(customCategoryFilesNotifierProvider.notifier)
                .deleteFile(category.customId, fileName);
            if (success) {
              deletedCount++;
            }
          } catch (e) {
            _logger.e("Error deleting file $fileName: $e");
          }
        }
      }

      // Exit selection mode
      _exitSelectionMode(category.id);

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
}
