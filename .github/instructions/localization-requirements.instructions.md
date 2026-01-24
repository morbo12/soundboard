---
applyTo: "**/*.dart"
description: "Mandatory localization requirements - all UI strings must use the translation system"
---

# Localization Requirements

## CRITICAL RULE: NO HARDCODED UI STRINGS

**Every user-facing string MUST use the localization system.**

## How to Add New UI Text

### Step 1: Add Translation Keys

Add the key to ALL translation files:

**`assets/translations/en.json`:**

```json
{
  "your_section": {
    "your_key": "English Text"
  }
}
```

**`assets/translations/sv.json`:**

```json
{
  "your_section": {
    "your_key": "Swedish Text"
  }
}
```

**`assets/translations/cs.json`:**

```json
{
  "your_section": {
    "your_key": "Czech Text"
  }
}
```

### Step 2: Use in Code

```dart
// Import localization
import 'package:soundboard/core/utils/app_localizations.dart';

// In your widget
@override
Widget build(BuildContext context) {
  final l10n = context.l10n;

  return Text(
    l10n.translate('your_section.your_key'),
  );
}
```

## What Requires Translation

✅ **MUST be localized:**

- Button labels
- Screen titles
- Dialog text
- Error messages
- Status messages
- Tooltips
- Placeholders
- Snackbar messages
- Any text visible to users

❌ **Does NOT need localization:**

- Log messages (Logger output)
- Debug prints
- Developer comments
- Technical identifiers
- API keys/URLs
- File paths

## Examples

### ❌ WRONG - Hardcoded String

```dart
Text('Live')  // FORBIDDEN!
TextButton(child: Text('Start Live'))  // FORBIDDEN!
showDialog(title: Text('Error'))  // FORBIDDEN!
```

### ✅ CORRECT - Localized

```dart
Text(l10n.translate('match_status.live'))
TextButton(child: Text(l10n.translate('match_status.start_live')))
showDialog(title: Text(l10n.translate('common.error')))
```

## Testing

The test `test/l10n/translation_keys_exist_test.dart` will catch missing translations, but you should verify:

1. All translation files (en.json, sv.json, cs.json) have the same keys
2. Translations make sense in context
3. Text fits in UI at all translations

## Code Review Checklist

When reviewing PRs, check:

- [ ] All new UI strings use `context.l10n.translate()`
- [ ] Translation keys exist in en.json, sv.json, AND cs.json
- [ ] Keys follow the existing naming pattern (section.specific_key)
- [ ] No string literals in Text, TextButton, Dialog widgets

## Common Mistakes

1. **Concatenating localized strings** - Don't do it, create separate keys
2. **Using string interpolation** - Use parameterized translations instead
3. **Forgetting to add to all languages** - Always update en.json, sv.json, AND cs.json
4. **Using variables for static text** - Still needs to come from translations

## Exception: Debug Mode Only

If text is ONLY shown in debug builds, you may use literals:

```dart
if (kDebugMode) {
  print('Debug info: $data'); // OK - not user-facing
}
```
