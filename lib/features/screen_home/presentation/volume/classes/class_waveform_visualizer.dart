import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:developer' as developer;

class VUMeterVisualizer extends StatefulWidget {
  final AudioPlayer channel1;
  final AudioPlayer channel2;
  final bool isVisible;
  final double height;
  final Color color;
  static bool enableDebugLogging =
      false; // Static flag to control debug logging

  const VUMeterVisualizer({
    super.key,
    required this.channel1,
    required this.channel2,
    required this.isVisible,
    required this.height,
    this.color = Colors.blue,
  });

  @override
  State<VUMeterVisualizer> createState() => _VUMeterVisualizerState();
}

class _VUMeterVisualizerState extends State<VUMeterVisualizer>
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
    if (VUMeterVisualizer.enableDebugLogging) {
      developer.log('''
VU Meter Debug:
Raw Levels: C1=${level1.toStringAsFixed(2)} C2=${level2.toStringAsFixed(2)} Max=${rawLevel.toStringAsFixed(2)}
EMA: ${_emaLevel.toStringAsFixed(2)}
Peak: ${_peakLevel.toStringAsFixed(2)} (Hold: ${_peakHoldCounter})
Target: ${targetLevel.toStringAsFixed(2)}
Current: ${_currentLevel.toStringAsFixed(2)}
New: ${newLevel.toStringAsFixed(2)}
Final Height: ${(newLevel * 0.9).toStringAsFixed(2)} (Yellow: ${(0.6 * 0.9).toStringAsFixed(2)}, Red: ${(0.8 * 0.9).toStringAsFixed(2)})
''', name: 'VUMeter');
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
      size: Size(10, widget.height),
      painter: VUMeterPainter(
        level: _currentLevel,
        baseColor: widget.color,
        peakLevel: _peakLevel,
      ),
    );
  }
}

class VUMeterPainter extends CustomPainter {
  final double level;
  final Color baseColor;
  final double peakLevel;

  VUMeterPainter({
    required this.level,
    required this.baseColor,
    required this.peakLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = 4.0;
    final scaledLevel = level * 0.9;
    final scaledPeak = peakLevel * 0.9;
    final currentHeight = math.min(scaledLevel, 1.0) * size.height;
    final peakHeight = math.min(scaledPeak, 1.0) * size.height;
    final scaleWidth = 6.0;

    // Define color zones
    const double yellowStart = 0.6; // Start of yellow zone
    const double redStart = 0.8; // Start of red zone

    final paint = Paint()..style = PaintingStyle.fill;

    if (currentHeight > 0) {
      final bottomY = size.height - currentHeight;

      // Create gradient for the main bar
      final gradient = const LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
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
        Rect.fromLTWH(0, 0, barWidth, size.height),
      );
      canvas.drawRect(
        Rect.fromLTWH(scaleWidth, bottomY, barWidth, currentHeight),
        paint,
      );

      // Draw peak indicator if it's higher than current level
      if (peakHeight > currentHeight) {
        // Draw a more visible line for the peak
        paint.shader = null;
        paint.color = Colors.white.withOpacity(0.6); // Increased opacity
        paint.strokeWidth = 1.0; // Thicker line
        paint.style = PaintingStyle.stroke;

        final peakY = size.height - peakHeight;
        canvas.drawLine(
          Offset(scaleWidth - 1, peakY), // Extended line
          Offset(scaleWidth + barWidth + 1, peakY), // Extended line
          paint,
        );

        // Add a larger dot at the peak
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(scaleWidth + barWidth / 2, peakY),
          1.0, // Larger dot
          paint,
        );
      }

      // Reset shader for scale drawing
      paint.shader = null;
    }

    // Draw scale
    _drawScale(canvas, size, scaleWidth);
  }

  void _drawScale(Canvas canvas, Size size, double scaleWidth) {
    final paint =
        Paint()
          ..color = Colors.grey.shade600
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.5;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Adjust scale points to match color zones
    final scalePoints = [
      {'value': '0', 'position': 0.0}, // Top (max)
      {'value': '-6', 'position': 0.2}, // 20%
      {'value': '-12', 'position': 0.4}, // 40%
      {'value': '-18', 'position': 0.6}, // Yellow start
      {'value': '-21', 'position': 0.8}, // Red start
      {'value': '-24', 'position': 1.0}, // Bottom (min)
    ];

    // Draw tick marks and labels
    for (final point in scalePoints) {
      final y = size.height * (point['position'] as double);

      // Draw tick mark
      canvas.drawLine(Offset(scaleWidth - 2, y), Offset(scaleWidth, y), paint);

      // Draw label
      textPainter.text = TextSpan(
        text: point['value'] as String,
        style: TextStyle(color: Colors.grey.shade600, fontSize: 6),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(scaleWidth - 4 - textPainter.width, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(VUMeterPainter oldDelegate) {
    return oldDelegate.level != level ||
        oldDelegate.baseColor != baseColor ||
        oldDelegate.peakLevel != peakLevel;
  }
}
