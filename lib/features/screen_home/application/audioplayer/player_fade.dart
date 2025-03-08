import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_mainvolume.dart';
import 'package:soundboard/utils/logger.dart';

class Fade {
  static const double MIN_VOLUME = 0.0;
  static const double MAX_VOLUME = 1.0;
  static const double VOLUME_STEP = 0.05;
  static const int MIN_STEP_DURATION = 1;

  final WidgetRef ref;
  final Logger _logger = const Logger('Fade');

  Fade(this.ref);

  Future<void> fade({
    required double to,
    required int duration,
    required AudioPlayer channel,
    required StateNotifierProvider<VolumeNotifier, Volume> provider,
  }) async {
    try {
      double from = channel.volume;
      double currentVolume = from;

      // Early return if volumes are already equal
      if ((to - from).abs() < 0.001) {
        // Using small epsilon for float comparison
        if (channel.playerId == "9ec5366c-f5aa-4e8e-831f-f6f07687440f") {
          _logger.d('Volumes already equal, no fade needed');
        }
        return;
      }

      int steps = ((to - from) / VOLUME_STEP).abs().ceil();

      if (steps == 0) {
        // If no steps needed, just set the final volume directly
        await _updateVolume(to, channel, provider);
        if (channel.playerId == "9ec5366c-f5aa-4e8e-831f-f6f07687440f") {
          _logger.d('Fade completed immediately. Final volume: $to');
        }
        return;
      }

      int stepDuration = math.max(MIN_STEP_DURATION, duration ~/ steps);

      if (channel.playerId == "9ec5366c-f5aa-4e8e-831f-f6f07687440f") {
        _logger.d(
            'Starting fade from $from to $to over $duration ms on channel ${channel.playerId}');
      }

      for (int i = 0; i < steps; i++) {
        if (channel.playerId == "9ec5366c-f5aa-4e8e-831f-f6f07687440f") {
          _logger.d('Step $i: $currentVolume');
        }
        await Future.delayed(Duration(milliseconds: stepDuration));
        currentVolume = _calculateNextVolume(currentVolume, to);
        await _updateVolume(currentVolume, channel, provider);

        if (_isFadeComplete(currentVolume, to, from)) break;
      }

      await _updateVolume(to, channel, provider);
      if (channel.playerId == "9ec5366c-f5aa-4e8e-831f-f6f07687440f") {
        _logger.d('Fade completed. Final volume: $to');
      }
    } catch (e) {
      _logger.d('Error during fade: $e');
    }
  }

  double _calculateNextVolume(double current, double target) {
    double next =
        target > current ? current + VOLUME_STEP : current - VOLUME_STEP;
    return (next * 100).round() / 100; // Round to 2 decimal places
  }

  Future<void> _updateVolume(double volume, AudioPlayer channel,
      StateNotifierProvider<VolumeNotifier, Volume> provider) async {
    volume = volume.clamp(MIN_VOLUME, MAX_VOLUME);
    await channel.setVolume(volume);
    ref.read(provider.notifier).updateVolume(volume);
  }

  bool _isFadeComplete(double current, double target, double start) {
    return (target < start && current <= target) ||
        (target > start && current >= target);
  }
}
