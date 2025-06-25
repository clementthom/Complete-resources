# Chapter 30: Case Studies – Emulator III (Complete Deep-Dive)
## Part 3: Voice Card Hardware, Filters, Service, MIDI, SCSI, Modernization, and Reverse Engineering

---

## Table of Contents

- 30.263 Voice Card Hardware: Schematics, Digital and Analog Path
  - 30.263.1 Block Diagram Overview
  - 30.263.2 Sample Playback Logic: Addressing, Pitch, Envelope, and Looping
  - 30.263.3 DAC, SSM2045 Filter, SSM2024 VCA, and Output Stage
  - 30.263.4 Voice Card Schematic Walkthrough (Text)
  - 30.263.5 Card Testing, Failure Modes, and Service
- 30.264 MIDI and External Control: Hardware, Integration, and Mapping
  - 30.264.1 MIDI Hardware: UART, Optoisolation, and Buffering
  - 30.264.2 MIDI Software: Parsing, Channel Mapping, Voice Assignment
  - 30.264.3 MIDI Implementation Chart, Limitations, and Sysex
  - 30.264.4 Example MIDI Event Handling and C Code
- 30.265 SCSI/Storage and Modernization: Disk, SD, and Computer Integration
  - 30.265.1 SCSI Hard Disk, Controller, and Protocol
  - 30.265.2 Modernization: SCSI2SD, BlueSCSI, and USB Solutions
  - 30.265.3 Floppy Disk Replacement and Software Imaging
  - 30.265.4 Computer Integration: Sample Editors and Remote Control
- 30.266 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation
  - 30.266.1 ROM Dump Process, Structure, and Tools
  - 30.266.2 Firmware Disassembly: Vector Tables, ISRs, Main Loops
  - 30.266.3 System Emulation: Bus, Timing, Peripherals
  - 30.266.4 Recreating the Voice Card in Software/FPGA
- 30.267 Example C Code: Hardware Emulation, MIDI Engine, and Service Utilities
  - 30.267.1 Voice Card Emulation: Sample Playback, Pitch, Envelope, VCF, VCA
  - 30.267.2 MIDI Event Parsing and Voice Assignment
  - 30.267.3 SCSI Block Read/Write, Floppy Abstraction
  - 30.267.4 LCD/Panel UI Emulation: Menu, Softkeys, and Feedback
  - 30.267.5 Panel/Keyboard Scan and Debounce
- 30.268 Appendices: Schematics, Pinouts, Filter Tables, Service Tables

---

## 30.263 Voice Card Hardware: Schematics, Digital and Analog Path

### 30.263.1 Block Diagram Overview

```
[Sample RAM]---[Address Counter]---[Playback Logic]---[DAC]---[SSM2045 VCF]---[SSM2024 VCA]---[AA Filter]---[Opamp]---[Sum Bus]
                             |               |             |             |              |              
                         [Pitch Reg]   [Envelope]      [Loop Logic]   [Velocity/CC]   [CV DAC]
```

- Each voice card is a full digital+analog voice, with sample RAM access, playback logic, DAC, analog VCF and VCA, and output buffer.
- Control/status registers mapped to CPU bus for triggering playback, setting pitch, filter, envelope, and voice allocation.

### 30.263.2 Sample Playback Logic: Addressing, Pitch, Envelope, and Looping

- **Address Counter**:
  - 24 bits, increments per sample clock, loaded by play pointer, wraps at end or loop.
- **Pitch Register**:
  - Sets increment per sample; supports fractional stepping for fine pitch and vibrato.
- **Envelope Generator**:
  - Multi-stage ADSR, digitally stepped, mapped to amplitude, filter, and VCA.
- **Loop Logic**:
  - Supports one-shot, simple loop, and multi-zone (key/velocity split) playback.

### 30.263.3 DAC, SSM2045 Filter, SSM2024 VCA, and Output Stage

- **DAC**:
  - 16-bit (PCM54, AD1860), current output, opamp transimpedance.
  - Sampled at 44.1kHz, output latched with every sample clock.
- **SSM2045 VCF**:
  - 4-pole lowpass with voltage control for cutoff and resonance.
  - Cutoff CV: 0-5V from CV DAC, mapped to software filter settings.
  - Resonance CV: 0-5V, direct or via software scaling.
- **SSM2024 VCA**:
  - Voltage-controlled, 0-5V for gain/loudness; envelope and velocity mapped.
- **AA Filter & Output**:
  - Post-VCF anti-aliasing filter (Bessel/Butterworth), opamp buffer (NE5532, TL072).
  - Per-voice output summed to stereo/mono bus or routed to individual outputs.

### 30.263.4 Voice Card Schematic Walkthrough (Text)

```
[Sample RAM]---[Address Counter]<---[Pitch Reg]---[Adder]------[Envelope Generator]
        |             |                     |                  |
     [Loop Logic]     |                  [DAC]                 |
        |             |                     |                  |
   [Playback Logic]   |                 [SSM2045 VCF]          |
        |             |                     |                  |
         +----------[SSM2024 VCA]---[AA Filter]---[Opamp]---[Sum Bus]
```

- **Sample RAM**: Shared via backplane, mapped per voice.
- **Address Counter**: Sets playback pointer; increments by pitch register; wraps/repeats via loop logic.
- **Playback Logic**: Fetches samples, applies envelope, sends to DAC.
- **DAC**: Outputs analog voltage, sent to VCF for filtering.
- **VCF**: Analog filter, cutoff/resonance CVs from control logic.
- **VCA**: Controls amplitude; envelope/velocity mapped.
- **AA Filter/Opamp**: Smooths and buffers output; per-voice or summed to stereo bus.

### 30.263.5 Card Testing, Failure Modes, and Service

- **Common Failures**:
  - DRAM/EPROM: missing notes, noise, stuck values.
  - DAC: distortion, missing voice, bad SNR.
  - SSM2045: no filter sweep, static sound, resonance issues.
  - SSM2024: low/no output, distortion.
  - Loop/Envelope: stuck notes, abrupt end, no release.
- **Testing**:
  - In-circuit: check data/address bus, probe DAC/VCF output.
  - Out-of-circuit: bench test with test ROM/data, scope outputs.
  - Replace socketed ICs, clean connectors, reflow as needed.

---

## 30.264 MIDI and External Control: Hardware, Integration, and Mapping

### 30.264.1 MIDI Hardware: UART, Optoisolation, and Buffering

- **UART**: 6850/8251, optoisolated input.
- **Buffering**: 128–512 byte FIFO, real-time message priority.
- **MIDI Out/Thru**: Buffered (74LS244); supports chaining.
- **External Control**: SCSI, RS-232, and footswitch for additional integration.

### 30.264.2 MIDI Software: Parsing, Channel Mapping, Voice Assignment

- **Parser**:
  - Handles running status, system real-time, and Sysex.
  - Filters by channel, note, velocity, CC, program change.
- **Channel Mapping**:
  - Maps incoming MIDI channels to internal voices/banks.
  - Multi-timbral: each channel can play a different bank/keymap.
- **Voice Assignment**:
  - Scheduler allocates note-on to free voice; implements voice stealing as needed.
  - Handles note-off, sustain, pedal, aftertouch, CC, pitch bend.

### 30.264.3 MIDI Implementation Chart, Limitations, and Sysex

| Message      | Supported | Comments                    |
|--------------|-----------|-----------------------------|
| Note On/Off  | Yes       | Multi-timbral, full poly    |
| Velocity     | Yes       | 0–127, per-voice            |
| Aftertouch   | Yes       | Poly & channel, mapped      |
| Program Chg  | Yes       | Patch select, bank change   |
| CC           | Yes       | Volume, pan, mod, macros    |
| Sysex        | Partial   | Dump/load, patch edit       |
| Clock/MTC    | Yes       | Sync, start/stop supported  |

- **Limitations**:  
  - No MPE, limited Sysex edit in early firmware, basic macro mapping.

### 30.264.4 Example MIDI Event Handling and C Code

```c
#define MIDI_BUF_SIZE 256
uint8_t midi_in_buf[MIDI_BUF_SIZE];
uint8_t midi_head = 0, midi_tail = 0;

void midi_rx_isr() {
    uint8_t byte = uart_read();
    midi_in_buf[midi_head++] = byte;
    if (midi_head >= MIDI_BUF_SIZE) midi_head = 0;
}

void process_midi() {
    static uint8_t status = 0;
    while (midi_tail != midi_head) {
        uint8_t byte = midi_in_buf[midi_tail++];
        if (midi_tail >= MIDI_BUF_SIZE) midi_tail = 0;
        if (byte & 0x80) status = byte;
        else handle_midi_byte(status, byte);
    }
}

void handle_midi_byte(uint8_t status, uint8_t data) {
    if ((status & 0xF0) == 0x90) { // Note On
        uint8_t channel = status & 0x0F;
        uint8_t note = data;
        uint8_t vel = midi_in_buf[midi_tail++];
        assign_voice(channel, note, vel);
    }
    // CC, PC, Aftertouch etc. handled here.
}
```

---

## 30.265 SCSI/Storage and Modernization: Disk, SD, and Computer Integration

### 30.265.1 SCSI Hard Disk, Controller, and Protocol

- **SCSI Controller**: NCR53C94/53C400, mapped to I/O space.
- **Device Support**: HDD (20–600MB), tape, removable; multiple LUNs supported.
- **Protocol**: SCSI-1/2, block mode, DMA transfer, IRQ completion.
- **DMA**: High-speed transfer for banks/samples; background prefetch/paging.

### 30.265.2 Modernization: SCSI2SD, BlueSCSI, and USB Solutions

- **SCSI2SD/BlueSCSI**: Emulate SCSI HDD, SD card as storage, compatible with EIII; transparent to OS.
- **Benefits**: Silent, reliable, replace failing HDDs, fast file backup, compatible with modern computers.
- **Drawbacks**: Some block size quirks; may require SCSI ID or termination tuning.

### 30.265.3 Floppy Disk Replacement and Software Imaging

- **Floppy Emulation**: HXC, Gotek, USB floppy emulators; load images from USB or SD.
- **Software Imaging**: Use Eii/EIII image tools to create/load disk images on computer.

### 30.265.4 Computer Integration: Sample Editors and Remote Control

- **Sample Editors**: EIII compatible editors for Mac/PC; MIDI/SCSI transfer, Sysex patch dump/load.
- **Remote Control**: RS-232 or MIDI for firmware updates, diagnostics, and advanced control.

---

## 30.266 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation

### 30.266.1 ROM Dump Process, Structure, and Tools

- **ROM Dump**: Extract with programmer (TL866, MiniPro, etc.), save as raw binary.
- **Structure**: Entry vectors, main loop, ISRs, kernel, sampler and sequencer code.
- **Tools**: Ghidra, IDA Pro, 68k disassemblers; annotate jump tables, label handlers.

### 30.266.2 Firmware Disassembly: Vector Tables, ISRs, Main Loops

- **Vectors**: IRQ, NMI, RESET, panel, timer, disk/SCSI, MIDI, voice card.
- **ISRs**: Service devices, queue events, update state.
- **Main Loop**: UI event poll, sequencer scheduling, file I/O, sample playback, voice allocation.

### 30.266.3 System Emulation: Bus, Timing, Peripherals

- **Bus**: Simulate 16-bit bus, memory-mapped I/O, DMA, arbitration.
- **Timing**: Cycle-accurate 68k core, real-time tick, DMA for sample/audio.
- **Peripherals**: Voice cards, panel, LCD, SCSI, floppy, MIDI.

### 30.266.4 Recreating the Voice Card in Software/FPGA

- **Software**: Emulate full playback, pitch stepping, loop/zone logic, envelope, DAC, VCF, VCA.
- **FPGA**: RTL for address counter, pitch, envelope, sample RAM, DAC/VCF/VCA interface.
- **Integration**: Software/FPGA engine can drop into full EIII emulator or hybrid replacement.

---

## 30.267 Example C Code: Hardware Emulation, MIDI Engine, and Service Utilities

### 30.267.1 Voice Card Emulation: Sample Playback, Pitch, Envelope, VCF, VCA

```c
typedef struct {
    uint32_t addr;      // Current sample address (24b)
    uint32_t start;     // Start address
    uint32_t end;       // End address
    uint32_t step;      // Pitch increment
    uint8_t  envelope;  // Envelope value (0-255)
    uint8_t  vcf_cutoff;// Filter cutoff (0-255)
    uint8_t  vca_gain;  // VCA level (0-255)
    uint8_t  active;    // Playing/not
} voice_t;

uint16_t sample_ram[1 << 20]; // 2MB sample RAM

void tick_voice(voice_t* v) {
    if (!v->active) return;
    v->addr += v->step;
    if (v->addr >= v->end) {
        if (loop_enabled) v->addr = v->start;
        else v->active = 0;
    }
    uint16_t sample = sample_ram[v->addr >> 8]; // 24.8 fixed point
    int32_t env_sample = (sample * v->envelope) >> 8;
    int32_t filtered = do_vcf(env_sample, v->vcf_cutoff); // Emulate SSM2045
    int32_t out = (filtered * v->vca_gain) >> 8;
    output_to_dac(out);
}
```

### 30.267.2 MIDI Event Parsing and Voice Assignment

```c
void assign_voice(uint8_t channel, uint8_t note, uint8_t velocity) {
    int free = find_free_voice();
    if (free < 0) free = steal_voice();
    voice_t* v = &voices[free];
    v->addr = note_to_addr(note);
    v->step = note_to_step(note);
    v->envelope = velocity << 1;
    v->vcf_cutoff = midi_to_cutoff(channel, note, velocity);
    v->vca_gain = velocity;
    v->active = 1;
}
```

### 30.267.3 SCSI Block Read/Write, Floppy Abstraction

```c
int scsi_read(uint32_t lba, uint8_t* buf) {
    // SCSI abstraction: send read cmd, wait for IRQ, handle errors
    // ...
    return 1; // Success
}
int fdd_read(uint32_t lba, uint8_t* buf) {
    // Floppy abstraction, same logic as SCSI
    // ...
    return 1;
}
```

### 30.267.4 LCD/Panel UI Emulation: Menu, Softkeys, and Feedback

```c
void lcd_show_menu(const char* menu[], int n) {
    for (int i = 0; i < n && i < LCD_ROWS; ++i)
        lcd_update(i, 0, menu[i]);
}
void softkey_press(int idx) {
    if (softkey_map[idx].handler) softkey_map[idx].handler();
}
```

### 30.267.5 Panel/Keyboard Scan and Debounce

```c
void scan_panel() {
    for (int row = 0; row < PANEL_ROWS; ++row) {
        set_panel_row(row);
        uint8_t cols = read_panel_cols();
        for (int col = 0; col < PANEL_COLS; ++col) {
            bool pressed = (cols >> col) & 1;
            if (pressed != panel_state[row][col]) {
                queue_panel_event(row, col, pressed);
                panel_state[row][col] = pressed;
            }
        }
    }
}
```

---

## 30.268 Appendices: Schematics, Pinouts, Filter Tables, Service Tables

### 30.268.1 Voice Card Schematic (Text, Partial)

```
[Sample RAM]---[Address Counter]<--[Pitch Reg]---[Adder]
                                  |                |
                              [Envelope]        [Loop Logic]
                                  |                |
                              [Playback]-----[DAC]---[SSM2045 VCF]---[SSM2024 VCA]---[AA Filter]---[Opamp]---[Sum Bus]
```

### 30.268.2 SSM2045/2024 Filter Table

| CV (V) | Cutoff Freq (Hz) | Res Peak | VCA Gain (dB) |
|--------|------------------|----------|---------------|
| 0      |   ~10            |  1.0     | -80           |
| 1      |   ~60            |  1.0     | -40           |
| 2      |  ~300            |  1.2     | -20           |
| 3      | ~1500            |  1.5     |  0            |
| 4      | ~8000            |  2.0     | +10           |
| 5      | ~18000           |  2.2     | +20           |

### 30.268.3 MIDI Implementation Table

| Message     | Supported | Notes                  |
|-------------|-----------|------------------------|
| Note On/Off | Yes       | Multi-timbral          |
| Velocity    | Yes       | 0–127                  |
| Aftertouch  | Yes       | Poly & channel         |
| CC          | Yes       | Vol/pan, macros        |
| Sysex       | Partial   | Dump/load, patch edit  |
| Clock/MTC   | Yes       | Sync                   |

### 30.268.4 Service Table

| Component    | Symptom               | Test/Remedy         |
|--------------|-----------------------|---------------------|
| DRAM         | Missing voice, noise  | RAM test, swap      |
| DAC          | Distortion, silence   | Scope/test, replace |
| SSM2045      | No sweep, dull sound  | CV test, swap       |
| SSM2024      | Low output, dist      | Audio probe, swap   |
| SCSI/FDD     | Boot fail, I/O error  | Replace/emulate     |
| Panel        | Dead keys, stuck LEDs | Scan, clean, swap   |

### 30.268.5 SCSI/SD/Panel Pinout (Excerpt)

| Pin | Signal   | Description           |
|-----|----------|-----------------------|
| 1   | GND      | Ground                |
| 2   | +5V      | Power                 |
| 3   | D0       | Data 0                |
| 4   | D1       | Data 1                |
| ... | ...      | ...                   |

---