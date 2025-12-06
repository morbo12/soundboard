import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_settings_api_key.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_api_usage.dart';
import 'package:soundboard/features/screen_settings/presentation/widgets/widget_device_id_display.dart';

/// Overview widget for API and Premium Features section.
///
/// This widget serves as a hub for all API-backed premium features,
/// showing API configuration status, usage statistics, and links to
/// features that require the API product key.
class ApiFeaturesSectionWidget extends ConsumerWidget {
  final SettingsBox _settings = SettingsBox();

  ApiFeaturesSectionWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasApiKey = _settings.apiProductKey.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!hasApiKey) ...[_ApiKeyRequiredBanner(), const Gap(20)],
        _ApiConfigurationSection(),
        const Gap(20),
        if (hasApiKey) ...[
          _DeviceRegistrationSection(),
          const Gap(20),
          _ApiUsageSection(),
          const Gap(20),
          _PremiumFeaturesOverview(),
        ],
      ],
    );
  }
}

class _ApiKeyRequiredBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.secondaryContainer,
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 32,
            color: Theme.of(context).colorScheme.primary,
          ),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'API Product Key Required',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
                const Gap(4),
                Text(
                  'Configure your API product key below to unlock premium features like AI-powered announcements and advanced TTS capabilities.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiConfigurationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const SettingsApiProductKey();
  }
}

class _ApiUsageSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ApiUsageWidget();
  }
}

class _DeviceRegistrationSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const DeviceIdDisplayWidget();
  }
}

class _PremiumFeaturesOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      _FeatureCard(
        icon: Icons.psychology_outlined,
        title: 'AI-Powered Announcements',
        description:
            'Generate professional sports announcements using advanced AI models',
        location: 'Text to Speech → AI Model',
        color: Colors.purple,
        onTap: () {
          // Could navigate to TTS section in future
        },
      ),
      _FeatureCard(
        icon: Icons.cloud_outlined,
        title: 'Cloud TTS Service',
        description:
            'High-quality text-to-speech synthesis powered by our API backend',
        location: 'Text to Speech → TTS Settings',
        color: Colors.blue,
        onTap: () {
          // Could navigate to TTS section in future
        },
      ),
      _FeatureCard(
        icon: Icons.upcoming_outlined,
        title: 'Future Premium Features',
        description: 'More API-powered features coming soon',
        location: 'Stay tuned!',
        color: Colors.grey,
        isComingSoon: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Available Premium Features',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const Gap(12),
        ...features.map(
          (feature) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: feature,
          ),
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String location;
  final Color color;
  final VoidCallback? onTap;
  final bool isComingSoon;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.location,
    required this.color,
    this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isComingSoon
              ? Theme.of(context).colorScheme.outlineVariant
              : color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: isComingSoon ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isComingSoon
                      ? Theme.of(context).colorScheme.surfaceContainerHigh
                      : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: isComingSoon
                      ? Theme.of(context).colorScheme.onSurfaceVariant
                      : color,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (isComingSoon) ...[
                          const Gap(8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'COMING SOON',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const Gap(4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(6),
                    Row(
                      children: [
                        Icon(
                          Icons.place_outlined,
                          size: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const Gap(4),
                        Text(
                          location,
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isComingSoon)
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
