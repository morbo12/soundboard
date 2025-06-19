import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/audioplayers_providers.dart';
import 'package:soundboard/core/providers/volume_providers.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/services/volume_control_service.dart';
import 'package:soundboard/core/utils/logger.dart';
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
  late final VolumeControlService _volumeControlService;

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

    // Initialize volume control service
    _volumeControlService = ref.read(volumeControlServiceProvider);

    Future.delayed(Duration.zero, () {
      // Set up channel listeners
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      jingleManagerAsync.whenData((jingleManager) {
        jingleManager.audioManager.channel1.onPlayerStateChanged.listen((
          state,
        ) {
          ref.read(c1StateProvider.notifier).state = state;
        });
        jingleManager.audioManager.channel2.onPlayerStateChanged.listen((
          state,
        ) {
          ref.read(c2StateProvider.notifier).state = state;
        });
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
                    ), // VU Meter in the middle
                    Column(
                      children: [
                        _buildCustomText(' '),
                        _buildCustomText(' '),
                        Expanded(
                          child: SizedBox(
                            width: 10,
                            child: Consumer(
                              builder: (context, ref, child) {
                                final jingleManagerAsync = ref.watch(
                                  jingleManagerProvider,
                                );
                                return jingleManagerAsync.when(
                                  data: (jingleManager) => VUMeterVisualizer(
                                    channel1:
                                        jingleManager.audioManager.channel1,
                                    channel2:
                                        jingleManager.audioManager.channel2,
                                    isVisible: true,
                                    height: double.infinity - 129,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                  loading: () => const SizedBox.shrink(),
                                  error: (error, stack) =>
                                      const SizedBox.shrink(),
                                );
                              },
                            ),
                          ),
                        ),
                        _buildCustomText(' '),
                        _buildCustomText('VU'),
                      ],
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
              ), // Second Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildVolumeColumn(
                        'Master',
                        PlayerState.stopped,
                        mainVolumeValue.vol,
                        (value) {
                          _volumeControlService.updateVolumeFromUI(
                            0,
                            value / 100,
                          );
                        },
                        isMaster: true,
                      ),
                    ),
                    Expanded(
                      child: _buildVolumeColumn(
                        'P1',
                        PlayerState.stopped,
                        p1VolumeValue.vol,
                        (value) {
                          _volumeControlService.updateVolumeFromUI(
                            1,
                            value / 100,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ), // Third Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: _buildVolumeColumn(
                        'P2',
                        PlayerState.stopped,
                        p2VolumeValue.vol,
                        (value) {
                          _volumeControlService.updateVolumeFromUI(
                            2,
                            value / 100,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildVolumeColumn(
                        'P3',
                        PlayerState.stopped,
                        p3VolumeValue.vol,
                        (value) {
                          _volumeControlService.updateVolumeFromUI(
                            3,
                            value / 100,
                          );
                        },
                      ),
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
    return Column(
      children: [
        Expanded(
          child: _buildCustomSlider(
            playerState: playerState,
            volumeValue: volumeValue,
            onVolumeChanged: onChanged,
          ),
        ),
        _buildCustomText(label),
      ],
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
        activeColor: playerState == PlayerState.playing
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.onSurface,
        onChanged: (dynamic value) => onVolumeChanged(value),
        value: volumeValue * 100,
      ),
    );
  }
}

// Contains AI-generated edits.
