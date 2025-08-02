import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/music_player/data/music_player_provider.dart';
import 'package:soundboard/features/music_player/data/music_models.dart';

/// A minimal music player widget for the home screen
class MiniMusicPlayer extends ConsumerWidget {
  const MiniMusicPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final musicStateAsync = ref.watch(musicPlaybackStateProvider);
    final musicNotifier = ref.read(musicPlayerNotifierProvider.notifier);

    return musicStateAsync.when(
      data: (state) => _buildPlayer(context, state, musicNotifier),
      loading: () => _buildLoadingPlayer(context),
      error: (error, stack) => _buildErrorPlayer(context, error),
    );
  }

  Widget _buildPlayer(
    BuildContext context,
    MusicPlaybackState state,
    MusicPlayerNotifier notifier,
  ) {
    if (state.playlist.isEmpty) {
      return _buildEmptyPlayer(context);
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compact track info and controls row
          Row(
            children: [
              // Smaller album art
              _buildCompactAlbumArt(context, state),
              const SizedBox(width: 10),

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.currentTrack?.displayName ?? 'No track selected',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${state.currentTrackIndex + 1}/${state.playlist.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),

              // Compact control buttons
              _buildCompactControls(context, state, notifier),
            ],
          ),

          const SizedBox(height: 8),

          // Compact progress section
          _buildCompactProgressSection(context, state, notifier),
        ],
      ),
    );
  }

  /// Builds compact album art placeholder with music visualization
  Widget _buildCompactAlbumArt(BuildContext context, MusicPlaybackState state) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primary.withValues(alpha: 0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (state.isPlaying) ...[
            _buildCompactWaveform(context),
          ] else ...[
            Icon(
              Icons.music_note_rounded,
              color: colorScheme.onPrimaryContainer,
              size: 18,
            ),
          ],
        ],
      ),
    );
  }

  /// Builds compact waveform animation
  Widget _buildCompactWaveform(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 400 + (index * 150)),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 0.5),
          width: 2,
          height: 10 + (index * 2),
          decoration: BoxDecoration(
            color: colorScheme.onPrimaryContainer.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      }),
    );
  }

  /// Builds compact control buttons with shuffle
  Widget _buildCompactControls(
    BuildContext context,
    MusicPlaybackState state,
    MusicPlayerNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shuffle button
        _buildCompactControlButton(
          context,
          icon: Icons.shuffle_rounded,
          onPressed: () => notifier.toggleShuffle(),
          size: 16,
          isActive: state.isShuffleEnabled,
        ),
        const SizedBox(width: 4),

        // Previous button
        _buildCompactControlButton(
          context,
          icon: Icons.skip_previous_rounded,
          onPressed: state.hasPrevious ? () => notifier.previous() : null,
          size: 16,
        ),
        const SizedBox(width: 4),

        // Play/Pause button (slightly larger)
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () => notifier.togglePlayPause(),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Icon(
                state.isPlaying
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                key: ValueKey(state.isPlaying),
                size: 16,
              ),
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(28, 28),
              padding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 4),

        // Next button
        _buildCompactControlButton(
          context,
          icon: Icons.skip_next_rounded,
          onPressed: state.hasNext ? () => notifier.next() : null,
          size: 16,
        ),
      ],
    );
  }

  /// Builds individual compact control button
  Widget _buildCompactControlButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback? onPressed,
    required double size,
    bool isActive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isActive
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.surfaceContainerHigh.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: isActive
            ? Border.all(
                color: colorScheme.primary.withValues(alpha: 0.5),
                width: 0.5,
              )
            : null,
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: size),
        style: IconButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: onPressed != null
              ? (isActive ? colorScheme.primary : colorScheme.onSurface)
              : colorScheme.onSurface.withValues(alpha: 0.4),
          minimumSize: const Size(24, 24),
          padding: EdgeInsets.zero,
        ),
      ),
    );
  }

  /// Builds compact progress section
  Widget _buildCompactProgressSection(
    BuildContext context,
    MusicPlaybackState state,
    MusicPlayerNotifier notifier,
  ) {
    return Column(
      children: [
        // Progress bar
        _buildCompactProgressBar(context, state, notifier),
        const SizedBox(height: 4),

        // Time info (more compact)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCompactTimeLabel(
              context,
              _formatDuration(state.currentPosition),
            ),
            _buildCompactTimeLabel(
              context,
              _formatDuration(state.totalDuration),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds compact time label
  Widget _buildCompactTimeLabel(BuildContext context, String time) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Text(
      time,
      style: theme.textTheme.labelSmall?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        fontSize: 10,
        fontWeight: FontWeight.w400,
        fontFeatures: [const FontFeature.tabularFigures()],
      ),
    );
  }

  Widget _buildCompactProgressBar(
    BuildContext context,
    MusicPlaybackState state,
    MusicPlayerNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(
          enabledThumbRadius: 5,
          elevation: 1,
        ),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.outline.withValues(alpha: 0.15),
        thumbColor: colorScheme.primary,
        overlayColor: colorScheme.primary.withValues(alpha: 0.1),
      ),
      child: Slider(
        value: state.progress.clamp(0.0, 1.0),
        onChanged: (value) {
          final position = Duration(
            milliseconds: (value * state.totalDuration.inMilliseconds).round(),
          );
          notifier.seek(position);
        },
      ),
    );
  }

  Widget _buildEmptyPlayer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainer.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.music_off_rounded,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No music uploaded',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Upload music files in settings',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlayer(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surfaceContainerLow,
            colorScheme.surfaceContainer.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.12),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.primary,
                backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Loading music player...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Please wait',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlayer(BuildContext context, Object error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.errorContainer.withValues(alpha: 0.8),
            colorScheme.errorContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: colorScheme.onErrorContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Music player error',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  error.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes);
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

// Contains AI-generated edits.
