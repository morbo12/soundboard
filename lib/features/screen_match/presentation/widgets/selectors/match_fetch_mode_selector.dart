import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_match/data/models/match_setup_state.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

class MatchFetchModeSelector extends ConsumerWidget {
  const MatchFetchModeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchFetchMode = ref.watch(matchSetupStateProvider).matchFetchMode;

    return DropdownButton<MatchFetchMode>(
      value: matchFetchMode,
      isExpanded: true,
      items: MatchFetchMode.values.map((mode) {
        return DropdownMenuItem<MatchFetchMode>(
          value: mode,
          child: Text(mode.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref
              .read(matchSetupStateProvider.notifier)
              .updateMatchFetchMode(value);
        }
      },
    );
  }
}
