import 'package:flutter/material.dart';
import 'package:soundboard/common/widgets/class_large_button.dart';
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
    return Row(
      children: [
        Expanded(
          child: LargeButton(
            style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
              backgroundColor: Theme.of(context).colorScheme.errorContainer,
              fixedSize: const Size.fromHeight(100),
            ),
            noLines: 1,

            onTap: _isLoading ? null : () => _handleCacheDeletion(),
            secondaryText: 'N/A',
            primaryText: "!!! DANGER - Delete jingle cache - DANGER !!!",
          ),
        ),
      ],
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
