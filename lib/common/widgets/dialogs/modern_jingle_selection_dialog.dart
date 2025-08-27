import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

/// Modern unified jingle selection dialog with tabbed interface
class ModernJingleSelectionDialog extends ConsumerStatefulWidget {
  final String currentButtonName;
  final AudioFile? currentAudioFile;

  const ModernJingleSelectionDialog({
    super.key,
    required this.currentButtonName,
    this.currentAudioFile,
  });

  @override
  ConsumerState<ModernJingleSelectionDialog> createState() =>
      _ModernJingleSelectionDialogState();
}

class _ModernJingleSelectionDialogState
    extends ConsumerState<ModernJingleSelectionDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _preserveButtonName = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: AudioCategory.values.length,
      vsync: this,
    );
    _initializeNamePreservation();
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
    // Convert camelCase to Title Case with spaces
    return name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(1)}')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and close button
            Row(
              children: [
                Icon(Icons.music_note, color: colorScheme.primary, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Select Jingle',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jingles...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest,
              ),
              onChanged: (value) {
                setState(() => _searchQuery = value.toLowerCase());
              },
            ),
            const SizedBox(height: 16),

            // Name preservation option
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _preserveButtonName,
                      onChanged: (value) {
                        setState(() => _preserveButtonName = value ?? false);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Keep current button name',
                            style: theme.textTheme.titleSmall,
                          ),
                          Text(
                            'Button: "${widget.currentButtonName}"',
                            style: theme.textTheme.bodySmall?.copyWith(
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
            const SizedBox(height: 16),

            // Tab bar for categories
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: AudioCategory.values
                  .map(
                    (category) => Tab(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_getCategoryIcon(category), size: 18),
                          const SizedBox(width: 8),
                          Text(_formatCategoryName(category)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            // Tab content - jingle grid
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: AudioCategory.values
                    .map((category) => _buildCategoryContent(context, category))
                    .toList(),
              ),
            ),

            // Quick actions
            const SizedBox(height: 16),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryContent(BuildContext context, AudioCategory category) {
    final jingleManagerAsync = ref.watch(jingleManagerProvider);

    return jingleManagerAsync.when(
      data: (jingleManager) {
        final jingles = jingleManager.audioManager.audioInstances
            .where(
              (j) =>
                  j.audioCategory == category &&
                  (_searchQuery.isEmpty ||
                      j.displayName.toLowerCase().contains(_searchQuery)),
            )
            .toList();

        if (jingles.isEmpty) {
          return _buildEmptyState(context, category);
        }

        return Column(
          children: [
            // Category random option
            Card(
              color: _getCategoryColor(context, category).withAlpha(100),
              child: ListTile(
                leading: Icon(_getCategoryIcon(category)),
                title: Text('Random ${_formatCategoryName(category)}'),
                subtitle: Text(
                  'Play any ${category.toString().split('.').last} randomly',
                ),
                trailing: const Icon(Icons.shuffle),
                onTap: () => _selectCategoryRandom(context, category),
              ),
            ),
            const SizedBox(height: 12),

            // Jingles grid
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                  childAspectRatio: 4.0,
                ),
                itemCount: jingles.length,
                itemBuilder: (context, index) {
                  final jingle = jingles[index];
                  return _buildJingleCard(context, jingle);
                },
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading jingles: $error'),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AudioCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(category),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No ${_formatCategoryName(category)} Found',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isNotEmpty
                ? 'Try a different search term'
                : 'This category has no jingles available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJingleCard(BuildContext context, AudioFile jingle) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _selectSpecificJingle(context, jingle),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _getCategoryColor(context, jingle.audioCategory),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getCategoryIcon(jingle.audioCategory),
                  color: colorScheme.onPrimaryContainer,
                  size: 12,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  jingle.displayName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
          label: const Text('Cancel'),
        ),
        const Spacer(),
        if (widget.currentAudioFile != null) ...[
          OutlinedButton.icon(
            onPressed: () => _clearAssignment(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Clear'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ],
    );
  }

  void _selectCategoryRandom(BuildContext context, AudioCategory category) {
    final categoryName = _formatCategoryName(category);
    final assignedAudioFile = AudioFile(
      filePath: '', // Empty as we'll use the category for playback
      displayName: _preserveButtonName
          ? widget.currentButtonName
          : categoryName,
      audioCategory: category,
      isCategoryOnly: true,
    );

    Navigator.of(context).pop(assignedAudioFile);
  }

  void _selectSpecificJingle(BuildContext context, AudioFile jingle) {
    final resultJingle = AudioFile(
      displayName: _preserveButtonName
          ? widget.currentButtonName
          : jingle.displayName,
      filePath: jingle.filePath,
      audioCategory: jingle.audioCategory,
      isCategoryOnly: jingle.isCategoryOnly,
    );

    Navigator.of(context).pop(resultJingle);
  }

  void _clearAssignment(BuildContext context) {
    Navigator.of(context).pop('CLEAR');
  }
}
