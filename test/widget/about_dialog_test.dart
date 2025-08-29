import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:soundboard/about/widgets/about_dialog.dart';

class MockPackageInfo extends Mock implements PackageInfo {
  @override
  String get appName => 'soundboard';

  @override
  String get packageName => 'com.example.soundboard';

  @override
  String get version => '1.0.0';

  @override
  String get buildNumber => '1';

  @override
  String get buildSignature => '';

  Future<String> get installSource => Future.value('');
}

class MockUrlLauncher {
  static bool Function(Uri)? mockLaunchUrl;
  static bool wasLaunched = false;
  static Uri? lastLaunchedUri;

  static Future<bool> launchUrl(Uri url) async {
    wasLaunched = true;
    lastLaunchedUri = url;
    if (mockLaunchUrl != null) {
      return mockLaunchUrl!(url);
    }
    return true;
  }

  static void reset() {
    mockLaunchUrl = null;
    wasLaunched = false;
    lastLaunchedUri = null;
  }
}

void main() {
  late MockPackageInfo mockPackageInfo;

  setUp(() {
    mockPackageInfo = MockPackageInfo();
    MockUrlLauncher.reset();
  });

  tearDown(() {
    MockUrlLauncher.reset();
  });

  testWidgets('shows loading indicator while loading package info', (
    WidgetTester tester,
  ) async {
    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => const AboutDialogWidget(),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show About'));
    await tester.pump();

    // Initially should show loading indicator
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('displays correct version and UI elements', (
    WidgetTester tester,
  ) async {
    // Provide a mock future for PackageInfo
    final mockFuture = Future.value(mockPackageInfo);

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    AboutDialogWidget(packageInfoFuture: mockFuture),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show About'));
    await tester.pumpAndSettle();

    // Verify UI elements
    expect(find.text('About Soundboard'), findsOneWidget);
    expect(find.text('Version: 1.0.0'), findsOneWidget);
    expect(
      find.text(
        'A soundboard application designed for sports events, '
        'specifically targeting Innebandy (Floorball) in Stockholm, Sweden.',
      ),
      findsOneWidget,
    );
    expect(find.text('Visit fbtools.eu'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('close button dismisses dialog', (WidgetTester tester) async {
    // Provide a mock future for PackageInfo
    final mockFuture = Future.value(mockPackageInfo);

    // Build our widget and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) =>
                    AboutDialogWidget(packageInfoFuture: mockFuture),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show About'));
    await tester.pumpAndSettle();

    // Verify dialog is shown
    expect(find.byType(AlertDialog), findsOneWidget);

    // Tap the close button
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Verify dialog is dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('launches URL when visit website button is tapped', (
    WidgetTester tester,
  ) async {
    MockUrlLauncher.mockLaunchUrl = (Uri uri) {
      expect(uri.toString(), equals('https://fbtools.eu'));
      return true;
    };

    final mockFuture = Future.value(mockPackageInfo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AboutDialogWidget(
                  packageInfoFuture: mockFuture,
                  urlLauncher: MockUrlLauncher.launchUrl,
                  debugLogging: false,
                ),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show About'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Visit fbtools.eu'));
    await tester.pumpAndSettle();

    expect(MockUrlLauncher.wasLaunched, isTrue);
    expect(
      MockUrlLauncher.lastLaunchedUri?.toString(),
      equals('https://fbtools.eu'),
    );
  });

  testWidgets('handles URL launch failure gracefully', (
    WidgetTester tester,
  ) async {
    MockUrlLauncher.mockLaunchUrl = (Uri uri) => false;

    final mockFuture = Future.value(mockPackageInfo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AboutDialogWidget(
                  packageInfoFuture: mockFuture,
                  urlLauncher: MockUrlLauncher.launchUrl,
                  debugLogging: false,
                ),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show About'));
    await tester.pumpAndSettle();

    // Should not throw when URL launch fails
    await tester.tap(find.text('Visit fbtools.eu'));
    await tester.pumpAndSettle();

    // Dialog should still be visible
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('shows error when package info fails to load', (
    WidgetTester tester,
  ) async {
    // Create a completer to control the future
    final completer = Completer<PackageInfo>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AboutDialogWidget(
                  packageInfoFuture: completer.future,
                  debugLogging: false,
                ),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.text('Show About'));
    await tester.pump();

    // Should show loading indicator initially
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Complete the future with an error
    completer.completeError('Failed to load');
    await tester.pump();

    // Wait for dialog dismissal
    await tester.pumpAndSettle();

    // Dialog should be dismissed
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('verifies dialog layout and styling', (
    WidgetTester tester,
  ) async {
    final mockFuture = Future.value(mockPackageInfo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AboutDialogWidget(
                  packageInfoFuture: mockFuture,
                  debugLogging: false,
                ),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show About'));
    await tester.pumpAndSettle();

    // Verify dialog structure
    final dialog = tester.widget<AlertDialog>(find.byType(AlertDialog));
    expect(dialog.title, isA<Text>());
    expect(dialog.content, isA<SingleChildScrollView>());
    expect(dialog.actions, hasLength(1));

    // Find the Row widget directly
    final row = tester.widget<Row>(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(Row),
      ),
    );
    expect(row.crossAxisAlignment, equals(CrossAxisAlignment.start));

    // Find the Container and Expanded widgets that are direct children of the Row
    final containerFinder = find.descendant(
      of: find.byType(Row),
      matching: find.byType(Container),
    );
    final expandedFinder = find.descendant(
      of: find.byType(Row),
      matching: find.byType(Expanded),
    );

    // Verify we have exactly one Container and one Expanded
    expect(tester.widgetList(containerFinder), hasLength(1));
    expect(tester.widgetList(expandedFinder), hasLength(1));

    // Verify image container styling
    final imageContainer = tester.widget<Container>(containerFinder);
    expect(
      (imageContainer.decoration as BoxDecoration).borderRadius,
      equals(BorderRadius.circular(8)),
    );
    expect(
      (imageContainer.decoration as BoxDecoration).color,
      equals(Colors.white),
    );

    // Verify content column
    final contentColumn =
        (tester.widget<Expanded>(expandedFinder)).child as Column;
    expect(contentColumn.crossAxisAlignment, equals(CrossAxisAlignment.start));
    expect(contentColumn.mainAxisSize, equals(MainAxisSize.min));
  });

  testWidgets('verifies asset image loading', (WidgetTester tester) async {
    final mockFuture = Future.value(mockPackageInfo);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AboutDialogWidget(
                  packageInfoFuture: mockFuture,
                  debugLogging: false,
                ),
              ),
              child: const Text('Show About'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show About'));
    await tester.pumpAndSettle();

    // Verify image properties
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect(
      (image.image as AssetImage).assetName,
      equals('assets/icon/fbtools.eu.png'),
    );
    expect(image.height, equals(100));
    expect(image.width, equals(100));
  });
}
