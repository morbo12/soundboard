import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/core/constants/app_constants.dart';
import 'package:soundboard/core/properties.dart';

/// Configuration providers that manage application settings.
/// These providers follow Riverpod best practices for state management.

/// Spotify configuration provider
final spotifyConfigProvider = Provider<SpotifyConfig>((ref) {
  final settings = SettingsBox();
  return SpotifyConfig(uri: settings.spotifyUri, url: settings.spotifyUrl);
});

/// Audio volume configuration provider
final audioVolumeConfigProvider = Provider<AudioVolumeConfig>((ref) {
  final settings = SettingsBox();
  return AudioVolumeConfig(
    c1InitialVolume: settings.c1InitialVolume,
    c2InitialVolume: settings.c2InitialVolume,
    mainVolume: settings.mainVolume,
    ttsVolume: settings.ttsVolume,
    backgroundVolume: settings.backgroundVolumeLevel,
  );
});

/// UI configuration provider
final uiConfigProvider = Provider<UIConfig>((ref) {
  return const UIConfig(
    borderSize: AppConstants.defaultBorderSize,
    soundboardSize: AppConstants.defaultSoundboardSize,
    homeScreenDividerSize: AppConstants.defaultHomeScreenDividerSize,
    appBarHeight: AppConstants.defaultAppBarHeight,
    defaultTextSize: AppConstants.defaultTextSize,
  );
});

/// Azure TTS configuration provider
final azureTtsConfigProvider = Provider<AzureTtsConfig>((ref) {
  final settings = SettingsBox();
  return AzureTtsConfig(
    charCountLimit: AppConstants.azureCharCountLimit,
    currentCharCount: settings.azCharCount,
    ttsKey: settings.azTtsKey,
    voiceId: settings.azVoiceId,
    regionId: settings.azRegionId,
  );
});

/// Immutable configuration classes

class SpotifyConfig {
  const SpotifyConfig({required this.uri, required this.url});

  final String uri;
  final String url;

  SpotifyConfig copyWith({String? uri, String? url}) {
    return SpotifyConfig(uri: uri ?? this.uri, url: url ?? this.url);
  }
}

class AudioVolumeConfig {
  const AudioVolumeConfig({
    required this.c1InitialVolume,
    required this.c2InitialVolume,
    required this.mainVolume,
    required this.ttsVolume,
    required this.backgroundVolume,
  });

  final double c1InitialVolume;
  final double c2InitialVolume;
  final double mainVolume;
  final double ttsVolume;
  final double backgroundVolume;

  AudioVolumeConfig copyWith({
    double? c1InitialVolume,
    double? c2InitialVolume,
    double? mainVolume,
    double? ttsVolume,
    double? backgroundVolume,
  }) {
    return AudioVolumeConfig(
      c1InitialVolume: c1InitialVolume ?? this.c1InitialVolume,
      c2InitialVolume: c2InitialVolume ?? this.c2InitialVolume,
      mainVolume: mainVolume ?? this.mainVolume,
      ttsVolume: ttsVolume ?? this.ttsVolume,
      backgroundVolume: backgroundVolume ?? this.backgroundVolume,
    );
  }
}

class UIConfig {
  const UIConfig({
    required this.borderSize,
    required this.soundboardSize,
    required this.homeScreenDividerSize,
    required this.appBarHeight,
    required this.defaultTextSize,
  });

  final double borderSize;
  final double soundboardSize;
  final double homeScreenDividerSize;
  final double appBarHeight;
  final double defaultTextSize;
}

class AzureTtsConfig {
  const AzureTtsConfig({
    required this.charCountLimit,
    required this.currentCharCount,
    required this.ttsKey,
    required this.voiceId,
    required this.regionId,
  });

  final int charCountLimit;
  final int currentCharCount;
  final String ttsKey;
  final int voiceId;
  final int regionId;

  AzureTtsConfig copyWith({
    int? charCountLimit,
    int? currentCharCount,
    String? ttsKey,
    int? voiceId,
    int? regionId,
  }) {
    return AzureTtsConfig(
      charCountLimit: charCountLimit ?? this.charCountLimit,
      currentCharCount: currentCharCount ?? this.currentCharCount,
      ttsKey: ttsKey ?? this.ttsKey,
      voiceId: voiceId ?? this.voiceId,
      regionId: regionId ?? this.regionId,
    );
  }
}

// Contains AI-generated edits.
