import 'package:audioplayers/audioplayers.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';

class AudioFile {
  final String filePath;
  final String displayName;
  late AudioPlayer audioPlayer2;
  AudioCategory audioCategory;

  AudioFile(
      {required this.filePath,
      required this.displayName,
      required this.audioCategory});
}
