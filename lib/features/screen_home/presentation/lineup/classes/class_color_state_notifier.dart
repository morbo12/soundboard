import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/utils/logger.dart';

enum PlayerState { normal, goal, assist, penalty }

final playerStatesProvider =
    StateNotifierProvider<PlayerStatesNotifier, Map<String, PlayerState>>((
      ref,
    ) {
      return PlayerStatesNotifier();
    });

class PlayerStatesNotifier extends StateNotifier<Map<String, PlayerState>> {
  PlayerStatesNotifier() : super({});
  final Logger logger = const Logger('PlayerStatesNotifier');

  // New read method
  PlayerState readState(String playerId) {
    return state[playerId] ?? PlayerState.normal;
  }

  String? getGoalScorer(WidgetRef ref) {
    final allStates = ref.read(playerStatesProvider);

    return allStates.entries
        .firstWhere(
          (entry) => entry.value == PlayerState.goal,
          orElse: () => const MapEntry('', PlayerState.normal),
        )
        .key;
  }

  String? getAssistMaker(WidgetRef ref) {
    final allStates = ref.read(playerStatesProvider);

    return allStates.entries
        .firstWhere(
          (entry) => entry.value == PlayerState.assist,
          orElse: () => const MapEntry('', PlayerState.normal),
        )
        .key;
  }

  void setGoalState(String playerId) {
    if (playerId.isEmpty) return;

    // Clear any existing goal states
    final updatedState = Map<String, PlayerState>.from(state)
      ..removeWhere((key, value) => value == PlayerState.goal);

    // Then set the new goal state
    updatedState[playerId] = PlayerState.goal;

    state = updatedState;
  }

  void setAssistState(String playerId) {
    if (playerId.isEmpty) return;

    // Clear any existing assist states
    final updatedState = Map<String, PlayerState>.from(state)
      ..removeWhere((key, value) => value == PlayerState.assist);

    // Then set the new assist state
    updatedState[playerId] = PlayerState.assist;

    state = updatedState;
    logger.d("Assist state: ${state[playerId]}");
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
