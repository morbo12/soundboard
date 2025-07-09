import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

class HorizontalVUMeterVisualizer extends StatefulWidget {
  final AudioPlayer channel1;
  final AudioPlayer channel2;
  final bool isVisible;
  final double width;
  final Color color;
  static bool enableDebugLogging =
      false; // Static flag to control debug logging

  const HorizontalVUMeterVisualizer({
    super.key,
    required this.channel1,
    required this.channel2,
    required this.isVisible,
    required this.width,
    this.color = Colors.blue,
  });

  @override
  State<HorizontalVUMeterVisualizer> createState() =>
      _HorizontalVUMeterVisualizerState();
}

class _HorizontalVUMeterVisualizerState
    extends State<HorizontalVUMeterVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _currentLevel = 0.0;
  bool _isPlaying1 = false;
  bool _isPlaying2 = false;

  // Replace history with EMA
  double _emaLevel = 0.0;
  static const double _emaAlpha =
      0.3; // Higher alpha = faster response (0.0-1.0)
  double _peakLevel = 0.0;
  double _peakHoldLevel = 0.0; // New peak hold level
  static const double _peakDecayRate =
      0.92; // Slower decay for less bouncy peaks
  static const double _peakBoost = 1.05; // Smaller boost for peaks
  static const int _peakHoldFrames =
      40; // Hold peak for ~1 second (40 frames at 40fps)
  int _peakHoldCounter = 0; // Counter for peak hold duration

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 25),
          )
          ..addListener(_onAnimationTick)
          ..repeat();

    // Listen to both channels
    widget.channel1.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying1 = state == PlayerState.playing;
        });
      }
    });

    widget.channel2.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying2 = state == PlayerState.playing;
        });
      }
    });
  }

  void _onAnimationTick() {
    if (!mounted) return;

    if (!widget.isVisible || (!_isPlaying1 && !_isPlaying2)) {
      if (_currentLevel != 0.0) {
        setState(() {
          _currentLevel = 0.0;
          _emaLevel = 0.0;
          _peakLevel = 0.0;
          _peakHoldLevel = 0.0;
          _peakHoldCounter = 0;
        });
      }
      return;
    }

    // Generate levels for both channels
    final level1 = _isPlaying1 ? math.Random().nextDouble() * 0.85 + 0.15 : 0.0;
    final level2 = _isPlaying2 ? math.Random().nextDouble() * 0.85 + 0.15 : 0.0;

    // Use the maximum level between the two channels
    final rawLevel = math.max(level1, level2);

    // Calculate exponential moving average
    _emaLevel = _emaAlpha * rawLevel + (1 - _emaAlpha) * _emaLevel;

    // Update peak level with hold behavior
    final newPeakLevel = rawLevel * _peakBoost;
    if (newPeakLevel > _peakHoldLevel) {
      // New peak detected, start holding
      _peakHoldLevel = newPeakLevel;
      _peakHoldCounter = _peakHoldFrames;
    } else if (_peakHoldCounter > 0) {
      // Still in hold period
      _peakHoldCounter--;
    } else {
      // Hold period over, start decaying
      _peakHoldLevel = math.max(_peakHoldLevel * _peakDecayRate, newPeakLevel);
    }

    // Use the held peak level for visualization
    _peakLevel = _peakHoldLevel;

    // Combine EMA and peak with more emphasis on average level
    final targetLevel = (_emaLevel * 0.4 + _peakLevel * 0.6);

    // Apply smoothing with more emphasis on current level
    final newLevel = _currentLevel * 0.4 + targetLevel * 0.6;

    // Debug logging (only if enabled)
    if (HorizontalVUMeterVisualizer.enableDebugLogging) {
      developer.log('''
Horizontal VU Meter Debug:
Raw Levels: C1=${level1.toStringAsFixed(2)} C2=${level2.toStringAsFixed(2)} Max=${rawLevel.toStringAsFixed(2)}
EMA: ${_emaLevel.toStringAsFixed(2)}
Peak: ${_peakLevel.toStringAsFixed(2)} (Hold: ${_peakHoldCounter})
Target: ${targetLevel.toStringAsFixed(2)}
Current: ${_currentLevel.toStringAsFixed(2)}
New: ${newLevel.toStringAsFixed(2)}
''', name: 'HorizontalVUMeter');
    }

    setState(() {
      _currentLevel = newLevel;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onAnimationTick);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      size: Size(widget.width, 20),
      painter: HorizontalVUMeterPainter(
        level: _currentLevel,
        baseColor: widget.color,
        peakLevel: _peakLevel,
      ),
    );
  }
}

class HorizontalVUMeterPainter extends CustomPainter {
  final double level;
  final Color baseColor;
  final double peakLevel;

  HorizontalVUMeterPainter({
    required this.level,
    required this.baseColor,
    required this.peakLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barHeight = 12.0;
    final scaledLevel = level * 0.9;
    final scaledPeak = peakLevel * 0.9;
    final currentWidth = math.min(scaledLevel, 1.0) * size.width;
    final peakWidth = math.min(scaledPeak, 1.0) * size.width;
    final scaleHeight = 6.0;

    // Define color zones
    const double yellowStart = 0.6; // Start of yellow zone
    const double redStart = 0.8; // Start of red zone

    final paint = Paint()..style = PaintingStyle.fill;

    if (currentWidth > 0) {
      final leftX = 0.0;

      // Create gradient for the main bar
      final gradient = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.green,
          Colors.green,
          Colors.amber,
          Colors.amber,
          Colors.red,
        ],
        stops: [
          0.0,
          yellowStart - 0.05,
          yellowStart + 0.05,
          redStart - 0.05,
          redStart + 0.05,
        ],
      );

      // Draw the main bar
      paint.shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, barHeight),
      );
      canvas.drawRect(
        Rect.fromLTWH(leftX, scaleHeight, currentWidth, barHeight),
        paint,
      );

      // Draw peak indicator if it's higher than current level
      if (peakWidth > currentWidth) {
        // Draw a more visible line for the peak
        paint.shader = null;
        paint.color = Colors.white.withAlpha(153);
        paint.strokeWidth = 1.0;
        paint.style = PaintingStyle.stroke;

        final peakX = peakWidth;
        canvas.drawLine(
          Offset(peakX, scaleHeight - 1),
          Offset(peakX, scaleHeight + barHeight + 1),
          paint,
        );

        // Add a larger dot at the peak
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(peakX, scaleHeight + barHeight / 2),
          1.0,
          paint,
        );
      }

      // Reset shader for scale drawing
      paint.shader = null;
    }

    // Draw scale
    _drawScale(canvas, size, scaleHeight);
  }

  void _drawScale(Canvas canvas, Size size, double scaleHeight) {
    final paint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Horizontal scale points
    final scalePoints = [
      {'value': '-24', 'position': 0.0}, // Left (min)
      {'value': '-18', 'position': 0.2}, // 20%
      {'value': '-12', 'position': 0.4}, // 40%
      {'value': '-6', 'position': 0.6}, // Yellow start
      {'value': '-3', 'position': 0.8}, // Red start
      {'value': '0', 'position': 1.0}, // Right (max)
    ];

    // Draw tick marks and labels
    for (final point in scalePoints) {
      final x = size.width * (point['position'] as double);

      // Draw tick mark
      canvas.drawLine(Offset(x, 0), Offset(x, scaleHeight - 2), paint);

      // Draw label
      textPainter.text = TextSpan(
        text: point['value'] as String,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 6),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, 0));
    }
  }

  @override
  bool shouldRepaint(HorizontalVUMeterPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.peakLevel != peakLevel;
  }
}

// Contains AI-generated edits.
