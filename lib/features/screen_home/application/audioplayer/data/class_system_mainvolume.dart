import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SystemVolume {
  final double vol;
  const SystemVolume({required this.vol});
}

class SystemVolumeNotifier extends StateNotifier<SystemVolume> {
  SystemVolumeNotifier(super.state);

  void updateVolume(double d) {
    state = SystemVolume(vol: d);
  }
}
