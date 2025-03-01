import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';

class AppThemes {
  // Keep the original constants for reference
  static const greyLaw = FlexScheme.greyLaw;
  static const aquaBlue = FlexScheme.aquaBlue;
  static const ebonyClay = FlexScheme.ebonyClay;
  static const outerSpace = FlexScheme.outerSpace;
  static const blueWhale = FlexScheme.blueWhale;
  static const sanJuanBlue = FlexScheme.sanJuanBlue;
  static const blueM3 = FlexScheme.blue;
  static const purpleBrown = FlexScheme.purpleBrown;

  // Get all themes dynamically from FlexScheme enum values
  static final List<FlexScheme> allThemes = [
    // Put preferred themes first
    greyLaw,
    aquaBlue,
    ebonyClay,
    outerSpace,
    blueWhale,
    sanJuanBlue,
    blueM3,
    purpleBrown,

    // Then add all remaining schemes
    ...FlexScheme.values.where((scheme) => ![
          greyLaw,
          aquaBlue,
          ebonyClay,
          outerSpace,
          blueWhale,
          sanJuanBlue,
          blueM3,
          purpleBrown,
        ].contains(scheme)),
  ];

  static String getName(FlexScheme scheme) {
    // Use the built-in scheme name and format it nicely
    final name = scheme.toString().split('.').last;

    // Special case handling for specific schemes
    switch (scheme) {
      case FlexScheme.blue:
        return 'Blue M3';
      case FlexScheme.materialHc:
        return 'Material High Contrast';
      case FlexScheme.vesuviusBurn:
        return 'Vesuvius Burn';
      case FlexScheme.deepPurple:
        return 'Deep Purple';
      case FlexScheme.hippieBlue:
        return 'Hippie Blue';
      case FlexScheme.mallardGreen:
        return 'Mallard Green';
      case FlexScheme.mandyRed:
        return 'Mandy Red';
      case FlexScheme.redWine:
        return 'Red Wine';
      case FlexScheme.purpleM3:
        return 'Purple M3';
      case FlexScheme.greenM3:
        return 'Green M3';
      case FlexScheme.limeM3:
        return 'Lime M3';
      case FlexScheme.yellowM3:
        return 'Yellow M3';
      case FlexScheme.orangeM3:
        return 'Orange M3';
      case FlexScheme.pinkM3:
        return 'Pink M3';
      case FlexScheme.tealM3:
        return 'Teal M3';
      case FlexScheme.cyanM3:
        return 'Cyan M3';
      case FlexScheme.deepBlue:
        return 'Deep Blue';
      case FlexScheme.verdunHemlock:
        return 'Verdun Hemlock';
      case FlexScheme.dellGenoa:
        return 'Dell Genoa';
      case FlexScheme.redM3:
        return 'Red M3';
      case FlexScheme.flutterDash:
        return 'Flutter Dash';
      case FlexScheme.bigStone:
        return 'Big Stone';
      case FlexScheme.brandBlue:
        return 'Brand Blue';
      default:
        // For other schemes, convert camelCase to Title Case with spaces
        return _formatSchemeName(name);
    }
  }

  // Helper method to format scheme names from camelCase to Title Case with spaces
  static String _formatSchemeName(String name) {
    // Handle special cases for M3 schemes
    if (name.endsWith('M3')) {
      return '${_formatSchemeName(name.substring(0, name.length - 2))} M3';
    }

    // Convert camelCase to words with spaces
    final result = name
        .replaceAllMapped(
          RegExp(r'([A-Z])'),
          (match) => ' ${match.group(0)}',
        )
        .trim();

    // Capitalize first letter
    if (result.isNotEmpty) {
      return result[0].toUpperCase() + result.substring(1);
    }
    return result;
  }

  static FlexScheme getSchemeFromName(String name) {
    // First check our special cases
    switch (name.toLowerCase()) {
      case 'blue m3':
        return FlexScheme.blue;
      case 'material high contrast':
        return FlexScheme.materialHc;
      case 'vesuvius burn':
        return FlexScheme.vesuviusBurn;
      case 'deep purple':
        return FlexScheme.deepPurple;
      case 'hippie blue':
        return FlexScheme.hippieBlue;
      case 'mallard green':
        return FlexScheme.mallardGreen;
      case 'mandy red':
        return FlexScheme.mandyRed;
      case 'red wine':
        return FlexScheme.redWine;
      case 'purple m3':
        return FlexScheme.purpleM3;
      case 'green m3':
        return FlexScheme.greenM3;
      case 'lime m3':
        return FlexScheme.limeM3;
      case 'yellow m3':
        return FlexScheme.yellowM3;
      case 'orange m3':
        return FlexScheme.orangeM3;
      case 'pink m3':
        return FlexScheme.pinkM3;
      case 'teal m3':
        return FlexScheme.tealM3;
      case 'cyan m3':
        return FlexScheme.cyanM3;
      case 'deep blue':
        return FlexScheme.deepBlue;
      case 'verdun hemlock':
        return FlexScheme.verdunHemlock;
      case 'dell genoa':
        return FlexScheme.dellGenoa;
      case 'red m3':
        return FlexScheme.redM3;
      case 'flutter dash':
        return FlexScheme.flutterDash;
      case 'big stone':
        return FlexScheme.bigStone;
      case 'brand blue':
        return FlexScheme.brandBlue;
    }

    // Try to find the scheme by comparing formatted names
    for (final scheme in FlexScheme.values) {
      if (getName(scheme).toLowerCase() == name.toLowerCase()) {
        return scheme;
      }
    }

    if (kDebugMode) {
      print("[AppThemes] ERROR ${name.toLowerCase()}");
    }
    throw ArgumentError('Unknown theme name: $name');
  }

  // Kept the original method
  static List<String> getThemeNamesList() {
    return allThemes.map((scheme) => getName(scheme)).toList();
  }
}
