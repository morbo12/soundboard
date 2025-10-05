import 'dart:io';
import 'package:flutter/services.dart';
import 'package:soundboard/core/utils/logger.dart';

class LocaleDetector {
  static const Logger _logger = Logger('LocaleDetector');
  static const MethodChannel _channel = MethodChannel(
    'com.fbtools.soundboard/locale',
  );

  /// Gets the Windows regional format locale (for date/time/number formatting)
  /// Falls back to system locale if detection fails
  static Future<String> getRegionalFormatLocale() async {
    if (!Platform.isWindows) {
      final systemLocale = Platform.localeName;
      _logger.d('Non-Windows platform, using system locale: $systemLocale');
      return systemLocale;
    }

    try {
      final String? regionalLocale = await _channel.invokeMethod(
        'getRegionalFormatLocale',
      );
      if (regionalLocale != null && regionalLocale.isNotEmpty) {
        _logger.d('Windows regional format locale: $regionalLocale');

        // Map the locale to ensure intl package compatibility
        final mappedLocale = _mapToSupportedLocale(regionalLocale);
        if (mappedLocale != regionalLocale) {
          _logger.d(
            'Mapped $regionalLocale to $mappedLocale for intl package compatibility',
          );
        }

        return mappedLocale;
      }
    } catch (e) {
      _logger.w('Failed to get Windows regional format locale: $e');
    }

    // Fallback to system locale
    final systemLocale = Platform.localeName;
    _logger.d('Falling back to system locale: $systemLocale');
    return systemLocale;
  }

  /// Maps hybrid locales (e.g., en_SE) to their regional equivalents
  /// for better intl package compatibility
  static String _mapToSupportedLocale(String locale) {
    // Split locale into language and country
    final parts = locale.split('_');
    if (parts.length != 2) {
      return locale; // Return as-is if format is unexpected
    }

    final language = parts[0];
    final country = parts[1];

    // Map of country codes to their primary language locales
    // This handles cases like en_SE -> sv_SE, en_DE -> de_DE, etc.
    const countryToLocale = {
      'SE': 'sv_SE', // Sweden -> Swedish
      'DE': 'de_DE', // Germany -> German
      'FR': 'fr_FR', // France -> French
      'ES': 'es_ES', // Spain -> Spanish
      'IT': 'it_IT', // Italy -> Italian
      'NL': 'nl_NL', // Netherlands -> Dutch
      'NO': 'nb_NO', // Norway -> Norwegian Bokmål
      'DK': 'da_DK', // Denmark -> Danish
      'FI': 'fi_FI', // Finland -> Finnish
      'PL': 'pl_PL', // Poland -> Polish
      'PT': 'pt_PT', // Portugal -> Portuguese
      'RU': 'ru_RU', // Russia -> Russian
      'JP': 'ja_JP', // Japan -> Japanese
      'CN': 'zh_CN', // China -> Chinese (Simplified)
      'KR': 'ko_KR', // Korea -> Korean
      'BR': 'pt_BR', // Brazil -> Portuguese (Brazil)
      'MX': 'es_MX', // Mexico -> Spanish (Mexico)
      'AR': 'es_AR', // Argentina -> Spanish (Argentina)
      'CA':
          'en_CA', // Canada -> English (Canada) - or fr_CA depending on preference
      'GB': 'en_GB', // UK -> English (UK)
      'US': 'en_US', // USA -> English (US)
      'AU': 'en_AU', // Australia -> English (Australia)
      'NZ': 'en_NZ', // New Zealand -> English (New Zealand)
      'IE': 'en_IE', // Ireland -> English (Ireland)
      'AT': 'de_AT', // Austria -> German (Austria)
      'CH':
          'de_CH', // Switzerland -> German (Switzerland) - could also be fr_CH or it_CH
      'BE': 'nl_BE', // Belgium -> Dutch (Belgium) - could also be fr_BE
    };

    // If the language doesn't match the country's primary language,
    // use the country's primary language for date formatting
    if (countryToLocale.containsKey(country)) {
      final countryLocale = countryToLocale[country]!;
      final countryLanguage = countryLocale.split('_')[0];

      // If using English (or another foreign language) with a regional format,
      // prefer the regional locale for formatting
      if (language != countryLanguage) {
        return countryLocale;
      }
    }

    // Return original locale if no mapping needed
    return locale;
  }

  /// Gets the system display language locale
  static String getSystemLocale() {
    return Platform.localeName;
  }
}
