import 'dart:async';

import 'package:animated_introduction/animated_introduction.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundboard/constants/default_constants.dart';
import 'package:soundboard/constants/globals.dart';
import 'package:soundboard/features/jingle_manager/application/class_jingle_manager.dart';
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
  bool _isIntroCompleted = false;
  static const String _introCompletedKey = 'intro_completed';
  bool _isLoading = true;
  final List<SingleIntroScreen> pages = [
    const SingleIntroScreen(
      title: 'Ny features #1',
      description:
          'Lineup är flyttad upp till höger\nPeriodstatistik visas och är klickbar för att spela upp ljud i högtalarna',
      imageAsset: 'assets/intros/intro1.png',
    ),
    const SingleIntroScreen(
      title: 'Ny feature #2 - scratchpad',
      description:
          "Här kan man skriva ner domarens information vid mål, berörda spelare higlightas i lineup",
      imageAsset: 'assets/intros/intro2.png',
    ),
  ];
  void launchSpotify() async {
    final Uri url = Uri.parse(SettingsBox().spotifyUri);
    await launchUrl(url);
  }

  @override
  void initState() {
    // _initPackageInfo();
    // jingleManager = JingleManager(context);
    // jingleManager.audioManager.setRef(ref);
    // _initJingleManager();
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      await Future.wait([
        _initPackageInfo(),
        _loadIntroState(),
        _initJingleManager(),
      ]);
    } catch (e) {
      showMessage(
        message: 'Error initializing app: ${e.toString()}',
        type: MsgType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _initJingleManager() async {
    try {
      jingleManager = JingleManager(showMessageCallback: showMessage);
      await jingleManager.initialize();
      setState(() {
        isJingleManagerInitialized = true;
      });
    } catch (e) {
      showMessage(
        message: 'Failed to initialize audio system: ${e.toString()}',
        type: MsgType.error,
      );
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  void showMessage({required String message, required MsgType type}) {
    FlutterToastr.show(
      message,
      context,
      duration: FlutterToastr.lengthLong,
      position: FlutterToastr.bottom,
      backgroundColor: type == MsgType.error ? Colors.red : Colors.green,
      textStyle: const TextStyle(color: Colors.white),
    );
  }

  Widget _buildMainContent(int currentIndex) {
    return Stack(
      children: [
        IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(),
            MatchSetupScreen(),
            SettingsScreen(),
            SettingsTtsScreen(),
          ],
        ),
      ],
    );
  }

  Future<void> _loadIntroState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isIntroCompleted = prefs.getBool(_introCompletedKey) ?? false;
    });
  }

  Future<void> _setIntroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introCompletedKey, true);
    setState(() {
      _isIntroCompleted = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    // If intro is not completed, show intro screens
    if (!_isIntroCompleted) {
      return AnimatedIntroduction(
        doneText: "Done",
        slides: pages,
        containerBg: Theme.of(context).colorScheme.surface,
        footerBgColor: Theme.of(context).colorScheme.primaryContainer,
        textColor: Theme.of(context).colorScheme.onPrimaryContainer,
        activeDotColor: Theme.of(context).colorScheme.onPrimaryContainer,
        inactiveDotColor: Theme.of(context).colorScheme.onPrimaryFixed,
        indicatorType: IndicatorType.circle,
        onDone: () {
          setState(() {
            _setIntroCompleted();
          });
        },
      );
    }
    return Scaffold(
      body:
          isJingleManagerInitialized
              ? _buildMainContent(selectedIndex)
              : const Center(child: CircularProgressIndicator()),
      appBar: AppBar(
        toolbarHeight: DefaultConstants().appBarHeight,
        elevation: 2,
        title: Text(
          'Game Soundboard ${_packageInfo.version}',
          style: const TextStyle(fontSize: 12),
        ),
      ),
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
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.settings_28_regular),
            activeIcon: Icon(FluentIcons.settings_16_filled),
            label: "Match",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.settings_16_regular),
            activeIcon: Icon(FluentIcons.settings_16_filled),
            label: "Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.settings_16_regular),
            activeIcon: Icon(FluentIcons.settings_16_filled),
            label: "TTS Settings",
          ),
          BottomNavigationBarItem(
            icon: Icon(FluentIcons.music_note_2_16_regular),
            activeIcon: Icon(FluentIcons.music_note_2_16_filled),
            label: "Spotify",
          ),
        ],
      ),
    );
  }
}
