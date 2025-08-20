import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/lineup.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match_event.dart';
import 'package:soundboard/core/services/innebandy_api/domain/entities/match.dart';

// Provider to toggle between manual and API lineup modes
final isManualLineupModeProvider = StateProvider<bool>((ref) => false);

// Providers for manual team names
final manualHomeTeamNameProvider = StateProvider<String>((ref) => 'Home Team');
final manualAwayTeamNameProvider = StateProvider<String>((ref) => 'Away Team');

// Providers for manual team players
final manualHomeTeamPlayersProvider = StateProvider<List<TeamPlayer>>(
  (ref) => [],
);
final manualAwayTeamPlayersProvider = StateProvider<List<TeamPlayer>>(
  (ref) => [],
);

// Provider for manual match events
final manualEventsProvider = StateProvider<List<IbyMatchEvent>>((ref) => []);

// Provider for manual lineup data
final manualLineupProvider = StateProvider<IbyMatchLineup?>((ref) => null);

// Provider for manual match - creates a mock match when in manual mode
final effectiveMatchProvider = Provider<IbyMatch>((ref) {
  final isManualMode = ref.watch(isManualLineupModeProvider);
  final selectedMatch = ref.watch(selectedMatchProvider);

  if (isManualMode) {
    final homeTeamName = ref.watch(manualHomeTeamNameProvider);
    final awayTeamName = ref.watch(manualAwayTeamNameProvider);

    // Create a manual match with custom team names
    return IbyMatch(
      matchId: 999999, // Special ID for manual matches
      categoryName: 'Manual Mode',
      competitionName: 'Manual Match',
      matchNo: 'M1',
      matchDateTime: DateTime.now().toString(),
      homeTeam: homeTeamName,
      awayTeam: awayTeamName,
      awayTeamLogotypeUrl: '',
      homeTeamLogotypeUrl: '',
      seasonId: 0,
      venue: 'Manual Setup',
      referee1: '',
      referee2: '',
      matchStatus: 1, // Active status
      intermediateResults: [],
      homeTeamId: 1001,
      awayTeamId: 1002,
      competitionId: 1,
    );
  }

  return selectedMatch;
});

// Combined provider that returns manual lineup when available, otherwise API lineup
final effectiveLineupProvider = Provider<IbyMatchLineup>((ref) {
  final isManualMode = ref.watch(isManualLineupModeProvider);

  if (isManualMode) {
    final manualLineup = ref.watch(manualLineupProvider);
    if (manualLineup != null) {
      return manualLineup;
    }

    // Create lineup from manual team players
    final homeTeamPlayers = ref.watch(manualHomeTeamPlayersProvider);
    final awayTeamPlayers = ref.watch(manualAwayTeamPlayersProvider);
    final effectiveMatch = ref.watch(effectiveMatchProvider);

    return IbyMatchLineup(
      matchId: effectiveMatch.matchId,
      homeTeamId: effectiveMatch.homeTeamId ?? 0,
      homeTeam: effectiveMatch.homeTeam,
      homeTeamShortName: effectiveMatch.homeTeamShortName ?? '',
      homeTeamLogotypeUrl: effectiveMatch.homeTeamLogotypeUrl ?? '',
      awayTeamId: effectiveMatch.awayTeamId ?? 0,
      awayTeam: effectiveMatch.awayTeam,
      awayTeamShortName: effectiveMatch.awayTeamShortName ?? '',
      awayTeamLogotypeUrl: effectiveMatch.awayTeamLogotypeUrl ?? '',
      homeTeamPlayers: homeTeamPlayers,
      awayTeamPlayers: awayTeamPlayers,
      homeTeamTeamPersons: [],
      awayTeamTeamPersons: [],
    );
  }

  // Return API lineup
  return ref.watch(lineupProvider);
});

// Provider that combines manual and API events
final effectiveEventsProvider = Provider<List<IbyMatchEvent>>((ref) {
  final selectedMatch = ref.watch(selectedMatchProvider);
  final manualEvents = ref.watch(manualEventsProvider);
  final apiEvents = selectedMatch.events ?? [];

  // Combine and sort by time
  final allEvents = <IbyMatchEvent>[...apiEvents, ...manualEvents];
  allEvents.sort((a, b) {
    if (a.period != b.period) return a.period.compareTo(b.period);
    if (a.minute != b.minute) return a.minute.compareTo(b.minute);
    return a.second.compareTo(b.second);
  });

  return allEvents;
});

// Auto-incrementing ID for manual events
final manualEventIdProvider = StateProvider<int>(
  (ref) => 999999,
); // Start with high number to avoid conflicts

// Next available manual event ID
final nextManualEventIdProvider = Provider<int>((ref) {
  final currentId = ref.watch(manualEventIdProvider);
  ref.read(manualEventIdProvider.notifier).state = currentId + 1;
  return currentId + 1;
});
