import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:soundboard/core/utils/providers.dart';

class AppTheme {
  static const _commonSubThemes = FlexSubThemesData(
    blendOnColors: true,
    defaultRadius: 8.0,
    inputDecoratorIsFilled: true,
    alignedDropdown: true,
    tooltipRadius: 4,
    tooltipSchemeColor: SchemeColor.inverseSurface,
    tooltipOpacity: 0.9,
    snackBarElevation: 6,
    snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
    navigationRailUseIndicator: true,
    navigationRailLabelType: NavigationRailLabelType.all,
  );

  static ThemeData _createTheme({
    required WidgetRef ref,
    required bool isDark,
  }) {
    final selectedScheme = ref.watch(colorThemeProvider);

    final baseTheme = isDark
        ? FlexThemeData.dark(
            scheme: selectedScheme,
            subThemesData: _commonSubThemes,
            keyColors: const FlexKeyColors(),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
          )
        : FlexThemeData.light(
            scheme: selectedScheme,
            subThemesData: _commonSubThemes,
            keyColors: const FlexKeyColors(),
            visualDensity: FlexColorScheme.comfortablePlatformDensity,
            useMaterial3: true,
          );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.notoSansTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.notoSansTextTheme(
        baseTheme.primaryTextTheme,
      ),
    );
  }

  static ThemeData lightTheme(WidgetRef ref) =>
      _createTheme(ref: ref, isDark: false);
  static ThemeData darkTheme(WidgetRef ref) =>
      _createTheme(ref: ref, isDark: true);
  static ThemeMode getThemeMode() => ThemeMode.system;
}
