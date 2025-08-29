# Deej System - Visual Flow Diagrams

## Current Implementation Flow

### 1. System Overview

```mermaid
graph TD
    A[Deej Hardware Board] -->|Serial/USB| B[External Deej Service]
    B -->|HTTP/WebSocket| C[Flutter DeejService]
    C -->|Updates| D[Volume Providers]

    E[UI Sliders] -->|User Input| F[VolumeControlService]
    D -->|State Changes| F

    F -->|Windows Audio| G[SystemVolumeManager]
    F -->|AudioPlayer| H[AudioManager]

    G -->|Process Control| I[Windows Audio Mixer]
    I -->|Output| J[chrome.exe, discord.exe, etc.]

    H -->|Direct Control| K[AudioPlayer Channel1]
    H -->|Direct Control| L[AudioPlayer Channel2]

    K -->|Audio Output| M[Flutter Audio System]
    L -->|Audio Output| M
```

### 2. Detailed Control Flow for AudioPlayer Channels

```mermaid
sequenceDiagram
    participant U as User/Deej
    participant DS as DeejService
    participant VP as VolumeProvider
    participant VCS as VolumeControlService
    participant AM as AudioManager
    participant AP as AudioPlayer

    Note over U,AP: Scenario: Playing audio on Deej-mapped channel

    U->>DS: Moves physical slider
    DS->>VP: Updates c1VolumeProvider (0.7)
    VP->>VCS: Notifies state change

    Note over VCS: Checks isDeejConnected = true
    VCS->>VP: Updates provider only (no AudioPlayer change)

    U->>AM: Triggers audio playback
    AM->>AM: _getCurrentTargetVolume()
    AM->>VP: Reads current provider value (0.7)
    AM->>AP: setVolume(0.7)
    AM->>AP: play(audioFile)

    Note over AP: Audio plays at correct volume
```

### 3. Control Path Separation

```mermaid
flowchart LR
    subgraph "Input Sources"
        UI[UI Slider]
        DEEJ[Deej Hardware]
    end

    subgraph "Control Logic"
        VCS[VolumeControlService]
        CONNECTED{Deej Connected?}
        MAPPED{Channel Mapped?}
    end

    subgraph "Audio Targets"
        WIN[Windows Audio]
        C1[AudioPlayer C1]
        C2[AudioPlayer C2]
    end

    UI --> VCS
    DEEJ --> VCS

    VCS --> CONNECTED
    CONNECTED -->|Yes| MAPPED
    CONNECTED -->|No| WIN
    CONNECTED -->|No| C1
    CONNECTED -->|No| C2

    MAPPED -->|Windows Process| WIN
    MAPPED -->|AudioPlayer| C1
    MAPPED -->|AudioPlayer| C2
```

### 4. Volume Provider State Management

```mermaid
stateDiagram-v2
    [*] --> Initialized
    Initialized --> DeejConnected: Deej service starts
    Initialized --> DeejDisconnected: No Deej connection

    DeejConnected --> ProviderControlled: Channel mapped to Deej
    DeejConnected --> UIControlled: Channel not mapped

    ProviderControlled --> VolumeFromProvider: AudioManager reads state
    VolumeFromProvider --> AudioPlayerUpdated: setVolume() called

    UIControlled --> DirectControl: UI changes volume
    DirectControl --> AudioPlayerUpdated: Immediate update

    DeejDisconnected --> DirectControl

    AudioPlayerUpdated --> [*]: Audio plays correctly
```

### 5. Mapping Configuration Impact

```mermaid
graph TD
    subgraph "Configuration"
        CONFIG[VolumeSystemConfig]
        DEEJ0[Deej Slider 0]
        DEEJ1[Deej Slider 1]
        DEEJ2[Deej Slider 2]
        DEEJ3[Deej Slider 3]
    end

    subgraph "Target Types"
        MASTER[Master Volume]
        EXTERNAL[External Process]
        C1[AudioPlayer C1]
        C2[AudioPlayer C2]
    end

    subgraph "Audio Output"
        WINPROC[Windows Processes]
        APCH1[AudioPlayer Channel 1]
        APCH2[AudioPlayer Channel 2]
        WINMASTER[Windows Master]
    end

    CONFIG --> DEEJ0
    CONFIG --> DEEJ1
    CONFIG --> DEEJ2
    CONFIG --> DEEJ3

    DEEJ0 -.->|DeejTarget| MASTER
    DEEJ1 -.->|DeejTarget| EXTERNAL
    DEEJ2 -.->|DeejTarget| C1
    DEEJ3 -.->|DeejTarget| C2

    MASTER --> WINMASTER
    EXTERNAL --> WINPROC
    C1 --> APCH1
    C2 --> APCH2
```

### 6. Error Scenarios and Recovery

```mermaid
flowchart TD
    START[Audio Playback Requested]

    START --> CHECKMAP{Channel Mapped to Deej?}

    CHECKMAP -->|Yes| CHECKCONN{Deej Connected?}
    CHECKMAP -->|No| DIRECTVOL[Use UI Volume]

    CHECKCONN -->|Yes| GETPROV[Get Provider Volume]
    CHECKCONN -->|No| DIRECTVOL

    GETPROV --> CHECKVOL{Provider Volume > 0?}

    CHECKVOL -->|Yes| USEPROV[Use Provider Volume]
    CHECKVOL -->|No| FALLBACK[Use Fallback 0.7]

    USEPROV --> SETVOLUME[Set AudioPlayer Volume]
    FALLBACK --> SETVOLUME
    DIRECTVOL --> SETVOLUME

    SETVOLUME --> PLAY[Play Audio]

    PLAY --> SUCCESS{Audio Audible?}
    SUCCESS -->|Yes| END[✓ Success]
    SUCCESS -->|No| DEBUG[Check Debug Logs]
```

## Key Points

1. **Separation of Concerns**: Windows audio and AudioPlayer channels are handled differently
2. **Provider-Driven**: AudioPlayer volumes are driven by provider state when Deej is connected
3. **Fallback Logic**: System gracefully handles edge cases like zero volumes and disconnection
4. **Conflict Prevention**: VolumeControlServiceV2 prevents UI and Deej from fighting over control
5. **Configuration Flexibility**: Any Deej slider can control any audio target through DeejTarget mappings
6. **Type Safety**: Modern configuration uses enums instead of magic numbers
7. **Service Evolution**: VolumeControlServiceV2 replaces the legacy integer-based mapping system

## Implementation Notes

- **Current Service**: Uses `VolumeControlServiceV2` with `DeejTarget` enum
- **Legacy Support**: Old `SliderMapping` system still available but deprecated
- **AudioPlayer Integration**: Channels respect Deej mappings and provider values
- **Volume Timing**: AudioPlayer volumes applied at playback start, not slider movement
- **Fallback Strategy**: When Deej disconnected, AudioPlayer uses maximum volume

_Contains AI-generated edits._
