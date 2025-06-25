# Chapter 2: System Architecture Overview (Part 2)

---

## Table of Contents

- 2.12 Detailed Subsystem Interactions
- 2.13 Data Structure Examples & Flowcharts
- 2.14 Signal & Event Workflow Scenarios
- 2.15 Hardware/Software Interface Deep Dive
- 2.16 Example Boot & Initialization Sequence
- 2.17 System Diagrams: Expansion, Audio, UI, MIDI, Networking
- 2.18 Troubleshooting & Edge Cases
- 2.19 Standards, Protocols & Extensibility
- 2.20 Summary & Further Reading

---

## 2.12 Detailed Subsystem Interactions

### 2.12.1 Audio Engine ↔ Sequencer

- The sequencer maintains a high-priority event queue with timestamped note, control, and automation data.
- For each audio buffer cycle, the engine polls the sequencer event queue:
    - Dispatches note on/off, CC, pitch bend, and automation events exactly at the sample they are scheduled.
    - Parameter automation (e.g., filter cutoff sweep) is interpolated for smoothness; engine exposes per-voice and per-global parameter accessors.
- When recording, the audio engine can embed time stamps for incoming MIDI and UI events, enabling tight “overdub” and automation replay.

### 2.12.2 UI Layer ↔ Control Core

- Touch, encoder, and button events are funneled into an asynchronous event dispatcher.
- Events are prioritized—emergency/stop, undo, and panic are always handled first.
- UI widgets and screens register for specific event types; only active modules receive updates.
- All UI elements are scriptable and can be dynamically mapped by users.

### 2.12.3 MIDI/CV ↔ Engine

- MIDI events (USB/DIN/BLE) are merged and timestamped by the MIDI service, presented to the central event bus.
- CV inputs are sampled at high resolution (~1 kHz or higher), filtered, and quantized before being routed to modulation or note input.
- Latency compensation is automatically applied for USB and network MIDI sources.

### 2.12.4 Networking ↔ Patch/Control

- OSC/Web UI changes are mapped to internal control events, respecting user permissions and system state.
- All remote changes are logged with timestamps and user/source IDs.
- Networking layer supports “atomic” patch changes—applying all related parameter updates as a unit to avoid partial state.

### 2.12.5 Storage ↔ All Subsystems

- Patches, projects, samples, and settings are stored to filesystem with checksums and versioning metadata.
- Autosave occurs on a rolling basis and after all major state changes.
- Subsystems can request “flush to disk” for critical parameters (e.g., sequencer position during live playback).

---

## 2.13 Data Structure Examples & Flowcharts

### 2.13.1 Audio Engine Data Structures

```plaintext
struct Voice {
    uint8_t id;
    bool active;
    float pitch;
    float velocity;
    Engine *engine;
    ModulationState mod;
    EnvelopeState env;
    ...
};

struct Engine {
    EngineType type; // VA, WT, FM, etc.
    EngineConfig config;
    Voice voices[MAX_VOICES];
    FXChain fx;
    RoutingMatrix routing;
    ...
};

struct FXChain {
    FXModule *modules[MAX_FX];
    RoutingConfig routing;
    ...
};
```

### 2.13.2 Sequencer and Pattern Data

```plaintext
struct Event {
    uint32_t timestamp;
    EventType type; // NOTE_ON, CC, PARAM, ...
    union {
        NoteEvent note;
        CCEvent   cc;
        ParamEvent param;
    };
};

struct Pattern {
    char name[32];
    Track tracks[MAX_TRACKS];
    uint32_t length; // steps
    uint8_t resolution; // PPQ
    ...
};
```

### 2.13.3 UI State and Mapping

```plaintext
struct UIState {
    ScreenID current_screen;
    Widget *widgets[MAX_WIDGETS];
    ControlMap control_map;
    ...
};

struct ControlMap {
    ControlSource source; // Encoder, Pad, OSC, MIDI
    ParameterID target;
    float scale;
    bool inverted;
    ...
};
```

### 2.13.4 Patch/Project Management

```plaintext
struct Patch {
    char name[64];
    EngineConfig engine_cfg;
    FXChain fx_cfg;
    ModMatrix mod_cfg;
    UIState ui_snapshot;
    ...
};

struct Project {
    char name[64];
    Patch patches[MAX_PATCHES];
    Pattern patterns[MAX_PATTERNS];
    AudioFile samples[MAX_SAMPLES];
    ...
};
```

---

### 2.13.5 Flowchart: Patch Recall Request

```plaintext
User presses "Recall Patch" →
    UI Event Queue →
        Patch Manager loads .patch from disk →
            All subsystems notified of new parameters →
                Audio Engine updates voices/FX/routing →
                UI refreshes parameter screens →
                Sequencer optionally updates track assignments →
                    → Ready for performance
```

---

### 2.13.6 Flowchart: Audio Event Processing

```plaintext
[Audio Thread Loop]
    |
    v
[Poll Sequencer/MIDI Event Queue]
    |
    v
[Dispatch Note/CC/Automation to Voice/FX]
    |
    v
[Process Modulation Matrix]
    |
    v
[Run Engine DSP for all active voices]
    |
    v
[Mix Voices, Apply FX Chain]
    |
    v
[Output to DAC/Analog]
    |
    v
[Repeat]
```

---

## 2.14 Signal & Event Workflow Scenarios

### 2.14.1 Example: Live Performance Workflow

1. **Startup**
    - System boots, initializes hardware, loads default project, brings up UI.
    - Audio thread and UI thread launch in parallel; networking and MIDI services start asynchronously.
2. **Patch Selection**
    - User navigates via encoder/touch to select a patch.
    - Patch Manager loads patch, notifies Audio Engine and UI.
    - Audio Engine flushes voices, resets FX, applies routing config.
3. **Sequencer Start**
    - User presses play on hardware transport.
    - Sequencer thread schedules events based on tempo and pattern.
    - Audio Engine synchronizes to sequencer; MIDI clock and CV outputs start.
4. **Parameter Tweaking**
    - User tweaks filter cutoff via encoder/touch.
    - Control event dispatched to Audio Engine for sample-accurate parameter change.
    - Automation can be recorded in real-time.
5. **Remote Collaboration**
    - Second user connects via WiFi/Web UI.
    - Remote parameter changes are visible in main UI and logged in project history.
6. **Save & Backup**
    - User triggers save; Patch Manager writes patch/project to SD card.
    - Optionally, backup sent to network/cloud storage.

### 2.14.2 Example: Modular Expansion Scenario

- User attaches an analog expansion shield (e.g., extra CV outs).
- System detects new device via GPIO/I2C.
- Hardware Abstraction Layer (HAL) loads corresponding driver, updates available I/O in UI.
- User maps new outputs in modulation matrix, immediately usable for real-time performance.

---

## 2.15 Hardware/Software Interface Deep Dive

### 2.15.1 Audio I/O

- **DAC/ADC:** High-quality I2S or SPI DAC (TI PCM5102, ESS ES9023), 24-32 bit, up to 192kHz.
- **Op-amp buffer:** Low-noise, rail-to-rail, unity-gain stable (TLV2372, OPA2134).
- **VCF/VCA Integration:** DAC outputs analog CVs for filter and amplifier control, with slew limiting to avoid zipper noise.
- **Pop-free startup:** Output relay or soft-mute circuit, controlled via GPIO at boot/shutdown.

### 2.15.2 MIDI/CV

- **MIDI DIN:** Opto-isolated 5V-tolerant input, 3.3V logic output; compliant with MIDI spec.
- **USB MIDI:** Host stack with hotplug detection, multi-client routing via ALSA MIDI bridge.
- **BLE MIDI:** BlueZ stack, pairable via UI; latency compensation for wireless jitter.
- **CV/Gate:** 0–5V or 0–10V buffered outputs, ESD-protected; ADCs for input, multiplexers for high channel count.

### 2.15.3 Display & Controls

- **Touch:** Capacitive or resistive; SPI/DSI/HDMI interface, EVDEV or custom driver.
- **Encoders:** Detented/non-detented, quadrature, debounce and acceleration in firmware.
- **Pads:** Matrix scanned, velocity/pressure via analog multiplexers or dedicated ICs (MPR121, FSR).
- **LEDs:** PWM dimmable, RGB addressable (WS2812/SK6812), mapped in UI for status/feedback.

### 2.15.4 Expansion

- **HAT standard:** 40-pin GPIO, supports I2C/SPI/UART, 3.3V/5V tolerant.
- **Custom shields:** Extended analog/digital I/O, motorized faders, wireless modules, additional DSP/FPGA.

---

## 2.16 Example Boot & Initialization Sequence

### 2.16.1 Power-On

1. Power supplied to primary and analog/digital rails.
2. SoC boots from SD card; U-Boot/bootloader initializes RAM, GPU, kernel.
3. Kernel loads device tree, configures primary peripherals (I2S, SPI, GPIO, USB, network).
4. systemd launches core services: audio engine, UI, MIDI, sequencer, storage, networking.
5. Hardware detection scripts poll for expansion shields, MIDI devices, USB peripherals.

### 2.16.2 Subsystem Initialization

- **Audio Engine:** Loads default DSP engine(s), sets buffer sizes, calibrates DAC/ADC.
- **UI:** Initializes touch, display, loads theme, maps controls.
- **MIDI:** Scans all available ports, merges device lists, sets up routing.
- **Sequencer:** Loads default pattern/project, syncs clock to internal or external source.
- **Networking:** Brings up WiFi/Ethernet, launches OSC/Web UI services.

### 2.16.3 Ready State

- UI presents home screen; all hardware is responsive.
- Audio thread runs at real-time priority; all event queues flushed.
- System waits for user or remote input.

---

## 2.17 System Diagrams: Expansion, Audio, UI, MIDI, Networking

### 2.17.1 Expansion/Shield Diagram

```plaintext
+---------------------+   +---------------------+
|   Main Workstation  |   |   Expansion Shield  |
| (BCM283, HAT GPIO)  |<->| (Analog/CV, Extra   |
|                     |   |  I/O, Controls, etc)|
+---------------------+   +---------------------+
        | 40-pin GPIO         | I2C, SPI, UART, Power
        +---------------------+
```

### 2.17.2 Audio Signal Path

```plaintext
[Digital Synth/FX] → [DAC] → [Op-Amp Buffer] → [Analog VCF/VCA] → [Output Jack]
                                      ↑
                         [ADC] ← [CV Input/Ext Audio]
```

### 2.17.3 UI/Control Flow

```plaintext
[Touch/Encoder/Pad Event] → [UI Driver] → [Event Queue] → [Control Processor] → [Audio/Sequencer/FX]
```

### 2.17.4 MIDI/Network Flow

```plaintext
[MIDI DIN/USB/BLE Event] → [MIDI Service] → [Event Bus] → [Sequencer/Audio Engine]
[OSC/Web UI Command]     → [Net Service]  → [Event Bus] → [All Subsystems]
```

---

## 2.18 Troubleshooting & Edge Cases

### 2.18.1 Audio Dropout Scenarios

- **Cause:** CPU overload, buffer underrun, USB/DAC glitch, kernel scheduling delay.
- **Detection:** Audio engine monitors buffer fill level, logs underruns.
- **Recovery:** Automatic buffer flush, user notification, optional subsystem restart.

### 2.18.2 MIDI/Sync Loss

- **Cause:** Bad cable, device unplug, wireless dropout.
- **Detection:** MIDI service logs missing keepalive, UI alerts user.
- **Recovery:** Hotplug rescan, reconnect logic, manual override in UI.

### 2.18.3 Storage Failure

- **Cause:** SD card corruption, power loss.
- **Detection:** Filesystem check (fsck), CRC errors in patch/project files.
- **Recovery:** Auto-mount as read-only, notify user, backup/restore prompt.

### 2.18.4 UI Freeze

- **Cause:** UI thread crash, GPU hang.
- **Detection:** Watchdog timer, lack of heartbeat.
- **Recovery:** UI subsystem restart, preserve audio thread state.

---

## 2.19 Standards, Protocols & Extensibility

### 2.19.1 Audio

- ALSA, JACK, PulseAudio for Linux audio routing.
- LV2, LADSPA for DSP plugins.
- OSC 1.1 for network control.

### 2.19.2 MIDI

- MIDI 1.0/2.0, MPE, NRPN, SysEx, MIDI clock/transport.
- BlueZ for BLE MIDI.
- ALSA MIDI bridge.

### 2.19.3 Networking

- OSC (UDP/TCP), WebSocket for browser UI.
- TLS/SSL for encrypted remote access.
- mDNS/Bonjour for auto-discovery.

### 2.19.4 Storage/File Formats

- JSON/YAML for patches, projects.
- WAV/AIFF/FLAC for samples.
- ext4/FAT32 for file system.

### 2.19.5 Extensibility

- Plugin APIs (DSP, UI, scripting).
- Hardware shields: HAT, custom pinout, SPI/I2C/UART.

---

## 2.20 Summary & Further Reading

- The Workstation’s architecture is designed for performance, flexibility, reliability, and deep user customization.
- Modular hardware and software enable powerful workflows and future expansion.
- Robust standards and protocols ensure compatibility with the broader music tech ecosystem.
- Next chapters will explore each subsystem in greater depth, with full implementation guides for both hardware and software.

**Recommended Resources:**
- Linux Audio Wiki: http://wiki.linuxaudio.org
- ALSA Project: https://www.alsa-project.org
- LV2 Plugin Standard: https://lv2plug.in
- Raspberry Pi HAT spec: https://www.raspberrypi.org/documentation/hardware/raspberrypi/hats/README.md
- MIDI Association: https://www.midi.org

---

**End of Chapter 2. Next: Chapter 3 — Hardware Platform (will be split into multiple parts).**