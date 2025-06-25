# Chapter 30: Case Studies – Fairlight CMI (Complete Deep-Dive)
## Part 1: System Architecture, Sampling Hardware, and Sound Generation

---

## Table of Contents

- 30.230 Introduction
- 30.231 Historical Context, Innovations, and System Overview
  - 30.231.1 Fairlight’s Market, Impact, and Legacy
  - 30.231.2 Key Innovations: Digital Sampling, Page R, Light Pen UI
  - 30.231.3 Block Diagram and Major Subsystems
- 30.232 Hardware Architecture
  - 30.232.1 Mainframe Chassis and Card Backplane
  - 30.232.2 CPU Board: Microprocessor, RAM, ROM, Control Logic
  - 30.232.3 Channel Cards: Sample Playback, DACs, and Voice Handling
  - 30.232.4 Analog Interface: Input/Output, Amplifiers, Filters
  - 30.232.5 Storage: Floppy, Hard Disk, and Backup
  - 30.232.6 Light Pen and Display: CRT, Graphics, and Input
- 30.233 Digital Sampling and Sound Generation
  - 30.233.1 Sampling Theory: Quantization, Rates, and Aliasing
  - 30.233.2 Fairlight’s ADC: Circuit, Resolution, and SNR
  - 30.233.3 Sample Storage: RAM Architecture, Paging, and Limits
  - 30.233.4 Playback Engines: Channel Card Digital Logic and DAC
  - 30.233.5 Polyphony and Voice Allocation: Real-Time Scheduling
- 30.234 System Bus, Memory Map, and I/O
  - 30.234.1 Q-bus Protocol, Arbitration, and Timing
  - 30.234.2 Memory Map: OS, Sample Buffers, Channel Registers
  - 30.234.3 I/O: Keyboard, Light Pen, Floppy, MIDI, Sync
- 30.235 Example C Code: Sample Playback, Channel Scheduling, and I/O Handlers
  - 30.235.1 Channel Register Read/Write
  - 30.235.2 Sample Block DMA Handler
  - 30.235.3 Keyboard Scan, Debounce, and Event Queue
  - 30.235.4 Light Pen Event Handler
- 30.236 Appendices: Schematics, Bus Pinouts, and Memory/Voice Tables

---

## 30.230 Introduction

The Fairlight CMI (Computer Musical Instrument), originating in Australia in 1979, is universally recognized as the first commercially available digital sampling workstation. It brought together digital audio recording, synthesis, sequencing, and an iconic graphical user interface operated by a light pen on a CRT screen. Its technological innovations, sound, and interface became deeply influential in the 1980s, shaping pop, electronic, and film music.

---

## 30.231 Historical Context, Innovations, and System Overview

### 30.231.1 Fairlight’s Market, Impact, and Legacy

- **Target Market**: Studios, composers, film scorers, and pioneering pop artists (Peter Gabriel, Kate Bush, Stevie Wonder).
- **Legacy**: Invented the term “sampling” in music, introduced user-editable waveforms, and pioneered graphical sequencing.
- **Price Point**: $20,000–$100,000 depending on era and configuration.

### 30.231.2 Key Innovations: Digital Sampling, Page R, Light Pen UI

- **Digital Sampling**:  
  - User-recorded sound snippets (8-bit, later 16-bit), mapped chromatically and played polyphonically.
- **Page R Sequencer**:  
  - Grid-based, non-linear sequencer with visual pattern editing.
- **Light Pen UI**:  
  - CRT-based graphics, direct manipulation of waveforms, envelopes, and arrangements via light pen.

### 30.231.3 Block Diagram and Major Subsystems

```
[Keyboard/Light Pen]---+
                       |
               [CRT/Display/Panel]
                       |
                 [Backplane/Q-bus]
                       |
     +-----------+-----+-----+-------------+-------------+
     |           |           |             |             |
 [CPU Board] [Channel Cards] [Analog I/O] [Disk/Floppy] [MIDI/Sync]
     |            |             |             |             |
   [RAM/ROM]   [DAC/Logic]  [ADC/Preamp]   [FDD/HDD]   [Ext. Control]
```

---

## 30.232 Hardware Architecture

### 30.232.1 Mainframe Chassis and Card Backplane

- **Chassis**:  
  - 19” rackmount steel/aluminum frame, heavy linear PSU, forced air cooling.
- **Backplane**:  
  - Proprietary Q-bus (not to be confused with DEC Q-bus); 64–96 pins/slot, with multiple voltage rails (+5V, ±12V).
  - Modular card slots: CPU, up to 8 channel cards, analog, disk, display, I/O.

### 30.232.2 CPU Board: Microprocessor, RAM, ROM, Control Logic

- **CPU**:  
  - Fairlight Series I: Motorola 6800; Series II/III: 6809, later 68000 (8/16/32 bit, 1–8 MHz).
- **RAM**:  
  - 16–32KB (Series I), up to 512KB (Series III) for OS, patches, and sample buffer.
- **ROM**:  
  - 8–64KB EPROM; bootloader, monitor, diagnostics.
- **Support Logic**:  
  - PAL/GAL for address decoding, 74LS/HC glue logic, timer/counter chips for event scheduling.
- **Bus Interface**:  
  - CPU is master; DMA or channel cards request bus during playback/record.

### 30.232.3 Channel Cards: Sample Playback, DACs, and Voice Handling

- **Function**:  
  - Each channel card is a complete digital playback engine (“voice”).
  - Contains address counters, sample RAM buffer, DAC, and control/status logic.
- **Playback**:  
  - Fetches sample blocks from shared RAM or direct from disk (later models, streaming).
  - Channel registers set start/end address, pitch, envelope, and output volume.
- **DAC**:  
  - 8-bit (Series I/II), 16-bit (Series III); monolithic or R-2R ladder, buffered by opamp.
- **Polyphony**:  
  - Series I/II: 8 voices; Series III: up to 16–32 with expanded chassis.

### 30.232.4 Analog Interface: Input/Output, Amplifiers, Filters

- **Input**:  
  - Balanced/unbalanced line in, relay pad, preamp, anti-aliasing filter.
  - ADC: 8-bit (μA710, later 16-bit), sample/hold, clocked by CPU or sequencer.
- **Output**:  
  - Each channel card’s DAC output summed, sent to main output amp.
  - Optional EQ, output filter, and volume control.

### 30.232.5 Storage: Floppy, Hard Disk, and Backup

- **Floppy**:  
  - 8” (Shugart SA-800, Series I/II), 5.25” (Series III); single/double sided, 500–1200KB.
  - OS boots from floppy; user patches, samples, and sequences stored here.
- **Hard Disk**:  
  - SCSI or MFM/RLL; 5–40 MB capacity in later Series III.
- **Backup**:  
  - Tape streamer or external SCSI tape (Series III).

### 30.232.6 Light Pen and Display: CRT, Graphics, and Input

- **CRT**:  
  - 9–12” green/amber phosphor, 640x256 or higher, custom graphics card.
- **Light Pen**:  
  - Photodiode stylus detects CRT scan, position decoded by timing circuit.
  - X/Y coordinates sent to CPU as interrupts or polled events.
- **Panel**:  
  - Softkey buttons mapped to UI functions, shown on CRT for context-sensitive input.

---

## 30.233 Digital Sampling and Sound Generation

### 30.233.1 Sampling Theory: Quantization, Rates, and Aliasing

- **Theory**:  
  - Sampling: periodic measurement of analog amplitude, quantized to digital value.
  - Nyquist theorem: max frequency = sample rate / 2; aliasing if undersampled.
  - Quantization noise: SNR limited by bit depth (6dB/bit rule).

### 30.233.2 Fairlight’s ADC: Circuit, Resolution, and SNR

- **ADC Circuit**:  
  - Sample/hold, anti-aliasing filter, followed by successive approximation ADC.
  - 8-bit (256 levels, ~48dB SNR), later 16-bit (Series III, ~96dB SNR).
- **Clocking**:  
  - Crystal oscillator, divided for sample rate (30–44.1kHz typical).
- **Input Range**:  
  - Calibrated for ±1V or ±5V audio, with input pad and gain trim.

### 30.233.3 Sample Storage: RAM Architecture, Paging, and Limits

- **Sample RAM**:  
  - Shared between CPU and channel cards; address-mapped so each channel can access its assigned buffer.
- **Paging**:  
  - Large samples split into blocks (“pages”), fetched as needed during playback; supports long samples despite RAM limits.
- **Limits**:  
  - Series I/II: 16–32KB per channel; Series III: up to 256KB per channel.

### 30.233.4 Playback Engines: Channel Card Digital Logic and DAC

- **Address Counter**:  
  - Each channel tracks play position, wraps or stops at end address.
- **Pitch Control**:  
  - Address increment rate set by frequency register; “fractional stepping” for pitch bend.
- **Envelope**:  
  - Basic attack/decay or user-drawn in UI; implemented as multiplier or lookup table.
- **DAC**:  
  - 8/16-bit output, anti-imaging filter, opamp buffer to output bus.

### 30.233.5 Polyphony and Voice Allocation: Real-Time Scheduling

- **Polyphony**:  
  - Each channel card = 1 voice; OS schedules note events to available channels.
- **Voice Stealing**:  
  - If all channels busy, oldest/quietest note is interrupted for new event.
- **Scheduling**:  
  - OS keeps real-time map of channel status; re-allocates on note off, sample end, or UI event.

---

## 30.234 System Bus, Memory Map, and I/O

### 30.234.1 Q-bus Protocol, Arbitration, and Timing

- **Bus Protocol**:  
  - Multiplexed address/data, CPU as master; channel cards and DMA as slaves.
  - Handshake signals: BUSY, REQ, ACK, INT, RESET.
- **Timing**:  
  - CPU cycles: ~1μs per access; DMA grants for block sample transfers.

### 30.234.2 Memory Map: OS, Sample Buffers, Channel Registers

| Address      | Region             | Size     | Function           |
|--------------|--------------------|----------|--------------------|
| 0x0000–0x1FFF| OS ROM             | 8KB      | Boot, Monitor      |
| 0x2000–0x3FFF| OS RAM             | 8KB      | Variables, Stack   |
| 0x4000–0xFFFF| Sample Buffers     | 48KB     | Per-channel data   |
| 0x10000+     | Channel Regs       | 256B/ch  | Playback control   |
| ...          | Disk/Floppy, I/O   | ...      | External devices   |

### 30.234.3 I/O: Keyboard, Light Pen, Floppy, MIDI, Sync

- **Keyboard**:  
  - Proprietary scan matrix, polled by CPU, debounced in software.
- **Light Pen**:  
  - Event-driven, triggers interrupt on touch, coordinates latched for UI handler.
- **Floppy/Disk**:  
  - FDC/SDC (WD1771, WD1793, or custom), mapped to I/O range, with IRQ for transfer complete.
- **MIDI**:  
  - Series III and later, UART-based, opto-isolated.
- **Sync**:  
  - FSK, tape sync, pulse in/out, SMPTE for external transport sync.

---

## 30.235 Example C Code: Sample Playback, Channel Scheduling, and I/O Handlers

### 30.235.1 Channel Register Read/Write

```c
#define CHANNEL_BASE 0x10000
#define CH_REG_SIZE  0x100

typedef struct {
    uint16_t start_addr;
    uint16_t end_addr;
    uint16_t play_addr;
    uint8_t  volume;
    uint8_t  envelope;
    uint8_t  status;
} channel_reg_t;

volatile channel_reg_t* channel_regs = (channel_reg_t*)CHANNEL_BASE;

void start_channel(int ch, uint16_t start, uint16_t end, uint8_t vol, uint8_t env) {
    channel_regs[ch].start_addr = start;
    channel_regs[ch].end_addr = end;
    channel_regs[ch].play_addr = start;
    channel_regs[ch].volume = vol;
    channel_regs[ch].envelope = env;
    channel_regs[ch].status = 1; // Active
}
```

### 30.235.2 Sample Block DMA Handler

```c
#define SAMPLE_RAM_BASE 0x4000

volatile uint8_t* sample_ram = (uint8_t*)SAMPLE_RAM_BASE;

void dma_sample_block(uint16_t src, uint16_t dst, uint16_t len) {
    for (uint16_t i = 0; i < len; ++i)
        sample_ram[dst + i] = sample_ram[src + i];
}
```

### 30.235.3 Keyboard Scan, Debounce, and Event Queue

```c
#define KEY_ROWS 8
#define KEY_COLS 8

uint8_t key_matrix[KEY_ROWS][KEY_COLS];
uint8_t key_debounce[KEY_ROWS][KEY_COLS];

void scan_keyboard() {
    for (int r = 0; r < KEY_ROWS; ++r) {
        select_key_row(r);
        delay_us(5);
        uint8_t cols = read_key_cols();
        for (int c = 0; c < KEY_COLS; ++c) {
            bool pressed = (cols >> c) & 1;
            if (pressed != key_matrix[r][c]) {
                if (++key_debounce[r][c] > 2) {
                    key_matrix[r][c] = pressed;
                    queue_key_event(r, c, pressed);
                    key_debounce[r][c] = 0;
                }
            } else {
                key_debounce[r][c] = 0;
            }
        }
    }
}
```

### 30.235.4 Light Pen Event Handler

```c
typedef struct {
    uint16_t x;
    uint16_t y;
    uint8_t  pen_down;
} light_pen_event_t;

light_pen_event_t pen_event;

void light_pen_irq_handler() {
    pen_event.x = read_pen_x();
    pen_event.y = read_pen_y();
    pen_event.pen_down = 1;
    queue_pen_event(pen_event.x, pen_event.y);
}
```

---

## 30.236 Appendices: Schematics, Bus Pinouts, and Memory/Voice Tables

### 30.236.1 Channel Card Schematic (Text, Partial)

```
[RAM Buffer]---[Address Counter]---[Sample Out]
        |             |                 |
[Pitch Reg]---[Adder] |          [Envelope Mult]
        |             |                 |
   [DAC]---[Opamp]---[Output Bus]
```

### 30.236.2 Q-bus Pinout (Excerpt)

| Pin | Signal   | Description           |
|-----|----------|-----------------------|
| A1  | GND      | Ground                |
| A2  | +5V      | Digital supply        |
| B1  | D0       | Data bus 0            |
| B2  | D1       | Data bus 1            |
| ... | ...      | ...                   |
| C1  | A0       | Address bus 0         |
| C2  | A1       | Address bus 1         |
| ... | ...      | ...                   |
| D1  | REQ      | Bus request           |
| D2  | ACK      | Bus acknowledge       |
| D3  | INT      | Interrupt             |

### 30.236.3 Memory/Voice Table (Series II Example)

| Channel | RAM Start | RAM End | Max Sample | DAC Bits |
|---------|-----------|---------|------------|----------|
| 0       | 0x4000    | 0x4FFF  | 4KB        | 8        |
| 1       | 0x5000    | 0x5FFF  | 4KB        | 8        |
| ...     | ...       | ...     | ...        | ...      |
| 7       | 0xC000    | 0xCFFF  | 4KB        | 8        |

---
