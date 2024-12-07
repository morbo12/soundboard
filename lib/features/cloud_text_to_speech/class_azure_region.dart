import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/properties.dart';

enum AzureRegion {
  northEurope,
  swedencentral,
  uksouth,
  westeurope,
  francecentral,
  germanywestcentral,
  norwayeast,
  polandcentral,
  switzerlandnorth
}

final regionManagerProvider = StateProvider<int>((ref) {
  return SettingsBox().azRegionId;
});

class AzureRegionManager {
  final List<Map<int, MapEntry<AzureRegion, String>>> regions;

  AzureRegionManager({List<Map<int, MapEntry<AzureRegion, String>>>? regions})
      : regions = regions ??
            [
              {1: const MapEntry(AzureRegion.northEurope, 'North Europe')},
              {2: const MapEntry(AzureRegion.swedencentral, 'Sweden Central')},
              {3: const MapEntry(AzureRegion.uksouth, 'UK South')},
              {4: const MapEntry(AzureRegion.westeurope, 'West Europe')},
              {5: const MapEntry(AzureRegion.francecentral, 'France Central')},
              {
                6: const MapEntry(
                    AzureRegion.germanywestcentral, 'Germany West Central')
              },
              {7: const MapEntry(AzureRegion.norwayeast, 'Norway East')},
              {8: const MapEntry(AzureRegion.polandcentral, 'Poland Central')},
              {
                9: const MapEntry(
                    AzureRegion.switzerlandnorth, 'Switzerland North')
              },
              // Add any other Europe regions from the input list with display names
            ];

  List<String> getRegionsList() {
    return regions.map((region) => region.values.first.value).toList();
  }

  int getIdByName(String regionName) {
    final regionEntry = regions.firstWhere(
        (entry) => entry.values.first.value == regionName,
        orElse: () =>
            {0: const MapEntry(AzureRegion.northEurope, 'Region not found')});
    return regionEntry.keys.first;
  }

  String getNameById(int regionId) {
    final regionEntry = regions.firstWhere(
        (entry) => entry.keys.first == regionId,
        orElse: () =>
            {0: const MapEntry(AzureRegion.northEurope, 'Region not found')});
    return regionEntry.values.first.value;
  }

  String getAzRegionName(int regionId) {
    final regionEntry = regions.firstWhere(
        (entry) => entry.keys.first == regionId,
        orElse: () =>
            {0: const MapEntry(AzureRegion.northEurope, 'Region not found')});
    // Using the 'name' property of the enum to get its string representation
    return regionEntry.values.first.key.name;
  }
}
