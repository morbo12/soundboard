import 'package:soundboard/features/music_player/data/music_player_service.dart';

/// Simple test to verify music player functionality
void main() async {
  print("Testing music player with metadata support...");

  try {
    final service = MusicPlayerService();

    // Test loading playlist
    final files = await service.loadMusicFiles();
    print("Found ${files.length} music files:");

    for (final file in files.take(3)) {
      // Show first 3 files
      print("- ${file.displayName} (${file.name})");
      if (file.title != null) {
        print("  Title: ${file.title}");
      }
      if (file.artist != null) {
        print("  Artist: ${file.artist}");
      }
    }

    // Test refresh functionality
    print("\nTesting playlist refresh...");
    await service.loadPlaylist();
    print("Playlist refresh completed");

    service.dispose();
    print("Music player test completed successfully!");
  } catch (e) {
    print("Error during test: $e");
  }
}
