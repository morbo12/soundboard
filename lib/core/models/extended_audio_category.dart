import 'package:flutter/foundation.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

/// Extended category type that supports both predefined and custom categories
@immutable
abstract class ExtendedAudioCategory {
  const ExtendedAudioCategory();

  /// Get the display name for the category
  String get displayName;

  /// Get the directory name for file storage
  String get directoryName;

  /// Get unique identifier for the category
  String get id;

  /// Check if this is a custom category
  bool get isCustom;
}

/// Wrapper for predefined audio categories
@immutable
class PredefinedAudioCategory extends ExtendedAudioCategory {
  final AudioCategory category;

  const PredefinedAudioCategory(this.category);

  @override
  String get displayName {
    switch (category) {
      case AudioCategory.genericJingle:
        return 'Generic Jingles';
      case AudioCategory.goalJingle:
        return 'Goal Jingles';
      case AudioCategory.penaltyJingle:
        return 'Penalty Jingles';
      case AudioCategory.clapJingle:
        return 'Clap Jingles';
      case AudioCategory.specialJingle:
        return 'Special Jingles';
      case AudioCategory.goalHorn:
        return 'Goal Horn';
    }
  }

  @override
  String get directoryName {
    switch (category) {
      case AudioCategory.genericJingle:
        return 'GenericJingles';
      case AudioCategory.goalJingle:
        return 'GoalJingles';
      case AudioCategory.penaltyJingle:
        return 'PenaltyJingles';
      case AudioCategory.clapJingle:
        return 'ClapJingles';
      case AudioCategory.specialJingle:
        return 'SpecialJingles';
      case AudioCategory.goalHorn:
        return 'GoalHorn';
    }
  }

  @override
  String get id => 'predefined_${category.name}';

  @override
  bool get isCustom => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PredefinedAudioCategory && other.category == category;
  }

  @override
  int get hashCode => category.hashCode;

  @override
  String toString() => 'PredefinedAudioCategory($category)';
}

/// Custom audio category created by the user
@immutable
class CustomAudioCategory extends ExtendedAudioCategory {
  final String customId;
  final String name;

  const CustomAudioCategory({required this.customId, required this.name});

  @override
  String get displayName => name;

  @override
  String get directoryName => 'Custom_$customId';

  @override
  String get id => 'custom_$customId';

  @override
  bool get isCustom => true;

  /// Factory constructor for creating from JSON
  factory CustomAudioCategory.fromJson(Map<String, dynamic> json) {
    return CustomAudioCategory(
      customId: json['customId'] as String,
      name: json['name'] as String,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {'customId': customId, 'name': name};
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomAudioCategory && other.customId == customId;
  }

  @override
  int get hashCode => customId.hashCode;

  @override
  String toString() => 'CustomAudioCategory(id: $customId, name: $name)';
}

/// Utility class for working with extended audio categories
class ExtendedAudioCategoryUtils {
  /// Get all predefined categories as extended categories
  static List<ExtendedAudioCategory> getAllPredefinedCategories() {
    return AudioCategory.values
        .map((category) => PredefinedAudioCategory(category))
        .toList();
  }

  /// Convert AudioCategory to ExtendedAudioCategory
  static ExtendedAudioCategory fromAudioCategory(AudioCategory category) {
    return PredefinedAudioCategory(category);
  }

  /// Get AudioCategory from ExtendedAudioCategory if it's predefined
  static AudioCategory? toAudioCategory(ExtendedAudioCategory extended) {
    if (extended is PredefinedAudioCategory) {
      return extended.category;
    }
    return null;
  }

  /// Create a custom category from a custom category model
  static CustomAudioCategory fromCustomCategory(String customId, String name) {
    return CustomAudioCategory(customId: customId, name: name);
  }
}
