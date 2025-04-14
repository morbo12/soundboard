import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_home/application/serialport_manager/class_serialport_provider_win32.dart';
import 'package:soundboard/properties.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SerialPortSettingsButton extends StatefulWidget {
  const SerialPortSettingsButton({super.key});

  @override
  State<SerialPortSettingsButton> createState() =>
      _SerialPortSettingsButtonState();
}

class _SerialPortSettingsButtonState extends State<SerialPortSettingsButton> {
  @override
  Widget build(BuildContext context) {
    // Get current settings for button display
    final portName =
        SettingsBox().serialPortName.isEmpty
            ? 'Not configured'
            : SettingsBox().serialPortName;
    final autoConnect = SettingsBox().serialAutoConnect;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: () {
        _showSettingsDialog(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Serial Device: $portName',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(4),
              Text(
                'Auto-connect: ${autoConnect ? "Enabled" : "Disabled"}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 204),
                ),
              ),
            ],
          ),
          Icon(
            Icons.settings,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const SerialSettingsDialog(),
    );
  }
}

class SerialSettingsDialog extends ConsumerStatefulWidget {
  const SerialSettingsDialog({super.key});

  @override
  ConsumerState<SerialSettingsDialog> createState() =>
      _SerialSettingsDialogState();
}

class _SerialSettingsDialogState extends ConsumerState<SerialSettingsDialog> {
  List<String> availablePorts = [];
  List<int> baudRates = [9600, 19200, 38400, 57600, 115200];
  List<int> dataBits = [5, 6, 7, 8];
  List<int> stopBits = [1, 2];
  List<String> parityOptions = ['None', 'Odd', 'Even', 'Mark', 'Space'];
  bool autoConnect = false;
  bool isConnecting = false;
  String _currentProcess = '';

  @override
  void initState() {
    super.initState();
    _refreshPortList();
    autoConnect = SettingsBox().serialAutoConnect;
  }

  void _refreshPortList() {
    setState(() {
      availablePorts =
          ref
              .read(serialPortManagerWin32Provider)
              .portList
              .map((port) => port.portName)
              .toList();
    });
  }

  int _getParityValue(String parity) {
    switch (parity) {
      case 'None':
        return 0;
      case 'Odd':
        return 1;
      case 'Even':
        return 2;
      case 'Mark':
        return 3;
      case 'Space':
        return 4;
      default:
        return 0;
    }
  }

  String _getParityString(int parity) {
    switch (parity) {
      case 0:
        return 'None';
      case 1:
        return 'Odd';
      case 2:
        return 'Even';
      case 3:
        return 'Mark';
      case 4:
        return 'Space';
      default:
        return 'None';
    }
  }

  Future<void> _connectToPort() async {
    if (SettingsBox().serialPortName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a serial port first')),
      );
      return;
    }

    setState(() {
      isConnecting = true;
    });

    try {
      ref.read(serialPortManagerWin32Provider).connect();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to serial port...')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error connecting to port: $e')));
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  Future<void> _disconnectPort() async {
    setState(() {
      isConnecting = true;
    });

    try {
      ref.read(serialPortManagerWin32Provider).disconnect();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disconnected from serial port')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error disconnecting from port: $e')),
      );
    } finally {
      setState(() {
        isConnecting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final serialPortManager = ref.watch(serialPortManagerWin32Provider);
    List<String> definedProcesses = SettingsBox().processMappings.keys.toList();

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Serial Port Settings'),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPortList,
            tooltip: 'Refresh Port List',
          ),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Port selection section
              Text(
                'Port Selection',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              if (availablePorts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).colorScheme.error,
                          size: 30,
                        ),
                        const Gap(8),
                        const Text('No serial ports detected'),
                        const Gap(4),
                        const Text(
                          'Connect your Deej device and press refresh',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availablePorts.length,
                    itemBuilder: (context, index) {
                      final port = availablePorts[index];
                      final isSelected = port == SettingsBox().serialPortName;

                      return ListTile(
                        title: Text(port),
                        selected: isSelected,
                        selectedTileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        leading: Icon(
                          Icons.usb,
                          color:
                              isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                        ),
                        onTap: () {
                          SettingsBox().serialPortName = port;
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),

              // Auto-connect option
              SwitchListTile(
                title: const Text('Auto Connect on Startup'),
                subtitle: const Text(
                  'Automatically connect when the app starts',
                ),
                value: autoConnect,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    autoConnect = value;
                    SettingsBox().serialAutoConnect = value;
                  });
                },
              ),

              // Connection settings section
              Text(
                'Connection Settings',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              const Gap(8),

              // Baud Rate
              _buildDropdownSetting(
                icon: Icons.speed,
                label: 'Baud Rate',
                value: SettingsBox().serialBaudRate.toString(),
                items: baudRates.map((rate) => rate.toString()).toList(),
                onChanged: (value) {
                  if (value != null) {
                    SettingsBox().serialBaudRate = int.parse(value);
                    setState(() {});
                  }
                },
              ),

              // Data Bits
              _buildDropdownSetting(
                icon: Icons.data_array,
                label: 'Data Bits',
                value: SettingsBox().serialDataBits.toString(),
                items: dataBits.map((bits) => bits.toString()).toList(),
                onChanged: (value) {
                  if (value != null) {
                    SettingsBox().serialDataBits = int.parse(value);
                    setState(() {});
                  }
                },
              ),

              // Stop Bits
              _buildDropdownSetting(
                icon: Icons.stop_circle,
                label: 'Stop Bits',
                value: SettingsBox().serialStopBits.toString(),
                items: stopBits.map((bits) => bits.toString()).toList(),
                onChanged: (value) {
                  if (value != null) {
                    SettingsBox().serialStopBits = int.parse(value);
                    setState(() {});
                  }
                },
              ),

              // Parity
              _buildDropdownSetting(
                icon: Icons.grid_3x3,
                label: 'Parity',
                value: _getParityString(SettingsBox().serialParity),
                items: parityOptions,
                onChanged: (value) {
                  if (value != null) {
                    SettingsBox().serialParity = _getParityValue(value);
                    setState(() {});
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: isConnecting ? null : _connectToPort,
          child:
              isConnecting
                  ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text('Connect'),
        ),
        ElevatedButton(
          onPressed: serialPortManager.isConnected ? _disconnectPort : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: const Text('Disconnect'),
        ),
      ],
    );
  }

  Widget _buildDropdownSetting({
    required IconData icon,
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      isExpanded: true,
                      onChanged: onChanged,
                      items:
                          items.map<DropdownMenuItem<String>>((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
