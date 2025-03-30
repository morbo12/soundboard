// import 'dart:async';
// import 'dart:collection';
// import 'dart:typed_data';

// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mockito/annotations.dart';
// import 'package:mockito/mockito.dart';
// import 'package:soundboard/constants/providers.dart';
// import 'package:soundboard/features/jingle_manager/application/class_audiocategory.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiomanager.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/data/class_mainvolume.dart';
// import 'package:soundboard/features/screen_home/application/audioplayer/player_fade.dart';
// import 'package:soundboard/properties.dart';
// import 'package:soundboard/utils/logger.dart';

// // Generate mocks for dependencies
// @GenerateMocks([
//   AudioPlayer,
//   WidgetRef,
//   StateNotifierProvider,
//   StateNotifier,
//   Fade,
//   Logger
// ])
// import 'test_audiomanager.mocks.dart';

// // Mock classes that can't be auto-generated
// class MockVolumeNotifier extends StateNotifier<double> with Mock {
//   MockVolumeNotifier() : super(0.0);

//   void updateVolume(double volume) {
//     state = volume;
//   }
// }

// class MockSettingsBox extends Mock implements SettingsBox {
//   @override
//   double get c1InitialVolume => 0.5;

//   @override
//   double get c2InitialVolume => 0.5;

//   @override
//   double get backgroundVolumeLevel => 0.3;
// }

// void main() {
//   late AudioManager audioManager;
//   late MockAudioPlayer mockChannel1;
//   late MockAudioPlayer mockChannel2;
//   late MockWidgetRef mockRef;
//   late MockVolumeNotifier mockC1VolumeNotifier;
//   late MockVolumeNotifier mockC2VolumeNotifier;
//   late MockFade mockFade;
//   late MockLogger mockLogger;

//   // Helper function to create test audio files
//   List<AudioFile> createTestAudioFiles() {
//     return [
//       AudioFile(
//         audioCategory: AudioCategory.lineupBackgroundJingle,
//         filePath: 'test/assets/background1.mp3',
//         displayName: 'background1.mp3',
//       ),
//       AudioFile(
//         audioCategory: AudioCategory.genericJingle,
//         filePath: 'test/assets/background2.mp3',
//         displayName: 'background2.mp3',
//       ),
//       AudioFile(
//         audioCategory: AudioCategory.hornJingle,
//         filePath: 'test/assets/horn1.mp3',
//         displayName: 'horn1.mp3',
//       ),
//       AudioFile(
//         audioCategory: AudioCategory.genericJingle,
//         filePath: 'test/assets/effect1.mp3',
//         displayName: 'effect1.mp3',
//       ),
//       AudioFile(
//         audioCategory: AudioCategory.genericJingle,
//         filePath: 'test/assets/effect2.mp3',
//         displayName: 'effect2.mp3',
//       ),
//     ];
//   }

//   setUp(() {
//     // Initialize mocks
//     mockChannel1 = MockAudioPlayer();
//     mockChannel2 = MockAudioPlayer();
//     mockRef = MockWidgetRef();
//     mockC1VolumeNotifier = MockVolumeNotifier();
//     mockC2VolumeNotifier = MockVolumeNotifier();
//     mockFade = MockFade();
//     mockLogger = MockLogger();

//     // Set up AudioManager with mocked dependencies
//     audioManager = AudioManager();

//     // Replace real instances with mocks
//     audioManager.channel1 = mockChannel1;
//     audioManager.channel2 = mockChannel2;

//     // Set up the widget reference
//     audioManager.setRef(mockRef);

//     // Add test audio files
//     for (var audioFile in createTestAudioFiles()) {
//       audioManager.addInstance(audioFile);
//     }

//     // Set up provider mocks
//     when(mockRef.read(c1VolumeProvider.notifier))
//         .thenReturn(mockC1VolumeNotifier as VolumeNotifier);
//     when(mockRef.read(c2VolumeProvider.notifier))
//         .thenReturn(mockC2VolumeNotifier as VolumeNotifier);

//     // Set up default behaviors for AudioPlayer mocks
//     when(mockChannel1.setVolume(any)).thenAnswer((_) async {});
//     when(mockChannel2.setVolume(any)).thenAnswer((_) async {});
//     when(mockChannel1.play(any)).thenAnswer((_) async {});
//     when(mockChannel2.play(any)).thenAnswer((_) async {});
//     when(mockChannel1.stop()).thenAnswer((_) async {});
//     when(mockChannel2.stop()).thenAnswer((_) async {});
//     when(mockChannel1.release()).thenAnswer((_) async {});
//     when(mockChannel2.release()).thenAnswer((_) async {});
//     when(mockChannel1.state).thenReturn(PlayerState.stopped);
//     when(mockChannel2.state).thenReturn(PlayerState.stopped);
//   });

//   group('AudioManager Initialization', () {
//     test('should initialize with default volumes', () {
//       // Create a new AudioManager to test initialization
//       final newAudioManager = AudioManager();

//       // Verify that setVolume was called with the expected values
//       verify(mockChannel1.setVolume(any)).called(greaterThanOrEqualTo(1));
//       verify(mockChannel2.setVolume(any)).called(greaterThanOrEqualTo(1));
//     });

//     test('should add audio instances correctly', () {
//       // Create a test audio file
//       final testAudio = AudioFile(
//         audioCategory: AudioCategory.genericJingle,
//         filePath: 'test/assets/test.mp3',
//         displayName: 'test.mp3',
//       );

//       // Add the instance
//       audioManager.addInstance(testAudio);

//       // Verify it was added
//       expect(audioManager.audioInstances.contains(testAudio), true);
//     });
//   });

//   group('Audio Playback', () {
//     test('should play audio on available channel', () async {
//       // Set up channel states
//       when(mockChannel1.state).thenReturn(PlayerState.playing);
//       when(mockChannel2.state).thenReturn(PlayerState.stopped);

//       // Call playAudio
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//       );

//       // Verify that channel2 was used (since channel1 is playing)
//       verify(mockChannel2.play(any)).called(1);
//       verify(mockChannel2.setVolume(any)).called(greaterThanOrEqualTo(1));
//     });

//     test('should fade out and stop all channels when stopAll is called',
//         () async {
//       // Call stopAll
//       await audioManager.stopAll(mockRef);

//       // Verify both channels were stopped
//       verify(mockChannel1.stop()).called(1);
//       verify(mockChannel2.stop()).called(1);
//       verify(mockChannel1.release()).called(1);
//       verify(mockChannel2.release()).called(1);
//     });

//     test('should play horn jingle on channel2', () async {
//       // Call playHorn
//       await audioManager.playHorn(mockRef);

//       // Verify channel2 was used with full volume
//       verify(mockChannel2.setVolume(1.0)).called(1);
//       verify(mockChannel2.play(any)).called(1);
//     });
//   });

//   group('Playback Strategies', () {
//     test('should play sequentially when sequential is true', () async {
//       // Call playAudio with sequential=true twice
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         sequential: true,
//       );

//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         sequential: true,
//       );

//       // Verify play was called twice
//       verify(mockChannel1.play(any)).called(2);
//     });

//     test('should reset sequential index correctly', () async {
//       // Play sequentially
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         sequential: true,
//       );

//       // Reset the index
//       audioManager.resetSequentialIndex(AudioCategory.genericJingle);

//       // Play again
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         sequential: true,
//       );

//       // Verify the first file was played again (would need to check the actual file path)
//       verify(mockChannel1.play(any)).called(2);
//     });

//     test('should play randomly when random is true', () async {
//       // Call playAudio with random=true
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         random: true,
//       );

//       // Verify play was called
//       verify(mockChannel1.play(any)).called(1);
//     });
//   });

//   group('Volume Control', () {
//     test('should set channel volume and update provider state', () async {
//       // Call _setChannelVolume through a public method
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//       );

//       // Verify volume was set and provider was updated
//       verify(mockChannel1.setVolume(any)).called(greaterThanOrEqualTo(1));
//       verify(mockRef.read(c1VolumeProvider.notifier))
//           .called(greaterThanOrEqualTo(1));
//     });

//     test('should fade out without stopping when fadeOutNoStop is called',
//         () async {
//       // Call fadeOutNoStop
//       await audioManager.fadeOutNoStop(mockRef, AudioChannel.channel1);

//       // Verify volume was set to 0 but stop was not called
//       verify(mockChannel1.setVolume(any)).called(greaterThanOrEqualTo(1));
//       verifyNever(mockChannel1.stop());
//     });
//   });

//   group('Byte Array Playback', () {
//     test('should play from byte array', () async {
//       // Create a test byte array
//       final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

//       // Call playBytes
//       await audioManager.playBytes(audio: testBytes, ref: mockRef);

//       // Verify channel2 was used with full volume
//       verify(mockChannel2.setVolume(1.0)).called(1);
//       verify(mockChannel2.play(any)).called(1);
//     });

//     test('should play from byte array and wait for completion', () async {
//       // Create a test byte array
//       final testBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

//       // Set up the onPlayerStateChanged stream
//       final controller = StreamController<PlayerState>();
//       when(mockChannel2.onPlayerStateChanged)
//           .thenAnswer((_) => controller.stream);

//       // Start playing (don't await so we can trigger completion)
//       final future =
//           audioManager.playBytesAndWait(audio: testBytes, ref: mockRef);

//       // Verify channel2 was used with full volume
//       verify(mockChannel2.setVolume(1.0)).called(1);
//       verify(mockChannel2.play(any)).called(1);

//       // Simulate completion
//       controller.add(PlayerState.completed);

//       // Now await the future
//       await future;

//       // Clean up
//       await controller.close();
//     });
//   });

//   group('Error Handling', () {
//     test('should handle errors when setting volume', () async {
//       // Set up an error
//       when(mockChannel1.setVolume(any)).thenThrow(Exception('Test error'));

//       // Call a method that sets volume
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//       );

//       // Verify the error was logged (would need to check logs)
//       // This test just verifies the method doesn't throw
//     });

//     test('should handle errors when playing audio', () async {
//       // Set up an error
//       when(mockChannel1.play(any)).thenThrow(Exception('Test error'));

//       // Call playAudio
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//       );

//       // Verify the error was logged (would need to check logs)
//       // This test just verifies the method doesn't throw
//     });
//   });

//   group('Memory Management', () {
//     test('should clear play history for all categories', () async {
//       // Play some audio to populate the history
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         random: true,
//       );

//       await audioManager.playAudio(
//         AudioCategory.lineupBackgroundJingle,
//         mockRef,
//         random: true,
//       );

//       // Clear the history
//       audioManager.clearPlayHistory();

//       // Play again
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         random: true,
//       );

//       // Verify play was called for each call
//       verify(mockChannel1.play(any)).called(3);
//     });

//     test('should clear play history for specific category', () async {
//       // Play some audio to populate the history
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         random: true,
//       );

//       await audioManager.playAudio(
//         AudioCategory.lineupBackgroundJingle,
//         mockRef,
//         random: true,
//       );

//       // Clear the history for one category
//       audioManager.clearPlayHistoryForCategory(AudioCategory.genericJingle);

//       // Play again
//       await audioManager.playAudio(
//         AudioCategory.genericJingle,
//         mockRef,
//         random: true,
//       );

//       // Verify play was called for each call
//       verify(mockChannel1.play(any)).called(3);
//     });
//   });
// }
