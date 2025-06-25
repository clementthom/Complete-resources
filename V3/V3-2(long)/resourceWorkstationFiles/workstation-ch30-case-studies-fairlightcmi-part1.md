# Chapter 30: Case Studies – Fairlight CMI (Complete Deep-Dive)
## Part 1: System Architecture, Digital/Analog Hardware, and Sound Generation

---

## Table of Contents

- 30.400 Introduction
- 30.401 Historical Context, Innovations, and System Overview
  - 30.401.1 Fairlight CMI’s Market, Impact, and Legacy
  - 30.401.2 Key Innovations: Digital Sampling, Page-R, Lightpen UI, Modular Expansion
  - 30.401.3 Block Diagram and Major Subsystems
- 30.402 Hardware Architecture
  - 30.402.1 Mainframe, Power Supply, and Card Cage
  - 30.402.2 CPU Board: Microprocessor, RAM, ROM, Bus
  - 30.402.3 Voice Cards: 8-bit/12-bit Sample Playback, DAC, Polyphony
  - 30.402.4 Analog Filter/Output: SSM Filters, Mixing, Envelope Generators
  - 30.402.5 Storage: 8"/5.25" Floppy, Hard Disk, Tape, Battery RAM
  - 30.402.6 Lightpen, Monitor, Keyboard, and Panel
- 30.403 Digital Sampling and Sound Generation
  - 30.403.1 Digital Sampling: ADC, Sample RAM, Clocking, Quantization
  - 30.403.2 Sample Playback: Addressing, Looping, Pitch, and Envelopes
  - 30.403.3 Voice Card: DAC, Analog Smoothing, Output Stage
  - 30.403.4 Polyphony and Mixing: Voice Allocation, Summing, Routing
  - 30.403.5 Page-R Sequencer: Event Model, Grid, and Data Structures
- 30.404 System Bus, Memory Map, and I/O
  - 30.404.1 Bus Protocol, Arbitration, and Timing
  - 30.404.2 Memory Map: OS, Sample Buffers, Voice Registers
  - 30.404.3 I/O: Lightpen, Monitor, Keyboard, Floppy, Disk, MIDI, Sync
- 30.405 Example C Code: Sample Engine, Voice Scheduling, Page-R, and I/O Handlers
  - 30.405.1 Sample RAM Access and Playback
  - 30.405.2 Voice Card/Polyphony Manager
  - 30.405.3 Page-R Step Sequencer Model
  - 30.405.4 Panel/Lightpen Event Queue
- 30.406 Appendices: Voice Card Schematics, Bus Pinouts, Memory/Voice Tables

---

## 30.400 Introduction

The Fairlight CMI (Computer Musical Instrument), developed in Australia and launched in the late 1970s, was the world’s first commercially available digital sampler and music workstation. Famous for its lightpen graphical interface, Page-R step sequencer, and iconic sound libraries, it rewrote music production, influencing artists like Peter Gabriel, Herbie Hancock, Kate Bush, and countless others. Its unique blend of hardware and software, from the CPU mainframe to custom voice cards, stands as a landmark in electronic music engineering.

---

## 30.401 Historical Context, Innovations, and System Overview

### 30.401.1 Fairlight CMI’s Market, Impact, and Legacy

- **Target Market**: Top studios, composers, producers, and sound designers (Stevie Wonder, Trevor Horn, Thomas Dolby).
- **Legacy**: First digital sampling workstation; established the visual, graphical approach to sound design and sequencing.
- **Price Point**: $25,000–$100,000+ depending on configuration.

### 30.401.2 Key Innovations: Digital Sampling, Page-R, Lightpen UI, Modular Expansion

- **Digital Sampling**:
  - 8-bit (Series I/II), 12-bit (Series III), up to 32kHz/100kHz sample rates.
  - Real-time sample editing, looping, truncation, and pitch shifting.
- **Page-R Sequencer**:
  - Iconic grid-based step sequencer with pattern chaining, groove, and live editing.
- **Lightpen UI**:
  - Direct graphical editing, waveform drawing, parameter access.
- **Modular Expansion**:
  - Expandable voice cards, additional RAM, disk, and interface cards.

### 30.401.3 Block Diagram and Major Subsystems

```
[Lightpen/Monitor/Keyboard]---+
                              |
                    [Host CPU/Memory/Bus]
                              |
     +---------+---------+---------+---------+---------+
     |         |         |         |         |         |
 [Voice Cards][Disk I/O][Analog][Sample RAM][MIDI/Sync][Panel]
     |         |         |         |         |         |
  [DACs]  [Floppy/HDD][VCF/VCA][RAM/EPROM][UARTs]  [LEDs]
```

---

## 30.402 Hardware Architecture

### 30.402.1 Mainframe, Power Supply, and Card Cage

- **Chassis**:
  - 19” rackmount or bespoke mainframe, modular card cage (Eurocard/Proprietary), high-current linear PSU (+5V, ±12V).
- **Card Cage**:
  - CPU board, up to 16 voice cards, disk controller, analog output, and expansion slots.

### 30.402.2 CPU Board: Microprocessor, RAM, ROM, Bus

- **CPU**:
  - Series I/II: Motorola 6800/6809 at 1–2 MHz; Series III: 68000 at 8 MHz.
- **RAM**:
  - 32KB–2MB DRAM/SRAM, for OS, sequencer, sample buffers.
- **ROM**:
  - 16–128KB EPROM for boot, diagnostics, monitor, and main OS.
- **Bus**:
  - Proprietary parallel bus, 8/16 bit data, 16/24 bit address.
  - Address decoding via PAL/GAL and 74LS/HC glue logic.

### 30.402.3 Voice Cards: 8-bit/12-bit Sample Playback, DAC, Polyphony

- **Voice Card**:
  - Each card: 1–2 voices, local sample RAM, address logic, DAC (8/12-bit), analog smoothing.
  - Multi-card systems for 8–32 voice polyphony.
- **Sample Playback**:
  - Address counter, loop/one-shot logic, dynamic pitch control, envelope mod.
- **DAC**:
  - 8-bit (Series I/II: DAC08, AD558), 12-bit (Series III: AD7541, etc.), opamp buffer.

### 30.402.4 Analog Filter/Output: SSM Filters, Mixing, Envelope Generators

- **Filters**:
  - SSM2044/2040 per voice or group; cutoff/resonance via CV.
- **Mixing**:
  - Summing bus, stereo/quad output, individual outs in Series III.
- **Envelope**:
  - Software or hardware-generated ADSR, mapped to amplitude and/or filter.

### 30.402.5 Storage: 8"/5.25" Floppy, Hard Disk, Tape, Battery RAM

- **Floppy**:
  - 8” (SSSD/DSSD), 5.25” (SSDD), 256–1,200KB per disk, OS, samples, sequences.
- **Hard Disk**:
  - SASI/SCSI, 5–100MB, added in later models.
- **Tape**:
  - Optional for sample/patch backup.
- **Battery RAM**:
  - For settings, sequence, and patch retention.

### 30.402.6 Lightpen, Monitor, Keyboard, and Panel

- **Lightpen**:
  - CRT-coupled, outputs X/Y via photodiode; polled by CPU for graphical editing.
- **Monitor**:
  - Composite monochrome or color CRT, 512x256–640x400 resolution.
- **Keyboard**:
  - 73/88 weighted keys, velocity, proprietary scan/serial protocol.
- **Panel**:
  - Tactile switches, LEDs for transport, patch, and service functions.

---

## 30.403 Digital Sampling and Sound Generation

### 30.403.1 Digital Sampling: ADC, Sample RAM, Clocking, Quantization

- **ADC**:
  - 8-bit (Series I/II: ADC0804), 12-bit (Series III: AD7574), sample clock up to 32kHz/100kHz.
- **Sample RAM**:
  - DRAM/SRAM, per voice or shared; DMA for fast load/save.
- **Quantization**:
  - Linear, companding optional; SNR: ~48dB (8-bit), ~72dB (12-bit).
- **Clocking**:
  - Programmable divider for variable pitch/sample rate.

### 30.403.2 Sample Playback: Addressing, Looping, Pitch, and Envelopes

- **Addressing**:
  - Start, end, loop pointers per sample; address counter increments at pitch rate.
- **Pitch**:
  - Variable playback rate via clock divider; coarse/fine tuning.
- **Looping**:
  - Simple (start-end), crossfade, or one-shot; adjustable in UI.
- **Envelope**:
  - Software-generated ADSR, per voice; maps to amplitude and optionally filter.

### 30.403.3 Voice Card: DAC, Analog Smoothing, Output Stage

- **DAC**:
  - 8/12-bit, R-2R or monolithic; opamp buffer, zero-centered or unipolar output.
- **Smoothing**:
  - RC low-pass or active filter to reduce quantization noise.
- **Output**:
  - Per-voice, summed to main out, individual outs (Series III).

### 30.403.4 Polyphony and Mixing: Voice Allocation, Summing, Routing

- **Voice Allocation**:
  - Software-managed pool; note-on assigned to available voice card.
  - Stealing: oldest, lowest amplitude, or release-phase.
- **Mixing**:
  - Summing amp, stereo/quad/individual out selection.
- **Routing**:
  - User-assignable, per-patch or per-note.

### 30.403.5 Page-R Sequencer: Event Model, Grid, and Data Structures

- **Grid Model**:
  - Steps (columns) × tracks (rows); each cell holds note, velocity, duration, and gate.
  - Patterns chained to form songs with repeats, fills, and tempo changes.
- **Real-Time/Step Mode**:
  - Step entry/edit, real-time recording, quantize, swing/humanize.

---

## 30.404 System Bus, Memory Map, and I/O

### 30.404.1 Bus Protocol, Arbitration, and Timing

- **Bus Protocol**:
  - 8/16-bit parallel, CPU master, voice cards and panel as slaves.
  - DMA for sample load/save.
- **Arbitration**:
  - Priority for audio/voice; lower for disk, UI, MIDI.
  - Interrupts: DMA complete, audio tick, panel/lightpen, floppy, error.

### 30.404.2 Memory Map: OS, Sample Buffers, Voice Registers

| Address      | Region             | Size     | Function           |
|--------------|--------------------|----------|--------------------|
| 0x0000–0x3FFF| OS ROM             | 16KB     | Boot, Kernel       |
| 0x4000–0xBFFF| OS RAM             | 32KB     | Vars, Stack        |
| 0xC000–0xFFFF| Sample RAM         | 16KB     | Samples, Buffers   |
| ...          | Voice Regs         | ...      | Playback, Env      |

### 30.404.3 I/O: Lightpen, Monitor, Keyboard, Floppy, Disk, MIDI, Sync

- **Lightpen**:
  - X/Y input, interrupt-driven or polled by CPU.
- **Monitor**:
  - Mapped to graphics memory, updated by CPU.
- **Keyboard**:
  - Serial/matrix scan, interrupt or polled.
- **Floppy/Disk**:
  - WD1772/SCSI, DMA and IRQ for sector/block transfer.
- **MIDI**:
  - UART, opto-isolated, merged with panel events.
- **Sync**:
  - Tape sync, clock in/out, MIDI clock in/out.

---

## 30.405 Example C Code: Sample Engine, Voice Scheduling, Page-R, and I/O Handlers

### 30.405.1 Sample RAM Access and Playback

```c
#define SAMP_RAM_SIZE 16384
uint8_t sample_ram[SAMP_RAM_SIZE];

typedef struct {
    uint16_t start, end, loop;
    uint16_t pos;
    uint16_t step;
    uint8_t env;
    uint8_t active;
} voice_t;

void tick_voice(voice_t* v) {
    if (!v->active) return;
    v->pos += v->step;
    if (v->pos >= v->end) {
        if (v->loop)
            v->pos = v->loop;
        else
            v->active = 0;
    }
    uint8_t sample = sample_ram[v->pos];
    output_to_dac(sample * v->env / 255);
}
```

### 30.405.2 Voice Card/Polyphony Manager

```c
#define VOICES 8
voice_t voices[VOICES];

int find_free_voice() {
    for (int i = 0; i < VOICES; ++i)
        if (!voices[i].active) return i;
    return -1;
}

int steal_voice() {
    int oldest = 0;
    for (int i = 1; i < VOICES; ++i)
        if (voices[i].pos > voices[oldest].pos) oldest = i;
    return oldest;
}

void assign_voice(uint16_t start, uint16_t end, uint16_t loop, uint16_t step, uint8_t env) {
    int v = find_free_voice();
    if (v < 0) v = steal_voice();
    voices[v] = (voice_t){start, end, loop, start, step, env, 1};
}
```

### 30.405.3 Page-R Step Sequencer Model

```c
#define PAGE_R_STEPS  32
#define PAGE_R_TRACKS 8

typedef struct {
    uint8_t note;
    uint8_t velocity;
    uint8_t duration;
    uint8_t gate;
} page_r_step_t;

page_r_step_t page_r_grid[PAGE_R_TRACKS][PAGE_R_STEPS];

void play_page_r(int pattern) {
    for (int s = 0; s < PAGE_R_STEPS; ++s) {
        for (int t = 0; t < PAGE_R_TRACKS; ++t) {
            page_r_step_t* st = &page_r_grid[t][s];
            if (st->gate) assign_voice(/*map note to sample/voice params*/);
        }
        wait_ms(100); // Step time
    }
}
```

### 30.405.4 Panel/Lightpen Event Queue

```c
#define EVENT_BUF 32

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

## 30.406 Appendices: Voice Card Schematics, Bus Pinouts, Memory/Voice Tables

### 30.406.1 Voice Card Schematic (Text, Partial)

```
[CPU Bus]--[Addr Logic]--[Sample RAM]--[Counter]--[DAC]--[RC Filter]--[SSM2044]--[Opamp]--[Sum Bus]
    |           |             |           |         |       |            |          |         |
[Loop/OneShot]  |         [Step]     [Env/LFO]  [CV DAC] [Panel LED] [CV DAC]   [Panel]   [Out]
```

### 30.406.2 Bus Pinout (Excerpt)

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

### 30.406.3 Memory/Voice Table (Example)

| Voice | RAM Start | RAM End  | Max Sample | DAC Bits | Poly | Series |
|-------|-----------|----------|------------|----------|------|--------|
| 0     | 0xC000    | 0xCFFF   | 4KB        | 8        | Yes  | I/II   |
| 1     | 0xD000    | 0xDFFF   | 4KB        | 8        | Yes  | I/II   |
| ...   | ...       | ...      | ...        | ...      | ...  | ...    |

---