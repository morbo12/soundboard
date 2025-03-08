// test/features/screen_tts_settings/presentation/settings_tts_screen_test.dart

import 'dart:io';

import 'package:easy_hive/easy_hive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/constants/providers.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/screen_settings_tts.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/widget_settings_tts_region.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/widget_settings_tts_servicekey.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/widget_settings_tts_voice.dart';
import 'package:soundboard/properties.dart';

// Mock implementations for dependencies (VERY IMPORTANT)
class MockDefaultConstants extends DefaultConstants {
  @override
  int get azCharCountLimit => 1000; // Example limit
}

// Mock for ScreenSizeUtil (if it's not a simple helper)
class MockScreenSizeUtil {
  static double getWidth(BuildContext context) => 400; // Example width
}

// Mock for PathProviderPlatform
class MockPathProviderPlatform extends MockPlatformInterfaceMixin
    with Mock
    implements PathProviderPlatform {
  // Use a Future<String> to ensure the path is available before use.
  late final Future<String> _tempDirPath;

  MockPathProviderPlatform() {
    _tempDirPath = _createTempDir();
  }

  Future<String> _createTempDir() async {
    final directory = await Directory.systemTemp.createTemp();
    return directory.path;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async => _tempDirPath;

  @override
  Future<String?> getApplicationCachePath() async => _tempDirPath;

  @override
  Future<String?> getApplicationSupportPath() async => _tempDirPath;

  @override
  Future<String?> getDownloadsPath() async => _tempDirPath;

  @override
  Future<List<String>?> getExternalCachePaths() async => [await _tempDirPath];

  @override
  Future<String?> getExternalStoragePath() async => _tempDirPath;

  @override
  Future<List<String>?> getExternalStoragePaths(
          {StorageDirectory? type}) async =>
      [await _tempDirPath];

  @override
  Future<String?> getLibraryPath() async => _tempDirPath;

  @override
  Future<String?> getTemporaryPath() async => _tempDirPath;
}

void main() {
  // Set up Hive for testing (BEFORE any tests run)
  setUpAll(() async {
    // Mock the PathProviderPlatform
    PathProviderPlatform.instance = MockPathProviderPlatform();
    // No need to await getApplicationSupportDirectory() here anymore,
    // because MockPathProviderPlatform handles it.
    Directory settingsDir = await getApplicationSupportDirectory();

    await EasyBox.initialize(subDir: settingsDir.path);
    await SettingsBox().init();
  });

  // Clean up Hive after all tests are done
  tearDownAll(() async {
    await Hive.close();
  });

  // Helper function to create the widget tree with Riverpod overrides
  Widget makeTestableWidget({
    required Widget child,
    int? azCharCount, // Allow overriding the character count
  }) {
    return ProviderScope(
      overrides: [
        // Override providers with mock/test values
        azCharCountProvider.overrideWithProvider(StateProvider(
            (ref) => azCharCount ?? 0)), // Default to 0 if not provided
        // Add other provider overrides as needed (e.g., for SettingsTtsVoice, etc.)
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('SettingsTtsScreen', () {
    testWidgets('renders correctly with initial values',
        (WidgetTester tester) async {
      // Arrange (setup)
      await tester
          .pumpWidget(makeTestableWidget(child: const SettingsTtsScreen()));

      // Assert (verify initial state)
      expect(find.text('Antal tecken kvar att använda'), findsOneWidget);
      expect(find.text('Text to speech konfiguration'), findsOneWidget);
      expect(find.text('Välj röst'), findsOneWidget);
      expect(find.text('Välj Region'), findsOneWidget);
      expect(find.text('Ange Azure service key för Text To Speech'),
          findsOneWidget);
      expect(find.byType(SettingsTtsVoice), findsOneWidget);
      expect(find.byType(SettingsTtsRegion), findsOneWidget);
      expect(find.byType(SettingsTtsServiceKey), findsOneWidget);
      expect(find.byType(Gap), findsWidgets); // Check for Gap widgets
    });

    testWidgets('displays correct remaining character count',
        (WidgetTester tester) async {
      // Arrange: Set a specific azCharCount
      const testCharCount = 500;

      // Create the widget with the overridden provider
      await tester.pumpWidget(makeTestableWidget(
        child: const SettingsTtsScreen(),
        azCharCount: testCharCount,
      ));

      // Allow the widget to fully settle (handles any animations or async operations)
      await tester.pumpAndSettle();

      // Calculate the expected remaining count
      final expectedRemaining =
          MockDefaultConstants().azCharCountLimit - testCharCount;

      // Try to find the text in different formats
      final containsMatch = find.textContaining(expectedRemaining.toString());

      // Use a more flexible assertion
      expect(containsMatch, findsWidgets,
          reason:
              'Should find text containing ${expectedRemaining.toString()}');
    });

    testWidgets('renders custom header and subheader texts correctly',
        (WidgetTester tester) async {
      // Arrange
      await tester
          .pumpWidget(makeTestableWidget(child: const SettingsTtsScreen()));

      // Act: No action needed, just observing the rendered state

      // Assert: Check for specific text styles (using helper methods)
      final headerTextFinder = find.byType(Text);
      final headerTexts = headerTextFinder
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .toList();

      // Check for the presence of header texts
      expect(headerTexts.contains('Antal tecken kvar att använda'), isTrue);
      expect(headerTexts.contains('Text to speech konfiguration'), isTrue);

      // You can also check for the style, but it's more brittle.  It's better to check
      // for semantic meaning (like "is this a header?") rather than exact style.
      // This is just an example:
      final settingsHeaderText =
          tester.widget<Text>(find.text('Antal tecken kvar att använda'));
      expect(settingsHeaderText.style!.fontSize, 19);
      expect(settingsHeaderText.style!.fontWeight, FontWeight.bold);

      final settingsHeader2Text = tester.widget<Text>(find.text(
          'Du behöver ett konto hos Azure för att använda denna funktion.'));
      expect(settingsHeader2Text.style!.fontSize, 12);
      expect(settingsHeader2Text.style!.fontWeight, FontWeight.normal);
    });
  });
}
