import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/constants/class_approved_color_schemes.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/properties.dart';

class MyColorScheme extends ConsumerStatefulWidget {
  const MyColorScheme({
    super.key,
  });

  @override
  ConsumerState<MyColorScheme> createState() => _MyColorSchemeState();
}

class _MyColorSchemeState extends ConsumerState<MyColorScheme> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
              onPressed: () => _showThemePicker(context, ref),
              child: AutoSizeText(
                SettingsBox().myColorTheme,
                textAlign: TextAlign.center,
              )),
        ),
      ],
    );
  }

  void _showThemePicker(BuildContext context, WidgetRef ref) {
    final themeList = AppThemes.getThemeNamesList();
    final selectedTheme = SettingsBox().myColorTheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Välj färgschema",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: themeList.length,
                itemBuilder: (context, index) {
                  final theme = themeList[index];
                  final isSelected = theme == selectedTheme;

                  // Get the actual color scheme to show a preview
                  final themeScheme = AppThemes.getSchemeFromName(theme);

                  return ListTile(
                    title: Text(theme),
                    selected: isSelected,
                    selectedTileColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    // Add a color preview circle
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    onTap: () {
                      // Update the selected theme
                      ref.read(colorThemeProvider.notifier).state =
                          AppThemes.getSchemeFromName(theme);
                      SettingsBox().myColorTheme = theme;

                      // Close the bottom sheet
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
