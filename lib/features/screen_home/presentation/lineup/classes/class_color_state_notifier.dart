import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common/models/enum_goaltypes.dart';
import 'package:soundboard/core/utils/logger.dart';

final GoalTypeStatesProvider =
    StateNotifierProvider<GoalTypeStatesNotifier, Map<String, GoalTypeState>>((
      ref,
    ) {
      return GoalTypeStatesNotifier();
    });

class GoalTypeStatesNotifier extends StateNotifier<Map<String, GoalTypeState>> {
  GoalTypeStatesNotifier() : super({});
  final Logger logger = const Logger('GoalTypeStatesNotifier');

  // New read method
  GoalTypeState readState(String playerId) {
    return state[playerId] ?? GoalTypeState.normal;
  }

  String? getGoalScorer(WidgetRef ref) {
    final allStates = ref.read(GoalTypeStatesProvider);

    return allStates.entries
        .firstWhere(
          (entry) => entry.value == GoalTypeState.goal,
          orElse: () => const MapEntry('', GoalTypeState.normal),
        )
        .key;
  }

  String? getAssistMaker(WidgetRef ref) {
    final allStates = ref.read(GoalTypeStatesProvider);

    return allStates.entries
        .firstWhere(
          (entry) => entry.value == GoalTypeState.assist,
          orElse: () => const MapEntry('', GoalTypeState.normal),
        )
        .key;
  }

  void setGoalState(String playerId) {
    if (playerId.isEmpty) return;

    // Clear any existing goal states
    final updatedState = Map<String, GoalTypeState>.from(state)
      ..removeWhere((key, value) => value == GoalTypeState.goal);

    // Then set the new goal state
    updatedState[playerId] = GoalTypeState.goal;

    state = updatedState;
  }

  void setAssistState(String playerId) {
    if (playerId.isEmpty) return;

    // Clear any existing assist states
    final updatedState = Map<String, GoalTypeState>.from(state)
      ..removeWhere((key, value) => value == GoalTypeState.assist);

    // Then set the new assist state
    updatedState[playerId] = GoalTypeState.assist;

    state = updatedState;
    logger.d("Assist state: ${state[playerId]}");
  }

  void setPenaltyState(String playerId) {
    // First, clear any existing assist states
    final clearedAssistStates = Map<String, GoalTypeState>.from(state)
      ..removeWhere((key, value) => value == GoalTypeState.penalty);

    // Then set the new assist state
    state = {
      ...clearedAssistStates,
      playerId: state[playerId] == GoalTypeState.penalty
          ? GoalTypeState.normal
          : GoalTypeState.penalty,
    };
  }

  // Optional: Method to clear all states
  void clearAllStates() {
    state = {};
  }

  // Optional: Method to clear specific player state
  void clearGoalTypeState(String playerId) {
    final newState = Map<String, GoalTypeState>.from(state);
    newState.remove(playerId);
    state = newState;
  }
}
