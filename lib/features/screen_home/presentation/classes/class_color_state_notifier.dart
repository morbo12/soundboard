import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ButtonState { normal, selected, longPressed }

final buttonStatesProvider =
    StateNotifierProvider<ButtonStatesNotifier, Map<String, ButtonState>>(
        (ref) {
  return ButtonStatesNotifier();
});

class ButtonStatesNotifier extends StateNotifier<Map<String, ButtonState>> {
  ButtonStatesNotifier() : super({});

  void toggleState(String playerId) {
    state = {
      ...state,
      playerId: switch (state[playerId]) {
        ButtonState.longPressed => ButtonState.normal,
        ButtonState.selected => ButtonState.normal,
        _ => ButtonState.selected,
      },
    };
  }

  void setLongPressedState(String playerId) {
    state = {
      ...state,
      playerId: state[playerId] == ButtonState.longPressed
          ? ButtonState.normal
          : ButtonState.longPressed,
    };
  }
}
