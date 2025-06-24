# Chapter 14: Building the UI – Basic Controls & MIDI – Part 2

---

## Table of Contents

6. Display and Feedback Elements (continued)
    - LED drivers, blink patterns, and multiplexing
    - Character and graphical displays: wiring, drivers, and libraries
    - Efficient real-time display updates
    - Displaying parameters and patch data
    - Building a simple menu system
7. Advanced UI Logic and Workflows
    - Menu navigation strategies (rotary, button, touchscreen)
    - Editing parameters: single and multi-parameter workflows
    - Patch management: saving, loading, and browsing
    - UI event queues and separating UI/audio threads
    - Handling “soft” controls and virtual buttons
8. Implementing MIDI: Input, Output, and Mapping
    - MIDI hardware and protocol basics
    - MIDI over DIN, USB, and UART on Pi
    - MIDI parsing in C: status bytes, running status, and SysEx
    - Integrating ALSA MIDI (Linux) with your synth code
    - Mapping MIDI controls to synth parameters
    - MIDI feedback: LEDs, displays, and MIDI out
9. MIDI Learn and Dynamic Mapping
    - What is MIDI Learn?
    - Detecting incoming CC, NRPN, and note messages
    - Assigning controls dynamically and storing mappings
    - Handling multiple MIDI channels and devices
    - Persistence: saving/loading user mappings
    - UI/UX for MIDI Learn (displays, LEDs, feedback)
10. Integrating Hardware and Software UIs
    - Hybrid workflows: panel, touchscreen, web UI
    - Synchronizing state between hardware and software controls
    - Strategies for avoiding parameter “jumps” and conflicts
    - Building a flexible event and mapping system
    - Real-world examples of hybrid synth UI architectures

---

## 6. Display and Feedback Elements (continued)

### 6.1 LED Drivers, Blink Patterns, and Multiplexing

- **Direct drive:** Use GPIO pins to drive LEDs; limited by available pins.
- **Multiplexing:** Drive more LEDs than you have pins, using row/column scanning.
- **Charlieplexing:** Even more efficient multiplexing using tri-state logic.
- **LED drivers:** Chips like 74HC595, MAX7219, or I2C/SPI expanders allow dozens of LEDs with just a few control lines.

#### Example: Multiplexed 8x8 LED Matrix

- Use timer interrupts to scan each row rapidly for flicker-free display.
- Store LED state in a frame buffer, update only changed LEDs for efficiency.

#### Blink Patterns

- Use timer or software counters to implement blinking for status/error indication.
- Patterns: solid, slow blink (normal), fast blink (warning), heartbeat (activity).

### 6.2 Character and Graphic Displays: Wiring, Drivers, and Libraries

- **Character LCDs (HD44780):** 16x2, 20x4 displays, parallel or I2C/SPI backpack.
    - Libraries: `lcdproc`, `wiringPi-lcd`, `LiquidCrystal`
- **OLED/Graphic LCDs:** SSD1306 (I2C/SPI), ST7735, ILI9341, etc.
    - Libraries: `Adafruit-GFX` (C++), `u8g2` (C), `luma.oled` (Python)
- **Wiring:** Mind voltage levels—most Pi displays use 3.3V logic.

#### Example: SSD1306 OLED on I2C

```c
// Use u8g2 or similar C library for display initialization and drawing.
u8g2_t u8g2;
u8g2_Setup_ssd1306_i2c_128x64_noname_f(
    &u8g2, U8G2_R0, u8x8_byte_sw_i2c, u8x8_gpio_and_delay_pi);
u8g2_InitDisplay(&u8g2);
u8g2_SetPowerSave(&u8g2, 0);
```

### 6.3 Efficient Real-Time Display Updates

- Double-buffer display RAM; only update changed regions (“dirty rectangles”).
- Use timer or main loop to throttle refresh rate (20–60 Hz typical).
- Avoid updating the display in the real-time audio thread—use a separate UI thread or event queue.

### 6.4 Displaying Parameters and Patch Data

- Show parameter values (cutoff, resonance, etc.) numerically or graphically (bar, dial).
- Use menus or overlays for patch names, save/load status, and error messages.
- For multi-page UIs, use “soft” buttons (display labels above/below real buttons).

### 6.5 Building a Simple Menu System

- Represent menu as a tree or list of items, each with an action or value.
- Use encoder or buttons for navigation.
- Highlight current item, allow enter/exit/back navigation.
- Store current menu position and restore after edits.

---

## 7. Advanced UI Logic and Workflows

### 7.1 Menu Navigation Strategies

- **Rotary encoder navigation:** Rotate to move, press to select/enter.
- **Button navigation:** Up/down/left/right or page/enter/back buttons.
- **Touchscreen:** Direct selection—support tap, swipe, long-press as needed.

#### Example: Menu State Machine

- State variable tracks current menu/context.
- Switch on input event to change state or value.

### 7.2 Editing Parameters: Single and Multi-Parameter Workflows

- **Single-parameter:** One knob/encoder edits selected parameter.
- **Multi-parameter:** Multiple controls mapped to different parameters (ideal, but uses more hardware).
- Use “shift” or “function” buttons to access more parameters per control.

### 7.3 Patch Management: Saving, Loading, and Browsing

- Store patches in EEPROM, SD card, or Pi filesystem.
- UI for browsing: List patches on display, use encoder/buttons to select/load/save.
- Show confirmation prompts and error messages.

### 7.4 UI Event Queues and Separating UI/Audio Threads

- Use queues or message passing to decouple UI and audio processing.
- UI thread reads controls, updates display, sends parameter changes to audio thread.
- Audio thread applies changes at safe points (e.g., buffer boundaries).

### 7.5 Handling “Soft” Controls and Virtual Buttons

- “Soft” buttons: Display labels for context-sensitive actions.
- Virtual controls: Touchscreen or rotary with on-screen feedback.

---

## 8. Implementing MIDI: Input, Output, and Mapping

### 8.1 MIDI Hardware and Protocol Basics

- **MIDI DIN:** 5-pin connector, 31.25 kbps serial, opto-isolated.
- **MIDI over USB:** Standard class-compliant devices, plug-and-play on Pi.
- **UART MIDI:** Use Pi’s UART pins (with 3.3V/5V level shifting).

### 8.2 MIDI Parsing in C

- **Status bytes:** 0x80–0xFF, indicate message type/channel.
- **Data bytes:** 0x00–0x7F, parameters (note, velocity, etc.).
- **Running status:** Repeated messages may omit status byte.
- **SysEx:** System Exclusive, variable-length, starts 0xF0 ends 0xF7.

#### Example: Basic MIDI Parser

```c
enum MidiState { WAIT_STATUS, WAIT_DATA1, WAIT_DATA2 };
MidiState midi_state = WAIT_STATUS;
uint8_t midi_status, data1;

void midi_receive(uint8_t byte) {
    if (byte & 0x80) { // Status byte
        midi_status = byte;
        midi_state = WAIT_DATA1;
    } else {
        switch (midi_state) {
            case WAIT_DATA1:
                data1 = byte;
                midi_state = WAIT_DATA2;
                break;
            case WAIT_DATA2:
                handle_midi_message(midi_status, data1, byte);
                midi_state = WAIT_DATA1;
                break;
        }
    }
}
```

### 8.3 Integrating ALSA MIDI (Linux) with Your Synth Code

- Use ALSA’s sequencer API: `snd_seq_open`, `snd_seq_create_simple_port`, etc.
- Poll for events in a dedicated MIDI thread or main UI loop.
- Pass MIDI events to synth engine via thread-safe queue.

### 8.4 Mapping MIDI Controls to Synth Parameters

- Map MIDI CC (control change), NRPN, or note events to synth parameters.
- Allow user to select which CC maps to which parameter (see MIDI Learn below).
- Provide feedback (LEDs, display) when a control is changed via MIDI.

### 8.5 MIDI Feedback: LEDs, Displays, and MIDI Out

- **LEDs:** Blink on MIDI activity, show MIDI channel, indicate learning mode.
- **Displays:** Show last received note/CC, current mappings, error messages.
- **MIDI out:** Send status or value changes to external devices (sync, feedback).

---

## 9. MIDI Learn and Dynamic Mapping

### 9.1 What is MIDI Learn?

- **MIDI Learn:** User-defined mapping of incoming MIDI controls (CC, NRPN, note) to synth parameters.
- Makes the synth compatible with a wide range of external controllers.

### 9.2 Detecting Incoming CC, NRPN, and Note Messages

- Enter “MIDI Learn” mode for a parameter.
- When a MIDI message is received (CC, NRPN, note), store its type/number/channel.
- Map parameter to this MIDI input for future control.

### 9.3 Assigning Controls Dynamically and Storing Mappings

- Store mappings in RAM and persistent storage (file, EEPROM, etc.).
- Allow remapping and clearing of assignments.
- Support multiple assignments per parameter (e.g., CC and NRPN).

### 9.4 Handling Multiple MIDI Channels and Devices

- Track source (channel/device) for each mapping.
- Optionally “omni” mode (respond to all channels), or per-channel filtering.
- UI to browse and edit mappings per channel/device.

### 9.5 Persistence: Saving/Loading User Mappings

- Store mapping tables in a config file or memory.
- Load mappings on boot, save when changed.
- Provide menu option to reset to defaults.

### 9.6 UI/UX for MIDI Learn

- Indicate “learning” mode (flashing LED, display prompt).
- Show assigned MIDI control info (type, number, channel).
- Allow canceling/confirming mapping.
- Warn on conflicts (same control mapped to multiple parameters).

---

## 10. Integrating Hardware and Software UIs

### 10.1 Hybrid Workflows: Panel, Touchscreen, Web UI

- Combine physical controls with touchscreens, web, or mobile UIs.
- Use web servers (Flask, Node.js, etc.) to serve control panels on the Pi.
- Synchronize parameter values between hardware and software.

### 10.2 Synchronizing State Between Hardware and Software Controls

- Use event-driven architecture: all value changes go through a central dispatcher.
- Update all UI elements (knobs, sliders, display, web) on parameter change.
- Implement “soft takeover” to prevent abrupt jumps.

### 10.3 Strategies for Avoiding Parameter “Jumps” and Conflicts

- Track last value from each control source.
- Only update parameter when physical and virtual values “pass through” or sync.
- Use smoothing/interpolation to mask jumps if needed.

### 10.4 Building a Flexible Event and Mapping System

- Use event structs/queues for all control changes.
- Support mapping from any input (hardware, MIDI, software) to any parameter.
- Allow user-defined macros or complex mappings.

### 10.5 Real-World Examples of Hybrid Synth UI Architectures

- **Elektron devices:** Deep menu-driven UI with encoders and display.
- **Novation Circuit:** Grid, encoders, RGB pads, and simple display.
- **Mutable Instruments:** Minimal UI, multi-function controls, LED feedback.
- **Moog Matriarch:** All-analog panel, but with MIDI and patch storage via software.

---

## 11. Summary and Further Reading

- Synth UI design is an art balancing immediacy, flexibility, and musicality.
- Hardware controls offer tactile immediacy; software adds power and flexibility.
- MIDI integration and learn modes make your synth future-proof and controller-friendly.
- Clear feedback (LEDs, display, sound) is essential for usability and performance.
- Test UI workflows rigorously—latency or missed events ruin the experience.
- Hybrid designs offer the best of both worlds, but require careful synchronization.

**Further Reading:**
- “Making Music with Synthesizers” by Mark Vail
- “Designing Interfaces” by Jenifer Tidwell (UI/UX principles)
- MIDI.org documentation
- Adafruit, SparkFun, Pimoroni tutorials (hardware UI and display projects)
- Open source synth UIs: Mutable Instruments, Axoloti, Zynthian

---

*End of Chapter 14. Next: Final Assembly, Calibration, and Sound Design (deep dive: putting it all together, calibration, tuning, and creative sound programming).*