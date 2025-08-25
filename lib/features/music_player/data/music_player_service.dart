import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/music_player/data/music_models.dart';

/// Service for managing music playback
class MusicPlayerService {
  final Logger logger = const Logger('MusicPlayerService');

  final AudioPlayer _audioPlayer = AudioPlayer();
  final StreamController<MusicPlaybackState> _stateController =
      StreamController<MusicPlaybackState>.broadcast();

  MusicPlaybackState _currentState = const MusicPlaybackState();
  Timer? _positionTimer;
  final Random _random = Random();
  bool _fadeInProgress = false;

  /// Stream of playback state changes
  Stream<MusicPlaybackState> get stateStream => _stateController.stream;

  /// Current playback state
  MusicPlaybackState get currentState => _currentState;

  MusicPlayerService() {
    _initializeAudioPlayer();
  }

  void _initializeAudioPlayer() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      _updateState(
        _currentState.copyWith(
          isPlaying: state == PlayerState.playing,
          isPaused: state == PlayerState.paused,
        ),
      );
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      _updateState(_currentState.copyWith(totalDuration: duration));
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((Duration position) {
      _updateState(_currentState.copyWith(currentPosition: position));
      _checkForCrossfade(position);
    });

    // Listen for playback completion
    _audioPlayer.onPlayerComplete.listen((_) {
      _onTrackComplete();
    });
  }

  void _updateState(MusicPlaybackState newState) {
    _currentState = newState;
    _stateController.add(newState);
  }

  void _checkForCrossfade(Duration position) {
    // Only check if we're playing and have a playlist with more content
    if (!_currentState.isPlaying || 
        _fadeInProgress || 
        _currentState.totalDuration == Duration.zero ||
        _currentState.playlist.isEmpty) {
      return;
    }

    // Start crossfade 4 seconds before the song ends
    const Duration crossfadeStartOffset = Duration(seconds: 4);
    final Duration timeRemaining = _currentState.totalDuration - position;
    
    if (timeRemaining <= crossfadeStartOffset && timeRemaining > Duration.zero) {
      _fadeInProgress = true;
      _startCrossfade();
    }
  }

  Future<void> _startCrossfade() async {
    try {
      // Check if we should proceed to next track
      if (_currentState.isRepeatEnabled && _currentState.currentTrack != null) {
        // Don't crossfade when repeating the same track
        _fadeInProgress = false;
        return;
      }
      
      if (_currentState.playlist.isEmpty) {
        _fadeInProgress = false;
        return;
      }

      // Start the crossfade with 4 second total duration
      await nextWithFade(
        fadeOut: const Duration(milliseconds: 2000),
        fadeIn: const Duration(milliseconds: 2000),
      );
    } catch (e) {
      logger.e("Error during crossfade: $e");
    } finally {
      _fadeInProgress = false;
    }
  }

  void _onTrackComplete() {
    // Reset fade flag when track actually completes
    _fadeInProgress = false;
    
    if (_currentState.isRepeatEnabled && _currentState.currentTrack != null) {
      // Repeat current track
      seek(Duration.zero);
      play();
    } else if (_currentState.hasNext) {
      // Play next track (may be redundant if crossfade already handled it)
      next();
    } else {
      // End of playlist - restart from beginning for continuous playback
      if (_currentState.playlist.isNotEmpty) {
        _selectTrack(0);
      } else {
        _updateState(
          _currentState.copyWith(
            isPlaying: false,
            isPaused: false,
            currentPosition: Duration.zero,
          ),
        );
      }
    }
  }

  /// Load the music playlist from the Music directory
  Future<List<MusicFile>> loadMusicFiles() async {
    try {
      final Directory appSupportDir = await getApplicationCacheDirectory();
      final Directory musicDir = Directory('${appSupportDir.path}/Music');

      if (!await musicDir.exists()) {
        logger.d("Music directory doesn't exist, creating it");
        await musicDir.create(recursive: true);
        return [];
      }

      final fileEntities = musicDir
          .listSync()
          .where((file) => file is File)
          .cast<File>()
          .toList();

      final List<MusicFile> files = [];

      // Load files with metadata asynchronously
      for (final file in fileEntities) {
        try {
          final musicFile = await MusicFile.fromFileWithMetadata(file);
          if (musicFile.isSupported) {
            files.add(musicFile);
          }
        } catch (e) {
          logger.w("Error loading metadata for ${file.path}: $e");
          // Fall back to basic file info
          final basicFile = MusicFile.fromFile(file);
          if (basicFile.isSupported) {
            files.add(basicFile);
          }
        }
      }

      // Sort by display name for consistent ordering
      files.sort(
        (a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()),
      );

      logger.d("Loaded ${files.length} music files with metadata");
      return files;
    } catch (e) {
      logger.e("Error loading music files: $e");
      return [];
    }
  }

  /// Load playlist and update state
  Future<void> loadPlaylist() async {
    final files = await loadMusicFiles();
    _updateState(
      _currentState.copyWith(
        playlist: files,
        currentTrackIndex: files.isNotEmpty ? 0 : -1,
        currentTrack: files.isNotEmpty ? files[0] : null,
      ),
    );
  }

  /// Play the current track or resume playback
  Future<void> play() async {
    try {
      if (_currentState.currentTrack == null) {
        logger.w("No track to play");
        return;
      }

      if (_currentState.isPaused) {
        // Resume playback
        await _audioPlayer.resume();
      } else {
        // Start playback from current track
        await _audioPlayer.play(
          DeviceFileSource(_currentState.currentTrack!.filePath),
        );
      }

      logger.d("Playing: ${_currentState.currentTrack!.name}");
    } catch (e) {
      logger.e("Error playing track: $e");
    }
  }

  /// Pause playback
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      logger.d("Playback paused");
    } catch (e) {
      logger.e("Error pausing playback: $e");
    }
  }

  /// Stop playback
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _updateState(
        _currentState.copyWith(
          isPlaying: false,
          isPaused: false,
          currentPosition: Duration.zero,
        ),
      );
      logger.d("Playback stopped");
    } catch (e) {
      logger.e("Error stopping playback: $e");
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      logger.d("Seeked to position: $position");
    } catch (e) {
      logger.e("Error seeking: $e");
    }
  }

  /// Play the next track
  Future<void> next() async {
    if (_currentState.playlist.isEmpty) {
      logger.d("No playlist available");
      return;
    }

    int nextIndex;
    if (_currentState.isShuffleEnabled) {
      // Random next track
      do {
        nextIndex = _random.nextInt(_currentState.playlist.length);
      } while (nextIndex == _currentState.currentTrackIndex &&
          _currentState.playlist.length > 1);
    } else {
      // Sequential next track
      nextIndex = _currentState.currentTrackIndex + 1;
      if (nextIndex >= _currentState.playlist.length) {
        nextIndex = 0; // Loop to beginning
      }
    }

    await _selectTrack(nextIndex);
  }

  /// Play the next track with fade-out/fade-in transition
  Future<void> nextWithFade({
    Duration fadeOut = const Duration(milliseconds: 2000),
    Duration fadeIn = const Duration(milliseconds: 2000),
  }) async {
    try {
      final wasPlaying = _currentState.isPlaying;
      // Check if we have a playlist to work with
      if (_currentState.playlist.isEmpty) {
        return;
      }

      if (wasPlaying) {
        final double originalVolume = _currentState.volume;
        if (originalVolume > 0) {
          await _fadeVolume(to: 0.0, duration: fadeOut);
        }

        // Move to next track (respects shuffle/repeat logic via next())
        await next();

        // next() will keep playing because state isPlaying remains true
        await _fadeVolume(to: originalVolume, duration: fadeIn);
      } else {
        // If not playing, just switch track without fade and keep paused state
        await next();
      }
    } catch (e) {
      logger.e("Error during nextWithFade: $e");
      // Best-effort fallback
      await next();
    }
  }

  Future<void> _fadeVolume({
    required double to,
    required Duration duration,
  }) async {
    final double from = _currentState.volume;
    final double target = to.clamp(0.0, 1.0);
    if (duration.inMilliseconds <= 0 || (from - target).abs() < 0.001) {
      await setVolume(target);
      return;
    }

    const int steps = 10; // small, quick fade
    final int stepMs = (duration.inMilliseconds / steps).round();
    for (int i = 1; i <= steps; i++) {
      final double t = i / steps;
      final double v = from + (target - from) * t;
      await setVolume(v);
      await Future.delayed(Duration(milliseconds: stepMs));
    }
    // Ensure exact target
    await setVolume(target);
  }

  /// Play the previous track
  Future<void> previous() async {
    if (!_currentState.hasPrevious && !_currentState.isRepeatEnabled) {
      logger.d("No previous track available");
      return;
    }

    int prevIndex;
    if (_currentState.isShuffleEnabled) {
      // Random previous track
      do {
        prevIndex = _random.nextInt(_currentState.playlist.length);
      } while (prevIndex == _currentState.currentTrackIndex &&
          _currentState.playlist.length > 1);
    } else {
      // Sequential previous track
      prevIndex = _currentState.currentTrackIndex - 1;
      if (prevIndex < 0) {
        prevIndex = _currentState.playlist.length - 1; // Loop to end
      }
    }

    await _selectTrack(prevIndex);
  }

  /// Select a specific track by index
  Future<void> selectTrack(int index) async {
    if (index < 0 || index >= _currentState.playlist.length) {
      logger.w("Invalid track index: $index");
      return;
    }
    await _selectTrack(index);
  }

  Future<void> _selectTrack(int index) async {
    final track = _currentState.playlist[index];
    _updateState(
      _currentState.copyWith(
        currentTrack: track,
        currentTrackIndex: index,
        currentPosition: Duration.zero,
      ),
    );

    if (_currentState.isPlaying) {
      await play();
    }

    logger.d("Selected track: ${track.name}");
  }

  /// Set the volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    try {
      final clampedVolume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(clampedVolume);
      _updateState(_currentState.copyWith(volume: clampedVolume));
      logger.d("Volume set to: $clampedVolume");
    } catch (e) {
      logger.e("Error setting volume: $e");
    }
  }

  /// Toggle shuffle mode
  void toggleShuffle() {
    _updateState(
      _currentState.copyWith(isShuffleEnabled: !_currentState.isShuffleEnabled),
    );
    logger.d(
      "Shuffle ${_currentState.isShuffleEnabled ? 'enabled' : 'disabled'}",
    );
  }

  /// Toggle repeat mode
  void toggleRepeat() {
    _updateState(
      _currentState.copyWith(isRepeatEnabled: !_currentState.isRepeatEnabled),
    );
    logger.d(
      "Repeat ${_currentState.isRepeatEnabled ? 'enabled' : 'disabled'}",
    );
  }

  /// Dispose of resources
  void dispose() {
    _positionTimer?.cancel();
    _audioPlayer.dispose();
    _stateController.close();
  }
}

// Contains AI-generated edits.
