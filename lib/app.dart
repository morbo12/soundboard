import 'dart:async';

import 'package:animated_introduction/animated_introduction.dart';
import 'package:soundboard/about/widgets/about_dialog.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_toastr/flutter_toastr.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soundboard/core/constants/message_types.dart';
import 'package:soundboard/core/services/jingle_manager/jingle_manager_provider.dart';
import 'package:soundboard/core/utils/logger.dart';
import 'package:soundboard/features/screen_match/presentation/widgets/match_setup_screen.dart';
import 'package:soundboard/core/properties.dart';
import 'package:soundboard/features/screen_home/presentation/home_screen.dart';
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
  static const _logger = Logger('Player');

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
      // Only show error message if we're past the loading phase to prevent snackbar flashing
      if (mounted && !_isLoading) {
        showMessage(
          message: 'Error initializing app: ${e.toString()}',
          type: MessageType.error,
        );
      } else {
        _logger.e('App initialization error during startup', e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _initJingleManager() async {
    // The JingleManager provider will initialize automatically when first accessed
    // We just need to wait for it to complete initialization
    try {
      final jingleManagerAsync = ref.read(jingleManagerProvider);
      await jingleManagerAsync.when(
        data: (jingleManager) async {
          if (mounted) {
            setState(() {
              isJingleManagerInitialized = true;
            });
          }
        },
        loading: () async {
          // Wait for the provider to finish loading by polling
          while (mounted) {
            await Future.delayed(const Duration(milliseconds: 100));
            final currentState = ref.read(jingleManagerProvider);
            if (currentState is AsyncData) {
              if (mounted) {
                setState(() {
                  isJingleManagerInitialized = true;
                });
              }
              break;
            } else if (currentState is AsyncError) {
              throw currentState.error ??
                  Exception('Unknown JingleManager error');
            }
          }
        },
        error: (error, stackTrace) async {
          // Log error but don't show toast during initialization to prevent flashing
          _logger.e('JingleManager initialization failed', error, stackTrace);
          throw Exception('Failed to initialize JingleManager: $error');
        },
      );
    } catch (e) {
      // Only show error message if we're past the loading phase
      if (mounted && !_isLoading) {
        showMessage(
          message: 'Failed to initialize audio system: ${e.toString()}',
          type: MessageType.error,
        );
      } else {
        _logger.e('JingleManager initialization error during app startup', e);
      }
      rethrow;
    }
  }

  Future<void> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  void showMessage({required String message, required MessageType type}) {
    // Only show message if context is available and mounted
    if (mounted && context.mounted) {
      FlutterToastr.show(
        message,
        context,
        duration: FlutterToastr.lengthLong,
        position: FlutterToastr.bottom,
        backgroundColor: type == MessageType.error ? Colors.red : Colors.green,
        textStyle: const TextStyle(color: Colors.white),
      );
    } else {
      // Fallback to console logging if UI context is not available
      _logger.i('Message [${type.name}]: $message');
    }
  }

  Widget _buildMainContent(int currentIndex) {
    return Stack(
      children: [
        IndexedStack(
          index: currentIndex,
          children: const [HomeScreen(), MatchSetupScreen(), SettingsScreen()],
        ),
      ],
    );
  }

  Future<void> _loadIntroState() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _isIntroCompleted = prefs.getBool(_introCompletedKey) ?? false;
      });
    }
  }

  Future<void> _setIntroCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introCompletedKey, true);
    if (mounted) {
      setState(() {
        _isIntroCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(selectedIndexProvider);
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(strokeCap: StrokeCap.round),
          ),
        ),
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
          _setIntroCompleted();
        },
      );
    }
    return Scaffold(
      body: isJingleManagerInitialized
          ? _buildMainContent(selectedIndex)
          : const Center(
              child: CircularProgressIndicator(strokeCap: StrokeCap.round),
            ),
      appBar: AppBar(
        toolbarHeight: 20.0,
        title: InkWell(
          onTap: () {
            showDialog(
              context: context,
              useSafeArea: true,
              barrierDismissible: true,
              builder: (context) => const AboutDialogWidget(),
            );
          },
          child: Text(
            'FBTools Soundboard ${_packageInfo.version}',
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        labelTextStyle: WidgetStateProperty.all(const TextStyle(fontSize: 10)),
        height: 65,
        elevation: 0,
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          if (index == 3) {
            launchSpotify();
          } else {
            ref.read(selectedIndexProvider.notifier).state = index;
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(FluentIcons.home_12_regular),
            selectedIcon: Icon(FluentIcons.home_12_filled), // M3 selected state

            label: "Home",
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.settings_28_regular),
            selectedIcon: Icon(
              FluentIcons.settings_28_filled,
            ), // M3 selected state

            label: "Match",
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.settings_16_regular),
            selectedIcon: Icon(
              FluentIcons.settings_16_filled,
            ), // M3 selected state

            label: "Settings",
          ),
          NavigationDestination(
            icon: Icon(FluentIcons.music_note_2_16_regular),
            selectedIcon: Icon(
              FluentIcons.music_note_2_16_filled,
            ), // M3 selected state

            label: "Spotify",
          ),
        ],
      ),
    );
  }
}

// Contains AI-generated edits.
