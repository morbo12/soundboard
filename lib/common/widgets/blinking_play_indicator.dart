import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/providers/audio_progress_provider.dart';

/// A simple blinking red dot that indicates when audio is playing for a specific button
class BlinkingPlayIndicator extends ConsumerStatefulWidget {
  final double size;
  final AudioFile? audioFile;

  const BlinkingPlayIndicator({
    super.key,
    this.size = 8.0,
    this.audioFile,
  });

  @override
  ConsumerState<BlinkingPlayIndicator> createState() => _BlinkingPlayIndicatorState();
}

class _BlinkingPlayIndicatorState extends ConsumerState<BlinkingPlayIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller for blinking effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Create opacity animation that fades in and out
    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Check if this specific button's audio is playing
    final isPlaying = ref.watch(isJinglePlayingProvider(widget.audioFile));
    
    // Start or stop animation based on playing state
    if (isPlaying) {
      if (!_animationController.isAnimating) {
        _animationController.repeat(reverse: true);
      }
    } else {
      _animationController.stop();
      _animationController.reset();
    }

    // Show the blinking dot only when playing
    if (!isPlaying) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
      );
    }

    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: _opacityAnimation.value),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(alpha: 0.3),
                blurRadius: 4.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
        );
      },
    );
  }
}

// Contains AI-generated edits.
