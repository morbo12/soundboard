import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/core/services/jingle_manager/class_static_audiofiles.dart';
import 'class_grid_jingle_config.dart';

/// Defines the default jingle assignments for specific positions on the board
class DefaultJingleAssignments {
  /// Returns a map of grid positions to their assigned categories
  static Map<String, AudioCategory> get defaultCategoryAssignments => {
    // Row 1
    '0_0': AudioCategory.ratataJingle,
    '0_2': AudioCategory.genericJingle,

    // Row 2
    '1_0': AudioCategory.clapJingle,
    '1_1': AudioCategory.powerupJingle,
    '1_2': AudioCategory.penaltyJingle,

    // Row 3
    '2_0': AudioCategory.oneminJingle,
    '2_1': AudioCategory.timeoutJingle,
    '2_2': AudioCategory.threeminJingle,
  };

  /// Defines which categories should be treated as category-only
  /// When true, the button will play a random sound from the category
  /// instead of a specific file
  static Map<String, bool> get categoryOnlySettings => {
    // Example: Set specific positions to be category-only
    '0_2': true,
    '1_0': true,
  };

  /// instead of a specific file
  static Map<String, String> get overrideDisplayName => {
    // Example: Set specific positions to be category-only
    '0_0': "RATATA",
    '0_2': "JINGLE",
    '1_0': "KLAPPA HÄNDERNA",
    '1_1': "Fulltalig",
    '1_2': "Utvisning",
    '2_0': "1 min - kvar på period",
    '2_2': "3 min - kvar på match",
    // Add more as needed
  };

  /// Returns a map of grid positions to jingle configurations
  /// The key is formatted as 'row_column' (e.g., '0_0' for top-left position)
  static Future<Map<String, GridJingleConfig>> getDefaultAssignments() async {
    final Map<String, GridJingleConfig> assignments = {};

    for (final entry in defaultCategoryAssignments.entries) {
      // Check if this position should be category-only
      final isCategoryOnly = categoryOnlySettings[entry.key] ?? false;

      if (isCategoryOnly) {
        // For category-only buttons, we don't need a specific file
        // We'll create a GridJingleConfig that represents the entire category
        assignments[entry.key] = GridJingleConfig(
          id: 'default_${entry.key}',
          displayName:
              overrideDisplayName[entry.key] ??
              getCategoryDisplayName(entry.value),
          // No specific filePath for category-only buttons
          filePath: null,
          category: entry.value,
          isCategoryOnly: true,
        );
      } else {
        // For specific jingle buttons, get a specific audio file
        final audioFile = await AudioConfigurations.getAudioFileForCategory(
          entry.value,
        );

        if (audioFile != null) {
          assignments[entry.key] = GridJingleConfig(
            id: 'default_${entry.key}',
            displayName:
                overrideDisplayName[entry.key] ?? audioFile.displayName,
            filePath: audioFile.filePath,
            category: audioFile.audioCategory,
            isCategoryOnly: false,
          );
        }
      }
    }

    return assignments;
  }

  /// Helper method to generate position key
  static String getPositionKey(int row, int column) {
    return '${row}_$column';
  }

  /// Helper method to get row and column from position key
  static (int row, int column) getPositionFromKey(String key) {
    final parts = key.split('_');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }

  /// Helper method to check if a position should be category-only
  static bool isCategoryOnly(String positionKey) {
    return categoryOnlySettings[positionKey] ?? false;
  }

  /// Helper method to check if a position should be category-only
  static bool isCategoryOnlyByRowColumn(int row, int column) {
    final key = getPositionKey(row, column);
    return isCategoryOnly(key);
  }

  /// Helper method to get a display name for a category
  static String getCategoryDisplayName(AudioCategory category) {
    // You can customize the display names for categories here
    switch (category) {
      default:
        return '${category.toString().split('.').last.replaceAll('Jingle', '')} - random';
    }
  }
}
