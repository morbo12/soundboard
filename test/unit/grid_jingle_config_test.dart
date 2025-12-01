import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/jingle_manager/class_audiocategory.dart';
import 'package:soundboard/features/screen_home/application/audioplayer/data/class_audio.dart';
import 'package:soundboard/features/screen_home/presentation/board/classes/class_grid_jingle_config.dart';

void main() {
  group('GridJingleConfig Custom Category Tests', () {
    test('Custom category ID is preserved through fromAudioFile', () {
      // Create an AudioFile with a custom category identifier
      final audioFile = AudioFile(
        displayName: 'Ra ta ta ta\n(Random)',
        filePath: 'custom_category:abc123',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      // Convert to GridJingleConfig
      final config = GridJingleConfig.fromAudioFile(audioFile);

      // Verify custom category ID is extracted
      expect(config, isNotNull);
      expect(config!.customCategoryId, equals('abc123'));
      expect(config.isCategoryOnly, isTrue);
      expect(config.filePath, isNull); // filePath should be cleared
    });

    test('Custom category ID is preserved through JSON serialization', () {
      // Create a config with custom category
      final config = GridJingleConfig(
        id: 'test_button',
        displayName: 'Ra ta ta ta\n(Random)',
        filePath: null,
        category: AudioCategory.genericJingle,
        isCategoryOnly: true,
        customCategoryId: 'abc123',
      );

      // Serialize to JSON
      final json = config.toJson();

      // Verify JSON contains custom category ID
      expect(json['customCategoryId'], equals('abc123'));

      // Deserialize from JSON
      final restoredConfig = GridJingleConfig.fromJson(json);

      // Verify custom category ID is preserved
      expect(restoredConfig.customCategoryId, equals('abc123'));
      expect(restoredConfig.isCategoryOnly, isTrue);
    });

    test('Custom category is reconstructed in toAudioFile', () async {
      // Create a config with custom category
      final config = GridJingleConfig(
        id: 'test_button',
        displayName: 'Ra ta ta ta\n(Random)',
        filePath: null,
        category: AudioCategory.genericJingle,
        isCategoryOnly: true,
        customCategoryId: 'abc123',
      );

      // Convert back to AudioFile
      final audioFile = await config.toAudioFile();

      // Verify the custom_category: prefix is reconstructed
      expect(audioFile, isNotNull);
      expect(audioFile!.filePath, equals('custom_category:abc123'));
      expect(audioFile.isCategoryOnly, isTrue);
      expect(audioFile.displayName, equals('Ra ta ta ta\n(Random)'));
    });

    test('Sound groups with custom_group: prefix are preserved', () {
      // Create an AudioFile with a sound group identifier
      final audioFile = AudioFile(
        displayName: 'My Group\n(Group)',
        filePath: 'custom_group:group123',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      // Convert to GridJingleConfig
      final config = GridJingleConfig.fromAudioFile(audioFile);

      // Verify sound group filePath is kept as-is
      expect(config, isNotNull);
      expect(config!.filePath, equals('custom_group:group123'));
      expect(config.customCategoryId, isNull); // No custom category ID
      expect(config.isCategoryOnly, isTrue);
    });

    test('Sound groups are preserved through JSON serialization', () {
      // Create a config with sound group
      final config = GridJingleConfig(
        id: 'test_button',
        displayName: 'My Group\n(Group)',
        filePath: 'custom_group:group123',
        category: AudioCategory.genericJingle,
        isCategoryOnly: true,
        customCategoryId: null,
      );

      // Serialize to JSON
      final json = config.toJson();

      // Deserialize from JSON
      final restoredConfig = GridJingleConfig.fromJson(json);

      // Verify sound group filePath is preserved
      expect(restoredConfig.filePath, equals('custom_group:group123'));
      expect(restoredConfig.isCategoryOnly, isTrue);
    });

    test('Sound groups are reconstructed correctly in toAudioFile', () async {
      // Create a config with sound group
      final config = GridJingleConfig(
        id: 'test_button',
        displayName: 'My Group\n(Group)',
        filePath: 'custom_group:group123',
        category: AudioCategory.genericJingle,
        isCategoryOnly: true,
        customCategoryId: null,
      );

      // Convert back to AudioFile
      final audioFile = await config.toAudioFile();

      // Verify the sound group filePath is preserved
      expect(audioFile, isNotNull);
      expect(audioFile!.filePath, equals('custom_group:group123'));
      expect(audioFile.isCategoryOnly, isTrue);
    });

    test('Predefined category-only buttons work without customCategoryId', () {
      // Create a predefined category-only button
      final audioFile = AudioFile(
        displayName: 'Generic Jingles\n(Random)',
        filePath: '',
        audioCategory: AudioCategory.genericJingle,
        isCategoryOnly: true,
      );

      // Convert to GridJingleConfig
      final config = GridJingleConfig.fromAudioFile(audioFile);

      // Verify no custom category ID
      expect(config, isNotNull);
      expect(config!.customCategoryId, isNull);
      expect(config.isCategoryOnly, isTrue);
      expect(config.filePath, isNull);
    });

    test('Predefined category-only is reconstructed correctly', () async {
      // Create a config with predefined category-only
      final config = GridJingleConfig(
        id: 'test_button',
        displayName: 'Goal Jingles\n(Random)',
        filePath: null,
        category: AudioCategory.goalJingle,
        isCategoryOnly: true,
        customCategoryId: null,
      );

      // Convert back to AudioFile
      final audioFile = await config.toAudioFile();

      // Verify predefined category-only is reconstructed
      expect(audioFile, isNotNull);
      expect(audioFile!.filePath, equals('')); // Empty for predefined
      expect(audioFile.isCategoryOnly, isTrue);
      expect(audioFile.audioCategory, equals(AudioCategory.goalJingle));
    });
  });
}
