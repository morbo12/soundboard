import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/features/screen_home/application/mixer_manager/mixer_manager_interface.dart';
import 'package:win32audio/win32audio.dart';

// Custom mock implementations
class MockProcessVolume implements ProcessVolume {
  @override
  int _processId;
  @override
  double _maxVolume;
  @override
  double _peakVolume;
  @override
  String _processPath;

  MockProcessVolume({
    int processId = 1,
    double maxVolume = 1.0,
    double peakVolume = 0.0,
    String processPath = 'test_process.exe',
  }) : _processId = processId,
       _maxVolume = maxVolume,
       _peakVolume = peakVolume,
       _processPath = processPath;

  @override
  int get processId => _processId;

  @override
  set processId(int value) => _processId = value;

  @override
  double get maxVolume => _maxVolume;

  @override
  set maxVolume(double value) => _maxVolume = value;

  @override
  double get peakVolume => _peakVolume;

  @override
  set peakVolume(double value) => _peakVolume = value;

  @override
  String get processPath => _processPath;

  @override
  set processPath(String value) => _processPath = value;

  @override
  Map<String, dynamic> toMap() => {
    'processId': processId,
    'maxVolume': maxVolume,
    'peakVolume': peakVolume,
    'processPath': processPath,
  };
}

class MockAudioDevice implements AudioDevice {
  @override
  String _id;
  @override
  String _name;
  @override
  bool _isActive;
  @override
  int _iconID;
  @override
  String _iconPath;
  @override
  bool _isDefault;
  @override
  bool _isMuted;
  @override
  double _volume;

  MockAudioDevice({
    String id = 'test_device_1',
    String name = 'Test Device',
    bool isActive = true,
    int iconID = 0,
    String iconPath = '',
    bool isDefault = false,
    bool isMuted = false,
    double volume = 1.0,
  }) : _id = id,
       _name = name,
       _isActive = isActive,
       _iconID = iconID,
       _iconPath = iconPath,
       _isDefault = isDefault,
       _isMuted = isMuted,
       _volume = volume;

  @override
  String get id => _id;

  @override
  set id(String value) => _id = value;

  @override
  String get name => _name;

  @override
  set name(String value) => _name = value;

  @override
  bool get isActive => _isActive;

  @override
  set isActive(bool value) => _isActive = value;

  @override
  int get iconID => _iconID;

  @override
  set iconID(int value) => _iconID = value;

  @override
  String get iconPath => _iconPath;

  @override
  set iconPath(String value) => _iconPath = value;

  @override
  bool get isDefault => _isDefault;

  @override
  set isDefault(bool value) => _isDefault = value;

  @override
  bool get isMuted => _isMuted;

  @override
  set isMuted(bool value) => _isMuted = value;

  @override
  double get volume => _volume;

  @override
  set volume(double value) => _volume = value;

  @override
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'isActive': isActive,
    'iconID': iconID,
    'iconPath': iconPath,
    'isDefault': isDefault,
    'isMuted': isMuted,
    'volume': volume,
  };
}

class MockMixerManager implements MixerManagerInterface {
  final List<MockProcessVolume> _processes = [];
  final List<MockAudioDevice> _devices = [];
  MockAudioDevice? _defaultDevice;
  double _masterVolume = 1.0;
  final List<Function(String, String)> _listeners = [];

  @override
  Future<void> initialize() async {
    // Initialize with test data
    _processes.addAll([
      MockProcessVolume(processId: 1, processPath: 'process1.exe'),
      MockProcessVolume(processId: 2, processPath: 'process2.exe'),
    ]);
    _devices.addAll([
      MockAudioDevice(id: 'device1', name: 'Device 1'),
      MockAudioDevice(id: 'device2', name: 'Device 2'),
    ]);
    _defaultDevice = _devices.first;
  }

  @override
  Future<List<ProcessVolume>> getMixerList() async => _processes;

  @override
  Future<List<AudioDevice>> getAudioDevices() async => _devices;

  @override
  Future<AudioDevice?> getDefaultDevice() async => _defaultDevice;

  @override
  Future<void> setApplicationVolume(int processId, double volume) async {
    final process = _processes.firstWhere(
      (p) => p.processId == processId,
      orElse: () => throw Exception('Process not found'),
    );
    process.maxVolume = volume;
  }

  @override
  Future<double> getApplicationVolume(int processId) async {
    final process = _processes.firstWhere(
      (p) => p.processId == processId,
      orElse: () => throw Exception('Process not found'),
    );
    return process.maxVolume;
  }

  @override
  Future<void> setMasterVolume(double volume) async {
    _masterVolume = volume.clamp(0.0, 1.0);
  }

  @override
  Future<double> getMasterVolume() async => _masterVolume;

  @override
  void addChangeListener(Function(String type, String id) callback) {
    _listeners.add(callback);
  }

  @override
  void removeChangeListener(Function(String type, String id) callback) {
    _listeners.remove(callback);
  }

  @override
  Future<void> setDefaultDevice(String deviceId) async {
    _defaultDevice = _devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => throw Exception('Device not found'),
    );
  }

  @override
  Future<void> switchToNextDevice() async {
    if (_devices.isEmpty) return;
    final currentIndex = _devices.indexOf(_defaultDevice!);
    final nextIndex = (currentIndex + 1) % _devices.length;
    _defaultDevice = _devices[nextIndex];
  }

  // Helper method to simulate device changes for testing
  void simulateDeviceChange(String type, String id) {
    for (final listener in _listeners) {
      listener(type, id);
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockMixerManager mixerManager;

  setUp(() async {
    mixerManager = MockMixerManager();
    await mixerManager.initialize();
  });

  group('MixerManager Initialization', () {
    test('initialize sets up initial state', () async {
      final processes = await mixerManager.getMixerList();
      final devices = await mixerManager.getAudioDevices();
      final defaultDevice = await mixerManager.getDefaultDevice();

      expect(processes.length, equals(2));
      expect(devices.length, equals(2));
      expect(defaultDevice, isNotNull);
    });
  });

  group('Audio Device Management', () {
    test('getAudioDevices returns list of devices', () async {
      final devices = await mixerManager.getAudioDevices();
      expect(devices.length, equals(2));
      expect(devices.first.name, equals('Device 1'));
      expect(devices.last.name, equals('Device 2'));
    });

    test('getDefaultDevice returns current default device', () async {
      final defaultDevice = await mixerManager.getDefaultDevice();
      expect(defaultDevice, isNotNull);
      expect(defaultDevice?.name, equals('Device 1'));
    });

    test('setDefaultDevice changes default device', () async {
      final devices = await mixerManager.getAudioDevices();
      final newDeviceId = devices.last.id;

      await mixerManager.setDefaultDevice(newDeviceId);
      final updatedDefault = await mixerManager.getDefaultDevice();

      expect(updatedDefault?.id, equals(newDeviceId));
      expect(updatedDefault?.name, equals('Device 2'));
    });

    test('switchToNextDevice cycles through devices', () async {
      final devices = await mixerManager.getAudioDevices();
      final initialDefault = await mixerManager.getDefaultDevice();
      final initialIndex = devices.indexOf(initialDefault!);

      await mixerManager.switchToNextDevice();
      final newDefault = await mixerManager.getDefaultDevice();
      final newIndex = devices.indexOf(newDefault!);

      expect(newIndex, equals((initialIndex + 1) % devices.length));
      expect(newDefault.name, equals('Device 2'));
    });
  });

  group('Volume Control', () {
    test('setMasterVolume clamps values between 0 and 1', () async {
      await mixerManager.setMasterVolume(1.5);
      expect(await mixerManager.getMasterVolume(), equals(1.0));

      await mixerManager.setMasterVolume(-0.5);
      expect(await mixerManager.getMasterVolume(), equals(0.0));

      await mixerManager.setMasterVolume(0.5);
      expect(await mixerManager.getMasterVolume(), equals(0.5));
    });

    test('setApplicationVolume updates process volume', () async {
      final processes = await mixerManager.getMixerList();
      final processId = processes.first.processId;
      const testVolume = 0.75;

      await mixerManager.setApplicationVolume(processId, testVolume);
      final volume = await mixerManager.getApplicationVolume(processId);

      expect(volume, equals(testVolume));
    });

    test('setApplicationVolume throws for invalid process ID', () async {
      expect(
        () => mixerManager.setApplicationVolume(999, 0.5),
        throwsException,
      );
    });
  });

  group('Event Listeners', () {
    test('addChangeListener and removeChangeListener manage listeners', () {
      var callbackCalled = false;
      void callback(String type, String id) {
        callbackCalled = true;
      }

      mixerManager.addChangeListener(callback);
      mixerManager.simulateDeviceChange('device', 'test_device_1');
      expect(callbackCalled, isTrue);

      callbackCalled = false;
      mixerManager.removeChangeListener(callback);
      mixerManager.simulateDeviceChange('device', 'test_device_1');
      expect(callbackCalled, isFalse);
    });
  });
}
