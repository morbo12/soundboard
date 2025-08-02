import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:soundboard/core/utils/audio_metadata_parser.dart';

/// Represents a music file with metadata
@immutable
class MusicFile {
  final String name;
  final String filePath;
  final int fileSizeBytes;
  final DateTime lastModified;
  final String? title;
  final String? artist;
  final String? album;
  final Duration? duration;

  const MusicFile({
    required this.name,
    required this.filePath,
    required this.fileSizeBytes,
    required this.lastModified,
    this.title,
    this.artist,
    this.album,
    this.duration,
  });

  /// Creates a MusicFile from a File object
  factory MusicFile.fromFile(File file) {
    final stats = file.statSync();
    final name = Platform.isWindows
        ? file.path.split('\\').last
        : file.path.split('/').last;

    return MusicFile(
      name: name,
      filePath: file.path,
      fileSizeBytes: stats.size,
      lastModified: stats.modified,
    );
  }

  /// Creates a MusicFile from a File object with metadata
  static Future<MusicFile> fromFileWithMetadata(File file) async {
    final stats = file.statSync();
    final name = Platform.isWindows
        ? file.path.split('\\').last
        : file.path.split('/').last;

    try {
      final displayName = await AudioMetadataParser.getDisplayName(file.path);

      return MusicFile(
        name: name,
        filePath: file.path,
        fileSizeBytes: stats.size,
        lastModified: stats.modified,
        title: displayName,
        artist:
            null, // We could extend AudioMetadataParser to return more details
        album: null,
        duration: null,
      );
    } catch (e) {
      // If metadata reading fails, create without metadata
      return MusicFile(
        name: name,
        filePath: file.path,
        fileSizeBytes: stats.size,
        lastModified: stats.modified,
      );
    }
  }

  /// Returns the display name (title if available, otherwise filename)
  String get displayName =>
      title?.isNotEmpty == true ? title! : nameWithoutExtension;

  /// Returns the filename without extension
  String get nameWithoutExtension {
    final dotIndex = name.lastIndexOf('.');
    return dotIndex != -1 ? name.substring(0, dotIndex) : name;
  }

  /// Returns the file size in megabytes
  double get fileSizeMB => fileSizeBytes / 1024 / 1024;

  /// Returns the file extension
  String get extension {
    final dotIndex = name.lastIndexOf('.');
    return dotIndex != -1 ? name.substring(dotIndex + 1).toLowerCase() : '';
  }

  /// Checks if the file extension is supported
  bool get isSupported {
    const supportedExtensions = ['mp3', 'flac', 'wav', 'm4a', 'ogg'];
    return supportedExtensions.contains(extension);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicFile &&
        other.name == name &&
        other.filePath == filePath;
  }

  @override
  int get hashCode => name.hashCode ^ filePath.hashCode;

  @override
  String toString() {
    return 'MusicFile(name: $name, path: $filePath, size: ${fileSizeMB.toStringAsFixed(2)}MB)';
  }
}

/// Represents the current state of music playback
@immutable
class MusicPlaybackState {
  final bool isPlaying;
  final bool isPaused;
  final Duration currentPosition;
  final Duration totalDuration;
  final MusicFile? currentTrack;
  final int currentTrackIndex;
  final List<MusicFile> playlist;
  final double volume;
  final bool isShuffleEnabled;
  final bool isRepeatEnabled;

  const MusicPlaybackState({
    this.isPlaying = false,
    this.isPaused = false,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.currentTrack,
    this.currentTrackIndex = -1,
    this.playlist = const [],
    this.volume = 1.0,
    this.isShuffleEnabled = false,
    this.isRepeatEnabled = false,
  });

  /// Creates a copy of this state with updated fields
  MusicPlaybackState copyWith({
    bool? isPlaying,
    bool? isPaused,
    Duration? currentPosition,
    Duration? totalDuration,
    MusicFile? currentTrack,
    int? currentTrackIndex,
    List<MusicFile>? playlist,
    double? volume,
    bool? isShuffleEnabled,
    bool? isRepeatEnabled,
  }) {
    return MusicPlaybackState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      currentTrack: currentTrack ?? this.currentTrack,
      currentTrackIndex: currentTrackIndex ?? this.currentTrackIndex,
      playlist: playlist ?? this.playlist,
      volume: volume ?? this.volume,
      isShuffleEnabled: isShuffleEnabled ?? this.isShuffleEnabled,
      isRepeatEnabled: isRepeatEnabled ?? this.isRepeatEnabled,
    );
  }

  /// Returns the progress as a value between 0.0 and 1.0
  double get progress {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// Returns true if there is a track currently loaded
  bool get hasTrack => currentTrack != null;

  /// Returns true if there is a next track in the playlist
  bool get hasNext => currentTrackIndex < playlist.length - 1;

  /// Returns true if there is a previous track in the playlist
  bool get hasPrevious => currentTrackIndex > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MusicPlaybackState &&
        other.isPlaying == isPlaying &&
        other.isPaused == isPaused &&
        other.currentPosition == currentPosition &&
        other.totalDuration == totalDuration &&
        other.currentTrack == currentTrack &&
        other.currentTrackIndex == currentTrackIndex &&
        listEquals(other.playlist, playlist) &&
        other.volume == volume &&
        other.isShuffleEnabled == isShuffleEnabled &&
        other.isRepeatEnabled == isRepeatEnabled;
  }

  @override
  int get hashCode {
    return Object.hash(
      isPlaying,
      isPaused,
      currentPosition,
      totalDuration,
      currentTrack,
      currentTrackIndex,
      playlist,
      volume,
      isShuffleEnabled,
      isRepeatEnabled,
    );
  }

  @override
  String toString() {
    return 'MusicPlaybackState(isPlaying: $isPlaying, currentTrack: ${currentTrack?.name}, progress: ${(progress * 100).toStringAsFixed(1)}%)';
  }
}

// Contains AI-generated edits.
