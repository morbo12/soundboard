/// Configuration for UI slider behavior when Deej is not connected
class UISliderConfig {
  /// Whether this UI slider should control Windows processes
  final bool controlsWindowsAudio;

  /// List of process names this slider should control (when controlsWindowsAudio is true)
  final List<String> processNames;

  /// Whether this slider is enabled for user interaction
  final bool enabled;

  /// Display name for this slider
  final String displayName;

  const UISliderConfig({
    required this.controlsWindowsAudio,
    required this.processNames,
    required this.enabled,
    required this.displayName,
  });

  factory UISliderConfig.fromJson(Map<String, dynamic> json) {
    return UISliderConfig(
      controlsWindowsAudio: json['controlsWindowsAudio'] ?? false,
      processNames: json['processNames'] != null
          ? List<String>.from(json['processNames'] as List)
          : <String>[],
      enabled: json['enabled'] ?? true,
      displayName: json['displayName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'controlsWindowsAudio': controlsWindowsAudio,
      'processNames': processNames,
      'enabled': enabled,
      'displayName': displayName,
    };
  }

  UISliderConfig copyWith({
    bool? controlsWindowsAudio,
    List<String>? processNames,
    bool? enabled,
    String? displayName,
  }) {
    return UISliderConfig(
      controlsWindowsAudio: controlsWindowsAudio ?? this.controlsWindowsAudio,
      processNames: processNames ?? this.processNames,
      enabled: enabled ?? this.enabled,
      displayName: displayName ?? this.displayName,
    );
  }
}

/// Configuration for Deej hardware mapping when connected
class DeejHardwareMapping {
  /// The physical Deej slider index (0-3)
  final int deejSliderIdx;

  /// What this Deej slider controls
  final DeejTarget target;

  /// For external process targets, the process name
  final String? processName;

  const DeejHardwareMapping({
    required this.deejSliderIdx,
    required this.target,
    this.processName,
  });

  factory DeejHardwareMapping.fromJson(Map<String, dynamic> json) {
    return DeejHardwareMapping(
      deejSliderIdx: json['deejSliderIdx'] ?? 0,
      target: DeejTarget.values.firstWhere(
        (t) => t.name == json['target'],
        orElse: () => DeejTarget.master,
      ),
      processName: json['processName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deejSliderIdx': deejSliderIdx,
      'target': target.name,
      'processName': processName,
    };
  }

  DeejHardwareMapping copyWith({
    int? deejSliderIdx,
    DeejTarget? target,
    String? processName,
  }) {
    return DeejHardwareMapping(
      deejSliderIdx: deejSliderIdx ?? this.deejSliderIdx,
      target: target ?? this.target,
      processName: processName ?? this.processName,
    );
  }
}

/// What a Deej slider can control
enum DeejTarget {
  master('Master Volume'),
  externalProcess('External Process'),
  audioPlayerC1('AudioPlayer C1'),
  audioPlayerC2('AudioPlayer C2'),
  musicPlayer('Music Player');

  const DeejTarget(this.displayName);
  final String displayName;
}

/// Complete configuration for the volume control system
class VolumeSystemConfig {
  /// Configuration for UI sliders when Deej is not connected
  final Map<int, UISliderConfig> uiSliderConfigs;

  /// Deej hardware mappings when connected
  final List<DeejHardwareMapping> deejMappings;

  /// Global process list for dropdown selections
  final List<String> availableProcesses;

  const VolumeSystemConfig({
    required this.uiSliderConfigs,
    required this.deejMappings,
    required this.availableProcesses,
  });

  /// Default configuration
  factory VolumeSystemConfig.defaultConfig() {
    return const VolumeSystemConfig(
      uiSliderConfigs: {
        0: UISliderConfig(
          controlsWindowsAudio: true,
          processNames: [],
          enabled: true,
          displayName: 'Master',
        ),
        4: UISliderConfig(
          controlsWindowsAudio: false,
          processNames: [],
          enabled: true,
          displayName: 'C1',
        ),
        5: UISliderConfig(
          controlsWindowsAudio: false,
          processNames: [],
          enabled: true,
          displayName: 'C2',
        ),
      },
      deejMappings: [],
      availableProcesses: [],
    );
  }

  factory VolumeSystemConfig.fromJson(Map<String, dynamic> json) {
    final uiConfigs = <int, UISliderConfig>{};
    final uiConfigsJson = json['uiSliderConfigs'] ?? {};

    // Safely handle the uiSliderConfigs with proper type casting
    if (uiConfigsJson is Map) {
      for (final entry in uiConfigsJson.entries) {
        final key = entry.key;
        final value = entry.value;

        // Parse the key as int
        final sliderIndex = key is String ? int.parse(key) : key as int;

        // Ensure the value is a proper Map<String, dynamic>
        final configMap = value is Map<String, dynamic>
            ? value
            : Map<String, dynamic>.from(value as Map);

        uiConfigs[sliderIndex] = UISliderConfig.fromJson(configMap);
      }
    }

    final deejMappingsList = json['deejMappings'] as List<dynamic>? ?? [];
    final deejMappings = deejMappingsList.map((m) {
      // Ensure each mapping is properly typed
      final mappingMap = m is Map<String, dynamic>
          ? m
          : Map<String, dynamic>.from(m as Map);
      return DeejHardwareMapping.fromJson(mappingMap);
    }).toList();

    return VolumeSystemConfig(
      uiSliderConfigs: uiConfigs,
      deejMappings: deejMappings,
      availableProcesses: List<String>.from(json['availableProcesses'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    final uiConfigsJson = <String, dynamic>{};
    for (final entry in uiSliderConfigs.entries) {
      uiConfigsJson[entry.key.toString()] = entry.value.toJson();
    }

    return {
      'uiSliderConfigs': uiConfigsJson,
      'deejMappings': deejMappings.map((m) => m.toJson()).toList(),
      'availableProcesses': availableProcesses,
    };
  }

  VolumeSystemConfig copyWith({
    Map<int, UISliderConfig>? uiSliderConfigs,
    List<DeejHardwareMapping>? deejMappings,
    List<String>? availableProcesses,
  }) {
    return VolumeSystemConfig(
      uiSliderConfigs: uiSliderConfigs ?? this.uiSliderConfigs,
      deejMappings: deejMappings ?? this.deejMappings,
      availableProcesses: availableProcesses ?? this.availableProcesses,
    );
  }
}

// Contains AI-generated edits.
