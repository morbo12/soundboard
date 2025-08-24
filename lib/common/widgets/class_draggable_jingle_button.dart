import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_config_notifier.dart';
import 'package:soundboard/common/widgets/class_normal_button.dart';
import 'package:soundboard/common/widgets/button_with_progress.dart';

class DraggableJingleButton extends ConsumerWidget {
  final int index;
  final AudioFile? audioFile;
  final List<AudioFile> specialJingles;

  const DraggableJingleButton({
    super.key,
    required this.index,
    this.audioFile,
    required this.specialJingles,
  });

  ButtonStyle _getButtonStyle(
    BuildContext context,
    AudioCategory? category, {
    bool isCategoryOnly = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Base style using Material 3 tokens
    ButtonStyle baseStyle =
        TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surfaceContainerLow,
          minimumSize: const Size(0, 100),
          textStyle: theme.textTheme.titleLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ).copyWith(
          // Add state layer colors
          overlayColor: WidgetStatePropertyAll(
            colorScheme.onSurface.withAlpha(20),
          ),
        );

    // Empty state style
    if (category == null) {
      return baseStyle;
    }

    // Category-only style
    if (isCategoryOnly) {
      return baseStyle.copyWith(
        backgroundColor: WidgetStatePropertyAll(
          colorScheme.primaryContainer.withAlpha(179),
        ),
        foregroundColor: WidgetStatePropertyAll(colorScheme.onPrimaryContainer),
        side: WidgetStatePropertyAll(
          BorderSide(color: colorScheme.primary, width: 2),
        ),
      );
    }

    // Category-specific styles
    switch (category) {
      case AudioCategory.specialJingle:
      case AudioCategory.goalHorn:
      case AudioCategory.penaltyJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            Color.alphaBlend(
              const Color(
                0xFFE6B422,
              ).withAlpha(128), // Yellow tint with 50% opacity
              colorScheme.primaryContainer,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onPrimaryContainer,
          ),
        );
      case AudioCategory.goalJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            Color.alphaBlend(
              const Color(
                0xFF4CAF50,
              ).withAlpha(128), // Green tint with 50% opacity
              colorScheme.primaryContainer,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onPrimaryContainer,
          ),
        );
      case AudioCategory.genericJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(colorScheme.primaryContainer),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onPrimaryContainer,
          ),
        );
      case AudioCategory.clapJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.tertiaryContainer,
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onTertiaryContainer,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buttonStyle = _getButtonStyle(
      context,
      audioFile?.audioCategory,
      isCategoryOnly: audioFile?.isCategoryOnly ?? false,
    );
    final displayText = audioFile?.displayName ?? 'Empty';

    // Add a suffix to indicate category-only mode
    // Handle multi-line display names properly
    final buttonText = audioFile?.isCategoryOnly ?? false
        ? '${displayText}\n(Random)'
        : displayText;

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        ref
            .read(jingleGridConfigProvider.notifier)
            .swapPositions(details.data, index);
      },
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: index,
          feedback: NormalButton(
            primaryText: buttonText,
            onTap: () {}, // Feedback doesn't need tap functionality
            style: buttonStyle,
            // If NormalButton relies on Material (e.g., for InkWell),
            // this might affect its appearance, but should fix the error.
            // We might need to wrap it in a specific Material type later if needed.
          ),
          childWhenDragging: NormalButton(
            primaryText: '',
            onTap: () {},
            isDisabled: false,
          ),
          child: GestureDetector(
            onLongPress: () => _handleLongPress(context, ref),
            child: ButtonWithProgress(
              audioFile: audioFile,
              child: NormalButton(
                primaryText: buttonText,
                onTap: () => _handleTap(context, ref),
                style: buttonStyle,
                isDisabled: false,
                isSelected: candidateData.isNotEmpty,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleTap(BuildContext context, WidgetRef ref) async {
    // Check if this is an empty button (has display name but no real audio file)
    final isEmptyButton =
        audioFile != null &&
        audioFile!.filePath.isEmpty &&
        !audioFile!.isCategoryOnly;

    if (audioFile != null && !isEmptyButton) {
      // Use the provider to get jingleManager
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      await jingleManagerAsync.when(
        data: (jingleManager) async {
          await jingleManager.audioManager.playAudioFile(audioFile!, ref);
        },
        loading: () async {
          // Handle loading state - maybe show a loading indicator
        },
        error: (error, stack) async {
          // Handle error state
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $error')));
        },
      );
    } else {
      // Show jingle selection for null audioFile OR empty buttons
      _showJingleSelectionDialog(context, ref);
    }
  }

  Future<void> _handleLongPress(BuildContext context, WidgetRef ref) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jingle Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: const Text('Change Jingle'),
              onTap: () => Navigator.of(context).pop('change_jingle'),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Change Display Name'),
              onTap: () => Navigator.of(context).pop('change_name'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Jingle Info'),
              onTap: () => Navigator.of(context).pop('show_info'),
            ),
            if (audioFile != null &&
                !(audioFile!.filePath.isEmpty &&
                    !audioFile!
                        .isCategoryOnly)) // Only show delete option if a real jingle is assigned (not empty buttons)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Assignment'),
                onTap: () => Navigator.of(context).pop('delete_assignment'),
              ),
          ],
        ),
      ),
    );

    if (!context.mounted) return;

    switch (choice) {
      case 'change_jingle':
        await _showJingleSelectionDialog(context, ref);
        break;
      case 'change_name':
        await _showChangeDisplayNameDialog(context, ref);
        break;
      case 'show_info':
        await _showJingleInfo(context);
        break;
      case 'delete_assignment':
        await _deleteJingleAssignment(context, ref);
        break;
    }
  }

  Future<void> _showChangeDisplayNameDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No jingle assigned to this button')),
      );
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: audioFile!.displayName,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Display Name'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Display Name',
                hintText: 'Enter new display name',
                helperText:
                    'Type \\n for line breaks\nExample: TIMEOUT\\nHemmalag → TIMEOUT\nHemmalag',
                helperMaxLines: 3,
              ),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              minLines: 1,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Convert literal \n to actual newlines
              final processedText = controller.text.replaceAll('\\n', '\n');
              Navigator.of(context).pop(processedText);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      final updatedAudioFile = AudioFile(
        displayName: newName,
        filePath: audioFile!.filePath,
        audioCategory: audioFile!.audioCategory,
        isCategoryOnly: audioFile!.isCategoryOnly,
      );
      ref
          .read(jingleGridConfigProvider.notifier)
          .assignJingle(index, updatedAudioFile);
    }
  }

  Future<void> _showJingleInfo(BuildContext context) async {
    if (audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No jingle assigned to this button')),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jingle Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Display Name: ${audioFile!.displayName}'),
            const SizedBox(height: 8),
            if (!audioFile!.isCategoryOnly)
              Text('File Path: ${audioFile!.filePath}')
            else
              const Text('File Path: [Random from category]'),
            const SizedBox(height: 8),
            Text(
              'Category: ${audioFile!.audioCategory.toString().split('.').last}',
            ),
            const SizedBox(height: 8),
            Text(
              'Mode: ${audioFile!.isCategoryOnly ? "Random from category" : "Specific jingle"}',
            ),
          ],
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

  Future<void> _showJingleSelectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final categories = AudioCategory.values;

    final selectedCategory = await showDialog<AudioCategory>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Select Jingle Category'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: categories.length,
            itemBuilder: (dialogContext, index) {
              final category = categories[index];
              return NormalButton(
                primaryText: category.toString().split('.').last,
                onTap: () => Navigator.of(dialogContext).pop(category),
                style: _getButtonStyle(dialogContext, category),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selectedCategory != null) {
      // Ask if the user wants to assign a specific jingle or the entire category
      final selectionMode = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) => AlertDialog(
          title: Text(
            'Select Mode for ${selectedCategory.toString().split('.').last}',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.music_note),
                title: const Text('Specific Jingle'),
                subtitle: const Text('Assign a specific jingle to this button'),
                onTap: () => Navigator.of(dialogContext).pop('specific'),
              ),
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Random from Category'),
                subtitle: const Text('Play a random jingle from this category'),
                onTap: () => Navigator.of(dialogContext).pop('category'),
              ),
            ],
          ),
        ),
      );

      if (selectionMode == 'category') {
        // Automatically preserve name if button has a custom name
        final currentName = audioFile?.displayName ?? 'Empty';
        final isEmptyButton = currentName == 'Empty';
        final isDefaultCategoryName = AudioCategory.values
            .map((cat) => cat.toString().split('.').last)
            .contains(currentName.replaceAll('\n', '').replaceAll(' ', ''));

        final shouldPreserveName = !isEmptyButton && !isDefaultCategoryName;

        bool preserveName = shouldPreserveName;

        // Only ask user if it's ambiguous (custom name exists)
        if (shouldPreserveName) {
          preserveName =
              await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Random from Category'),
                  content: Text(
                    'Keep current button name "$currentName" or use category name "${selectedCategory.toString().split('.').last}"?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Use Category Name'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Keep Button Name'),
                    ),
                  ],
                ),
              ) ??
              true; // Default to preserve if dialog is dismissed
        }

        // Assign the entire category
        final categoryName = selectedCategory.toString().split('.').last;
        final assignedAudioFile = AudioFile(
          filePath: '', // Empty as we'll use the category for playback
          displayName: preserveName ? currentName : categoryName,
          audioCategory: selectedCategory,
          isCategoryOnly: true,
        );

        ref
            .read(jingleGridConfigProvider.notifier)
            .assignJingle(index, assignedAudioFile);
        return;
      }
      List<AudioFile> jingles = [];

      // Use the provider to get jingleManager for all categories including special jingles
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      await jingleManagerAsync.when(
        data: (jingleManager) async {
          jingles = jingleManager.audioManager.audioInstances
              .where((j) => j.audioCategory == selectedCategory)
              .toList();
        },
        loading: () async {
          // Handle loading state
          jingles = [];
        },
        error: (error, stack) async {
          // Handle error state
          jingles = [];
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error loading jingles: $error')),
            );
          }
        },
      );

      if (jingles.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No jingles found for ${selectedCategory.toString().split('.').last}',
              ),
            ),
          );
        }
        return;
      }

      if (!context.mounted) return;

      final selectedJingle = await showDialog<AudioFile>(
        context: context,
        builder: (BuildContext dialogContext) => _JingleSelectionDialog(
          jingles: jingles,
          category: selectedCategory,
          currentButtonName: audioFile?.displayName ?? 'Empty',
        ),
      );

      if (selectedJingle != null) {
        ref
            .read(jingleGridConfigProvider.notifier)
            .assignJingle(index, selectedJingle);
      }
    }
  }

  Future<void> _deleteJingleAssignment(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to remove this jingle assignment?',
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

    if (confirmed == true) {
      // Remove the jingle assignment by setting it to null
      ref.read(jingleGridConfigProvider.notifier).removeJingle(index);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jingle assignment removed')),
        );
      }
    }
  }
}

/// Custom dialog for selecting jingles with option to preserve button name
class _JingleSelectionDialog extends StatefulWidget {
  final List<AudioFile> jingles;
  final AudioCategory category;
  final String currentButtonName;

  const _JingleSelectionDialog({
    required this.jingles,
    required this.category,
    required this.currentButtonName,
  });

  @override
  State<_JingleSelectionDialog> createState() => _JingleSelectionDialogState();
}

class _JingleSelectionDialogState extends State<_JingleSelectionDialog> {
  bool _preserveButtonName = false;

  @override
  void initState() {
    super.initState();
    // Auto-check preserve name if button has a custom name (not "Empty" or category name)
    final currentName = widget.currentButtonName;
    final isEmptyButton = currentName == 'Empty';
    final isDefaultCategoryName = AudioCategory.values
        .map((cat) => cat.toString().split('.').last)
        .contains(currentName.replaceAll('\n', '').replaceAll(' ', ''));

    // Preserve name by default if it's a custom name
    _preserveButtonName = !isEmptyButton && !isDefaultCategoryName;
  }

  ButtonStyle _getButtonStyle(BuildContext context, AudioCategory? category) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Base style using Material 3 tokens
    ButtonStyle baseStyle =
        TextButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          backgroundColor: colorScheme.surfaceContainerLow,
          minimumSize: const Size(0, 100),
          textStyle: theme.textTheme.titleLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ).copyWith(
          // Add state layer colors
          overlayColor: WidgetStatePropertyAll(
            colorScheme.onSurface.withAlpha(20),
          ),
        );

    // Empty state style
    if (category == null) {
      return baseStyle;
    }

    // Category-specific styles
    switch (category) {
      case AudioCategory.specialJingle:
      case AudioCategory.goalHorn:
      case AudioCategory.penaltyJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            Color.alphaBlend(
              const Color(0xFFE6B422).withAlpha(128), // Yellow tint
              colorScheme.primaryContainer,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onPrimaryContainer,
          ),
        );
      case AudioCategory.goalJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            Color.alphaBlend(
              const Color(0xFF4CAF50).withAlpha(128), // Green tint
              colorScheme.primaryContainer,
            ),
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onPrimaryContainer,
          ),
        );
      case AudioCategory.genericJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(colorScheme.primaryContainer),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onPrimaryContainer,
          ),
        );
      case AudioCategory.clapJingle:
        return baseStyle.copyWith(
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.tertiaryContainer,
          ),
          foregroundColor: WidgetStatePropertyAll(
            colorScheme.onTertiaryContainer,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Select ${widget.category.toString().split('.').last}'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Checkbox for preserving button name
            CheckboxListTile(
              title: const Text('Keep current button name'),
              subtitle: Text(
                'Button name: "${widget.currentButtonName}"'
                '${_preserveButtonName && !widget.currentButtonName.contains('Empty') ? ' (auto-selected for custom names)' : ''}',
              ),
              value: _preserveButtonName,
              onChanged: (value) {
                setState(() {
                  _preserveButtonName = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),
            // Jingle list
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.jingles.length,
                itemBuilder: (context, index) {
                  final jingle = widget.jingles[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: NormalButton(
                      primaryText: jingle.displayName,
                      onTap: () {
                        // Create AudioFile with potentially modified display name
                        final resultJingle = AudioFile(
                          displayName: _preserveButtonName
                              ? widget.currentButtonName
                              : jingle.displayName,
                          filePath: jingle.filePath,
                          audioCategory: jingle.audioCategory,
                          isCategoryOnly: jingle.isCategoryOnly,
                        );
                        Navigator.of(context).pop(resultJingle);
                      },
                      style: _getButtonStyle(context, jingle.audioCategory),
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
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
