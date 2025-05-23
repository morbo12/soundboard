import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_jingle_grid_config_notifier.dart';

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
                  max: 4,
                  divisions: 3,
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
