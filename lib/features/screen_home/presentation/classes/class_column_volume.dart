import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:audioplayers/audioplayers.dart';

class ColumnVolume extends ConsumerStatefulWidget {
  const ColumnVolume({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ColumnVolumeState();
}

class _ColumnVolumeState extends ConsumerState<ColumnVolume> {
  late double bgVol = 0;
  void initState() {
    super.initState();

    // Listen to system volume change
    Future.delayed(Duration.zero, () async {
      jingleManager.audioManager.channel1.onPlayerStateChanged.listen((state) {
        ref.read(c1StateProvider.notifier).state = state;
      });
      jingleManager.audioManager.channel2.onPlayerStateChanged.listen((state) {
        ref.read(c2StateProvider.notifier).state = state;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final c1VolumeValue = ref.watch(c1VolumeProvider);
    final c2VolumeValue = ref.watch(c2VolumeProvider);
    final c1PlayerState = ref.watch(c1StateProvider);
    final c2PlayerState = ref.watch(c2StateProvider);
    // ref.read(c2ColorProvider.notifier).state =
    //     Theme.of(context).colorScheme.onPrimaryContainer;
    return SizedBox(
      // width: 150,
      child: Row(
        children: [
          // Column(children: [
          //   AutoSizeText(
          //     'MAIN',
          //     style: TextStyle(
          //         fontSize: 6,
          //         fontWeight: FontWeight.bold,
          //         color: Theme.of(context).colorScheme.onSurface),
          //   ),
          //   Expanded(
          //     // flex: 1,
          //     child: SfSliderTheme(
          //       data: SfSliderThemeData(
          //         thumbRadius: 6,
          //         activeTickColor: Theme.of(context).colorScheme.surface,
          //         activeTrackColor:
          //             Theme.of(context).colorScheme.secondaryContainer,
          //         inactiveLabelStyle: const TextStyle(
          //           fontSize: 10,
          //         ),
          //         activeLabelStyle: const TextStyle(
          //           fontSize: 10,
          //         ),
          //       ),
          //       child: SfSlider.vertical(
          //         // Slider properties
          //         min: 0,
          //         max: 100,
          //         stepSize: 1,
          //         showTicks: true,
          //         showLabels: true,
          //         showDividers: true,
          //         interval: 10,
          //         enableTooltip: false,
          //         inactiveColor: Theme.of(context).colorScheme.primaryContainer,
          //         activeColor: Theme.of(context).colorScheme.onPrimaryContainer,
          //         onChanged: (dynamic value) {
          //           // Set the volume using VolumeController
          //           FlutterVolumeController.setVolume(value / 100);
          //           ref
          //               .read(mainVolumeProvider.notifier)
          //               .updateVolume(value / 100);
          //           // Trigger a state update to reflect the new value
          //           setState(() {});
          //         },
          //         // The slider's current value based on setVolumeValue (between 0 and 1)
          //         value: mainVolumeValue.vol * 100,
          //       ),
          //     ),
          //   ),
          // ]),
          Column(children: [
            AutoSizeText(
              'C1',
              style: TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            Expanded(
              // flex: 1,
              child: SfSliderTheme(
                data: SfSliderThemeData(
                  thumbRadius: 6,
                  activeTickColor: Theme.of(context).colorScheme.surface,
                  activeTrackColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  inactiveLabelStyle: const TextStyle(
                    fontSize: 10,
                  ),
                  activeLabelStyle: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                child: SfSlider.vertical(
                  // Slider properties
                  min: 0,
                  max: 100,
                  // showTicks: true,
                  // showLabels: true,
                  showDividers: true,
                  interval: 10,
                  stepSize: 1,
                  enableTooltip: false,
                  inactiveColor: Theme.of(context).colorScheme.primaryContainer,
                  activeColor: c1PlayerState == PlayerState.playing
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.onSurface,
                  onChanged: (dynamic value) {
                    jingleManager.audioManager.channel1.setVolume(value / 100);
                    ref
                        .read(c1VolumeProvider.notifier)
                        .updateVolume(value / 100);
                    setState(() {});
                  },
                  // The slider's current value based on setVolumeValue (between 0 and 1)
                  value: c1VolumeValue.vol * 100,
                ),
              ),
            ),
          ]),
          Column(children: [
            AutoSizeText(
              'C2',
              style: TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface),
            ),
            Expanded(
              // flex: 1,
              child: SfSliderTheme(
                data: SfSliderThemeData(
                  thumbRadius: 6,
                  activeTickColor: Theme.of(context).colorScheme.surface,
                  activeTrackColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  inactiveLabelStyle: const TextStyle(
                    fontSize: 10,
                  ),
                  activeLabelStyle: const TextStyle(
                    fontSize: 10,
                  ),
                ),
                child: SfSlider.vertical(
                  // Slider properties
                  min: 0,
                  max: 100,
                  // showTicks: true,
                  // showLabels: true,
                  showDividers: true,
                  stepSize: 1,
                  interval: 10,
                  enableTooltip: false,
                  inactiveColor: Theme.of(context).colorScheme.primaryContainer,
                  activeColor: c2PlayerState == PlayerState.playing
                      ? Theme.of(context).colorScheme.errorContainer
                      : Theme.of(context).colorScheme.onSurface,
                  onChanged: (dynamic value) {
                    // Set the volume using VolumeController
                    jingleManager.audioManager.channel2.setVolume(value / 100);
                    ref
                        .read(c2VolumeProvider.notifier)
                        .updateVolume(value / 100);
                    setState(() {});
                  },
                  // The slider's current value based on setVolumeValue (between 0 and 1)
                  value: c2VolumeValue.vol * 100,
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
