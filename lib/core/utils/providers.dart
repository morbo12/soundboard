import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';

final lineupFileProvider = StateProvider<String>((ref) {
  return "";
});
final azCharCountProvider = StateProvider<int>(
  (ref) => SettingsBox().azCharCount,
);

// final mainStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

// final sbStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

// final jpStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

// final spoStateProvider = StateProvider<PlayerState>((ref) {
//   return PlayerState.stopped;
// });

final voicesProvider = StateProvider<VoicesSuccessUniversal>((ref) {
  return VoicesSuccessUniversal(voices: [], code: 200, reason: "N/A");
});

// final c1ColorProvider = StateProvider<Color>((ref) {
//   return const Color(0xffe3e2e6);
// });

// final c2ColorProvider = StateProvider<Color>((ref) {
//   return const Color(0xffe3e2e6);
// });

final colorThemeProvider = StateProvider<FlexScheme>((ref) {
  return FlexScheme.greyLaw;
});
