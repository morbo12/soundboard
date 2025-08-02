// ignore_for_file: unused_import

import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:soundboard/core/constants/globals.dart';
import 'package:soundboard/core/models/volume_system_config.dart';
import 'package:soundboard/core/providers/volume_providers.dart';
import 'package:soundboard/core/utils/providers.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/player_fade.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/deej_providers.dart';
import 'package:flutter/foundation.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/core/services/volume_control_service_v2.dart';
import 'package:soundboard/features/screen_home/presentation/board/providers/audio_progress_provider.dart';

/// Enum representing the available audio channels
enum AudioChannel { channel1, channel2 }

/// Manages audio playback with dual-channel support, fading effects,
/// and various playback strategies.
///
/// CHANNEL ASSIGNMENT STRATEGY (Static):
/// - Channel 1 (C1): Background music and regular jingles
/// - Channel 2 (C2): Horn, TTS/byte audio, and special effects
///
/// This replaces the previous dynamic channel selection which was unreliable.
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

  /// Flag to track if volumes have been initialized
  bool _volumesInitialized = false;

  /// Constructor - channels initialized with default volume of 0.0
  AudioManager() {
    // Volumes will be set by initializeVolumes() method when WidgetRef is available
  }

  /// Initializes audio channel volumes, respecting Deej mappings
  Future<void> initializeVolumes(WidgetRef ref) async {
    if (_volumesInitialized) return; // Already initialized

    try {
      // Set C1 volume if not mapped to Deej
      if (!_isChannelMappedToDeej(ref, AudioChannel.channel1)) {
        await channel1.setVolume(SettingsBox().c1InitialVolume);
        logger.d("Initialized C1 volume to ${SettingsBox().c1InitialVolume}");
      } else {
        logger.d("C1 mapped to Deej - skipping initial volume setting");
      }

      // Set C2 volume if not mapped to Deej
      if (!_isChannelMappedToDeej(ref, AudioChannel.channel2)) {
        await channel2.setVolume(SettingsBox().c2InitialVolume);
        logger.d("Initialized C2 volume to ${SettingsBox().c2InitialVolume}");
      } else {
        logger.d("C2 mapped to Deej - skipping initial volume setting");
      }

      _volumesInitialized = true;
    } catch (e) {
      logger.e("Error initializing audio channel volumes: $e");
    }
  }

  /// Checks if an AudioPlayer channel is mapped to Deej and should skip automatic volume setting
  bool _isChannelMappedToDeej(WidgetRef ref, AudioChannel channel) {
    try {
      // Check if Deej is connected
      final isDeejConnected = ref.read(deejConnectionStatusProvider);
      if (!isDeejConnected) {
        return false; // If Deej is not connected, allow volume control
      }

      // Determine which DeejTarget corresponds to this channel
      final DeejTarget targetForChannel = channel == AudioChannel.channel1
          ? DeejTarget.audioPlayerC1
          : DeejTarget.audioPlayerC2;

      // Check if this AudioPlayer channel is mapped to any Deej slider
      final config = SettingsBox().volumeSystemConfig;
      final isChannelMapped = config.deejMappings.any(
        (sliderConfig) => sliderConfig.target == targetForChannel,
      );

      if (isChannelMapped) {
        logger.d(
          'Channel ${channel.name} is mapped to Deej - skipping automatic volume setting',
        );
      }

      return isChannelMapped;
    } catch (e) {
      logger.e('Error checking if channel is mapped to Deej: $e');
      return false; // Default to allowing volume control if error
    }
  }

  /// Ensures volumes are initialized before first use
  Future<void> _ensureInitialized(WidgetRef ref) async {
    if (!_volumesInitialized) {
      await initializeVolumes(ref);
    }
  }

  /// Gets the current target volume for a channel based on the new volume system
  double _getCurrentTargetVolume(WidgetRef ref, AudioChannel channel) {
    try {
      final channelNumber = channel == AudioChannel.channel1 ? 1 : 2;

      // Use the VolumeControlServiceV2 to get the target volume
      final volumeService = VolumeControlServiceV2(ref);
      final targetVolume = volumeService.getAudioPlayerTargetVolume(
        channelNumber,
      );

      logger.d(
        'Channel ${channel.name} target volume from VolumeControlServiceV2: $targetVolume',
      );

      // Safety check: if target volume is 0, use a reasonable default
      if (targetVolume <= 0.0) {
        logger.w(
          'Channel ${channel.name} target volume is 0 - using fallback volume 0.7',
        );
        return 0.7; // Use 70% as a reasonable fallback
      }

      return targetVolume;
    } catch (e) {
      logger.e('Error getting target volume for channel: $e');
      return 1.0; // Default to maximum volume if error
    }
  }

  /// Adds an audio file to the available instances
  void addInstance(AudioFile audioInstance) =>
      audioInstances.add(audioInstance);

  /// Updates the volume for a specific AudioPlayer channel
  /// This is called by external volume control services (e.g., Deej)
  Future<void> updateChannelVolume(
    Ref ref,
    int channelNumber,
    double volume,
  ) async {
    try {
      final player = channelNumber == 1 ? channel1 : channel2;

      logger.d(
        'updateChannelVolume called: C$channelNumber -> ${(volume * 100).toStringAsFixed(0)}%',
      );
      logger.d('Player state: ${player.state}');

      // Directly set the volume on the AudioPlayer
      await player.setVolume(volume);

      // Update the provider for UI feedback (always update when called externally)
      final provider = channelNumber == 1 ? c1VolumeProvider : c2VolumeProvider;
      ref.read(provider.notifier).updateVolume(volume);

      // Force log the current volume to verify it was set
      logger.d(
        'AudioPlayer C$channelNumber volume set. Player state after setVolume: ${player.state}',
      );

      logger.d(
        'Successfully updated AudioPlayer C$channelNumber volume from external source: ${(volume * 100).toStringAsFixed(0)}%',
      );
    } catch (e) {
      logger.e('Error updating AudioPlayer channel $channelNumber volume: $e');
    }
  }

  /// Test method to manually set volume (for debugging)
  Future<void> testSetVolume(int channelNumber, double volume) async {
    try {
      final player = channelNumber == 1 ? channel1 : channel2;
      logger.d(
        'TEST: Setting C$channelNumber volume to ${(volume * 100).toStringAsFixed(0)}%',
      );
      await player.setVolume(volume);
      logger.d('TEST: Volume set successfully');
    } catch (e) {
      logger.e('TEST: Error setting volume: $e');
    }
  }

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

      // For Deej-mapped channels, set to current target volume instead of 0
      // For non-Deej channels, start at 0 for smooth fade-in
      if (_isChannelMappedToDeej(ref, channel)) {
        final targetVolume = _getCurrentTargetVolume(ref, channel);
        logger.d(
          "Channel ${channel.name} is Deej-mapped, setting to target volume: $targetVolume",
        );
        // Use _setChannelVolume to ensure proper synchronization
        await _setChannelVolume(ref, channel, targetVolume);
      } else {
        await _setChannelVolume(ref, channel, 0.0);
      }

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
        // For Deej-mapped channels, volume is already set correctly
        // For non-Deej channels, fade in to target volume
        if (!_isChannelMappedToDeej(ref, channel)) {
          final targetVolume = _getCurrentTargetVolume(ref, channel);
          await _fadeChannel(ref, channel, targetVolume, fadeDuration);
          logger.d(
            "Fading to target volume: $targetVolume for ${channel.name}",
          );
        } else {
          logger.d(
            "Channel ${channel.name} is Deej-mapped - volume already set, no fade needed",
          );
        }
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
      final provider = channel == AudioChannel.channel1
          ? c1VolumeProvider
          : c2VolumeProvider;

      logger.d("Setting volume to $volume for channel ${channel.name}");

      // Always set the AudioPlayer volume, but only update provider if not Deej-mapped
      await player.setVolume(volume);

      if (!_isChannelMappedToDeej(ref, channel)) {
        ref.read(provider.notifier).updateVolume(volume);
      } else {
        logger.d(
          "AudioPlayer volume set but provider not updated - ${channel.name} is mapped to Deej",
        );
      }
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
    await _ensureInitialized(ref);

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

      final channel = _getChannelForAudioType(
        category: category,
        isBackgroundMusic: isBackgroundMusic,
      );

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
    await _ensureInitialized(ref);

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

      final channel = _getChannelForAudioType(
        category: audiofile.audioCategory,
      );

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

  /// Returns the appropriate channel for the given audio type
  ///
  /// Static channel assignment strategy:
  /// - C1: Background music and regular jingles (goal, clap, generic, etc.)
  /// - C2: Horn, byte audio (TTS), and special effects (penalty, timeout, powerup)
  ///
  /// This replaces the old _getAvailableChannel() which was unreliable and
  /// caused audio conflicts. Static assignment ensures predictable behavior.
  AudioChannel _getChannelForAudioType({
    bool isHorn = false,
    bool isBackgroundMusic = false,
    bool isByteAudio = false,
    AudioCategory? category,
  }) {
    // Background music always on C1 (existing behavior)
    if (isBackgroundMusic) {
      return AudioChannel.channel1;
    }

    // C2 for horn, byte audio, and special effects
    if (isHorn || isByteAudio) {
      return AudioChannel.channel2;
    }

    // C2 for special effect categories
    if (category != null) {
      switch (category) {
        case AudioCategory.specialJingle:
          return AudioChannel.channel2;
        default:
          return AudioChannel.channel1;
      }
    }

    // C1 for everything else (regular jingles)
    return AudioChannel.channel1;
  }

  /// Plays a horn jingle immediately
  Future<void> playHorn(WidgetRef ref) async {
    await _ensureInitialized(ref);

    try {
      logger.d("[playHorn] Playing goalHorn category");

      // Stop both channels first for immediate horn playback
      if (channel2.state == PlayerState.playing) {
        logger.d("[playHorn] Stopping Channel 2");
        await channel2.stop();
        logger.d("[playHorn] Channel 2 Stopped");
      }
      if (channel1.state == PlayerState.playing) {
        logger.d("[playHorn] Stopping Channel 1");
        await channel1.stop();
        logger.d("[playHorn] Channel 1 Stopped");
      }

      // Use the existing playAudio method with goalHorn category
      // This ensures consistent behavior with the rest of the audio system
      await playAudio(
        AudioCategory.goalHorn,
        ref,
        shortFade: true, // Quick fade for immediate horn response
      );
    } catch (e) {
      logger.e("[playHorn] Error playing horn: $e");
    }
  }

  /// Plays audio from a byte array
  Future<void> playBytes({
    required Uint8List audio,
    required WidgetRef ref,
  }) async {
    await _ensureInitialized(ref);

    try {
      logger.d("Length is ${audio.length}");

      if (channel2.state == PlayerState.playing) {
        await channel2.stop(); // Stop the currently playing instance
      }

      // Only set volume if channel is not mapped to Deej
      if (!_isChannelMappedToDeej(ref, AudioChannel.channel2)) {
        final targetVolume = _getCurrentTargetVolume(
          ref,
          AudioChannel.channel2,
        );
        await channel2.setVolume(targetVolume);
        ref.read(c2VolumeProvider.notifier).updateVolume(targetVolume);
      } else {
        logger.d(
          "[playBytes] Skipping volume setting - Channel 2 is mapped to Deej",
        );
      }

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
    await _ensureInitialized(ref);

    try {
      logger.d("[playBytesAndWait] Length is ${audio.length}");

      if (channel2.state == PlayerState.playing) {
        await channel2.stop(); // Stop the currently playing instance
      }

      logger.d("[playBytesAndWait] Setting volume to target");

      // Only set volume if channel is not mapped to Deej
      if (!_isChannelMappedToDeej(ref, AudioChannel.channel2)) {
        final targetVolume = _getCurrentTargetVolume(
          ref,
          AudioChannel.channel2,
        );
        await channel2.setVolume(targetVolume);
        ref.read(c2VolumeProvider.notifier).updateVolume(targetVolume);
      } else {
        logger.d(
          "[playBytesAndWait] Skipping volume setting - Channel 2 is mapped to Deej",
        );
      }

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
