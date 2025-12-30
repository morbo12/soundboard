---
post_title: "Localization Guide"
author1: "Lars"
post_slug: "localization-guide"
microsoft_alias: ""
featured_image: ""
categories:
  - "documentation"
tags:
  - "flutter"
  - "localization"
  - "i18n"
ai_note: "Created with AI assistance (GitHub Copilot)."
summary: "How translations work in Soundboard and how to add a new language."
post_date: "2025-12-30"
---

## Supported Languages

- English (`en`)
- Swedish (`sv`)
- Czech (`cs`)

## Overview

This app uses JSON translation files in `assets/translations/`.
UI strings are accessed via `context.l10n.translate('some.dot.key')`.

Fallback behavior:

- If a locale file is missing, the app falls back to English (`en`).
- If a translation key is missing inside a file, the key itself is returned.

## Adding a New Language

1. Create a new translation file.

   - File: `assets/translations/{languageCode}.json`
   - Copy the structure from `assets/translations/en.json`.
   - Translate all values.

2. Register the asset in `pubspec.yaml`.

   - Add: `assets/translations/{languageCode}.json`

3. Add the locale to `MaterialApp.supportedLocales`.

   - File: `lib/main.dart`

4. Add the language code to the localization delegate.

   - File: `lib/core/utils/app_localizations.dart`
   - Update `_supportedLanguageCodes`.

5. Add the language to the Settings dropdown.

   - File: `lib/features/screen_settings/presentation/widgets/widget_language_selector.dart`
   - Add a `DropdownMenuItem` for the new language code.

6. Add a label key for the language name.

   - Key: `languages.{languageNameKey}`
   - Files:
     - `assets/translations/en.json`
     - `assets/translations/sv.json`
     - `assets/translations/{languageCode}.json`

7. Add a flag icon mapping.

   - File: `lib/common/widgets/flag_icon.dart`
   - Map the new `languageCode` to the correct painter.

8. Update the translation-key test.

   - File: `test/l10n/translation_keys_exist_test.dart`
   - Add the new translation file and ensure it contains all used `translate()` keys.

## Translation File Format

Translation files must be JSON objects (top-level map) and use a nested structure
so the app can access values via dot notation.

Example:

```json
{
  "common": {
    "cancel": "Cancel",
    "save": "Save"
  },
  "settings": {
    "items": {
      "language": {
        "title": "Language"
      }
    }
  }
}
```

## Where to Look

- JSON loader + fallback logic: `lib/core/utils/app_localizations.dart`
- Locale persistence (selected language): `lib/core/providers/locale_provider.dart`
- Language dropdown UI: `lib/features/screen_settings/presentation/widgets/widget_language_selector.dart`
- Flag icons: `lib/common/widgets/flag_icon.dart`
- Key coverage test: `test/l10n/translation_keys_exist_test.dart`
