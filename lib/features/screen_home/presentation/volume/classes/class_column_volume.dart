import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libserialport/flutter_libserialport.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/screen_home/presentation/volume/classes/class_serial_IO.dart';
import 'package:soundboard/features/screen_home/presentation/volume/classes/class_serial_processor.dart';
import 'package:soundboard/properties.dart';
import 'package:soundboard/utils/logger.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:win32audio/win32audio.dart';
import 'dart:convert';

// Global key to access the ColumnVolume widget
final GlobalKey<_ColumnVolumeState> columnVolumeKey =
    GlobalKey<_ColumnVolumeState>();

// Provider to manage serial port connection
final serialPortProvider = StateNotifierProvider<SerialPortNotifier, bool>((
  ref,
) {
  return SerialPortNotifier();
});

class SerialPortNotifier extends StateNotifier<bool> {
  SerialPortNotifier() : super(false);

  void connect() {
    state = true;
  }

  void disconnect() {
    state = false;
  }
}

class ColumnVolume extends ConsumerStatefulWidget {
  const ColumnVolume({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ColumnVolumeState();
}

class _ColumnVolumeState extends ConsumerState<ColumnVolume> {
  final AudioDeviceType audioDeviceType = AudioDeviceType.output;
  final Logger logger = const Logger('ColumnVolumeState');

  // Performance configuration
  static const int _refreshIntervalSeconds = 3; // Reduced from 1 second
  static const int _serialReconnectIntervalSeconds = 5;
  static const int _volumeDebounceMilliseconds = 50;

  Timer? _refreshTimer;
  Timer? _serialReconnectTimer;
  AudioDevice defaultDevice = AudioDevice();
  List<AudioDevice> audioDevices = <AudioDevice>[];

  // Process cache with timestamps for memoization
  final Map<String, ProcessVolume> processCache = {
    'spotify': ProcessVolume(),
    'soundboard': ProcessVolume(),
    'jinglepalette': ProcessVolume(),
  };

  // Debouncing
  final Map<String, Timer> _debounceTimers = {};
  final Map<String, double> _lastVolumeValues = {};

  bool _initialSetupComplete = false;
  DateTime _lastProcessRefresh = DateTime.now().subtract(
    const Duration(days: 1),
  );
  static const Duration _processCacheValidity = Duration(minutes: 5);

  List<SerialPort> portList = [];
  SerialPort? _serialPort;
  SerialProcessor? _serialProcessor;
  SerialPortReader? _serialPortReader;
  bool _isSerialConnected = false;
  bool _isSerialReconnecting = false;
  StreamSubscription<SliderMoveEvent>? _sliderMoveSubscription;

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _serialReconnectTimer?.cancel();
    _sliderMoveSubscription?.cancel();

    // Cancel all debounce timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    _debounceTimers.clear();

    closeSerialPort();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _initSerialPort();

    Audio.addChangeListener((String type, String id) {
      // Only refresh when audio configuration changes
      syncSystemVolume();
    });

    Future.delayed(Duration.zero, () {
      // Set up channel listeners
      jingleManager.audioManager.channel1.onPlayerStateChanged.listen((state) {
        ref.read(c1StateProvider.notifier).state = state;
      });
      jingleManager.audioManager.channel2.onPlayerStateChanged.listen((state) {
        ref.read(c2StateProvider.notifier).state = state;
      });
    });

    // Single timer for all refreshes - reduced frequency to 3 seconds
    _refreshTimer = Timer.periodic(Duration(seconds: _refreshIntervalSeconds), (
      timer,
    ) {
      if (mounted) {
        syncSystemVolume();
      }
    });

    // Initial fetch
    syncSystemVolume();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _initSerialPort() {
    _serialProcessor = SerialProcessor();

    // Setup slider move listener
    _sliderMoveSubscription = _serialProcessor?.serialIO.addSliderMoveListener(
      _handleSliderMove,
    );

    // Find available ports
    _refreshPortList();

    // Connect to the port if auto-connect is enabled
    if (SettingsBox().serialAutoConnect &&
        SettingsBox().serialPortName.isNotEmpty) {
      connectToSerialPort();
    }
  }

  void _refreshPortList() {
    try {
      portList =
          SerialPort.availablePorts.map((name) => SerialPort(name)).toList();
      logger.d('Found ${portList.length} serial ports');
    } catch (e) {
      logger.d('Error refreshing port list: $e');
      portList = [];
    }
  }

  // Public method to connect to serial port
  void connectToSerialPort() {
    final portName = SettingsBox().serialPortName;
    SerialPort? targetPort;

    try {
      targetPort = portList.firstWhere((port) => port.name == portName);
    } catch (e) {
      // If no matching port is found, use the first available port or null
      logger.d(
        'Configured port $portName not found, falling back to first available port',
      );
      targetPort = portList.isNotEmpty ? portList.first : null;
    }

    if (targetPort != null) {
      _serialPort = targetPort;
      _openSerialPort();
    } else {
      logger.d('No suitable serial port found for connection');
      _startSerialReconnectTimer();
    }
  }

  void _startSerialReconnectTimer() {
    if (_isSerialReconnecting) return;

    _isSerialReconnecting = true;
    _serialReconnectTimer = Timer.periodic(
      Duration(seconds: _serialReconnectIntervalSeconds),
      (timer) {
        if (!_isSerialConnected && mounted) {
          logger.d('Attempting to reconnect to serial port...');
          _refreshPortList();
          connectToSerialPort();
        } else {
          _serialReconnectTimer?.cancel();
          _isSerialReconnecting = false;
        }
      },
    );
  }

  void _openSerialPort() {
    if (_serialPort == null || _isSerialConnected) return;

    try {
      if (_serialPort!.open(mode: SerialPortMode.read)) {
        SerialPortConfig config = _serialPort!.config;

        // Configure port settings from saved preferences
        config.baudRate = SettingsBox().serialBaudRate;
        config.bits = SettingsBox().serialDataBits;
        config.stopBits = SettingsBox().serialStopBits;
        config.parity = SettingsBox().serialParity;
        config.cts = 0;
        config.rts = 0;
        config.xonXoff = 0;

        _serialPort!.config = config;

        if (_serialPort!.isOpen) {
          _isSerialConnected = true;
          _isSerialReconnecting = false;
          logger.d('${_serialPort!.name} opened!');

          // Create reader and listen for data
          _serialPortReader = SerialPortReader(_serialPort!);
          _serialPortReader!.stream.listen(
            (data) {
              if (_serialProcessor != null) {
                _serialProcessor!.processStream(Stream.value(data));
              }
            },
            onError: (error) {
              if (error is SerialPortError) {
                logger.d(
                  'Serial error: ${error.message}, code: ${error.errorCode}',
                );
                _handleSerialDisconnect();
              }
            },
            onDone: () {
              _handleSerialDisconnect();
            },
          );
        }
      } else {
        logger.d('Failed to open serial port');
        _handleSerialDisconnect();
      }
    } catch (e) {
      logger.d('Error opening serial port: $e');
      _handleSerialDisconnect();
    }
  }

  void _handleSerialDisconnect() {
    _isSerialConnected = false;
    _startSerialReconnectTimer();
  }

  // Public method to close serial port
  void closeSerialPort() {
    if (_serialPort != null && _serialPort!.isOpen) {
      try {
        _serialPort!.close();
        logger.d('${_serialPort!.name} closed!');
      } catch (e) {
        logger.d('Error closing serial port: $e');
      } finally {
        _isSerialConnected = false;
      }
    }
  }

  // Debounce volume changes to reduce rapid updates
  void _debouncedVolumeChange(
    String id,
    double value,
    Function(double) callback,
  ) {
    // Store the latest value
    _lastVolumeValues[id] = value;

    // Cancel existing timer if any
    _debounceTimers[id]?.cancel();

    // Create a new timer
    _debounceTimers[id] = Timer(
      Duration(milliseconds: _volumeDebounceMilliseconds),
      () {
        // Only proceed if the component is still mounted
        if (mounted) {
          // Use the most recent value when the timer fires
          callback(_lastVolumeValues[id] ?? value);
        }
      },
    );
  }

  void _handleSliderMove(SliderMoveEvent event) {
    // Get the mapping for this slider
    String mapping;
    switch (event.sliderId) {
      case 0:
        mapping = SettingsBox().slider0Mapping;
        break;
      case 1:
        mapping = SettingsBox().slider1Mapping;
        break;
      case 2:
        mapping = SettingsBox().slider2Mapping;
        break;
      case 3:
        mapping = SettingsBox().slider3Mapping;
        break;
      default:
        return;
    }

    // Map sliders to volume controls with debouncing
    switch (mapping) {
      case 'master':
        _debouncedVolumeChange('main', event.percentValue, (value) {
          Audio.setVolume(value, AudioDeviceType.output);
          ref.read(mainVolumeProvider.notifier).updateVolume(value);
        });
        break;
      case 'spotify':
        final process = processCache['spotify'];
        if (process?.processId != 0) {
          _debouncedVolumeChange('spotify', event.percentValue, (value) {
            Audio.setAudioMixerVolume(process!.processId, value);
            ref.read(spoVolumeProvider.notifier).updateVolume(value);
          });
        }
        break;
      case 'soundboard':
        final process = processCache['soundboard'];
        if (process?.processId != 0) {
          _debouncedVolumeChange('soundboard', event.percentValue, (value) {
            Audio.setAudioMixerVolume(process!.processId, value);
            ref.read(sbVolumeProvider.notifier).updateVolume(value);
          });
        }
        break;
      case 'jinglepalette':
        final process = processCache['jinglepalette'];
        if (process?.processId != 0) {
          _debouncedVolumeChange('jinglepalette', event.percentValue, (value) {
            Audio.setAudioMixerVolume(process!.processId, value);
            ref.read(jpVolumeProvider.notifier).updateVolume(value);
          });
        }
        break;
      case 'c1':
        _debouncedVolumeChange('c1', event.percentValue, (value) {
          jingleManager.audioManager.channel1.setVolume(value);
          ref.read(c1VolumeProvider.notifier).updateVolume(value);
        });
        break;
      case 'c2':
        _debouncedVolumeChange('c2', event.percentValue, (value) {
          jingleManager.audioManager.channel2.setVolume(value);
          ref.read(c2VolumeProvider.notifier).updateVolume(value);
        });
        break;
    }
  }

  bool _needsRefresh() {
    final now = DateTime.now();
    final cacheExpired =
        now.difference(_lastProcessRefresh) > _processCacheValidity;

    // Check if we need to refresh process list
    return !_initialSetupComplete ||
        cacheExpired ||
        processCache.values.any((process) => process.processId == 0);
  }

  Future<void> syncSystemVolume() async {
    if (!mounted) return;

    // Update master volume
    try {
      defaultDevice = (await Audio.getDefaultDevice(audioDeviceType))!;
      final masterVolume = await Audio.getVolume(audioDeviceType);
      ref.read(mainVolumeProvider.notifier).updateVolume(masterVolume);
    } catch (e) {
      logger.d('Error getting master volume: $e');
    }

    // Only refresh process list if needed
    if (_needsRefresh()) {
      try {
        final mixerList = await Audio.enumAudioMixer() ?? <ProcessVolume>[];
        _lastProcessRefresh = DateTime.now();

        // Update process cache
        for (ProcessVolume mixer in mixerList) {
          final path = mixer.processPath.toLowerCase();

          if (path.contains("spotify.exe")) {
            processCache['spotify'] = mixer;
            ref.read(spoVolumeProvider.notifier).updateVolume(mixer.maxVolume);
          } else if (path.contains("soundboard.exe")) {
            processCache['soundboard'] = mixer;
            ref.read(sbVolumeProvider.notifier).updateVolume(mixer.maxVolume);
          } else if (path.contains("jingle_palette.exe")) {
            processCache['jinglepalette'] = mixer;
            ref.read(jpVolumeProvider.notifier).updateVolume(mixer.maxVolume);
          } else {
            // Check if this process matches any of the slider mappings
            for (int i = 0; i < 4; i++) {
              final mapping =
                  i == 0
                      ? SettingsBox().slider0Mapping
                      : i == 1
                      ? SettingsBox().slider1Mapping
                      : i == 2
                      ? SettingsBox().slider2Mapping
                      : SettingsBox().slider3Mapping;

              if (path.contains(mapping.toLowerCase())) {
                processCache[mapping] = mixer;
                // For custom processes, we'll need to create a provider dynamically
                // This is a placeholder for future implementation
              }
            }
          }
        }

        _initialSetupComplete = true;
        audioDevices =
            await Audio.enumDevices(audioDeviceType) ?? <AudioDevice>[];
      } catch (e) {
        logger.d('Error refreshing process list: $e');
      }
    } else {
      // Just update volumes for existing processes
      _updateProcessVolumes();
    }
  }

  void _updateProcessVolumes() {
    // Update volume providers from cache
    for (final entry in processCache.entries) {
      if (entry.value.processId == 0) continue;

      try {
        switch (entry.key) {
          case 'spotify':
            ref
                .read(spoVolumeProvider.notifier)
                .updateVolume(entry.value.maxVolume);
            break;
          case 'soundboard':
            ref
                .read(sbVolumeProvider.notifier)
                .updateVolume(entry.value.maxVolume);
            break;
          case 'jinglepalette':
            ref
                .read(jpVolumeProvider.notifier)
                .updateVolume(entry.value.maxVolume);
            break;
          default:
            // For custom processes, we'll need to update their providers dynamically
            // This is a placeholder for future implementation
            break;
        }
      } catch (e) {
        logger.d('Error updating volume for ${entry.key}: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to serial port connection state changes
    ref.listen(serialPortProvider, (previous, next) {
      if (next && !_isSerialConnected) {
        connectToSerialPort();
      } else if (!next && _isSerialConnected) {
        closeSerialPort();
      }
    });

    final c1VolumeValue = ref.watch(c1VolumeProvider);
    final c2VolumeValue = ref.watch(c2VolumeProvider);
    final c1PlayerState = ref.watch(c1StateProvider);
    final c2PlayerState = ref.watch(c2StateProvider);

    final mainVolumeValue = ref.watch(mainVolumeProvider);
    final spotifyVolumeValue = ref.watch(spoVolumeProvider);
    final soundboardVolumeValue = ref.watch(sbVolumeProvider);
    final jinglePaletteVolumeValue = ref.watch(jpVolumeProvider);

    final isConnected = ref.watch(serialPortProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // First Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumeColumn('C1', c1PlayerState, c1VolumeValue.vol, (
                      value,
                    ) {
                      _debouncedVolumeChange('c1_ui', value / 100, (
                        adjustedValue,
                      ) {
                        jingleManager.audioManager.channel1.setVolume(
                          adjustedValue,
                        );
                        ref
                            .read(c1VolumeProvider.notifier)
                            .updateVolume(adjustedValue);
                      });
                    }),
                    _buildVolumeColumn('C2', c2PlayerState, c2VolumeValue.vol, (
                      value,
                    ) {
                      _debouncedVolumeChange('c2_ui', value / 100, (
                        adjustedValue,
                      ) {
                        jingleManager.audioManager.channel2.setVolume(
                          adjustedValue,
                        );
                        ref
                            .read(c2VolumeProvider.notifier)
                            .updateVolume(adjustedValue);
                      });
                    }),
                  ],
                ),
              ),

              // Second Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumeColumn(
                      'Master',
                      PlayerState.stopped,
                      mainVolumeValue.vol,
                      (value) {
                        _debouncedVolumeChange('main_ui', value / 100, (
                          adjustedValue,
                        ) {
                          Audio.setVolume(
                            adjustedValue,
                            AudioDeviceType.output,
                          );
                          ref
                              .read(mainVolumeProvider.notifier)
                              .updateVolume(adjustedValue);
                        });
                      },
                      isMaster: true,
                    ),
                    _buildVolumeColumn(
                      'SB',
                      PlayerState.stopped,
                      soundboardVolumeValue.vol,
                      (value) {
                        final process = processCache['soundboard'];
                        if (process?.processId != 0) {
                          _debouncedVolumeChange('sb_ui', value / 100, (
                            adjustedValue,
                          ) {
                            Audio.setAudioMixerVolume(
                              process!.processId,
                              adjustedValue,
                            );
                            ref
                                .read(sbVolumeProvider.notifier)
                                .updateVolume(adjustedValue);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              // Third Row
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildVolumeColumn(
                      'SPO',
                      PlayerState.stopped,
                      spotifyVolumeValue.vol,
                      (value) {
                        final process = processCache['spotify'];
                        if (process?.processId != 0) {
                          _debouncedVolumeChange('spo_ui', value / 100, (
                            adjustedValue,
                          ) {
                            Audio.setAudioMixerVolume(
                              process!.processId,
                              adjustedValue,
                            );
                            ref
                                .read(spoVolumeProvider.notifier)
                                .updateVolume(adjustedValue);
                          });
                        }
                      },
                    ),
                    _buildVolumeColumn(
                      'JP',
                      PlayerState.stopped,
                      jinglePaletteVolumeValue.vol,
                      (value) {
                        final process = processCache['jinglepalette'];
                        if (process?.processId != 0) {
                          _debouncedVolumeChange('jp_ui', value / 100, (
                            adjustedValue,
                          ) {
                            Audio.setAudioMixerVolume(
                              process!.processId,
                              adjustedValue,
                            );
                            ref
                                .read(jpVolumeProvider.notifier)
                                .updateVolume(adjustedValue);
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),

              if (isConnected)
                Text('Connected to serial port')
              else
                Text('Not connected'),
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
    return Expanded(
      child: Column(
        children: [
          // Modified order - slider first, then label
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: _buildCustomSlider(
                playerState: playerState,
                volumeValue: volumeValue,
                onVolumeChanged: onChanged,
              ),
            ),
          ),
          _buildCustomText(label),
        ],
      ),
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
        activeColor:
            playerState == PlayerState.playing
                ? Theme.of(context).colorScheme.errorContainer
                : Theme.of(context).colorScheme.onSurface,
        onChanged: (dynamic value) => onVolumeChanged(value),
        value: volumeValue * 100,
      ),
    );
  }
}
