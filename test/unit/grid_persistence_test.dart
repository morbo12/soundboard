import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_grid_jingle_config.dart';

void main() {
  group('Grid Persistence Integration Tests', () {
    test('Custom category survives save/load cycle', () async {
      // Simulate user assigning a custom category to a button
      final originalAudioFile = AudioFile(
        displayName: 'Ra ta ta ta\n(Random)',
        filePath: 'custom_category:abc123',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      // Step 1: Convert to GridJingleConfig (this happens in _saveState)
      final config = GridJingleConfig.fromAudioFile(originalAudioFile);
      expect(config, isNotNull);
      expect(config!.customCategoryId, equals('abc123'));

      // Step 2: Serialize to JSON (simulating save to storage)
      final jsonData = config.toJson();
      final jsonString = json.encode(jsonData);

      // Step 3: Deserialize from JSON (simulating load from storage)
      final restoredJsonData = json.decode(jsonString) as Map<String, dynamic>;
      final restoredConfig = GridJingleConfig.fromJson(restoredJsonData);

      // Step 4: Convert back to AudioFile (this happens in _loadState)
      final restoredAudioFile = await restoredConfig.toAudioFile();

      // Verify the custom category is fully restored
      expect(restoredAudioFile, isNotNull);
      expect(restoredAudioFile!.filePath, equals('custom_category:abc123'));
      expect(restoredAudioFile.isCategoryOnly, isTrue);
      expect(restoredAudioFile.displayName, equals('Ra ta ta ta\n(Random)'));
      expect(
        restoredAudioFile.audioCategory,
        equals(AudioCategory.genericJingle),
      );
    });

    test('Sound group survives save/load cycle', () async {
      // Simulate user assigning a sound group to a button
      final originalAudioFile = AudioFile(
        displayName: 'My Group\n(Group)',
        filePath: 'custom_group:group123',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      // Step 1: Convert to GridJingleConfig
      final config = GridJingleConfig.fromAudioFile(originalAudioFile);
      expect(config, isNotNull);
      expect(config!.filePath, equals('custom_group:group123'));

      // Step 2: Serialize to JSON
      final jsonData = config.toJson();
      final jsonString = json.encode(jsonData);

      // Step 3: Deserialize from JSON
      final restoredJsonData = json.decode(jsonString) as Map<String, dynamic>;
      final restoredConfig = GridJingleConfig.fromJson(restoredJsonData);

      // Step 4: Convert back to AudioFile
      final restoredAudioFile = await restoredConfig.toAudioFile();

      // Verify the sound group is fully restored
      expect(restoredAudioFile, isNotNull);
      expect(restoredAudioFile!.filePath, equals('custom_group:group123'));
      expect(restoredAudioFile.isCategoryOnly, isTrue);
      expect(restoredAudioFile.displayName, equals('My Group\n(Group)'));
    });

    test('Predefined category-only survives save/load cycle', () async {
      // Simulate user assigning a predefined category for random play
      final originalAudioFile = AudioFile(
        displayName: 'Goal Jingles\n(Random)',
        filePath: '',
        audioCategory: AudioCategory.goalJingle,
        isCategoryOnly: true,
      );

      // Step 1: Convert to GridJingleConfig
      final config = GridJingleConfig.fromAudioFile(originalAudioFile);
      expect(config, isNotNull);
      expect(config!.customCategoryId, isNull);
      expect(config.filePath, isNull);

      // Step 2: Serialize to JSON
      final jsonData = config.toJson();
      final jsonString = json.encode(jsonData);

      // Step 3: Deserialize from JSON
      final restoredJsonData = json.decode(jsonString) as Map<String, dynamic>;
      final restoredConfig = GridJingleConfig.fromJson(restoredJsonData);

      // Step 4: Convert back to AudioFile
      final restoredAudioFile = await restoredConfig.toAudioFile();

      // Verify the predefined category is fully restored
      expect(restoredAudioFile, isNotNull);
      expect(restoredAudioFile!.filePath, equals(''));
      expect(restoredAudioFile.isCategoryOnly, isTrue);
      expect(restoredAudioFile.audioCategory, equals(AudioCategory.goalJingle));
    });

    test('Multiple buttons with different custom categories', () async {
      // Simulate multiple buttons with different custom categories
      final button1 = AudioFile(
        displayName: 'Category A\n(Random)',
        filePath: 'custom_category:cat_a',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      final button2 = AudioFile(
        displayName: 'Category B\n(Random)',
        filePath: 'custom_category:cat_b',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      // Save/load cycle for button 1
      final config1 = GridJingleConfig.fromAudioFile(button1);
      final json1 = json.encode(config1!.toJson());
      final restored1 = GridJingleConfig.fromJson(
        json.decode(json1) as Map<String, dynamic>,
      );
      final audioFile1 = await restored1.toAudioFile();

      // Save/load cycle for button 2
      final config2 = GridJingleConfig.fromAudioFile(button2);
      final json2 = json.encode(config2!.toJson());
      final restored2 = GridJingleConfig.fromJson(
        json.decode(json2) as Map<String, dynamic>,
      );
      final audioFile2 = await restored2.toAudioFile();

      // Verify both buttons retain their distinct custom categories
      expect(audioFile1!.filePath, equals('custom_category:cat_a'));
      expect(audioFile2!.filePath, equals('custom_category:cat_b'));
    });
  });
}
