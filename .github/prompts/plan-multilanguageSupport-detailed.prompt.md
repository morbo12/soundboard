## Localization Plan - Implementation Guide

### Phase 1: Setup Translation Infrastructure

#### Task 1.1: Create Translation Files

**Location:** `assets/translations/`
**Files to create:**

- `en.json` - English translations (base/fallback language)
- `sv.json` - Swedish translations

**File structure example:**

```json
{
  "app_title": "Soundboard",
  "common": {
    "cancel": "Cancel",
    "save": "Save",
    "delete": "Delete",
    "close": "Close",
    "error": "Error"
  },
  "jingle_options": {
    "title": "Jingle Options",
    "change_jingle": "Change Jingle",
    "change_display_name": "Change Display Name",
    "jingle_info": "Jingle Info",
    "assign_hotkey": "Assign Hotkey",
    "delete_assignment": "Delete Assignment"
  }
}
```

**Swedish equivalents in `sv.json`:**

```json
{
  "app_title": "Ljudpanel",
  "common": {
    "cancel": "Avbryt",
    "save": "Spara",
    "delete": "Ta bort",
    "close": "Stäng",
    "error": "Fel"
  },
  "jingle_options": {
    "title": "Jingle-alternativ",
    "change_jingle": "Ändra jingle",
    "change_display_name": "Ändra visningsnamn",
    "jingle_info": "Jingle-info",
    "assign_hotkey": "Tilldela snabbtangent",
    "delete_assignment": "Ta bort tilldelning"
  }
}
```

#### Task 1.2: Update pubspec.yaml

**File:** `pubspec.yaml`
**Action:** Add assets section if not present:

```yaml
flutter:
  assets:
    - assets/translations/en.json
    - assets/translations/sv.json
```

**Dependencies already present (verify):**

- `flutter_localizations` from SDK
- `intl: ^0.20.2`

#### Task 1.3: Create AppLocalizations Helper

**File to create:** `lib/core/utils/app_localizations.dart`

**Complete implementation:**

```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap;
    return true;
  }

  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _localizedStrings;

    for (final k in keys) {
      if (value is Map && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation missing
      }
    }

    return value.toString();
  }

  // Convenience getter
  String get appTitle => translate('app_title');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'sv'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// Extension for easy access
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
```

### Phase 2: Locale State Management

#### Task 2.1: Create Locale Provider

**File to create:** `lib/core/providers/locale_provider.dart`

**Complete implementation:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
```

#### Task 2.2: Add Language Setting to SettingsBox

**File to modify:** `lib/core/properties.dart`

**Add these properties to SettingsBox class:**

```dart
@HiveField(999) // Use next available field number
String appLanguage = 'en';
```

### Phase 3: Wire Up MaterialApp

#### Task 3.1: Update main.dart

**File:** `lib/main.dart`
**In `_SoundBoardState.build()` method:**

**Add import at top:**

```dart
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:soundboard/core/providers/locale_provider.dart';
```

**Modify MaterialApp widget:**

```dart
@override
Widget build(BuildContext context) {
  final locale = ref.watch(localeProvider);

  return MaterialApp(
    navigatorKey: navigatorKey,
    locale: locale, // ADD THIS LINE
    localizationsDelegates: const [
      AppLocalizations.delegate, // ADD THIS LINE
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', 'US'),
      Locale('sv', 'SE'),
    ],
    // ... rest of existing config
  );
}
```

### Phase 4: Add Language Selector to Settings

#### Task 4.1: Create Language Selector Widget

**File to create:** `lib/features/screen_settings/presentation/widgets/widget_language_selector.dart`

**Complete implementation:**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Language / Språk',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: currentLocale.languageCode,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: 'en',
                  child: Text('English'),
                ),
                DropdownMenuItem(
                  value: 'sv',
                  child: Text('Svenska'),
                ),
              ],
              onChanged: (String? newValue) {
                if (newValue != null) {
                  ref.read(localeProvider.notifier).setLocale(
                        Locale(newValue),
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Task 4.2: Add to Settings Screen

**File:** `lib/features/screen_settings/presentation/screen_settings.dart`

**Add import:**

```dart
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_language_selector.dart';
```

**Add widget in appropriate location (near top of settings list):**

```dart
const LanguageSelector(),
```

### Phase 5: Replace Hard-Coded Strings

#### Task 5.1: Update Draggable Jingle Button

**File:** `lib/common/widgets/class_draggable_jingle_button.dart`

**In `_handleLongPress` method, replace AlertDialog:**

```dart
Future<void> _handleLongPress(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n; // ADD THIS LINE

  final choice = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.translate('jingle_options.title')), // CHANGE THIS
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.music_note),
            title: Text(l10n.translate('jingle_options.change_jingle')), // CHANGE THIS
            onTap: () => Navigator.of(context).pop('change_jingle'),
          ),
          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(l10n.translate('jingle_options.change_display_name')), // CHANGE THIS
            onTap: () => Navigator.of(context).pop('change_name'),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.translate('jingle_options.jingle_info')), // CHANGE THIS
            onTap: () => Navigator.of(context).pop('show_info'),
          ),
          ListTile(
            leading: const Icon(Icons.keyboard),
            title: Text(l10n.translate('jingle_options.assign_hotkey')), // CHANGE THIS
            onTap: () => Navigator.of(context).pop('assign_hotkey'),
          ),
          if (widget.audioFile != null &&
              !(widget.audioFile!.filePath.isEmpty &&
                  !widget.audioFile!.isCategoryOnly))
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.translate('jingle_options.delete_assignment')), // CHANGE THIS
              onTap: () => Navigator.of(context).pop('delete_assignment'),
            ),
        ],
      ),
    ),
  );
  // ... rest of method
}
```

**Similar pattern for other dialogs in the same file:**

- `_showChangeDisplayNameDialog` - update title, labels, buttons
- `_showJingleInfo` - update title and labels
- `_deleteJingleAssignment` - update title, content, buttons

### Phase 6: Create Complete Translation Keys

#### Task 6.1: Audit All Strings

**Search for hard-coded strings in these files:**

1. `lib/common/widgets/class_draggable_jingle_button.dart`
2. `lib/common/widgets/class_goal_button.dart`
3. `lib/common/widgets/class_stop_button.dart`
4. `lib/features/screen_settings/presentation/screen_settings.dart`
5. `lib/features/screen_home/presentation/home_screen.dart`
6. `lib/app.dart`

**For each string found:**

1. Add to both `en.json` and `sv.json`
2. Replace in code with `context.l10n.translate('key.path')`

#### Task 6.2: Complete Translation File Structure

**Expand both JSON files with these sections:**

```json
{
  "app_title": "",
  "common": {
    "cancel": "",
    "save": "",
    "delete": "",
    "close": "",
    "error": "",
    "loading": "",
    "empty": "",
    "confirm": ""
  },
  "jingle_options": {},
  "settings": {},
  "home": {},
  "match": {},
  "lineup": {},
  "events": {},
  "music_player": {},
  "dialogs": {},
  "snackbar_messages": {},
  "tooltips": {}
}
```

### Phase 7: Testing & Validation

#### Task 7.1: Manual Testing Checklist

- [ ] Launch app - verify default language matches system
- [ ] Navigate to Settings
- [ ] Find Language selector
- [ ] Switch from English to Swedish - verify UI updates immediately
- [ ] Open jingle options menu - verify Swedish labels
- [ ] Restart app - verify language persists
- [ ] Switch back to English - verify all labels revert

#### Task 7.2: Add Widget Test

**File to create:** `test/widget/locale_switching_test.dart`

**Basic test structure:**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/utils/app_localizations.dart';

void testMain() {
  testWidgets('Language switching updates UI', (tester) async {
    // Test implementation here
  });
}
```

### Phase 8: Documentation

#### Task 8.1: Create Localization Guide

**File to create:** `docs/LOCALIZATION.md`

**Content structure:**

```markdown
# Localization Guide

## Supported Languages

- English (en)
- Swedish (sv)

## Adding a New Language

1. Create `assets/translations/{language_code}.json`
2. Copy structure from `en.json`
3. Translate all values
4. Add locale to `supportedLocales` in `main.dart`
5. Add to `isSupported()` in `app_localizations.dart`
6. Add to dropdown in `widget_language_selector.dart`

## Translation File Format

Use nested JSON structure with dot notation for keys...
```

### Implementation Order

1. **Phase 1** → Setup files and infrastructure (no code changes yet)
2. **Phase 2** → Add state management (can test in isolation)
3. **Phase 3** → Wire to MaterialApp (should see locale detection working)
4. **Phase 4** → Add UI controls (can manually switch languages)
5. **Phase 5** → Replace strings (incremental, file by file)
6. **Phase 6** → Complete all translations
7. **Phase 7** → Test thoroughly
8. **Phase 8** → Document for future contributors

### Key Files Summary

**New files to create:**

- `assets/translations/en.json`
- `assets/translations/sv.json`
- `lib/core/utils/app_localizations.dart`
- `lib/core/providers/locale_provider.dart`
- `lib/features/screen_settings/presentation/widgets/widget_language_selector.dart`
- `docs/LOCALIZATION.md`

**Files to modify:**

- `pubspec.yaml` (add assets)
- `lib/core/properties.dart` (add appLanguage field)
- `lib/main.dart` (wire locale provider)
- `lib/common/widgets/class_draggable_jingle_button.dart` (replace strings)
- All feature screens with user-facing text

### Fallback Strategy

- If translation key missing → return the key itself (visible bug)
- If locale file missing → fall back to English
- Log warnings for missing translations in debug mode
