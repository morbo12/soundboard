import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_config_notifier.dart';

class GridSettingsSection extends ConsumerWidget {
  const GridSettingsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Column(
      children: [GridSettingsButton(), Gap(8), GridResetButton()],
    );
  }
}

class GridResetButton extends ConsumerWidget {
  const GridResetButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Reset Everything button (full width)
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
