# Volume Control Decision Logic

## Main Decision Flow (Current Implementation)

```mermaid
flowchart TD
    START([Volume Change Event]) --> SOURCE{Source of Change?}

    %% Hardware Path
    SOURCE -->|Hardware Slider| DEEJ[Deej SerialIO Handler]
    DEEJ --> PARSE[Parse Serial Data<br/>Convert to Percentage]
    PARSE --> GET_MAPPING[Get DeejHardwareMapping<br/>by deejSliderIdx]
    GET_MAPPING --> CHECK_TARGET{DeejTarget Type?}

    %% Deej Target Handling
    CHECK_TARGET -->|master| UPDATE_MASTER[Update Windows<br/>Master Volume]
    CHECK_TARGET -->|externalProcess| UPDATE_PROCESS[Update Windows<br/>Process Volume]
    CHECK_TARGET -->|audioPlayerC1| UPDATE_C1[Update C1 Provider<br/>+ AudioManager]
    CHECK_TARGET -->|audioPlayerC2| UPDATE_C2[Update C2 Provider<br/>+ AudioManager]

    UPDATE_MASTER --> END_HW[End Hardware Flow]
    UPDATE_PROCESS --> END_HW
    UPDATE_C1 --> END_HW
    UPDATE_C2 --> END_HW

    %% UI Path
    SOURCE -->|UI Slider| UI_HANDLER[UI Slider Callback]
    UI_HANDLER --> CHECK_CONNECTION{Is Deej Connected?}

    %% Connected - UI updates providers only
    CHECK_CONNECTION -->|Yes| UI_CONNECTED[Update Provider Only<br/>for Visual Feedback]
    UI_CONNECTED --> END_UI_CONNECTED[End - Hardware Controls]

    %% Disconnected - UI controls system
    CHECK_CONNECTION -->|No| UI_DISCONNECTED[UI Controls System]
    UI_DISCONNECTED --> CHECK_UI_TYPE{UI Slider Type?}

    CHECK_UI_TYPE -->|Master (0)| UPDATE_MASTER_UI[Update Windows<br/>Master Volume]
    CHECK_UI_TYPE -->|AudioPlayer (4,5)| UPDATE_AP_VIZ[Update Provider<br/>Visualization Only]
    CHECK_UI_TYPE -->|Other (1-3)| END_OTHER[No Action<br/>Legacy Sliders]

    UPDATE_MASTER_UI --> END_UI_MASTER[End Master UI Flow]
    UPDATE_AP_VIZ --> END_AP_VIZ[AudioPlayer uses<br/>max volume when playing]
    END_OTHER --> END_UI_OTHER[End Other UI Flow]

    %% Styling
    classDef startEnd fill:#e1f5fe,stroke:#01579b,stroke-width:2px
    classDef decision fill:#fff3e0,stroke:#e65100,stroke-width:2px
    classDef hardware fill:#f3e5f5,stroke:#4a148c,stroke-width:2px
    classDef ui fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef audioplayer fill:#fce4ec,stroke:#c2185b,stroke-width:2px

    class START,END_HW,END_UI_CONNECTED,END_UI_MASTER,END_AP_VIZ,END_UI_OTHER startEnd
    class SOURCE,CHECK_CONNECTION,CHECK_TARGET,CHECK_UI_TYPE decision
    class DEEJ,PARSE,GET_MAPPING hardware
    class UI_HANDLER,UI_CONNECTED,UI_DISCONNECTED ui
    class UPDATE_C1,UPDATE_C2,UPDATE_AP_VIZ audioplayer
```

    classDef ui fill:#e8f5e8,stroke:#1b5e20,stroke-width:2px
    classDef system fill:#fce4ec,stroke:#880e4f,stroke-width:2px

    class START,END_HW,END_UI_CONNECTED,END_MASTER,END_UI_NO_PROC,END_UI_PROC startEnd
    class SOURCE,CHECK_CONNECTION,CHECK_PROCESS,CHECK_MASTER,CHECK_MASTER_PROCESSES,CHECK_UI_PROCESSES decision
    class DEEJ,PARSE,GET_MAPPING hardware
    class UI_HANDLER,UI_CONNECTED,UI_DISCONNECTED,UPDATE_UI_ONLY,UPDATE_UI_PROV,GET_UI_MAPPINGS ui
    class UPDATE_UI,UPDATE_PROCESS,UPDATE_MASTER,UPDATE_MASTER_PROC,UPDATE_UI_PROC system

````

## State Management Flow

```mermaid
stateDiagram-v2
    [*] --> Initializing

    Initializing --> DeejConnected : Hardware detected
    Initializing --> DeejDisconnected : No hardware

    state DeejConnected {
        [*] --> HardwareControl
        HardwareControl --> ProcessingSerialData : Slider moved
        ProcessingSerialData --> UpdatingUIProviders : Data parsed
        UpdatingUIProviders --> UpdatingWindowsAudio : UI synced
        UpdatingWindowsAudio --> HardwareControl : Complete
    }

    state DeejDisconnected {
        [*] --> UIControl
        UIControl --> ProcessingUIInput : Slider moved
        ProcessingUIInput --> CheckingMappings : Input validated
        CheckingMappings --> UpdatingProviders : Mappings found
        CheckingMappings --> UIOnlyUpdate : No mappings
        UpdatingProviders --> UpdatingSystemAudio : Providers updated
        UpdatingSystemAudio --> UIControl : Complete
        UIOnlyUpdate --> UIControl : UI only updated
    }

    DeejConnected --> DeejDisconnected : Connection lost
    DeejDisconnected --> DeejConnected : Hardware reconnected

    DeejConnected --> [*] : App shutdown
    DeejDisconnected --> [*] : App shutdown
````

## Component Interaction Matrix

| Component            | Deej Connected             | Deej Disconnected       |
| -------------------- | -------------------------- | ----------------------- |
| **Hardware Sliders** | ✅ Control system audio    | ❌ No effect            |
| **UI Sliders**       | 📊 Display only (reactive) | ✅ Control system audio |
| **Volume Providers** | 🔄 Updated by hardware     | 🔄 Updated by UI        |
| **Windows Audio**    | 🎵 Controlled by hardware  | 🎵 Controlled by UI     |
| **Process Mapping**  | ✅ Applied from hardware   | ✅ Applied from UI      |
| **Master Volume**    | ✅ Hardware controlled     | ✅ UI controlled        |

## Error Handling

```mermaid
flowchart TD
    ERROR_START([Error Occurs]) --> ERROR_TYPE{Error Type?}

    ERROR_TYPE -->|Serial Connection| SERIAL_ERROR[Serial Connection Lost]
    SERIAL_ERROR --> UPDATE_STATUS[Update Connection Status<br/>to Disconnected]
    UPDATE_STATUS --> FALLBACK_UI[Fallback to UI Control]
    FALLBACK_UI --> LOG_SERIAL[Log Connection Loss]
    LOG_SERIAL --> ERROR_END[Continue with UI]

    ERROR_TYPE -->|Volume Update| VOLUME_ERROR[Volume Update Failed]
    VOLUME_ERROR --> LOG_VOLUME[Log Volume Error]
    LOG_VOLUME --> RETRY_VOLUME{Retry Possible?}
    RETRY_VOLUME -->|Yes| RETRY_UPDATE[Retry Volume Update]
    RETRY_VOLUME -->|No| SKIP_UPDATE[Skip This Update]
    RETRY_UPDATE --> ERROR_END
    SKIP_UPDATE --> ERROR_END

    ERROR_TYPE -->|Process Not Found| PROCESS_ERROR[Mapped Process Not Running]
    PROCESS_ERROR --> LOG_PROCESS[Log Process Not Found]
    LOG_PROCESS --> CONTINUE_OTHER[Continue Other Processes]
    CONTINUE_OTHER --> ERROR_END

    ERROR_TYPE -->|Provider Update| PROVIDER_ERROR[Provider Update Failed]
    PROVIDER_ERROR --> LOG_PROVIDER[Log Provider Error]
    LOG_PROVIDER --> UI_DESYNC[UI May Show Wrong Value]
    UI_DESYNC --> ERROR_END

    %% Styling
    classDef error fill:#ffebee,stroke:#c62828,stroke-width:2px
    classDef recovery fill:#e8f5e8,stroke:#2e7d32,stroke-width:2px
    classDef logging fill:#fff3e0,stroke:#f57c00,stroke-width:2px

    class ERROR_START,SERIAL_ERROR,VOLUME_ERROR,PROCESS_ERROR,PROVIDER_ERROR error
    class UPDATE_STATUS,FALLBACK_UI,RETRY_UPDATE,CONTINUE_OTHER recovery
    class LOG_SERIAL,LOG_VOLUME,LOG_PROCESS,LOG_PROVIDER logging
```

## Performance Considerations

### Debouncing Strategy

```dart
// Debounce rapid slider movements to prevent audio stuttering
final Map<String, Timer> _debounceTimers = {};

void _debounceVolumeUpdate(String sliderId, double value) {
  _debounceTimers[sliderId]?.cancel();
  _debounceTimers[sliderId] = Timer(
    const Duration(milliseconds: 50),
    () => _actualVolumeUpdate(sliderId, value),
  );
}
```

### Optimization Techniques

1. **Threshold Detection**: Only update if change > 1%
2. **Batch Updates**: Group multiple process updates
3. **Selective Rebuilds**: Use `select()` for specific provider changes
4. **Connection Caching**: Cache connection status for performance

### Memory Management

- Dispose timers on widget disposal
- Cancel subscriptions when providers disposed
- Weak references for audio process handles
- Regular cleanup of disconnected process mappings

## Testing Strategy

### Unit Tests

- Volume calculation accuracy
- Connection status detection
- Provider state updates
- Error handling scenarios

### Integration Tests

- Hardware → UI synchronization
- UI → System audio flow
- Mapping configuration persistence
- Connection loss recovery
- AudioPlayer volume application timing

### Manual Testing Scenarios

1. **Connect/Disconnect Hardware**: Verify seamless transition
2. **Process Mapping**: Test different app combinations
3. **AudioPlayer Control**: Test C1/C2 volume behavior with/without Deej
4. **Error Recovery**: Simulate connection failures
5. **Performance**: Test rapid slider movements
6. **Configuration**: Verify settings persistence with new DeejTarget system

## Current Implementation Summary

The volume control system has evolved to support:

- **Type-Safe Configuration**: `DeejTarget` enum replaces integer-based mappings
- **AudioPlayer Integration**: C1/C2 channels properly integrated with Deej system
- **Service Architecture**: `VolumeControlServiceV2` provides cleaner separation
- **Provider-Driven Volumes**: AudioPlayer respects provider state when Deej connected
- **Fallback Behavior**: Clear behavior when Deej disconnected (max volume for AudioPlayer)

The legacy system using `SliderMapping` and integer indices is deprecated but still functional for backward compatibility.

_Contains AI-generated edits._
