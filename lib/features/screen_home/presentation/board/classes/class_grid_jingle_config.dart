import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

class GridJingleConfig {
  final String id;
  final String? displayName;
  final String? filePath;
  final AudioCategory? category;
  final bool isCategoryOnly;

  GridJingleConfig({
    required this.id,
    this.displayName,
    this.filePath,
    this.category,
    this.isCategoryOnly = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'displayName': displayName,
    'filePath': filePath,
    'category': category?.toString(),
    'isCategoryOnly': isCategoryOnly,
  };

  factory GridJingleConfig.fromJson(Map<String, dynamic> json) {
    return GridJingleConfig(
      id: json['id'],
      displayName: json['displayName'],
      filePath: json['filePath'],
      category:
          json['category'] != null
              ? AudioCategory.values.firstWhere(
                (e) => e.toString() == json['category'],
                orElse: () => AudioCategory.genericJingle,
              )
              : null,
      isCategoryOnly: json['isCategoryOnly'] ?? false,
    );
  }

  AudioFile? toAudioFile() {
    if (category == null || displayName == null) return null;

    if (isCategoryOnly) {
      // For category-only mode, we don't need a specific file path
      return AudioFile(
        displayName: displayName!,
        filePath: '', // Empty as we'll use the category for playback
        audioCategory: category!,
        isCategoryOnly: true,
      );
    } else if (filePath == null) {
      return null; // For specific jingle mode, we need a file path
    }

    return AudioFile(
      displayName: displayName!,
      filePath: filePath!,
      audioCategory: category!,
      isCategoryOnly: false,
    );
  }

  static GridJingleConfig? fromAudioFile(AudioFile? file) {
    if (file == null) return null;
    return GridJingleConfig(
      id: file.displayName,
      displayName: file.displayName,
      filePath: file.isCategoryOnly ? null : file.filePath,
      category: file.audioCategory,
      isCategoryOnly: file.isCategoryOnly,
    );
  }
}
