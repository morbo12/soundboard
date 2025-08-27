import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
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

    return Card(
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade100,
              Colors.green.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () => _showSpotifyDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withAlpha(100),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.music_note,
                    color: Colors.green.shade700,
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
                            'Spotify Playlist',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: hasUrl ? Colors.green : Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hasUrl ? 'CONFIGURED' : 'SETUP',
                              style: const TextStyle(
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
                        hasUrl ? url : 'Not configured',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.settings,
                  color: Colors.green.shade700,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
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
