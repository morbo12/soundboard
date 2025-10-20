import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/hotkey_service.dart';

/// Dialog for assigning hotkeys to buttons
class HotkeyAssignmentDialog extends ConsumerStatefulWidget {
  final String buttonId;
  final String buttonName;

  const HotkeyAssignmentDialog({
    super.key,
    required this.buttonId,
    required this.buttonName,
  });

  @override
  ConsumerState<HotkeyAssignmentDialog> createState() =>
      _HotkeyAssignmentDialogState();
}

class _HotkeyAssignmentDialogState
    extends ConsumerState<HotkeyAssignmentDialog> {
  String _currentHotkey = '';
  String _inputHotkey = '';
  bool _isCapturing = false;
  String? _errorMessage;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentHotkey =
        ref.read(hotkeyServiceProvider).getHotkey(widget.buttonId) ?? '';
    _inputHotkey = _currentHotkey;
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hotkeyService = ref.watch(hotkeyServiceProvider);

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Assign Hotkey', style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Button: ${widget.buttonName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),

              // Current hotkey display
              if (_currentHotkey.isNotEmpty) ...[
                Text('Current Hotkey:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    HotkeyUtils.formatForDisplay(_currentHotkey),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Hotkey input section
              Text('New Hotkey:', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              // Key capture area
              Focus(
                focusNode: _focusNode,
                onKeyEvent: _handleKeyEvent,
                child: GestureDetector(
                  onTap: _startCapturing,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 80),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _isCapturing
                          ? theme.colorScheme.secondaryContainer
                          : theme.colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isCapturing
                            ? theme.colorScheme.secondary
                            : theme.colorScheme.outline,
                        width: _isCapturing ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        if (_isCapturing) ...[
                          Icon(
                            Icons.keyboard,
                            size: 32,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Press key combination...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ] else if (_inputHotkey.isNotEmpty) ...[
                          Icon(
                            Icons.keyboard_alt,
                            size: 24,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            HotkeyUtils.formatForDisplay(_inputHotkey),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontFamily: 'monospace',
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.touch_app,
                            size: 24,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap here to capture hotkey',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning,
                        size: 16,
                        color: theme.colorScheme.onErrorContainer,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Quick suggestions
              Text('Suggestions:', style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),

              // Single keys section
              Text(
                'Single Keys:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    [
                          '1',
                          '2',
                          '3',
                          '4',
                          '5',
                          '6',
                          '7',
                          '8',
                          '9',
                          '0',
                          'Q',
                          'W',
                          'E',
                          'R',
                          'T',
                          'Y',
                          'A',
                          'S',
                          'D',
                          'F',
                          'G',
                          'H',
                          'SPACE',
                        ]
                        .where(
                          (hotkey) =>
                              !hotkeyService.isHotkeyAssigned(hotkey) ||
                              hotkey == _currentHotkey,
                        )
                        .map(
                          (hotkey) => ActionChip(
                            label: Text(
                              HotkeyUtils.formatForDisplay(hotkey),
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              setState(() {
                                _inputHotkey = hotkey;
                                _errorMessage = null;
                                _isCapturing = false;
                              });
                            },
                            backgroundColor: hotkey == _inputHotkey
                                ? theme.colorScheme.primaryContainer
                                : null,
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 12),

              // Function keys and combinations section
              Text(
                'Function Keys & Combinations:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children:
                    [
                          'F1',
                          'F2',
                          'F3',
                          'F4',
                          'F5',
                          'F6',
                          'Ctrl+1',
                          'Ctrl+2',
                          'Ctrl+3',
                          'Alt+1',
                          'Alt+2',
                          'Alt+3',
                        ]
                        .where(
                          (hotkey) =>
                              !hotkeyService.isHotkeyAssigned(hotkey) ||
                              hotkey == _currentHotkey,
                        )
                        .map(
                          (hotkey) => ActionChip(
                            label: Text(
                              HotkeyUtils.formatForDisplay(hotkey),
                              style: const TextStyle(fontSize: 11),
                            ),
                            onPressed: () {
                              setState(() {
                                _inputHotkey = hotkey;
                                _errorMessage = null;
                                _isCapturing = false;
                              });
                            },
                            backgroundColor: hotkey == _inputHotkey
                                ? theme.colorScheme.primaryContainer
                                : null,
                          ),
                        )
                        .toList(),
              ),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  if (_currentHotkey.isNotEmpty) ...[
                    OutlinedButton(
                      onPressed: _removeHotkey,
                      child: const Text('Remove'),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilledButton(
                    onPressed: _inputHotkey.isNotEmpty && _errorMessage == null
                        ? _saveHotkey
                        : null,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startCapturing() {
    setState(() {
      _isCapturing = true;
      _errorMessage = null;
    });
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!_isCapturing || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    // Skip standalone modifier keys
    const modifierKeys = [
      LogicalKeyboardKey.control,
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.controlRight,
      LogicalKeyboardKey.shift,
      LogicalKeyboardKey.shiftLeft,
      LogicalKeyboardKey.shiftRight,
      LogicalKeyboardKey.alt,
      LogicalKeyboardKey.altLeft,
      LogicalKeyboardKey.altRight,
      LogicalKeyboardKey.meta,
      LogicalKeyboardKey.metaLeft,
      LogicalKeyboardKey.metaRight,
    ];

    if (modifierKeys.contains(event.logicalKey)) {
      return KeyEventResult.handled;
    }

    // Handle Escape to cancel
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      setState(() {
        _isCapturing = false;
        _inputHotkey = _currentHotkey;
      });
      return KeyEventResult.handled;
    }

    // Build hotkey string
    final parts = <String>[];
    if (HardwareKeyboard.instance.isControlPressed) parts.add('Ctrl');
    if (HardwareKeyboard.instance.isShiftPressed) parts.add('Shift');
    if (HardwareKeyboard.instance.isAltPressed) parts.add('Alt');
    if (HardwareKeyboard.instance.isMetaPressed) parts.add('Meta');

    // Handle special keys
    String keyPart = '';
    switch (event.logicalKey) {
      case LogicalKeyboardKey.space:
        keyPart = 'SPACE';
        break;
      case LogicalKeyboardKey.enter:
        keyPart = 'ENTER';
        break;
      case LogicalKeyboardKey.tab:
        keyPart = 'TAB';
        break;
      case LogicalKeyboardKey.backspace:
        keyPart = 'BACKSPACE';
        break;
      case LogicalKeyboardKey.delete:
        keyPart = 'DELETE';
        break;
      case LogicalKeyboardKey.insert:
        keyPart = 'INSERT';
        break;
      case LogicalKeyboardKey.home:
        keyPart = 'HOME';
        break;
      case LogicalKeyboardKey.end:
        keyPart = 'END';
        break;
      case LogicalKeyboardKey.pageUp:
        keyPart = 'PAGE_UP';
        break;
      case LogicalKeyboardKey.pageDown:
        keyPart = 'PAGE_DOWN';
        break;
      case LogicalKeyboardKey.arrowUp:
        keyPart = 'ARROW_UP';
        break;
      case LogicalKeyboardKey.arrowDown:
        keyPart = 'ARROW_DOWN';
        break;
      case LogicalKeyboardKey.arrowLeft:
        keyPart = 'ARROW_LEFT';
        break;
      case LogicalKeyboardKey.arrowRight:
        keyPart = 'ARROW_RIGHT';
        break;
      default:
        // Use the key label for regular keys
        final keyLabel = event.logicalKey.keyLabel;
        if (keyLabel.isNotEmpty) {
          keyPart = keyLabel.toUpperCase();
        }
    }

    if (keyPart.isNotEmpty) {
      parts.add(keyPart);
    }

    final hotkey = parts.join('+');

    setState(() {
      _inputHotkey = hotkey;
      _isCapturing = false;
      _validateHotkey(hotkey);
    });

    return KeyEventResult.handled;
  }

  void _validateHotkey(String hotkey) {
    setState(() {
      _errorMessage = null;
    });

    if (!HotkeyUtils.isValidHotkey(hotkey)) {
      setState(() {
        _errorMessage =
            'Invalid hotkey. Use single keys (A-Z, 0-9), function keys (F1-F12), special keys (Space, Enter, etc.), or combinations with modifier keys (Ctrl, Alt, Shift).';
      });
      return;
    }

    final hotkeyService = ref.read(hotkeyServiceProvider);
    if (hotkey != _currentHotkey && hotkeyService.isHotkeyAssigned(hotkey)) {
      final conflictingButton = hotkeyService.getButtonIdForHotkey(hotkey);
      setState(() {
        _errorMessage = 'Hotkey already assigned to: $conflictingButton';
      });
    }
  }

  Future<void> _saveHotkey() async {
    if (_inputHotkey.isEmpty || _errorMessage != null) return;

    try {
      // For now, just return the hotkey to the caller
      // The button will handle the actual assignment with its callback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Hotkey "${HotkeyUtils.formatForDisplay(_inputHotkey)}" assigned to ${widget.buttonName}',
            ),
          ),
        );
        Navigator.of(context).pop(_inputHotkey);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to save hotkey: $e';
      });
    }
  }

  Future<void> _removeHotkey() async {
    final hotkeyService = ref.read(hotkeyServiceProvider);

    try {
      await hotkeyService.removeHotkey(widget.buttonId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hotkey removed from ${widget.buttonName}')),
        );
        Navigator.of(context).pop('removed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to remove hotkey: $e';
      });
    }
  }
}

/// Utility function to show the hotkey assignment dialog
Future<String?> showHotkeyAssignmentDialog({
  required BuildContext context,
  required String buttonId,
  required String buttonName,
}) {
  return showDialog<String?>(
    context: context,
    builder: (context) =>
        HotkeyAssignmentDialog(buttonId: buttonId, buttonName: buttonName),
  );
}
