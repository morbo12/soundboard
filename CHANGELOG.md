# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
## [0.3.14-beta3] - 2025-02-01

### Changed
- Scratchpad look and functionality updated
- Random jingles has now a memory of the last 10 jingles to avoid playing the same jingle too often
- Minor adjustments to Lineup data for better visibility
- Playing channels now shows duration clock

### Fixed
- Fix: API Token is now caching properly

## [0.3.14-beta2] - 2025-01-25

### Added
- Button for sequential play of jingle list
- Intermediate scores and ssml for vocies
- "Notepad" to display time, goal, assist and penalty in lineup
### Changed
- Rearranged buttons
- Flutter version 3.27.3
#### Flutter Pub upgrades
##### Major
- Updated syncfusion_flutter_sliders from 27.1.52 to 28.1.41
- Updated archive from 3.4.9 to 4.0.2
- Updated syncfusion_flutter_core from 27.1.52 to 28.1.41
- Updated _fe_analyzer_shared from 76.0.0 to 79.0.0
- Updated analyzer from 6.11.0 to 7.2.0
##### Minor
- Updated build from 2.4.1 to 2.4.2
- Updated build_config from 1.1.1 to 1.1.2
- Updated build_daemon from 4.0.2 to 4.0.3
- Updated build_resolvers from 2.4.2 to 2.4.3
- Updated build_runner from 2.4.13 to 2.4.14
- Updated build_runner_core from 7.3.2 to 8.0.0
- Updated camera from 0.11.0+2 to 0.11.1
- Updated camera_android_camerax from 0.6.10+3 to 0.6.13
- Updated camera_avfoundation from 0.9.17+5 to 0.9.18+1
- Updated camera_platform_interface from 2.8.0 to 2.9.0
- Updated dart_style from 2.3.7 to 3.0.1
- Updated file_picker from 8.1.6 to 8.1.7
- Updated flex_color_scheme from 8.0.2 to 8.1.0
- Updated flex_seed_scheme from 3.4.1 to 3.5.0
- Updated fluentui_system_icons from 1.1.270 to 1.1.271
- Updated flutter_launcher_icons from 0.14.2 to 0.14.3
- Updated glob from 2.1.2 to 2.1.3
- Updated http from 1.2.2 to 1.3.0
- Updated http_parser from 4.0.2 to 4.1.2
- Updated package_info_plus from 8.1.2 to 8.1.3
- Updated pubspec_parse from 1.4.0 to 1.5.0
- Updated shared_preferences from 2.3.4 to 2.4.0
- Updated shared_preferences_android from 2.4.0 to 2.4.3
- Updated shelf from 1.4.1 to 1.4.2
- Updated stream_channel from 2.1.3 to 2.1.4
- Updated url_launcher_web from 2.3.3 to 2.4.0
- Updated url_launcher_windows from 3.1.3 to 3.1.4
- Updated web_socket_channel from 3.0.1 to 3.0.2
- Updated win32 from 5.9.0 to 5.10.0

### Removed
- Lineup button in board (moved to lineup section)

## [0.3.14-beta1] - 2024-12-23

### Added
- Support flac encoding (Windows, Android)
- Support ogg encoding (Android)

### Removed
- Unused buttons in settings

## [0.3.13] - 2024-12-21
- Fix: Update list of venues in Stockholm
- Fix: Lineup is now displayed automatically
- Update: flutter pub update

## [0.3.12] - 2024-12-07

### Added
- BREAKING CHANGE: Update build system to Visual Studio Community 2022
    - requires vc_redist version > 14
    - Windows 11: OK
    - Windows 10: Update the VC redist package https://aka.ms/vs/17/release/vc_redist.x64.exe	
- Clickable lineup
- Move to zip release
- pipeline build
- automatic release
- Add current time for internal display
- Changelog entered into CHANGELOG.md

### Changed
- adjusted lineup size


## [0.3.12-beta4] - 2024-11-23

### Added
- BREAKING CHANGE: Update build system to Visual Studio Community 2022
    - requires vc_redist version > 14
    - Windows 11: OK
    - Windows 10: Update the VC redist package https://aka.ms/vs/17/release/vc_redist.x64.exe	
- Clickable lineup
- Move to zip release
- pipeline build
- automatic release
- Add current time for internal display
- Changelog entered into CHANGELOG.md

### Changed
- adjusted lineup size

## [0.3.11] - 2024-11-08

### Added
- Theme Changer

### Changed
- bump pubspec versions
- Lineup remodeled

### Removed
- Volume control to master volume
