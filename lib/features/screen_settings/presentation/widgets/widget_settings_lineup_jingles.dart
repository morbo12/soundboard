import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

class LineupJingleSettingsButton extends ConsumerWidget {
  const LineupJingleSettingsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = SettingsBox();
    final homeJingle = settings.homeJingleFilePath.isEmpty
        ? "Not configured"
        : _getFileNameFromPath(settings.homeJingleFilePath);
    final awayJingle = settings.awayJingleFilePath.isEmpty
        ? "Not configured"
        : _getFileNameFromPath(settings.awayJingleFilePath);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: () => _showSettingsDialog(context, ref),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lineup Jingles Configuration',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Gap(4),
                Text(
                  'Home: $homeJingle',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 204),
                  ),
                ),
                Text(
                  'Away: $awayJingle',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimaryContainer.withValues(alpha: 204),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.music_note,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  String _getFileNameFromPath(String filePath) {
    if (filePath.isEmpty) return "Not configured";
    return filePath.split('/').last.split('\\').last;
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const LineupJingleSettingsDialog(),
    );
  }
}

class LineupJingleSettingsDialog extends ConsumerStatefulWidget {
  const LineupJingleSettingsDialog({super.key});

  @override
  ConsumerState<LineupJingleSettingsDialog> createState() =>
      _LineupJingleSettingsDialogState();
}

class _LineupJingleSettingsDialogState
    extends ConsumerState<LineupJingleSettingsDialog> {
  String? selectedHomeJinglePath;
  String? selectedAwayJinglePath;
  List<AudioFile> specialJingles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJingles();
  }

  Future<void> _loadJingles() async {
    try {
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      final jingleManager = await jingleManagerAsync.when(
        data: (manager) => manager,
        loading: () => throw Exception('JingleManager not loaded'),
        error: (error, stack) => throw Exception('JingleManager error: $error'),
      );

      final specialJinglesList = jingleManager.audioManager.audioInstances
          .where(
            (instance) => instance.audioCategory == AudioCategory.specialJingle,
          )
          .toList();

      if (mounted) {
        setState(() {
          specialJingles = specialJinglesList;
          selectedHomeJinglePath = SettingsBox().homeJingleFilePath.isEmpty
              ? null
              : SettingsBox().homeJingleFilePath;
          selectedAwayJinglePath = SettingsBox().awayJingleFilePath.isEmpty
              ? null
              : SettingsBox().awayJingleFilePath;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading jingles: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lineup Jingle Configuration'),
      content: SizedBox(
        width: 500,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select which jingles to use for home and away team lineups',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Gap(16),
                  _buildJingleSelector(
                    'Home Team Jingle',
                    selectedHomeJinglePath,
                    (value) => setState(() => selectedHomeJinglePath = value),
                    Icons.home,
                  ),
                  const Gap(16),
                  _buildJingleSelector(
                    'Away Team Jingle',
                    selectedAwayJinglePath,
                    (value) => setState(() => selectedAwayJinglePath = value),
                    Icons.directions_walk,
                  ),
                  if (specialJingles.isEmpty) ...[
                    const Gap(16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                          const Gap(8),
                          Expanded(
                            child: Text(
                              'No special jingles found. Upload jingles to the Special Jingles folder first.',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: specialJingles.isEmpty ? null : _saveSettings,
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildJingleSelector(
    String label,
    String? selectedValue,
    ValueChanged<String?> onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const Gap(8),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              hint: const Text('Select a jingle'),
              isExpanded: true,
              onChanged: onChanged,
              items: [
                const DropdownMenuItem<String>(
                  value: null,
                  child: Text('None (use default)'),
                ),
                ...specialJingles.map<DropdownMenuItem<String>>((jingle) {
                  return DropdownMenuItem<String>(
                    value: jingle.filePath,
                    child: Text(
                      jingle.displayName,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _saveSettings() {
    final settings = SettingsBox();
    settings.homeJingleFilePath = selectedHomeJinglePath ?? "";
    settings.awayJingleFilePath = selectedAwayJinglePath ?? "";

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lineup jingle settings saved successfully'),
      ),
    );
  }
}

// Contains AI-generated edits.
