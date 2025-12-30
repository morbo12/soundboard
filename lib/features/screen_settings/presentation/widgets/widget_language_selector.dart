import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/common/widgets/flag_icon.dart';
import 'package:soundboard/core/providers/locale_provider.dart';
import 'package:soundboard/core/utils/app_localizations.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  Widget _buildLanguageLabel(String languageCode, String label) {
    return Row(
      children: [
        FlagIcon(languageCode: languageCode),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('settings.items.language.title'),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: currentLocale.languageCode,
              isExpanded: true,
              items: [
                DropdownMenuItem(
                  value: 'en',
                  child: _buildLanguageLabel(
                    'en',
                    l10n.translate('languages.english'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'sv',
                  child: _buildLanguageLabel(
                    'sv',
                    l10n.translate('languages.swedish'),
                  ),
                ),
                DropdownMenuItem(
                  value: 'cs',
                  child: _buildLanguageLabel(
                    'cs',
                    l10n.translate('languages.czech'),
                  ),
                ),
              ],
              onChanged: (newValue) {
                if (newValue == null) {
                  return;
                }
                ref.read(localeProvider.notifier).setLocale(Locale(newValue));
              },
            ),
          ],
        ),
      ),
    );
  }
}
