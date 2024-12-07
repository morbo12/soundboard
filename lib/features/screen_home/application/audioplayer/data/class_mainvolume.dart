import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class Volume {
  final double vol;
  const Volume({required this.vol});
}

class VolumeNotifier extends StateNotifier<Volume> {
  VolumeNotifier(super.state);

  void updateVolume(double d) {
    state = Volume(vol: d);
  }
}
