import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/providers/profile_providers.dart';
import 'package:soundboard/core/services/profile_service.dart';
import 'package:soundboard/core/utils/app_localizations.dart';

/// A dropdown widget that allows switching between team profiles
/// Can be placed in app bar, settings, or anywhere else
class ProfileSwitcher extends ConsumerWidget {
  /// Whether to show the full UI with profile management buttons
  final bool showManageButton;
  
  /// Whether to show only an icon (compact mode)
  final bool compactMode;

  const ProfileSwitcher({
    super.key,
    this.showManageButton = true,
    this.compactMode = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileService = ProfileService();
    final profiles = profileService.getAllProfiles();
    final activeProfile = profileService.getActiveProfile();
    
    // Listen to profile changes
    ref.watch(profileChangeCounterProvider);

    if (profiles.isEmpty) {
      return const SizedBox.shrink();
    }

    if (compactMode) {
      return _buildCompactMode(context, ref, profiles, activeProfile);
    }

    return _buildFullMode(context, ref, profiles, activeProfile);
  }

  Widget _buildCompactMode(
    BuildContext context,
    WidgetRef ref,
    List<TeamProfile> profiles,
    TeamProfile? activeProfile,
  ) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.account_circle),
      tooltip: context.l10n.translate('profiles.switch_profile'),
      onSelected: (profileId) => _switchProfile(context, ref, profileId),
      itemBuilder: (context) => [
        ...profiles.map((profile) {
          final isActive = profile.id == activeProfile?.id;
          return PopupMenuItem<String>(
            value: profile.id,
            child: Row(
              children: [
                if (isActive)
                  const Icon(Icons.check, size: 20)
                else
                  const SizedBox(width: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    profile.name,
                    style: isActive
                        ? const TextStyle(fontWeight: FontWeight.bold)
                        : null,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        if (showManageButton) ...[
          const PopupMenuDivider(),
          PopupMenuItem<String>(
            value: '__manage__',
            child: Row(
              children: [
                const Icon(Icons.settings, size: 20),
                const SizedBox(width: 8),
                Text(context.l10n.translate('profiles.manage_profiles')),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFullMode(
    BuildContext context,
    WidgetRef ref,
    List<TeamProfile> profiles,
    TeamProfile? activeProfile,
  ) {
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, size: 24),
                const SizedBox(width: 12),
                Text(
                  l10n.translate('profiles.switch_profile'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: activeProfile?.id,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              items: profiles.map((profile) {
                return DropdownMenuItem<String>(
                  value: profile.id,
                  child: Row(
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 20,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              profile.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (profile.description.isNotEmpty)
                              Text(
                                profile.description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _switchProfile(context, ref, newValue);
                }
              },
            ),
            if (showManageButton) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _showManageDialog(context, ref),
                icon: const Icon(Icons.settings, size: 18),
                label: Text(l10n.translate('profiles.manage_profiles')),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 40),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _switchProfile(
    BuildContext context,
    WidgetRef ref,
    String profileId,
  ) async {
    if (profileId == '__manage__') {
      _showManageDialog(context, ref);
      return;
    }

    try {
      final profileService = ProfileService();
      await profileService.setActiveProfile(profileId);
      
      // Trigger provider refresh
      ref.read(profileChangeCounterProvider.notifier).state++;

      final profile = profileService.getActiveProfile();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${context.l10n.translate('profiles.profile_switched')}: ${profile?.name}',
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.translate('common.error')}: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showManageDialog(BuildContext context, WidgetRef ref) {
    // TODO: Navigate to profile management screen
    // For now, show a placeholder dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.translate('profiles.manage_profiles')),
        content: Text('Profile management screen coming soon...'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.translate('common.close')),
          ),
        ],
      ),
    );
  }
}
