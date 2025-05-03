import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/properties.dart';
import 'class_grid_jingle_config.dart';
import 'default_jingle_assignments.dart';

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

        jsonMap.forEach((key, value) {
          final position = int.parse(key);
          if (value != null) {
            final config = GridJingleConfig.fromJson(value);
            if (config.category != null) {
              loadedState[position] = AudioFile(
                filePath: config.filePath ?? '',
                displayName: config.displayName ?? '',
                audioCategory: config.category!,
                isCategoryOnly: config.isCategoryOnly,
              );
            }
          } else {
            loadedState[position] = null;
          }
        });

        state = loadedState;
      } catch (e) {
        print('Error loading grid state: $e');
        await _initializeDefaultConfiguration();
      }
    }
  }

  Future<void> _initializeDefaultConfiguration() async {
    final defaultAssignments =
        await DefaultJingleAssignments.getDefaultAssignments();
    final Map<int, AudioFile?> initialState = {};

    // Initialize with default assignments
    defaultAssignments.forEach((positionKey, config) {
      final (row, col) = DefaultJingleAssignments.getPositionFromKey(
        positionKey,
      );
      final position = row * 3 + col; // Convert 2D position to 1D index

      if (config.category != null && config.displayName != null) {
        initialState[position] = AudioFile(
          filePath: config.filePath ?? '',
          displayName: config.displayName!,
          audioCategory: config.category!,
          isCategoryOnly: config.isCategoryOnly,
        );
      }
    });

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
}
