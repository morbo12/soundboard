# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0-beta5] - 2025-08-16

### Added

- Manual lineup entry mode, for matches that are not in IBIS
- Full music player and a mini music player (moved to bottom bar)
- Default jingles and jingle assets shipped with the app (includes AI-generated jingles)
- Soundboard Backend API for TTS and AI-powered sentence generation (new AiSentenceService)
- Audio metadata parser to read and surface track metadata
- Support for multi-language models and several experimental TTS voices

### Changed

- Moved/refactored the music player and jingle manager into a cleaner service/UI structure
- Jingle manager and button refactors for improved assignment and playback behavior
- Various UI layout adjustments (volume controller, event card placement, gridsize, colors)
- UI cleanup on settings page and buttons
- Version bump to final release

### Fixed

- Fixed multiple layout and rendering issues (ParentDataWidget misuse, hidden progress bars)
- Fixed audio metadata parsing and related edge-cases
- Updated Deej board output handling and lineup/SSML initialization fixes

### Other

- Added license and music disclaimer related to bundled jingles
- Chore: project cleanup, pub upgrades and test additions

_This release summary is based on commits on branch `feature/0.4.0`._

### Added

- Full music player and a mini music player (moved to bottom bar)
- Default jingles and jingle assets shipped with the app (includes AI-generated jingles)
- Soundboard Backend API for TTS and AI-powered sentence generation (new AiSentenceService)
- Audio metadata parser to read and surface track metadata
- Support for multi-language models and several experimental TTS voices

### Changed

- Moved/refactored the music player and jingle manager into a cleaner service/UI structure
- Jingle manager and button refactors for improved assignment and playback behavior
- Various UI layout adjustments (volume controller, event card placement, gridsize, colors)

### Fixed

- Fixed multiple layout and rendering issues (ParentDataWidget misuse, hidden progress bars)
- Fixed audio metadata parsing and related edge-cases
- Updated Deej board output handling and lineup/SSML initialization fixes

### Other

- Added license and music disclaimer related to bundled jingles
- Chore: project cleanup, pub upgrades and test additions

_This release summary is based on commits on branch `feature/0.4.0`._

## [0.4.0-beta4] - 2025-08-02

### Added

- Soundboard Backend API for TTS and AI Generation
- Requires: Soundboard Backend API
  - AI-powered sports announcement sentence generation using Azure OpenAI (new `AiSentenceService`)
  - Refactored TTS dialog to support AI-generated suggestions and improved player/penalty selection logic
  - Integration of AI-generated suggestions in TTS dialog for event announcements

## [0.4.0-beta3] - 2025-08-02

### Added

- Improved documentation for Deej/volume control system (see updated docs/)
- More unit tests for audio metadata and music player features

### Changed

- Updated volume control documentation and diagrams for clarity and accuracy
- Minor code cleanups and adherence to Flutter style guide

### Fixed

- Improved error handling in AI sentence service and TTS dialog
- Fixed edge cases in music player and audio metadata parsing tests

### Removed

- Deprecated or unused code paths in TTS and volume control logic

_Contains AI-generated edits._

## [0.4.0-beta2] - 2025-04-12

### Added

- VU-meter to visualize levels
- Manual text can be transformed into Speech (TTS)

## [0.4.0-beta1] - 2025-04-12

### Added

- Support for Deej soundboard using serial port, controlling Windows Mixer
- Scratchpad for penalties
- Long pressing lineup and events show the announcment text
- Adjustable grid of buttons
- Buttons can be assigned individual or categorys of jingles
- Clicking on a match shows the current table of the series and other available stats.

### Changes

- Modernized layout
- TTS Settings moved into "settings"
- Code generation by Cursor AI
- New Application Cache dir

### Fixes

- Lots of under-the-hood-updates to enhance layout and performance

### Removed

- TTS Settings screen

## [0.3.15] - 2025-03-30

### Changed

- Dropdown menus update for better visibility
- Update 'Delete cache' logic/visual
- SonarQube scanning

### Added

- update debug code to a logger function

### Fixes

- Lots of cleanup of unused code
- added unit tests
- add Const where appropriate
- Say period event if period score is 0-0

## [0.3.14] - 2025-03-01

### Fixed

- Fix: API Token is now caching properly
- Overlay when creating tts from ssml
- Period table handling corrected
- "Notepad" corrected
- Android windows size corrected.

### Added

- Support flac encoding (Windows, Android)
- Support ogg encoding (Android)
- Button for sequential play of jingle list
- Intermediate scores and ssml for vocies
- "Notepad" to display time, goal, assist and penalty in lineup

### Changed

- Replaced picker due to dependencies
- Selectorbutton now gives correct feedback
- You can select any colorscheme from FlexColorScheme to the app
- minor visual fixes
- Lineup now plays background music for home and away teams
- A new features intro is added
- TTS AudioCodec audio48Khz192kBitrateMonoMp3 -> Webm24Khz16Bit24KbpsMonoOpus
- Scratchpad look and functionality updated
- Random jingles has now a memory of the last 10 jingles to avoid playing the same jingle too often
- Minor adjustments to Lineup data for better visibility
- Playing channels now shows duration clock
- Rearranged buttons
- Flutter version 3.29.0

### Removed

- Unused buttons in settings
- Lineup button in board (moved to lineup section)
- msix module
- cleanup unused code

#### Flutter Pub upgrades

##### Major

- Updated syncfusion_flutter_sliders from 27.1.52 to 28.1.41
- Updated archive from 3.4.9 to 4.0.2
- Updated syncfusion_flutter_core from 27.1.52 to 28.1.41
- Updated \_fe_analyzer_shared from 76.0.0 to 79.0.0
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

## [0.3.14-beta4] - 2025-02-01

### Added

- Lineup now plays background music for home and away teams
- A new features intro is added

### Changed

- TTS AudioCodec audio48Khz192kBitrateMonoMp3 -> Webm24Khz16Bit24KbpsMonoOpus

### Fixed

- Overlay when creating tts from ssml

### Removed

- msix module
- cleanup unused code

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
- Updated \_fe_analyzer_shared from 76.0.0 to 79.0.0
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
