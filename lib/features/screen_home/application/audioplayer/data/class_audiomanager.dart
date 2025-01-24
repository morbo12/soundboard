// ignore_for_file: unused_import

import 'dart:async';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/player_fade.dart';
import 'package:flutter/foundation.dart';
import 'package:soundboard/properties.dart';

enum AudioChannel { channel1, channel2 }

class AudioManager {
  final List<AudioFile> audioInstances = [];
  WidgetRef? _ref;
  Map<AudioCategory, int> _currentPlayIndex = {};

  final AudioPlayer channel1 = AudioPlayer();
  final AudioPlayer channel2 = AudioPlayer();
  AudioManager() {
    channel1.setVolume(SettingsBox().c1InitialVolume);
    channel2.setVolume(SettingsBox().c2InitialVolume);
  }
  static const int _shortFadeDuration = 10;
  static const int _longFadeDuration = 400;

  void setRef(WidgetRef ref) => _ref = ref;
  void addInstance(AudioFile audioInstance) =>
      audioInstances.add(audioInstance);

  Future<void> stopAll(WidgetRef ref) async {
    await _fadeAndStop(ref, AudioChannel.channel1);
    await _fadeAndStop(ref, AudioChannel.channel2);
  }

  Future<void> _fadeAndStop(WidgetRef ref, AudioChannel channel,
      {int fadeDuration = _longFadeDuration}) async {
    await _fadeChannel(ref, channel, 0.0, fadeDuration);
    await _stopChannel(channel);
  }

  Future<void> _fadeChannel(
      WidgetRef ref, AudioChannel channel, double to, int duration) async {
    Fade f = Fade(ref);
    AudioPlayer player = channel == AudioChannel.channel1 ? channel1 : channel2;
    var provider =
        channel == AudioChannel.channel1 ? c1VolumeProvider : c2VolumeProvider;

    await f.fade(
        to: to, duration: duration, channel: player, provider: provider);
  }

  Future<void> _stopChannel(AudioChannel channel) async {
    AudioPlayer player = channel == AudioChannel.channel1 ? channel1 : channel2;
    await player.stop();
    await player.release();
  }

  Future<void> _playAudioFile(
    WidgetRef ref,
    AudioChannel channel,
    String filePath, {
    int fadeDuration = _shortFadeDuration,
    bool isBackgroundMusic = false,
  }) async {
    AudioChannel otherChannel = channel == AudioChannel.channel1
        ? AudioChannel.channel2
        : AudioChannel.channel1;

    await _setChannelVolume(ref, channel, 0.0);
    _fadeAndStop(ref, otherChannel, fadeDuration: fadeDuration);

    AudioPlayer player = channel == AudioChannel.channel1 ? channel1 : channel2;
    await player.play(DeviceFileSource(filePath));

    // Fade in to full volume
    await _fadeChannel(ref, channel, 1.0, fadeDuration);

    if (isBackgroundMusic) {
      // Wait for 5 seconds
      await Future.delayed(Duration(seconds: 5));

      // Fade down to background music level
      await _fadeChannel(
          ref, channel, SettingsBox().backgroundVolumeLevel, fadeDuration);

      // Set up a listener for when the background music ends
      player.onPlayerComplete.listen((_) async {
        await _setChannelVolume(ref, channel, 0.0);
      });
    }
  }

// Add this method to reset the sequential playback index for a category
  void resetSequentialIndex(AudioCategory category) {
    _currentPlayIndex[category] = 0;
  }

  // Add this method to reset all sequential playback indices
  void resetAllSequentialIndices() {
    _currentPlayIndex.clear();
  }

  Future<void> _setChannelVolume(
      WidgetRef ref, AudioChannel channel, double volume) async {
    AudioPlayer player = channel == AudioChannel.channel1 ? channel1 : channel2;
    await player.setVolume(volume);

    if (_ref != null) {
      var provider = channel == AudioChannel.channel1
          ? c1VolumeProvider
          : c2VolumeProvider;
      _ref!.read(provider.notifier).updateVolume(volume);
    }
  }

  Future<void> playAudio(
    AudioCategory category,
    WidgetRef ref, {
    bool random = false,
    bool sequential = false, // Add this parameter
    bool shortFade = true,
    bool isBackgroundMusic = false,
  }) async {
    List<AudioFile> categoryInstances = audioInstances
        .where((instance) => instance.audioCategory == category)
        .toList();
    if (categoryInstances.isEmpty) return;

    AudioFile audioFile;

    if (random) {
      audioFile = categoryInstances[Random().nextInt(categoryInstances.length)];
      print("Playing random file: ${audioFile.filePath}");
    } else if (sequential) {
      // Initialize the index for this category if it doesn't exist
      if (!_currentPlayIndex.containsKey(category)) {
        _currentPlayIndex[category] = 0;
      }

      // Get the current index for this category
      int currentIndex = _currentPlayIndex[category]!;

      // Play the current index
      audioFile = categoryInstances[currentIndex];
      print("Playing sequential index: ${currentIndex}");
      // Increment the index for next time
      _currentPlayIndex[category] =
          (currentIndex + 1) % categoryInstances.length;
    } else {
      audioFile = categoryInstances[0];
    }

    AudioChannel channel = _getAvailableChannel();

    int fadeDuration = shortFade ? _shortFadeDuration : _longFadeDuration;

    await _playAudioFile(
      ref,
      channel,
      audioFile.filePath,
      fadeDuration: fadeDuration,
      isBackgroundMusic: isBackgroundMusic,
    );
  }

  AudioChannel _getAvailableChannel() {
    return channel1.state == PlayerState.playing
        ? AudioChannel.channel2
        : AudioChannel.channel1;
  }

  Future<void> playHorn(WidgetRef ref) async {
    AudioCategory category = AudioCategory.hornJingle;
    List<AudioFile> categoryInstances = audioInstances
        .where((instance) => instance.audioCategory == category)
        .toList();
    if (kDebugMode) {
      print(categoryInstances[0].filePath);
    }
    if (categoryInstances.isNotEmpty) {
      if (channel2.state == PlayerState.playing) {
        channel2.stop(); // Stop the currently playing instance
        channel1.stop(); // Stop the currently playing instance
      }
      await channel2.setVolume(1.0);
      ref.read(c2VolumeProvider.notifier).updateVolume(1.0);

      await channel2.play(DeviceFileSource(categoryInstances[0].filePath));
    }
  }

  Future<void> playBytes(
      {required Uint8List audio, required WidgetRef ref}) async {
    if (kDebugMode) {
      print("Length is ${audio.length}");
    }

    if (channel2.state == PlayerState.playing) {
      channel2.stop(); // Stop the currently playing instance
    }
    await channel2.setVolume(1.0);
    ref.read(c2VolumeProvider.notifier).updateVolume(1.0);

    await channel2.play(BytesSource(audio));
  }
}
