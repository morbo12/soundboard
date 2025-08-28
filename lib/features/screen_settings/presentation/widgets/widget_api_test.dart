import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/providers/auth_providers.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';

class ApiTestWidget extends ConsumerStatefulWidget {
  const ApiTestWidget({super.key});

  @override
  ConsumerState<ApiTestWidget> createState() => _ApiTestWidgetState();
}

class _ApiTestWidgetState extends ConsumerState<ApiTestWidget> {
  static const Logger _logger = Logger('ApiTestWidget');
  bool _isTesting = false;

  Future<void> _testAuthentication() async {
    setState(() {
      _isTesting = true;
    });

    try {
      final authService = ref.read(authServiceProvider);
      final settings = SettingsBox();

      _logger.i(
        'Testing authentication with product key: ${settings.apiProductKey.isNotEmpty ? "***${settings.apiProductKey.substring(settings.apiProductKey.length - 4)}" : "EMPTY"}',
      );

      // Test authentication
      final isAuthenticated = await authService.authenticate();

      if (isAuthenticated) {
        _logger.i('Authentication successful');

        // Test connection
        final connectionStatus = await ref.refresh(
          apiConnectionStatusProvider.future,
        );
        _logger.i('Connection test result: $connectionStatus');

        // Test voice fetching
        final voices = await ref.refresh(apiVoicesProvider.future);
        _logger.i('Voices fetched: ${voices?.length ?? 0} voices available');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ API Test Successful!\n${voices?.length ?? 0} voices available',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        _logger.e('Authentication failed');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Authentication failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      _logger.e('API test failed: $e', stackTrace);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ API Test Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTesting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsBox();
    final hasApiKey = settings.apiProductKey.isNotEmpty;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Soundboard API Test',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // API Key Status
            Row(
              children: [
                Icon(
                  hasApiKey ? Icons.check_circle : Icons.warning,
                  color: hasApiKey ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  hasApiKey ? 'API Key: Configured' : 'API Key: Not configured',
                  style: TextStyle(
                    color: hasApiKey ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasApiKey && !_isTesting
                    ? _testAuthentication
                    : null,
                icon: _isTesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_isTesting ? 'Testing...' : 'Test API Connection'),
              ),
            ),

            const SizedBox(height: 16),

            // Connection Status
            Consumer(
              builder: (context, ref, child) {
                final connectionAsync = ref.watch(apiConnectionStatusProvider);
                return connectionAsync.when(
                  data: (isConnected) => Row(
                    children: [
                      Icon(
                        isConnected ? Icons.cloud_done : Icons.cloud_off,
                        color: isConnected ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected ? 'Connected to API' : 'Not connected',
                        style: TextStyle(
                          color: isConnected ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Testing connection...'),
                    ],
                  ),
                  error: (error, stack) => const Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Connection error',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // Voices Status
            Consumer(
              builder: (context, ref, child) {
                final voicesAsync = ref.watch(apiVoicesProvider);
                return voicesAsync.when(
                  data: (voices) => Row(
                    children: [
                      Icon(
                        voices != null && voices.isNotEmpty
                            ? Icons.record_voice_over
                            : Icons.voice_over_off,
                        color: voices != null && voices.isNotEmpty
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        voices != null && voices.isNotEmpty
                            ? '${voices.length} voices available'
                            : 'No voices available',
                        style: TextStyle(
                          color: voices != null && voices.isNotEmpty
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 8),
                      Text('Loading voices...'),
                    ],
                  ),
                  error: (error, stack) => const Row(
                    children: [
                      Icon(Icons.error, color: Colors.red),
                      SizedBox(width: 8),
                      Text(
                        'Error loading voices',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Contains AI-generated edits.
