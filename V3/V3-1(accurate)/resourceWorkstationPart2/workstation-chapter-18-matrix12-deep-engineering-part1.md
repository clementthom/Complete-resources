# Workstation Chapter 18: Deep Engineering Analysis — Oberheim Matrix 12 (Part 1)
## Technical Blueprint for Hardware + Software Recreation

---

> **Beginner note:** This chapter is a deep technical dive into every detail of the Oberheim Matrix 12, with the goal of enabling you to design your own board and software to match its analog sound, digital modulation, UI, MIDI, and patch storage. Take your time — every concept will be explained for newcomers.

---

## Table of Contents

1. Overview and System Map
    - What Is the Matrix 12?
    - Big-Picture Architecture: Subsystems and Dataflow
    - High-Level Block Diagram
2. Voice Architecture in Depth
    - Voice Board Physical Layout
    - VCOs: Design, Circuit, and Modern Equivalents
    - Mixer and Waveshaping
    - Filter (VCF): Multimode Circuit and Implementation
    - VCA and Panning
    - EGs, LFOs, Tracking Generators
    - Analog and Digital Control: CV, DACs, and Multiplexing
3. Modulation Matrix: Hardware and Logic
    - Matrix Concept and Data Structure
    - Sources & Destinations: Signal Paths
    - Digital Routing: How the Matrix is Scanned and Applied
    - Designing a Mod Matrix in Firmware
    - Limitations, Aliasing, and CPU Load
4. Digital Control Core
    - Microprocessor Selection and Role
    - Scanning, Parameter Changes, and Timing
    - Voice Assignment Logic
    - Data Communication: Buses, Addressing, and Expansions
5. User Interface Hardware
    - Panel Layout: Membrane Matrix, Slider, Display
    - Button Matrix Scanning Circuit
    - Display Driving: VFD or Modern Substitutes
    - Encoder/Slider Reading and Debouncing
6. MIDI, CV/Gate, and External I/O
    - MIDI Implementation: Hardware and Software
    - CV/Gate, Pedals, and Panel Inputs
    - Output Stage: Stereo and Summing
7. Patch Storage
    - Internal RAM: Battery Backup
    - Cartridge Slot: External Memory Protocol
    - SysEx Dump: MIDI Data Format and Recovery
8. Serviceability, Calibration, and Field Issues
    - Calibration Process: VCOs, VCAs, Filters
    - Common Failures and Modern Solutions
9. Practice: Mapping a Full Board and Firmware Plan

---

## 1. Overview and System Map

### 1.1 What Is the Matrix 12?

- The Matrix 12 is a 12-voice analog polysynth with full digital parameter control, revolutionary modulation flexibility, and a hybrid analog-digital design.
- **Goal:** Recreate this instrument’s capabilities, sound, and interface with modern (but true-to-vintage) engineering.

### 1.2 Big-Picture Architecture: Subsystems and Dataflow

- **Major subsystems:**
    - Keyboard/Panel (input, UI)
    - Digital Control Core (CPU, patch memory, voice assignment)
    - Voice Boards (12x, each with VCOs, VCF, VCA, modulators)
    - Panel Board (buttons, display, sliders)
    - MIDI and CV/Gate I/O
    - Power Supply and Distribution
    - Audio Summing and Output
    - Patch Storage (internal RAM, cartridge, SysEx)

**Dataflow:**

```
[Panel+Keyboard] → [CPU/Control] → [CV/DAC] → [Voice Boards] → [Analog Output]
                                  ↘ [Patch Storage/MIDI/CV] ↙
```

### 1.3 High-Level Block Diagram

```
[ Keyboard ]
     |
[ UI Panel ] ------ [ CPU Board ] ----+-- [ DACs ] --+-- [ Voice Boards ×12 ]
     |                                |              |
[ Display ]                        [ RAM/ROM ]    [ CV/Gate ]
     |                                |              |
[ MIDI + CV I/O ]                 [ Storage ]   [ Audio Out ]
```

---

## 2. Voice Architecture in Depth

### 2.1 Voice Board Physical Layout

- Each voice is a physically separate analog circuit, duplicated 12 times.
- **Components per voice:**
    - 2x VCO (CEM3374 or equivalent)
    - Mixer (with noise, ring mod, external in)
    - Multimode VCF (CEM3372)
    - VCA (CEM3372)
    - EGs, LFOs: digitally generated, CV-applied
    - Per-voice panning, output buffer
    - S/H (Sample-and-hold) for CVs
    - Local voltage references, trimmers for calibration

**For your board:**
- Design a single voice board and plan for 12 identical instances, or one multi-voice board with replicated sections.

### 2.2 VCOs: Design, Circuit, and Modern Equivalents

- **Original:** CEM3374 dual VCO IC, analog saw, triangle, pulse, sync, Xmod.
    - *Features:*
        - Linear and exponential pitch CVs
        - Hard sync input
        - Triangle, saw, pulse outs
        - PWM (Pulse Width Mod) via CV
        - Xmod (FM) via CV
    - *Modern equivalents:*
        - SSI2131, CEM3340, or discrete OTA VCO
        - Digital control: Each parameter receives a calibrated CV from DAC

- **Circuit essentials:**
    - Exponential converter for pitch
    - Current source for core
    - Wave shaping (saw/tri), comparator for pulse
    - Sync: pulse or edge into integrator reset
    - FM/Xmod: sum linear FM to core current

- **Board design:**
    - Shielding and ground plane to reduce noise
    - Separate analog/digital power
    - Trimmers for offset, scale, and symmetry

- **Software:**
    - CPU scans panel/MIDI, calculates pitch, PWM, FM per voice
    - Sends values to DAC, which updates S/H for each VCO param

### 2.3 Mixer and Waveshaping

- **Analog mixer:**
    - Mixes VCO1, VCO2, noise, external in, ring mod
    - Each input has VCAs for modulation (crossfade, ringmod)
    - Noise: White noise transistor circuit buffered and summed

- **Ring modulator:**
    - Analog multiplier (often diode or OTA based) between VCO1/VCO2
    - Can be bypassed or modulated into the mixer

- **Board design:**
    - Use low-noise op-amps for summing
    - VCAs for each source (CEM3372 or equivalent) controlled by CV

- **Software:**
    - Modulation matrix sets mixer levels dynamically
    - Assigns sources/destinations per patch

### 2.4 Filter (VCF): Multimode Circuit and Implementation

- **Original:** CEM3372 (one per voice) — 15 filter modes!
    - 24dB Lowpass, 12dB LP, 6dB HP, BP, Notch, Phase, combinations
- **Control:**
    - Cutoff, resonance, mode selection, key tracking, mod CVs
    - Mode selection: CMOS analog switches or digital logic

- **Modern options:**
    - Reissue chips (CEM3372, AS3320), or multi-mode OTA/discrete designs

- **Circuit:**
    - OTA/capacitor ladder, resonance feedback
    - Mode switching via relays or CMOS analog switches (CD4053, etc.)
    - Resonance CV summed to feedback loop

- **Board design:**
    - Isolate digital mode lines from audio path
    - Use separate ground for filter section if possible

- **Software:**
    - Matrix assigns cutoff/resonance/other modulations per voice
    - Mode changes per patch or performance setup

### 2.5 VCA and Panning

- **VCA:**  
  - Part of CEM3372, final gain stage per voice.  
  - Controlled by its own S/H, EG, and mod CVs.

- **Panning:**  
  - Each voice can be panned (L/R or continuous) using a voltage-controlled pan circuit (VCA crossfade or special panner IC).
  - Controlled by a separate DAC/S&H or digitally-controlled potentiometer.

- **Board design:**  
  - Summing resistors and op-amps for stereo out.
  - Careful layout to avoid crosstalk and maintain stereo separation.

- **Software:**  
  - Pan position is part of patch and can be modulated by LFO, EG, etc.

### 2.6 EGs, LFOs, Tracking Generators

- **EGs (Envelopes):**  
  - 5 per voice. Digitally generated: CPU updates target times/levels for each stage, output as CV via DAC/S&H.
  - Stages: DADSR (Delay, Attack, Decay, Sustain, Release).
  - Looping, retrigger, and modulated by velocity, key, etc.

- **LFOs:**  
  - 5 per voice. Digital (CPU-generated) or analog triangle/sine/step.
  - S&H or DAC per LFO per voice for analog destination, or sum digitally in modulation routing.

- **Tracking Generators:**  
  - Map input CV (velocity, pressure, key) to arbitrary output curve (stored as lookup table).
  - Used for complex non-linear modulations.

- **Board design:**  
  - S&H circuits for each dynamic CV per voice
  - Multiplexed DAC outputs, clocked by CPU

- **Software:**  
  - Timer interrupts generate LFO, EG, and update S&H at high sample rate (~1kHz min)
  - Modulation matrix sums sources, applies scaling, and sends CVs to voice

### 2.7 Analog and Digital Control: CV, DACs, and Multiplexing

- **Digital to Analog:**
    - CPU outputs parameter values via parallel or serial bus to DAC(s)
    - Multiplexers (4051/4052/4053) route DAC outputs to S&H per parameter per voice
    - S&H holds CV steady between updates

- **Typical update cycle:**
    - For 12 voices × ~10 modulated params/voice = 120 S&H channels
    - Update each channel at 1kHz for smooth LFO/EG (may need faster for audio-rate mod)
    - Use fast DAC (e.g., 12-16 bit), and fast, low droop S&H

- **Board design:**
    - Careful routing of digital lines to avoid noise injection
    - Shield analog S&H and DACs
    - Use analog ground planes, star grounding, and EMC best practice

- **Software:**
    - Main loop: scan UI/MIDI, update modulation matrix, recalc CVs, output to DAC/mux
    - Prioritize latency for playing/EG changes, batch less time-critical updates

---

## [TO BE CONTINUED IN PART 2: Modulation Matrix Logic, Digital Control Core, UI Hardware, MIDI/IO, and Patch Storage]

---

**Practice for Beginners:**
- Try drawing a block diagram for just one voice, showing all the CVs, DACs, and S&H circuits needed.
- Research S&H and multiplexer ICs and how you would use them to control 12 voices worth of analog parameters.
- Write a simple microcontroller loop that updates a DAC and cycles through a multiplexer for multiple outputs.

---

**Next: Part 2 — Modulation Matrix Digital Logic, Microcontroller Firmware, UI Panel Engineering, MIDI/CV Hardware, and Patch Storage Internals.**