import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:path/path.dart' as path;

/// Utility class for parsing audio file metadata and display names
class AudioMetadataParser {
  static const Logger _logger = Logger('AudioMetadataParser');

  /// Extracts a display name from an audio file using metadata or filename parsing
  ///
  /// Priority order:
  /// 1. Try to read metadata (artist + title from FLAC/MP3)
  /// 2. Fall back to filename parsing for format "Artist - Title - Extra.extension"
  /// 3. Fall back to filename without extension
  static Future<String> getDisplayName(String filePath) async {
    try {
      // First, try to read metadata from the audio file
      final metadataDisplayName = await _readMetadata(filePath);
      if (metadataDisplayName != null && metadataDisplayName.isNotEmpty) {
        _logger.d('Using metadata display name: $metadataDisplayName');
        return metadataDisplayName;
      }

      // Fall back to filename parsing
      final filenameDisplayName = _parseFilename(filePath);
      _logger.d('Using filename display name: $filenameDisplayName');
      return filenameDisplayName;
    } catch (e) {
      _logger.w('Error parsing metadata for $filePath: $e');
      return _parseFilename(filePath);
    }
  }

  /// Reads metadata from audio file (FLAC, MP3, etc.)
  /// Returns "Artist - Title" if both are available, otherwise null
  static Future<String?> _readMetadata(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        _logger.w('File does not exist: $filePath');
        return null;
      }

      // Check if file extension is supported for metadata reading
      final extension = filePath.toLowerCase().split('.').last;
      if (!['mp3', 'flac', 'ogg', 'm4a', 'aac'].contains(extension)) {
        _logger.d('Unsupported file type for metadata: $extension');
        return null;
      }

      final metadata = await readMetadata(file, getImage: false);

      // Try different common property names for artist and title
      String? artist;
      String? title;

      // Common patterns for accessing metadata properties
      try {
        // Try accessing as properties (most likely)
        artist =
            (metadata as dynamic).artist ?? (metadata as dynamic).albumArtist;
        title = (metadata as dynamic).title ?? (metadata as dynamic).trackName;
      } catch (e) {
        _logger.d('Could not access metadata properties directly: $e');
      }

      if (artist != null &&
          artist.isNotEmpty &&
          title != null &&
          title.isNotEmpty) {
        return '$artist - $title';
      } else if (title != null && title.isNotEmpty) {
        return title;
      } else if (artist != null && artist.isNotEmpty) {
        return artist;
      }

      return null;
    } catch (e) {
      _logger.w('Failed to read metadata from $filePath: $e');
      return null;
    }
  }

  /// Parses filename for display name using various patterns
  ///
  /// Supports formats like:
  /// - "Artist - Title - Extra.flac" -> "Artist - Title"
  /// - "Artist - Title.mp3" -> "Artist - Title"
  /// - "SongName.flac" -> "SongName"
  static String _parseFilename(String filePath) {
    try {
      // Get filename without path and extension using proper path utilities
      final nameWithoutExtension = path.basenameWithoutExtension(filePath);

      // Try to parse format "Artist - Title - Extra" or "Artist - Title"
      if (nameWithoutExtension.contains(' - ')) {
        final parts = nameWithoutExtension.split(' - ');
        if (parts.length >= 2) {
          // Take first two parts: "Artist - Title"
          return '${parts[0].trim()} - ${parts[1].trim()}';
        }
      }

      // Fall back to filename without extension, cleaned up
      return nameWithoutExtension.trim();
    } catch (e) {
      _logger.w('Failed to parse filename $filePath: $e');
      // Ultimate fallback - just return filename without extension
      try {
        return path.basenameWithoutExtension(filePath);
      } catch (e2) {
        // Last resort fallback
        String filename = filePath;
        if (filename.contains('/')) {
          filename = filename.split('/').last;
        }
        if (filename.contains('\\')) {
          filename = filename.split('\\').last;
        }
        return filename.contains('.')
            ? filename.substring(0, filename.lastIndexOf('.'))
            : filename;
      }
    }
  }

  /// Validates if a file is a supported audio format for metadata reading
  static bool isSupportedAudioFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return ['mp3', 'flac', 'ogg', 'm4a', 'aac'].contains(extension);
  }

  /// Creates a sanitized display name from raw text
  /// Removes special characters and normalizes spacing
  static String sanitizeDisplayName(String rawName) {
    return rawName
        .replaceAll(
          RegExp(r'[^\w\s\-]'),
          '',
        ) // Remove special chars except dash
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }
}

// Contains AI-generated edits.
