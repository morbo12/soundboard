import 'package:flutter/foundation.dart';

/// Weight settings for a sound in a group (optional feature)
@immutable
class SoundWeight {
  final String soundFilePath;
  final double weight;
  final bool isExcluded;

  const SoundWeight({
    required this.soundFilePath,
    this.weight = 1.0,
    this.isExcluded = false,
  });

  factory SoundWeight.fromJson(Map<String, dynamic> json) {
    return SoundWeight(
      soundFilePath: json['soundFilePath'] as String,
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      isExcluded: json['isExcluded'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundFilePath': soundFilePath,
      'weight': weight,
      'isExcluded': isExcluded,
    };
  }

  SoundWeight copyWith({
    String? soundFilePath,
    double? weight,
    bool? isExcluded,
  }) {
    return SoundWeight(
      soundFilePath: soundFilePath ?? this.soundFilePath,
      weight: weight ?? this.weight,
      isExcluded: isExcluded ?? this.isExcluded,
    );
  }
}

/// Model representing a custom sound group that can contain sounds from multiple categories
@immutable
class SoundGroup {
  final String id;
  final String name;
  final String description;
  final List<String> soundFilePaths;
  final Map<String, SoundWeight> soundWeights; // Optional weights/exclusions
  final String
  customCategoryId; // Links to the custom category this group belongs to
  final bool enableRandomization;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SoundGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.soundFilePaths,
    this.soundWeights = const {},
    required this.customCategoryId,
    this.enableRandomization = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating from JSON
  factory SoundGroup.fromJson(Map<String, dynamic> json) {
    final weightsJson = json['soundWeights'] as Map<String, dynamic>? ?? {};
    final soundWeights = weightsJson.map(
      (key, value) =>
          MapEntry(key, SoundWeight.fromJson(value as Map<String, dynamic>)),
    );

    return SoundGroup(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      soundFilePaths: List<String>.from(json['soundFilePaths'] as List),
      soundWeights: soundWeights,
      customCategoryId: json['customCategoryId'] as String,
      enableRandomization: json['enableRandomization'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    final weightsJson = soundWeights.map(
      (key, value) => MapEntry(key, value.toJson()),
    );

    return {
      'id': id,
      'name': name,
      'description': description,
      'soundFilePaths': soundFilePaths,
      'soundWeights': weightsJson,
      'customCategoryId': customCategoryId,
      'enableRandomization': enableRandomization,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  SoundGroup copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? soundFilePaths,
    Map<String, SoundWeight>? soundWeights,
    String? customCategoryId,
    bool? enableRandomization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SoundGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      soundFilePaths: soundFilePaths ?? this.soundFilePaths,
      soundWeights: soundWeights ?? this.soundWeights,
      customCategoryId: customCategoryId ?? this.customCategoryId,
      enableRandomization: enableRandomization ?? this.enableRandomization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get available sounds for randomization (excluding those marked as excluded)
  List<String> getAvailableSounds() {
    return soundFilePaths.where((filePath) {
      final weight = soundWeights[filePath];
      return weight == null || !weight.isExcluded;
    }).toList();
  }

  /// Get weighted random sound selection
  String? getRandomSound([List<String>? recentlyPlayed]) {
    final availableSounds = getAvailableSounds();

    if (availableSounds.isEmpty) return null;

    // Filter out recently played sounds if provided
    final candidateSounds = recentlyPlayed != null
        ? availableSounds
              .where((sound) => !recentlyPlayed.contains(sound))
              .toList()
        : availableSounds;

    // If all sounds were recently played, fall back to all available sounds
    final finalCandidates = candidateSounds.isNotEmpty
        ? candidateSounds
        : availableSounds;

    if (finalCandidates.isEmpty) return null;

    // Simple random selection (can be enhanced with weighted selection later)
    finalCandidates.shuffle();
    return finalCandidates.first;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SoundGroup(id: $id, name: $name, sounds: ${soundFilePaths.length})';
  }
}
