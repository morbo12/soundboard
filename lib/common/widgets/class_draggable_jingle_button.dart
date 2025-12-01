import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:soundboard/common/widgets/dialogs/hotkey_assignment_dialog.dart';
import 'package:soundboard/core/services/hotkey_service.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_config_notifier.dart';
import 'package:soundboard/common/widgets/class_normal_button.dart';
import 'package:soundboard/common/widgets/button_with_progress.dart';
import 'package:soundboard/common/widgets/dialogs/extended_jingle_selection_dialog.dart';

class DraggableJingleButton extends ConsumerStatefulWidget {
  final int index;
  final AudioFile? audioFile;
  final List<AudioFile> specialJingles;

  const DraggableJingleButton({
    super.key,
    required this.index,
    this.audioFile,
    required this.specialJingles,
  });

  @override
  ConsumerState<DraggableJingleButton> createState() =>
      _DraggableJingleButtonState();
}

class _DraggableJingleButtonState extends ConsumerState<DraggableJingleButton> {
  String get _buttonId => 'jingle_button_${widget.index}';

  @override
  void initState() {
    super.initState();

    // Register hotkey callback after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final hotkeyService = ref.read(hotkeyServiceProvider);
      hotkeyService.registerCallback(_buttonId, _triggerButton);
    });
  }

  void _triggerButton() {
    if (widget.audioFile != null) {
      _handleTap(context, ref);
    }
  }

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
  Widget build(BuildContext context) {
    final hotkeyService = ref.watch(hotkeyServiceProvider);
    final assignedHotkey = hotkeyService.getHotkey(_buttonId);

    final buttonStyle = _getButtonStyle(
      context,
      widget.audioFile?.audioCategory,
      isCategoryOnly: widget.audioFile?.isCategoryOnly ?? false,
    );
    final displayText = widget.audioFile?.displayName ?? 'Empty';

    // Add a suffix to indicate category-only mode
    // Handle multi-line display names properly
    final buttonText = widget.audioFile?.isCategoryOnly ?? false
        ? '${displayText}\n(Random)'
        : displayText;

    return DragTarget<int>(
      onAcceptWithDetails: (details) {
        ref
            .read(jingleGridConfigProvider.notifier)
            .swapPositions(details.data, widget.index);
      },
      builder: (context, candidateData, rejectedData) {
        return LongPressDraggable<int>(
          data: widget.index,
          delay: const Duration(milliseconds: 300),
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
              audioFile: widget.audioFile,
              child: NormalButton(
                primaryText: assignedHotkey != null
                    ? '$buttonText\n[${HotkeyUtils.formatForDisplay(assignedHotkey)}]'
                    : buttonText,
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
        widget.audioFile != null &&
        widget.audioFile!.filePath.isEmpty &&
        !widget.audioFile!.isCategoryOnly;

    if (widget.audioFile != null && !isEmptyButton) {
      // Use the provider to get jingleManager
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      await jingleManagerAsync.when(
        data: (jingleManager) async {
          await jingleManager.audioManager.playAudioFile(
            widget.audioFile!,
            ref,
          );
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
            ListTile(
              leading: const Icon(Icons.keyboard),
              title: const Text('Assign Hotkey'),
              onTap: () => Navigator.of(context).pop('assign_hotkey'),
            ),
            if (widget.audioFile != null &&
                !(widget.audioFile!.filePath.isEmpty &&
                    !widget
                        .audioFile!
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
      case 'assign_hotkey':
        await _showHotkeyAssignmentDialog(context, ref);
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
    if (widget.audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No jingle assigned to this button')),
      );
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: widget.audioFile!.displayName,
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
        filePath: widget.audioFile!.filePath,
        audioCategory: widget.audioFile!.audioCategory,
        isCategoryOnly: widget.audioFile!.isCategoryOnly,
      );
      ref
          .read(jingleGridConfigProvider.notifier)
          .assignJingle(widget.index, updatedAudioFile);
    }
  }

  Future<void> _showJingleInfo(BuildContext context) async {
    if (widget.audioFile == null) {
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
            Text('Display Name: ${widget.audioFile!.displayName}'),
            const SizedBox(height: 8),
            if (!widget.audioFile!.isCategoryOnly)
              Text('File Path: ${widget.audioFile!.filePath}')
            else
              const Text('File Path: [Random from category]'),
            const SizedBox(height: 8),
            Text(
              'Category: ${widget.audioFile!.audioCategory.toString().split('.').last}',
            ),
            const SizedBox(height: 8),
            Text(
              'Mode: ${widget.audioFile!.isCategoryOnly ? "Random from category" : "Specific jingle"}',
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
    final result = await showDialog<dynamic>(
      context: context,
      builder: (context) => ExtendedJingleSelectionDialog(
        currentButtonName: widget.audioFile?.displayName ?? 'Empty',
        currentAudioFile: widget.audioFile,
      ),
    );

    if (result != null) {
      if (result == 'CLEAR') {
        // Clear the jingle assignment
        ref.read(jingleGridConfigProvider.notifier).removeJingle(widget.index);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Jingle assignment removed')),
          );
        }
      } else if (result is AudioFile) {
        // Assign the selected jingle
        ref
            .read(jingleGridConfigProvider.notifier)
            .assignJingle(widget.index, result);
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
      ref.read(jingleGridConfigProvider.notifier).removeJingle(widget.index);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Jingle assignment removed')),
        );
      }
    }
  }

  Future<void> _showHotkeyAssignmentDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final displayName =
        widget.audioFile?.displayName ?? 'Button ${widget.index + 1}';

    final result = await showHotkeyAssignmentDialog(
      context: context,
      buttonId: _buttonId,
      buttonName: displayName,
    );

    if (result != null && mounted) {
      // Assign the hotkey with our callback
      final hotkeyService = ref.read(hotkeyServiceProvider);
      await hotkeyService.assignHotkey(_buttonId, result, _triggerButton);
      setState(() {}); // Trigger rebuild to show hotkey in UI
    }
  }
}
