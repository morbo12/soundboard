import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

class FederationSelector extends ConsumerWidget {
  const FederationSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final federations = ref.watch(federationsProvider);
    final selectedFederation =
        ref.watch(matchSetupStateProvider).selectedFederation;

    return DropdownButton<int>(
      value: selectedFederation,
      isExpanded: true,
      items:
          federations.map((federation) {
            return DropdownMenuItem<int>(
              value: federation.id,
              child: Text(federation.name),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(matchSetupStateProvider.notifier).updateFederation(value);
        }
      },
    );
  }
}
