import 'package:flutter/material.dart';

/// Global navigator key for accessing context from service layers and non-widget contexts.
///
/// ⚠️ Use sparingly! Prefer passing BuildContext through dependency injection
/// or using Riverpod providers for navigation state management.
///
/// Valid use cases:
/// - Service layer dialogs (e.g., migration prompts)
/// - Error handling from background services
/// - Deep linking navigation from system notifications
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Contains AI-generated edits.
