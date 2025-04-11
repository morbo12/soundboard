# Soundboard: A speaker/DJ helper app 

## Soundboard

Soundboard was written to support our "sekretariat" to play jingles during a match. It is explicitly targeting Innebandy (Floorball) in Stockholm, Sweden

Several extensions has been developed with the help of AI
- TTS (Text To Speech) - events that happens during the game can be read and played on the sound system, no need for a speaker person
- Display live reports of events during the game

The app is built primarily to Windows but is also build and tested on Android Phones. 

Features on both platforms
- Main soundboard
- TextToSpeech
- Theme changer

Features on Windows platform
- Lineups
- Live Events
- Hardware volume mixer support (Deej)

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
The volume sliders are mapped as follows:
- Slider 1: Main system volume
- Slider 2: Spotify volume
- Slider 3: Soundboard volume
- Slider 4: Jingle Palette volume
- Slider 5: Channel 1 volume
- Slider 6: Channel 2 volume

## Pre-req
Windows 10 needs a VC Redist update to run this program. 
Here is the lastest ones
https://learn.microsoft.com/en-us/cpp/windows/latest-supported-vc-redist?view=msvc-170#visual-studio-2015-2017-2019-and-2022

---------------------

### ⬇️ Downloads

Soundboard: [stable](https://github.com/morbo12/Soundboard/releases/latest)

---------------------
### Thanks to
- ChatGPT, Claude
- GitHub for providing the runners to build new images.

---------------------
### How can I help?
Do you love this project? All kinds of contributions are welcome 🙌!
 * ⭐️ star the project
 * raise 🐞 issues 
 * 💰 donations.

<p align="center">
  <a href="https://buymeacoffee.com/morbo12">Donate using By Me a Coffee</a>
</p>
