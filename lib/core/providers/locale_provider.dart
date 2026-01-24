import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:soundboard/core/properties.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en', 'US')) {
    _loadSavedLocale();
  }

  void _loadSavedLocale() {
    final savedLanguageCode = SettingsBox().appLanguage;
    if (savedLanguageCode.isNotEmpty) {
      state = Locale(savedLanguageCode);
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    SettingsBox().appLanguage = locale.languageCode;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
