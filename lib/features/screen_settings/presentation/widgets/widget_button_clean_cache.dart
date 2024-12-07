import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common_widgets/button.dart';

class CleanCacheButton extends StatefulWidget {
  const CleanCacheButton({super.key}); // Updated constructor

  @override
  CleanCacheButtonToDirState createState() => CleanCacheButtonToDirState();
}

class CleanCacheButtonToDirState extends State<CleanCacheButton> {
  // File? file;
  // final ValueNotifier<String?> selectedPath = ValueNotifier(null);

  Future<void> _deleteCacheDirectory() async {
    try {
      // Get the cache directory
      final Directory cacheDir = await getApplicationCacheDirectory();

      // Check if the directory exists
      if (await cacheDir.exists()) {
        // Delete the directory and its contents
        await cacheDir.delete(recursive: true);

        if (kDebugMode) {
          print("Cache directory deleted: ${cacheDir.path}");
        }
      } else {
        if (kDebugMode) {
          print("Cache directory does not exist: ${cacheDir.path}");
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error deleting cache directory: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Button(
          style: ElevatedButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
            backgroundColor: Theme.of(context).colorScheme.errorContainer,
            fixedSize: Size.fromHeight(100),
            // side: BorderSide(
            // width: 1, color: Theme.of(context).colorScheme.primaryContainer),
          ),
          noLines: 1,
          isSelected: true,
          onTap: () async {
            final Directory _cacheDir = await getApplicationCacheDirectory();

            // Invoke the file picker UI function
            bool? confirm = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Confirm Deletion'),
                  content: Text(
                      'Are you sure you want to delete the cache? \n${_cacheDir.path}'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Cancel'),
                      onPressed: () {
                        Navigator.of(context).pop(false); // Return false
                      },
                    ),
                    TextButton(
                      child: Text('Delete'),
                      onPressed: () {
                        Navigator.of(context).pop(true); // Return true
                      },
                    ),
                  ],
                );
              },
            );

            if (confirm == true) {
              await _deleteCacheDirectory();
            }
          },
          secondaryText: 'N/A',
          primaryText:
              "!!! DANGER - Delete jingle cache - DANGER !!!", // Use directory name for the button text
        ),
      ],
    );
  }
}
