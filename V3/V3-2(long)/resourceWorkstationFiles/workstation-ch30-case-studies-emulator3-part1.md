# Chapter 30: Case Studies – Emulator III (Complete Deep-Dive)
## Part 1: System Architecture, Sampling Hardware, and Sound Generation

---

## Table of Contents

- 30.250 Introduction
- 30.251 Historical Context, Innovations, and System Overview
  - 30.251.1 Emulator III’s Market, Impact, and Legacy
  - 30.251.2 Key Innovations: 16-Bit Sampling, SSM Filters, SCSI, Multi-Timbral Architecture
  - 30.251.3 Block Diagram and Major Subsystems
- 30.252 Hardware Architecture
  - 30.252.1 Main Chassis, Power Supply, and Card Cage
  - 30.252.2 CPU Board: Microprocessor, RAM, ROM, Support Logic
  - 30.252.3 Voice Cards: Sample Playback, DACs, and SSM Filters
  - 30.252.4 Analog Interface: Input/Output, Amplifiers, SSM Filters, VCAs
  - 30.252.5 Storage: Floppy, SCSI Hard Disk, and Backup
  - 30.252.6 Display, Panel, and Keyboard: Matrix, LCD, and Control
- 30.253 Digital Sampling and Sound Generation
  - 30.253.1 Sampling Theory: Quantization, Rates, and Aliasing
  - 30.253.2 Emulator III’s ADC: Circuit, Resolution, and SNR
  - 30.253.3 Sample Storage: RAM Architecture, Bank Management, and Paging
  - 30.253.4 Playback Engines: Channel Card Logic, DAC, and SSM Filter
  - 30.253.5 Polyphony and Multi-Timbral Operation: Scheduling and Prioritization
- 30.254 System Bus, Memory Map, and I/O
  - 30.254.1 Bus Protocol, Arbitration, and Timing
  - 30.254.2 Memory Map: OS, Sample Buffers, Channel Registers
  - 30.254.3 I/O: Panel, Keyboard, Floppy, SCSI, MIDI, Sync
- 30.255 Example C Code: Sample Playback, Channel Scheduling, and I/O Handlers
  - 30.255.1 Channel Register Read/Write
  - 30.255.2 Sample Block DMA Handler
  - 30.255.3 Keyboard Scan, Debounce, and Event Queue
  - 30.255.4 LCD/Panel Event Handler
- 30.256 Appendices: Schematics, Bus Pinouts, Memory/Voice Tables

---

## 30.250 Introduction

The E-mu Emulator III, released in 1987, is a landmark sampler that brought professional 16-bit digital sampling, analog SSM filtering, and advanced sequencing to the mainstream. Building on the lineage of the Emulator I and II, the EIII’s blend of digital precision and analog warmth, coupled with SCSI storage and multi-timbral operation, made it a favorite in studios and on stage throughout the late 1980s and 1990s.

---

## 30.251 Historical Context, Innovations, and System Overview

### 30.251.1 Emulator III’s Market, Impact, and Legacy

- **Target Market**: Professional studios, film composers, touring musicians, and sound designers (notable users: Depeche Mode, Peter Gabriel, Vangelis).
- **Legacy**: Set the 16-bit/44.1kHz standard for pro sampling; pioneering SCSI integration; revered for its analog VCF/VCA section.
- **Price Point**: $12,000–$15,000 at launch (keyboard or rackmount).

### 30.251.2 Key Innovations: 16-Bit Sampling, SSM Filters, SCSI, Multi-Timbral Architecture

- **16-Bit Digital Sampling**:  
  - True 16-bit linear PCM, stereo and mono, up to 44.1kHz.
- **SSM Filters and VCAs**:  
  - Analog 4-pole VCFs (SSM2045), per-voice, providing classic “creamy” sound.
- **SCSI Storage**:  
  - Fast, random-access hard disk support, plus floppy; rapid bank loading.
- **Multi-Timbral Voice Architecture**:  
  - Up to 16-32 voices, split across 16 MIDI channels; each with independent sample, filter, and envelope.

### 30.251.3 Block Diagram and Major Subsystems

```
[Keyboard/Panel]---+
                   |
           [LCD/Panel/Encoder]
                   |
                [Backplane Bus]
                   |
    +---------+----+-------+-------+-------+--------+
    |         |            |       |       |        |
 [CPU]  [Voice Cards]  [Analog I/O] [Disk/SCSI] [MIDI/I/O]
    |         |            |       |       |        |
 [RAM/ROM] [DAC/SSM]  [ADC/Preamp][HDD/FDD] [Ext. Control]
```

---

## 30.252 Hardware Architecture

### 30.252.1 Main Chassis, Power Supply, and Card Cage

- **Chassis**:  
  - 19” rack or keyboard, steel/aluminum, heavy-duty linear PSU with oversized toroidal transformer, regulated ±12V, +5V rails.
- **Cooling**:  
  - Forced air with filtered intake; SSM analog cards isolated from digital for noise performance.
- **Card Cage**:  
  - Backplane with edge connectors; CPU, voice, analog, storage, I/O cards.

### 30.252.2 CPU Board: Microprocessor, RAM, ROM, Support Logic

- **CPU**:  
  - Motorola 68000 @ 8MHz, 16/24-bit address, 16-bit data.
- **RAM**:  
  - 512KB–2MB DRAM, battery-backed SRAM for system settings and user patches.
- **ROM**:  
  - 64–256KB EPROM for boot, diagnostics, kernel.
- **Support**:  
  - PAL/GAL for address decoding, watchdog timer, glue logic with 74LS/HC series.
- **Bus Interface**:  
  - CPU is bus master; DMA for sample transfer (disk, voice cards).

### 30.252.3 Voice Cards: Sample Playback, DACs, and SSM Filters

- **Playback Engine**:  
  - Each voice card contains sample address logic, pitch/frequency registers, envelope generator, and velocity/aftertouch mapping.
- **DAC**:  
  - 16-bit monolithic (PCM54, AD1860), differential current out, opamp buffered.
- **VCF/VCA**:  
  - SSM2045 VCF, SSM2024 VCA per voice; cutoff, resonance, envelope, and velocity mapped.
- **Polyphony**:  
  - 16–32 voices (expandable); allocated dynamically per MIDI/event.

### 30.252.4 Analog Interface: Input/Output, Amplifiers, SSM Filters, VCAs

- **Input**:  
  - Balanced line in, pad/trim, anti-aliasing filter (7th order Bessel/Butterworth).
  - ADC: 16-bit successive approximation (AD1674, AD676), crystal clocked.
- **Output**:  
  - Each voice summed post-SSM, then through analog line driver (NE5532/TL072), with optional EQ section.
  - Stereo/mono output, individual outs per voice (configurable).

### 30.252.5 Storage: Floppy, SCSI Hard Disk, and Backup

- **Floppy**:  
  - 3.5” 720KB/1.44MB, for OS, samples, and bank storage.
- **SCSI HD**:  
  - SCSI-1/2, 20–600MB, hot-swappable (later models), managed via internal SCSI controller ASIC.
- **Backup**:  
  - SCSI tape or external backup via SCSI port.

### 30.252.6 Display, Panel, and Keyboard: Matrix, LCD, and Control

- **LCD**:  
  - 2x40 or 4x40 character, with backlight, mapped to memory via parallel bus.
- **Panel**:  
  - Softkey buttons, rotary encoder, numeric pad; scanned via matrix, debounced in firmware.
- **Keyboard**:  
  - 61 weighted keys, velocity and aftertouch, proprietary scan matrix.

---

## 30.253 Digital Sampling and Sound Generation

### 30.253.1 Sampling Theory: Quantization, Rates, and Aliasing

- **Theory**:  
  - 44.1kHz/16-bit standard; Nyquist theorem, anti-aliasing filter before ADC.
  - Quantization noise: 96dB SNR, dithering for low-level accuracy.

### 30.253.2 Emulator III’s ADC: Circuit, Resolution, and SNR

- **ADC Circuit**:  
  - Preamp, anti-aliasing filter, sample/hold, 16-bit SAR ADC.
  - Input range ±1V, switchable pad for higher level.
- **Clocking**:  
  - Crystal oscillator (11.2896 MHz for 44.1kHz), divided for sample rate accuracy.
- **SNR**:  
  - True 16-bit, SNR > 90dB, low THD, careful PCB layout and analog/digital plane separation.

### 30.253.3 Sample Storage: RAM Architecture, Bank Management, and Paging

- **Sample RAM**:  
  - DRAM, shared between CPU and voice cards; paging used for large samples.
- **Bank Management**:  
  - Samples organized as “banks”; each bank holds a set of keymaps, velocity splits, and MIDI assignments.
- **Paging**:  
  - Large samples loaded from disk/SCSI in blocks; background DMA manages paging during playback.

### 30.253.4 Playback Engines: Channel Card Logic, DAC, and SSM Filter

- **Address Counter**:  
  - Each voice tracks play position; increment per sample, wraps at end or loop.
- **Pitch/Velocity Control**:  
  - Frequency register sets increment; velocity mapped to envelope, VCF, and VCA amount.
- **Envelope**:  
  - Multi-stage ADSR, user-drawn in UI; implemented as digital curve, mapped to SSM CVs.
- **VCF (SSM2045)**:  
  - Voltage-controlled, analog 4-pole lowpass; cutoff, resonance, and envelope mapped via CV DAC.

### 30.253.5 Polyphony and Multi-Timbral Operation: Scheduling and Prioritization

- **Polyphony**:  
  - 16–32 voices, each independently addressable; multi-timbral mapping via MIDI channel splits.
- **Scheduling**:  
  - OS maintains voice pool; allocates note events based on priority (oldest, quietest, or lowest velocity).
- **Voice Stealing**:  
  - If all voices active, oldest/release-phase voice is reassigned.

---

## 30.254 System Bus, Memory Map, and I/O

### 30.254.1 Bus Protocol, Arbitration, and Timing

- **Bus Protocol**:  
  - 16-bit data, 24-bit address; CPU as master, DMA for voice/disk/SCSI transfer.
- **Arbitration**:  
  - DMA requests via HOLD/WAIT; bus grant, cycle-stealing for real-time audio.
- **Timing**:  
  - CPU cycle ~500ns; DMA blocks scheduled during audio frame boundaries.

### 30.254.2 Memory Map: OS, Sample Buffers, Channel Registers

| Address      | Region             | Size     | Function           |
|--------------|--------------------|----------|--------------------|
| 0x000000–0x03FFFF | OS ROM        | 256KB    | Boot, Kernel       |
| 0x040000–0x07FFFF | OS RAM        | 256KB    | Variables, Stack   |
| 0x080000–0x3FFFFF | Sample RAM    | 3.5MB    | Per-voice buffers  |
| 0x400000+         | Voice Regs    | 256B/voice| Playback, filter   |
| ...              | Disk/SCSI, I/O | ...      | Ext peripherals    |

### 30.254.3 I/O: Panel, Keyboard, Floppy, SCSI, MIDI, Sync

- **Panel/Encoder**:  
  - Scanned via parallel lines, debounced in firmware, mapped to OS event queue.
- **Keyboard**:  
  - Matrix scanned, velocity/aftertouch timing measured, priority interrupt for key events.
- **Floppy/SCSI**:  
  - WD1772 or SCSI ASIC, mapped to I/O range; DMA and IRQ for transfer complete.
- **MIDI**:  
  - UART-based, opto-isolated input, buffered output/thru.
- **Sync**:  
  - SMPTE, FSK, MIDI clock in/out; jack field or DB25 rear-panel.

---

## 30.255 Example C Code: Sample Playback, Channel Scheduling, and I/O Handlers

### 30.255.1 Channel Register Read/Write

```c
#define VOICE_BASE 0x400000
#define VOICE_REG_SIZE 0x20

typedef struct {
    uint32_t start_addr;
    uint32_t end_addr;
    uint32_t play_addr;
    uint16_t pitch;
    uint8_t  velocity;
    uint8_t  envelope;
    uint8_t  filter_cutoff;
    uint8_t  filter_res;
    uint8_t  status;
} voice_reg_t;

volatile voice_reg_t* voice_regs = (voice_reg_t*)VOICE_BASE;

void start_voice(int v, uint32_t start, uint32_t end, uint16_t pitch, uint8_t vel, uint8_t env, uint8_t cutoff, uint8_t res) {
    voice_regs[v].start_addr = start;
    voice_regs[v].end_addr = end;
    voice_regs[v].play_addr = start;
    voice_regs[v].pitch = pitch;
    voice_regs[v].velocity = vel;
    voice_regs[v].envelope = env;
    voice_regs[v].filter_cutoff = cutoff;
    voice_regs[v].filter_res = res;
    voice_regs[v].status = 1;
}
```

### 30.255.2 Sample Block DMA Handler

```c
#define SAMPLE_RAM_BASE 0x080000

volatile uint16_t* sample_ram = (uint16_t*)SAMPLE_RAM_BASE;

void dma_sample_block(uint32_t src, uint32_t dst, uint32_t len) {
    for (uint32_t i = 0; i < len; ++i)
        sample_ram[dst + i] = sample_ram[src + i];
}
```

### 30.255.3 Keyboard Scan, Debounce, and Event Queue

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

### 30.255.4 LCD/Panel Event Handler

```c
#define LCD_ROWS 4
#define LCD_COLS 40

char lcd_buffer[LCD_ROWS][LCD_COLS+1];

void lcd_write(int row, int col, const char* text) {
    strncpy(&lcd_buffer[row][col], text, LCD_COLS-col);
    lcd_buffer[row][LCD_COLS] = '\0';
    update_lcd_hardware(row);
}

void panel_event_handler(int key_id) {
    // Map key_id to OS function, update event queue or execute directly
}
```

---

## 30.256 Appendices: Schematics, Bus Pinouts, Memory/Voice Tables

### 30.256.1 Voice Card Schematic (Text, Partial)

```
[Sample RAM]---[Address Counter]<--[Pitch Reg]---[Adder]----[Envelope]---[DAC]---[VCF/SSM2045]---[VCA/SSM2024]---[Output Bus]
                                                        |                                   |
                                                    [Loop Logic]                        [CV DAC]
```

### 30.256.2 Bus Pinout (Excerpt)

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
| D1  | HOLD     | DMA request           |
| D2  | WAIT     | Bus wait state        |

### 30.256.3 Memory/Voice Table (Example)

| Voice | RAM Start | RAM End  | Max Sample | DAC Bits | VCF | VCA |
|-------|-----------|----------|------------|----------|-----|-----|
| 0     | 0x080000  | 0x0BFFFF | 256KB      | 16       | Y   | Y   |
| 1     | 0x0C0000  | 0x0FFFFF | 256KB      | 16       | Y   | Y   |
| ...   | ...       | ...      | ...        | ...      | ... | ... |
| 15    | 0x380000  | 0x3BFFFF | 256KB      | 16       | Y   | Y   |

---