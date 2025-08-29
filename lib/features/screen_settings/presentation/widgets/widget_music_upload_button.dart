import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/common/widgets/dialogs/modern_music_upload_dialog.dart';
import 'package:soundboard/core/utils/logger.dart';

class MusicUploadButton extends ConsumerStatefulWidget {
  const MusicUploadButton({super.key});

  @override
  ConsumerState<MusicUploadButton> createState() => _MusicUploadButtonState();
}

class _MusicUploadButtonState extends ConsumerState<MusicUploadButton> {
  final ValueNotifier<String?> selectedPath = ValueNotifier(null);
  final Logger logger = const Logger('MusicUploadButton');

  void _showMusicManager() {
    showDialog(
      context: context,
      builder: (context) => const ModernMusicUploadDialog(),
    );
  }

  Future<int> _getMusicFileCount() async {
    try {
      final Directory appSupportDir = await getApplicationCacheDirectory();
      final Directory musicDir = Directory('${appSupportDir.path}/Music');

      if (!await musicDir.exists()) {
        return 0;
      }

      final files = musicDir
          .listSync()
          .where(
            (file) =>
                file is File &&
                (file.path.toLowerCase().endsWith('.mp3') ||
                    file.path.toLowerCase().endsWith('.flac') ||
                    file.path.toLowerCase().endsWith('.ogg') ||
                    file.path.toLowerCase().endsWith('.wav') ||
                    file.path.toLowerCase().endsWith('.m4a')),
          )
          .length;

      return files;
    } catch (e) {
      logger.e("Error counting music files: $e");
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getMusicFileCount(),
      builder: (context, snapshot) {
        final fileCount = snapshot.data ?? 0;

        return Card(
          elevation: 2,
          child: InkWell(
            onTap: _showMusicManager,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9C27B0).withAlpha(80), // Purple for music
                    const Color(0xFF9C27B0).withAlpha(50),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF9C27B0,
                      ).withAlpha(100), // Purple for music
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.library_music,
                      color: Color(0xFF9C27B0),
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
                            const Text(
                              'Music Player',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF9C27B0),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9C27B0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'MUSIC',
                                style: TextStyle(
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
                          'Manage background music files ($fileCount files)',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF9C27B0).withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.settings,
                    color: Color(0xFF9C27B0),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Contains AI-generated edits.
