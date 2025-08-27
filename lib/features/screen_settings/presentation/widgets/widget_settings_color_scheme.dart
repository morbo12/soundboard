import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/theme/class_approved_color_schemes.dart';
import 'package:soundboard/core/utils/providers.dart';
import 'package:soundboard/core/properties.dart';

class MyColorScheme extends ConsumerStatefulWidget {
  const MyColorScheme({super.key});

  @override
  ConsumerState<MyColorScheme> createState() => _MyColorSchemeState();
}

class _MyColorSchemeState extends ConsumerState<MyColorScheme> {
  @override
  Widget build(BuildContext context) {
    final currentTheme = SettingsBox().myColorTheme;

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade100, Colors.purple.shade50],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showThemeDialog(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.palette,
                    color: Colors.purple.shade700,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Color Theme: $currentTheme',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'THEME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to change theme - personalize your interface',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.purple.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.settings, color: Colors.purple.shade700, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final themeList = AppThemes.getThemeNamesList();
    final selectedTheme = SettingsBox().myColorTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                          const SizedBox(height: 8),
                          const Text('No themes available'),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
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
                          selectedTileColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          leading: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primaryContainer,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 1,
                              ),
                            ),
                          ),
                          onTap: () {
                            ref.read(colorThemeProvider.notifier).state =
                                AppThemes.getSchemeFromName(theme);
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
