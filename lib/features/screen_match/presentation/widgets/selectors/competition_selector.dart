import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/competition.dart';
import 'package:soundboard/features/screen_match/presentation/providers/match_setup_providers.dart';

final competitionsProvider = StateProvider<List<Competition>>((ref) => []);

class CompetitionSelector extends ConsumerWidget {
  const CompetitionSelector({super.key});

  Future<void> _loadCompetitions(WidgetRef ref) async {
    final state = ref.read(matchSetupStateProvider);
    final service = ref.read(matchSetupServiceProvider);
    final notifier = ref.read(matchSetupStateProvider.notifier);

    try {
      notifier.setLoading(true);
      final competitions = await service.getCompetitions(
        federationId: state.selectedFederation,
        type: state.competitionType,
      );
      ref.read(competitionsProvider.notifier).state = competitions;
      notifier.setLoading(false);
    } catch (e) {
      notifier.setError(e.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final competitions = ref.watch(competitionsProvider);
    final selectedCompetitionId = ref
        .watch(matchSetupStateProvider)
        .selectedCompetitionId;
    final state = ref.watch(matchSetupStateProvider);

    if (competitions.isEmpty) {
      return ElevatedButton.icon(
        onPressed: state.isLoading ? null : () => _loadCompetitions(ref),
        icon: const Icon(Icons.refresh),
        label: const Text('Ladda tävlingar'),
      );
    }

    return DropdownButton<int>(
      value: selectedCompetitionId,
      hint: const Text('Välj tävling/turnering'),
      isExpanded: true,
      items: competitions.map((competition) {
        return DropdownMenuItem<int>(
          value: competition.competitionCategoryId,
          child: Text(competition.name),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          ref.read(matchSetupStateProvider.notifier).updateCompetitionId(value);
        }
      },
    );
  }
}
