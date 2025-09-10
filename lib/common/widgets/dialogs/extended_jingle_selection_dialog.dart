import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/models/extended_audio_category.dart';
import 'package:soundboard/core/models/custom_category.dart';
import 'package:soundboard/core/models/sound_group.dart';
import 'package:soundboard/core/providers/custom_category_providers.dart';
import 'package:soundboard/core/providers/custom_category_file_providers.dart';
import 'package:soundboard/core/models/custom_category_file.dart';

/// Extended jingle selection dialog with support for custom categories and sound groups
class ExtendedJingleSelectionDialog extends ConsumerStatefulWidget {
  final String currentButtonName;
  final AudioFile? currentAudioFile;

  const ExtendedJingleSelectionDialog({
    super.key,
    required this.currentButtonName,
    this.currentAudioFile,
  });

  @override
  ConsumerState<ExtendedJingleSelectionDialog> createState() =>
      _ExtendedJingleSelectionDialogState();
}

class _ExtendedJingleSelectionDialogState
    extends ConsumerState<ExtendedJingleSelectionDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _preserveButtonName = false;
  final TextEditingController _searchController = TextEditingController();

  List<ExtendedAudioCategory> _allCategories = [];

  @override
  void initState() {
    super.initState();
    _initializeNamePreservation();
    _initializeTabs();
  }

  void _initializeTabs() {
    // Get predefined categories
    final predefinedCategories =
        ExtendedAudioCategoryUtils.getAllPredefinedCategories();

    // Get custom categories from provider
    final customCategoriesAsync = ref.read(customCategoriesProvider);
    final customCategories =
        customCategoriesAsync.whenOrNull(
          data: (categories) => categories
              .map(
                (cat) => ExtendedAudioCategoryUtils.fromCustomCategory(
                  cat.id,
                  cat.name,
                ),
              )
              .toList(),
        ) ??
        [];

    _allCategories = [...predefinedCategories, ...customCategories];

    _tabController = TabController(length: _allCategories.length, vsync: this);
  }

  void _initializeNamePreservation() {
    final currentName = widget.currentButtonName;
    final isEmptyButton = currentName == 'Empty';
    final isDefaultCategoryName = AudioCategory.values
        .map((cat) => cat.toString().split('.').last)
        .contains(currentName.replaceAll('\n', '').replaceAll(' ', ''));

    // Preserve name by default if it's a custom name
    _preserveButtonName = !isEmptyButton && !isDefaultCategoryName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Color _getCategoryColor(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    if (category is PredefinedAudioCategory) {
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
      return Icons.folder_special;
    }

    return Icons.music_note;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Watch for changes in custom categories and rebuild tabs
    ref.listen<AsyncValue<List<CustomCategory>>>(customCategoriesProvider, (
      previous,
      next,
    ) {
      next.whenData((_) {
        setState(() {
          _initializeTabs();
        });
      });
    });

    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.music_note, color: colorScheme.primary),
              const SizedBox(width: 12),
              const Text('Select Jingle'),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(100),
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search jingles...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHigh,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 8),
                // Tabs
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  tabs: _allCategories
                      .map(
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
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: _allCategories
              .map((category) => _buildCategoryTab(context, category))
              .toList(),
        ),
        bottomNavigationBar: _buildBottomBar(context),
      ),
    );
  }

  Widget _buildCategoryTab(
    BuildContext context,
    ExtendedAudioCategory category,
  ) {
    if (category is PredefinedAudioCategory) {
      return _buildPredefinedCategoryTab(context, category);
    } else if (category is CustomAudioCategory) {
      return _buildCustomCategoryTab(context, category);
    }

    return const Center(child: Text('Unknown category type'));
  }

  Widget _buildPredefinedCategoryTab(
    BuildContext context,
    PredefinedAudioCategory category,
  ) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        // Get all audio files for this category
        final categoryFiles = jingleManager.audioManager.audioInstances
            .where((audio) => audio.audioCategory == category.category)
            .toList();

        // Filter by search query
        final filteredFiles = categoryFiles.where((audio) {
          return _searchQuery.isEmpty ||
              audio.displayName.toLowerCase().contains(_searchQuery) ||
              audio.filePath.toLowerCase().contains(_searchQuery);
        }).toList();

        return _buildFilesList(context, filteredFiles, category);
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }

  Widget _buildCustomCategoryTab(
    BuildContext context,
    CustomAudioCategory category,
  ) {
    final soundGroupsAsync = ref.watch(soundGroupsProvider(category.customId));
    final customFilesAsync = ref.watch(
      customCategoryFilesProvider(category.customId),
    );

    // Combine sound groups and individual files in a consistent layout like predefined categories
    return customFilesAsync.when(
      data: (customFiles) {
        return soundGroupsAsync.when(
          data: (soundGroups) {
            // Filter by search query
            final filteredFiles = customFiles.where((file) {
              return _searchQuery.isEmpty ||
                  file.fileName.toLowerCase().contains(_searchQuery) ||
                  file.nameWithoutExtension.toLowerCase().contains(
                    _searchQuery,
                  );
            }).toList();

            final filteredGroups = soundGroups.where((group) {
              return _searchQuery.isEmpty ||
                  group.name.toLowerCase().contains(_searchQuery) ||
                  group.description.toLowerCase().contains(_searchQuery);
            }).toList();

            return _buildCustomFilesList(
              context,
              filteredFiles,
              filteredGroups,
              category,
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) =>
              Center(child: Text('Error loading sound groups: $error')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading files: $error')),
    );
  }

  Widget _buildFilesList(
    BuildContext context,
    List<AudioFile> files,
    ExtendedAudioCategory category,
  ) {
    if (files.isEmpty) {
      return _buildEmptyState(context, category);
    }

    return Column(
      children: [
        // Category-only option for predefined categories
        if (category is PredefinedAudioCategory)
          _buildCategoryOnlyOption(context, category),

        // Individual files
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: files.length,
            itemBuilder: (context, index) {
              final file = files[index];
              return _buildFileCard(context, file);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomFilesList(
    BuildContext context,
    List<CustomCategoryFile> files,
    List<SoundGroup> groups,
    CustomAudioCategory category,
  ) {
    // Handle empty state
    if (groups.isEmpty && files.isEmpty) {
      return _buildEmptyState(context, category);
    }

    // Build a layout similar to predefined categories: category-only option at top, then individual items
    return Column(
      children: [
        // Category-only option (Random from custom category)
        _buildCustomCategoryOnlyOption(context, category, groups, files),

        // Sound groups section (if any)
        if (groups.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Sound Groups',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],

        // Individual files and sound groups
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length + files.length,
            itemBuilder: (context, index) {
              if (index < groups.length) {
                // Show sound group
                final group = groups[index];
                return _buildSoundGroupCard(context, group, category);
              } else {
                // Show individual file
                final file = files[index - groups.length];
                return _buildCustomFileCard(context, file, category);
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomFileCard(
    BuildContext context,
    CustomCategoryFile file,
    CustomAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
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
        title: Text(
          file.nameWithoutExtension,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          '${file.fileName} • ${file.formattedSize}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectCustomFile(file, category),
      ),
    );
  }

  Widget _buildCategoryOnlyOption(
    BuildContext context,
    PredefinedAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(context, category),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shuffle,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(
            'Random from ${category.displayName}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: const Text('Play a random sound from this category'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectCategoryOnly(category),
        ),
      ),
    );
  }

  Widget _buildCustomCategoryOnlyOption(
    BuildContext context,
    CustomAudioCategory category,
    List<SoundGroup> groups,
    List<CustomCategoryFile> files,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Only show if there are files or groups to randomize from
    if (groups.isEmpty && files.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor(context, category),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.shuffle,
              color: colorScheme.onPrimaryContainer,
              size: 20,
            ),
          ),
          title: Text(
            'Random from ${category.displayName}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            groups.isNotEmpty && files.isNotEmpty
                ? 'Play random from ${groups.length} groups and ${files.length} files'
                : groups.isNotEmpty
                ? 'Play random from ${groups.length} sound groups'
                : 'Play random from ${files.length} files',
          ),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _selectCustomCategoryOnly(category, groups, files),
        ),
      ),
    );
  }

  Widget _buildFileCard(BuildContext context, AudioFile file) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
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
        title: Text(file.displayName, style: theme.textTheme.titleSmall),
        subtitle: Text(
          file.filePath.split('/').last.split('\\').last,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectFile(file),
      ),
    );
  }

  Widget _buildSoundGroupCard(
    BuildContext context,
    SoundGroup group,
    CustomAudioCategory category,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              const Color(0xFF9C27B0).withAlpha(128),
              colorScheme.primaryContainer,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            group.enableRandomization ? Icons.shuffle : Icons.queue_music,
            color: colorScheme.onPrimaryContainer,
            size: 20,
          ),
        ),
        title: Text(group.name, style: theme.textTheme.titleSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${group.soundFilePaths.length} sounds',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectSoundGroup(group, category),
      ),
    );
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
          Icon(
            _getCategoryIcon(category),
            size: 64,
            color: colorScheme.outline,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${category.displayName} found',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            category is CustomAudioCategory
                ? 'Create sound groups in this category'
                : 'Upload files to this category first',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(top: BorderSide(color: theme.colorScheme.outline)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preserve button name checkbox
          CheckboxListTile(
            title: const Text('Keep current button name'),
            subtitle: Text('Current: "${widget.currentButtonName}"'),
            value: _preserveButtonName,
            onChanged: (value) {
              setState(() {
                _preserveButtonName = value ?? false;
              });
            },
            contentPadding: EdgeInsets.zero,
          ),

          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Clear button
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pop('CLEAR'),
                icon: const Icon(Icons.clear),
                label: const Text('Clear'),
              ),

              const Spacer(),

              // Cancel button
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _selectFile(AudioFile file) {
    final finalDisplayName = _preserveButtonName
        ? widget.currentButtonName
        : file.displayName;

    final updatedAudioFile = AudioFile(
      displayName: finalDisplayName,
      filePath: file.filePath,
      audioCategory: file.audioCategory,
      isCategoryOnly: false,
    );

    Navigator.of(context).pop(updatedAudioFile);
  }

  void _selectCategoryOnly(PredefinedAudioCategory category) {
    final finalDisplayName = _preserveButtonName
        ? widget.currentButtonName
        : '${category.displayName}\n(Random)';

    final categoryOnlyAudioFile = AudioFile(
      displayName: finalDisplayName,
      filePath: '', // Empty for category-only
      audioCategory: category.category,
      isCategoryOnly: true,
    );

    Navigator.of(context).pop(categoryOnlyAudioFile);
  }

  void _selectCustomFile(
    CustomCategoryFile file,
    CustomAudioCategory category,
  ) {
    final finalDisplayName = _preserveButtonName
        ? widget.currentButtonName
        : file.nameWithoutExtension;

    final customFileAudioFile = AudioFile(
      displayName: finalDisplayName,
      filePath: file.filePath,
      audioCategory:
          AudioCategory.genericJingle, // Default category for compatibility
      isCategoryOnly: false,
    );

    Navigator.of(context).pop(customFileAudioFile);
  }

  void _selectCustomCategoryOnly(
    CustomAudioCategory category,
    List<SoundGroup> groups,
    List<CustomCategoryFile> files,
  ) {
    final finalDisplayName = _preserveButtonName
        ? widget.currentButtonName
        : '${category.displayName}\n(Random)';

    // Create a special AudioFile for custom category random selection
    // We'll use a special identifier that the AudioManager can recognize
    final customCategoryOnlyAudioFile = AudioFile(
      displayName: finalDisplayName,
      filePath:
          'custom_category:${category.customId}', // Special identifier for custom category random
      audioCategory:
          AudioCategory.genericJingle, // Default category for compatibility
      isCategoryOnly: true, // Treat as category-only for randomization
    );

    Navigator.of(context).pop(customCategoryOnlyAudioFile);
  }

  void _selectSoundGroup(SoundGroup group, CustomAudioCategory category) {
    final finalDisplayName = _preserveButtonName
        ? widget.currentButtonName
        : '${group.name}\n(Group)';

    // Create a special AudioFile for sound groups
    // We'll use a custom category identifier in the file path
    final soundGroupAudioFile = AudioFile(
      displayName: finalDisplayName,
      filePath:
          'custom_group:${group.id}', // Special identifier for sound groups
      audioCategory:
          AudioCategory.genericJingle, // Default category for compatibility
      isCategoryOnly: true, // Treat as category-only for randomization
    );

    Navigator.of(context).pop(soundGroupAudioFile);
  }
}
