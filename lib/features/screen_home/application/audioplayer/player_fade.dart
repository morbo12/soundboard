import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_mainvolume.dart';

class Fade {
  static const double MIN_VOLUME = 0.0;
  static const double MAX_VOLUME = 1.0;
  static const double VOLUME_STEP = 0.05;
  static const int MIN_STEP_DURATION = 1;

  final WidgetRef ref;
  final Logger _logger = Logger('Fade');

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
      int steps = ((to - from) / VOLUME_STEP).abs().ceil();
      int stepDuration = math.max(MIN_STEP_DURATION, duration ~/ steps);

      if (kDebugMode) {
        print('[Fade] Starting fade from $from to $to over $duration ms');
      }

      for (int i = 0; i < steps; i++) {
        await Future.delayed(Duration(milliseconds: stepDuration));
        currentVolume = _calculateNextVolume(currentVolume, to);
        await _updateVolume(currentVolume, channel, provider);

        if (_isFadeComplete(currentVolume, to, from)) break;
      }

      await _updateVolume(to, channel, provider);
      _logger.info('Fade completed. Final volume: $to');
    } catch (e) {
      _logger.severe('Error during fade: $e');
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
