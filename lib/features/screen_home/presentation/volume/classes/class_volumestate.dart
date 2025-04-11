// volume_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VolumeState {
  final double vol;
  final String? processName;

  VolumeState({required this.vol, this.processName});

  VolumeState copyWith({double? vol, String? processName}) {
    return VolumeState(
      vol: vol ?? this.vol,
      processName: processName ?? this.processName,
    );
  }
}

class VolumeNotifier extends StateNotifier<VolumeState> {
  VolumeNotifier() : super(VolumeState(vol: 0.0));

  void updateVolume(double volume) {
    state = state.copyWith(vol: volume);
  }
}
