import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soundboard/core/utils/app_localizations.dart';

class _TestApp extends StatelessWidget {
  const _TestApp({required this.locale});

  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', 'US'), Locale('sv', 'SE')],
      home: Builder(
        builder: (context) {
          final l10n = context.l10n;
          return Scaffold(
            body: Center(
              child: Text(
                l10n.translate('nav.home'),
                key: const ValueKey('nav_home'),
              ),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Language switching updates UI', (tester) async {
    await tester.pumpWidget(const _TestApp(locale: Locale('en', 'US')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('nav_home')), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    await tester.pumpWidget(const _TestApp(locale: Locale('sv', 'SE')));
    await tester.pumpAndSettle();

    expect(find.text('Hem'), findsOneWidget);
  });
}
