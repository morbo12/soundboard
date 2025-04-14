import 'package:win32audio/win32audio.dart';
import 'mixer_manager.dart';

class MixerManagerExample {
  final MixerManager _mixerManager = MixerManager();

  Future<void> runExample() async {
    // Initialize the mixer manager
    await _mixerManager.initialize();

    // Get list of all audio devices
    final audioDevices = await _mixerManager.getAudioDevices();
    print('Available audio devices:');
    for (var device in audioDevices) {
      print('- ${device.name} (${device.isActive ? 'Active' : 'Inactive'})');
    }

    // Get current default device
    final defaultDevice = await _mixerManager.getDefaultDevice();
    print('\nCurrent default device: ${defaultDevice?.name}');

    // Get list of all processes with audio
    final mixerList = await _mixerManager.getMixerList();
    print('\nProcesses with audio:');
    for (var process in mixerList) {
      print('- ${process.processPath} (Volume: ${process.maxVolume})');
    }

    // Set volume for a specific process
    if (mixerList.isNotEmpty) {
      final processId = mixerList.first.processId;
      await _mixerManager.setApplicationVolume(processId, 0.5);
      print('\nSet volume for ${mixerList.first.processPath} to 50%');
    }

    // Get and set master volume
    final currentMasterVolume = await _mixerManager.getMasterVolume();
    print(
      '\nCurrent master volume: ${(currentMasterVolume * 100).toStringAsFixed(0)}%',
    );

    await _mixerManager.setMasterVolume(0.75);
    print('Set master volume to 75%');

    // Listen for audio device changes
    _mixerManager.addChangeListener((type, id) {
      print('\nAudio device change detected:');
      print('Type: $type');
      print('ID: $id');
    });

    // Switch to next audio device
    await _mixerManager.switchToNextDevice();
    print('\nSwitched to next audio device');
  }
}
