# Chapter 30: Case Studies – PPG Wave (Complete Deep-Dive)
## Part 1: System Architecture, Hybrid Synthesis Hardware, and Retro-Engineering

---

## Table of Contents

- 30.270 Introduction
- 30.271 Historical Context, Innovations, and System Overview
  - 30.271.1 PPG Wave’s Market, Impact, and Legacy
  - 30.271.2 Key Innovations: Digital Wavetables, Analog VCF/VCA, Hybrid Voice Architecture
  - 30.271.3 Block Diagram and Major Subsystems
- 30.272 Hardware Architecture
  - 30.272.1 Mainframe, PSU, and Card Backplane
  - 30.272.2 CPU Board: Microprocessor, RAM, ROM, Bus Logic
  - 30.272.3 Digital Voice Cards: Wavetable Oscillators, Addressing, DACs
  - 30.272.4 Analog Voice Cards: SSM Filters, VCAs, Output Mixing
  - 30.272.5 Storage: Tape Interface, EPROM, Battery Backup
  - 30.272.6 Panel, Display, and Keyboard Architecture
- 30.273 Digital Wavetable Synthesis and Hybrid Sound Generation
  - 30.273.1 Wavetable Theory: Structure, Interpolation, and Scanning
  - 30.273.2 PPG’s Wavetable ROM: Organization, Data Format, and Addressing
  - 30.273.3 Digital Oscillator Design: Phase Accum, Interpolation, and Aliasing
  - 30.273.4 DAC, Sample Rate, and Digital Output Path
  - 30.273.5 VCF/VCA Analog Path: SSM2044/2040, Envelope, and Modulation
  - 30.273.6 Voice Summing, Mix Bus, and Output Amplifiers
- 30.274 System Bus, Memory Map, and I/O
  - 30.274.1 Bus Protocol, Arbitration, and Timing
  - 30.274.2 Memory Map: OS, Parameter Buffers, Voice Registers
  - 30.274.3 I/O: Panel, Display, Tape, MIDI, Sync
- 30.275 Example C Code: Wavetable Playback, Voice Scheduling, and I/O Handlers
  - 30.275.1 Voice Register Access and Parameter Update
  - 30.275.2 Wavetable Oscillator: Phase Accumulation and Interpolation
  - 30.275.3 Envelope Generator, VCF, and VCA Control
  - 30.275.4 Panel/Display Scan, Debounce, and Event Queue
- 30.276 Appendices: Schematics, Pinouts, Wavetable Maps, Service Tables

---

## 30.270 Introduction

The PPG Wave series (notably the Wave 2.2 and 2.3) is a legendary family of hybrid digital/analog synthesizers, introducing digital wavetable oscillators with analog VCF/VCA circuits. Designed by Wolfgang Palm, these instruments combine crisp, evolving digital timbres with the warmth and punch of classic analog filters, defining the sound of the early-to-mid 1980s in pop, electronic, and film music. Their architecture, panel, and OS represent a unique intersection of digital logic, microprocessor control, and classic analog engineering.

---

## 30.271 Historical Context, Innovations, and System Overview

### 30.271.1 PPG Wave’s Market, Impact, and Legacy

- **Target Market**: Professional studios, synth pioneers, producers seeking new timbres (notable users: Depeche Mode, Thomas Dolby, Tangerine Dream).
- **Legacy**: Introduced wavetable synthesis, inspiring later synths (Waldorf Microwave, Access Virus, modern plugins).
- **Price Point**: Approx. $8,000–$10,000 at launch (Wave 2.3).

### 30.271.2 Key Innovations: Digital Wavetables, Analog VCF/VCA, Hybrid Voice Architecture

- **Digital Wavetables**:  
  - 64–128 distinct waveforms per bank; user can scan, morph, or modulate between them.
- **Hybrid Voice Architecture**:  
  - Digital oscillators (custom logic, EPROM-based) drive analog SSM2044/2040 VCFs and VCAs.
- **Modulation**:  
  - Complex LFOs, envelopes, velocity, aftertouch, and external (MIDI, CV) routing.

### 30.271.3 Block Diagram and Major Subsystems

```
[Keyboard/Panel]---+
                   |
           [Display/Softkeys]
                   |
                [Backplane Bus]
                   |
   +---------+-----+-----+-------+--------+
   |         |           |       |        |
 [CPU]  [Voice Cards] [Analog] [Tape]  [MIDI]
   |         |          |        |        |
 [RAM/ROM][Wavetable][VCF/VCA][Storage][I/O]
```

---

## 30.272 Hardware Architecture

### 30.272.1 Mainframe, PSU, and Card Backplane

- **Chassis**:  
  - 19” rackmount or keyboard, heavy linear PSU (multiple windings for digital and analog), forced air cooling.
- **Backplane**:  
  - Proprietary, 60–100 pins/slot, multiple voltage rails (+5V digital, ±12V analog, +9V logic).
  - Modular: CPU, 8–16 voice cards, analog card, panel/display, storage.

### 30.272.2 CPU Board: Microprocessor, RAM, ROM, Bus Logic

- **CPU**:  
  - Motorola 6809 or Z80; 8-bit data, 16-bit address, 2–4 MHz.
- **RAM**:  
  - 2–16KB static/dynamic RAM for OS, patch storage, parameter buffers.
- **ROM**:  
  - 8–64KB EPROM, holds OS, panel routines, wavetables (early models).
- **Bus Logic**:  
  - PAL/GAL address decoding, 74LS/HC glue logic, bus transceivers.
- **DMA/Timer**:  
  - 8253/8257 or discrete logic for timing, voice update, and sample clock.

### 30.272.3 Digital Voice Cards: Wavetable Oscillators, Addressing, DACs

- **Voice Card**:  
  - Each card: 1–2 digital oscillators, address logic, wavetable ROM, 8/12-bit DAC.
  - Phase accumulator: 16–20 bit, increments per key pitch/velocity/modulation.
  - LFO and envelope modulate wavetable position, amplitude, and filter cutoff.
- **Wavetable ROM**:  
  - 2K–8K x 8/12 bits, stores waveform samples.
- **DAC**:  
  - Multiplexed, sends digital output to analog VCF/VCA.

### 30.272.4 Analog Voice Cards: SSM Filters, VCAs, Output Mixing

- **VCF**:  
  - SSM2044 or SSM2040, 4-pole lowpass; cutoff/resonance set by CV from CPU/LFO/envelope.
- **VCA**:  
  - SSM2024 or discrete OTA; CV from envelope, velocity, or modulation matrix.
- **Output Mixing**:  
  - Each voice summed to stereo/mono bus; output buffer (NE5532/TL072).

### 30.272.5 Storage: Tape Interface, EPROM, Battery Backup

- **Tape**:  
  - Cassette interface for patches, sequences, OS backup/restore.
- **EPROM**:  
  - Main OS and basic waveforms; upgradeable for new features.
- **Battery Backup**:  
  - Lithium or NiCd, keeps RAM for patch/sequence retention.

### 30.272.6 Panel, Display, and Keyboard Architecture

- **Panel**:  
  - 40+ tactile switches, rotary encoder, membrane numeric pad; matrix scanned.
- **Display**:  
  - 2x16 or 2x24 alphanumeric LCD or VFD, parallel bus, custom character generator.
- **Keyboard**:  
  - 61-note, velocity, aftertouch; scanned via CPU or matrix logic.

---

## 30.273 Digital Wavetable Synthesis and Hybrid Sound Generation

### 30.273.1 Wavetable Theory: Structure, Interpolation, and Scanning

- **Wavetable**:  
  - Array of single-cycle waveforms, each 64–256 samples, stored in ROM.
  - User/CPU selects table and position; interpolates between waves for smooth morphing.
- **Interpolation**:  
  - Linear or higher-order between adjacent waveforms; prevents stepping artifacts.
- **Scanning**:  
  - LFO, envelope, velocity, or real-time modulation sweeps through table.

### 30.273.2 PPG’s Wavetable ROM: Organization, Data Format, and Addressing

- **ROM Organization**:  
  - Each table: N waveforms × S samples/wave, 8 or 12 bits/sample.
  - Address: [table][pos][sample]; logic selects current waveform, sample, interpolates as needed.
- **Data Format**:  
  - Unsigned or signed PCM, 8/12 bit; table headers with metadata (e.g., name, loop, flags).

### 30.273.3 Digital Oscillator Design: Phase Accum, Interpolation, and Aliasing

- **Phase Accumulator**:  
  - 20–24 bits; high bits select waveform position, low bits interpolate between samples.
- **Frequency Calculation**:  
  - Phase increment = 2^N × (note freq / sample rate).
  - Supports pitch bend, detune, and microtuning.
- **Aliasing**:  
  - Addressed by oversampling, analog filter, and careful wavetable design.

### 30.273.4 DAC, Sample Rate, and Digital Output Path

- **DAC**:  
  - 8/12-bit, R-2R or monolithic (DAC08, AD7541).
  - Sample rate: 31.25kHz (typ), set by timer/CPU clock.
- **Output Path**:  
  - Digital output buffered, lowpass filtered, sent to VCF input.

### 30.273.5 VCF/VCA Analog Path: SSM2044/2040, Envelope, and Modulation

- **VCF**:  
  - 4-pole lowpass, cutoff/resonance set by CV; modulated by envelope, LFO, velocity, aftertouch.
- **Envelope**:  
  - ADSR, digitally generated; per-voice, controls VCA and optionally VCF.
- **VCA**:  
  - CV from envelope, velocity; controls amplitude, can be modulated in real-time.

### 30.273.6 Voice Summing, Mix Bus, and Output Amplifiers

- **Summing**:  
  - Analog bus sums all voices; stereo or mono main out, optional individual outs (Wave 2.3).
- **Output Amplifiers**:  
  - Balanced/unbalanced, low-noise; main out, phones, aux.

---

## 30.274 System Bus, Memory Map, and I/O

### 30.274.1 Bus Protocol, Arbitration, and Timing

- **Bus Protocol**:  
  - Multiplexed address/data, CPU master; voice cards and panel as slaves.
  - Handshake: BUSY, REQ, ACK, INT, RESET.
- **Timing**:  
  - CPU cycles: ~500ns–1μs access; timer interrupts for voice/LFO update.

### 30.274.2 Memory Map: OS, Parameter Buffers, Voice Registers

| Address      | Region             | Size     | Function           |
|--------------|--------------------|----------|--------------------|
| 0x0000–0x1FFF| OS ROM             | 8KB      | Boot, Routines     |
| 0x2000–0x3FFF| RAM                | 8KB      | Patch, Params      |
| 0x4000–0x4FFF| Wavetable ROM      | 4KB      | Waveforms          |
| 0x5000–0x5FFF| Voice Regs         | 4KB      | Per-voice control  |
| ...          | Panel, Display, I/O| ...      | Ext peripherals    |

### 30.274.3 I/O: Panel, Display, Tape, MIDI, Sync

- **Panel**:  
  - Matrix scanned, polled by CPU, debounced in firmware.
- **Display**:  
  - Mapped to parallel bus, updated from CPU.
- **Tape**:  
  - Serial/parallel interface, block transfer, error correction.
- **MIDI**:  
  - UART-based, opto-isolated, merged with panel events.
- **Sync**:  
  - FSK, clock, DIN sync for sequencer and arpeggiator.

---

## 30.275 Example C Code: Wavetable Playback, Voice Scheduling, and I/O Handlers

### 30.275.1 Voice Register Access and Parameter Update

```c
#define VOICE_BASE 0x5000
#define VOICE_REG_SIZE 0x10

typedef struct {
    uint16_t phase;
    uint16_t phase_inc;
    uint8_t  wavetable;
    uint8_t  position;
    uint8_t  envelope;
    uint8_t  filter_cv;
    uint8_t  amp_cv;
    uint8_t  status;
} voice_reg_t;

volatile voice_reg_t* voice_regs = (voice_reg_t*)VOICE_BASE;

void update_voice(int v, uint16_t phase_inc, uint8_t wave, uint8_t pos, uint8_t env, uint8_t filt, uint8_t amp) {
    voice_regs[v].phase_inc = phase_inc;
    voice_regs[v].wavetable = wave;
    voice_regs[v].position = pos;
    voice_regs[v].envelope = env;
    voice_regs[v].filter_cv = filt;
    voice_regs[v].amp_cv = amp;
    voice_regs[v].status = 1; // Active
}
```

### 30.275.2 Wavetable Oscillator: Phase Accumulation and Interpolation

```c
uint8_t wavetable_rom[64][128]; // 64 waves, 128 samples each

uint16_t phase_acc;
uint16_t phase_inc;
uint8_t  wavetable, position;

int16_t wavetable_playback() {
    uint16_t idx = (phase_acc >> 9) & 0x7F; // 128 samples
    uint8_t wave_a = wavetable;
    uint8_t wave_b = (wavetable + 1) % 64;
    uint8_t pos_a = wavetable_rom[wave_a][idx];
    uint8_t pos_b = wavetable_rom[wave_b][idx];
    uint16_t frac = phase_acc & 0x1FF; // fraction between samples

    // Interpolate between waveforms for smooth morph
    int16_t val = ((pos_a * (512 - frac)) + (pos_b * frac)) >> 9;
    phase_acc += phase_inc;
    return val;
}
```

### 30.275.3 Envelope Generator, VCF, and VCA Control

```c
typedef struct {
    uint8_t attack, decay, sustain, release;
    uint8_t state;
    uint16_t level;
} env_t;

env_t envs[8];

void tick_envelope(env_t* env) {
    switch (env->state) {
        case 0: // Attack
            env->level += env->attack;
            if (env->level >= 1023) {
                env->level = 1023;
                env->state = 1;
            }
            break;
        case 1: // Decay
            if (env->level > env->sustain)
                env->level -= env->decay;
            else
                env->state = 2;
            break;
        case 2: // Sustain
            // Hold
            break;
        case 3: // Release
            if (env->level > 0)
                env->level -= env->release;
            else
                env->state = 4;
            break;
    }
}

void set_vcf_vca(int v, uint16_t env_level, uint8_t velocity) {
    // Map envelope and velocity to filter and amp CVs
    voice_regs[v].filter_cv = (env_level * velocity) >> 10;
    voice_regs[v].amp_cv = (env_level * velocity) >> 10;
}
```

### 30.275.4 Panel/Display Scan, Debounce, and Event Queue

```c
#define PANEL_ROWS 8
#define PANEL_COLS 8

uint8_t panel_matrix[PANEL_ROWS][PANEL_COLS];
uint8_t panel_debounce[PANEL_ROWS][PANEL_COLS];

void scan_panel() {
    for (int r = 0; r < PANEL_ROWS; ++r) {
        select_panel_row(r);
        delay_us(2);
        uint8_t cols = read_panel_cols();
        for (int c = 0; c < PANEL_COLS; ++c) {
            bool pressed = (cols >> c) & 1;
            if (pressed != panel_matrix[r][c]) {
                if (++panel_debounce[r][c] > 2) {
                    panel_matrix[r][c] = pressed;
                    queue_panel_event(r, c, pressed);
                    panel_debounce[r][c] = 0;
                }
            } else {
                panel_debounce[r][c] = 0;
            }
        }
    }
}
```

---

## 30.276 Appendices: Schematics, Pinouts, Wavetable Maps, Service Tables

### 30.276.1 Voice Card Schematic (Text, Partial)

```
[Wavetable ROM]--[Addr Logic]<--[Phase Accum]---[DAC]---[VCF/SSM2044]---[VCA/SSM2024]---[AA Filter]---[Opamp]---[Sum Bus]
    |                 |                |             |            |                |             
[LFO/Env Mod]    [Wave Pos]       [Loop Logic]   [CV DAC]    [CV DAC]         [CV DAC]
```

### 30.276.2 Wavetable Map Table (Example)

| Table # | Waveforms | Samples/Wave | Bits/Sample | Notes        |
|---------|-----------|--------------|-------------|--------------|
| 0       | 64        | 128          | 8           | Sine-Pulse   |
| 1       | 64        | 128          | 8           | Harmonics    |
| 2       | 64        | 128          | 8           | Organ        |
| ...     | ...       | ...          | ...         | ...          |

### 30.276.3 Service Table

| Component    | Symptom               | Test/Remedy         |
|--------------|-----------------------|---------------------|
| RAM          | Missing voice, noise  | RAM test, swap      |
| DAC          | Distortion, silence   | Scope/test, replace |
| SSM2044      | No filter, dull sound | CV test, swap       |
| SSM2024      | Low output, dist      | Audio probe, swap   |
| Panel        | Dead keys, stuck LEDs | Scan, clean, swap   |

### 30.276.4 Pinout (Excerpt)

| Pin | Signal   | Description           |
|-----|----------|-----------------------|
| 1   | GND      | Ground                |
| 2   | +5V      | Digital supply        |
| 3   | D0       | Data bus 0            |
| 4   | D1       | Data bus 1            |
| ... | ...      | ...                   |

---