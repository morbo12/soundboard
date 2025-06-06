import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:gap/gap.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/core/utils/logger.dart';

class SettingsSpotify extends StatefulWidget {
  const SettingsSpotify({super.key});

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
    ctrlSpotifyUrl.dispose();
    ctrlSpotifyUri.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasUrl = SettingsBox().spotifyUrl.isNotEmpty;
    final url = SettingsBox().spotifyUrl;

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      onPressed: () {
        _showSpotifyDialog(context);
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spotify Playlist',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
              const Gap(4),
              Text(
                hasUrl ? url : 'Not configured',
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
            Icons.music_note,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ],
      ),
    );
  }

  void _showSpotifyDialog(BuildContext context) {
    ctrlSpotifyUrl.text = SettingsBox().spotifyUrl;
    ctrlSpotifyUri.text = SettingsBox().spotifyUri;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Spotify Playlist Settings'),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
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
                      r'^https:\/\/open.spotify.com\/playlist\/[a-zA-Z0-9]+',
                    ).hasMatch(text)) {
                      final uriParts = text.split('/');
                      SettingsBox().spotifyUrl = text;
                      if (uriParts.length > 4) {
                        final playlistId = uriParts[4].split('?')[0];
                        SettingsBox().spotifyUri =
                            "spotify:playlist:$playlistId:play";
                        FlutterToastr.show(
                          "Spotify URL updated",
                          context,
                          duration: FlutterToastr.lengthLong,
                          position: FlutterToastr.bottom,
                          backgroundColor: Colors.green,
                          textStyle: const TextStyle(color: Colors.white),
                        );
                      } else {
                        FlutterToastr.show(
                          "Invalid Spotify playlist URL",
                          context,
                          duration: FlutterToastr.lengthLong,
                          position: FlutterToastr.bottom,
                          backgroundColor: Colors.red,
                          textStyle: const TextStyle(color: Colors.white),
                        );
                      }
                    } else {
                      FlutterToastr.show(
                        "Invalid Spotify playlist URL",
                        context,
                        duration: FlutterToastr.lengthLong,
                        position: FlutterToastr.bottom,
                        backgroundColor: Colors.red,
                        textStyle: const TextStyle(color: Colors.white),
                      );
                    }
                  });
                },
              ),
            ],
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
