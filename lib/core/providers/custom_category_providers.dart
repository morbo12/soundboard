import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/custom_category.dart';
import 'package:soundboard/core/models/sound_group.dart';
import 'package:soundboard/core/services/custom_category_service.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Provider for custom categories list
final customCategoriesProvider =
    StateNotifierProvider<
      CustomCategoriesNotifier,
      AsyncValue<List<CustomCategory>>
    >((ref) {
      final service = ref.watch(customCategoryServiceProvider);
      return CustomCategoriesNotifier(service);
    });

/// Notifier for managing custom categories state
class CustomCategoriesNotifier
    extends StateNotifier<AsyncValue<List<CustomCategory>>> {
  final CustomCategoryService _service;
  final Logger _logger = const Logger('CustomCategoriesNotifier');

  CustomCategoriesNotifier(this._service) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  /// Load all custom categories
  Future<void> loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final categories = _service.getCustomCategories();
      state = AsyncValue.data(categories);
      _logger.d('Loaded ${categories.length} custom categories');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      _logger.e('Error loading custom categories: $error');
    }
  }

  /// Create a new custom category
  Future<CustomCategory?> createCategory({
    required String name,
    required String description,
    String iconName = 'music_note',
    String colorHex = '#9C27B0',
  }) async {
    try {
      final category = await _service.createCustomCategory(
        name: name,
        description: description,
        iconName: iconName,
        colorHex: colorHex,
      );

      // Reload the list to update state
      await loadCategories();

      _logger.i('Created custom category: ${category.name}');
      return category;
    } catch (error) {
      _logger.e('Error creating custom category: $error');
      // Don't update state on error, let the UI handle the error
      rethrow;
    }
  }

  /// Update an existing custom category
  Future<CustomCategory?> updateCategory(
    String categoryId, {
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
  }) async {
    try {
      final category = await _service.updateCustomCategory(
        categoryId,
        name: name,
        description: description,
        iconName: iconName,
        colorHex: colorHex,
      );

      // Reload the list to update state
      await loadCategories();

      _logger.i('Updated custom category: ${category.name}');
      return category;
    } catch (error) {
      _logger.e('Error updating custom category: $error');
      rethrow;
    }
  }

  /// Delete a custom category
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _service.deleteCustomCategory(categoryId);

      // Reload the list to update state
      await loadCategories();

      _logger.i('Deleted custom category: $categoryId');
    } catch (error) {
      _logger.e('Error deleting custom category: $error');
      rethrow;
    }
  }

  /// Refresh categories from storage
  Future<void> refresh() async {
    await loadCategories();
  }
}

/// Provider for sound groups of a specific custom category
final soundGroupsProvider =
    StateNotifierProvider.family<
      SoundGroupsNotifier,
      AsyncValue<List<SoundGroup>>,
      String
    >((ref, customCategoryId) {
      final service = ref.watch(customCategoryServiceProvider);
      return SoundGroupsNotifier(service, customCategoryId);
    });

/// Notifier for managing sound groups state for a specific category
class SoundGroupsNotifier extends StateNotifier<AsyncValue<List<SoundGroup>>> {
  final CustomCategoryService _service;
  final String _customCategoryId;
  final Logger _logger = const Logger('SoundGroupsNotifier');

  SoundGroupsNotifier(this._service, this._customCategoryId)
    : super(const AsyncValue.loading()) {
    loadSoundGroups();
  }

  /// Load sound groups for the category
  Future<void> loadSoundGroups() async {
    try {
      state = const AsyncValue.loading();
      final groups = _service.getSoundGroupsForCategory(_customCategoryId);
      state = AsyncValue.data(groups);
      _logger.d(
        'Loaded ${groups.length} sound groups for category $_customCategoryId',
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      _logger.e('Error loading sound groups: $error');
    }
  }

  /// Create a new sound group
  Future<SoundGroup?> createSoundGroup({
    required String name,
    required String description,
    required List<String> soundFilePaths,
    bool enableRandomization = true,
  }) async {
    try {
      final group = await _service.createSoundGroup(
        name: name,
        description: description,
        customCategoryId: _customCategoryId,
        soundFilePaths: soundFilePaths,
        enableRandomization: enableRandomization,
      );

      // Reload the list to update state
      await loadSoundGroups();

      _logger.i('Created sound group: ${group.name}');
      return group;
    } catch (error) {
      _logger.e('Error creating sound group: $error');
      rethrow;
    }
  }

  /// Update an existing sound group
  Future<SoundGroup?> updateSoundGroup(
    String groupId, {
    String? name,
    String? description,
    List<String>? soundFilePaths,
    Map<String, SoundWeight>? soundWeights,
    bool? enableRandomization,
  }) async {
    try {
      final group = await _service.updateSoundGroup(
        groupId,
        name: name,
        description: description,
        soundFilePaths: soundFilePaths,
        soundWeights: soundWeights,
        enableRandomization: enableRandomization,
      );

      // Reload the list to update state
      await loadSoundGroups();

      _logger.i('Updated sound group: ${group.name}');
      return group;
    } catch (error) {
      _logger.e('Error updating sound group: $error');
      rethrow;
    }
  }

  /// Delete a sound group
  Future<void> deleteSoundGroup(String groupId) async {
    try {
      await _service.deleteSoundGroup(groupId);

      // Reload the list to update state
      await loadSoundGroups();

      _logger.i('Deleted sound group: $groupId');
    } catch (error) {
      _logger.e('Error deleting sound group: $error');
      rethrow;
    }
  }

  /// Add sounds to an existing sound group
  Future<void> addSoundsToGroup(
    String groupId,
    List<String> soundFilePaths,
  ) async {
    try {
      await _service.addSoundsToGroup(groupId, soundFilePaths);
      await loadSoundGroups();
      _logger.i('Added ${soundFilePaths.length} sounds to group $groupId');
    } catch (error) {
      _logger.e('Error adding sounds to group: $error');
      rethrow;
    }
  }

  /// Remove sounds from an existing sound group
  Future<void> removeSoundsFromGroup(
    String groupId,
    List<String> soundFilePaths,
  ) async {
    try {
      await _service.removeSoundsFromGroup(groupId, soundFilePaths);
      await loadSoundGroups();
      _logger.i('Removed ${soundFilePaths.length} sounds from group $groupId');
    } catch (error) {
      _logger.e('Error removing sounds from group: $error');
      rethrow;
    }
  }

  /// Refresh sound groups from storage
  Future<void> refresh() async {
    await loadSoundGroups();
  }
}

/// Provider for all sound groups across all custom categories
final allSoundGroupsProvider =
    StateNotifierProvider<AllSoundGroupsNotifier, AsyncValue<List<SoundGroup>>>(
      (ref) {
        final service = ref.watch(customCategoryServiceProvider);
        return AllSoundGroupsNotifier(service);
      },
    );

/// Notifier for managing all sound groups
class AllSoundGroupsNotifier
    extends StateNotifier<AsyncValue<List<SoundGroup>>> {
  final CustomCategoryService _service;
  final Logger _logger = const Logger('AllSoundGroupsNotifier');

  AllSoundGroupsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadAllSoundGroups();
  }

  /// Load all sound groups
  Future<void> loadAllSoundGroups() async {
    try {
      state = const AsyncValue.loading();
      final groups = _service.getSoundGroups();
      state = AsyncValue.data(groups);
      _logger.d('Loaded ${groups.length} total sound groups');
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      _logger.e('Error loading all sound groups: $error');
    }
  }

  /// Refresh all sound groups from storage
  Future<void> refresh() async {
    await loadAllSoundGroups();
  }
}
