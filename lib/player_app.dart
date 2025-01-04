import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/jingle_manager/application/class_jingle_manager.dart';
import 'package:soundboard/features/screen_home/presentation/classes/class_camera_widget.dart';
import 'package:soundboard/features/screen_tts_settings/presentation/screen_settings_tts.dart';
import 'package:soundboard/properties.dart';
import 'package:soundboard/features/screen_home/presentation/home_screen.dart';
import 'package:soundboard/features/screen_match/presentation/screen_matchsetup.dart';
import 'package:soundboard/features/screen_settings/presentation/screen_settings.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class Player extends ConsumerStatefulWidget {
  const Player({super.key});

  @override
  ConsumerState<Player> createState() => _PlayerState();
}

class _PlayerState extends ConsumerState<Player> {
  // ignore: unused_field
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
    installerStore: 'Unknown',
  );
  bool isJingleManagerInitialized = false;

  void launchSpotify() async {
    final Uri url = Uri.parse(SettingsBox().spotifyUri);
    await launchUrl(url);
  }

  @override
  void initState() {
    _initPackageInfo();
    // jingleManager = JingleManager(context);
    // jingleManager.audioManager.setRef(ref);
    _initJingleManager();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initJingleManager() async {
    jingleManager = JingleManager(showMessageCallback: showMessage);
    await jingleManager.initialize();
    jingleManager.audioManager.setRef(ref);
    setState(() {
      // Set the flag to indicate that JingleManager is initialized
      isJingleManagerInitialized = true;
    });
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void showMessage({required String message, required MsgType type}) {
    FlutterToastr.show(message, context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor: type == MsgType.error ? Colors.red : Colors.green,
        textStyle: const TextStyle(color: Colors.white));
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    return Scaffold(
      body: isJingleManagerInitialized
          ? Stack(
              children: [
                IndexedStack(
                  index: selectedIndex,
                  children: const [
                    HomeScreen(),
                    MatchSetupScreen(),
                    SettingsScreen(),
                    SettingsTtsScreen(),
                  ],
                ),
                // if (selectedIndex == 0 &&
                //     Platform.isWindows) // Only show on Home screen on Windows
                //   FloatingCameraWindow(),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
      appBar: AppBar(
          toolbarHeight: DefaultConstants().appBarHeight,
          elevation: 2,
          title: Text(
            'Game Soundboard ${_packageInfo.version}',
            style: const TextStyle(fontSize: 12),
          )),
      bottomNavigationBar: BottomNavigationBar(
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 2,
          currentIndex: selectedIndex,
          onTap: (index) {
            if (index == 4) {
              launchSpotify();
            } else {
              ref.read(selectedIndexProvider.notifier).state = index;
            }
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white54,
          type: BottomNavigationBarType.shifting,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.home_12_filled),
                activeIcon: Icon(FluentIcons.home_12_filled),
                label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.settings_28_regular),
                activeIcon: Icon(FluentIcons.settings_16_filled),
                label: "Match"),
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.settings_16_regular),
                activeIcon: Icon(FluentIcons.settings_16_filled),
                label: "Settings"),
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.settings_16_regular),
                activeIcon: Icon(FluentIcons.settings_16_filled),
                label: "TTS Settings"),
            BottomNavigationBarItem(
                icon: Icon(FluentIcons.music_note_2_16_regular),
                activeIcon: Icon(FluentIcons.music_note_2_16_filled),
                label: "Spotify"),
          ]),
    );
  }
}
