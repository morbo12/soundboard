import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

class GridJingleConfig {
  final String id;
  final String? displayName;
  final String? filePath;
  final AudioCategory? category;
  final bool isCategoryOnly;
  final String? customCategoryId;

  GridJingleConfig({
    required this.id,
    this.displayName,
    this.filePath,
    this.category,
    this.isCategoryOnly = false,
    this.customCategoryId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'filePath': filePath,
    'category': category?.toString(),
    'isCategoryOnly': isCategoryOnly,
    'customCategoryId': customCategoryId,
  };

  factory GridJingleConfig.fromJson(Map<String, dynamic> json) {
    return GridJingleConfig(
      id: json['id'],
      displayName: json['displayName'],
      filePath: json['filePath'],
      category: json['category'] != null
          ? AudioCategory.values.firstWhere(
              (e) => e.toString() == json['category'],
              orElse: () => AudioCategory.genericJingle,
            )
          : null,
      isCategoryOnly: json['isCategoryOnly'] ?? false,
      customCategoryId: json['customCategoryId'],
    );
  }

  Future<AudioFile?> toAudioFile() async {
    // Handle empty buttons with display names but no category
    if (category == null) {
      if (displayName != null) {
        // Return a special AudioFile for empty buttons so they display but don't play
        return AudioFile(
          displayName: displayName!,
          filePath: '', // Empty file path indicates this is an empty button
          audioCategory: AudioCategory.genericJingle, // Placeholder category
          isCategoryOnly: false, // This will help us identify it as empty
        );
      }
      return null;
    }

    if (displayName == null) return null;

    // Check if this is a sound group (has special filePath prefix)
    if (filePath != null && filePath!.startsWith('custom_group:')) {
      return AudioFile(
        displayName: displayName!,
        filePath: filePath!,
        audioCategory: category!,
        isCategoryOnly: true,
      );
    }

    if (isCategoryOnly) {
      // For category-only mode with custom category, reconstruct the special filePath
      if (customCategoryId != null) {
        return AudioFile(
          displayName: displayName!,
          filePath: 'custom_category:$customCategoryId',
          audioCategory: category!,
          isCategoryOnly: true,
        );
      }

      // For predefined category-only mode, we don't need a specific file path
      return AudioFile(
        displayName: displayName!,
        filePath: '', // Empty as we'll use the category for playback
        audioCategory: category!,
        isCategoryOnly: true,
      );
    } else if (filePath == null) {
      return null; // For specific jingle mode, we need a file path
    }

    // For specific file mode, the filePath should contain either:
    // 1. A full file path (if already resolved)
    // 2. Just a filename (which needs to be resolved by the AudioManager)
    return AudioFile(
      displayName: displayName!,
      filePath: filePath!, // AudioManager will handle filename resolution
      audioCategory: category!,
      isCategoryOnly: false,
    );
  }

  static GridJingleConfig? fromAudioFile(AudioFile? file) {
    if (file == null) return null;

    // Extract custom category ID from special filePath format
    String? customCategoryId;
    String? actualFilePath = file.filePath;

    if (file.filePath.startsWith('custom_category:')) {
      customCategoryId = file.filePath.substring('custom_category:'.length);
      actualFilePath = null; // Clear the special filePath for storage
    } else if (file.filePath.startsWith('custom_group:')) {
      // For sound groups, keep the special filePath as-is
      actualFilePath = file.filePath;
    } else if (file.isCategoryOnly) {
      actualFilePath = null;
    }

    return GridJingleConfig(
      id: file.displayName,
      displayName: file.displayName,
      filePath: actualFilePath,
      category: file.audioCategory,
      isCategoryOnly: file.isCategoryOnly,
      customCategoryId: customCategoryId,
    );
  }
}
