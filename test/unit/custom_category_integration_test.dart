import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/services/custom_category_service.dart';
import 'package:soundboard/core/models/custom_category.dart';
import 'package:soundboard/core/models/sound_group.dart';

void main() {
  group('Custom Category Integration Tests', () {
    late CustomCategoryService service;

    setUp(() {
      service = CustomCategoryService();
    });

    test('should create custom category and sound group', () async {
      // Create a custom category
      final category = await service.createCustomCategory(
        name: 'Test Category',
        description: 'A test category for integration testing',
        iconName: 'music_note',
        colorHex: '#9C27B0',
      );

      expect(category.name, equals('Test Category'));
      expect(
        category.description,
        equals('A test category for integration testing'),
      );

      // Create a sound group in the category
      final soundGroup = await service.createSoundGroup(
        name: 'Test Sound Group',
        description: 'A test sound group',
        customCategoryId: category.id,
        soundFilePaths: ['test1.mp3', 'test2.mp3', 'test3.mp3'],
        enableRandomization: true,
      );

      expect(soundGroup.name, equals('Test Sound Group'));
      expect(soundGroup.customCategoryId, equals(category.id));
      expect(soundGroup.soundFilePaths.length, equals(3));
      expect(soundGroup.enableRandomization, isTrue);

      // Test retrieval
      final retrievedGroup = service.getSoundGroupById(soundGroup.id);
      expect(retrievedGroup, isNotNull);
      expect(retrievedGroup!.id, equals(soundGroup.id));

      // Test random sound selection
      final randomSound = soundGroup.getRandomSound();
      expect(randomSound, isNotNull);
      expect(soundGroup.soundFilePaths.contains(randomSound), isTrue);
    });

    test('should handle special filePath format for custom sound groups', () {
      const groupId = 'test-group-123';
      const specialFilePath = 'custom_group:$groupId';

      expect(specialFilePath.startsWith('custom_group:'), isTrue);

      final extractedGroupId = specialFilePath.substring(
        'custom_group:'.length,
      );
      expect(extractedGroupId, equals(groupId));
    });

    test('should get sound groups for category', () async {
      // Create a custom category
      final category = await service.createCustomCategory(
        name: 'Test Category 2',
        description: 'Another test category',
      );

      // Create multiple sound groups
      final soundGroup1 = await service.createSoundGroup(
        name: 'Group 1',
        description: 'First group',
        customCategoryId: category.id,
        soundFilePaths: ['sound1.mp3'],
      );

      final soundGroup2 = await service.createSoundGroup(
        name: 'Group 2',
        description: 'Second group',
        customCategoryId: category.id,
        soundFilePaths: ['sound2.mp3'],
      );

      // Get groups for category
      final groups = service.getSoundGroupsForCategory(category.id);
      expect(groups.length, equals(2));
      expect(
        groups.map((g) => g.id),
        containsAll([soundGroup1.id, soundGroup2.id]),
      );
    });
  });
}
