import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/providers/profile_providers.dart';
import 'package:soundboard/core/services/profile_service.dart';
import 'package:soundboard/core/services/profile_switch_controller.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/app.dart';

const Logger _logger = Logger('ProfileSelectionScreen');

/// Profile selection screen shown on startup when no active profile is set
/// or when user wants to switch profiles
class ProfileSelectionScreen extends ConsumerStatefulWidget {
  /// Whether this screen is shown as an overlay (for quick switch)
  /// or as the main screen (on startup)
  final bool isOverlay;

  const ProfileSelectionScreen({
    super.key,
    this.isOverlay = false,
  });

  @override
  ConsumerState<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends ConsumerState<ProfileSelectionScreen> {
  String? _selectedProfileId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profileListProvider);
    final currentProfile = ref.watch(currentProfileProvider);
    final l10n = context.l10n;

    // Auto-select current profile if available
    _selectedProfileId ??= currentProfile?.id ?? (profiles.isNotEmpty ? profiles.first.id : null);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              _buildHeader(l10n),
              const SizedBox(height: 48),

              // Profile list
              Expanded(
                child: profiles.isEmpty
                    ? _buildNoProfilesMessage(l10n)
                    : _buildProfileGrid(profiles, currentProfile),
              ),

              const SizedBox(height: 24),

              // Actions
              _buildActions(l10n, profiles.isEmpty),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        Icon(
          FluentIcons.people_team_24_filled,
          size: 64,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 16),
        Text(
          widget.isOverlay
              ? l10n.translate('profiles.switch_profile')
              : l10n.translate('profiles.select_profile'),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.isOverlay
              ? l10n.translate('profiles.switch_description')
              : l10n.translate('profiles.startup_description'),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onBackground.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNoProfilesMessage(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            FluentIcons.folder_open_24_regular,
            size: 48,
            color: Theme.of(context).colorScheme.onBackground.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('profiles.no_profiles'),
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.translate('profiles.create_first_profile'),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onBackground.withOpacity(0.6),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileGrid(List<TeamProfile> profiles, TeamProfile? currentProfile) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 300,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final isSelected = _selectedProfileId == profile.id;
        final isCurrent = currentProfile?.id == profile.id;

        return _buildProfileCard(profile, isSelected, isCurrent);
      },
    );
  }

  Widget _buildProfileCard(TeamProfile profile, bool isSelected, bool isCurrent) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surface,
      child: InkWell(
        onTap: () => setState(() => _selectedProfileId = profile.id),
        onDoubleTap: () => _selectProfile(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and current badge
              Row(
                children: [
                  Icon(
                    FluentIcons.people_team_24_filled,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onPrimaryContainer
                        : Theme.of(context).colorScheme.primary,
                  ),
                  const Spacer(),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Profile name
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : null,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Description
              if (profile.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  profile.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: (isSelected
                                ? Theme.of(context).colorScheme.onPrimaryContainer
                                : Theme.of(context).colorScheme.onSurface)
                            .withOpacity(0.7),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const Spacer(),

              // Last used
              Text(
                'Last used: ${_formatDate(profile.lastUsed)}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: (isSelected
                              ? Theme.of(context).colorScheme.onPrimaryContainer
                              : Theme.of(context).colorScheme.onSurface)
                          .withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(AppLocalizations l10n, bool noProfiles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Create new profile button
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _createNewProfile,
          icon: const Icon(FluentIcons.add_24_regular),
          label: Text(l10n.translate('profiles.create_new')),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        ),

        if (!noProfiles) ...[
          const SizedBox(width: 16),

          // Continue/Select button
          FilledButton.icon(
            onPressed: _isLoading || _selectedProfileId == null ? null : _selectProfile,
            icon: _isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(FluentIcons.checkmark_24_regular),
            label: Text(
              widget.isOverlay
                  ? l10n.translate('profiles.switch')
                  : l10n.translate('profiles.continue'),
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],

        if (widget.isOverlay) ...[
          const SizedBox(width: 16),
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: Text(l10n.translate('common.cancel')),
          ),
        ],
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectProfile() async {
    if (_selectedProfileId == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Use ProfileSwitchController to perform the switch
      final profileService = ref.read(profileServiceProvider);
      final switchController = ProfileSwitchController(
        ref: ref,
        profileService: profileService,
      );

      final success = await switchController.switchToProfile(_selectedProfileId!);

      if (!success) {
        throw Exception('Profile switch failed');
      }

      _logger.d('Profile selected: $_selectedProfileId');

      if (mounted) {
        if (widget.isOverlay) {
          // Close the overlay
          Navigator.of(context).pop();
        } else {
          // Navigate to main app
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const Player()),
          );
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Error selecting profile', e, stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

    setState(() => _isLoading = true);

    try {
      final profileListNotifier = ref.read(profileListProvider.notifier);
      final newProfile = await profileListNotifier.createProfile(
        name: name.trim(),
        description: '',
      );

      // Automatically select the newly created profile
      setState(() => _selectedProfileId = newProfile.id);

      _logger.d('Profile created: ${newProfile.id}');
    } catch (e, stackTrace) {
      _logger.e('Error creating profile', e, stackTrace);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating profile: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String?> _showProfileNameDialog(BuildContext context, String title, String hint) async {
    final controller = TextEditingController();

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
            child: Text(context.l10n.translate('common.create')),
          ),
        ],
      ),
    );
  }
}
