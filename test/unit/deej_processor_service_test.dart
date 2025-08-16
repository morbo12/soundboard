import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/deej_processor_service.dart';
import 'package:soundboard/features/screen_home/application/deej_processor/data/deej_config.dart';
import 'package:soundboard/core/services/volume_control_service_v2.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_settings/data/class_slider_mappings_adapter.dart';
import 'package:hive/hive.dart';
import 'package:easy_hive/easy_hive.dart';
import 'dart:io';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// Mock PathProviderPlatform for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  String? _tempDirPath;

  Future<String> get _tempPath async {
    return _tempDirPath ??= Directory.systemTemp.createTempSync('test_').path;
  }

  @override
  Future<String?> getApplicationSupportPath() async => _tempPath;

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempPath;

  @override
  Future<String?> getApplicationCachePath() async => _tempPath;

  @override
  Future<String?> getTemporaryPath() async => _tempPath;

  @override
  Future<String?> getLibraryPath() async => _tempPath;

  @override
  Future<String?> getDownloadsPath() async => _tempPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => [await _tempPath];

  @override
  Future<String?> getExternalStoragePath() async => _tempPath;

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async => [await _tempPath];
}

void main() {
  // Set up Hive for testing
  setUpAll(() async {
    // Mock the PathProviderPlatform
    PathProviderPlatform.instance = MockPathProviderPlatform();

    // Get the temp directory for testing
    final tempDir = Directory.systemTemp.createTempSync('test_hive_');

    // Register the SliderMappingAdapter (same as in main.dart)
    Hive.registerAdapter(SliderMappingAdapter());

    // Initialize EasyBox with the temp directory
    await EasyBox.initialize(subDir: tempDir.path);

    // Initialize SettingsBox
    await SettingsBox().init();
  });

  // Clean up Hive after all tests
  tearDownAll(() async {
    await Hive.close();
  });
  group('DeejProcessorService', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('deejProcessorServiceProvider can be created', () async {
      // This test verifies that the provider can be instantiated without errors
      // and that all dependencies are properly resolved

      try {
        final serviceAsync = container.read(deejProcessorServiceProvider);
        expect(serviceAsync, isA<AsyncValue<DeejProcessorService>>());

        // If running on Windows, the service should initialize
        // If not on Windows, it should still create but with limited functionality
        print('DeejProcessorService provider created successfully');
      } catch (e) {
        // If there are dependency issues, they should show up here
        fail('Failed to create DeejProcessorService: $e');
      }
    });

    test('DeejConfig provider provides proper configuration', () {
      final config = container.read(deejConfigProvider);

      expect(config, isA<DeejConfig>());
      expect(config.noiseReductionLevel, equals(0.02));
      expect(config.invertSliders, isA<bool>());
      expect(config.verbose, isA<bool>());
      expect(config.sliderMappings, isList);

      print('DeejConfig provider works correctly');
    });

    test('VolumeControlService provider is available', () {
      // There is no legacy `volumeControlServiceProvider` in the codebase anymore.
      // Instantiate the current service directly for the unit test.
      final volumeService = VolumeControlServiceV2(container);

      expect(volumeService, isA<VolumeControlServiceV2>());
      print('VolumeControlServiceV2 instance created successfully');
    });
  });
}

// Contains AI-generated edits.
