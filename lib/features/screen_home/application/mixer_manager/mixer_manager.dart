import 'package:win32audio/win32audio.dart';
import 'mixer_manager_interface.dart';
import 'package:soundboard/utils/platform_utils.dart';
import 'package:soundboard/utils/logger.dart';

class MixerManager implements MixerManagerInterface {
  static final MixerManager _instance = MixerManager._internal();
  factory MixerManager() => _instance;
  MixerManager._internal();

  final Logger logger = const Logger('MixerManager');
  List<ProcessVolume>? _mixerList;
  List<AudioDevice>? _audioDevices;
  AudioDevice? _defaultOutputDevice;

  @override
  Future<void> initialize() async {
    if (!PlatformUtils.isWindows) {
      logger.d(
        'MixerManager: Windows-specific features not available on this platform',
      );
      return;
    }
    await Audio.setupChangeListener();
    await _refreshMixerList();
    await _refreshAudioDevices();
    await _refreshDefaultDevice();
  }

  Future<void> _refreshMixerList() async {
    if (!PlatformUtils.isWindows) return;
    _mixerList = await Audio.enumAudioMixer();
  }

  Future<void> _refreshAudioDevices() async {
    if (!PlatformUtils.isWindows) return;
    _audioDevices = await Audio.enumDevices(AudioDeviceType.output);
  }

  Future<void> _refreshDefaultDevice() async {
    if (!PlatformUtils.isWindows) return;
    _defaultOutputDevice = await Audio.getDefaultDevice(AudioDeviceType.output);
  }

  @override
  Future<List<ProcessVolume>> getMixerList() async {
    if (!PlatformUtils.isWindows) return [];
    if (_mixerList == null) {
      await _refreshMixerList();
    }
    return _mixerList ?? [];
  }

  @override
  Future<List<AudioDevice>> getAudioDevices() async {
    if (!PlatformUtils.isWindows) return [];
    if (_audioDevices == null) {
      await _refreshAudioDevices();
    }
    return _audioDevices ?? [];
  }

  @override
  Future<AudioDevice?> getDefaultDevice() async {
    if (!PlatformUtils.isWindows) return null;
    if (_defaultOutputDevice == null) {
      await _refreshDefaultDevice();
    }
    return _defaultOutputDevice;
  }

  @override
  Future<void> setApplicationVolume(int processId, double volume) async {
    if (!PlatformUtils.isWindows) return;
    await Audio.setAudioMixerVolume(processId, volume);
    await _refreshMixerList();
  }

  @override
  Future<double> getApplicationVolume(int processId) async {
    if (!PlatformUtils.isWindows) return 0.0;
    final mixerList = await getMixerList();
    final process = mixerList.firstWhere(
      (p) => p.processId == processId,
      orElse: () => ProcessVolume(),
    );
    return process.maxVolume;
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    if (!PlatformUtils.isWindows) return;
    await Audio.setVolume(volume, AudioDeviceType.output);
  }

  @override
  Future<double> getMasterVolume() async {
    if (!PlatformUtils.isWindows) return 0.0;
    return await Audio.getVolume(AudioDeviceType.output) ?? 0.0;
  }

  @override
  void addChangeListener(Function(String type, String id) callback) {
    if (!PlatformUtils.isWindows) return;
    Audio.addChangeListener(callback);
  }

  @override
  void removeChangeListener(Function(String type, String id) callback) {
    if (!PlatformUtils.isWindows) return;
    Audio.removeChangeListener(callback);
  }

  @override
  Future<void> setDefaultDevice(String deviceId) async {
    if (!PlatformUtils.isWindows) return;
    await Audio.setDefaultDevice(deviceId);
  }

  @override
  Future<void> switchToNextDevice() async {
    if (!PlatformUtils.isWindows) return;
    await Audio.switchDefaultDevice(
      AudioDeviceType.output,
      console: false,
      multimedia: true,
      communications: false,
    );
    await _refreshDefaultDevice();
  }
}
