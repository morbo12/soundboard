import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/providers/profile_providers.dart';
import 'package:soundboard/core/services/profile_service.dart';
import 'package:soundboard/core/services/profile_switch_controller.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:soundboard/features/profile_selection/presentation/profile_selection_screen.dart';

class ProfileManagementWidget extends ConsumerStatefulWidget {
  const ProfileManagementWidget({super.key});

  @override
  ConsumerState<ProfileManagementWidget> createState() => _ProfileManagementWidgetState();
}

class _ProfileManagementWidgetState extends ConsumerState<ProfileManagementWidget> {
  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(currentProfileProvider);
    final profiles = ref.watch(profileListProvider);
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Profile Card
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      FluentIcons.people_team_24_filled,
                      color: colorScheme.primary,
                      size: 32,
                    ),
                    const Gap(12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.translate('profiles.current_profile'),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                          ),
                          const Gap(4),
                          Text(
                            currentProfile?.name ?? 'No profile selected',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: () => _showProfileSwitcher(context),
                      icon: const Icon(FluentIcons.arrow_swap_24_regular),
                      label: Text(l10n.translate('profiles.switch_profile')),
                    ),
                  ],
                ),
                if (currentProfile?.description.isNotEmpty ?? false) ...[
                  const Gap(12),
                  Text(
                    currentProfile!.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                  ),
                ],
                const Gap(12),
                Divider(color: colorScheme.outlineVariant),
                const Gap(12),
                Row(
                  children: [
                    _buildInfoChip(
                      icon: FluentIcons.grid_24_regular,
                      label: '${currentProfile?.gridColumns ?? 0}x${currentProfile?.gridRows ?? 0}',
                      tooltip: l10n.translate('settings.items.grid_layout.title'),
                    ),
                    const Gap(8),
                    _buildInfoChip(
                      icon: FluentIcons.music_note_2_24_regular,
                      label: '${currentProfile?.jingleAssignments.length ?? 0} jingles',
                      tooltip: l10n.translate('settings.items.jingles_manager.title'),
                    ),
                    const Gap(8),
                    _buildInfoChip(
                      icon: FluentIcons.clock_24_regular,
                      label: _formatDate(currentProfile?.lastUsed),
                      tooltip: l10n.translate('profiles.last_used'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const Gap(20),

        // Profile List
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.translate('profiles.all_profiles'),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: _createNewProfile,
              icon: const Icon(FluentIcons.add_24_regular),
              label: Text(l10n.translate('profiles.create_new')),
            ),
          ],
        ),
        const Gap(12),

        // Profile list
        ...profiles.map((profile) => _buildProfileListTile(
              profile,
              isActive: profile.id == currentProfile?.id,
              l10n: l10n,
            )),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const Gap(6),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileListTile(
    TeamProfile profile, {
    required bool isActive,
    required AppLocalizations l10n,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isActive ? colorScheme.primaryContainer.withOpacity(0.3) : null,
      child: ListTile(
        leading: Icon(
          FluentIcons.people_team_24_regular,
          color: isActive ? colorScheme.primary : null,
        ),
        title: Row(
          children: [
            Text(
              profile.name,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isActive) ...[
              const Gap(8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ACTIVE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ],
        ),
        subtitle: profile.description.isNotEmpty
            ? Text(profile.description)
            : Text('Created ${_formatDate(profile.createdAt)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isActive)
              IconButton(
                icon: const Icon(FluentIcons.arrow_swap_24_regular),
                tooltip: l10n.translate('profiles.switch'),
                onPressed: () => _switchToProfile(profile),
              ),
            IconButton(
              icon: const Icon(FluentIcons.edit_24_regular),
              tooltip: l10n.translate('profiles.edit'),
              onPressed: () => _editProfile(profile),
            ),
            IconButton(
              icon: const Icon(FluentIcons.copy_24_regular),
              tooltip: l10n.translate('profiles.duplicate'),
              onPressed: () => _duplicateProfile(profile),
            ),
            if (!isActive)
              IconButton(
                icon: const Icon(FluentIcons.delete_24_regular),
                tooltip: l10n.translate('profiles.delete_profile'),
                onPressed: () => _deleteProfile(profile),
                color: colorScheme.error,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';

    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _showProfileSwitcher(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileSelectionScreen(isOverlay: true),
        fullscreenDialog: true,
      ),
    );

    // Refresh the profile list after returning
    ref.read(profileListProvider.notifier).refresh();
    ref.read(currentProfileProvider.notifier).refresh();
  }

  Future<void> _switchToProfile(TeamProfile profile) async {
    final l10n = context.l10n;

    // Show loading indicator
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text('Switching to ${profile.name}...'),
            ],
          ),
          duration: const Duration(seconds: 10),
        ),
      );
    }

    try {
      // Use ProfileSwitchController to perform the switch
      final profileService = ref.read(profileServiceProvider);
      final switchController = ProfileSwitchController(
        ref: ref,
        profileService: profileService,
      );

      final success = await switchController.switchToProfile(profile.id);

      if (mounted) {
        // Clear loading snackbar
        ScaffoldMessenger.of(context).clearSnackBars();

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.translate('profiles.profile_switched')}: ${profile.name}'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to switch profile'),
              backgroundColor: Theme.of(context).colorScheme.error,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error switching profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _createNewProfile() async {
    final l10n = context.l10n;
    final name = await _showProfileNameDialog(
      context,
      l10n.translate('profiles.create_new'),
      l10n.translate('profiles.enter_name'),
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      final profileListNotifier = ref.read(profileListProvider.notifier);
      await profileListNotifier.createProfile(
        name: name.trim(),
        description: '',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('profiles.profile_created')),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _editProfile(TeamProfile profile) async {
    final l10n = context.l10n;
    final name = await _showProfileNameDialog(
      context,
      l10n.translate('profiles.edit'),
      l10n.translate('profiles.enter_name'),
      initialValue: profile.name,
    );

    if (name == null || name.trim().isEmpty || name == profile.name) return;

    try {
      final updatedProfile = profile.copyWith(name: name.trim());
      final profileListNotifier = ref.read(profileListProvider.notifier);
      await profileListNotifier.updateProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('profiles.profile_updated')),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _duplicateProfile(TeamProfile profile) async {
    final l10n = context.l10n;
    final name = await _showProfileNameDialog(
      context,
      l10n.translate('profiles.duplicate'),
      l10n.translate('profiles.enter_name'),
      initialValue: '${profile.name} (Copy)',
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      final profileListNotifier = ref.read(profileListProvider.notifier);
      await profileListNotifier.createProfile(
        name: name.trim(),
        description: profile.description,
        copyFrom: profile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.translate('profiles.profile_created')),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteProfile(TeamProfile profile) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('profiles.confirm_delete_title')),
        content: Text(l10n.translate('profiles.confirm_delete_body')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.translate('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.translate('common.delete')),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final profileListNotifier = ref.read(profileListProvider.notifier);
      final success = await profileListNotifier.deleteProfile(profile.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('profiles.profile_deleted')),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('profiles.cannot_delete_active')),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<String?> _showProfileNameDialog(
    BuildContext context,
    String title,
    String hint, {
    String? initialValue,
  }) async {
    final controller = TextEditingController(text: initialValue);

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.of(context).pop(value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.translate('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(context.l10n.translate('common.save')),
          ),
        ],
      ),
    );
  }
}
