import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition_type.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

class CompetitionTypeSelector extends ConsumerWidget {
  const CompetitionTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitionType = ref.watch(matchSetupStateProvider).competitionType;

    return DropdownButton<CompetitionType>(
      value: competitionType,
      isExpanded: true,
      items: CompetitionType.values.map((type) {
        return DropdownMenuItem<CompetitionType>(
          value: type,
          child: Text(type.displayName),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref
              .read(matchSetupStateProvider.notifier)
              .updateCompetitionType(value);
        }
      },
    );
  }
}
