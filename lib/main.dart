// Local Imports
import 'dart:io';

import 'package:cloud_text_to_speech/cloud_text_to_speech.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:soundboard/features/cloud_text_to_speech/class_azure_region.dart';
import 'package:soundboard/features/cloud_text_to_speech/providers.dart';
import 'package:soundboard/features/scrolling/presentation/scroll_config.dart';
import 'package:soundboard/properties.dart'; // Local file for handling soundboard properties.
import 'package:soundboard/player_app.dart'; // Local main app file.

// External Imports (sorted by package name length, shortest first)
import 'package:easy_hive/easy_hive.dart'; // Package for easy integration of Hive, a lightweight and fast NoSQL database.
import 'package:permission_handler/permission_handler.dart'; // Package for handling permissions in Flutter apps.

// Flutter Imports
import 'package:flutter/material.dart';
import 'package:soundboard/theme_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  Directory settingsDir = await getApplicationSupportDirectory();
  if (kDebugMode) {
    print("AppSupportDir: ${settingsDir.path} ");
  }

  await EasyBox.initialize(subDir: settingsDir.path);
  await SettingsBox().init();

  void checkAndResetCount() {
    DateTime now = DateTime.now();
    DateTime lastDate =
        SettingsBox().azCharCountLastDate; // Assuming this is a DateTime
    DateTime firstOfThisMonth = DateTime(now.year, now.month, 1);

    // If last reset was before the first of this month, reset the count
    if (lastDate.isBefore(firstOfThisMonth)) {
      SettingsBox().azCharCount = 0;
      SettingsBox().azCharCountLastDate = now; // Updating the last reset to now
      // Save changes in SettingsBox if necessary
      if (kDebugMode) {
        print("Resetting count to 0");
      }
    }
  }

  checkAndResetCount();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('sv')],
      path:
          'assets/translations', // <-- change the path of the translation files
      fallbackLocale: const Locale('sv'),
      useOnlyLangCode: true,
      child: const ProviderScope(
        child: SoundBoard(),
      ),
    ),
  );
}

class SoundBoard extends ConsumerStatefulWidget {
  const SoundBoard({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SoundBoardState createState() => _SoundBoardState();
}

class _SoundBoardState extends ConsumerState<SoundBoard> {
  @override
  initState() {
    super.initState();
    checkPermissions();

    final microsoftParams = InitParamsMicrosoft(
        subscriptionKey: SettingsBox().azTtsKey,
        region: AzureRegionManager().getAzRegionName(SettingsBox().azRegionId));
    final textToSpeechService = ref.read(textToSpeechServiceProvider);

    textToSpeechService.initialize(microsoftParams: microsoftParams);
  }

  @override
  void dispose() {
    // _subscription.cancel();
    // _durationSubscription.cancel();
    // _positionSubscription.cancel();
    super.dispose();
  }

  void checkPermissions() async {
    var status = await Permission.storage.status;

    if (status.isGranted) {
    } else if (status.isDenied) {
      // ignore: unused_local_variable
      Map<Permission, PermissionStatus> status = await [
        Permission.storage,
        // Permission.manageExternalStorage,
        Permission.accessMediaLocation
      ].request();
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Implement restart app
    // final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    // final restartAppProvider = Provider<void Function()>((ref) {
    //   return () {
    //     navigatorKey.currentState?.pushReplacement(
    //       MaterialPageRoute(
    //         builder: (BuildContext context) =>
    //             const Player(), // MyApp is your root widget
    //       ),
    //     );
    //   };
    // });

    return MaterialApp(
      // TODO: Implement restart app
      // navigatorKey: navigatorKey,
      builder: (contex, child) {
        return ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: child!,
        );
      },
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      // darkTheme: FlexThemeData.dark(scheme: FlexScheme.mandyRed),
      // vesuviusBurn
      darkTheme: AppTheme.darkTheme(ref),
      theme: AppTheme.lightTheme(ref),
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,

      home: Player(),
    );
  }
}