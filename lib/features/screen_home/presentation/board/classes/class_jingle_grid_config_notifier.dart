import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'class_grid_jingle_config.dart';
import 'default_jingle_assignments.dart';

// Provider for grid settings
final gridSettingsProvider =
    StateNotifierProvider<GridSettingsNotifier, (int, int)>((ref) {
      return GridSettingsNotifier();
    });

class GridSettingsNotifier extends StateNotifier<(int, int)> {
  GridSettingsNotifier()
    : super((SettingsBox().gridColumns, SettingsBox().gridRows)) {
    // Force default to 3x4 if grid is currently 3x3 (legacy)
    if (state.$1 == 3 && state.$2 == 3) {
      updateSettings(3, 4);
    }
  }

  void updateSettings(int columns, int rows) {
    SettingsBox().gridColumns = columns;
    SettingsBox().gridRows = rows;
    state = (columns, rows);
  }

  void forceResetToDefault() {
    updateSettings(3, 4);
  }
}

// Provider to store the grid configuration
final jingleGridConfigProvider =
    StateNotifierProvider<JingleGridConfigNotifier, Map<int, AudioFile?>>((
      ref,
    ) {
      return JingleGridConfigNotifier();
    });

class JingleGridConfigNotifier extends StateNotifier<Map<int, AudioFile?>> {
  static const String _storageKey = 'jingle_grid_config';
  final _settingsBox = SettingsBox();
  final Logger logger = const Logger('JingleGridConfigNotifier');

  JingleGridConfigNotifier() : super({}) {
    _initializeStorage();
  }

  Future<void> _initializeStorage() async {
    await _loadState();
  }

  Future<void> _loadState() async {
    final String? jsonStr = _settingsBox.get(_storageKey, defaultValue: null);

    if (jsonStr == null) {
      // First launch - initialize with default configuration
      await _initializeDefaultConfiguration();
    } else {
      // Load existing configuration
      try {
        final Map<String, dynamic> jsonMap = json.decode(jsonStr);
        final Map<int, AudioFile?> loadedState = {};

        for (final entry in jsonMap.entries) {
          final position = int.parse(entry.key);
          if (entry.value != null) {
            final config = GridJingleConfig.fromJson(entry.value);
            // Include both category buttons AND empty buttons (no need to check category)
            loadedState[position] = await config.toAudioFile();
          } else {
            loadedState[position] = null;
          }
        }

        state = loadedState;
      } catch (e, stackTrace) {
        logger.e('Error loading grid state', e, stackTrace);
        await _initializeDefaultConfiguration();
      }
    }
  }

  Future<void> _initializeDefaultConfiguration() async {
    final defaultAssignments =
        await DefaultJingleAssignments.getDefaultAssignments();
    final Map<int, AudioFile?> initialState = {};

    logger.d('Loading ${defaultAssignments.length} default assignments');

    // Initialize with default assignments
    for (final entry in defaultAssignments.entries) {
      final positionKey = entry.key;
      final config = entry.value;
      final (row, col) = DefaultJingleAssignments.getPositionFromKey(
        positionKey,
      );
      final position = row * 3 + col; // Convert 2D position to 1D index

      logger.d(
        'Processing position $positionKey -> $position: ${config.displayName} (category: ${config.category})',
      );

      // Include both category buttons AND empty buttons (with displayName but no category)
      if (config.displayName != null) {
        // Use the toAudioFile method to properly resolve file paths
        final audioFile = await config.toAudioFile();
        initialState[position] = audioFile;
        logger.d('Added to position $position: ${audioFile?.displayName}');
      }
    }

    logger.d('Final state has ${initialState.length} entries');
    state = initialState;
    await _saveState();
  }

  Future<void> _saveState() async {
    final Map<String, dynamic> jsonMap = {};
    state.forEach((key, value) {
      if (value != null) {
        final config = GridJingleConfig(
          id: value.displayName,
          displayName: value.displayName,
          filePath: value.filePath,
          category: value.audioCategory,
          isCategoryOnly: value.isCategoryOnly,
        );
        jsonMap[key.toString()] = config.toJson();
      } else {
        jsonMap[key.toString()] = null;
      }
    });
    _settingsBox.put(_storageKey, json.encode(jsonMap));
  }

  Future<void> assignJingle(int position, AudioFile audioFile) async {
    final newState = Map<int, AudioFile?>.from(state);
    newState[position] = audioFile;
    state = newState;
    await _saveState();
  }

  Future<void> removeJingle(int position) async {
    final newState = Map<int, AudioFile?>.from(state);
    newState[position] = null;
    state = newState;
    await _saveState();
  }

  Future<void> swapPositions(int from, int to) async {
    final newState = Map<int, AudioFile?>.from(state);
    final fromJingle = state[from];
    final toJingle = state[to];
    newState[to] = fromJingle;
    newState[from] = toJingle;
    state = newState;
    await _saveState();
  }

  /// Reset all assignments to default configuration
  Future<void> resetToDefaults() async {
    logger.d('Resetting grid assignments to defaults');
    await _initializeDefaultConfiguration();
  }

  /// Clear all assignments (empty grid)
  Future<void> clearAllAssignments() async {
    logger.d('Clearing all grid assignments');
    state = {};
    await _saveState();
  }
}
