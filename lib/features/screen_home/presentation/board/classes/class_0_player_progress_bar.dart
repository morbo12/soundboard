import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

class PlayerProgressBar extends ConsumerStatefulWidget {
  const PlayerProgressBar({super.key});

  @override
  ConsumerState<PlayerProgressBar> createState() => _PlayerProgressBarState();
}

class _PlayerProgressBarState extends ConsumerState<PlayerProgressBar> {
  // @override
  // void dispose() {
  //   super.dispose();
  //   // audioPlayer.dispose();
  //   // hornAudioPlayer.dispose();
  // }
  @override
  void initState() {
    super.initState();

    // Listen to system volume change
    Future.delayed(Duration.zero, () async {
      jingleManager.audioManager.channel1.onDurationChanged
          .listen((Duration d) {
        //get the duration of audio
        ref.read(maxdurationProviderC1.notifier).state = d;
      });

      jingleManager.audioManager.channel1.onPositionChanged
          .listen((Duration p) {
        // currentpos =
        ref.read(currentposProviderC1.notifier).state = p;
      });

      jingleManager.audioManager.channel2.onDurationChanged
          .listen((Duration d) {
        //get the duration of audio
        ref.read(maxdurationProviderC2.notifier).state = d;
      });

      jingleManager.audioManager.channel2.onPositionChanged
          .listen((Duration p) {
        ref.read(currentposProviderC2.notifier).state = p;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // AudioPlayer.global.changeLogLevel(LogLevel.none);
    final currentPosC1 = ref.watch(currentposProviderC1);
    final maxdurationC1 = ref.watch(maxdurationProviderC1);
    final currentPosC2 = ref.watch(currentposProviderC2);
    final maxdurationC2 = ref.watch(maxdurationProviderC2);

    return Column(
      children: [
        // Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //   children: [
        //     AutoSizeText(
        //       "Progress",
        //       style: TextStyle(
        //           fontSize: 6,
        //           fontWeight: FontWeight.bold,
        //           color: Theme.of(context).colorScheme.onBackground),
        //     ),
        //   ],
        // ),
        Row(
          children: [
            Expanded(
              // child: Text(currentpos.inMilliseconds.toString()),
              child: ProgressBar(
                thumbRadius: 4,
                progress: currentPosC1,
                // buffered: buffered,
                total: maxdurationC1,
                onSeek: (duration) {},
                progressBarColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                thumbColor: Theme.of(context).colorScheme.onSecondaryContainer,
                baseBarColor: Theme.of(context).colorScheme.onInverseSurface,
                timeLabelLocation: TimeLabelLocation.sides,
                timeLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14),
              ),
              // child: Slider(
              //   value: double.parse(currentpos.toString()),
              //   min: 0,
              //   max: double.parse(maxduration.toString()),
              //   divisions: maxduration,
              //   label: currentpostlabel,
              //   activeColor: Theme.of(context).colorScheme.onBackground,
              //   onChanged: (double value) {},
              // ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ProgressBar(
                thumbRadius: 4,
                progress: currentPosC2,
                // buffered: buffered,
                total: maxdurationC2,
                onSeek: (duration) {},
                progressBarColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                thumbColor: Theme.of(context).colorScheme.onSecondaryContainer,
                baseBarColor: Theme.of(context).colorScheme.onInverseSurface,
                timeLabelLocation: TimeLabelLocation.sides,
                timeLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
