import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soundboard/properties.dart';

class SettingsTtsServiceKey extends StatefulWidget {
  const SettingsTtsServiceKey({
    super.key,
  });

  @override
  State<SettingsTtsServiceKey> createState() => _SettingsTtsServiceKeyState();
}

class _SettingsTtsServiceKeyState extends State<SettingsTtsServiceKey> {
  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    final ctrlTtsKey = TextEditingController();
    ctrlTtsKey.text = SettingsBox().azTtsKey;

    if (kDebugMode) {
      print(SettingsBox().azTtsKey);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: TextField(
            // textAlign: TextAlign.center,
            controller: ctrlTtsKey,
            decoration: const InputDecoration(
              enabledBorder: OutlineInputBorder(),
              border: OutlineInputBorder(),
              labelText: "Azure Speech Service Key ",
              floatingLabelBehavior: FloatingLabelBehavior.auto,
            ),
            onChanged: (text) {
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 2000), () {
                SettingsBox().azTtsKey = text;
                ScaffoldMessenger.of(context).showMaterialBanner(MaterialBanner(
                  content: const Text(
                      "Omstart av applikationen krävs för att ändringarna ska slå igenom."),
                  elevation: 5,
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .hideCurrentMaterialBanner();
                      },
                      child: const Text("OK"),
                    ),
                  ],
                ));
              });
            },
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
