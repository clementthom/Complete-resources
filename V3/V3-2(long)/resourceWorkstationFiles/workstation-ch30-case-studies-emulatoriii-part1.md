# Chapter 30: Case Studies – Emulator III (Complete Deep-Dive)
## Part 1: System Architecture, Digital/Analog Hardware, and Sampling Engine

---

## Table of Contents

- 30.500 Introduction
- 30.501 Historical Context, Innovations, and System Overview
  - 30.501.1 Emulator III’s Market, Impact, and Legacy
  - 30.501.2 Key Innovations: 16-bit Sampling, SCSI, Modular Voices, Advanced UI
  - 30.501.3 Block Diagram and Major Subsystems
- 30.502 Hardware Architecture
  - 30.502.1 Mainframe, Power Supply, and Cardcage
  - 30.502.2 CPU Board: Microprocessor, RAM, ROM, Bus
  - 30.502.3 Voice Cards: Sample Playback, DAC, Filters, Polyphony
  - 30.502.4 Output/Mixer: Analog Summing, SSM Filters, Envelope Generators
  - 30.502.5 Storage: Floppy, SCSI Hard Disk, Battery RAM
  - 30.502.6 Keyboard, Panel, Display, and Remote
- 30.503 Digital Sampling and Sound Generation
  - 30.503.1 16-bit Sampling: ADC, Sample RAM, Clocking, Quantization
  - 30.503.2 Sample Playback: Addressing, Looping, Pitch, and Envelopes
  - 30.503.3 Voice Card: DAC, Analog Smoothing, Output Stage
  - 30.503.4 Polyphony and Mixing: Voice Allocation, Summing, Routing
  - 30.503.5 Sequencer: Event Model, Grid, and Data Structures
- 30.504 System Bus, Memory Map, and I/O
  - 30.504.1 Bus Protocol, Arbitration, and Timing
  - 30.504.2 Memory Map: OS, Sample Buffers, Voice Registers
  - 30.504.3 I/O: Panel, Display, Keyboard, Floppy, SCSI, MIDI, Sync
- 30.505 Example C Code: Sample Engine, Voice Scheduling, Sequencer, and I/O Handlers
  - 30.505.1 Sample RAM Access and Playback
  - 30.505.2 Voice Card/Polyphony Manager
  - 30.505.3 Sequencer Data Model
  - 30.505.4 Panel Event Queue
- 30.506 Appendices: Voice Card Schematics, Bus Pinouts, Memory/Voice Tables

---

## 30.500 Introduction

The E-mu Emulator III, released in 1987, marked the zenith of “classic” sampling technology before the workstation era became fully digital and software-driven. With 16-bit stereo sampling, a sophisticated SCSI-based storage system, modular voice architecture, and a highly flexible operating system, the EIII was a flagship for professional studios and soundtrack composers worldwide. Its design combined leading-edge digital and analog engineering, delivering a sound and workflow that is still revered (and emulated) today.

---

## 30.501 Historical Context, Innovations, and System Overview

### 30.501.1 Emulator III’s Market, Impact, and Legacy

- **Target Market**: High-end studios, composers, producers (Peter Gabriel, Depeche Mode, Jean-Michel Jarre).
- **Legacy**: Last “pure” hardware E-mu sampler before Proteus/softsampler era; raised the bar for fidelity, workflow, and storage.
- **Price Point**: $12,000–$15,000, depending on configuration.

### 30.501.2 Key Innovations: 16-bit Sampling, SCSI, Modular Voices, Advanced UI

- **16-bit Stereo Sampling**:
  - True 16-bit converters, up to 44.1kHz, stereo and mono, with advanced anti-aliasing filtering.
- **SCSI Storage**:
  - First major sampler with SCSI hard disk and removable media—fast, reliable, large libraries.
- **Modular Voices**:
  - Up to 16 polyphonic voices (expandable); each with independent sample RAM, DAC, filter, and envelope.
- **Advanced UI**:
  - LCD, keypad, soft buttons, numeric entry; deep editing, layering, and modulation capabilities.

### 30.501.3 Block Diagram and Major Subsystems

```
[Keyboard/Panel/Display]---+
                           |
                 [Host CPU/Memory/Bus]
                           |
    +---------+---------+---------+---------+---------+
    |         |         |         |         |         |
[Voice Cards][Disk I/O][Analog][Sample RAM][MIDI/Sync][Remote]
    |         |         |         |         |         |
 [DACs]  [SCSI/Floppy][VCF/VCA][RAM/EPROM][UARTs]  [RS422]
```

---

## 30.502 Hardware Architecture

### 30.502.1 Mainframe, Power Supply, and Cardcage

- **Chassis**:
  - 19” rackmount, multi-board backplane, linear power supply (+5V, ±12V), forced air cooling.
- **Cardcage**:
  - Modular: CPU board, voice cards, SCSI/floppy controller, analog output, expansion.

### 30.502.2 CPU Board: Microprocessor, RAM, ROM, Bus

- **CPU**:
  - Motorola 68000 @ 8MHz (main), Z80 or similar as I/O coprocessor.
- **RAM**:
  - 512KB–8MB DRAM, for OS, samples, and sequencing.
- **ROM**:
  - 64–512KB EPROM for bootloader, OS, diagnostics.
- **Bus**:
  - Proprietary 16-bit parallel, DMA support, address decoding via PAL/GAL, 74LS/HC logic.

### 30.502.3 Voice Cards: Sample Playback, DAC, Filters, Polyphony

- **Voice Card**:
  - Each: 1–2 voices, local DRAM/SRAM, digital pitch/loop logic, 16-bit DAC, analog VCF/VCA.
  - SSM2044/2045 (or CEM3328) filter per voice.
- **Pitch/Loop Logic**:
  - Address counters, programmable loop, dynamic pitch via variable rate clock.

### 30.502.4 Output/Mixer: Analog Summing, SSM Filters, Envelope Generators

- **Analog Summing**:
  - Voice outputs summed, routed through stereo/individual outs.
- **Filters**:
  - SSM/CEM filters for classic analog warmth, cutoff/resonance via CPU CV.
- **Envelope Generators**:
  - Per-voice, software-driven ADSR, mapped to amplitude and filter.

### 30.502.5 Storage: Floppy, SCSI Hard Disk, Battery RAM

- **Floppy**:
  - 3.5" HD, 720KB/1.44MB, for OS, banks, and sample transfer.
- **SCSI**:
  - Hard disk (20MB–2GB), SyQuest/Zip removable, multi-volume support.
- **Battery RAM**:
  - Patch/sequence retention, user settings.

### 30.502.6 Keyboard, Panel, Display, and Remote

- **Keyboard**:
  - 61/76 weighted keys, velocity, aftertouch, MIDI out.
- **Panel**:
  - Soft buttons, keypad, rotary encoder.
- **Display**:
  - 40x2 LCD or 240x64 graphics.
- **Remote**:
  - RS422 or MIDI for remote control, librarian, or editor.

---

## 30.503 Digital Sampling and Sound Generation

### 30.503.1 16-bit Sampling: ADC, Sample RAM, Clocking, Quantization

- **ADC**:
  - Stereo 16-bit converters, up to 44.1kHz, with precision anti-aliasing filters.
- **Sample RAM**:
  - DRAM, per voice or shared, fast DMA for loading/storing large samples.
- **Clocking**:
  - Programmable sample/loop rates for pitch shifting, fine/coarse tuning, sample start offset.
- **Quantization**:
  - Linear, with dither; 96dB SNR typical.

### 30.503.2 Sample Playback: Addressing, Looping, Pitch, and Envelopes

- **Addressing**:
  - Start, end, loop points; address pointer advanced per sample tick.
- **Looping**:
  - Forward, reverse, ping-pong, crossfade; all parameters user-editable.
- **Pitch**:
  - Variable rate playback, key-tracking, velocity curve.
- **Envelopes**:
  - Classic ADSR, with velocity and key-follow, modulates amplitude and filter.

### 30.503.3 Voice Card: DAC, Analog Smoothing, Output Stage

- **DAC**:
  - 16-bit monolithic (PCM56, AD1860, etc.), opamp buffer.
- **Smoothing**:
  - RC lowpass or active filter to remove digital noise.
- **Output Stage**:
  - Per-voice buffer, summed to main out, individual or group outs, balanced/unbalanced options.

### 30.503.4 Polyphony and Mixing: Voice Allocation, Summing, Routing

- **Voice Allocation**:
  - OS manages polyphony, assigns notes to free voices (stealing by age, release, or amplitude).
- **Mixing**:
  - Analog summing, stereo/quad/individual outs, user-assignable routing per patch.
- **Routing**:
  - Internal/external effects, group outs, panning, submixes.

### 30.503.5 Sequencer: Event Model, Grid, and Data Structures

- **Grid/Pattern Model**:
  - Step or real-time entry; patterns of notes/events, chainable into songs.
- **Event Data**:
  - Timestamp, type, note, velocity, duration, channel, CC, aftertouch.
- **Editing**:
  - Step, block, graphical, and parameter-based editing.

---

## 30.504 System Bus, Memory Map, and I/O

### 30.504.1 Bus Protocol, Arbitration, and Timing

- **Bus**:
  - 16-bit parallel, CPU master, voice cards/panel/storage/MIDI as slaves.
  - DMA for sample transfer, bus arbitration with priority for audio.
- **Timing**:
  - 8MHz system bus, adjustable wait states for different peripherals.

### 30.504.2 Memory Map: OS, Sample Buffers, Voice Registers

| Address         | Region        | Size      | Function           |
|-----------------|--------------|-----------|--------------------|
| 0x000000–0x07FFFF | OS ROM      | 512KB     | Boot, kernel, UI   |
| 0x080000–0x0FFFFF | OS RAM      | 512KB     | Vars, stack, patch |
| 0x100000–0x7FFFFF | Sample RAM  | up to 7MB | Samples, buffers   |
| 0x800000+      | Voice Regs    | 256B/card | Playback, env, filt|
| ...            | Storage, I/O  | ...       | SCSI, floppy, MIDI |

### 30.504.3 I/O: Panel, Display, Keyboard, Floppy, SCSI, MIDI, Sync

- **Panel/Display**:
  - Matrix scan, interrupt or polled; LCD/graphics buffer mapped in RAM.
- **Keyboard**:
  - Serial, matrix scan, interrupt-driven, MIDI merged.
- **Floppy/SCSI**:
  - WD1772/SCSI, DMA, IRQ for block transfer.
- **MIDI**:
  - UART-based, opto-isolated, 64–256 byte FIFO.
- **Sync**:
  - Tape sync, MIDI clock, external triggers.

---

## 30.505 Example C Code: Sample Engine, Voice Scheduling, Sequencer, and I/O Handlers

### 30.505.1 Sample RAM Access and Playback

```c
#define SAMPLE_RAM_SIZE 1048576
uint16_t sample_ram[SAMPLE_RAM_SIZE];

typedef struct {
    uint32_t start, end, loop, pos, step;
    uint16_t env;
    uint8_t active;
} voice_t;

void tick_voice(voice_t* v) {
    if (!v->active) return;
    v->pos += v->step;
    if (v->pos >= v->end) {
        if (v->loop) v->pos = v->loop;
        else v->active = 0;
    }
    uint16_t sample = sample_ram[v->pos];
    output_to_dac(sample * v->env / 65535);
}
```

### 30.505.2 Voice Card/Polyphony Manager

```c
#define VOICES 16
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

void assign_voice(uint32_t start, uint32_t end, uint32_t loop, uint32_t step, uint16_t env) {
    int v = find_free_voice();
    if (v < 0) v = steal_voice();
    voices[v] = (voice_t){start, end, loop, start, step, env, 1};
}
```

### 30.505.3 Sequencer Data Model

```c
#define SEQ_STEPS 64
#define SEQ_TRACKS 8

typedef struct {
    uint32_t time;
    uint8_t note, velocity, duration, gate;
} seq_event_t;

typedef struct {
    seq_event_t steps[SEQ_STEPS];
    uint16_t length;
} seq_track_t;

seq_track_t seq_tracks[SEQ_TRACKS];

void play_tracks() {
    for (int t = 0; t < SEQ_TRACKS; ++t)
        for (int s = 0; s < seq_tracks[t].length; ++s)
            if (seq_tracks[t].steps[s].gate)
                assign_voice(/*mapping logic*/);
}
```

### 30.505.4 Panel Event Queue

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

## 30.506 Appendices: Voice Card Schematics, Bus Pinouts, Memory/Voice Tables

### 30.506.1 Voice Card Schematic (Text, Partial)

```
[Bus]--[Addr/Control Logic]--[Sample RAM]--[Counter/Loop Logic]--[DAC]--[RC Filter]--[VCF (SSM2044)]--[Envelope]--[Opamp]--[Mix Bus]
    |           |                 |             |                |         |           |              |        |
[DMA/IRQ]  [Start/End/Loop]  [Pitch/Step]   [Env/LFO]        [CV DAC]   [Sweep CV]   [VCA/Panel]    [LEDs]  [Output]
```

### 30.506.2 Bus Pinout (Excerpt)

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

### 30.506.3 Memory/Voice Table (Example)

| Voice | RAM Start | RAM End  | Max Sample | DAC Bits | Poly |
|-------|-----------|----------|------------|----------|------|
| 0     | 0x100000  | 0x10FFFF | 64KB       | 16       | Yes  |
| 1     | 0x110000  | 0x11FFFF | 64KB       | 16       | Yes  |
| ...   | ...       | ...      | ...        | ...      | ...  |

---