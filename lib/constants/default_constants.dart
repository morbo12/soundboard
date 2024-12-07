import 'dart:io';
import 'package:flutter/widgets.dart';

class DefaultConstants {
  String spotifyUri =
      "spotify:playlist:37i9dQZEVXbNG2KDcFcKOF:play"; // Defaults to Spotify Top 100 World
  String spotifyUrl =
      "https://open.spotify.com/playlist/37i9dQZEVXbNG2KDcFcKOF"; // Defaults to Spotify Top 100 World
  double c1InitialVolume = 0.3;
  double c2InitialVolume = 0.2;
  double defaultTextSize = Platform.isWindows ? 24 : 24;
  double borderSize = 20;
  double soundboardSize = 500;
  double homeScreenDividerSize = 40;
  double appBarHeight = 15;
  int azCharCountLimit = 500000;
}

enum MsgType { normal, error }

class ScreenSizeUtil {
  static double getWidth(BuildContext context, {double? maxWidth}) {
    double screenWidth = MediaQuery.of(context).size.width;
    return maxWidth != null
        ? (screenWidth > maxWidth ? maxWidth : screenWidth)
        : screenWidth - DefaultConstants().borderSize;
  }

  static double getHeight(BuildContext context, {double? maxHeight}) {
    double screenHeight = MediaQuery.of(context).size.height;
    return maxHeight != null
        ? (screenHeight > maxHeight ? maxHeight : screenHeight)
        : screenHeight;
  }

  static double getSoundboardSize(BuildContext context) {
    if (Platform.isWindows) {
      // Return the soundboard size for Windows
      return DefaultConstants().soundboardSize;
    } else {
      // Return 0 for other platforms
      return MediaQuery.of(context).size.width;
    }
  }
}
