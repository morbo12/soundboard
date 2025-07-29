import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/audioplayers_providers.dart';
import 'package:soundboard/core/providers/volume_providers.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/services/volume_control_service_v2.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:audioplayers/audioplayers.dart';

class HorizontalVolumeControl extends ConsumerStatefulWidget {
  const HorizontalVolumeControl({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _HorizontalVolumeControlState();
}

class _HorizontalVolumeControlState
    extends ConsumerState<HorizontalVolumeControl> {
  @override
  void initState() {
    super.initState();

    // Listen to system volume change
    Future.delayed(Duration.zero, () async {
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
  Widget build(BuildContext context) {
    // Initialize volume control service with ref
    final volumeControlService = VolumeControlServiceV2(ref);

    final c1VolumeValue = ref.watch(c1VolumeProvider);
    final c2VolumeValue = ref.watch(c2VolumeProvider);
    final c1PlayerState = ref.watch(c1StateProvider);
    final c2PlayerState = ref.watch(c2StateProvider);

    final mainVolumeValue = ref.watch(mainVolumeProvider);
    final p1VolumeValue = ref.watch(
      p1VolumeProvider,
    ); // Used for External slider

    return Consumer(
      builder: (context, ref, child) {
        final jingleManagerAsync = ref.watch(jingleManagerProvider);
        return jingleManagerAsync.when(
          data: (jingleManager) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row of all vertical sliders
              SizedBox(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // C1 Volume (AudioPlayer Channel 1)
                    Expanded(
                      child: _buildVerticalVolumeColumn(
                        'C1',
                        c1PlayerState,
                        c1VolumeValue.vol,
                        (value) {
                          volumeControlService.updateVolumeFromUI(
                            4, // C1 = index 4
                            value / 100,
                          );
                        },
                      ),
                    ),
                    // C2 Volume (AudioPlayer Channel 2)
                    Expanded(
                      child: _buildVerticalVolumeColumn(
                        'C2',
                        c2PlayerState,
                        c2VolumeValue.vol,
                        (value) {
                          volumeControlService.updateVolumeFromUI(
                            5, // C2 = index 5
                            value / 100,
                          );
                        },
                      ),
                    ),
                    // Master Volume (Windows Master)
                    Expanded(
                      child: _buildVerticalVolumeColumn(
                        'Master',
                        PlayerState.stopped,
                        mainVolumeValue.vol,
                        (value) {
                          volumeControlService.updateVolumeFromUI(
                            0, // Master = index 0
                            value / 100,
                          );
                        },
                      ),
                    ),
                    // External Process Volume (configurable via Deej when connected)
                    Expanded(
                      child: _buildVerticalVolumeColumn(
                        'External',
                        PlayerState.stopped,
                        p1VolumeValue.vol, // Use P1 provider for external
                        (value) {
                          volumeControlService.updateVolumeFromUI(
                            1, // External = index 1 (P1)
                            value / 100,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // const SizedBox(height: 8),
              // // Horizontal VU meter
              // SizedBox(
              //   height: 20,
              //   child: HorizontalVUMeterVisualizer(
              //     channel1: jingleManager.audioManager.channel1,
              //     channel2: jingleManager.audioManager.channel2,
              //     isVisible: true,
              //     width: double.infinity,
              //     color: Theme.of(context).colorScheme.primary,
              //   ),
              // ),
            ],
          ),
          loading: () => const SizedBox(height: 148), // 120 + 8 + 20
          error: (error, stack) => const SizedBox(height: 148),
        );
      },
    );
  }

  Widget _buildVerticalVolumeColumn(
    String label,
    PlayerState playerState,
    double volumeValue,
    Function(double) onChanged,
  ) {
    return Column(
      children: [
        Expanded(
          child: _buildVerticalSlider(
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

  Widget _buildVerticalSlider({
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
        interval: 25,
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
