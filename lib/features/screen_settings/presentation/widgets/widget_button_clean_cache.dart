import 'package:flutter/material.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/class_cache_service.dart';

class CleanCacheButton extends StatefulWidget {
  const CleanCacheButton({super.key}); // Updated constructor

  @override
  CleanCacheButtonState createState() => CleanCacheButtonState();
}

class CleanCacheButtonState extends State<CleanCacheButton> {
  final CacheService _cacheService = CacheService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.errorContainer,
              Theme.of(context).colorScheme.errorContainer.withAlpha(200),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: _isLoading ? null : () => _handleCacheDeletion(),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error.withAlpha(50),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.delete_forever,
                    color: Theme.of(context).colorScheme.error,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'DANGER - Delete Jingle Cache',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onErrorContainer,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'CRITICAL',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Permanently removes all uploaded jingle files from cache storage',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onErrorContainer.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_isLoading)
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.error,
                    ),
                  )
                else
                  Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Note: No BuildContext parameter here
  Future<void> _handleCacheDeletion() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get cache directory and size
      final cacheDir = await _cacheService.getCacheDirectory();
      final cacheSize = await _cacheService.calculateCacheSize(cacheDir);
      final formattedSize = _cacheService.formatBytes(cacheSize);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Now we can safely use context since we're back in sync code
      final shouldDelete = await _showConfirmationDialog(
        cacheDir.path,
        formattedSize,
      );

      if (shouldDelete == true) {
        _showLoadingIndicator();

        final success = await _cacheService.clearCache(cacheDir);

        if (!mounted) return;

        // Close loading dialog
        Navigator.of(context).pop();

        // Show feedback
        _showResultFeedback(success);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showErrorFeedback(e.toString());
    }
  }

  // Helper methods that use the current context
  Future<bool?> _showConfirmationDialog(String cachePath, String cacheSize) {
    return showDialog<bool>(
      context: context, // Using the current context is safe here
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Cache Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to delete the cache?'),
              const SizedBox(height: 16),
              Text('Location: $cachePath'),
              const SizedBox(height: 8),
              Text('Size: $cacheSize'),
              const SizedBox(height: 16),
              const Text(
                'Warning: This will remove all cached jingles.',
                style: TextStyle(color: Colors.orange),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  void _showLoadingIndicator() {
    showDialog(
      context: context, // Using the current context is safe here
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 20),
              const Text("Clearing cache..."),
            ],
          ),
        );
      },
    );
  }

  void _showResultFeedback(bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Cache successfully cleared'
              : 'Cache directory not found or already empty',
        ),
        backgroundColor: success ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorFeedback(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to clear cache: $errorMessage'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}

// Contains AI-generated edits.
