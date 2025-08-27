import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/models/volume_system_config.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/deej_providers.dart';
import 'package:soundboard/core/utils/logger.dart';

class VolumeSystemConfigButton extends StatefulWidget {
  const VolumeSystemConfigButton({super.key});

  @override
  State<VolumeSystemConfigButton> createState() =>
      _VolumeSystemConfigButtonState();
}

class _VolumeSystemConfigButtonState extends State<VolumeSystemConfigButton> {
  static const _logger = Logger('VolumeSystemConfigButton');

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final isDeejConnected = ref.watch(deejConnectionStatusProvider);
        final config = SettingsBox().volumeSystemConfig;

        // Debug: Log connection status
        _logger.d('Deej Connected: $isDeejConnected');

        return Card(
          elevation: 2,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () => _showConfigDialog(context, isDeejConnected),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withAlpha(100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isDeejConnected ? Icons.settings_remote : Icons.tune,
                        color: Colors.deepPurple.shade700,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                isDeejConnected
                                    ? 'Volume Control: Deej Hardware Mode'
                                    : 'Volume Control: UI Only Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade800,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: isDeejConnected
                                      ? Colors.green
                                      : Colors.blue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  isDeejConnected ? 'HARDWARE' : 'SOFTWARE',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isDeejConnected
                                ? '${config.deejMappings.length} Deej mappings active'
                                : 'Master: Windows audio, C1/C2: Max volume',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.deepPurple.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.settings,
                      color: Colors.deepPurple.shade700,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfigDialog(BuildContext context, bool isDeejConnected) {
    showDialog(
      context: context,
      builder: (context) =>
          VolumeSystemConfigDialog(isDeejConnected: isDeejConnected),
    );
  }
}

class VolumeSystemConfigDialog extends StatefulWidget {
  final bool isDeejConnected;

  const VolumeSystemConfigDialog({super.key, required this.isDeejConnected});

  @override
  State<VolumeSystemConfigDialog> createState() =>
      _VolumeSystemConfigDialogState();
}

class _VolumeSystemConfigDialogState extends State<VolumeSystemConfigDialog> {
  late VolumeSystemConfig _config;
  final _processNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _config = SettingsBox().volumeSystemConfig;
  }

  @override
  void dispose() {
    _processNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isDeejConnected
            ? 'Deej Hardware Configuration'
            : 'UI Volume Configuration',
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 700,
          maxWidth: 1000,
          minHeight: 500,
          maxHeight: 800,
        ),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.7,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection(),
                const Gap(24),
                _buildProcessManagement(),
                const Gap(24),
                if (widget.isDeejConnected) ...[
                  _buildDeejMappings(),
                ] else ...[
                  _buildUIOnlyInfo(),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
        if (widget.isDeejConnected)
          ElevatedButton(
            onPressed: _saveConfiguration,
            child: const Text('Save'),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(128),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isDeejConnected ? 'Deej Hardware Mode' : 'UI Only Mode',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
          const Gap(8),
          Text(
            widget.isDeejConnected
                ? '• 4 Deej sliders can control Master, External Processes, or AudioPlayer channels\n'
                      '• Each Deej slider maps to one target\n'
                      '• UI sliders show current values but don\'t control audio'
                : '• Master slider controls Windows master volume\n'
                      '• C1/C2 sliders are for visualization only\n'
                      '• AudioPlayer channels use max volume when playing\n'
                      '• External processes are not controlled',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessManagement() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'External Process Management',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const Gap(8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _processNameController,
                decoration: const InputDecoration(
                  labelText: 'Add Process',
                  hintText: 'e.g., chrome, discord, obs',
                  prefixIcon: Icon(Icons.apps),
                ),
                onSubmitted: _addProcess,
              ),
            ),
            const Gap(8),
            ElevatedButton(
              onPressed: () => _addProcess(_processNameController.text),
              child: const Text('Add'),
            ),
          ],
        ),
        const Gap(12),
        if (_config.availableProcesses.isNotEmpty) ...[
          const Text(
            'Available Processes',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _config.availableProcesses.map((process) {
              return Chip(
                label: Text(process),
                onDeleted: () => _removeProcess(process),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildDeejMappings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deej Slider Mappings',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(),
        const Gap(8),
        for (int i = 0; i < 4; i++) _buildDeejSliderRow(i),
      ],
    );
  }

  Widget _buildDeejSliderRow(int deejSliderIdx) {
    final mapping = _config.deejMappings
        .where((m) => m.deejSliderIdx == deejSliderIdx)
        .firstOrNull;

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
            flex: 3,
            child: DropdownButtonFormField<DeejTarget>(
              value: mapping?.target,
              decoration: const InputDecoration(
                labelText: 'Target',
                border: OutlineInputBorder(),
              ),
              items: DeejTarget.values.map((target) {
                return DropdownMenuItem(
                  value: target,
                  child: Row(
                    children: [
                      _getTargetIcon(target),
                      const Gap(8),
                      Text(target.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (target) => _updateDeejMapping(
                deejSliderIdx,
                target,
                mapping?.processName,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            flex: 3,
            child: mapping?.target == DeejTarget.externalProcess
                ? DropdownButtonFormField<String>(
                    value: mapping?.processName,
                    decoration: const InputDecoration(
                      labelText: 'Process',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Select...'),
                      ),
                      ..._config.availableProcesses.map((process) {
                        return DropdownMenuItem(
                          value: process,
                          child: Text(process),
                        );
                      }),
                    ],
                    onChanged: (process) => _updateDeejMapping(
                      deejSliderIdx,
                      mapping?.target,
                      process,
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      mapping?.target == null
                          ? 'No target selected'
                          : 'No process needed',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
          ),
          const Gap(8),
          IconButton(
            onPressed: mapping != null
                ? () => _removeDeejMapping(deejSliderIdx)
                : null,
            icon: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }

  Widget _buildUIOnlyInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withAlpha(128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const Gap(8),
              Text(
                'UI Only Mode (Deej Disconnected)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
          const Gap(12),
          Text(
            'Current Behavior:\n'
            '• Master slider: Controls Windows master volume\n'
            '• C1/C2 sliders: Visualization only, AudioPlayer uses max volume\n'
            '• External processes: Not controlled by UI sliders\n\n'
            'To control external processes, connect your Deej hardware and configure mappings above.',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _getTargetIcon(DeejTarget target) {
    switch (target) {
      case DeejTarget.master:
        return const Icon(Icons.volume_up, size: 16);
      case DeejTarget.externalProcess:
        return const Icon(Icons.apps, size: 16);
      case DeejTarget.audioPlayerC1:
      case DeejTarget.audioPlayerC2:
        return const Icon(Icons.music_note, size: 16, color: Colors.orange);
    }
  }

  void _addProcess(String processName) {
    if (processName.isNotEmpty &&
        !_config.availableProcesses.contains(processName)) {
      setState(() {
        _config = _config.copyWith(
          availableProcesses: [..._config.availableProcesses, processName],
        );
      });
      _processNameController.clear();
    }
  }

  void _removeProcess(String processName) {
    setState(() {
      // Remove from available processes
      final newProcesses = _config.availableProcesses
          .where((p) => p != processName)
          .toList();

      // Remove any Deej mappings using this process
      final newMappings = _config.deejMappings
          .where((m) => m.processName != processName)
          .toList();

      _config = _config.copyWith(
        availableProcesses: newProcesses,
        deejMappings: newMappings,
      );
    });
  }

  void _updateDeejMapping(
    int deejSliderIdx,
    DeejTarget? target,
    String? processName,
  ) {
    setState(() {
      // Remove existing mapping for this slider
      final newMappings = _config.deejMappings
          .where((m) => m.deejSliderIdx != deejSliderIdx)
          .toList();

      // Add new mapping if target is selected
      if (target != null) {
        newMappings.add(
          DeejHardwareMapping(
            deejSliderIdx: deejSliderIdx,
            target: target,
            processName: target == DeejTarget.externalProcess
                ? processName
                : null,
          ),
        );
      }

      _config = _config.copyWith(deejMappings: newMappings);
    });
  }

  void _removeDeejMapping(int deejSliderIdx) {
    setState(() {
      final newMappings = _config.deejMappings
          .where((m) => m.deejSliderIdx != deejSliderIdx)
          .toList();
      _config = _config.copyWith(deejMappings: newMappings);
    });
  }

  void _saveConfiguration() {
    SettingsBox().volumeSystemConfig = _config;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved successfully')),
    );
  }
}

// Contains AI-generated edits.
