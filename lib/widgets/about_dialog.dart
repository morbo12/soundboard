import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:gap/gap.dart';

class AboutDialogWidget extends StatelessWidget {
  const AboutDialogWidget({super.key});

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
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
