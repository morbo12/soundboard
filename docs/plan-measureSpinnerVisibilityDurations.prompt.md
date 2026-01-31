Plan: Measure Spinner Visibility Durations

Goal
- Instrument spinner visibility durations to identify which spinners are useful vs. too brief, prioritizing long AI/TTS operations.

Steps
1. Add `AppSpinner` wrapper
- Replace `CircularProgressIndicator` where long operations occur (AI/TTS, uploads, heavy providers).
- Start a timer on mount and stop on dispose; accept `label` and `size` for context tagging.

2. Implement `LoadingMetricsService`
- Aggregate durations per `label` and route.
- Provide dev-only listing of recent samples and totals; optionally emit `Timeline` events for DevTools.

3. Route tagging
- Wire a `RouteObserver<PageRoute>` in `app.dart`.
- In `AppSpinner`, read `ModalRoute.of(context)?.settings.name` to tag durations by route.

4. Dialog tracking
- Introduce `showLoadingDialog()` utility to record open/close times.
- Use it to replace ad-hoc loading dialogs (e.g., `_showLoadingIndicator()` in `widget_button_clean_cache.dart`).

5. Targeted migration first
- Replace only spinners around long-running API/TTS flows with `AppSpinner(label: 'tts:request')`.
- Leave short `AsyncValue.when(loading)` center spinners unchanged initially.

Further Considerations
- Accuracy vs. overhead: simple mount/dispose timing (fast) vs. `visibility_detector` for precise on-screen time (heavier).
- Correlate with provider transitions: optional `ProviderObserver` to log `AsyncValue.loading→data/error` for key providers.
- Output channels: in-memory dev view, logs, and `Timeline` marks for inspection.
