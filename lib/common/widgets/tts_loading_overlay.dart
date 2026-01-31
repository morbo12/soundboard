import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

/// Loading overlay with spinning ArenaVox logo and status messages
/// shown during TTS generation
class TtsLoadingOverlay extends StatefulWidget {
  const TtsLoadingOverlay({super.key});

  @override
  State<TtsLoadingOverlay> createState() => _TtsLoadingOverlayState();
}

class _TtsLoadingOverlayState extends State<TtsLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _messageTimer;
  int _currentMessageIndex = 0;

  final List<String> _loadingMessages = [
    'Förbereder röst...',
    'Genererar ljud...',
    'Bearbetar text...',
    'Skapar annonsering...',
    'Optimerar kvalitet...',
    'Mixar ljudfiler...',
    'Nästan klar...',
    'Laddar röstdata...',
    'Bygger meddelande...',
    'Justerar tonhöjd...',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Shuffle messages for variety
    _loadingMessages.shuffle(Random());

    // Change message every 1.5 seconds
    _messageTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _currentMessageIndex =
              (_currentMessageIndex + 1) % _loadingMessages.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _messageTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spinning logo
              RotationTransition(
                turns: _controller,
                child: Image.asset(
                  'assets/ArenaVox_logo.png',
                  width: 120,
                  height: 120,
                ),
              ),
              const SizedBox(height: 24),
              // Status message
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  _loadingMessages[_currentMessageIndex],
                  key: ValueKey<int>(_currentMessageIndex),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
