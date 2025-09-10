import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/custom_category.dart';
import 'package:soundboard/core/models/sound_group.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Service for managing custom categories and sound groups
class CustomCategoryService {
  static const String _customCategoriesKey = 'custom_categories';
  static const String _soundGroupsKey = 'sound_groups';

  final SettingsBox _settingsBox = SettingsBox();
  final Logger _logger = const Logger('CustomCategoryService');
  final Uuid _uuid = const Uuid();

  /// Get all custom categories
  List<CustomCategory> getCustomCategories() {
    try {
      final jsonString = _settingsBox.get(
        _customCategoriesKey,
        defaultValue: '[]',
      );
      final List<dynamic> jsonList = jsonDecode(jsonString as String);
      return jsonList
          .map((json) => CustomCategory.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error loading custom categories: $e');
      return [];
    }
  }

  /// Save all custom categories
  Future<void> _saveCustomCategories(List<CustomCategory> categories) async {
    try {
      final jsonList = categories.map((category) => category.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      _settingsBox.put(_customCategoriesKey, jsonString);
      _logger.d('Saved ${categories.length} custom categories');
    } catch (e) {
      _logger.e('Error saving custom categories: $e');
      throw Exception('Failed to save custom categories: $e');
    }
  }

  /// Create a new custom category
  Future<CustomCategory> createCustomCategory({
    required String name,
    required String description,
    String iconName = 'music_note',
    String colorHex = '#9C27B0',
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    // Check for duplicate names
    final existingCategories = getCustomCategories();
    final normalizedName = name.trim().toLowerCase();
    if (existingCategories.any(
      (cat) => cat.name.toLowerCase() == normalizedName,
    )) {
      throw ArgumentError('A category with this name already exists');
    }

    // Create new category
    final now = DateTime.now();
    final category = CustomCategory(
      id: _uuid.v4(),
      name: name.trim(),
      description: description.trim(),
      iconName: iconName,
      colorHex: colorHex,
      createdAt: now,
      updatedAt: now,
    );

    // Save to persistence
    final updatedCategories = [...existingCategories, category];
    await _saveCustomCategories(updatedCategories);

    _logger.i('Created custom category: ${category.name}');
    return category;
  }

  /// Update an existing custom category
  Future<CustomCategory> updateCustomCategory(
    String categoryId, {
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    final categories = getCustomCategories();
    final categoryIndex = categories.indexWhere((cat) => cat.id == categoryId);

    if (categoryIndex == -1) {
      throw ArgumentError('Category not found');
    }

    // Validate name if provided
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('Category name cannot be empty');
    }

    // Check for duplicate names if name is being changed
    if (name != null) {
      final normalizedName = name.trim().toLowerCase();
      final existingCategory = categories.firstWhere(
        (cat) => cat.id == categoryId,
      );
      if (existingCategory.name.toLowerCase() != normalizedName &&
          categories.any((cat) => cat.name.toLowerCase() == normalizedName)) {
        throw ArgumentError('A category with this name already exists');
      }
    }

    // Update category
    final updatedCategory = categories[categoryIndex].copyWith(
      name: name?.trim(),
      description: description?.trim(),
      iconName: iconName,
      colorHex: colorHex,
      updatedAt: DateTime.now(),
    );

    categories[categoryIndex] = updatedCategory;
    await _saveCustomCategories(categories);

    _logger.i('Updated custom category: ${updatedCategory.name}');
    return updatedCategory;
  }

  /// Delete a custom category and all its associated sound groups
  Future<void> deleteCustomCategory(String categoryId) async {
    final categories = getCustomCategories();
    final categoryIndex = categories.indexWhere((cat) => cat.id == categoryId);

    if (categoryIndex == -1) {
      throw ArgumentError('Category not found');
    }

    final categoryName = categories[categoryIndex].name;

    // Remove the category
    categories.removeAt(categoryIndex);
    await _saveCustomCategories(categories);

    // Remove all associated sound groups
    final soundGroups = getSoundGroups();
    final updatedGroups = soundGroups
        .where((group) => group.customCategoryId != categoryId)
        .toList();
    await _saveSoundGroups(updatedGroups);

    _logger.i(
      'Deleted custom category: $categoryName and ${soundGroups.length - updatedGroups.length} associated sound groups',
    );
  }

  /// Get all sound groups
  List<SoundGroup> getSoundGroups() {
    try {
      final jsonString = _settingsBox.get(_soundGroupsKey, defaultValue: '[]');
      final List<dynamic> jsonList = jsonDecode(jsonString as String);
      return jsonList
          .map((json) => SoundGroup.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error loading sound groups: $e');
      return [];
    }
  }

  /// Get sound groups for a specific custom category
  List<SoundGroup> getSoundGroupsForCategory(String customCategoryId) {
    return getSoundGroups()
        .where((group) => group.customCategoryId == customCategoryId)
        .toList();
  }

  /// Get a single sound group by ID
  SoundGroup? getSoundGroupById(String groupId) {
    return getSoundGroups().where((group) => group.id == groupId).firstOrNull;
  }

  /// Save all sound groups
  Future<void> _saveSoundGroups(List<SoundGroup> groups) async {
    try {
      final jsonList = groups.map((group) => group.toJson()).toList();
      final jsonString = jsonEncode(jsonList);
      _settingsBox.put(_soundGroupsKey, jsonString);
      _logger.d('Saved ${groups.length} sound groups');
    } catch (e) {
      _logger.e('Error saving sound groups: $e');
      throw Exception('Failed to save sound groups: $e');
    }
  }

  /// Create a new sound group
  Future<SoundGroup> createSoundGroup({
    required String name,
    required String description,
    required String customCategoryId,
    required List<String> soundFilePaths,
    bool enableRandomization = true,
  }) async {
    // Validate input
    if (name.trim().isEmpty) {
      throw ArgumentError('Sound group name cannot be empty');
    }

    if (soundFilePaths.isEmpty) {
      throw ArgumentError('Sound group must contain at least one sound');
    }

    // Verify the custom category exists
    final categories = getCustomCategories();
    if (!categories.any((cat) => cat.id == customCategoryId)) {
      throw ArgumentError('Custom category not found');
    }

    // Check for duplicate names within the same category
    final existingGroups = getSoundGroupsForCategory(customCategoryId);
    final normalizedName = name.trim().toLowerCase();
    if (existingGroups.any(
      (group) => group.name.toLowerCase() == normalizedName,
    )) {
      throw ArgumentError(
        'A sound group with this name already exists in this category',
      );
    }

    // Create new sound group
    final now = DateTime.now();
    final group = SoundGroup(
      id: _uuid.v4(),
      name: name.trim(),
      description: description.trim(),
      soundFilePaths: soundFilePaths,
      customCategoryId: customCategoryId,
      enableRandomization: enableRandomization,
      createdAt: now,
      updatedAt: now,
    );

    // Save to persistence
    final allGroups = getSoundGroups();
    final updatedGroups = [...allGroups, group];
    await _saveSoundGroups(updatedGroups);

    _logger.i(
      'Created sound group: ${group.name} with ${soundFilePaths.length} sounds',
    );
    return group;
  }

  /// Update an existing sound group
  Future<SoundGroup> updateSoundGroup(
    String groupId, {
    String? name,
    String? description,
    List<String>? soundFilePaths,
    Map<String, SoundWeight>? soundWeights,
    bool? enableRandomization,
  }) async {
    final groups = getSoundGroups();
    final groupIndex = groups.indexWhere((group) => group.id == groupId);

    if (groupIndex == -1) {
      throw ArgumentError('Sound group not found');
    }

    final existingGroup = groups[groupIndex];

    // Validate name if provided
    if (name != null && name.trim().isEmpty) {
      throw ArgumentError('Sound group name cannot be empty');
    }

    // Check for duplicate names if name is being changed
    if (name != null) {
      final normalizedName = name.trim().toLowerCase();
      final existingGroups = getSoundGroupsForCategory(
        existingGroup.customCategoryId,
      );
      if (existingGroup.name.toLowerCase() != normalizedName &&
          existingGroups.any(
            (group) => group.name.toLowerCase() == normalizedName,
          )) {
        throw ArgumentError(
          'A sound group with this name already exists in this category',
        );
      }
    }

    // Validate sound files if provided
    if (soundFilePaths != null && soundFilePaths.isEmpty) {
      throw ArgumentError('Sound group must contain at least one sound');
    }

    // Update sound group
    final updatedGroup = existingGroup.copyWith(
      name: name?.trim(),
      description: description?.trim(),
      soundFilePaths: soundFilePaths,
      soundWeights: soundWeights,
      enableRandomization: enableRandomization,
      updatedAt: DateTime.now(),
    );

    groups[groupIndex] = updatedGroup;
    await _saveSoundGroups(groups);

    _logger.i('Updated sound group: ${updatedGroup.name}');
    return updatedGroup;
  }

  /// Delete a sound group
  Future<void> deleteSoundGroup(String groupId) async {
    final groups = getSoundGroups();
    final groupIndex = groups.indexWhere((group) => group.id == groupId);

    if (groupIndex == -1) {
      throw ArgumentError('Sound group not found');
    }

    final groupName = groups[groupIndex].name;
    groups.removeAt(groupIndex);
    await _saveSoundGroups(groups);

    _logger.i('Deleted sound group: $groupName');
  }

  /// Add sounds to an existing sound group
  Future<SoundGroup> addSoundsToGroup(
    String groupId,
    List<String> soundFilePaths,
  ) async {
    final groups = getSoundGroups();
    final groupIndex = groups.indexWhere((group) => group.id == groupId);

    if (groupIndex == -1) {
      throw ArgumentError('Sound group not found');
    }

    final existingGroup = groups[groupIndex];
    final updatedPaths = [...existingGroup.soundFilePaths];

    // Add new sounds (avoid duplicates)
    for (final path in soundFilePaths) {
      if (!updatedPaths.contains(path)) {
        updatedPaths.add(path);
      }
    }

    return updateSoundGroup(groupId, soundFilePaths: updatedPaths);
  }

  /// Remove sounds from an existing sound group
  Future<SoundGroup> removeSoundsFromGroup(
    String groupId,
    List<String> soundFilePaths,
  ) async {
    final groups = getSoundGroups();
    final groupIndex = groups.indexWhere((group) => group.id == groupId);

    if (groupIndex == -1) {
      throw ArgumentError('Sound group not found');
    }

    final existingGroup = groups[groupIndex];
    final updatedPaths = existingGroup.soundFilePaths
        .where((path) => !soundFilePaths.contains(path))
        .toList();

    if (updatedPaths.isEmpty) {
      throw ArgumentError('Cannot remove all sounds from a sound group');
    }

    return updateSoundGroup(groupId, soundFilePaths: updatedPaths);
  }

  /// Clear all custom categories and sound groups (useful for testing/reset)
  Future<void> clearAllCustomData() async {
    await _saveCustomCategories([]);
    await _saveSoundGroups([]);
    _logger.i('Cleared all custom categories and sound groups');
  }
}

/// Provider for the custom category service
final customCategoryServiceProvider = Provider<CustomCategoryService>((ref) {
  return CustomCategoryService();
});
