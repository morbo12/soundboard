import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/audioplayers_providers.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';

class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({super.key});

  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  @override
  void initState() {
    super.initState();

    // Listen to system volume change
    Future.delayed(Duration.zero, () async {
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      jingleManagerAsync.whenData((jingleManager) {
        jingleManager.audioManager.channel1.onDurationChanged.listen((
          Duration d,
        ) {
          //get the duration of audio
          ref.read(maxdurationProviderC1.notifier).state = d;
        });

        jingleManager.audioManager.channel1.onPositionChanged.listen((
          Duration p,
        ) {
          // currentpos =
          ref.read(currentposProviderC1.notifier).state = p;
        });

        jingleManager.audioManager.channel2.onDurationChanged.listen((
          Duration d,
        ) {
          //get the duration of audio
          ref.read(maxdurationProviderC2.notifier).state = d;
        });

        jingleManager.audioManager.channel2.onPositionChanged.listen((
          Duration p,
        ) {
          ref.read(currentposProviderC2.notifier).state = p;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Return invisible widget - we only need this widget for setting up the audio listeners
    // The actual progress tracking is handled by the mini progress bars in individual buttons
    return const SizedBox.shrink();
  }
}
