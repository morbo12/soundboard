import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  late final Map<String, Object?> _localizedStrings;

  static AppLocalizations of(BuildContext context) {
    final localizations = Localizations.of<AppLocalizations>(
      context,
      AppLocalizations,
    );
    assert(localizations != null, 'AppLocalizations not found in widget tree');
    return localizations!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<void> load() async {
    _localizedStrings = await _loadJsonForLocale(locale);
  }

  String translate(String key) {
    final keys = key.split('.');
    Object? value = _localizedStrings;

    for (final part in keys) {
      if (value is Map<String, Object?> && value.containsKey(part)) {
        value = value[part];
        continue;
      }

      if (kDebugMode) {
        debugPrint('Missing translation key: $key');
      }
      return key;
    }

    return value?.toString() ?? key;
  }

  String get appTitle => translate('app_title');

  static Future<Map<String, Object?>> _loadJsonForLocale(Locale locale) async {
    final languageCode = locale.languageCode;

    try {
      return await _loadJsonAsset('assets/translations/$languageCode.json');
    } on FlutterError {
      if (languageCode == 'en') {
        rethrow;
      }
      return _loadJsonAsset('assets/translations/en.json');
    }
  }

  static Future<Map<String, Object?>> _loadJsonAsset(String assetPath) async {
    final jsonString = await rootBundle.loadString(assetPath);
    final decoded = json.decode(jsonString);

    if (decoded is! Map<String, Object?>) {
      throw FormatException(
        'Localization JSON must be a JSON object: $assetPath',
      );
    }

    return decoded;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  static const _supportedLanguageCodes = <String>['en', 'sv', 'cs'];

  @override
  bool isSupported(Locale locale) =>
      _supportedLanguageCodes.contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
