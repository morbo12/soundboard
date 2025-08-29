import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'class_grid_jingle_config.dart';

/// Simple default jingle assignments for the soundboard grid
class DefaultJingleAssignments {
  /// Default grid assignments for 3x4 grid (3 columns, 4 rows)
  /// Format: 'row_column': GridJingleConfig with what you want
  static Future<Map<String, GridJingleConfig>> getDefaultAssignments() async {
    final assignments = <String, GridJingleConfig>{};

    assignments['0_0'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'Bortalag\nBakgrund',
      'eu.fbtools - AwayTeamBackground - Jumpstart.mp3',
    );
    assignments['0_1'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'Hemmalag\nBakgrund',
      'eu.fbtools - HomeTeamBackground - Contradiction.mp3',
    );

    // Provide some example category assignments
    assignments['1_0'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'Match Period\nStart',
      'eu.fbtools - Ratata.mp3',
    );
    assignments['1_1'] = _createSpecificFile(
      AudioCategory.penaltyJingle,
      'UTVISNING',
      'eu.fbtools - En stund på kanten v1 - b0d10f14 - [sports pop, instrumental, playful].mp3', // Example specific file
    );
    assignments['1_2'] = _createRandomCategory(
      AudioCategory.genericJingle,
      'RANDOM\nJINGLE',
    );
    // Create empty buttons with meaningful names for common jingles
    // Users can upload their own files and assign them to these buttons

    // Map special effect buttons to specific files so shipped assets work OOTB
    assignments['2_0'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'TIMEOUT\nBortalag',
      'eu.fbtools - timeout - bortalag.mp3', // Example specific file
    );
    assignments['2_1'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'TIMEOUT\nHemmalag',
      'eu.fbtools - timeout - hemmalag.mp3', // Example specific file
    );

    assignments['2_2'] = _createSpecificFile(
      AudioCategory.specialJingle,
      '1 MIN',
      'eu.fbtools - oneMinFile.mp3', // Example specific file
    );
    // Button 3_3 left empty for user customization
    assignments['3_0'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'POWERUP\nBortalag',
      'eu.fbtools - Bortalag Fulltalig - kvinnlig.mp3', // Example specific file
    );
    assignments['3_1'] = _createSpecificFile(
      AudioCategory.specialJingle,
      'POWERUP\nHemmalag',
      'eu.fbtools - Hemmalag Fulltalig - kvinnlig.mp3', // Example specific file
    );

    assignments['3_2'] = _createSpecificFile(
      AudioCategory.specialJingle,
      '3 MIN',
      'eu.fbtools - threeMinFile.mp3', // Example specific file
    );
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

  /// Create a specific file assignment from category
  /// This creates a category-only assignment that will be resolved to the specific file
  /// during runtime when the file matching occurs
  static GridJingleConfig _createSpecificFile(
    AudioCategory category,
    String displayName,
    String fileName,
  ) {
    // For now, we'll create a category-only assignment with a special ID pattern
    // The AudioManager can detect this pattern and match the specific file
    return GridJingleConfig(
      id: 'specific_${category.toString().split('.').last}_$fileName',
      displayName: displayName,
      filePath: fileName, // Store the target filename
      category: category,
      isCategoryOnly: false, // This is a specific file assignment
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
