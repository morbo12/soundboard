import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/music_player/data/music_player_service.dart';
import 'package:soundboard/features/music_player/data/music_models.dart';
import 'package:soundboard/core/services/volume_control_service_v2.dart';

/// Provider for triggering playlist refresh
final playlistRefreshProvider = StateProvider<int>((ref) => 0);

/// Provider for the music player service
final musicPlayerServiceProvider = Provider<MusicPlayerService>((ref) {
  final service = MusicPlayerService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider for the current music playback state
final musicPlaybackStateProvider = StreamProvider<MusicPlaybackState>((ref) {
  final service = ref.watch(musicPlayerServiceProvider);
  // Watch the refresh trigger to reload playlist when it changes
  ref.watch(playlistRefreshProvider);
  return service.stateStream;
});

/// Provider for the current playback state synchronously
final currentMusicStateProvider = Provider<MusicPlaybackState>((ref) {
  final service = ref.watch(musicPlayerServiceProvider);
  return service.currentState;
});

/// Notifier for music player actions
class MusicPlayerNotifier extends Notifier<void> {
  MusicPlayerService get _service => ref.read(musicPlayerServiceProvider);

  @override
  void build() {
    // Initialize the playlist when the notifier is created
    _service.loadPlaylist();

    // Watch for refresh triggers and reload playlist
    ref.listen(playlistRefreshProvider, (previous, next) {
      if (previous != next) {
        _service.loadPlaylist();
      }
    });
  }

  /// Load the music playlist
  Future<void> loadPlaylist() async {
    await _service.loadPlaylist();
  }

  /// Refresh the music playlist (reload from disk)
  Future<void> refreshPlaylist() async {
    await _service.loadPlaylist();
  }

  /// Play the current track or resume playbook
  Future<void> play() async {
    // Get the target volume before playing
    final targetVolume = await _getCurrentTargetVolume();
    await _service.setVolume(targetVolume);
    await _service.play();
  }

  /// Pause playback
  Future<void> pause() async {
    await _service.pause();
  }

  /// Stop playback
  Future<void> stop() async {
    await _service.stop();
  }

  /// Play/pause toggle
  Future<void> togglePlayPause() async {
    final state = _service.currentState;
    if (state.isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  /// Play the next track
  Future<void> next() async {
    await _service.next();
  }

  /// Play the next track with a short fade-out and fade-in
  Future<void> nextWithFade({
    Duration fadeOut = const Duration(milliseconds: 2000),
    Duration fadeIn = const Duration(milliseconds: 2000),
  }) async {
    await _service.nextWithFade(fadeOut: fadeOut, fadeIn: fadeIn);
  }

  /// Play the previous track
  Future<void> previous() async {
    await _service.previous();
  }

  /// Select a specific track by index
  Future<void> selectTrack(int index) async {
    // Get the target volume before selecting a new track
    final targetVolume = await _getCurrentTargetVolume();
    await _service.setVolume(targetVolume);
    await _service.selectTrack(index);
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    // Check if music player volume is controlled by Deej
    if (await _isMusicPlayerMappedToDeej()) {
      // If mapped to Deej, don't allow UI volume control
      return;
    }
    await _service.setVolume(volume);
  }

  /// Set the volume directly (bypass Deej mapping check)
  /// This is used by the VolumeControlService when applying Deej or system volume changes
  Future<void> setVolumeDirectly(double volume) async {
    await _service.setVolume(volume);
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _service.toggleShuffle();
  }

  /// Toggle repeat mode
  void toggleRepeat() {
    _service.toggleRepeat();
  }

  /// Gets the current target volume for the music player based on the volume system
  Future<double> _getCurrentTargetVolume() async {
    try {
      // Use the VolumeControlServiceV2 to get the target volume
      final volumeService = VolumeControlServiceV2(ref);
      final targetVolume = await volumeService.getMusicPlayerTargetVolume();

      // Safety check: if target volume is 0, use a reasonable default
      if (targetVolume <= 0.0) {
        return 0.8; // Use 80% as a reasonable fallback for music
      }

      return targetVolume;
    } catch (e) {
      // Fallback to max volume if there's an error
      return 1.0;
    }
  }

  /// Checks if the music player is mapped to Deej and should skip manual volume control
  Future<bool> _isMusicPlayerMappedToDeej() async {
    try {
      final volumeService = VolumeControlServiceV2(ref);
      final targetVolume = await volumeService.getMusicPlayerTargetVolume();
      // If we get a specific target volume that's not 1.0, it means it's mapped to Deej
      return targetVolume < 1.0;
    } catch (e) {
      return false; // Default to allowing volume control if error
    }
  }
}

/// Provider for the music player notifier
final musicPlayerNotifierProvider = NotifierProvider<MusicPlayerNotifier, void>(
  MusicPlayerNotifier.new,
);

// Contains AI-generated edits.
