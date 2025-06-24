# Workstation Chapter 04: System Architecture — Modular Design, Hardware/Software Split (Part 2)
## Detailed Module Design, Communication Protocols, Interface Standards, and Partitioning Strategies

---

## Table of Contents

1. Introduction: From Block Diagram to Detailed Modules  
2. Modular Hardware Design  
    - Digital Mainboard  
    - Analog Processing Boards  
    - I/O Expansion and Control Boards  
    - Power Supplies and Regulation  
    - Chassis and Physical Layout  
3. Modular Software Design  
    - Layered Architecture  
    - Core Audio Engine  
    - User Interface Layer  
    - Storage/Filesystem Layer  
    - Communication Layer (MIDI, USB, Network)  
    - Firmware Update and Bootloader  
4. Interface and Communication Protocols  
    - Digital Audio (I2S, S/PDIF, TDM)  
    - Control Buses (I2C, SPI, UART, GPIO, CAN)  
    - MIDI (DIN, USB-MIDI, BLE-MIDI)  
    - Analog Control (CV/Gate, ADC/DAC)  
    - Human Interface (Touch, Encoders, Buttons, Display)  
    - Data Storage (SD, eMMC, SATA, USB)  
    - Power Distribution and Monitoring  
5. Partitioning Strategies: Scaling, Upgrading, and Maintaining  
6. Classic Workstation Module Comparisons  
7. Practice Section 2: Detailed Design for Your Workstation  
8. Exercises

---

## 1. Introduction: From Block Diagram to Detailed Modules

In Part 1, you outlined your high-level workstation system. Now, you’ll break down each block into concrete modules and define how they interact.

Key questions:
- How do you physically and logically separate the digital and analog domains?
- What protocols and standards ensure reliable communication?
- How do you design for upgrades, repairs, or community expansion?
- How will you debug and test modules in isolation?

**Modular thinking** is not just about splitting things up—it’s about establishing robust, clear contracts at every boundary.

---

## 2. Modular Hardware Design

### 2.1 Digital Mainboard

**Role:** Central processor, RAM, digital I/O, main firmware

**Typical Parts:**
- CPU (Raspberry Pi, ARM Cortex, STM32, etc.)
- RAM (onboard or SODIMM)
- Flash/SD/eMMC storage
- USB, Ethernet, WiFi, HDMI, etc.
- Headers for I2C, SPI, UART, GPIO
- Connectors for expansion boards

**Design Principles:**
- Use standard connectors (2.54mm pin headers, card edge, etc.)
- Isolate digital and analog power/ground planes
- Add test points for debugging (UART, JTAG, SWD)

**Example (ASCII):**
```
+----------------------------+
|  CPU   RAM   SD  USB  ETH  |
+----------------------------+
| I2C | SPI | UART | GPIO... |--- Expansion bus
+----------------------------+
```

### 2.2 Analog Processing Boards

**Role:** Filters, VCAs, mixers, audio output, analog effects

**Typical Parts:**
- Op-amps (TL07x, NE5532, etc.)
- Analog switches (for routing)
- High-quality capacitors/resistors
- DAC/ADC interface (matched to digital mainboard)
- Power filtering, muting relays

**Design Principles:**
- Keep analog traces short and away from digital noise
- Use star grounding and shielded cables as needed
- Modularize by function: “Filter Board,” “VCA Board,” etc.

### 2.3 I/O Expansion and Control Boards

**Role:** User input (buttons, encoders, touch), display, LEDs, CV/Gate, MIDI

**Typical Parts:**
- GPIO expanders (MCP23017, PCF8574)
- Multiplexers/demultiplexers
- LED drivers, button matrices, rotary encoders
- Capacitive touch controllers (e.g., FT5x06)
- Display controller (SPI/I2C/parallel for LCD/OLED)

**Connectivity:**
- Use I2C for slow devices (buttons, LEDs)
- Use SPI for fast devices (displays, ADCs)

### 2.4 Power Supplies and Regulation

**Role:** Clean, reliable voltage for digital and analog domains

**Key Concepts:**
- Multiple rails: +5V digital, +3.3V digital, ±12V analog, etc.
- Linear regulators for analog (low noise)
- Switch-mode regulators for digital (efficiency)
- Overcurrent/overvoltage protection
- Fused and reverse-polarity protected inputs

**Testing:**
- Measure all rails under load
- Use scope to check for ripple and noise on analog rails

### 2.5 Chassis and Physical Layout

**Role:** Mechanical support, shielding, cooling, ergonomics

**Choices:**
- Aluminum vs. steel vs. plastic
- PCB standoffs, panel mount connectors
- Shielding between digital/analog sections
- Access points for service/upgrade

---

## 3. Modular Software Design

### 3.1 Layered Architecture

**Typical Layers:**

- **Hardware Abstraction Layer (HAL):**  
  - Wraps all hardware access (pins, buses, ADC/DAC, display, etc.)  
  - Allows code portability and easier testing

- **Core Audio Engine:**  
  - Polyphony, multi-timbrality, voice management  
  - Oscillators, envelopes, filters, effects

- **Sequencer Engine:**  
  - Event scheduling, pattern/step/real-time modes  
  - Synchronization (internal clock, MIDI, Song Position Pointer, etc.)

- **UI Layer:**  
  - Menu system, touch/encoder/button handling  
  - Screen drawing (monochrome, color, etc.)

- **Storage Layer:**  
  - Filesystem, patch/sample/sequence management  
  - Backup/restore, firmware upgrade

- **Communication Layer:**  
  - MIDI, USB-MIDI, OSC, network protocols  
  - External control, remote editor support

- **Diagnostics and Logging:**  
  - Error reporting, debug output, user notifications

### 3.2 Core Audio Engine

- Modular DSP units (oscillator, filter, envelope, etc.)
- Voice allocation and routing
- Real-time audio callback (buffered, double-buffered, or interrupt-based)
- Parameter automation and modulation matrix

### 3.3 User Interface Layer

- Modular UI widgets (knob, slider, menu, text entry)
- Event-driven: input events trigger UI and engine updates
- Visual feedback: meters, waveform displays, status LEDs

### 3.4 Storage/Filesystem Layer

- Abstract filesystem (FAT32, ext4, or custom)
- Patch/sample/sequence file formats (binary, JSON, XML, etc.)
- Indexing and fast lookup (hash tables, trees)

### 3.5 Communication Layer

- Abstraction for MIDI, USB, network
- Parsing/formatting standard messages (MIDI, SysEx, OSC, etc.)
- Bidirectional sync with DAWs, remote editors, etc.

### 3.6 Firmware Update and Bootloader

- Robust bootloader (supports rollback, safe update)
- Firmware integrity check (checksum, signature)
- User feedback during update (progress, error handling)

---

## 4. Interface and Communication Protocols

### 4.1 Digital Audio

- **I2S:** Standard for connecting CPUs to DACs/ADCs; up to 32 channels, low jitter.
- **S/PDIF:** Optical/coaxial digital audio; for external audio gear.
- **TDM:** Multi-channel audio on a single bus (used in pro gear).

### 4.2 Control Buses

- **I2C:** Up to 100kHz–1MHz; good for sensors, buttons, low-speed I/O.
- **SPI:** Fast (10MHz+); for displays, ADC/DAC, fast peripherals.
- **UART:** Serial comms (MIDI, debugging).
- **GPIO:** Direct digital I/O (buttons, LEDs, triggers).
- **CAN:** Robust, multi-drop bus for distributed systems (rare in synths, common in industrial).

### 4.3 MIDI

- **DIN-5:** Standard 31,250 baud, opto-isolated.
- **USB-MIDI:** Class-compliant devices, plug-and-play.
- **BLE-MIDI:** Wireless, lower latency, battery powered.

### 4.4 Analog Control

- **CV/Gate:** 1V/oct, Hz/V, triggers; for modular synth integration.
- **ADC/DAC:** For control voltage in/out; 8–24 bits, 44.1kHz+ for audio.

### 4.5 Human Interface

- **Touch:** Capacitive, resistive, multi-touch; I2C/SPI/USB interface.
- **Encoders/Buttons:** Debounced, matrix scanned.
- **Display:** LCD (parallel/SPI/I2C), OLED, TFT.

### 4.6 Data Storage

- **SD Card:** Removable, FAT32/exFAT.
- **eMMC:** Onboard flash, soldered, fast.
- **SATA:** For SSDs (rare in synths, common in samplers).
- **USB:** Thumb drive, host or device mode.

### 4.7 Power Distribution and Monitoring

- Bus bars, PCBs, or harnesses.
- Power-good signals, current/protection monitoring.

---

## 5. Partitioning Strategies: Scaling, Upgrading, and Maintaining

### 5.1 Scaling

- Design busses and connectors for expansion (add more voices, effects, I/O).
- Use modular firmware: loadable plugins, DSP modules.

### 5.2 Upgrading

- Define interfaces so modules can be swapped (e.g., new analog filter board, color screen upgrade).
- Version hardware and firmware, maintain compatibility tables.

### 5.3 Maintenance

- Use connectors, not soldered wires, for easy replacement.
- Write diagnostics to isolate faults to specific modules.
- Provide firmware tools for field updates and recovery.

---

## 6. Classic Workstation Module Comparisons

### 6.1 Synclavier

- Separate CPU, keyboard, and voice cards
- Modular analog/digital voice boards
- SCSI storage, disk drives, networked editors

### 6.2 Fairlight CMI

- CPU/motherboard, separate keyboard and light pen
- Analog output boards, MIDI expansion
- Modular disk and tape drives

### 6.3 Emulator III

- Main CPU board, analog voice cards
- Modular sample RAM and storage
- MIDI, analog, and SCSI interfaces

**Modern lesson:**  
These designs allowed for repair, upgrades, and expansion—your workstation should, too!

---

## 7. Practice Section 2: Detailed Design for Your Workstation

### 7.1 List Your Hardware Modules

- For each, write:
  - Function (role)
  - Main components
  - Inputs/outputs
  - Physical size/connector

### 7.2 List Your Software Modules

- For each, write:
  - Function
  - Key data structures
  - Dependencies (uses which hardware, talks to which other software modules)

### 7.3 Draw a Communication Map

- For each bus or protocol, show:
  - What modules use it
  - Typical data rates
  - Message/packet formats

### 7.4 Upgrade and Maintenance Plan

- For each module, define:
  - How it can be replaced/upgraded
  - What must be tested after replacement
  - How users can recover from a failed update

---

## 8. Exercises

1. **Module Specification**
   - For each hardware and software module, write a 3–5 line “spec sheet” (function, connections, critical requirements).

2. **Interface Table**
   - Create a table mapping every module-to-module connection, showing protocol, speed, signal level, and cable/connector type.

3. **Communication Protocol Deep Dive**
   - Choose one protocol (I2C/SPI/MIDI/USB) and research:
     - Electrical specs
     - Data format
     - How errors are detected and handled

4. **Upgrade Scenario**
   - Imagine you want to double the polyphony by adding another voice board. What hardware and software changes are needed? How will you test and validate the upgrade?

5. **Diagnostic Feature Design**
   - For each major module, outline a diagnostic test (hardware or software) that confirms proper operation.

6. **Classic Comparison**
   - Research how expansion/upgrade was handled in your favorite classic workstation. What worked, what didn’t, and why?

---

**End of Part 2.**  
_Part 3 will cover software-hardware interface implementation, error handling at the system level, and best practices for documentation and future-proofing your workstation architecture._
