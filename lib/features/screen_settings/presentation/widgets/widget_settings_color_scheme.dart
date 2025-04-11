import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/constants/class_approved_color_schemes.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/properties.dart';

class MyColorScheme extends ConsumerStatefulWidget {
  const MyColorScheme({super.key});

  @override
  ConsumerState<MyColorScheme> createState() => _MyColorSchemeState();
}

class _MyColorSchemeState extends ConsumerState<MyColorScheme> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = SettingsBox().myColorTheme;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: () {
        _showThemeDialog(context, ref);
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color Theme: $currentTheme',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(4),
              Text(
                'Tap to change theme',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).colorScheme.onPrimaryContainer.withValues(alpha: 204),
                ),
              ),
            ],
          ),
          Icon(
            Icons.palette,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeList = AppThemes.getThemeNamesList();
    final selectedTheme = SettingsBox().myColorTheme;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Color Theme'),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (themeList.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                color: Colors.red,
                                size: 30,
                              ),
                              Gap(8),
                              Text('No themes available'),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 16),
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: themeList.length,
                          itemBuilder: (context, index) {
                            final theme = themeList[index];
                            final isSelected = theme == selectedTheme;

                            return ListTile(
                              title: Text(theme),
                              selected: isSelected,
                              selectedTileColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              leading: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                    width: 1,
                                  ),
                                ),
                              ),
                              onTap: () {
                                ref
                                    .read(colorThemeProvider.notifier)
                                    .state = AppThemes.getSchemeFromName(theme);
                                SettingsBox().myColorTheme = theme;
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
