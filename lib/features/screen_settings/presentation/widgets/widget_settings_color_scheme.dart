import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_material_pickers/helpers/show_scroll_picker.dart';
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
              onPressed: () => showMaterialScrollPicker<String>(
                    title: "Välj färgschema",
                    context: context,
                    items: AppThemes.getThemeNamesList(),
                    onChanged: (value) {
                      ref.read(colorThemeProvider.notifier).state =
                          AppThemes.getSchemeFromName(value);
                      SettingsBox().myColorTheme = value;
                    },
                    selectedItem: SettingsBox().myColorTheme,
                  ),
              child: AutoSizeText(
                SettingsBox().myColorTheme,
                textAlign: TextAlign.center,
              )),
        ),
      ],
    );
  }
}
