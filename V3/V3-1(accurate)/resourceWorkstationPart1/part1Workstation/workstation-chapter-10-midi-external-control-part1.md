# Workstation Chapter 10: MIDI and External Control Integration (Part 1)
## MIDI Protocols, Hardware/Software Interfaces, Mapping, Scripting, and Robust Control Workflows

---

## Table of Contents

1. Introduction: Why MIDI and External Control Matter
2. The MIDI Protocol: History, Structure, and Modern Extensions
    - MIDI Message Types: Note, CC, Program, SysEx, Real-Time
    - MIDI Channel Structure and Polyphony
    - MIDI Data Format and Timing
    - Modern MIDI: MIDI 2.0, MPE, and High-Resolution Extensions
    - MIDI vs. OSC, USB, and Other Protocols
3. MIDI Hardware Interfacing
    - Classic 5-Pin DIN: Electrical, UART, Opto-Isolation
    - MIDI over USB: Classes, Drivers, and Compatibility
    - MIDI Thru, Merge, and Splitter Hardware
    - Level Shifting, ESD, and Noise Immunity
    - Hardware Testing and Troubleshooting
    - Schematic Examples: MIDI In/Out/Thru Circuits
4. MIDI Software Interfacing
    - UART, USB, and Class-Compliant MIDI Stack
    - Interrupts, Buffers, and Real-Time Constraints
    - Parsing and Assembling MIDI Messages
    - Timestamping and Jitter Reduction
    - MIDI Routing: Internal, External, and Hybrid Paths
    - MIDI Driver Abstraction (Embedded, Desktop, and Mobile)
5. MIDI Mapping and Advanced Routing
    - Fixed vs. Dynamic Mapping (Learn, Templates, Macros)
    - Multi-Channel, Multi-Port, and Split Mapping
    - Routing to Sequencer, Sound Engine, and Analog Boards
    - MIDI Filtering, Transpose, and Transformation
    - Velocity, Curve, and Range Mapping
    - Practice: Building a Flexible MIDI Map Engine
6. MIDI Scripting and Automation
    - Scripting MIDI: Lua, JS, Python, and Embedded DSLs
    - Custom Event Processing (Macros, Chord Memory, Arpeggiators)
    - MIDI Processing Chains: Filters, Transformers, Generators
    - Sysex Scripting and Bulk Data Operations
    - Practice: Creating MIDI Scripts for Creative Control
7. Practice Section 1: MIDI and External Control Prototypes
8. Exercises

---

## 1. Introduction: Why MIDI and External Control Matter

MIDI is the universal language for connecting and controlling electronic musical instruments.  
Every workstation must deeply support MIDI — for performance, studio, integration, and automation.  
External control (MIDI, CV/Gate, OSC, USB, Bluetooth, custom protocols) is what makes your instrument play with others — and be played by everything else.

**Key Roles of MIDI and External Control:**
- Connect keyboards, pads, controllers, sequencers, DAWs, and synths (old and new)
- Automate performance and editing (MIDI control surfaces, macro buttons, expression pedals)
- Integrate with modular, analog, and software environments
- Enable advanced workflows: multi-timbral setups, splits, layers, remote automation, scripting

**Why does this matter?**
- Without robust MIDI/external control, your workstation is isolated.
- Modern musicians expect plug-and-play MIDI, multi-device setups, real-time mapping, and deep automation.
- Future-proofing: MIDI 2.0, new protocols, and custom integrations are shaping the next generation.

---

## 2. The MIDI Protocol: History, Structure, and Modern Extensions

### 2.1 MIDI Message Types: Note, CC, Program, SysEx, Real-Time

- **Note On/Off:**  
  - 0x90 (Note On), 0x80 (Note Off) + channel (0–15)
  - Data: note number (0–127), velocity (0–127)
- **Control Change (CC):**  
  - 0xB0 + channel; Data: controller number (0–127), value (0–127)
  - Standard CCs: 1 (mod wheel), 7 (volume), 10 (pan), 64 (sustain pedal), etc.
- **Program Change:**  
  - 0xC0 + channel; Data: program number (0–127)
- **Pitch Bend:**  
  - 0xE0 + channel; Data: LSB, MSB (14 bits, center=8192)
- **Channel Pressure (Aftertouch):**  
  - 0xD0 + channel; Data: pressure (0–127)
- **Polyphonic Key Pressure:**  
  - 0xA0 + channel; Data: note, pressure

- **System Exclusive (SysEx):**  
  - 0xF0 ... 0xF7, variable length (for manufacturer-specific data, firmware, patch dumps)
- **Real-Time Messages:**  
  - 0xF8–0xFF: Timing Clock (0xF8), Start (0xFA), Continue (0xFB), Stop (0xFC), Active Sensing (0xFE), System Reset (0xFF)

### 2.2 MIDI Channel Structure and Polyphony

- 16 MIDI channels per port; each channel can be assigned to a different instrument, part, or timbre.
- Multi-timbral workstations map parts/layers to MIDI channels.
- Polyphony is managed per channel/part; note events must be tracked for proper voice handling.

### 2.3 MIDI Data Format and Timing

- **Serial data:** 31.25 kbps, 8N1 (8 data bits, no parity, 1 stop bit)
- **Running status:** Status byte can be omitted if repeated
- **Timing:** Each byte is ~320µs; note event latency must be minimized for tight timing

**Message example:**  
| Status (byte 1) | Data 1 | Data 2 |
|---|---|---|
| 0x90 (Note On, ch 1) | 60 (Middle C) | 127 (max velocity) |

### 2.4 Modern MIDI: MIDI 2.0, MPE, and High-Resolution Extensions

- **MIDI 2.0:**  
  - New packet format (32 bits), bi-directional, higher resolution (16/32 bits), profiles, property exchange
  - Backwards compatible with MIDI 1.0
- **MPE (MIDI Polyphonic Expression):**  
  - Allows per-note control (pitch bend, aftertouch, etc.), enabling expressive controllers (Roli Seaboard, LinnStrument)
  - Uses multiple channels for one instrument, each note gets its own channel
- **High-Resolution CC:**  
  - CC#32–63 are MSB for CC#0–31, enabling 14-bit control (0–16383 values)
  - Pitch Bend always 14-bit

### 2.5 MIDI vs. OSC, USB, and Other Protocols

- **OSC (Open Sound Control):**  
  - Network protocol, higher resolution, text-based, not limited to 7/14 bits, used for modern controllers and modular apps
- **USB MIDI:**  
  - Built-in on most modern devices, supports multiple ports, faster, no cable length limit
- **Bluetooth MIDI:**  
  - Wireless MIDI, used for mobile and wearable controllers (latency varies)
- **Analog CV/Gate:**  
  - Used for modular/analog synths, can be combined with MIDI for hybrid rigs

---

## 3. MIDI Hardware Interfacing

### 3.1 Classic 5-Pin DIN: Electrical, UART, Opto-Isolation

- **DIN-5 connectors:**  
  - Pins 4,5 carry current loop (5mA), opto-isolator for galvanic isolation
  - Pin 2: shield/ground (optional)
- **UART:**  
  - Standard 31250 baud, 8N1
- **Opto-isolation:**  
  - Prevents ground loops, protects against voltage spikes, required by MIDI spec

### 3.2 MIDI over USB: Classes, Drivers, and Compatibility

- **USB Class-Compliant MIDI:**  
  - No drivers required on modern OSes (Windows, Mac, Linux, iOS)
  - Multiple MIDI ports, higher throughput, plug-and-play
- **USB Device/Host:**  
  - Workstation can be USB device (connect to DAW) and/or host (connect controllers)
- **Compatibility:**  
  - Some devices require special drivers (legacy gear); most modern are plug-and-play

### 3.3 MIDI Thru, Merge, and Splitter Hardware

- **Thru:**  
  - Passes input to multiple outputs (hardware buffer, avoids signal degradation)
- **Merge:**  
  - Combines multiple MIDI streams (handle running status, avoid message collision)
- **Splitter:**  
  - Duplicates output to multiple devices (passive or active buffer)
- **Active circuits:**  
  - Use buffers and logic to prevent signal loss and crosstalk

### 3.4 Level Shifting, ESD, and Noise Immunity

- **Level shifting:**  
  - MIDI uses 5V logic; level shifters may be needed for 3.3V MCUs
- **ESD protection:**  
  - TVS diodes, series resistors on MIDI lines
- **Noise immunity:**  
  - Twisted pair cable, shielded enclosures, avoid running near power lines

### 3.5 Hardware Testing and Troubleshooting

- **Loopback test:**  
  - Connect MIDI out to MIDI in; verify transmission and parsing
- **MIDI monitor:**  
  - Use hardware or software monitor to view raw MIDI data
- **Scope/logic analyzer:**  
  - Debug signal integrity, timing, and isolation issues

### 3.6 Schematic Examples: MIDI In/Out/Thru Circuits

**MIDI In (with Opto-Isolation):**
```
DIN5 Pin 4 → 220Ω → opto input → opto output → MCU RX
DIN5 Pin 5 → 220Ω → opto input (reverse) → GND
```
- **MIDI Out:**
```
MCU TX → 220Ω → DIN5 Pin 4
GND     → 220Ω → DIN5 Pin 5
```
- **MIDI Thru:**
```
Buffer or direct copy of MIDI In to Thru (with appropriate resistors)
```

---

## 4. MIDI Software Interfacing

### 4.1 UART, USB, and Class-Compliant MIDI Stack

- **UART:**  
  - Configure hardware UART for 31250 baud; set up interrupt for RX/TX
- **USB MIDI stack:**  
  - Implement or use class-compliant MIDI stack (TinyUSB, STM32, etc.)
- **Buffering:**  
  - Circular buffers for input/output; handle overflow gracefully

### 4.2 Interrupts, Buffers, and Real-Time Constraints

- **Interrupt-driven RX/TX:**  
  - Low latency, avoids missing messages
- **Double buffering:**  
  - Separate ISRs from main code; process messages in main loop
- **Priority:**  
  - MIDI ISRs should be high priority, but lower than audio

### 4.3 Parsing and Assembling MIDI Messages

- **Status byte detection:**  
  - Detect new message, handle running status
- **State machine:**  
  - Track message type, bytes received, and assemble full messages
- **Multi-byte messages:**  
  - Handle SysEx, NRPN, and high-res CCs

### 4.4 Timestamping and Jitter Reduction

- **Timestamp every message:**  
  - Use timer or audio clock for reference
- **Jitter buffer:**  
  - Buffer messages for a few ms to smooth timing, especially with USB/Bluetooth
- **Priority:**  
  - Note on/off have highest priority; non-critical messages can be delayed

### 4.5 MIDI Routing: Internal, External, and Hybrid Paths

- **Internal routing:**  
  - Direct messages to sequencer, engine, or analog board
- **External routing:**  
  - Pass messages to other MIDI ports, USB, or network
- **Hybrid:**  
  - Map messages to multiple destinations (e.g., split keyboard: lower to engine, upper to external synth)

### 4.6 MIDI Driver Abstraction (Embedded, Desktop, and Mobile)

- **Abstraction layer:**  
  - Common API for UART, USB, and virtual MIDI
- **Platform differences:**  
  - Embedded: bare-metal or RTOS, strict real-time; Desktop: OS MIDI API (WinMM, CoreMIDI, ALSA); Mobile: iOS/Android MIDI APIs
- **Port/endpoint management:**  
  - Allow user to select input/output ports, merge or split as needed

---

## 5. MIDI Mapping and Advanced Routing

### 5.1 Fixed vs. Dynamic Mapping (Learn, Templates, Macros)

- **Fixed mapping:**  
  - Predefined CC/note → parameter assignments (e.g., CC74 always controls filter cutoff)
- **Dynamic mapping (“MIDI learn”):**  
  - User assigns controller to parameter by moving control while in learn mode
- **Templates:**  
  - Load/save sets of mappings for different controllers or use cases
- **Macros:**  
  - Map multiple controls to same parameter, or vice versa; assign macro controls for live performance

### 5.2 Multi-Channel, Multi-Port, and Split Mapping

- **Multi-channel:**  
  - Route events by MIDI channel to different parts/engines; support for omni or single channel modes
- **Multi-port:**  
  - Route between DIN, USB, Bluetooth, network, and virtual ports
- **Split mapping:**  
  - Key/velocity splits; map different keyboard zones or velocity ranges to different sounds, engines, or outputs

### 5.3 Routing to Sequencer, Sound Engine, and Analog Boards

- **Flexible routing matrix:**  
  - User-configurable, per-port and per-channel routing
- **Sequencer integration:**  
  - Route incoming MIDI to sequencer for recording, playback, or real-time triggering
- **Analog board:**  
  - Map MIDI events to CV/gate or analog controls (e.g., CC → filter cutoff CV)

### 5.4 MIDI Filtering, Transpose, and Transformation

- **Filtering:**  
  - Block or allow specific messages (e.g., ignore aftertouch, block program changes)
- **Transformation:**  
  - Transpose notes, scale velocity, remap CCs, invert/scale/polarize controls
- **Advanced scripting:**  
  - Custom scripts for conditional routing, transformation, or generation

### 5.5 Velocity, Curve, and Range Mapping

- **Velocity curves:**  
  - Linear, exponential, logarithmic, custom (drawn or table-based)
- **Range mapping:**  
  - Map controller ranges to parameter ranges, support for min/max, dead zones, and inversion
- **Scaling:**  
  - Map 7-bit CC (0–127) to parameter range (e.g., -64 to +63, 0–1023)

### 5.6 Practice: Building a Flexible MIDI Map Engine

- Implement data structures for mapping CC/note to parameter, including channel, port, and range.
- Build a MIDI learn function that captures controller messages and assigns to parameters.
- Support saving/loading mapping templates and applying macros.

---

## 6. MIDI Scripting and Automation

### 6.1 Scripting MIDI: Lua, JS, Python, and Embedded DSLs

- **Languages:**  
  - Lua: Lightweight, embeddable, real-time safe.
  - JavaScript: For web-based or hybrid apps.
  - Python: Powerful, but less real-time for embedded.
  - Custom DSLs: Optimized for speed/safety.

- **Capabilities:**  
  - Process incoming/outgoing MIDI data, generate new messages, filter or transform events, create arpeggiators, chord memory, generative sequences

### 6.2 Custom Event Processing (Macros, Chord Memory, Arpeggiators)

- **Macros:**  
  - Trigger multiple MIDI/parameter actions with one input (e.g., play chord, change patch, send CC)
- **Chord memory:**  
  - Store and trigger chords from single key presses or MIDI events
- **Arpeggiators:**  
  - Generate patterns from held notes, support for complex patterns, scales, and sync

### 6.3 MIDI Processing Chains: Filters, Transformers, Generators

- **Chain architecture:**  
  - Stack multiple processors: filter → transform → generate → map
- **Pipeline:**  
  - Modular, allow user to insert/remove processors dynamically

### 6.4 Sysex Scripting and Bulk Data Operations

- **Sysex parsing:**  
  - Read/write manufacturer-specific data (patch dumps, parameter changes, firmware updates)
- **Bulk operations:**  
  - Automate patch dumps/loads, parameter backups, or updates
- **Sysex security:**  
  - Validate messages before processing to prevent bricking device

### 6.5 Practice: Creating MIDI Scripts for Creative Control

- Write a Lua script to transform CC1 (mod wheel) into a pitch bend sweep.
- Build a chord memory script that triggers a major chord on every C note played.
- Chain a filter that blocks aftertouch, a transformer that remaps CC74 to filter cutoff, and a generator for random note echo.

---

## 7. Practice Section 1: MIDI and External Control Prototypes

### 7.1 MIDI UART Loopback

- Build a hardware and software loopback test for MIDI In/Out.
- Verify correct message parsing, timing, and error handling.

### 7.2 MIDI Learn and Mapping Engine

- Implement MIDI learn on a parameter (e.g., filter cutoff).
- Save/load mapping templates.
- Add macro assignment for live performance.

### 7.3 Routing and Filtering

- Build a flexible routing matrix: assign ports, channels, and filters.
- Test by routing MIDI from USB controller to DIN synth and vice versa.

### 7.4 MIDI Script Engine

- Implement an embedded scripting engine for custom MIDI processing.
- Write and test at least three example scripts (macro, chord, filter).

### 7.5 Sysex Dump Utility

- Build a tool to receive, parse, and save SysEx bulk dumps from external synths.

---

## 8. Exercises

1. **MIDI Message Struct**
   - Write a C struct or class for parsing and assembling MIDI messages (status, channel, data1, data2).

2. **MIDI In/Out Schematic**
   - Draw a complete MIDI In/Out/Thru circuit with opto-isolation and ESD protection.

3. **UART Interrupt Handler**
   - Implement a UART RX interrupt routine for MIDI message parsing.

4. **MIDI Routing Matrix**
   - Develop a data structure for routing MIDI by port, channel, and message type.

5. **MIDI Learn Algorithm**
   - Write pseudocode for assigning a controller to a parameter via MIDI learn.

6. **Velocity Curve Mapping**
   - Implement user-editable velocity curves for mapping incoming MIDI velocity to engine parameter value.

7. **MIDI Script Example**
   - Write a Lua/Python script that blocks all CC messages except CC1 and CC74, and inverts pitch bend direction.

8. **Sysex Parser**
   - Build a parser for receiving and validating SysEx patch dumps for a synth (manufacturer ID, data, checksum).

9. **MIDI Macro System**
   - Create a macro mapping that triggers multiple parameter changes and MIDI events with one incoming event.

10. **MIDI Error Handling**
    - Implement detection and recovery for stuck notes, running status errors, and dropped messages.

---

**End of Part 1.**  
_Part 2 will cover advanced MIDI 2.0 and MPE features, deep OSC and networked control, MIDI-CV integration, Bluetooth and wireless MIDI, robust scripting and control surface workflows, and advanced troubleshooting and future-proofing strategies._