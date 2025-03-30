import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/properties.dart';
import 'package:soundboard/utils/logger.dart';

class SettingsSpotify extends StatefulWidget {
  const SettingsSpotify({
    super.key,
  });

  @override
  State<SettingsSpotify> createState() => _SettingsSpotifyState();
}

class _SettingsSpotifyState extends State<SettingsSpotify> {
  Timer? _debounce;
  final ctrlSpotifyUrl = TextEditingController();
  final ctrlSpotifyUri = TextEditingController();
  final Logger logger = const Logger('SettingsSpotify');

  @override
  void dispose() {
    _debounce?.cancel();
    ctrlSpotifyUrl.dispose(); // Dispose the TextEditingController
    ctrlSpotifyUri.dispose(); // Dispose the TextEditingController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ctrlSpotifyUrl.text = SettingsBox().spotifyUrl;
    ctrlSpotifyUri.text = SettingsBox().spotifyUri;

    logger.d("SpotifyURL: ${SettingsBox().spotifyUrl}");

    return Row(
      children: [
        Column(
          children: [
            const Gap(20),
            SizedBox(
              width: ScreenSizeUtil.getWidth(context),
              child: Center(
                child: TextField(
                  // textAlign: TextAlign.center,
                  controller: ctrlSpotifyUrl,
                  decoration: const InputDecoration(
                    enabledBorder: OutlineInputBorder(),
                    border: OutlineInputBorder(),
                    labelText: "Spotify Playlist URL",
                    floatingLabelBehavior: FloatingLabelBehavior.auto,
                  ),
                  onChanged: (text) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 2000), () {
                      if (RegExp(
                              r'^https:\/\/open.spotify.com\/playlist\/[a-zA-Z0-9]+')
                          .hasMatch(text)) {
                        final uriParts = text.split('/');
                        SettingsBox().spotifyUrl = text;
                        if (uriParts.length > 4) {
                          final playlistId = uriParts[4].split('?')[0];
                          SettingsBox().spotifyUri =
                              "spotify:playlist:$playlistId:play";
                          // Show toast message for successful URL update
                          FlutterToastr.show("Spotify URL updated", context,
                              duration: FlutterToastr.lengthLong,
                              position: FlutterToastr.bottom,
                              backgroundColor: Colors.green,
                              textStyle: const TextStyle(color: Colors.white));
                        } else {
                          // URL doesn't match expected structure
                          FlutterToastr.show(
                              "Invalid Spotify playlist URL", context,
                              duration: FlutterToastr.lengthLong,
                              position: FlutterToastr.bottom,
                              backgroundColor: Colors.red,
                              textStyle: const TextStyle(color: Colors.white));
                        }
                      } else {
                        // URL doesn't match the Spotify playlist pattern
                        FlutterToastr.show(
                            "Invalid Spotify playlist URL", context,
                            duration: FlutterToastr.lengthLong,
                            position: FlutterToastr.bottom,
                            backgroundColor: Colors.red,
                            textStyle: const TextStyle(color: Colors.white));
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
