import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:intl/intl.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/providers/profile_providers.dart';
import 'package:soundboard/core/services/profile_switch_controller.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:soundboard/core/utils/logger.dart';

/// Quick profile switch dialog - compact version for keyboard shortcut
class ProfileQuickSwitchDialog extends ConsumerStatefulWidget {
  const ProfileQuickSwitchDialog({super.key});

  @override
  ConsumerState<ProfileQuickSwitchDialog> createState() =>
      _ProfileQuickSwitchDialogState();
}

class _ProfileQuickSwitchDialogState
    extends ConsumerState<ProfileQuickSwitchDialog> {
  static const _logger = Logger('ProfileQuickSwitchDialog');
  bool _isSwitching = false;

  Future<void> _switchToProfile(TeamProfile profile) async {
    if (_isSwitching) return;

    setState(() {
      _isSwitching = true;
    });

    try {
      final switchController = ProfileSwitchController(
        ref: ref,
        profileService: ref.read(profileServiceProvider),
      );

      await switchController.switchToProfile(profile.id);

      if (mounted) {
        Navigator.of(context).pop(); // Close dialog
      }
    } catch (e) {
      _logger.e('Failed to switch profile', e);
      if (mounted) {
        final l10n = context.l10n;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.translate('profiles.error_switching')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSwitching = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profiles = ref.watch(profileListProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 500,
          maxHeight: 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.people_swap_24_filled,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    l10n.translate('profiles.quick_switch'),
                    style: theme.textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(FluentIcons.dismiss_24_regular),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: l10n.translate('common.close'),
                  ),
                ],
              ),
            ),

            // Profile list
            Flexible(
              child: profiles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.translate('profiles.no_profiles'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(8),
                      itemCount: profiles.length,
                      itemBuilder: (context, index) {
                        final profile = profiles[index];
                        final isActive = currentProfile?.id == profile.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          elevation: isActive ? 4 : 1,
                          color: isActive
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surface,
                          child: InkWell(
                            onTap: _isSwitching || isActive
                                ? null
                                : () => _switchToProfile(profile),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Profile icon
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? theme.colorScheme.primary
                                          : theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      FluentIcons.person_24_filled,
                                      color: isActive
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onPrimaryContainer,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Profile info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                profile.name,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: isActive
                                                      ? FontWeight.bold
                                                      : FontWeight.w500,
                                                  color: isActive
                                                      ? theme.colorScheme.onPrimaryContainer
                                                      : theme.colorScheme.onSurface,
                                                ),
                                              ),
                                            ),
                                            if (isActive)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  l10n.translate('profiles.active').toUpperCase(),
                                                  style: theme.textTheme.labelSmall?.copyWith(
                                                    color: theme.colorScheme.onPrimary,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        if (profile.description.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            profile.description,
                                            style: theme.textTheme.bodySmall?.copyWith(
                                              color: isActive
                                                  ? theme.colorScheme.onPrimaryContainer
                                                      .withValues(alpha: 0.8)
                                                  : theme.colorScheme.onSurface
                                                      .withValues(alpha: 0.6),
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                        const SizedBox(height: 4),
                                        Text(
                                          _formatLastUsed(profile.lastUsed, l10n),
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: isActive
                                                ? theme.colorScheme.onPrimaryContainer
                                                    .withValues(alpha: 0.7)
                                                : theme.colorScheme.onSurface
                                                    .withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Loading indicator or arrow
                                  if (_isSwitching && !isActive)
                                    const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  else if (!isActive)
                                    Icon(
                                      FluentIcons.chevron_right_24_regular,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.4),
                                      size: 20,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Footer with keyboard hint
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    FluentIcons.keyboard_24_regular,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n.translate('profiles.quick_switch_hint'),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatLastUsed(DateTime lastUsed, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(lastUsed);

    if (difference.inMinutes < 1) {
      return l10n.translate('profiles.last_used_just_now');
    } else if (difference.inMinutes < 60) {
      return l10n.translate('profiles.last_used_minutes')
          .replaceAll('{minutes}', '${difference.inMinutes}');
    } else if (difference.inHours < 24) {
      return l10n.translate('profiles.last_used_hours')
          .replaceAll('{hours}', '${difference.inHours}');
    } else if (difference.inDays < 7) {
      return l10n.translate('profiles.last_used_days')
          .replaceAll('{days}', '${difference.inDays}');
    } else {
      return l10n.translate('profiles.last_used_on')
          .replaceAll('{date}', DateFormat.yMd().format(lastUsed));
    }
  }
}
