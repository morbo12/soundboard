import 'dart:io';

/// Core application constants that don't change during runtime.
/// These are compile-time constants and platform-agnostic defaults.
class AppConstants {
  AppConstants._(); // Private constructor to prevent instantiation

  // Spotify defaults
  static const String defaultSpotifyUri =
      "spotify:playlist:37i9dQZEVXbNG2KDcFcKOF:play";
  static const String defaultSpotifyUrl =
      "https://open.spotify.com/playlist/37i9dQZEVXbNG2KDcFcKOF";

  // Audio defaults
  static const double defaultC1Volume = 0.0;
  static const double defaultC2Volume = 0.0;
  static const double defaultMusicPlayerVolume = 0.8;

  // UI defaults
  static const double defaultBorderSize = 20.0;
  static const double defaultSoundboardSize = 500.0;
  static const double defaultHomeScreenDividerSize = 40.0;
  static const double defaultAppBarHeight = 15.0;
  static const double defaultTextSize = 24.0;

  // Azure TTS limits
  static const int azureCharCountLimit = 500000;

  // Responsive breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  static const double desktopBreakpoint = 1440.0;
}

/// Platform-specific constants that are determined at runtime.
class PlatformConstants {
  PlatformConstants._();

  static bool get isDesktop =>
      Platform.isWindows || Platform.isMacOS || Platform.isLinux;

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static double get defaultTextSize => Platform.isWindows ? 24.0 : 22.0;

  static double get defaultButtonHeight => isDesktop ? 48.0 : 44.0;
}

// Contains AI-generated edits.
