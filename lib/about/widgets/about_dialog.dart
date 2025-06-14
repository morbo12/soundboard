import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';

class AboutDialogWidget extends StatelessWidget {
  static const _logger = Logger('AboutDialogWidget');

  final Future<PackageInfo>? packageInfoFuture;
  final Future<bool> Function(Uri) urlLauncher;
  final bool debugLogging;

  const AboutDialogWidget({
    super.key,
    this.packageInfoFuture,
    this.urlLauncher = launchUrl,
    this.debugLogging = true,
  });

  Future<void> _launchUrl(String url) async {
    try {
      if (!await urlLauncher(Uri.parse(url))) {
        if (debugLogging) {
          _logger.w('Could not launch $url');
        }
      }
    } catch (e) {
      if (debugLogging) {
        _logger.e('Error launching URL', e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: packageInfoFuture ?? PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Dismiss the dialog when there's an error
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          });
          return const SizedBox.shrink();
        }

        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final packageInfo = snapshot.data!;

        return AlertDialog(
          title: const Text('About Soundboard'),
          content: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Image.asset(
                    'assets/icon/fbtools.eu.png',
                    height: 100,
                    width: 100,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Version: ${packageInfo.version}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const Gap(8),
                      const Text(
                        'A soundboard application designed for sports events, '
                        'specifically targeting Innebandy (Floorball) in Stockholm, Sweden.',
                      ),
                      const Gap(16),
                      TextButton(
                        onPressed: () => _launchUrl('https://fbtools.eu'),
                        child: const Text('Visit fbtools.eu'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

// Contains AI-generated edits.
