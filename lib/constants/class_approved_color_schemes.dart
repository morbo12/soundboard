import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppThemes {
  static const greyLaw = FlexScheme.greyLaw;
  static const aquaBlue = FlexScheme.aquaBlue;
  static const ebonyClay = FlexScheme.ebonyClay;
  static const outerSpace = FlexScheme.outerSpace;
  static const blueWhale = FlexScheme.blueWhale;
  static const sanJuanBlue = FlexScheme.sanJuanBlue;
  static const blueM3 = FlexScheme.blue;
  static const purpleBrown = FlexScheme.purpleBrown;

  static const List<FlexScheme> allThemes = [
    greyLaw,
    aquaBlue,
    ebonyClay,
    outerSpace,
    blueWhale,
    sanJuanBlue,
    blueM3,
    purpleBrown,
  ];

  static String getName(FlexScheme scheme) {
    switch (scheme) {
      case FlexScheme.greyLaw:
        return 'Grey Law';
      case FlexScheme.aquaBlue:
        return 'Aqua Blue';
      case FlexScheme.ebonyClay:
        return 'Ebony Clay';
      case FlexScheme.outerSpace:
        return 'Outer Space';
      case FlexScheme.blueWhale:
        return 'Blue Whale';
      case FlexScheme.sanJuanBlue:
        return 'San Juan Blue';
      case FlexScheme.blue:
        return 'Blue M3';
      case FlexScheme.purpleBrown:
        return 'Purple Brown';
      default:
        return 'Unknown';
    }
  }

  static FlexScheme getSchemeFromName(String name) {
    switch (name.toLowerCase()) {
      case 'grey law':
        return greyLaw;
      case 'aqua blue':
        return aquaBlue;
      case 'ebony clay':
        return ebonyClay;
      case 'outer space':
        return outerSpace;
      case 'blue whale':
        return blueWhale;
      case 'san juan blue':
        return sanJuanBlue;
      case 'blue m3':
        return blueM3;
      case 'purple brown':
        return purpleBrown;
      default:
        print("ERROR ${name.toLowerCase()}");
        throw ArgumentError('Unknown theme name: $name');
    }
  }

  // New method to get a list of all theme names
  static List<String> getThemeNamesList() {
    return allThemes.map((scheme) => getName(scheme)).toList();
  }
}
