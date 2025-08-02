import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_config_notifier.dart';

class GridSettingsSection extends ConsumerWidget {
  const GridSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const GridSettingsButton(),
        const Gap(8),
        const GridResetButton(),
      ],
    );
  }
}

class GridResetButton extends ConsumerWidget {
  const GridResetButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // First row: Reset Everything button (full width)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () => _showResetEverythingDialog(context, ref),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.settings_backup_restore,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                const Gap(8),
                Text(
                  'Reset Everything to Defaults',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(8),
        // Second row: Individual reset options
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.errorContainer,
                ),
                onPressed: () => _showResetAssignmentsDialog(context, ref),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restore,
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                    const Gap(8),
                    Text(
                      'Reset Assignments',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Gap(8),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                onPressed: () => _showClearDialog(context, ref),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.clear_all,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    const Gap(8),
                    Text(
                      'Clear All',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showResetEverythingDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Everything to Defaults'),
        content: const Text(
          'This will reset EVERYTHING back to defaults:\n\n'
          '🔧 Grid Layout: 3x4 (3 columns × 4 rows)\n'
          '🎵 All Jingle Assignments:\n'
          '   • Category buttons (clap, random jingle)\n'
          '   • Named empty buttons (HORN, RATATA, etc.)\n'
          '   • Ready for your custom jingles\n\n'
          '⚠️ ALL your custom settings will be lost!\n'
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
            onPressed: () async {
              // Reset grid layout to default (3x4)
              ref.read(gridSettingsProvider.notifier).updateSettings(3, 4);

              // Reset all assignments to defaults
              await ref
                  .read(jingleGridConfigProvider.notifier)
                  .resetToDefaults();

              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Everything reset to defaults! 🎉'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  void _showResetAssignmentsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Jingle Assignments Only'),
        content: const Text(
          '🎵 WHAT THIS DOES:\n'
          'Restores all jingle assignments to defaults:\n'
          '• Category buttons (clap, random jingle)\n'
          '• Named empty buttons (HORN, RATATA, etc.)\n'
          '• Ready for your custom jingle uploads\n\n'
          '🔧 WHAT THIS KEEPS:\n'
          '• Your current grid size (rows × columns)\n'
          '• All other settings unchanged\n\n'
          '⚠️ Your custom jingle assignments will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(jingleGridConfigProvider.notifier)
                  .resetToDefaults();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jingle assignments reset to defaults'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Reset Assignments'),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Jingle Assignments'),
        content: const Text(
          '🗑️ WHAT THIS DOES:\n'
          'Removes ALL jingle assignments from the grid.\n'
          'Every button will become empty/unassigned.\n\n'
          '🔧 WHAT THIS KEEPS:\n'
          '• Your current grid size (rows × columns)\n'
          '• All other settings unchanged\n'
          '• All your jingle files (they stay in the system)\n\n'
          '💡 WHEN TO USE THIS:\n'
          '• You want to start fresh with manual assignments\n'
          '• You want a completely custom layout\n'
          '• You prefer to assign each button yourself\n\n'
          'You can assign jingles by right-clicking empty buttons,\n'
          'or use "Reset Assignments" to get defaults back.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              await ref
                  .read(jingleGridConfigProvider.notifier)
                  .clearAllAssignments();
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'All jingle assignments cleared - grid is now empty',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            child: const Text('Clear All Assignments'),
          ),
        ],
      ),
    );
  }
}

class GridSettingsButton extends ConsumerWidget {
  const GridSettingsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (columns, rows) = ref.watch(gridSettingsProvider);

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grid Layout: ${columns}x$rows',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(4),
              Text(
                'Configure the number of columns and rows in the jingle grid',
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
            Icons.grid_view,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const GridSettingsDialog(),
    );
  }
}

class GridSettingsDialog extends ConsumerStatefulWidget {
  const GridSettingsDialog({super.key});

  @override
  ConsumerState<GridSettingsDialog> createState() => _GridSettingsDialogState();
}

class _GridSettingsDialogState extends ConsumerState<GridSettingsDialog> {
  late int columns;
  late int rows;

  @override
  void initState() {
    super.initState();
    final (initialColumns, initialRows) = ref.read(gridSettingsProvider);
    columns = initialColumns;
    rows = initialRows;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Grid Layout Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configure the grid layout for jingles',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const Gap(16),

          // Columns setting
          Text(
            'Number of Columns',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: columns.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: columns.toString(),
                  onChanged: (value) {
                    setState(() {
                      columns = value.toInt();
                    });
                    // Update in real-time
                    ref
                        .read(gridSettingsProvider.notifier)
                        .updateSettings(columns, rows);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  columns.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),

          const Gap(16),

          // Rows setting
          Text(
            'Number of Rows',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: rows.toDouble(),
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: rows.toString(),
                  onChanged: (value) {
                    setState(() {
                      rows = value.toInt();
                    });
                    // Update in real-time
                    ref
                        .read(gridSettingsProvider.notifier)
                        .updateSettings(columns, rows);
                  },
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  rows.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Restore previous settings when canceling
            final (prevColumns, prevRows) = ref.read(gridSettingsProvider);
            ref
                .read(gridSettingsProvider.notifier)
                .updateSettings(prevColumns, prevRows);
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
