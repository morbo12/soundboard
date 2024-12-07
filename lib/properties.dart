import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:easy_hive/easy_hive.dart';

enum Settings {
  key, // Use as box key. You can use a String constant instead.

  themeMode,
  spotifyUri,
  spotifyUrl,
  c1InitialVolume,
  c2InitialVolume,
  venueId,
  federationId,
  azVoiceId,
  azRegionId,
  azTtsKey,
  azCharCount,
  azCharCountLastDate,
  backgroundVolumeLevel,
  ttsVolume,
  mainVolume,
  myColorTheme
}

class SettingsBox extends EasyBox {
  @override
  String get boxKey => Settings.key.toString();

  /// Singleton.
  static final SettingsBox _instance = SettingsBox._();
  factory SettingsBox() => _instance;
  SettingsBox._();
}

extension GeneralSettingsExtension on SettingsBox {
  ThemeMode get themeMode {
    final index = get(
      Settings.themeMode,
      defaultValue: 0,
    );
    return ThemeMode.values[index];
  }

  set themeMode(ThemeMode value) => put(Settings.themeMode, value.index);

  String get spotifyUri => get(Settings.spotifyUri,
      defaultValue:
          DefaultConstants().spotifyUri); // Defaults to Spotify Top 100 World
  String get spotifyUrl => get(Settings.spotifyUrl,
      defaultValue:
          DefaultConstants().spotifyUrl); // Defaults to Spotify Top 100 World

  double get c1InitialVolume => get(Settings.c1InitialVolume,
      defaultValue: kDebugMode
          ? 0.10
          : DefaultConstants().c1InitialVolume); // 0.10 if we are in DebugMode

  double get c2InitialVolume => get(Settings.c2InitialVolume,
      defaultValue: kDebugMode
          ? 0.10
          : DefaultConstants().c2InitialVolume); // 0.10 if we are in DebugMode
  set spotifyUrl(String value) => put(Settings.spotifyUrl, value);
  set spotifyUri(String value) => put(Settings.spotifyUri, value);

  set c1InitialVolume(double value) => put(Settings.c1InitialVolume, value);
  set c2InitialVolume(double value) => put(Settings.c2InitialVolume, value);

// Save our favourite Venue
  set venueId(int value) => put(Settings.venueId, value);
  int get venueId => get(Settings.venueId, defaultValue: 3455);

  // Save our favourite Federation
  set federationId(int value) => put(Settings.federationId, value);
  int get federationId => get(Settings.federationId, defaultValue: 8);

  // Save our favourite Azure Voice
  set azVoiceId(int value) => put(Settings.azVoiceId, value);
  int get azVoiceId => get(Settings.azVoiceId, defaultValue: 1);

  // Save our favourite Azure Location
  set azRegionId(int value) => put(Settings.azRegionId, value);
  int get azRegionId => get(Settings.azRegionId, defaultValue: 2);

  // Save our Azure TTS Key
  set azTtsKey(String value) => put(Settings.azTtsKey, value);
  String get azTtsKey => get(Settings.azTtsKey, defaultValue: "NoKey");

  // Save our Char count for Azure TTS
  set azCharCount(int value) => put(Settings.azCharCount, value);
  int get azCharCount => get(Settings.azCharCount, defaultValue: 0);

  // Last date of reset our Char count
  set azCharCountLastDate(DateTime value) =>
      put(Settings.azCharCountLastDate, value);
  DateTime get azCharCountLastDate =>
      get(Settings.azCharCountLastDate, defaultValue: DateTime.utc(2024, 1, 1));

  // Save our Volumesettings for background
  set backgroundVolumeLevel(double value) =>
      put(Settings.backgroundVolumeLevel, value);
  double get backgroundVolumeLevel =>
      get(Settings.backgroundVolumeLevel, defaultValue: 0.1);
  // Save our Volumesettings for background

  set ttsVolume(double value) => put(Settings.ttsVolume, value);
  double get ttsVolume => get(Settings.ttsVolume, defaultValue: 0.3);

  set mainVolume(double value) => put(Settings.mainVolume, value);
  double get mainVolume => get(Settings.mainVolume, defaultValue: 0.3);

  set myColorTheme(String value) => put(Settings.myColorTheme, value);
  String get myColorTheme =>
      get(Settings.myColorTheme, defaultValue: "greyLaw");
}
