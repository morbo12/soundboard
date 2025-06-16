import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_settings/data/class_slider_mappings.dart';

/// Repository for managing Deej configuration data
class DeejConfigRepository {
  final SettingsBox _settingsBox;

  DeejConfigRepository(this._settingsBox);

  /// Get process ID for a specific slider index based on mappings
  int getProcessIdForSlider(int sliderIdx) {
    final mappings = _settingsBox.sliderMappings;
    final mapping = mappings
        .where((m) => m.deejSliderIdx == sliderIdx)
        .firstOrNull;

    if (mapping == null) {
      return -1; // No mapping found
    }

    // For now, return the UI slider index as process ID
    // This should be enhanced to return actual process IDs
    return mapping.uiSliderIdx;
  }

  /// Get all slider mappings
  List<SliderMapping> getSliderMappings() {
    return _settingsBox.sliderMappings;
  }

  /// Get mapping for a specific Deej slider
  SliderMapping? getMappingForDeejSlider(int deejSliderIdx) {
    return _settingsBox.getMappingForDeejSlider(deejSliderIdx);
  }
}

/// Immutable Deej configuration model
class DeejConfig {
  final bool invertSliders;
  final bool verbose;
  final double noiseReductionLevel;
  final List<SliderMapping> sliderMappings;

  const DeejConfig({
    required this.invertSliders,
    required this.verbose,
    required this.noiseReductionLevel,
    required this.sliderMappings,
  });

  DeejConfig copyWith({
    bool? invertSliders,
    bool? verbose,
    double? noiseReductionLevel,
    List<SliderMapping>? sliderMappings,
  }) {
    return DeejConfig(
      invertSliders: invertSliders ?? this.invertSliders,
      verbose: verbose ?? this.verbose,
      noiseReductionLevel: noiseReductionLevel ?? this.noiseReductionLevel,
      sliderMappings: sliderMappings ?? this.sliderMappings,
    );
  }

  /// Get process ID for a specific slider index
  int getProcessIdForSlider(int sliderIdx) {
    final mapping = sliderMappings
        .where((m) => m.deejSliderIdx == sliderIdx)
        .firstOrNull;
    return mapping?.uiSliderIdx ?? -1;
  }
}

/// Repository provider for Deej configuration
final deejConfigRepositoryProvider = Provider<DeejConfigRepository>((ref) {
  return DeejConfigRepository(SettingsBox());
});

/// Provider for Deej configuration
final deejConfigProvider = Provider<DeejConfig>((ref) {
  final repository = ref.watch(deejConfigRepositoryProvider);

  return DeejConfig(
    invertSliders: false, // Can be made configurable
    verbose: false, // Can be made configurable
    noiseReductionLevel: 0.02, // Can be made configurable
    sliderMappings: repository.getSliderMappings(),
  );
});

// Contains AI-generated edits.
