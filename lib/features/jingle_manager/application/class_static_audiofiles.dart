import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audiocategory.dart';

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
        'audioCategory': config['audioCategory']
      };
    }).toList();
  }

  static List<Map<String, dynamic>> audioFileConfigurations = [
    {
      'fileName': 'ratataFile.mp3',
      'displayName': 'Ratata',
      'audioCategory': AudioCategory.ratataJingle
    },
    {
      'fileName': 'penaltyFile.mp3',
      'displayName': 'Penalty',
      'audioCategory': AudioCategory.penaltyJingle
    },
    {
      'fileName': 'lineup.mp3',
      'displayName': 'Lineup',
      'audioCategory': AudioCategory.lineupJingle
    },
    {
      'fileName': 'goalHornFile.mp3',
      'displayName': 'GoalHorn',
      'audioCategory': AudioCategory.hornJingle
    },
    {
      'fileName': 'oneMinFile.mp3',
      'displayName': 'OneMin',
      'audioCategory': AudioCategory.oneminJingle
    },
    {
      'fileName': 'treeMinFile.mp3',
      'displayName': 'ThreeMin',
      'audioCategory': AudioCategory.threeminJingle
    },
    {
      'fileName': 'timeoutFile.mp3',
      'displayName': 'Timeout',
      'audioCategory': AudioCategory.timeoutJingle
    },
    {
      'fileName': 'powerUpFile.mp3',
      'displayName': 'PowerUp',
      'audioCategory': AudioCategory.powerupJingle
    },
    {
      'fileName': 'Intro-AwayTeam.mp3',
      'displayName': 'AwayJingle',
      'audioCategory': AudioCategory.awayTeamJingle
    },
    {
      'fileName': 'Intro-HomeTeam.mp3',
      'displayName': 'HomeJingle',
      'audioCategory': AudioCategory.homeTeamJingle
    },
  ];
}
