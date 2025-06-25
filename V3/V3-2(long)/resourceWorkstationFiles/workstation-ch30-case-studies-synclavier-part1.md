# Chapter 30: Case Studies – Synclavier (Complete Deep-Dive)
## Part 1: System Architecture, DSP Hardware, and Sound Generation

---

## Table of Contents

- 30.300 Introduction
- 30.301 Historical Context, Innovations, and System Overview
  - 30.301.1 Synclavier’s Market, Impact, and Legacy
  - 30.301.2 Key Innovations: FM/Additive Synthesis, Polyphonic Sampling, Direct-to-Disk, Modular Design
  - 30.301.3 Block Diagram and Major Subsystems
- 30.302 Hardware Architecture
  - 30.302.1 Mainframe Chassis, Power Supply, and Modular Cardcage
  - 30.302.2 CPU/Host Board: Microprocessor, RAM, ROM, Bus Logic
  - 30.302.3 Voice DSP Cards: FM/Additive Synthesis, DACs, Polyphony
  - 30.302.4 Analog Interface: Input/Output, Amplifiers, Filters
  - 30.302.5 Storage: Winchester HDD, Floppy, Magneto-Optical, Direct-to-Disk
  - 30.302.6 Keyboard, Panel, Terminal, and Control Surfaces
- 30.303 Digital Synthesis and Sound Generation
  - 30.303.1 Additive Synthesis: Theory, Harmonics, and Data Structures
  - 30.303.2 FM Synthesis: Algorithm, Operator Routing, and Parameter Mapping
  - 30.303.3 Synclavier’s DSP: Architecture, Microcode, and Real-Time Scheduling
  - 30.303.4 Sample Playback: DAC, Voice Allocation, and Polyphony
  - 30.303.5 Direct-to-Disk Recording: Data Path, DMA, and Timing
- 30.304 System Bus, Memory Map, and I/O
  - 30.304.1 Bus Protocol, Arbitration, and Timing
  - 30.304.2 Memory Map: OS, Sample/Synth Buffers, DSP Registers
  - 30.304.3 I/O: Keyboard, Panel, Terminal, Floppy, Disk, MIDI, Sync
- 30.305 Example C Code: Additive/FM Engine, Voice Scheduling, and I/O Handlers
  - 30.305.1 Harmonic Data Structure and Additive Engine
  - 30.305.2 FM Operator Algorithm and Modulation Table
  - 30.305.3 Sample Block DMA Handler
  - 30.305.4 Voice/Polyphony Scheduler
  - 30.305.5 Keyboard/Panel Event Queue
- 30.306 Appendices: DSP Card Schematics, Bus Pinouts, Memory/Voice Tables

---

## 30.300 Introduction

The Synclavier, launched by New England Digital in the late 1970s, is a monument in the history of digital music workstations. Famed for its modular DSP architecture, real-time FM/additive synthesis, polyphonic sampling, direct-to-disk recording, and unique terminal-based UI, it became the centerpiece of top studios and soundtracks in the 1980s and 90s. Its complexity, power, and flexibility have never been fully matched, and its hardware/software design stands as a masterclass in integrated music technology.

---

## 30.301 Historical Context, Innovations, and System Overview

### 30.301.1 Synclavier’s Market, Impact, and Legacy

- **Target Market**: Major studios, film composers, sound designers, top-tier musicians (Stevie Wonder, Michael Jackson, Frank Zappa, Trevor Horn, Sting).
- **Legacy**: First digital workstation with FM/additive synthesis and sampling; direct-to-disk multitrack; modular, expandable, and networkable.
- **Price Point**: $30,000–$400,000+ depending on era and configuration.

### 30.301.2 Key Innovations: FM/Additive Synthesis, Polyphonic Sampling, Direct-to-Disk, Modular Design

- **Additive Synthesis**:  
  - 24–96 harmonics, per-voice, per-note, real-time control, morphing envelopes.
- **FM Synthesis**:  
  - Multi-operator, flexible algorithm, real-time parameter modulation.
- **Polyphonic Sampling**:  
  - True 16-bit/50–100kHz, stereo, with voice layering, key splits, and DSP effects.
- **Direct-to-Disk**:  
  - Multitrack digital audio recording/playback, ultra-low latency, seamless integration with synthesis engine.
- **Modular DSP**:  
  - Expandable voice cards, separate disk and audio buses, networked control surfaces.

### 30.301.3 Block Diagram and Major Subsystems

```
[Terminal/Panel/Keyboard]---+
                            |
                  [Host CPU/Memory/Bus]
                            |
        +---------+---------+---------+---------+---------+
        |         |         |         |         |         |
    [DSP Cards][Disk I/O][Analog][Sample RAM][MIDI/Sync][Network]
        |         |         |         |         |         |
     [DACs]  [SCSI/Floppy][VCF/VCA][DRAM/SRAM][UARTs]  [Ethernet]
```

---

## 30.302 Hardware Architecture

### 30.302.1 Mainframe Chassis, Power Supply, and Modular Cardcage

- **Chassis**:  
  - 19” rackmount, steel/aluminum, modular cardcage with passive backplane, heavy-duty multi-rail linear PSU (+5V, ±12V, +24V), forced air cooling.
- **Cardcage**:  
  - Up to 12–32 slots; host CPU card, multiple DSP voice cards, disk controllers, analog I/O, MIDI, etc.

### 30.302.2 CPU/Host Board: Microprocessor, RAM, ROM, Bus Logic

- **CPU**:  
  - Early: Data General Nova minicomputer; later: Motorola 68000/68020 (16/32-bit), or custom NED CPU.
  - Clock: 8–20 MHz typical.
- **RAM**:  
  - 256KB–8MB, socketed DRAM/SRAM, for OS, patch, and sample buffers.
- **ROM**:  
  - 64–512KB, EPROM/EEPROM; bootloader, diagnostics, monitor.
- **Support Logic**:  
  - PAL/GAL/CPLD address decoding, 74LS/HC for bus, timers, interrupt controllers.
- **Bus**:  
  - Custom parallel bus, up to 32 bits, with DMA support for voice cards, sample RAM, and disk.

### 30.302.3 Voice DSP Cards: FM/Additive Synthesis, DACs, Polyphony

- **DSP Card**:  
  - Each card: 4–8 voices, each with dedicated microcode DSP (bit-slice, custom, or TMS32010/20/68000), local RAM, and DAC.
  - **Additive Engine**: Real-time summing of 24–96 sine/cosine harmonics per voice, shaped by dynamic envelopes.
  - **FM Engine**: Multiple operators, operator routing matrix, feedback path, real-time modulation.
  - **Sample Playback**: 16-bit sample engine, anti-aliasing & interpolation, with RAM buffer.
- **DAC**:  
  - 16–20 bit, monolithic (Burr-Brown PCM54/PCM56, Analog Devices AD1860, etc.), with opamp buffer.
- **Polyphony**:  
  - System can scale from 8 to 96+ voices by adding DSP cards.

### 30.302.4 Analog Interface: Input/Output, Amplifiers, Filters

- **Input**:  
  - Balanced line/mic in, pad, preamp, 7th order Bessel/Butterworth anti-aliasing filter.
- **Output**:  
  - Each DSP card output summed, sent through analog line driver (NE5532, TL072) to main outs (stereo/quad), optional EQ, insert points.

### 30.302.5 Storage: Winchester HDD, Floppy, Magneto-Optical, Direct-to-Disk

- **Floppy**:  
  - 8”/5.25”, 500KB–1.2MB, OS and patch storage.
- **Hard Disk**:  
  - SCSI, MFM, or custom controller; 20–2000MB, hot-swappable in later models.
- **Magneto-Optical**:  
  - Used for long-form audio storage, backups, and libraries.
- **Direct-to-Disk**:  
  - Multitrack audio streams written/read in real-time to disk; DMA and sector interleaving ensure glitch-free operation.

### 30.302.6 Keyboard, Panel, Terminal, and Control Surfaces

- **Keyboard**:  
  - 76/88 weighted keys, polyphonic aftertouch, velocity, proprietary scan matrix.
- **Panel**:  
  - Softkey array, rotary encoders, numeric pad, LED indicators.
- **Terminal**:  
  - VT100/ANSI terminal, later custom Synclavier keyboard with CRT or plasma display.

---

## 30.303 Digital Synthesis and Sound Generation

### 30.303.1 Additive Synthesis: Theory, Harmonics, and Data Structures

- **Theory**:  
  - Sound is created by summing sine/cosine harmonics, each with independent amplitude and phase envelopes.
  - Up to 96 harmonics per voice; envelope resolution of 256–1024 points.
- **Data Structure**:
  ```c
  typedef struct {
      float amp[96];
      float phase[96];
      float freq[96];
      float env[96][1024];
  } additive_voice_t;
  ```
- **Implementation**:  
  - DSP calculates sum of all harmonics per sample, applies envelope, writes to DAC.

### 30.303.2 FM Synthesis: Algorithm, Operator Routing, and Parameter Mapping

- **FM Engine**:  
  - 4–8 operators per voice, each can modulate any other (including feedback).
  - Operator: sine generator, EG, frequency ratio, output level.
  - Algorithm defined as a routing matrix (NxN).
- **Parameter Mapping**:
  ```c
  typedef struct {
      float freq_ratio[8];
      float mod_index[8][8];
      float eg[8][256];
  } fm_voice_t;
  ```
- **Implementation**:  
  - At each sample, operators modulate each other according to algorithm, output summed and written to DAC.

### 30.303.3 Synclavier’s DSP: Architecture, Microcode, and Real-Time Scheduling

- **DSP Core**:  
  - Bit-slice or custom microcoded processor, parallel accumulation, fast sine/cos tables in local RAM/ROM.
- **Microcode**:  
  - Custom instruction set for envelope, harmonic sum, FM modulation, sample fetch.
- **Scheduling**:  
  - Real-time, sample-accurate, parallel processing for all active voices.

### 30.303.4 Sample Playback: DAC, Voice Allocation, and Polyphony

- **Sample Engine**:  
  - 16–20 bit samples, RAM or streamed from disk, interpolation for pitch shift.
- **Voice Allocation**:  
  - OS manages pool of voices; assigns samples to available DSP engines, handles release/steal.
- **Polyphony**:  
  - 8–32 voices per system, expandable via additional DSPs.

### 30.303.5 Direct-to-Disk Recording: Data Path, DMA, and Timing

- **Data Path**:  
  - Audio input digitized, DMA’d directly to disk in frames/blocks.
- **DMA**:  
  - High-speed transfer, real-time sector allocation, buffer underrun/overrun protection.
- **Timing**:  
  - Host CPU coordinates disk, DSP, and UI for sample-accurate sync.

---

## 30.304 System Bus, Memory Map, and I/O

### 30.304.1 Bus Protocol, Arbitration, and Timing

- **Bus Protocol**:  
  - 16/32-bit parallel, multiplexed address/data, CPU as master, DSP cards as slaves.
  - DMA for sample engine, disk I/O.
- **Arbitration**:  
  - Priority for audio/DSP; lower for disk, UI, MIDI.
  - Bus grant, wait, and interrupt lines.

### 30.304.2 Memory Map: OS, Sample/Synth Buffers, DSP Registers

| Address      | Region              | Size       | Function           |
|--------------|---------------------|------------|--------------------|
| 0x000000–0x03FFFF | OS ROM        | 256KB      | Boot, Kernel       |
| 0x040000–0x0FFFFF | OS RAM        | 960KB      | Variables, Stack   |
| 0x100000–0x3FFFFF | Sample RAM    | 3MB        | Samples, Buffers   |
| 0x400000+         | DSP Regs      | 256B/card  | Synth, FM, Sample  |
| ...              | Disk, I/O      | ...        | Peripherals        |

### 30.304.3 I/O: Keyboard, Panel, Terminal, Floppy, Disk, MIDI, Sync

- **Keyboard**:  
  - Matrix scanned, velocity/aftertouch, interrupt-driven.
- **Panel/Terminal**:  
  - VT100/ANSI protocol, mapped to event queue; softkey/encoder events polled or interrupt.
- **Floppy/Disk**:  
  - SCSI, WD1772, or custom; DMA and IRQ for sector/block transfer.
- **MIDI**:  
  - UART-based, opto-isolated, merged with panel/key events.
- **Sync**:  
  - SMPTE, FSK, MIDI clock in/out; chase lock for multitrack sync.

---

## 30.305 Example C Code: Additive/FM Engine, Voice Scheduling, and I/O Handlers

### 30.305.1 Harmonic Data Structure and Additive Engine

```c
#define HARMONICS 96

typedef struct {
    float amp[HARMONICS];
    float phase[HARMONICS];
    float freq[HARMONICS];
} voice_additive_t;

float compute_sample(voice_additive_t* v, float t) {
    float out = 0.0f;
    for (int h = 0; h < HARMONICS; ++h) {
        out += v->amp[h] * sinf(2 * M_PI * v->freq[h] * t + v->phase[h]);
    }
    return out;
}
```

### 30.305.2 FM Operator Algorithm and Modulation Table

```c
#define OPS 8

typedef struct {
    float freq[OPS];
    float phase[OPS];
    float mod_index[OPS][OPS];
    float output[OPS];
} fm_voice_t;

void compute_fm_sample(fm_voice_t* v, float t) {
    for (int op = 0; op < OPS; ++op) {
        float mod = 0.0f;
        for (int src = 0; src < OPS; ++src) {
            mod += v->mod_index[op][src] * v->output[src];
        }
        v->output[op] = sinf(2 * M_PI * v->freq[op] * t + v->phase[op] + mod);
    }
}
```

### 30.305.3 Sample Block DMA Handler

```c
void dma_sample_block(uint32_t src, uint32_t dst, uint32_t len, uint16_t* ram) {
    for (uint32_t i = 0; i < len; ++i)
        ram[dst + i] = ram[src + i];
}
```

### 30.305.4 Voice/Polyphony Scheduler

```c
#define VOICES 32

typedef struct {
    int active;
    int note;
    int age;
} poly_voice_t;

poly_voice_t poly[VOICES];

int find_free_voice() {
    for (int i = 0; i < VOICES; ++i)
        if (!poly[i].active) return i;
    int oldest = 0;
    for (int i = 1; i < VOICES; ++i)
        if (poly[i].age > poly[oldest].age) oldest = i;
    return oldest;
}

void assign_voice(int note) {
    int v = find_free_voice();
    poly[v].active = 1;
    poly[v].note = note;
    poly[v].age = 0;
}
```

### 30.305.5 Keyboard/Panel Event Queue

```c
#define EVENT_BUF 64

typedef struct {
    int type;
    int data1, data2;
} event_t;

event_t event_queue[EVENT_BUF];
int evt_head = 0, evt_tail = 0;

void queue_event(int type, int d1, int d2) {
    event_queue[evt_head].type = type;
    event_queue[evt_head].data1 = d1;
    event_queue[evt_head].data2 = d2;
    evt_head = (evt_head + 1) % EVENT_BUF;
}

event_t next_event() {
    event_t e = event_queue[evt_tail];
    evt_tail = (evt_tail + 1) % EVENT_BUF;
    return e;
}
```

---

## 30.306 Appendices: DSP Card Schematics, Bus Pinouts, Memory/Voice Tables

### 30.306.1 DSP Card Schematic (Text, Partial)

```
[Host Bus]--[Addr Decode]--[DSP Core]--[RAM/ROM]--[Microcode]--[Additive/FM Engine]--[DAC]--[Opamp]--[Sum Bus]
     |             |             |             |          |            |             |         |         |
[DMA Logic]  [Bus Arbiter]   [Voice Regs]  [Sin/Cos LUT] |            |         [Sample Engine]    [Out]
```

### 30.306.2 Bus Pinout (Excerpt)

| Pin | Signal   | Description           |
|-----|----------|-----------------------|
| 1   | GND      | Ground                |
| 2   | +5V      | Digital supply        |
| 3   | D0       | Data bus 0            |
| 4   | D1       | Data bus 1            |
| ... | ...      | ...                   |
| 32  | REQ      | Bus Request           |
| 33  | ACK      | Bus Acknowledge       |
| 34  | INT      | Interrupt             |

### 30.306.3 Memory/Voice Table (Example)

| Voice | RAM Start | RAM End  | Max Sample | Synth Type | DSP Bits | Poly |
|-------|-----------|----------|------------|------------|----------|------|
| 0     | 0x100000  | 0x10FFFF | 64KB       | Add/FM/Smp | 16       | Yes  |
| 1     | 0x110000  | 0x11FFFF | 64KB       | Add/FM/Smp | 16       | Yes  |
| ...   | ...       | ...      | ...        | ...        | ...      | ...  |

---