import 'package:audioplayers/audioplayers.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';

class AudioFile {
  final String filePath;
  final String displayName;
  late AudioPlayer audioPlayer2;
  AudioCategory audioCategory;
  final bool isCategoryOnly;

  AudioFile({
    required this.filePath,
    required this.displayName,
    required this.audioCategory,
    this.isCategoryOnly = false,
  });
}
