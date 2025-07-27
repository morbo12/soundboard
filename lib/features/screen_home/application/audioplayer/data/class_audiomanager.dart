// ignore_for_file: unused_import

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:soundboard/core/constants/globals.dart';
import 'package:soundboard/core/providers/volume_providers.dart';
import 'package:soundboard/core/utils/providers.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/player_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_home/presentation/board/providers/audio_progress_provider.dart';

/// Enum representing the available audio channels
enum AudioChannel { channel1, channel2 }

/// Manages audio playback with dual-channel support, fading effects,
/// and various playback strategies.
class AudioManager {
  final Logger logger = const Logger('AudioManager');

  /// List of all available audio files
  final List<AudioFile> audioInstances = [];

  /// Tracks the current play index for sequential playback by category
  final Map<AudioCategory, int> _currentPlayIndex = {};

  /// Number of recently played songs to remember (to avoid repetition)
  static const int _memorySize = 10;

  /// Queue of recently played songs by category
  final Map<AudioCategory, Queue<String>> _recentlyPlayed = {};

  /// Primary audio channel
  AudioPlayer channel1 = AudioPlayer();

  /// Secondary audio channel
  AudioPlayer channel2 = AudioPlayer();

  /// Fade duration constants
  static const int _shortFadeDuration = 10;
  static const int _longFadeDuration = 300;

  /// Constructor initializes audio channels with default volumes
  AudioManager() {
    try {
      channel1.setVolume(SettingsBox().c1InitialVolume);
      channel2.setVolume(SettingsBox().c2InitialVolume);
    } catch (e) {
      logger.e("Error initializing audio channels: $e");
    }
  }

  /// Adds an audio file to the available instances
  void addInstance(AudioFile audioInstance) =>
      audioInstances.add(audioInstance);

  /// Stops all audio playback with fade effect
  Future<void> stopAll(WidgetRef ref) async {
    try {
      await _fadeAndStop(ref, AudioChannel.channel1);
      await _fadeAndStop(ref, AudioChannel.channel2);

      // Clear progress tracking when stopping all audio
      ref.read(currentPlayingJingleProvider.notifier).state = null;
      ref.read(currentJingleChannelProvider.notifier).state = null;
      ref.read(lastPressedButtonProvider.notifier).state = null;
    } catch (e) {
      logger.e("Error stopping all audio", e.toString());
    }
  }

  /// Fades out a channel without stopping playback
  Future<void> fadeOutNoStop(WidgetRef ref, AudioChannel channel) async {
    try {
      await _fadeNoStop(ref, channel);
    } catch (e) {
      logger.e("Error fading out channel ${channel.name}: $e");
    }
  }

  /// Internal method to fade a channel without stopping
  Future<void> _fadeNoStop(
    WidgetRef ref,
    AudioChannel channel, {
    int fadeDuration = _longFadeDuration,
  }) async {
    await _fadeChannel(ref, channel, 0.0, fadeDuration);
  }

  /// Internal method to fade out and stop a channel
  Future<void> _fadeAndStop(
    WidgetRef ref,
    AudioChannel channel, {
    int fadeDuration = _longFadeDuration,
  }) async {
    try {
      await _fadeChannel(ref, channel, 0.0, fadeDuration);
      await _stopChannel(channel);
    } catch (e) {
      logger.e("Error in fade and stop for channel ${channel.name}: $e");
    }
  }

  /// Fades a channel's volume to the specified level
  Future<void> _fadeChannel(
    WidgetRef ref,
    AudioChannel channel,
    double to,
    int duration,
  ) async {
    try {
      final fade = Fade(ref);
      final player = channel == AudioChannel.channel1 ? channel1 : channel2;
      final provider = channel == AudioChannel.channel1
          ? c1VolumeProvider
          : c2VolumeProvider;
      logger.d(
        "[_fadeChannel] Fading channel ${channel.name} duration $duration",
      );
      await fade.fade(
        to: to,
        duration: duration,
        channel: player,
        provider: provider,
      );
    } catch (e) {
      logger.e("Error fading channel ${channel.name}: $e");
    }
  }

  /// Stops and releases a channel
  Future<void> _stopChannel(AudioChannel channel) async {
    try {
      final player = channel == AudioChannel.channel1 ? channel1 : channel2;
      await player.stop();
      await player.release();
    } catch (e) {
      logger.e("Error stopping channel ${channel.name}: $e");
    }
  }

  /// Plays an audio file on the specified channel
  Future<void> _playAudioFile(
    WidgetRef ref,
    AudioChannel channel, // the channel to play on
    String filePath, {
    required int fadeDuration,
    bool isBackgroundMusic = false,
    AudioFile? audioFile, // Track which jingle is playing
  }) async {
    try {
      final otherChannel = channel == AudioChannel.channel1
          ? AudioChannel.channel2
          : AudioChannel.channel1;

      await _setChannelVolume(ref, channel, 0.0);
      logger.d("Fading and stopping channel ${otherChannel.name}");
      _fadeAndStop(ref, otherChannel, fadeDuration: fadeDuration);
      logger.d("After _fadeAndStop");

      final player = channel == AudioChannel.channel1 ? channel1 : channel2;

      // Update providers to track currently playing jingle
      if (audioFile != null && !isBackgroundMusic) {
        ref.read(currentPlayingJingleProvider.notifier).state = audioFile;
        ref.read(currentJingleChannelProvider.notifier).state =
            channel == AudioChannel.channel1 ? 1 : 2;

        // Clear tracking when playback completes
        player.onPlayerComplete.listen((_) {
          ref.read(currentPlayingJingleProvider.notifier).state = null;
          ref.read(currentJingleChannelProvider.notifier).state = null;
          ref.read(lastPressedButtonProvider.notifier).state = null;
        });
      }

      await player.play(DeviceFileSource(filePath));

      if (isBackgroundMusic) {
        // Fade down to background music level
        await _fadeChannel(
          ref,
          channel,
          SettingsBox().backgroundVolumeLevel,
          fadeDuration,
        );

        // Set up a listener for when the background music ends
        player.onPlayerComplete.listen((_) async {
          await _setChannelVolume(ref, channel, 0.0);
        });
      } else {
        // Fade in to full volume
        await _fadeChannel(ref, channel, 1.0, fadeDuration);
      }
    } catch (e) {
      logger.e("Error playing audio file: $e");
    }
  }

  /// Resets the sequential playback index for a category
  void resetSequentialIndex(AudioCategory category) {
    _currentPlayIndex[category] = 0;
  }

  /// Resets all sequential playback indices
  void resetAllSequentialIndices() {
    _currentPlayIndex.clear();
  }

  /// Sets the volume for a specific channel
  Future<void> _setChannelVolume(
    WidgetRef ref,
    AudioChannel channel,
    double volume,
  ) async {
    try {
      final player = channel == AudioChannel.channel1 ? channel1 : channel2;
      logger.d("Setting volume to $volume for channel ${channel.name}");
      await player.setVolume(volume);

      final provider = channel == AudioChannel.channel1
          ? c1VolumeProvider
          : c2VolumeProvider;
      ref.read(provider.notifier).updateVolume(volume);
    } catch (e) {
      logger.e("Error setting channel volume: $e");
    }
  }

  /// Plays audio from a specific category with various playback options
  Future<void> playAudio(
    AudioCategory category,
    WidgetRef ref, {
    bool random = false,
    bool sequential = false,
    bool shortFade = true,
    bool isBackgroundMusic = false,
  }) async {
    try {
      final categoryInstances = audioInstances
          .where((instance) => instance.audioCategory == category)
          .toList();

      if (categoryInstances.isEmpty) return;

      late AudioFile audioFile;

      if (random) {
        audioFile = _selectRandomAudioFile(category, categoryInstances);
      } else if (sequential) {
        audioFile = _selectSequentialAudioFile(category, categoryInstances);
      } else {
        audioFile = categoryInstances[0];
      }

      final channel = isBackgroundMusic
          ? AudioChannel.channel1
          : _getAvailableChannel();

      final fadeDuration = shortFade ? _shortFadeDuration : _longFadeDuration;
      logger.d("[playAudio] fadeDuration is $fadeDuration");
      logger.d(
        "[playAudio] Playing ${audioFile.filePath} on channel ${channel.name}",
      );

      // Update progress providers for jingle tracking
      ref.read(currentPlayingJingleProvider.notifier).state = audioFile;
      ref.read(currentJingleChannelProvider.notifier).state =
          channel == AudioChannel.channel1 ? 1 : 2;
      logger.d(
        "[playAudio] Updated progress providers for: ${audioFile.displayName}",
      );

      await _playAudioFile(
        ref,
        channel,
        audioFile.filePath,
        fadeDuration: fadeDuration,
        isBackgroundMusic: isBackgroundMusic,
        audioFile: audioFile,
      );
    } catch (e) {
      logger.e("Error playing audio: $e");
    }
  }

  /// Plays audio from a specific category with various playback options
  Future<void> playAudioFile(
    AudioFile audiofile,
    WidgetRef ref, {
    bool shortFade = true,
  }) async {
    try {
      // If this is a category-only audio file, play a random audio from the category
      if (audiofile.isCategoryOnly) {
        // Track which button was pressed for category-only buttons
        ref.read(lastPressedButtonProvider.notifier).state = audiofile;

        await playAudio(
          audiofile.audioCategory,
          ref,
          random: true,
          shortFade: shortFade,
        );
        return;
      }

      final channel = _getAvailableChannel();

      final fadeDuration = shortFade ? _shortFadeDuration : _longFadeDuration;
      logger.d("[playAudio] fadeDuration is $fadeDuration");
      logger.d(
        "[playAudio] Playing ${audiofile.filePath} on channel ${channel.name}",
      );
      await _playAudioFile(
        ref,
        channel,
        audiofile.filePath,
        fadeDuration: fadeDuration,
        audioFile: audiofile,
      );
    } catch (e) {
      logger.e("Error playing audio: $e");
    }
  }

  /// Selects a random audio file while avoiding recently played files
  AudioFile _selectRandomAudioFile(
    AudioCategory category,
    List<AudioFile> categoryInstances,
  ) {
    // Initialize queue for this category if it doesn't exist
    if (!_recentlyPlayed.containsKey(category)) {
      _recentlyPlayed[category] = Queue<String>();
    }

    // Get the queue for this category
    final recentQueue = _recentlyPlayed[category]!;

    // Try to find a song that hasn't been played recently
    int attempts = 0;
    const maxAttempts = 50;
    late AudioFile audioFile;
    late String filePath;

    do {
      final index = Random().nextInt(categoryInstances.length);
      audioFile = categoryInstances[index];
      filePath = audioFile.filePath;
      attempts++;

      // If we've tried too many times, just use the last generated index
      if (attempts >= maxAttempts) break;
    } while (recentQueue.contains(filePath));

    // Add to recently played and remove oldest if exceeding memory size
    recentQueue.addLast(filePath);
    if (recentQueue.length > _memorySize) {
      recentQueue.removeFirst();
    }

    if (kDebugMode) {
      logger.d("[playAudio] Playing random file: ${audioFile.filePath}");
      logger.d("[playAudio] Recent queue size: ${recentQueue.length}");
    }

    return audioFile;
  }

  /// Selects an audio file sequentially from the category
  AudioFile _selectSequentialAudioFile(
    AudioCategory category,
    List<AudioFile> categoryInstances,
  ) {
    if (!_currentPlayIndex.containsKey(category)) {
      _currentPlayIndex[category] = 0;
    }

    final currentIndex = _currentPlayIndex[category]!;
    final audioFile = categoryInstances[currentIndex];

    _currentPlayIndex[category] = (currentIndex + 1) % categoryInstances.length;

    return audioFile;
  }

  /// Clears the play history for all categories
  void clearPlayHistory() {
    _recentlyPlayed.clear();
  }

  /// Clears the play history for a specific category
  void clearPlayHistoryForCategory(AudioCategory category) {
    _recentlyPlayed.remove(category);
  }

  /// Returns the channel that is currently available for playback
  AudioChannel _getAvailableChannel() {
    return channel1.state == PlayerState.playing
        ? AudioChannel.channel2
        : AudioChannel.channel1;
  }

  /// Plays a horn jingle immediately
  Future<void> playHorn(WidgetRef ref) async {
    try {
      const category = AudioCategory.hornJingle;
      final categoryInstances = audioInstances
          .where((instance) => instance.audioCategory == category)
          .toList();

      if (categoryInstances.isEmpty) return;

      final hornAudioFile = categoryInstances[0];
      logger.d("[playHorn] Loading ${hornAudioFile.filePath} into channel 2");

      if (channel2.state == PlayerState.playing) {
        logger.d("[playHorn] Stopping Channel 2");
        await channel2.stop(); // Stop the currently playing instance
        logger.d("[playHorn] Channel 2 Stopped");
      }
      if (channel1.state == PlayerState.playing) {
        logger.d("[playHorn] Stopping Channel 1");
        await channel1.stop(); // Stop the currently playing instance
        logger.d("[playHorn] Channel 1 Stopped");
      }

      // Update progress providers for tracking
      ref.read(currentPlayingJingleProvider.notifier).state = hornAudioFile;
      ref.read(currentJingleChannelProvider.notifier).state = 2;

      // Set up completion listener to clear tracking
      channel2.onPlayerComplete.listen((_) {
        ref.read(currentPlayingJingleProvider.notifier).state = null;
        ref.read(currentJingleChannelProvider.notifier).state = null;
        ref.read(lastPressedButtonProvider.notifier).state = null;
      });

      logger.d("[playHorn] Channel 2 setVolume 1.0");
      await channel2.setVolume(1.0);
      ref.read(c2VolumeProvider.notifier).updateVolume(1.0);
      logger.d("[playHorn] Playing horn");
      await channel2.play(DeviceFileSource(hornAudioFile.filePath));
    } catch (e) {
      logger.e("[playHorn] Error playing horn: $e");
    }
  }

  /// Plays audio from a byte array
  Future<void> playBytes({
    required Uint8List audio,
    required WidgetRef ref,
  }) async {
    try {
      logger.d("Length is ${audio.length}");

      if (channel2.state == PlayerState.playing) {
        await channel2.stop(); // Stop the currently playing instance
      }

      await channel2.setVolume(1.0);
      ref.read(c2VolumeProvider.notifier).updateVolume(1.0);

      await channel2.play(BytesSource(audio));
    } catch (e) {
      logger.e("Error playing bytes: $e");
    }
  }

  /// Plays audio from a byte array and waits for completion
  Future<void> playBytesAndWait({
    required Uint8List audio,
    required WidgetRef ref,
  }) async {
    try {
      logger.d("[playBytesAndWait] Length is ${audio.length}");

      if (channel2.state == PlayerState.playing) {
        await channel2.stop(); // Stop the currently playing instance
      }

      logger.d("[playBytesAndWait] Setting volume to 1.0");

      await channel2.setVolume(1.0);
      ref.read(c2VolumeProvider.notifier).updateVolume(1.0);

      // Create a completer to handle the completion
      final completer = Completer<void>();

      // Set up player state stream subscription
      StreamSubscription? subscription;
      subscription = channel2.onPlayerStateChanged.listen((PlayerState state) {
        if (state == PlayerState.completed) {
          subscription?.cancel();
          completer.complete();
        }
      });

      logger.d("[playBytesAndWait] Playing audio");

      // Play the audio
      await channel2.play(BytesSource(audio));

      logger.d("[playBytesAndWait] Returning completer");

      // Wait for completion
      return completer.future;
    } catch (e) {
      logger.e("Error in playBytesAndWait: $e");
      // Re-throw to allow caller to handle
      rethrow;
    }
  }
}
