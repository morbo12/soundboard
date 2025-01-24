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
        ref.read(maxdurationProvider.notifier).state = d;

        // setState(() {
        //   // maxduration = d.inMilliseconds;
        //   maxduration = d;
        //   // print("ONDURATIONCHANGED" + d.toString());
        // });
      });

      jingleManager.audioManager.channel1.onPositionChanged
          .listen((Duration p) {
        // currentpos =
        // p.inMilliseconds; //get the current position of playing audio
        ref.read(currentposProvider.notifier).state = p;
        // setState(() {
        //   // currentpos = p;
        //   // Duration sec = Duration(milliseconds: maxduration - currentpos);
        //   // currentpostlabel = "${sec.inMilliseconds} ms";
        //   // print("ONPOSCHANGED" + p.toString());
        // });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // AudioPlayer.global.changeLogLevel(LogLevel.none);
    final currentPos = ref.watch(currentposProvider);
    final maxduration = ref.watch(maxdurationProvider);

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
                progress: currentPos,
                // buffered: buffered,
                total: maxduration,
                onSeek: (duration) {},
                progressBarColor:
                    Theme.of(context).colorScheme.onSecondaryContainer,
                thumbColor: Theme.of(context).colorScheme.onSecondaryContainer,
                baseBarColor: Theme.of(context).colorScheme.onInverseSurface,
                timeLabelLocation: TimeLabelLocation.sides,
                timeLabelTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.surface, fontSize: 10),
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
      ],
    );
  }
}
