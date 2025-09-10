import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/custom_category_file_service.dart';
import 'package:soundboard/core/models/custom_category_file.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Provider for getting files in a specific custom category
final customCategoryFilesProvider =
    FutureProvider.family<List<CustomCategoryFile>, String>((
      ref,
      customCategoryId,
    ) async {
      const logger = Logger('CustomCategoryFilesProvider');

      try {
        logger.d('Loading files for custom category: $customCategoryId');
        final files = await CustomCategoryFileService.getFilesForCustomCategory(
          customCategoryId,
        );

        final customCategoryFiles = files
            .map((file) => CustomCategoryFile.fromFile(file, customCategoryId))
            .toList();

        // Sort by name for consistent display
        customCategoryFiles.sort((a, b) => a.fileName.compareTo(b.fileName));

        logger.d(
          'Found ${customCategoryFiles.length} files for custom category $customCategoryId',
        );
        return customCategoryFiles;
      } catch (e) {
        logger.e(
          'Error loading files for custom category $customCategoryId: $e',
        );
        throw Exception('Failed to load files for custom category: $e');
      }
    });

/// Provider for getting file count in a specific custom category
final customCategoryFileCountProvider = FutureProvider.family<int, String>((
  ref,
  customCategoryId,
) async {
  try {
    return await CustomCategoryFileService.getFileCount(customCategoryId);
  } catch (e) {
    const Logger(
      'CustomCategoryFileCountProvider',
    ).e('Error getting file count for custom category $customCategoryId: $e');
    return 0;
  }
});

/// Notifier for managing custom category files with reactive updates
class CustomCategoryFilesNotifier
    extends StateNotifier<Map<String, AsyncValue<List<CustomCategoryFile>>>> {
  CustomCategoryFilesNotifier() : super({});

  static const Logger _logger = Logger('CustomCategoryFilesNotifier');

  /// Refresh files for a specific custom category
  Future<void> refreshCategory(String customCategoryId) async {
    _logger.d('Refreshing files for custom category: $customCategoryId');

    // Set loading state
    state = {...state, customCategoryId: const AsyncValue.loading()};

    try {
      final files = await CustomCategoryFileService.getFilesForCustomCategory(
        customCategoryId,
      );
      final customCategoryFiles = files
          .map((file) => CustomCategoryFile.fromFile(file, customCategoryId))
          .toList();

      // Sort by name for consistent display
      customCategoryFiles.sort((a, b) => a.fileName.compareTo(b.fileName));

      // Update state with new files
      state = {
        ...state,
        customCategoryId: AsyncValue.data(customCategoryFiles),
      };

      _logger.d(
        'Refreshed ${customCategoryFiles.length} files for custom category $customCategoryId',
      );
    } catch (e) {
      _logger.e(
        'Error refreshing files for custom category $customCategoryId: $e',
      );
      state = {
        ...state,
        customCategoryId: AsyncValue.error(e, StackTrace.current),
      };
    }
  }

  /// Delete a file from a custom category
  Future<bool> deleteFile(String customCategoryId, String fileName) async {
    _logger.d('Deleting file $fileName from custom category $customCategoryId');

    try {
      final success =
          await CustomCategoryFileService.deleteFileFromCustomCategory(
            customCategoryId,
            fileName,
          );

      if (success) {
        // Refresh the category to update the UI
        await refreshCategory(customCategoryId);
        _logger.d('Successfully deleted file $fileName');
      } else {
        _logger.w('Failed to delete file $fileName');
      }

      return success;
    } catch (e) {
      _logger.e(
        'Error deleting file $fileName from custom category $customCategoryId: $e',
      );
      return false;
    }
  }

  /// Get files for a category (returns cached if available, otherwise loads)
  AsyncValue<List<CustomCategoryFile>>? getFilesForCategory(
    String customCategoryId,
  ) {
    return state[customCategoryId];
  }

  /// Delete all files from a custom category
  Future<bool> deleteAllFiles(String customCategoryId) async {
    _logger.d('Deleting all files for custom category: $customCategoryId');
    try {
      final success =
          await CustomCategoryFileService.deleteAllFilesForCustomCategory(
            customCategoryId,
          );
      if (success) {
        // Clear cache for this category
        clearCategory(customCategoryId);
        _logger.i('Deleted all files for custom category: $customCategoryId');
      }
      return success;
    } catch (e) {
      _logger.e(
        'Error deleting all files for custom category $customCategoryId: $e',
      );
      return false;
    }
  }

  /// Clear cache for a specific category
  void clearCategory(String customCategoryId) {
    final newState = Map<String, AsyncValue<List<CustomCategoryFile>>>.from(
      state,
    );
    newState.remove(customCategoryId);
    state = newState;
    _logger.d('Cleared cache for custom category: $customCategoryId');
  }

  /// Clear all cached files
  void clearAll() {
    state = {};
    _logger.d('Cleared all custom category file cache');
  }
}

/// Provider for the custom category files notifier
final customCategoryFilesNotifierProvider =
    StateNotifierProvider<
      CustomCategoryFilesNotifier,
      Map<String, AsyncValue<List<CustomCategoryFile>>>
    >((ref) {
      return CustomCategoryFilesNotifier();
    });
