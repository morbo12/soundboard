## Localization Plan

- **Detect & supply locale** – Use the existing `LocaleDetector` plus Flutter’s `localizationsDelegates`/`supportedLocales` so the app automatically adapts to the system locale (English + Swedish only for now). Ensure MaterialApp’s `locale` and fallback behavior are wired to a single source of truth (e.g., a `StateProvider<Locale>`).

- **Translation resources** – Create a base `en.json` ARB-style file in `translations/` containing every user-facing label, button text, dialog title, snackbar, etc. Add a matching `sv.json` with Swedish equivalents wherever possible (best effort). Include `intl` codegen if helpful, or simple JSON lookup helper.

- **Strings replacement** – Replace hard-coded strings in widgets (especially in `lib/features/...`, `lib/common/widgets`, `lib/app.dart`) with localized lookups (e.g., via `AppStrings.of(context)` or `context.l10n`). Keep UI structure the same but call the shared translation helper so new languages flow automatically.

- **Runtime language switch** – Add a settings option (under Localization/Language in the Settings screen) that lets the user pick English or Swedish. Update a Riverpod provider storing the chosen locale; when it changes, rebuild MaterialApp with the new `locale`. Persist the choice via your existing settings storage so it “sticks.”

- **Documentation & contribution guide** – Document in `docs/` or README how to add a new language: file naming, key formatting, how to use the translator helper, and how to add the locale to `supportedLocales`. Mention RTL considerations.

- **Testing & fallback** – Add simple widget tests that render a key screen in both locales to ensure lookups succeed. Ensure missing keys fall back to English (the base). Optionally log warnings when a translation is missing.
