import 'package:flutter_riverpod/flutter_riverpod.dart';

enum PlayerState { normal, goal, assist, penalty }

final playerStatesProvider =
    StateNotifierProvider<PlayerStatesNotifier, Map<String, PlayerState>>(
        (ref) {
  return PlayerStatesNotifier();
});

class PlayerStatesNotifier extends StateNotifier<Map<String, PlayerState>> {
  PlayerStatesNotifier() : super({});

// New read method
  PlayerState readState(String playerId) {
    return state[playerId] ?? PlayerState.normal;
  }

  String? getGoalScorer(WidgetRef ref) {
    final allStates = ref.read(playerStatesProvider);

    return allStates.entries
        .firstWhere((entry) => entry.value == PlayerState.goal,
            orElse: () => MapEntry('', PlayerState.normal))
        .key;
  }

  String? getAssistMaker(WidgetRef ref) {
    final allStates = ref.read(playerStatesProvider);

    return allStates.entries
        .firstWhere((entry) => entry.value == PlayerState.assist,
            orElse: () => MapEntry('', PlayerState.normal))
        .key;
  }

  // New methods for goal and assist
  void setGoalState(String playerId) {
    // First, clear any existing goal states
    final clearedGoalStates = Map<String, PlayerState>.from(state)
      ..removeWhere((key, value) => value == PlayerState.goal);

    // Then set the new goal state
    state = {
      ...clearedGoalStates,
      playerId: state[playerId] == PlayerState.goal
          ? PlayerState.normal
          : PlayerState.goal,
    };
  }

  void setAssistState(String playerId) {
    // First, clear any existing assist states
    final clearedAssistStates = Map<String, PlayerState>.from(state)
      ..removeWhere((key, value) => value == PlayerState.assist);

    // Then set the new assist state
    state = {
      ...clearedAssistStates,
      playerId: state[playerId] = PlayerState.assist == PlayerState.assist
          ? PlayerState.normal
          : PlayerState.assist,
    };
  }

  void setPenaltyState(String playerId) {
    // First, clear any existing assist states
    final clearedAssistStates = Map<String, PlayerState>.from(state)
      ..removeWhere((key, value) => value == PlayerState.penalty);

    // Then set the new assist state
    state = {
      ...clearedAssistStates,
      playerId: state[playerId] == PlayerState.penalty
          ? PlayerState.normal
          : PlayerState.penalty,
    };
  }

  // Optional: Method to clear all states
  void clearAllStates() {
    state = {};
  }

  // Optional: Method to clear specific player state
  void clearPlayerState(String playerId) {
    final newState = Map<String, PlayerState>.from(state);
    newState.remove(playerId);
    state = newState;
  }
}
