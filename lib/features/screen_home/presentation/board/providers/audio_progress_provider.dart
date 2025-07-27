import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

/// Provider to track which jingle is currently playing
final currentPlayingJingleProvider = StateProvider<AudioFile?>((ref) {
  return null;
});

/// Provider to track the current channel that's playing a jingle
final currentJingleChannelProvider = StateProvider<int?>((ref) {
  return null; // 1 for channel1, 2 for channel2
});

/// Provider to track which specific button was pressed (for category-only buttons)
/// This helps distinguish between multiple buttons that share the same category
final lastPressedButtonProvider = StateProvider<AudioFile?>((ref) {
  return null;
});

/// Provider to track if a specific jingle is currently playing
/// This works for both specific jingle buttons and category-only (random) buttons
final isJinglePlayingProvider = Provider.family<bool, AudioFile?>((
  ref,
  jingle,
) {
  if (jingle == null) return false;

  final currentJingle = ref.watch(currentPlayingJingleProvider);
  if (currentJingle == null) return false;

  // For category-only buttons (random buttons), check if:
  // 1. The currently playing jingle belongs to the same category AND
  // 2. This specific button was the one that was pressed
  if (jingle.isCategoryOnly) {
    final lastPressedButton = ref.watch(lastPressedButtonProvider);
    return currentJingle.audioCategory == jingle.audioCategory &&
        lastPressedButton != null &&
        lastPressedButton.audioCategory == jingle.audioCategory &&
        lastPressedButton.displayName == jingle.displayName;
  }

  // For specific jingle buttons, compare by filePath and displayName for robust matching
  final isPlaying =
      currentJingle.filePath == jingle.filePath ||
      (currentJingle.displayName == jingle.displayName &&
          currentJingle.audioCategory == jingle.audioCategory);

  return isPlaying;
});

// Contains AI-generated edits.
