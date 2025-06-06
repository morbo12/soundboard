import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/constants/message_types.dart';
import 'package:soundboard/core/services/jingle_manager/class_jingle_manager.dart';

/// Provider for the JingleManager instance
/// This follows Riverpod best practices by managing the JingleManager lifecycle
/// and providing dependency injection throughout the application
final jingleManagerProvider =
    AsyncNotifierProvider<JingleManagerNotifier, JingleManager>(
      () => JingleManagerNotifier(),
    );

/// Notifier for managing JingleManager state and initialization
class JingleManagerNotifier extends AsyncNotifier<JingleManager> {
  @override
  Future<JingleManager> build() async {
    // Initialize the JingleManager when the provider is first accessed
    final jingleManager = JingleManager(
      showMessageCallback: _showMessageCallback,
    );

    await jingleManager.initialize();
    return jingleManager;
  }

  /// Callback for showing messages from JingleManager
  /// During initialization, we only log messages to avoid UI issues
  /// Toast messages will be shown later when the UI is ready
  void _showMessageCallback({
    required MessageType type,
    required String message,
  }) {
    // During provider initialization, only log messages to avoid context issues
    // This prevents snackbar flashing during app startup
    print('JingleManager: [$type] $message');

    // Note: If you need to show messages after initialization is complete,
    // use a separate messaging system or state management
  }

  /// Reinitialize the JingleManager
  /// Useful for refreshing the audio files or handling configuration changes
  Future<void> reinitialize() async {
    state = const AsyncValue.loading();
    try {
      final jingleManager = JingleManager(
        showMessageCallback: _showMessageCallback,
      );
      await jingleManager.initialize();
      state = AsyncValue.data(jingleManager);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

/// Convenience provider to access the AudioManager from JingleManager
/// This follows the pattern of providing easy access to commonly used sub-components
final audioManagerProvider = Provider<AsyncValue<dynamic>>((ref) {
  final jingleManagerAsync = ref.watch(jingleManagerProvider);
  return jingleManagerAsync.when(
    data: (jingleManager) => AsyncValue.data(jingleManager.audioManager),
    loading: () => const AsyncValue.loading(),
    error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
  );
});
