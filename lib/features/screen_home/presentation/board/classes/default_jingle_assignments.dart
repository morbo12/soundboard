import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'class_grid_jingle_config.dart';

/// Simple default jingle assignments for the soundboard grid
class DefaultJingleAssignments {
  /// Default grid assignments for 3x4 grid (3 columns, 4 rows)
  /// Format: 'row_column': GridJingleConfig with what you want
  static Future<Map<String, GridJingleConfig>> getDefaultAssignments() async {
    final assignments = <String, GridJingleConfig>{};

    assignments['0_0'] = _createEmptyButton('AWAY TEAM');
    assignments['0_1'] = _createEmptyButton('HOME TEAM');

    // Provide some example category assignments
    assignments['1_0'] = _createEmptyButton('RATATA');
    assignments['1_1'] = _createRandomCategory(
      AudioCategory.clapJingle,
      'KLAPPA\nHÄNDERNA',
    );
    assignments['1_2'] = _createRandomCategory(
      AudioCategory.genericJingle,
      'RANDOM\nJINGLE',
    );
    // Create empty buttons with meaningful names for common jingles
    // Users can upload their own files and assign them to these buttons

    assignments['2_1'] = _createEmptyButton('TIMEOUT');
    assignments['2_2'] = _createEmptyButton('PENALTY');
    // Button 3_3 left empty for user customization
    assignments['3_0'] = _createEmptyButton('POWERUP');
    assignments['3_1'] = _createEmptyButton('ONE MIN');
    assignments['3_2'] = _createEmptyButton('THREE MIN');
    // Button 4_3 left empty for user customization

    return assignments;
  }

  /// Create a random category assignment (plays random from category)
  static GridJingleConfig _createRandomCategory(
    AudioCategory category,
    String displayName,
  ) {
    return GridJingleConfig(
      id: 'default_${category.toString().split('.').last}',
      displayName: displayName,
      filePath: null,
      category: category,
      isCategoryOnly: true,
    );
  }

  /// Create an empty button with a display name
  /// Users can assign their own jingles to these buttons
  static GridJingleConfig _createEmptyButton(String displayName) {
    return GridJingleConfig(
      id: 'empty_${displayName.toLowerCase().replaceAll(' ', '_')}',
      displayName: displayName,
      filePath: null,
      category: null,
      isCategoryOnly: false,
    );
  }

  /// Helper methods for position management
  static String getPositionKey(int row, int column) => '${row}_$column';

  static (int row, int column) getPositionFromKey(String key) {
    final parts = key.split('_');
    return (int.parse(parts[0]), int.parse(parts[1]));
  }
}

// Contains AI-generated edits.
