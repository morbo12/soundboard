import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/providers/sponsor_kiosk_providers.dart';
import 'package:soundboard/core/utils/app_localizations.dart';
import 'package:gap/gap.dart';

/// Widget for managing sponsor and kiosk settings
class SponsorKioskSettings extends ConsumerStatefulWidget {
  const SponsorKioskSettings({super.key});

  @override
  ConsumerState<SponsorKioskSettings> createState() =>
      _SponsorKioskSettingsState();
}

class _SponsorKioskSettingsState extends ConsumerState<SponsorKioskSettings> {
  final TextEditingController _mainSponsorController = TextEditingController();
  final TextEditingController _otherSponsorsController =
      TextEditingController();
  final TextEditingController _kioskMessageController = TextEditingController();
  final SettingsBox _settingsBox = SettingsBox();
  
  bool _mainSponsorHasChanges = false;
  bool _otherSponsorsHaveChanges = false;
  bool _kioskMessageHasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    
    // Listen for changes
    _mainSponsorController.addListener(() {
      setState(() {
        _mainSponsorHasChanges = 
            _mainSponsorController.text.trim() != _settingsBox.mainSponsor;
      });
    });
    
    _otherSponsorsController.addListener(() {
      setState(() {
        _otherSponsorsHaveChanges = 
            _otherSponsorsController.text.trim() != _settingsBox.otherSponsors.join('\n');
      });
    });
    
    _kioskMessageController.addListener(() {
      setState(() {
        _kioskMessageHasChanges = 
            _kioskMessageController.text.trim() != _settingsBox.kioskMessage;
      });
    });
  }

  void _loadSettings() {
    _mainSponsorController.text = _settingsBox.mainSponsor;
    _otherSponsorsController.text = _settingsBox.otherSponsors.join('\n');
    _kioskMessageController.text = _settingsBox.kioskMessage;
  }

  @override
  void dispose() {
    _mainSponsorController.dispose();
    _otherSponsorsController.dispose();
    _kioskMessageController.dispose();
    super.dispose();
  }

  void _saveMainSponsor() {
    _settingsBox.mainSponsor = _mainSponsorController.text.trim();
    ref.read(mainSponsorProvider.notifier).state =
        _mainSponsorController.text.trim();
    
    setState(() {
      _mainSponsorHasChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.translate('common.save')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveOtherSponsors() {
    // Split by newlines and filter out empty lines
    final sponsors = _otherSponsorsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    _settingsBox.otherSponsors = sponsors;
    ref.read(otherSponsorsProvider.notifier).state = sponsors;

    setState(() {
      _otherSponsorsHaveChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.translate('common.save')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveKioskMessage() {
    _settingsBox.kioskMessage = _kioskMessageController.text.trim();
    ref.read(kioskMessageProvider.notifier).state =
        _kioskMessageController.text.trim();
    
    setState(() {
      _kioskMessageHasChanges = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(l10n.translate('common.save')),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  AppLocalizations get l10n => context.l10n;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    final sponsorEnabled = ref.watch(sponsorEnabledProvider);
    final kioskEnabled = ref.watch(kioskEnabledProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unsaved changes warning
          if (_mainSponsorHasChanges || _otherSponsorsHaveChanges || _kioskMessageHasChanges)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange, width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                  const Gap(12),
                  Expanded(
                    child: Text(
                      'You have unsaved changes! Click the SAVE buttons to apply your changes.',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Enable Sponsors Toggle
          SwitchListTile(
            title: Text(l10n.translate('sponsor_kiosk.enable_sponsor_section')),
            value: sponsorEnabled,
            onChanged: (value) {
              _settingsBox.sponsorEnabled = value;
              ref.read(sponsorEnabledProvider.notifier).state = value;
            },
            secondary: Icon(
              Icons.business,
              color: colorScheme.primary,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          if (sponsorEnabled) ...[
            const Gap(16),
            const Divider(),
            const Gap(16),

            // Main Sponsor Input
            Text(
              l10n.translate('sponsor_kiosk.main_sponsor_label'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _mainSponsorController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l10n.translate('sponsor_kiosk.main_sponsor_hint'),
                    ),
                  ),
                ),
                const Gap(12),
                ElevatedButton.icon(
                  onPressed: _saveMainSponsor,
                  icon: Icon(_mainSponsorHasChanges ? Icons.save : Icons.check),
                  label: Text(
                    _mainSponsorHasChanges 
                        ? l10n.translate('common.save')
                        : 'Saved',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainSponsorHasChanges 
                        ? colorScheme.primary 
                        : Colors.green,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(24),

            // Other Sponsors Input
            Text(
              l10n.translate('sponsor_kiosk.other_sponsors_label'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              l10n.translate('sponsor_kiosk.other_sponsors_description'),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _otherSponsorsController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l10n.translate('sponsor_kiosk.other_sponsors_hint'),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                  ),
                ),
                const Gap(12),
                ElevatedButton.icon(
                  onPressed: _saveOtherSponsors,
                  icon: Icon(_otherSponsorsHaveChanges ? Icons.save : Icons.check),
                  label: Text(
                    _otherSponsorsHaveChanges 
                        ? l10n.translate('common.save')
                        : 'Saved',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _otherSponsorsHaveChanges 
                        ? colorScheme.primary 
                        : Colors.green,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(16),
            const Divider(),
          ],

          const Gap(16),

          // Enable Kiosk Toggle
          SwitchListTile(
            title: Text(l10n.translate('sponsor_kiosk.enable_kiosk')),
            subtitle: Text(l10n.translate('sponsor_kiosk.kiosk_description')),
            value: kioskEnabled,
            onChanged: (value) {
              _settingsBox.kioskEnabled = value;
              ref.read(kioskEnabledProvider.notifier).state = value;
            },
            secondary: Icon(
              Icons.store,
              color: colorScheme.primary,
            ),
            contentPadding: EdgeInsets.zero,
          ),

          // Kiosk Message Input (only show when kiosk is enabled)
          if (kioskEnabled) ...[
            const Gap(16),
            Text(
              l10n.translate('sponsor_kiosk.kiosk_message_label'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const Gap(4),
            Text(
              l10n.translate('sponsor_kiosk.kiosk_message_description'),
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _kioskMessageController,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: l10n.translate('sponsor_kiosk.kiosk_message_hint'),
                    ),
                    maxLines: 2,
                  ),
                ),
                const Gap(12),
                ElevatedButton.icon(
                  onPressed: _saveKioskMessage,
                  icon: Icon(_kioskMessageHasChanges ? Icons.save : Icons.check),
                  label: Text(
                    _kioskMessageHasChanges 
                        ? l10n.translate('common.save')
                        : 'Saved',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kioskMessageHasChanges 
                        ? colorScheme.primary 
                        : Colors.green,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const Gap(16),

          // Preview Section
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const Gap(8),
                    Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                const Gap(8),
                Text(
                  _buildPreviewText(),
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildPreviewText() {
    final sponsorEnabled = ref.watch(sponsorEnabledProvider);
    final kioskEnabled = ref.watch(kioskEnabledProvider);
    final mainSponsor = _mainSponsorController.text.trim();
    final otherSponsors = _otherSponsorsController.text
        .split('\n')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    String preview = 'Välkomna till [venue]!\n\n';

    if (sponsorEnabled && mainSponsor.isNotEmpty) {
      preview +=
          'IFK Haninge, tillsammans med vår huvudsponsor $mainSponsor, hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan IFK Haninge och [motståndare].\n\n';
    } else {
      preview +=
          'IFK Haninge hälsar motståndarna, domarna och publiken hjärtligt välkomna till dagens match mellan IFK Haninge och [motståndare].\n\n';
    }

    if (sponsorEnabled && otherSponsors.isNotEmpty) {
      String sponsorText;
      if (otherSponsors.length == 1) {
        sponsorText = otherSponsors[0];
      } else if (otherSponsors.length == 2) {
        sponsorText = '${otherSponsors[0]} och ${otherSponsors[1]}';
      } else {
        final lastSponsor = otherSponsors.last;
        final allButLast = otherSponsors.sublist(0, otherSponsors.length - 1);
        sponsorText = '${allButLast.join(', ')}, och $lastSponsor';
      }
      preview +=
          'Vi vill också tacka $sponsorText för att stödja föreningen.\n\n';
    }

    if (kioskEnabled) {
      final kioskMessage = _kioskMessageController.text.trim();
      preview += kioskMessage.isNotEmpty 
          ? '$kioskMessage\n'
          : 'Kiosken är öppen, välkommen att besöka oss under pausen!\n';
    }

    return preview;
  }
}
