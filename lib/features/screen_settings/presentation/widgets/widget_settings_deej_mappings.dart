import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_settings/data/class_slider_mappings.dart';
import 'package:soundboard/properties.dart';

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
    final activeMappings =
        SettingsBox().sliderMappings
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
    // Load existing mappings and extract unique process names
    _processNames.addAll(
      SettingsBox().sliderMappings.map((m) => m.processName).toSet(),
    );
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
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  children:
                      _processNames.map((name) {
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
          ),
        ),
      ),
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
    final currentProcess = mapping?.processName ?? '';
    final currentUiSlider = mapping?.uiSliderIdx ?? 0;

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
          const Gap(16),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: currentProcess,
              decoration: const InputDecoration(
                labelText: 'Process',
                border: OutlineInputBorder(),
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
          const Gap(16),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int>(
              value: currentUiSlider,
              decoration: const InputDecoration(
                labelText: 'UI Slider',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 0, child: Text('Master')),
                DropdownMenuItem(value: 1, child: Text('Slider 1')),
                DropdownMenuItem(value: 2, child: Text('Slider 2')),
                DropdownMenuItem(value: 3, child: Text('Slider 3')),
              ],
              onChanged: (value) {
                if (value != null && currentProcess.isNotEmpty) {
                  setState(() {
                    SettingsBox().addSliderMapping(
                      SliderMapping(
                        deejSliderIdx: deejSliderIdx,
                        processName: currentProcess,
                        uiSliderIdx: value,
                      ),
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
