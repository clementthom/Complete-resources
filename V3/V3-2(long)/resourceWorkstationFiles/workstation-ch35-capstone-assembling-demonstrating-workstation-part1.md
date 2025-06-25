# Chapter 35: Capstone — Assembling and Demonstrating Your Own Workstation  
## Part 1: Planning, System Integration, and Hardware Build

---

## Table of Contents

- 35.100 Introduction and Capstone Goals
- 35.101 Planning Your Workstation Project
  - 35.101.1 Defining Requirements and Use Cases
  - 35.101.2 Choosing the Platform: Embedded Linux, Bare Metal, Hybrid
  - 35.101.3 UI/UX: Color, Touch, Controls, and Workflow
  - 35.101.4 Audio and MIDI I/O: Channels, Latency, Expansion
  - 35.101.5 Power, Storage, and Physical Design
- 35.102 System Architecture and Block Diagram
  - 35.102.1 Functional Block Diagram
  - 35.102.2 Signal Flow: Audio, MIDI, UI, Power
  - 35.102.3 Modularity and Expansion (CV, GPIO, USB, Network)
- 35.103 Hardware Selection and Assembly
  - 35.103.1 Mainboard Choices (Raspberry Pi, STM32, Teensy, Custom SBC)
  - 35.103.2 Audio Codec/DAC: Selection, Schematic, Integration
  - 35.103.3 Display: Color TFT/OLED, Touch Controller, Mounting
  - 35.103.4 MIDI, CV/Gate, and User I/O (Encoders, Pads, Faders)
  - 35.103.5 Enclosure, Power Supply, and Cooling
- 35.104 Example Hardware Build Log
  - 35.104.1 Parts List (BOM) and Suppliers
  - 35.104.2 Schematic and Wiring Examples
  - 35.104.3 Step-by-Step Assembly Instructions
  - 35.104.4 Hardware Bring-Up: Testing and Troubleshooting
  - 35.104.5 Physical Assembly: Mounting, Cables, Final Checklist
- 35.105 Appendices: Reference Schematics, Panel Templates, BOM Templates, Troubleshooting

---

## 35.100 Introduction and Capstone Goals

With all the theory and practical code behind us, this capstone chapter is a comprehensive guide to assembling, testing, and demonstrating a modern, open, and extensible workstation or sampler.  
Whether your goal is a self-contained instrument, a Eurorack module, or a desktop production tool, this walk-through covers requirements planning, hardware and software integration, and best practices for demonstration and iteration.

---

## 35.101 Planning Your Workstation Project

### 35.101.1 Defining Requirements and Use Cases

- **Intended Use**:  
  - Live performance, studio, experimental sound design, teaching, DIY/hobby.
- **Key Questions**:
  - How many voices/polyphony?
  - Sample-based, synthesis, or hybrid?
  - Real-time DSP? (effects, spectral processing, AI tools)
  - Required I/O: Audio (in/out/channels), MIDI (DIN, USB, BLE), CV/Gate, networking.
  - UI: Color touchscreen, encoders, pads, keyboard, external control (MIDI/OSC/web).
  - Storage: Samples, presets, projects (SD, eMMC, SSD).
  - Portability: Battery or mains? Form factor?
  - Expansion: User modules, plugins, DIY hardware add-ons?
- **User Journey**:  
  - Map out a typical workflow: power-on, load a project, record/sample, edit, apply DSP, save/export, play live.

### 35.101.2 Choosing the Platform: Embedded Linux, Bare Metal, Hybrid

- **Embedded Linux**:  
  - Good for advanced UI, networking, multi-process, file management.
  - Hardware: Raspberry Pi, BeagleBone, i.MX, Allwinner, Pi Compute Module.
- **Bare Metal/MCU**:  
  - Lowest latency, tightest control, best for pure synths, minimal UI, MIDI/CV tools.
  - Hardware: STM32, Teensy, ESP32, RP2040.
- **Hybrid**:  
  - Linux for UI/sequencing, MCU or DSP for real-time audio.
  - Communication via SPI/UART/I2C/shared RAM.

**Decision Table**:

| Feature             | Embedded Linux      | Bare Metal           | Hybrid             |
|---------------------|--------------------|----------------------|--------------------|
| Boot Time           | 2–10s              | <100ms               | 1–3s               |
| UI Complexity       | High (Qt/LVGL)     | Low (OLED, buttons)  | High               |
| Audio Channels      | Many (USB/I2S)     | Few (I2S, DAC)       | Many               |
| Networking         | Yes                 | Rare                 | Yes                |
| Power Consumption   | High                | Low                  | Medium             |

### 35.101.3 UI/UX: Color, Touch, Controls, and Workflow

- **Color Touchscreen**: TFT/LCD 3.5”–10”, capacitive multi-touch, LVGL/Qt/TouchGFX or custom UI engine.
- **Physical Controls**:  
  - Encoders (endless, detented), potentiometers, velocity pads, faders, buttons (RGB).
  - Panel layout: ergonomic, one-hand operation, “muscle memory.”
- **Workflow**:  
  - Menu navigation, one-touch record/play, context-sensitive controls, undo/redo, quick save/load.

### 35.101.4 Audio and MIDI I/O: Channels, Latency, Expansion

- **Audio**:
  - Stereo in/out, multi-channel support (I2S, USB audio interface).
  - Codec: PCM5102, WM8731, CS4270, or USB Class Compliant.
  - Latency: Round-trip below 10ms for live playability.
- **MIDI**:
  - 5-pin DIN, USB host/device, BLE MIDI.
  - Merge, filter, and route MIDI internally.
- **Expansion**:
  - Additional I/O via GPIO, SPI/I2C, CV/gate outs, USB host (for controllers, storage).

### 35.101.5 Power, Storage, and Physical Design

- **Power**:
  - Internal Li-ion/LiPo battery (with charge controller) or external 9–15V DC.
  - Power budget: estimate max and idle draw, thermal planning.
- **Storage**:
  - SD/microSD, eMMC, or SATA/USB SSD.
  - Partition for OS, user data, backup.
- **Physical**:
  - Enclosure: 3D printed, laser cut acrylic, aluminum; rack mount, desktop, Eurorack.
  - Accessibility: serviceability, expansion slots, cooling vents, panel labeling.

---

## 35.102 System Architecture and Block Diagram

### 35.102.1 Functional Block Diagram

```
+---------------------------+
|        Main CPU/MCU       |
|  (e.g., Pi, STM32, etc.)  |
+------------+--------------+
             |
  +----------+----------+
  |   Audio Codec/DAC    |
  +----------+----------+
             |
       +-----+-----+
       |   Output  |----> Audio Out (Line, Headphone)
       +-----------+
       |   Input   |<---- Audio In (Line, Mic)
       +-----------+

+-------------+    +------------+
|  Touch LCD  |    |  Encoders  |
+------+------+    +-----+------+
       |                 |
 +-----+-----+     +-----+------+
 |   UI CPU   |     |  Keypad   |
 +-----------+     +------------+

+----------+   +-----------+   +----------+
|  MIDI In |   | MIDI Out  |   | USB Host |
+----------+   +-----------+   +----------+

+----------+   +----------+   +--------------+
|  CV/Gate |   |  GPIO    |   |  Network     |
+----------+   +----------+   +--------------+
```

### 35.102.2 Signal Flow: Audio, MIDI, UI, Power

- **Audio**:  
  - Input (ADC) → DSP (FX/Engine) → DAC (Output)
- **MIDI**:  
  - DIN/USB/BLE → MIDI parser/router → Synth engine/Sequencer
- **UI**:  
  - Touch/encoder/pad events → UI state machine → Parameter updates, menu navigation
- **Power**:  
  - DC in/Battery → Regulator(s) → CPU, Codec, Display, Peripherals
- **Expansion**:  
  - GPIO → Triggers, LEDs, additional controls

### 35.102.3 Modularity and Expansion (CV, GPIO, USB, Network)

- **CV/Gate**:
  - Use DAC or PWM out, opto-isolated trigger/gate outputs, ADC for CV in.
- **GPIO**:
  - For triggers, external switches, mod wheels.
- **USB**:
  - Host mode for controllers, thumb drives; device mode for DAW integration.
- **Network**:
  - Ethernet/Wi-Fi for OSC, NTP sync, remote control, updates.

---

## 35.103 Hardware Selection and Assembly

### 35.103.1 Mainboard Choices (Raspberry Pi, STM32, Teensy, Custom SBC)

- **Raspberry Pi 4/CM4**:  
  - Quad-core, 1–8GB RAM, USB 3, Ethernet, HDMI, runs full Linux.
- **BeagleBone Black/Green**:  
  - ARM Cortex-A8, real-time PRUs for ultra-low-latency I/O.
- **STM32H7/F7**:  
  - Up to 480MHz, DSP/FPU, I2S, SAI, plenty of GPIO.
- **Teensy 4.x**:  
  - 600MHz ARM Cortex-M7, excellent audio/MIDI support.
- **Custom SBC/FPGA**:  
  - For advanced users; e.g., Cyclone V, Zynq.

**Criteria**:  
- RAM/flash requirements
- Available audio I/O (I2S, SAI, SPDIF, USB)
- Peripheral support (touch, MIDI, GPIO)
- Community support and tools

### 35.103.2 Audio Codec/DAC: Selection, Schematic, Integration

- **Popular Audio Codecs for DIY**:
  - PCM5102A, WM8731 (I2S, 24-bit, up to 96kHz)
  - CS4270 (multi-channel)
  - AK4452 (high-end, 32-bit)
- **Integration**:
  - I2S wiring: SCK, LRCK, SDIN, SDOUT, MCLK
  - Power: 3.3V/5V, decoupling caps, analog/digital ground separation
- **Schematic Example**:

```
Pi I2S ----> [PCM5102]
  BCK  ---> SCK
  LRCK ---> LRCK
  DATA ---> DIN
  3.3V ---> VDD / LDO
  GND  ---> GND
```

- **Board Layout**:
  - Keep analog/digital grounds separated, short traces, shielded if possible.

### 35.103.3 Display: Color TFT/OLED, Touch Controller, Mounting

- **Display Selection**:
  - Size: 3.5” (QVGA), 5” (800x480), 7” (1024x600)
  - Interface: SPI (slower), RGB parallel, MIPI-DSI (fastest, but requires SoC support)
  - Touch controller: I2C (FT6206, Goodix GT911), SPI
- **Mounting**:
  - Mechanical: glue, screws, 3D-printed bezel, gasket for IP rating
  - Electrical: FPC ribbon, ZIF socket, breakout board

### 35.103.4 MIDI, CV/Gate, and User I/O (Encoders, Pads, Faders)

- **MIDI**:
  - DIN: opto-isolator (6N138), 220Ω resistor, 5-pin connector
  - USB: Host port for controllers, device for DAW
- **CV/Gate**:
  - DAC (MCP4922, TLV5618) for CV out (1V/oct, Hz/V)
  - Open-drain transistor for gate out, comparator for gate in
- **Encoders, Pads, Faders**:
  - Rotary encoders (with/without detent), tactile switches, capacitive touch, velocity pads (FSR or piezo)
  - Matrix scanning for pads, debounce filtering

### 35.103.5 Enclosure, Power Supply, and Cooling

- **Enclosure**:
  - Aluminum (CNC, laser-cut), acrylic, wood, or 3D printed
  - Cutouts for display, knobs, jacks; internal standoffs
- **Power**:
  - DC-DC converter, battery charger (TP4056, BQ24074), fuse/ESD diodes
  - Power switch, charge status LED
- **Cooling**:
  - Passive: vents, heatsinks
  - Active: fan, thermal pads, sensor-driven PWM control

---

## 35.104 Example Hardware Build Log

### 35.104.1 Parts List (BOM) and Suppliers

**Example BOM:**

| Component                  | Part Number | Qty | Supplier      | Notes                |
|----------------------------|-------------|-----|---------------|----------------------|
| Raspberry Pi 4B 4GB        | RPI4-4GB    | 1   | RaspberryPi   | Mainboard            |
| PCM5102A Audio DAC Module  | PCM5102A    | 1   | AliExpress    | I2S DAC              |
| 5" TFT Touchscreen         | 5INCH-TFT   | 1   | Waveshare     | 800x480, HDMI/I2C    |
| 6N138 Opto-isolator        | 6N138       | 1   | Mouser        | MIDI In DIN          |
| 5-Pin DIN Jack             | DIN5        | 2   | Tayda         | MIDI In/Out          |
| Rotary Encoder w/ switch   | EC11        | 4   | Digi-Key      | UI controls          |
| USB Type A Socket          | USB-A       | 2   | Mouser        | Host ports           |
| MCP4922 DAC (CV out)       | MCP4922     | 1   | Digi-Key      | CV/Gate out          |
| Li-ion Battery (18650)     | NCR18650B   | 1   | BatterySpace  | Power                |
| TP4056 Charger Module      | TP4056      | 1   | AliExpress    | Charging             |
| Aluminum Enclosure         | Custom      | 1   | Hammond       | Case                 |
| Heatsinks                  | -           | 3   | Amazon        | Cooling              |

### 35.104.2 Schematic and Wiring Examples

- **Audio (I2S)**:  
  - Pi GPIO pins to PCM5102A: GPIO18 (PCM_CLK), GPIO19 (PCM_FS), GPIO21 (PCM_DOUT)
- **MIDI (DIN In)**:  
  - MIDI DIN 4/5 → 6N138 → Pi GPIO RX
- **Touch Display**:  
  - HDMI for video, I2C for touch
- **CV Out**:  
  - Pi SPI MOSI/SCK → MCP4922 → Buffer → 3.5mm jack

### 35.104.3 Step-by-Step Assembly Instructions

1. Mount Pi, display, and DAC module in enclosure.
2. Solder MIDI DIN and opto-isolator circuit, connect to GPIO.
3. Wire encoders and buttons to GPIO (use pull-up resistors if needed).
4. Connect DAC (CV out) to SPI pins, run output through buffer op-amp.
5. Install battery, charger, and power switch; verify voltage before powering mainboard.
6. Attach heatsinks and fan if needed.

### 35.104.4 Hardware Bring-Up: Testing and Troubleshooting

- **Initial Power-On**:  
  - Verify voltage rails, check for shorts.
- **Display Test**:  
  - Confirm HDMI output, calibrate touch.
- **Audio Test**:  
  - Play test tone, check for noise, latency, channel balance.
- **MIDI Test**:  
  - Loopback test: send/receive MIDI data, verify routing.
- **CV/Gate Test**:  
  - Output 1V/oct signals, verify with voltmeter or synth.
- **Thermal Test**:  
  - Run at max CPU/DSP load, monitor temperature, adjust cooling if needed.

### 35.104.5 Physical Assembly: Mounting, Cables, Final Checklist

- Secure all modules with standoffs/screws.
- Route cables to avoid interference, use cable ties/labels.
- Check all connections, close enclosure.
- Label panel controls, ports, and expansion slots.

---

## 35.105 Appendices: Reference Schematics, Panel Templates, BOM Templates, Troubleshooting

### 35.105.1 Reference Schematic (Text)

```
[Pi GPIO]
  |---[PCM5102A I2S DAC]---[Stereo Out]
  |---[MIDI In: 6N138 Opto]---[DIN]
  |---[MIDI Out: Transistor]---[DIN]
  |---[Touch TFT: HDMI/I2C]---[LCD Panel]
  |---[SPI: MCP4922 DAC]---[CV Out]
  |---[Encoders/Buttons]---[Front Panel]
  |---[USB-A Host]---[Back Panel]
  |---[Li-ion Batt/Charger]---[Power Jack]
```

### 35.105.2 Panel Design Template (ASCII)

```
+------------------------------------------------------+
| [Display]           [Encoders]          [Pads]       |
|           [Buttons]    [Faders] [MIDI] [CV/Gate]     |
| [USB] [Power] [SD] [Audio Out] [Audio In] [Network]  |
+------------------------------------------------------+
```

### 35.105.3 BOM Template (CSV)

```
Component,Part Number,Qty,Supplier,Notes
Raspberry Pi 4B 4GB,RPI4-4GB,1,RaspberryPi,Mainboard
PCM5102A Audio DAC Module,PCM5102A,1,AliExpress,I2S DAC
...
```

### 35.105.4 Troubleshooting Tips

- **No Power**: Check battery wiring, fuse, power switch, charger module.
- **No Audio**: Verify I2S wiring, codec power, kernel modules, test with known-good DAC.
- **No Touch**: Check I2C lines, install correct driver, calibrate.
- **MIDI Issues**: Reverse MIDI DIN pins, check opto-isolator orientation.
- **Noise**: Separate analog/digital grounds, shield cables, add ferrite beads.

---

# End of Chapter 35, Part 1

---

## Next Steps

Continue to **Part 2** for:  
- System software bring-up (Linux/RTOS/MCU firmware)
- Audio/MIDI routing and engine integration
- UI/UX workflows (color/touch, encoders, remote control)
- Real-time DSP, effects, and AI/ML feature demonstration
- End-to-end testing, calibration, and performance benchmarks

---