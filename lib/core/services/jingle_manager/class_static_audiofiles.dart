import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';

class AudioConfigurations {
  static late String basePath;
  static bool initialized = false;

  static Future<void> initializeBasePath() async {
    if (!initialized) {
      Directory appCacheDir = await getApplicationCacheDirectory();
      basePath = appCacheDir.path;
      initialized = true;
    }
  }

  static Future<List<Map<String, dynamic>>> getAudioFileConfigurations() async {
    await initializeBasePath();
    return audioFileConfigurations.map((config) {
      return {
        'filePath': '$basePath/${config['fileName']}',
        'displayName': config['displayName'],
        'audioCategory': config['audioCategory'],
      };
    }).toList();
  }

  /// Returns the audio file configuration for a specific category
  /// Returns null if no configuration is found for the category
  static Future<Map<String, dynamic>?> getAudioFileConfigForCategory(
    AudioCategory category,
  ) async {
    await initializeBasePath();
    final config = audioFileConfigurations.firstWhere(
      (config) => config['audioCategory'] == category,
      orElse: () => {},
    );

    if (config.isEmpty) return null;

    return {
      'filePath': '$basePath/${config['fileName']}',
      'displayName': config['displayName'],
      'audioCategory': config['audioCategory'],
    };
  }

  /// Returns an AudioFile instance for a specific category
  /// Returns null if no configuration is found for the category
  static Future<AudioFile?> getAudioFileForCategory(
    AudioCategory category,
  ) async {
    final config = await getAudioFileConfigForCategory(category);
    if (config == null) return null;

    return AudioFile(
      filePath: config['filePath'],
      displayName: config['displayName'],
      audioCategory: config['audioCategory'],
    );
  }

  static Future<List<AudioFile>> getSpecialJingles() async {
    await initializeBasePath();
    return audioFileConfigurations
        .map(
          (config) => AudioFile(
            filePath: '$basePath/${config['fileName']}',
            displayName: '${config['displayName']}',
            audioCategory: AudioCategory.specialJingle,
          ),
        )
        .toList();
  }

  static List<Map<String, dynamic>> audioFileConfigurations = [
    {
      'fileName': 'ratataFile.mp3',
      'displayName': 'Ratata',
      'audioCategory': AudioCategory.ratataJingle,
    },
    {
      'fileName': 'penaltyFile.mp3',
      'displayName': 'Penalty',
      'audioCategory': AudioCategory.penaltyJingle,
    },
    {
      'fileName': 'lineup.mp3',
      'displayName': 'Lineup',
      'audioCategory': AudioCategory.lineupJingle,
    },
    {
      'fileName': 'goalHornFile.mp3',
      'displayName': 'GoalHorn',
      'audioCategory': AudioCategory.hornJingle,
    },
    {
      'fileName': 'oneMinFile.mp3',
      'displayName': 'OneMin',
      'audioCategory': AudioCategory.oneminJingle,
    },
    {
      'fileName': 'treeMinFile.mp3',
      'displayName': 'ThreeMin',
      'audioCategory': AudioCategory.threeminJingle,
    },
    {
      'fileName': 'timeoutFile.mp3',
      'displayName': 'Timeout',
      'audioCategory': AudioCategory.timeoutJingle,
    },
    {
      'fileName': 'powerUpFile.mp3',
      'displayName': 'PowerUp',
      'audioCategory': AudioCategory.powerupJingle,
    },
    {
      'fileName': 'Intro-AwayTeam.mp3',
      'displayName': 'AwayJingle',
      'audioCategory': AudioCategory.awayTeamJingle,
    },
    {
      'fileName': 'Intro-HomeTeam.mp3',
      'displayName': 'HomeJingle',
      'audioCategory': AudioCategory.homeTeamJingle,
    },
  ];
}
