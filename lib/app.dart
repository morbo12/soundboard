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
import 'package:soundboard/features/music_player/presentation/mini_music_player.dart';
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

  Widget _buildNavDestination(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required int selectedIndex,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 20,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          border: Border(
            top: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Row(
              children: [
                // Mini Music Player - minimal space
                Expanded(
                  flex: 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    child: const MiniMusicPlayer(),
                  ),
                ),

                // Vertical divider
                Container(
                  height: 40,
                  width: 1,
                  color: Theme.of(
                    context,
                  ).colorScheme.outline.withValues(alpha: 0.2),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                ),

                // Navigation Controls - most of the space
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavDestination(
                        context,
                        icon: FluentIcons.home_12_regular,
                        selectedIcon: FluentIcons.home_12_filled,
                        label: "Home",
                        index: 0,
                        selectedIndex: selectedIndex,
                        onTap: () =>
                            ref.read(selectedIndexProvider.notifier).state = 0,
                      ),
                      _buildNavDestination(
                        context,
                        icon: FluentIcons.settings_28_regular,
                        selectedIcon: FluentIcons.settings_28_filled,
                        label: "Match",
                        index: 1,
                        selectedIndex: selectedIndex,
                        onTap: () =>
                            ref.read(selectedIndexProvider.notifier).state = 1,
                      ),
                      _buildNavDestination(
                        context,
                        icon: FluentIcons.settings_16_regular,
                        selectedIcon: FluentIcons.settings_16_filled,
                        label: "Settings",
                        index: 2,
                        selectedIndex: selectedIndex,
                        onTap: () =>
                            ref.read(selectedIndexProvider.notifier).state = 2,
                      ),
                      _buildNavDestination(
                        context,
                        icon: FluentIcons.music_note_2_16_regular,
                        selectedIcon: FluentIcons.music_note_2_16_filled,
                        label: "Spotify",
                        index: 3,
                        selectedIndex: selectedIndex,
                        onTap: launchSpotify,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Contains AI-generated edits.
