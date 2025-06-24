# Chapter 10: Interfacing Pi 4 with DACs and Analog Circuits – Part 1

---

## Table of Contents

1. Introduction: Pi 4 as a Synth Engine and I/O Hub
2. Hardware Overview: The Raspberry Pi 4
    - CPU, RAM, GPIO, SPI, I2C, I2S, USB
    - Why use Pi for synths?
    - Pi 4 pinout and voltage levels
3. Digital-to-Analog Conversion (DAC) Fundamentals
    - What is a DAC?
    - Bit depth, sample rate, and audio quality
    - Types of DACs: resistor ladder, delta-sigma, commercial ICs
    - Key parameters: THD, SNR, dynamic range, monotonicity
4. Choosing a DAC for Your Project
    - SPI vs I2C vs I2S: protocol comparison
    - Popular DAC chips: MCP4922, PCM5102A, TLV320, AK4490, PCM1794, etc.
    - Audio vs CV (control voltage) DACs
    - Output voltage ranges, current drive, and impedance
5. Physical Interfacing: Wiring the Pi to a DAC
    - Understanding the Pi’s GPIO headers
    - Level shifting and voltage compatibility
    - SPI/I2C/I2S DAC wiring diagrams
    - Power supply considerations, decoupling, and noise
    - Breadboarding, soldering, and prototyping best practices
6. Digital Communication Protocols Deep Dive
    - SPI: how it works, timing, multi-device setups, Pi configuration
    - I2C: address structure, clock stretching, pull-ups, multi-master
    - I2S: audio streaming, word clock, bit clock, frame sync
    - Linux device tree overlays for enabling interfaces

---

## 1. Introduction: Pi 4 as a Synth Engine and I/O Hub

The **Raspberry Pi 4** is a powerful, affordable, and flexible platform for DIY synthesizer projects, bridging the world of digital signal processing and real-world analog audio. With a quad-core ARM CPU, ample RAM, fast I/O, and extensive GPIO (General-Purpose Input/Output), the Pi 4 is capable of running complex synth engines, handling MIDI, managing user interfaces, and communicating with both digital and analog hardware.

**Why use Pi 4 for hybrid synths?**
- High computational power for digital oscillators, filters, effects, and polyphony
- Direct access to GPIO for custom hardware control
- Multiple communication buses (SPI, I2C, I2S, UART, USB)
- Runs Linux, enabling easy development and software portability
- Affordable and widely supported in the maker community

## 2. Hardware Overview: The Raspberry Pi 4

### 2.1 CPU, RAM, and I/O

- **CPU:** Quad-core ARM Cortex-A72, up to 1.5GHz (overclockable)
- **RAM:** 2GB, 4GB, 8GB variants (ample for audio)
- **I/O:** 
  - 40-pin GPIO header (digital I/O, PWM, SPI, I2C, UART, I2S)
  - HDMI, USB 2.0/3.0, Ethernet, WiFi, Bluetooth
- **SD Card:** Boot device, also used for storage

### 2.2 Why Use Pi for Synths?

- **DSP Power:** Can run real-time audio engines, soft synths, and effects comfortably
- **Flexibility:** Easily interface with sensors, controls, displays, and analog circuits
- **Community:** Abundant examples, libraries, and support
- **Cost:** Much cheaper than most dedicated DSP boards with similar power

### 2.3 Pi 4 Pinout and Voltage Levels

- **GPIO Header:** 40 pins, supports 3.3V logic ONLY
    - **Do NOT connect 5V directly to GPIO!**
    - Pins are not 5V tolerant—use level shifters if needed
- **Power Pins:** 5V and 3.3V rails available for peripherals
- **Ground Pins:** Multiple grounds for stable connections

#### Example: 40-Pin Header Key Functions

| Pin | Function | Typical Use |
|-----|----------|-------------|
| 1   | 3.3V     | Power for logic |
| 2   | 5V       | Power for peripherals |
| 3/5 | SDA/SCL  | I2C         |
| 6   | GND      | Ground      |
| 8   | TXD      | UART TX     |
| 10  | RXD      | UART RX     |
| 11  | GPIO17   | General I/O |
| 19  | MOSI     | SPI Data    |
| 21  | MISO     | SPI Data    |
| 23  | SCLK     | SPI Clock   |
| 24  | CE0      | SPI Chip Sel|
| 35  | I2S      | Audio Data  |

## 3. Digital-to-Analog Conversion (DAC) Fundamentals

### 3.1 What is a DAC?

A **Digital-to-Analog Converter (DAC)** turns a stream of digital numbers (binary data, e.g. 8, 12, 16, 24 bits per sample) into a corresponding analog voltage or current. DACs are critical for any system that needs to output audio or control voltages (CV) from a digital source—like a Pi-based synth.

### 3.2 Bit Depth, Sample Rate, and Audio Quality

- **Bit depth:** Number of bits per sample (8/10/12/16/24). Higher = more resolution and dynamic range.
- **Sample rate:** How many samples per second (Hz, kHz). CD audio = 44.1kHz, Pro audio = 48/96/192kHz.
- **Audio quality:** 
    - More bits = less quantization noise, higher fidelity
    - Higher sample rates = more accurate high frequencies, less aliasing

#### Table: Bit Depth and Dynamic Range

| Bits | Levels | Dynamic Range (dB) |
|------|--------|--------------------|
| 8    | 256    | 48                 |
| 12   | 4096   | 72                 |
| 16   | 65,536 | 96                 |
| 24   | 16.7M  | 144                |

### 3.3 Types of DACs

- **Resistor Ladder (R-2R):** Simple, low-cost, used in basic CV/audio projects. Moderate speed and linearity.
- **Delta-Sigma (ΣΔ):** Oversampling, noise shaping; high-resolution audio DACs. Used in PCM5102, AK4490, etc.
- **Current-steering:** High-speed, used in some pro audio and video.
- **Commercial ICs:** MCP4922 (12-bit SPI), PCM5102A (24-bit I2S), many others.

### 3.4 Key Parameters

- **THD (Total Harmonic Distortion):** Lower = cleaner audio
- **SNR (Signal-to-Noise Ratio):** Higher is better
- **Dynamic Range:** Max difference between loudest/softest output
- **Monotonicity:** Output always increases with input (no "glitches")
- **Settling Time:** How fast DAC output reaches target value

---

## 4. Choosing a DAC for Your Project

### 4.1 SPI vs I2C vs I2S: Protocol Comparison

- **SPI:** Simple, fast, full-duplex, supports multiple peripherals, used for MCP4922, AD5668.
- **I2C:** Two wires, slower, supports many devices, addressable; used for some CV DACs.
- **I2S:** Dedicated digital audio bus, synchronous, high-quality, used for PCM5102A, AK4490.

#### Table: Protocol Feature Comparison

| Feature    | SPI         | I2C         | I2S           |
|------------|-------------|-------------|---------------|
| Pins       | 4 (MOSI, MISO, SCLK, CS) | 2 (SDA, SCL)  | 3-4 (SD, WS, SCK, MCK) |
| Speed      | 10+ MHz     | 100k–1MHz   | 3+ MHz        |
| Audio Use  | YES         | Rare        | YES           |
| Addressing | By CS pin   | By address  | N/A (dedicated) |

### 4.2 Popular DAC Chips

- **MCP4922:** 12-bit dual, SPI, easy for both audio and CV, up to 350kSPS.
- **PCM5102A:** 24-bit, I2S, up to 384kHz, excellent SNR/THD; widely used in Pi “HiFi” hats.
- **TLV320:** 24-bit, I2S, also includes ADC (codec).
- **AK4490/PCM1794:** High-end audio DACs, I2S, up to 32 bits.
- **AD5668:** 16-bit, SPI, multiple channels.

### 4.3 Audio vs CV DACs

- **Audio DACs:** Prioritize SNR, THD, speed. Usually AC-coupled, fixed voltage range (e.g., 2Vpp).
- **CV DACs:** Must provide accurate, monotonic DC output over wide range (e.g., 0–5V, ±10V). Needs DC coupling, low drift, and low glitch energy.

### 4.4 Output Voltage Ranges, Current Drive, and Impedance

- Most DACs output 0–Vref or 0–3.3V/5V. For ±5V/±10V, use op-amp buffers and level shifters.
- **Current drive:** Most can only drive high-impedance loads—use a buffer for headphones, speakers, or modular synth inputs.
- **Impedance:** Keep output impedance low for audio, use buffer op-amps to prevent loading.

---

## 5. Physical Interfacing: Wiring the Pi to a DAC

### 5.1 Understanding the Pi’s GPIO Headers

- 40 pins, with mixed power, ground, and I/O.
- Each pin can be configured as input, output, or special function (SPI, I2C, etc.).
- **3.3V logic only**—never connect 5V signals directly.

#### Pinout Resources

- Use https://pinout.xyz/ for up-to-date pin diagrams

### 5.2 Level Shifting and Voltage Compatibility

- **Pi GPIO is 3.3V ONLY.**
- If DAC expects 5V logic, use a level shifter (e.g., 74LVC245, MOSFET or resistor divider for basic cases).
- Many modern DACs accept 3.3V logic even when powered at 5V, but check datasheet!

### 5.3 SPI/I2C/I2S DAC Wiring Diagrams

#### Example: MCP4922 (SPI)

| Pi GPIO   | MCP4922 |
|-----------|---------|
| MOSI (19) | SDI     |
| SCLK (23) | SCK     |
| CE0  (24) | CS      |
| 3.3V/5V   | VDD     |
| GND       | VSS     |
| VOUTA/B   | Audio/CV Out |

- Connect decoupling caps (0.1uF) close to VDD/GND pins.
- Place buffer op-amp after DAC output for audio/CV use.

#### Example: PCM5102A (I2S)

| Pi GPIO     | PCM5102A |
|-------------|----------|
| I2S_DOUT(40)| DIN      |
| I2S_BCLK(12)| BCK      |
| I2S_LRCK(35)| LRCK     |
| 3.3V        | VDD      |
| GND         | GND      |
| OUTL, OUTR  | Audio Out|

- PCM5102A is audio-only; cannot output DC (CV).

### 5.4 Power Supply Considerations, Decoupling, and Noise

- **Power supplies:** Use clean, regulated 3.3V/5V. Avoid sharing noisy digital power with analog circuits.
- **Decoupling:** Place 0.1uF ceramic caps close to all power pins.
- **Grounding:** Use star ground for analog and digital sections.
- **Analog/digital separation:** If possible, separate analog and digital grounds on PCB.

### 5.5 Breadboarding, Soldering, and Prototyping Best Practices

- Breadboard for initial testing, but move to soldered proto or PCB for reliability.
- Keep wires short, especially for SPI/I2S (high speed).
- Avoid running analog and digital traces parallel for long distances (crosstalk).
- Use shielded cable for sensitive analog signals.

---

*End of Part 1. Part 2 will cover protocol deep dives, Linux device tree overlays, C code for SPI/I2C/I2S interfacing on Pi, troubleshooting, oscilloscope measurement, and real-world integration tips.*