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
import 'package:soundboard/core/utils/app_localizations.dart';

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
  final GlobalKey _buttonKey = GlobalKey();
  Size? _buttonSize;
  // Scale factor for drag preview; slightly larger than the original
  static const double _dragScale = 1.08;

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
        // Measure the button size once it is laid out so we can keep
        // the drag feedback and placeholder consistent with the button
        // size and avoid visual shrinking when dragging.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final contextForSize = _buttonKey.currentContext;
          if (contextForSize != null) {
            final renderBox = contextForSize.findRenderObject() as RenderBox?;
            if (renderBox != null) {
              final newSize = renderBox.size;
              if (_buttonSize == null || _buttonSize != newSize) {
                setState(() {
                  _buttonSize = newSize;
                });
              }
            }
          }
        });
        return LongPressDraggable<int>(
          data: widget.index,
          delay: const Duration(milliseconds: 500),
          feedback: SizedBox(
            width: (_buttonSize?.width ?? 100) * _dragScale,
            height: (_buttonSize?.height ?? 100) * _dragScale,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.45),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: NormalButton(
                  primaryText: buttonText,
                  onTap: () {}, // Feedback doesn't need tap functionality
                  style: buttonStyle,
                ),
              ),
            ),
          ),
          childWhenDragging: SizedBox(
            width: _buttonSize?.width,
            height: _buttonSize?.height ?? 100,
            child: Opacity(
              opacity: 0.0,
              child: NormalButton(
                primaryText: assignedHotkey != null
                    ? '$buttonText\n[${HotkeyUtils.formatForDisplay(assignedHotkey)}]'
                    : buttonText,
                onTap: () {},
                style: buttonStyle,
                isDisabled: true,
              ),
            ),
          ),
          child: GestureDetector(
            onSecondaryTap: () => _handleLongPress(context, ref),
            child: ButtonWithProgress(
              audioFile: widget.audioFile,
              child: Container(
                key: _buttonKey,
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
          final l10n = context.l10n;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.translate('common.error')}: $error'),
            ),
          );
        },
      );
    } else {
      // Show jingle selection for null audioFile OR empty buttons
      _showJingleSelectionDialog(context, ref);
    }
  }

  Future<void> _handleLongPress(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('jingle_options.title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.music_note),
              title: Text(l10n.translate('jingle_options.change_jingle')),
              onTap: () => Navigator.of(context).pop('change_jingle'),
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(l10n.translate('jingle_options.change_display_name')),
              onTap: () => Navigator.of(context).pop('change_name'),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: Text(l10n.translate('jingle_options.jingle_info')),
              onTap: () => Navigator.of(context).pop('show_info'),
            ),
            ListTile(
              leading: const Icon(Icons.keyboard),
              title: Text(l10n.translate('jingle_options.assign_hotkey')),
              onTap: () => Navigator.of(context).pop('assign_hotkey'),
            ),
            if (widget.audioFile != null &&
                !(widget.audioFile!.filePath.isEmpty &&
                    !widget
                        .audioFile!
                        .isCategoryOnly)) // Only show delete option if a real jingle is assigned (not empty buttons)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text(l10n.translate('jingle_options.delete_assignment')),
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
    final l10n = context.l10n;

    if (widget.audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('dialogs.no_jingle_assigned'))),
      );
      return;
    }

    final TextEditingController controller = TextEditingController(
      text: widget.audioFile!.displayName,
    );
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('jingle_options.change_display_name')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: l10n.translate('dialogs.display_name_label'),
                hintText: l10n.translate('dialogs.display_name_hint'),
                helperText: l10n.translate('dialogs.display_name_helper'),
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
            child: Text(l10n.translate('common.cancel')),
          ),
          TextButton(
            onPressed: () {
              // Convert literal \n to actual newlines
              final processedText = controller.text.replaceAll('\\n', '\n');
              Navigator.of(context).pop(processedText);
            },
            child: Text(l10n.translate('common.save')),
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
    final l10n = context.l10n;

    if (widget.audioFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('dialogs.no_jingle_assigned'))),
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('dialogs.jingle_information_title')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.translate('dialogs.display_name_label')}: ${widget.audioFile!.displayName}',
            ),
            const SizedBox(height: 8),
            if (!widget.audioFile!.isCategoryOnly)
              Text(
                '${l10n.translate('dialogs.file_path_label')}: ${widget.audioFile!.filePath}',
              )
            else
              Text(
                '${l10n.translate('dialogs.file_path_label')}: ${l10n.translate('dialogs.file_path_random')}',
              ),
            const SizedBox(height: 8),
            Text(
              '${l10n.translate('dialogs.category_label')}: ${widget.audioFile!.audioCategory.toString().split('.').last}',
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.translate('dialogs.mode_label')}: ${widget.audioFile!.isCategoryOnly ? l10n.translate('dialogs.mode_random') : l10n.translate('dialogs.mode_specific')}',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.translate('common.close')),
          ),
        ],
      ),
    );
  }

  Future<void> _showJingleSelectionDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;

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
            SnackBar(
              content: Text(
                l10n.translate('snackbar_messages.jingle_assignment_removed'),
              ),
            ),
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
    final l10n = context.l10n;

    // Confirm deletion
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('dialogs.confirm_deletion_title')),
        content: Text(l10n.translate('dialogs.confirm_deletion_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.translate('common.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.translate('common.delete')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Remove the jingle assignment by setting it to null
      ref.read(jingleGridConfigProvider.notifier).removeJingle(widget.index);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.translate('snackbar_messages.jingle_assignment_removed'),
            ),
          ),
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
