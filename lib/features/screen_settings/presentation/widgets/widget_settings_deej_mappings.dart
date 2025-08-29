import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_settings/data/class_slider_mappings.dart';
import 'package:soundboard/core/properties.dart';

class DeejMappingsButton extends StatefulWidget {
  const DeejMappingsButton({super.key});

  @override
  State<DeejMappingsButton> createState() => _DeejMappingsButtonState();
}

class _DeejMappingsButtonState extends State<DeejMappingsButton> {
  @override
  Widget build(BuildContext context) {
    // Get current mappings count for button display
    final mappingsCount = SettingsBox().sliderMappings.length;
    final activeMappings = SettingsBox().sliderMappings
        .where((m) => m.processName.isNotEmpty)
        .length;

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
                'Deej Mappings: $activeMappings active',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(4),
              Text(
                'Total mappings: $mappingsCount',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withAlpha(204),
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
      builder: (context) => const DeejMappingsDialog(),
    );
  }
}

class DeejMappingsDialog extends StatefulWidget {
  const DeejMappingsDialog({super.key});

  @override
  State<DeejMappingsDialog> createState() => _DeejMappingsDialogState();
}

class _DeejMappingsDialogState extends State<DeejMappingsDialog> {
  final List<String> _processNames = [];
  final _processNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load existing mappings and extract unique non-empty process names
    _processNames.addAll(
      SettingsBox().sliderMappings
          .map((m) => m.processName)
          .where((name) => name.isNotEmpty)
          .toSet(),
    );

    // Clean up any mappings with invalid UI slider indices
    _cleanupInvalidMappings();
  }

  /// Removes mappings with invalid UI slider indices to prevent dropdown errors
  void _cleanupInvalidMappings() {
    final validMappings = SettingsBox().sliderMappings
        .where(
          (mapping) => mapping.uiSliderIdx >= 0 && mapping.uiSliderIdx <= 5,
        )
        .toList();

    if (validMappings.length != SettingsBox().sliderMappings.length) {
      // Update the settings with only valid mappings
      SettingsBox().sliderMappings = validMappings;
    }
  }

  @override
  void dispose() {
    _processNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Deej Slider Mappings'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 600,
          maxWidth: 900,
          minHeight: 400,
          maxHeight: 700,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
          height:
              MediaQuery.of(context).size.height * 0.7, // 70% of screen height
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Information Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Mappings Work',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      const Text(
                        '• Regular sliders (Master, Slider 1-3): Control Windows processes\n'
                        '• AudioPlayer channels (C1, C2): Control app audio directly\n'
                        '• AudioPlayer channels don\'t need a Windows process',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Gap(16),

                // Process Management Section
                Text(
                  'Process Management',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                const Gap(8),
                TextField(
                  controller: _processNameController,
                  decoration: const InputDecoration(
                    labelText: 'Add New Process',
                    hintText: 'Enter process name (e.g., chrome, discord)',
                    prefixIcon: Icon(Icons.apps),
                  ),
                  onSubmitted: (value) {
                    if (value.isNotEmpty && !_processNames.contains(value)) {
                      setState(() {
                        _processNames.add(value);
                      });
                      _processNameController.clear();
                    }
                  },
                ),
                const Gap(8),
                if (_processNames.isNotEmpty) ...[
                  const Text(
                    'Defined Processes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Gap(4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _processNames.map((name) {
                      return Chip(
                        label: Text(name),
                        onDeleted: () {
                          setState(() {
                            _processNames.remove(name);
                            // Remove all mappings for this process
                            SettingsBox().sliderMappings.removeWhere(
                              (m) => m.processName == name,
                            );
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],

                const Gap(24),

                // Slider Mappings Section
                Text(
                  'Slider Mappings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Divider(),
                const Gap(8),
                for (int i = 0; i < 4; i++) _buildSliderMappingRow(i),
              ],
            ), // Close the Column
          ), // Close the SingleChildScrollView
        ), // Close the SizedBox
      ), // Close the ConstrainedBox
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildSliderMappingRow(int deejSliderIdx) {
    final mapping = SettingsBox().getMappingForDeejSlider(deejSliderIdx);
    final rawCurrentProcess = mapping?.processName ?? '';
    final rawCurrentUiSlider = mapping?.uiSliderIdx ?? 0;

    // Ensure the current process value is valid for the dropdown
    // If the process is not in the list and not empty, either add it or reset to empty
    String currentProcess = rawCurrentProcess;
    if (currentProcess.isNotEmpty && !_processNames.contains(currentProcess)) {
      // Add the missing process to the list to maintain the mapping
      _processNames.add(currentProcess);
    }

    // Ensure the UI slider value is within valid range (0-5)
    int currentUiSlider = rawCurrentUiSlider;
    if (currentUiSlider < 0 || currentUiSlider > 5) {
      currentUiSlider = 0; // Default to Master if invalid
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Deej Slider $deejSliderIdx',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Gap(12),
          Expanded(
            flex: 4, // Increased from 3 to give more space
            child: DropdownButtonFormField<String>(
              initialValue: currentProcess,
              decoration: InputDecoration(
                labelText: 'Process',
                border: const OutlineInputBorder(),
                helperText: _isAudioPlayerSelected(currentUiSlider)
                    ? 'AudioPlayer channels don\'t need a process'
                    : 'Select Windows process to control',
                helperMaxLines: 2,
              ),
              items: [
                const DropdownMenuItem<String>(value: '', child: Text('None')),
                ..._processNames.map((name) {
                  return DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  );
                }).toList(),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    if (value.isEmpty) {
                      // Remove mapping if "None" is selected
                      SettingsBox().removeSliderMapping(deejSliderIdx);
                    } else {
                      SettingsBox().addSliderMapping(
                        SliderMapping(
                          deejSliderIdx: deejSliderIdx,
                          processName: value,
                          uiSliderIdx: currentUiSlider,
                        ),
                      );
                    }
                  });
                }
              },
            ),
          ),
          const Gap(12),
          Expanded(
            flex: 4, // Increased from 3 to give more space
            child: DropdownButtonFormField<int>(
              initialValue: currentUiSlider,
              decoration: const InputDecoration(
                labelText: 'UI Slider',
                border: OutlineInputBorder(),
                helperText: 'Select which UI element to control',
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Master')),
                DropdownMenuItem(value: 1, child: Text('Slider 1')),
                DropdownMenuItem(value: 2, child: Text('Slider 2')),
                DropdownMenuItem(value: 3, child: Text('Slider 3')),
                DropdownMenuItem(
                  value: 4,
                  child: Row(
                    children: [
                      Icon(Icons.music_note, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('AudioPlayer C1'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Row(
                    children: [
                      Icon(Icons.music_note, size: 16, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('AudioPlayer C2'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    // Auto-clear process field for AudioPlayer channels
                    String processToUse = currentProcess;
                    if (_isAudioPlayerSelected(value)) {
                      processToUse =
                          ''; // Clear process for AudioPlayer channels
                    }

                    // For AudioPlayer channels, we can create mapping even without process
                    // For other sliders, we need a process name
                    if (_isAudioPlayerSelected(value) ||
                        processToUse.isNotEmpty) {
                      SettingsBox().addSliderMapping(
                        SliderMapping(
                          deejSliderIdx: deejSliderIdx,
                          processName: processToUse,
                          uiSliderIdx: value,
                        ),
                      );
                    } else {
                      // Remove mapping if no process is selected for non-AudioPlayer sliders
                      SettingsBox().removeSliderMapping(deejSliderIdx);
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper method to check if the selected UI slider is an AudioPlayer channel
  bool _isAudioPlayerSelected(int uiSliderIdx) {
    return uiSliderIdx == 4 || uiSliderIdx == 5; // AudioPlayer C1 or C2
  }
}
