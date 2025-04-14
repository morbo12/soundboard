import 'package:win32audio/win32audio.dart';
import 'mixer_manager_interface.dart';

class MixerManager implements MixerManagerInterface {
  static final MixerManager _instance = MixerManager._internal();
  factory MixerManager() => _instance;
  MixerManager._internal();

  List<ProcessVolume>? _mixerList;
  List<AudioDevice>? _audioDevices;
  AudioDevice? _defaultOutputDevice;

  @override
  Future<void> initialize() async {
    await Audio.setupChangeListener();
    await _refreshMixerList();
    await _refreshAudioDevices();
    await _refreshDefaultDevice();
  }

  Future<void> _refreshMixerList() async {
    _mixerList = await Audio.enumAudioMixer();
  }

  Future<void> _refreshAudioDevices() async {
    _audioDevices = await Audio.enumDevices(AudioDeviceType.output);
  }

  Future<void> _refreshDefaultDevice() async {
    _defaultOutputDevice = await Audio.getDefaultDevice(AudioDeviceType.output);
  }

  @override
  Future<List<ProcessVolume>> getMixerList() async {
    if (_mixerList == null) {
      await _refreshMixerList();
    }
    return _mixerList ?? [];
  }

  @override
  Future<List<AudioDevice>> getAudioDevices() async {
    if (_audioDevices == null) {
      await _refreshAudioDevices();
    }
    return _audioDevices ?? [];
  }

  @override
  Future<AudioDevice?> getDefaultDevice() async {
    if (_defaultOutputDevice == null) {
      await _refreshDefaultDevice();
    }
    return _defaultOutputDevice;
  }

  @override
  Future<void> setApplicationVolume(int processId, double volume) async {
    await Audio.setAudioMixerVolume(processId, volume);
    await _refreshMixerList();
  }

  @override
  Future<double> getApplicationVolume(int processId) async {
    final mixerList = await getMixerList();
    final process = mixerList.firstWhere(
      (p) => p.processId == processId,
      orElse: () => ProcessVolume(),
    );
    return process.maxVolume;
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    await Audio.setVolume(volume, AudioDeviceType.output);
  }

  @override
  Future<double> getMasterVolume() async {
    return await Audio.getVolume(AudioDeviceType.output) ?? 0.0;
  }

  @override
  void addChangeListener(Function(String type, String id) callback) {
    Audio.addChangeListener(callback);
  }

  @override
  void removeChangeListener(Function(String type, String id) callback) {
    Audio.removeChangeListener(callback);
  }

  @override
  Future<void> setDefaultDevice(String deviceId) async {
    await Audio.setDefaultDevice(
      deviceId,
      console: false,
      multimedia: true,
      communications: false,
    );
    await _refreshDefaultDevice();
  }

  @override
  Future<void> switchToNextDevice() async {
    await Audio.switchDefaultDevice(
      AudioDeviceType.output,
      console: false,
      multimedia: true,
      communications: false,
    );
    await _refreshDefaultDevice();
  }
}
