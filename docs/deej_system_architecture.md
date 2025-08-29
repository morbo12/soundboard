# Deej System Architecture - Complete Flow Visualization

## Overview

The Deej system creates a bridge between physical hardware sliders and both Windows audio processes and the Flutter app's internal AudioPlayer channels.

## 1. Hardware Layer - Deej Board

```
Physical Deej Board
┌─────────────────────────────────────┐
│  Slider 0  │  Slider 1  │  Slider 2  │  Slider 3  │
│     ║      │     ║      │     ║      │     ║      │
│    ╫╫╫     │    ╫╫╫     │    ╫╫╫     │    ╫╫╫     │
│   ╫╫╫╫╫    │   ╫╫╫╫╫    │   ╫╫╫╫╫    │   ╫╫╫╫╫    │
│  ╫╫╫╫╫╫╫   │  ╫╫╫╫╫╫╫   │  ╫╫╫╫╫╫╫   │  ╫╫╫╫╫╫╫   │
│ ╫╫╫╫╫╫╫╫╫  │ ╫╫╫╫╫╫╫╫╫  │ ╫╫╫╫╫╫╫╫╫  │ ╫╫╫╫╫╫╫╫╫  │
│╫╫╫╫╫╫╫╫╫╫╫ │╫╫╫╫╫╫╫╫╫╫╫ │╫╫╫╫╫╫╫╫╫╫╫ │╫╫╫╫╫╫╫╫╫╫╫ │
└─────────────────────────────────────┘
       │           │           │           │
       ▼           ▼           ▼           ▼
   [0.0-1.0]   [0.0-1.0]   [0.0-1.0]   [0.0-1.0]
```

## 2. Mapping Configuration Layer

```
Deej Board Sliders → Configurable Targets
┌──────────────┬─────────────────────────────────────┐
│ Deej Slider  │ Can Map To                          │
├──────────────┼─────────────────────────────────────┤
│ Slider 0     │ → UI Master, Slider 1-3, C1, C2    │
│ Slider 1     │ → UI Master, Slider 1-3, C1, C2    │
│ Slider 2     │ → UI Master, Slider 1-3, C1, C2    │
│ Slider 3     │ → UI Master, Slider 1-3, C1, C2    │
└──────────────┴─────────────────────────────────────┘

Target Types:
• Master/Slider 1-3: Control Windows audio processes
• C1/C2: Control AudioPlayer channels directly
```

## 3. Data Flow Architecture

### A. Deej Connection & Volume Updates

```
Deej Hardware
      ║
      ▼
┌─────────────────┐
│ Deej Service    │ ← Reads hardware values via serial/USB
│ (External)      │
└─────────────────┘
      ║
      ▼ HTTP/WebSocket
┌─────────────────┐
│ DeejService     │ ← receives volume updates
│ (Flutter)       │
└─────────────────┘
      ║
      ▼ Updates providers
┌─────────────────┐
│ Volume          │ ← mainVolumeProvider, p1VolumeProvider, etc.
│ Providers       │   c1VolumeProvider, c2VolumeProvider
└─────────────────┘
```

### B. Dual Control Paths

```
                    ┌─ Windows Audio Processes ─┐
                    │                           │
UI Sliders ────┬────▶ SystemVolumeManager ────▶ chrome.exe, discord.exe, etc.
               │    │                           │
               │    └───────────────────────────┘
               │
               │    ┌─ AudioPlayer Channels ──┐
               │    │                         │
               └────▶ VolumeControlService ───▶ AudioManager
                    │                         │  ├─ Channel1 (AudioPlayer)
                    │                         │  └─ Channel2 (AudioPlayer)
                    └─────────────────────────┘

Deej Hardware ─┬────▶ SystemVolumeManager ────▶ Windows Audio (when mapped)
               │
               └────▶ VolumeControlService ───▶ AudioManager (when mapped to C1/C2)
```

## 4. Control Logic Flow

### A. For Windows Audio Processes (Master, Slider 1-3)

```
Deej Slider Movement
       ║
       ▼
DeejService detects change
       ║
       ▼
Updates corresponding provider
       ║
       ▼
VolumeControlService._updateSystemVolume()
       ║
       ▼
SystemVolumeManager sets Windows process volume
       ║
       ▼
Physical audio output changes
```

### B. For AudioPlayer Channels (C1, C2)

```
Deej Slider Movement
       ║
       ▼
DeejService detects change
       ║
       ▼
Updates c1VolumeProvider or c2VolumeProvider
       ║
       ▼
VolumeControlService._updateAudioPlayerChannel()
       ║
       ▼ (only if Deej connected)
Provider state updated, AudioPlayer volume NOT changed
       ║
       ▼
AudioManager reads provider state for target volume
       ║
       ▼
AudioManager._getCurrentTargetVolume() returns provider value
       ║
       ▼
AudioManager sets AudioPlayer.setVolume() directly
```

## 5. Volume Control Separation Logic

### A. When Deej is Connected

```
For Windows Processes:
UI Slider → VolumeControlService → SystemVolumeManager → Windows Audio
Deej Slider → DeejService → Provider → SystemVolumeManager → Windows Audio

For AudioPlayer Channels:
UI Slider → VolumeControlService → Provider Update Only (no AudioPlayer change)
Deej Slider → DeejService → Provider → AudioManager reads provider → AudioPlayer.setVolume()
```

### B. When Deej is Disconnected

```
For Windows Processes:
UI Slider → VolumeControlService → SystemVolumeManager → Windows Audio

For AudioPlayer Channels:
UI Slider → VolumeControlService → AudioManager → AudioPlayer.setVolume()
```

## 6. Component Responsibilities

### VolumeControlService

```
┌─────────────────────────────────────┐
│ VolumeControlService                │
├─────────────────────────────────────┤
│ • updateVolume()                    │
│   ├─ Check if Deej connected        │
│   ├─ Route to appropriate handler   │
│   └─ Prevent conflicts              │
│                                     │
│ • _updateSystemVolume()             │
│   └─ Always updates system volumes  │
│                                     │
│ • _updateAudioPlayerChannel()       │
│   ├─ If Deej connected: provider    │
│   │   update only                   │
│   └─ If disconnected: direct        │
│       AudioPlayer control           │
└─────────────────────────────────────┘
```

### AudioManager

```
┌─────────────────────────────────────┐
│ AudioManager                        │
├─────────────────────────────────────┤
│ • _getCurrentTargetVolume()         │
│   ├─ Check if channel mapped        │
│   ├─ If mapped: read provider       │
│   └─ If not mapped: return 1.0      │
│                                     │
│ • _setChannelVolume()               │
│   ├─ Always set AudioPlayer volume  │
│   └─ Update provider only if not    │
│       Deej-mapped                   │
│                                     │
│ • _playAudioFile()                  │
│   ├─ Get target volume              │
│   ├─ Set initial volume             │
│   └─ Handle fade-in if needed       │
└─────────────────────────────────────┘
```

## 7. State Synchronization

### Provider State Flow

```
┌─ Deej Updates ─┐    ┌─ UI Updates ─┐
│                │    │              │
▼                │    ▼              │
Volume Provider  │    Volume Provider │
    ║            │        ║          │
    ▼            │        ▼          │
┌─ Deej Mapped ─┐│    ┌─ Not Mapped ─┐│
│ AudioManager  ││    │ Direct       ││
│ reads provider││    │ AudioPlayer  ││
│ for target    ││    │ control      ││
│ volume        ││    │              ││
└───────────────┘│    └──────────────┘│
                 │                   │
                 └───────────────────┘
```

## 8. Configuration Management

### Mapping Storage

```
VolumeSystemConfig:
  deejMappings: [
    DeejHardwareMapping(
      deejSliderIdx: 0,         // Physical slider on Deej board
      target: DeejTarget.master, // What it controls
      processName: null,        // Not needed for non-process targets
    ),
    DeejHardwareMapping(
      deejSliderIdx: 1,
      target: DeejTarget.externalProcess,
      processName: "chrome",    // Required for external process
    ),
    DeejHardwareMapping(
      deejSliderIdx: 2,
      target: DeejTarget.audioPlayerC1,  // Controls AudioPlayer Channel 1
      processName: null,        // Not needed for AudioPlayer
    ),
    // ... more mappings
  ]
```

### Modern Configuration vs Legacy

The system now supports two configuration approaches:

#### Current: VolumeSystemConfig (Recommended)

- Uses `DeejTarget` enum for type safety
- Supports AudioPlayer channels directly
- Clear separation between Windows processes and AudioPlayer
- Used by `VolumeControlServiceV2`

#### Legacy: SliderMapping (Deprecated)

- Integer-based UI slider mapping
- AudioPlayer channels handled as special UI sliders (4, 5)
- Less type-safe
- Used by deprecated service

### UI Configuration Flow

```
VolumeSystemConfigWidget
       ║
       ▼
User selects Deej slider and target
       ║
       ▼ AudioPlayer channels
┌─────────────────────────┐
│ target = audioPlayerC1  │ ← Direct AudioPlayer C1 control
│ target = audioPlayerC2  │ ← Direct AudioPlayer C2 control
│ processName = null      │ ← No Windows process needed
└─────────────────────────┘
       ║
       ▼ Windows processes
┌─────────────────────────┐
│ target = externalProcess│ ← Windows process control
│ processName = "chrome"  │ ← Process name required
└─────────────────────────┘
       ║
       ▼ Master volume
┌─────────────────────────┐
│ target = master         │ ← Windows master volume
│ processName = null      │ ← No process needed
└─────────────────────────┘
```

## 9. Error Handling & Edge Cases

### Volume Restoration Logic

```
Audio Stops
    ║
    ▼
AudioManager checks if Deej-mapped
    ║
    ├─ If Deej-mapped: Keep current volume (don't fade to 0)
    └─ If not mapped: Fade to 0 for clean stop
```

### Initialization Sequence

```
App Start
    ║
    ▼
Configure providers with saved volumes
    ║
    ▼
AudioManager checks mappings
    ║
    ▼
Set initial AudioPlayer volumes based on provider state
```

This architecture ensures that:

1. **Physical control**: Deej hardware directly controls audio
2. **Visual feedback**: UI sliders reflect current state
3. **Conflict prevention**: Separated control paths prevent interference
4. **Flexibility**: Any Deej slider can control any audio target
5. **State consistency**: All components stay synchronized

## Service Evolution

### VolumeControlServiceV2 (Current)

The current implementation uses a modern approach:

```
VolumeControlServiceV2
├─ updateVolumeFromDeej(deejSliderIdx, volume)
│  ├─ Lookup DeejHardwareMapping by deejSliderIdx
│  ├─ Handle by DeejTarget type
│  ├─ For audioPlayerC1/C2: Update provider + AudioManager
│  └─ For master/externalProcess: Update Windows mixer
│
├─ updateVolumeFromUI(uiSliderIdx, volume)
│  ├─ Check Deej connection status
│  ├─ If connected: Update provider only (visualization)
│  └─ If disconnected: Handle based on slider type
│
└─ getAudioPlayerTargetVolume(channelNumber)
   ├─ Check Deej connection and mapping
   ├─ If mapped to Deej: Return provider volume
   └─ If not mapped: Return max volume (1.0)
```

### Legacy Service (Deprecated)

The older implementation used integer-based mappings:

- Slider indices: 0=Master, 1-3=P1-P3, 4=C1, 5=C2
- Less type-safe configuration
- Mixed Windows and AudioPlayer logic
- Harder to maintain and extend

_Contains AI-generated edits._
