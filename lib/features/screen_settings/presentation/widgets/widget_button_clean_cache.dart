import 'package:flutter/material.dart';
import 'package:soundboard/common_widgets/button.dart';
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
        Button(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            fixedSize: const Size.fromHeight(100),
          ),
          noLines: 1,
          isSelected: true,
          onTap: _isLoading ? null : () => _handleCacheDeletion(context),
          secondaryText: 'N/A',
          primaryText: "!!! DANGER - Delete jingle cache - DANGER !!!",
        ),
      ],
    );
  }

  Future<void> _handleCacheDeletion(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get cache directory
      final cacheDir = await _cacheService.getCacheDirectory();

      // Calculate cache size
      final cacheSize = await _cacheService.calculateCacheSize(cacheDir);
      final formattedSize = _cacheService.formatBytes(cacheSize);

      // Check if widget is still mounted after async operations
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show confirmation dialog with size info
      final bool? shouldDelete =
          await _showConfirmationDialog(context, cacheDir.path, formattedSize);

      if (!mounted) return;

      if (shouldDelete == true) {
        // Show loading dialog during deletion
        _showLoadingDialog(context);

        // Perform deletion
        final success = await _cacheService.clearCache(cacheDir);

        if (!mounted) return;

        // Close loading dialog
        Navigator.of(context).pop();

        // Show appropriate feedback based on success
        _showFeedback(context, success);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      // Show error feedback
      _showErrorFeedback(context, e.toString());
    }
  }

  Future<bool?> _showConfirmationDialog(
      BuildContext context, String cachePath, String cacheSize) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Cache Deletion'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to delete the cache?'),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text: 'Location: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: cachePath),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyMedium,
                  children: [
                    const TextSpan(
                      text: 'Size: ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: cacheSize),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Warning: This will remove all cached jingles. You may need to download them again.',
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
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
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

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 20),
              const Text("Clearing cache...")
            ],
          ),
        );
      },
    );
  }

  void _showFeedback(BuildContext context, bool success) {
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache successfully cleared'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cache directory not found or already empty'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    // Refresh the widget state
    setState(() {});
  }

  void _showErrorFeedback(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Failed to clear cache',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Error: $errorMessage'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
