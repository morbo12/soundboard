# Soundboard: A speaker/DJ helper app

<p align="center">
  <a href="https://www.fbtools.eu/">
    <img src="https://www.fbtools.eu/_next/image?url=%2Ffbtools.eu.png&w=384&q=75" alt="FB Tools Logo" width="200"/>
  </a>
  <br/>
  <a href="https://www.fbtools.eu/">Visit FB Tools Website</a>
</p>

## Overview

Soundboard is a professional audio management application designed to enhance the experience of sports events, particularly Floorball matches in Stockholm, Sweden. It provides a comprehensive solution for managing audio playback, announcements, and live event reporting during matches.

## Features

### Core Features (All Platforms)

- **Main Soundboard**: Play and manage audio clips with ease
- **Text-to-Speech (TTS)**: Automated announcements for game events
- **Theme Support**: Customize the app's appearance
- **Multi-channel Audio Management**: Control different audio sources independently

### Windows-specific Features

- **Lineup Management**: Handle team lineups and player information
- **Live Events**: Real-time event reporting and display
- **Hardware Volume Mixer**: Physical control over audio levels using Deej protocol

## System Requirements

### Windows

- Windows 10 or later
- Latest Visual C++ Redistributable (see [Prerequisites](#prerequisites))

### Android

- Android 8.0 or later

## Installation

### Windows

1. Download the latest release from the [Releases page](https://github.com/morbo12/Soundboard/releases/latest)
2. Unzip the package in folder of choice
3. Install the required Visual C++ Redistributable if needed.

### Android

1. Download the APK from the [Releases page](https://github.com/morbo12/Soundboard/releases/latest)
2. Enable "Install from Unknown Sources" in your device settings
3. Install the APK
4. Grant necessary permissions when prompted

## Prerequisites

- **Visual C++ Redistributable**: Required for Windows users. Download from [Microsoft's official page](https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#visual-studio-2015-2017-2019-and-2022)
- **Azure Speech Service**: Required for TTS functionality. You'll need to:
  1. Create an Azure account (Azure provides 500k chars for free per month)
  2. Set up a Speech Service resource
  3. Configure your API key in the app settings

## Getting Started

1. Launch the application
2. Configure your audio devices in Settings
3. Set up your Azure Speech Service credentials if using TTS
4. Import your audio files (jingles, sound effects, etc.)
5. Configure the hardware mixer if using one (see [Hardware Volume Mixer](#hardware-volume-mixer-deej))

## Limitations

- No plans exists to build for any Apple device.
- TTS requires an Azure Speech Service, which you need to provide yourself
- No jingles included

## Hardware Volume Mixer (Deej)

Soundboard now supports hardware volume mixers following the Deej protocol. This allows you to control
various volume levels using physical sliders.

### Setup

1. Build a Deej mixer following instructions at [Deej GitHub repository](https://github.com/omriharel/deej)
2. Connect your Arduino to your computer via USB
3. In Soundboard, go to Settings and configure your serial port settings:
   - Select the correct COM port
   - Set baud rate to match your Arduino sketch (default: 9600)
   - Configure other serial port parameters if needed
   - Enable "Auto Connect" to automatically connect at startup

### Slider Mapping

You need to map your sliders to a process or master.

---

### ⬇️ Downloads

Soundboard: [stable](https://github.com/morbo12/Soundboard/releases/latest)

---

### Thanks to

- ChatGPT, Claude
- Cursor AI ⭐⭐⭐⭐⭐
- GitHub for providing the runners to build new images.

---

### How can I help?

Do you love this project? All kinds of contributions are welcome 🙌!

- ⭐️ star the project
- raise 🐞 issues
- 💰 donations.

<p align="center">
  <a href="https://buymeacoffee.com/morbo12"><img src="https://img.shields.io/badge/Donate-BuyMeACoffee-blue.svg" alt="Donate with Buy me a coffee" /></a>
</p>

## Contributing

We welcome contributions! Here's how you can help:

1. ⭐️ Star the project
2. 🐞 Report bugs or suggest features
3. 💰 Support development through donations
4. 📝 Improve documentation
5. 🔧 Submit pull requests

For developers:

- Fork the repository
- Create a feature branch
- Make your changes
- Submit a pull request
- Ensure all tests pass
- Update documentation as needed
