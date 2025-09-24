import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundboard/core/utils/logger.dart';

final Logger _logger = const Logger('HotkeyService');

/// Service for managing keyboard shortcuts and hotkey assignments
class HotkeyService extends ChangeNotifier {
  static const String _hotkeyPrefix = 'hotkey_';

  final Map<String, String> _hotkeys = {}; // buttonId -> hotkey combination
  final Map<String, VoidCallback> _callbacks = {}; // buttonId -> callback
  StreamSubscription<RawKeyEvent>? _keySubscription;

  /// Get assigned hotkey for a button
  String? getHotkey(String buttonId) => _hotkeys[buttonId];

  /// Check if hotkey is already assigned
  bool isHotkeyAssigned(String hotkey) => _hotkeys.containsValue(hotkey);

  /// Get button ID that has this hotkey assigned
  String? getButtonIdForHotkey(String hotkey) {
    for (final entry in _hotkeys.entries) {
      if (entry.value == hotkey) return entry.key;
    }
    return null;
  }

  /// Assign a hotkey to a button
  Future<void> assignHotkey(
    String buttonId,
    String hotkey,
    VoidCallback callback,
  ) async {
    _logger.d('Assigning hotkey "$hotkey" to button "$buttonId"');

    // Remove any existing hotkey for this button
    await removeHotkey(buttonId);

    // Check for conflicts
    final existingButtonId = getButtonIdForHotkey(hotkey);
    if (existingButtonId != null && existingButtonId != buttonId) {
      _logger.w(
        'Hotkey "$hotkey" already assigned to "$existingButtonId", removing old assignment',
      );
      await removeHotkey(existingButtonId);
    }

    _hotkeys[buttonId] = hotkey;
    _callbacks[buttonId] = callback;

    await _saveHotkey(buttonId, hotkey);
    notifyListeners();
  }

  /// Remove hotkey assignment for a button
  Future<void> removeHotkey(String buttonId) async {
    _logger.d('Removing hotkey for button "$buttonId"');

    final hotkey = _hotkeys.remove(buttonId);
    _callbacks.remove(buttonId);

    if (hotkey != null) {
      await _deleteHotkey(buttonId);
      notifyListeners();
    }
  }

  /// Load saved hotkeys from persistence
  Future<void> loadHotkeys() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith(_hotkeyPrefix),
      );

      for (final key in keys) {
        final buttonId = key.substring(_hotkeyPrefix.length);
        final hotkey = prefs.getString(key);
        if (hotkey != null) {
          _hotkeys[buttonId] = hotkey;
        }
      }

      _logger.d('Loaded ${_hotkeys.length} hotkeys from storage');
      notifyListeners();
    } catch (e) {
      _logger.e('Failed to load hotkeys: $e');
    }
  }

  /// Register callbacks for buttons (call this when buttons are initialized)
  void registerCallback(String buttonId, VoidCallback callback) {
    _callbacks[buttonId] = callback;
    _logger.d('Registered callback for button "$buttonId"');
  }

  /// Start listening for keyboard events
  void startListening(BuildContext context) {
    if (_keySubscription != null) return;

    _logger.d('Starting hotkey listener');

    // Use RawKeyboardListener's onKey callback approach
    // This will be called from the main app's RawKeyboardListener
  }

  /// Stop listening for keyboard events
  void stopListening() {
    _keySubscription?.cancel();
    _keySubscription = null;
    _logger.d('Stopped hotkey listener');
  }

  /// Handle key event - call this from the main app's RawKeyboardListener
  bool handleKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return false;

    final hotkey = _formatKeyEvent(event);
    if (hotkey.isEmpty) return false;

    final buttonId = getButtonIdForHotkey(hotkey);
    if (buttonId != null) {
      _logger.d('Hotkey "$hotkey" triggered for button "$buttonId"');
      final callback = _callbacks[buttonId];
      if (callback != null) {
        callback();
        return true; // Indicate we handled this key event
      }
    }

    return false;
  }

  /// Format key event into hotkey string
  String _formatKeyEvent(RawKeyEvent event) {
    final parts = <String>[];

    // Add modifiers
    if (event.isControlPressed) parts.add('Ctrl');
    if (event.isShiftPressed) parts.add('Shift');
    if (event.isAltPressed) parts.add('Alt');
    if (event.isMetaPressed) parts.add('Meta');

    // Handle special keys and regular keys
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
        // Use the key label for regular keys (letters, numbers, function keys)
        final label = event.logicalKey.keyLabel;
        if (label.isNotEmpty) {
          keyPart = label.toUpperCase();
        }
    }

    if (keyPart.isNotEmpty) {
      parts.add(keyPart);
    }

    return parts.join('+');
  }

  /// Save hotkey to persistent storage
  Future<void> _saveHotkey(String buttonId, String hotkey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_hotkeyPrefix$buttonId', hotkey);
      _logger.d('Saved hotkey "$hotkey" for button "$buttonId"');
    } catch (e) {
      _logger.e('Failed to save hotkey: $e');
    }
  }

  /// Delete hotkey from persistent storage
  Future<void> _deleteHotkey(String buttonId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_hotkeyPrefix$buttonId');
      _logger.d('Deleted hotkey for button "$buttonId"');
    } catch (e) {
      _logger.e('Failed to delete hotkey: $e');
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  /// Get all assigned hotkeys (for debugging/display)
  Map<String, String> getAllHotkeys() => Map.from(_hotkeys);
}

/// Provider for the hotkey service
final hotkeyServiceProvider = ChangeNotifierProvider<HotkeyService>((ref) {
  final service = HotkeyService();
  service.loadHotkeys();
  return service;
});

/// Helper class for hotkey validation and formatting
class HotkeyUtils {
  /// Check if hotkey string is valid
  static bool isValidHotkey(String hotkey) {
    if (hotkey.isEmpty) return false;

    final parts = hotkey.split('+');
    if (parts.isEmpty) return false;

    final lastPart = parts.last;
    final hasModifier = parts.length > 1;

    // Allow function keys without modifiers
    final isFunctionKey =
        lastPart.startsWith('F') && int.tryParse(lastPart.substring(1)) != null;

    // Allow single letters, numbers, and special keys without modifiers
    final isSingleKey =
        parts.length == 1 &&
        (
        // Single letters (A-Z)
        (lastPart.length == 1 &&
                lastPart.toUpperCase().codeUnitAt(0) >= 65 &&
                lastPart.toUpperCase().codeUnitAt(0) <= 90) ||
            // Single numbers (0-9)
            (lastPart.length == 1 &&
                lastPart.codeUnitAt(0) >= 48 &&
                lastPart.codeUnitAt(0) <= 57) ||
            // Function keys (F1-F12)
            isFunctionKey ||
            // Special keys
            [
              'SPACE',
              'ENTER',
              'TAB',
              'ESCAPE',
              'BACKSPACE',
              'DELETE',
              'INSERT',
              'HOME',
              'END',
              'PAGE_UP',
              'PAGE_DOWN',
              'ARROW_UP',
              'ARROW_DOWN',
              'ARROW_LEFT',
              'ARROW_RIGHT',
            ].contains(lastPart.toUpperCase()));

    return hasModifier || isFunctionKey || isSingleKey;
  }

  /// Format hotkey for display
  static String formatForDisplay(String hotkey) {
    if (hotkey.isEmpty) return '';

    return hotkey
        .split('+')
        .map((part) {
          switch (part.toLowerCase()) {
            case 'ctrl':
              return 'Ctrl';
            case 'shift':
              return 'Shift';
            case 'alt':
              return 'Alt';
            case 'meta':
              return 'Meta';
            case 'space':
              return 'Space';
            case 'enter':
              return 'Enter';
            case 'tab':
              return 'Tab';
            case 'escape':
              return 'Esc';
            case 'backspace':
              return 'Backspace';
            case 'delete':
              return 'Del';
            case 'insert':
              return 'Insert';
            case 'home':
              return 'Home';
            case 'end':
              return 'End';
            case 'page_up':
              return 'PgUp';
            case 'page_down':
              return 'PgDn';
            case 'arrow_up':
              return '↑';
            case 'arrow_down':
              return '↓';
            case 'arrow_left':
              return '←';
            case 'arrow_right':
              return '→';
            default:
              return part.toUpperCase();
          }
        })
        .join(' + ');
  }

  /// Get suggested hotkeys for common buttons
  static List<String> getSuggestedHotkeys() {
    return [
      // Single keys
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
      'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P',
      'A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L',
      'Z', 'X', 'C', 'V', 'B', 'N', 'M',
      // Function keys
      'F1', 'F2', 'F3', 'F4', 'F5', 'F6', 'F7', 'F8', 'F9', 'F10', 'F11', 'F12',
      // Special keys
      'SPACE', 'ENTER',
      // Modifier combinations (for advanced users)
      'Ctrl+1', 'Ctrl+2', 'Ctrl+3', 'Ctrl+4', 'Ctrl+5', 'Ctrl+G', 'Ctrl+H',
      'Alt+1', 'Alt+2', 'Alt+3', 'Alt+4', 'Alt+5',
      'Shift+F1', 'Shift+F2', 'Shift+F3', 'Shift+F4', 'Shift+F5',
    ];
  }
}
