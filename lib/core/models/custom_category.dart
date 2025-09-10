import 'package:flutter/foundation.dart';

/// Model representing a custom sound category created by the user
@immutable
class CustomCategory {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorHex;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CustomCategory({
    required this.id,
    required this.name,
    required this.description,
    this.iconName = 'music_note',
    this.colorHex = '#9C27B0',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Factory constructor for creating from JSON
  factory CustomCategory.fromJson(Map<String, dynamic> json) {
    return CustomCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String? ?? 'music_note',
      colorHex: json['colorHex'] as String? ?? '#9C27B0',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with updated fields
  CustomCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomCategory && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'CustomCategory(id: $id, name: $name, description: $description)';
  }
}
