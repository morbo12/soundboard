import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/utils/logger.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:soundboard/features/screen_home/presentation/volume/classes/class_waveform_visualizer.dart'
    show VUMeterVisualizer;

// Global key to access the ColumnVolume widget
final GlobalKey<_ColumnVolumeState> columnVolumeKey =
    GlobalKey<_ColumnVolumeState>();

class ColumnVolume extends ConsumerStatefulWidget {
  const ColumnVolume({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ColumnVolumeState();
}

class _ColumnVolumeState extends ConsumerState<ColumnVolume> {
  final Logger logger = const Logger('ColumnVolumeState');

  // Performance configuration

  Timer? _refreshTimer;

  // Debouncing
  final Map<String, Timer> _debounceTimers = {};

  @override
  void dispose() {
    _refreshTimer?.cancel();

    // Cancel all debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      // Set up channel listeners
      jingleManager.audioManager.channel1.onPlayerStateChanged.listen((state) {
        ref.read(c1StateProvider.notifier).state = state;
      });
      jingleManager.audioManager.channel2.onPlayerStateChanged.listen((state) {
        ref.read(c2StateProvider.notifier).state = state;
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final c1VolumeValue = ref.watch(c1VolumeProvider);
    final c2VolumeValue = ref.watch(c2VolumeProvider);
    final c1PlayerState = ref.watch(c1StateProvider);
    final c2PlayerState = ref.watch(c2StateProvider);

    final mainVolumeValue = ref.watch(mainVolumeProvider);
    final p1VolumeValue = ref.watch(p1VolumeProvider);
    final p2VolumeValue = ref.watch(p2VolumeProvider);
    final p3VolumeValue = ref.watch(p3VolumeProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // First Row with VU meter between channels
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // C1 Volume
                    Expanded(
                      child: _buildVolumeColumn(
                        'C1',
                        c1PlayerState,
                        c1VolumeValue.vol,
                        (value) {
                          ref
                              .read(c1VolumeProvider.notifier)
                              .updateVolume(value / 100);
                        },
                      ),
                    ),
                    // VU Meter in the middle
                    SizedBox(
                      width: 10,
                      child: VUMeterVisualizer(
                        channel1: jingleManager.audioManager.channel1,
                        channel2: jingleManager.audioManager.channel2,
                        isVisible: true,
                        height: 210,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    // C2 Volume
                    Expanded(
                      child: _buildVolumeColumn(
                        'C2',
                        c2PlayerState,
                        c2VolumeValue.vol,
                        (value) {
                          ref
                              .read(c2VolumeProvider.notifier)
                              .updateVolume(value / 100);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Second Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumeColumn(
                      'Master',
                      PlayerState.stopped,
                      mainVolumeValue.vol,
                      (value) {
                        ref
                            .watch(mainVolumeProvider.notifier)
                            .updateVolume(value / 100);
                      },
                      isMaster: true,
                    ),
                    _buildVolumeColumn(
                      'P1',
                      PlayerState.stopped,
                      p1VolumeValue.vol,
                      (value) {
                        ref
                            .watch(p1VolumeProvider.notifier)
                            .updateVolume(value / 100);
                      },
                    ),
                  ],
                ),
              ),

              // Third Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumeColumn(
                      'P2',
                      PlayerState.stopped,
                      p2VolumeValue.vol,
                      (value) {
                        ref
                            .watch(p2VolumeProvider.notifier)
                            .updateVolume(value / 100);
                      },
                    ),
                    _buildVolumeColumn(
                      'P3',
                      PlayerState.stopped,
                      p3VolumeValue.vol,
                      (value) {
                        ref
                            .watch(p3VolumeProvider.notifier)
                            .updateVolume(value);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVolumeColumn(
    String label,
    PlayerState playerState,
    double volumeValue,
    Function(double) onChanged, {
    bool isMaster = false,
  }) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // Volume slider
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    child: _buildCustomSlider(
                      playerState: playerState,
                      volumeValue: volumeValue,
                      onVolumeChanged: onChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildCustomText(label),
        ],
      ),
    );
  }

  Widget _buildCustomText(String text) {
    return AutoSizeText(
      text,
      style: TextStyle(
        fontSize: 8,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildCustomSlider({
    required PlayerState playerState,
    required double volumeValue,
    required Function(double) onVolumeChanged,
  }) {
    return SfSliderTheme(
      data: SfSliderThemeData(
        thumbRadius: 6,
        activeTickColor: Theme.of(context).colorScheme.surface,
        activeTrackColor: Theme.of(context).colorScheme.secondaryContainer,
        inactiveLabelStyle: const TextStyle(fontSize: 10),
        activeLabelStyle: const TextStyle(fontSize: 10),
      ),
      child: SfSlider.vertical(
        min: 0,
        max: 100,
        showDividers: true,
        interval: 10,
        stepSize: 1,
        enableTooltip: false,
        inactiveColor: Theme.of(context).colorScheme.primaryContainer,
        activeColor:
            playerState == PlayerState.playing
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.onSurface,
        onChanged: (dynamic value) => onVolumeChanged(value),
        value: volumeValue * 100,
      ),
    );
  }
}
