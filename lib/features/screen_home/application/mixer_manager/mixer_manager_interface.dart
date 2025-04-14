import 'package:win32audio/win32audio.dart';

abstract class MixerManagerInterface {
  Future<void> initialize();
  Future<List<ProcessVolume>> getMixerList();
  Future<List<AudioDevice>> getAudioDevices();
  Future<AudioDevice?> getDefaultDevice();
  Future<void> setApplicationVolume(int processId, double volume);
  Future<double> getApplicationVolume(int processId);
  Future<void> setMasterVolume(double volume);
  Future<double> getMasterVolume();
  void addChangeListener(Function(String type, String id) callback);
  void removeChangeListener(Function(String type, String id) callback);
  Future<void> setDefaultDevice(String deviceId);
  Future<void> switchToNextDevice();
}
