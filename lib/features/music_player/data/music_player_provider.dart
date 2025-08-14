import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/music_player/data/music_player_service.dart';
import 'package:soundboard/features/music_player/data/music_models.dart';

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

  /// Play the current track or resume playback
  Future<void> play() async {
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
    Duration fadeOut = const Duration(milliseconds: 200),
    Duration fadeIn = const Duration(milliseconds: 200),
  }) async {
    await _service.nextWithFade(fadeOut: fadeOut, fadeIn: fadeIn);
  }

  /// Play the previous track
  Future<void> previous() async {
    await _service.previous();
  }

  /// Select a specific track by index
  Future<void> selectTrack(int index) async {
    await _service.selectTrack(index);
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    await _service.seek(position);
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
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
}

/// Provider for the music player notifier
final musicPlayerNotifierProvider = NotifierProvider<MusicPlayerNotifier, void>(
  MusicPlayerNotifier.new,
);

// Contains AI-generated edits.
