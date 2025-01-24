import 'package:audioplayers/audioplayers.dart';
import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';

class AudioFile {
  final String filePath;
  final String displayName;
  late AudioPlayer audioPlayer2;
  AudioCategory audioCategory;
  // late StreamSubscription<Duration> _durationSubscription;
  // late StreamSubscription<Duration> _positionSubscription;

  AudioFile(
      {required this.filePath,
      required this.displayName,
      required this.audioCategory}) {
    // audioPlayer2 = AudioPlayer();

    // _durationSubscription = audioPlayer2.onDurationChanged.listen((Duration d) {
    //   //get the duration of audio
    //   setState(() {
    //     // maxduration = d.inMilliseconds;
    //     maxduration = d;
    //     if (kDebugMode) {
    //       print("ONDURATIONCHANGED$d");
    //     }
    //   });
    // });
    // audioPlayer2.onPositionChanged.listen((Duration p) {});
  }
  // Future<void> setVol([double d = 1.0]) async {
  //   await audioPlayer2.setVolume(d);
  // }

  // Future<void> play([double d = 1.0]) async {
  //   if (audioPlayer2.state.name == "playing") {
  //     // print("audioPlayer is playing, stopping and releasing");
  //     await audioPlayer2.stop();
  //     await audioPlayer2.release();
  //   }
  //   await audioPlayer2.setVolume(d);
  //   await audioPlayer2.play(DeviceFileSource(filePath));
  // }

  // Future<void> stopNow() async {
  //   await audioPlayer2.stop();
  //   await audioPlayer2.release();
  // }

  // Future<void> stop([double d = 1.0]) async {
  //   const fadeDuration = 1000;
  //   Fade f = Fade();
  //   // print("Playing is: ${audioPlayer.state.name}");

  //   f.fade(0.0, d, fadeDuration, audioPlayer2);
  //   Future.delayed(const Duration(milliseconds: fadeDuration + 400), () async {
  //     // print("Completed wait Future.delayed");
  //     await audioPlayer2.stop();
  //     await audioPlayer2.release();
  //   });
  // }
}
