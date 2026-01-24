import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/config_providers.dart';
import 'package:soundboard/core/services/usage_stats_service.dart';

/// Widget for toggling anonymous usage statistics in settings
class UsageStatsToggle extends ConsumerWidget {
  const UsageStatsToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = SettingsBox();
    final isEnabled = ref.watch(usageStatsEnabledProvider);

    return SwitchListTile(
      title: const Text('Anonymous Usage Statistics'),
      subtitle: const Text(
        'Help improve the app by sending anonymized feature usage.\n'
        'No personal data is collected; events are only associated with your device ID.',
      ),
      value: isEnabled,
      onChanged: (value) {
        settings.usageStatsEnabled = value;
        ref.read(usageStatsEnabledProvider.notifier).state = value;
      },
      secondary: const Icon(Icons.insights_outlined),
    );
  }
}

/// Lightweight diagnostics to help verify usage stats behavior in development.
class UsageStatsDiagnostics extends ConsumerWidget {
  const UsageStatsDiagnostics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.read(usageStatsServiceProvider);
    final buffer = service.getBufferSize();

    return Row(
      children: [
        Expanded(
          child: Text(
            'Buffered events: $buffer  •  Flush every: ${service.flushEvery.inSeconds}s',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        TextButton.icon(
          onPressed: () async {
            final ok = await service.flush();
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(ok ? 'Flushed usage events' : 'No events to flush'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          icon: const Icon(Icons.sync),
          label: const Text('Flush now'),
        ),
      ],
    );
  }
}
