import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/models/team_profile.dart';
import 'package:soundboard/core/providers/profile_providers.dart';
import 'package:soundboard/core/services/profile_service.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:intl/intl.dart';

/// Profile selection screen shown on app startup
/// Allows users to select which team profile to use
class ProfileSelectionScreen extends ConsumerStatefulWidget {
  final VoidCallback onProfileSelected;

  const ProfileSelectionScreen({
    super.key,
    required this.onProfileSelected,
  });

  @override
  ConsumerState<ProfileSelectionScreen> createState() =>
      _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState
    extends ConsumerState<ProfileSelectionScreen> {
  final ProfileService _profileService = ProfileService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profiles = _profileService.getAllProfiles();
    final activeProfile = _profileService.getActiveProfile();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1200),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and Title
                  _buildHeader(l10n),
                  const SizedBox(height: 48),

                  // Profile Grid
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildProfileGrid(profiles, activeProfile, l10n),
                  ),

                  const SizedBox(height: 24),

                  // Create New Profile Button
                  _buildCreateProfileButton(l10n),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return Column(
      children: [
        // ArenaVox Logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/ArenaVox_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          l10n.translate('profiles.select_profile_title'),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.translate('profiles.select_profile_subtitle'),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileGrid(
    List<TeamProfile> profiles,
    TeamProfile? activeProfile,
    AppLocalizations l10n,
  ) {
    if (profiles.isEmpty) {
      return Center(
        child: Text(
          l10n.translate('common.empty'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
      );
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: profiles.length > 4 ? 3 : 2,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 1.2,
      ),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        final isActive = activeProfile?.id == profile.id;
        return _buildProfileCard(profile, isActive, l10n);
      },
    );
  }

  Widget _buildProfileCard(
    TeamProfile profile,
    bool isActive,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: isActive ? 8 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 3,
              )
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectProfile(profile),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Icon/Logo
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.sports_soccer,
                      size: 32,
                      color: isActive
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Profile Name
              Text(
                profile.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Profile Description
              if (profile.description.isNotEmpty)
                Text(
                  profile.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.6),
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

              const Spacer(),

              // Last Used
              Text(
                '${l10n.translate('profiles.last_used')}: ${_formatDate(profile.lastUsed)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateProfileButton(AppLocalizations l10n) {
    return OutlinedButton.icon(
      onPressed: _createNewProfile,
      icon: const Icon(Icons.add_circle_outline, size: 24),
      label: Text(
        l10n.translate('profiles.create_new_profile'),
        style: const TextStyle(fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _selectProfile(TeamProfile profile) async {
    setState(() => _isLoading = true);

    try {
      await _profileService.setActiveProfile(profile.id);
      
      // Trigger provider refresh
      ref.read(profileChangeCounterProvider.notifier).state++;
      
      if (mounted) {
        widget.onProfileSelected();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${context.l10n.translate('common.error')}: $e'),
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
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('profiles.create_new_profile')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: l10n.translate('profiles.profile_name'),
                border: const OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l10n.translate('profiles.profile_description'),
                border: const OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.translate('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.translate('profiles.create')),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      setState(() => _isLoading = true);

      try {
        // Create profile using current settings as a template
        final newProfile = await _profileService.createProfile(
          name: nameController.text,
          description: descriptionController.text,
          copyFrom: _profileService.createProfileFromCurrentSettings(
            name: 'temp',
            description: '',
          ),
        );
        await _profileService.setActiveProfile(newProfile.id);

        // Trigger provider refresh
        ref.read(profileChangeCounterProvider.notifier).state++;

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.translate('profiles.profile_created')),
              backgroundColor: Theme.of(context).colorScheme.primary,
            ),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.translate('common.error')}: $e'),
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
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${DateFormat.Hm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat.yMd().format(date);
    }
  }
}
