# Chapter 30: Case Studies – Fairlight CMI (Complete Deep-Dive)
## Part 3: Channel Card Hardware, Service, MIDI, Modernization, and Reverse Engineering

---

## Table of Contents

- 30.242 Channel Card Hardware: Schematics, Digital and Analog Path
  - 30.242.1 Block Diagram Overview
  - 30.242.2 Sample Playback Logic: Addressing, Pitch, Envelope, and Looping
  - 30.242.3 DAC and Output Stage: R-2R, Filters, and Summing
  - 30.242.4 Channel Card Schematic Walkthrough (Text)
  - 30.242.5 Card Testing, Failure Modes, and Service
- 30.243 MIDI and External Control: Hardware, Integration, and Mapping
  - 30.243.1 MIDI Hardware: UART, Optoisolation, and Buffering
  - 30.243.2 MIDI Software: Parsing, Channel Mapping, Voice Assignment
  - 30.243.3 MIDI Implementation Chart, Limitations, and Sysex
  - 30.243.4 Example MIDI Event Handling and C Code
- 30.244 Modernization and Upgrades: Storage, Display, and Connectivity
  - 30.244.1 Floppy/Hard Disk Replacement: SCSI2SD, USB, and SD Solutions
  - 30.244.2 CRT to LCD/HDMI: Video Conversion and Display Emulation
  - 30.244.3 Panel/Keyboard Upgrades: USB and Matrix Scan Emulation
  - 30.244.4 Audio Output: New DACs, Summing, and Interface Cards
- 30.245 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation
  - 30.245.1 ROM Dump Process, Structure, and Tools
  - 30.245.2 Firmware Disassembly: Vector Tables, ISRs, Main Loops
  - 30.245.3 System Emulation: Bus, Timing, Peripherals
  - 30.245.4 Recreating the Channel Card in Software/FPGA
- 30.246 Example C Code: Hardware Emulation, MIDI Engine, and Service Utilities
  - 30.246.1 Channel Card Emulation: Sample Playback, Pitch, and Envelope
  - 30.246.2 MIDI Event Parsing and Voice Assignment
  - 30.246.3 Storage Abstraction: Disk/FDD/SD Read/Write
  - 30.246.4 CRT/LCD UI Emulation: Page R and Softkeys
  - 30.246.5 Panel/Keyboard Scan and Debounce
- 30.247 Appendices: Schematics, Pinouts, MIDI Charts, Service Tables

---

## 30.242 Channel Card Hardware: Schematics, Digital and Analog Path

### 30.242.1 Block Diagram Overview

```
[Sample RAM]---[Address Counter]---[Playback Logic]---[DAC]---[AA Filter]---[Opamp]---[Sum Bus]
                 |                            |         |                |         |
             [Pitch Reg]                 [Envelope]  [Volume]      [Loop Logic]
```

- Each channel card is a complete digital/analog playback voice.
- Contains sample RAM buffer (shared or dedicated), address generation logic, pitch register, envelope generator, output DAC, anti-aliasing filter, and opamp buffer.
- Control/status registers mapped to CPU bus for starting/stopping playback, setting pitch, envelope, and loop points.

### 30.242.2 Sample Playback Logic: Addressing, Pitch, Envelope, and Looping

- **Address Counter**:
  - 16–20 bit binary counter.
  - Incremented each sample clock; value set by play pointer, wraps at end address or loop point.
- **Pitch Register**:
  - Sets the increment per sample; higher values = faster stepping = higher pitch.
  - Fractional stepping for pitch bend/vibrato.
- **Envelope Generator**:
  - Simple attack/decay or more complex user-drawn shape (Page D in UI).
  - Implemented as an 8-bit register/multiplier or as a scanned table.
- **Loop Logic**:
  - Loop start/end addresses; when play pointer reaches end, jumps to loop start.
  - Supports one-shot, sustain, and multi-loop for complex sample playback.

### 30.242.3 DAC and Output Stage: R-2R, Filters, and Summing

- **DAC**:
  - 8-bit R-2R ladder network (TL084 opamps), or monolithic DAC (DAC08, later AD7528 for Series III 16-bit).
  - Sampled at 30–44.1kHz, output latched on falling sample clock edge.
- **Anti-Aliasing Filter**:
  - 4th to 7th order Bessel/Butterworth filter, -3dB at Nyquist, minimizes aliasing and imaging.
- **Opamp Buffer**:
  - Low-noise buffer (NE5532, TL072) drives sum bus; AC or DC coupled.
- **Summing**:
  - All channel outputs mixed via analog sum bus, then output to main line driver.

### 30.242.4 Channel Card Schematic Walkthrough (Text)

```
[Sample RAM]---[Address Counter]<--[Pitch Reg]---[Adder]--+
                                         |                |
                                     [Loop Logic]      [Envelope Gen]
                                         |                |
                                    [AND/OR Logic]       |
                                         |______________ |
                                                      |  |
                                            [Playback Logic]
                                                      |
                                                  [DAC]
                                                      |
                                              [AA Filter]
                                                      |
                                              [Opamp Buffer]
                                                      |
                                                 [Sum Bus]
```

- **Sample RAM**: Shared with system, or present as onboard buffer.
- **Address Counter**: Loads start address; auto-incremented per sample clock, increment determined by pitch register.
- **Playback Logic**: Handles sample fetch, applies envelope, checks for loop/end, triggers DAC update.
- **DAC**: Receives digital sample value, outputs analog voltage.
- **AA Filter & Opamp**: Smooths output, buffers for summing and output.

### 30.242.5 Card Testing, Failure Modes, and Service

- **Common Failures**:
  - DRAM/EPROM failure: voice missing, noise, or stuck high/low.
  - DAC drift: distortion, low SNR, missing voice.
  - Opamp failure: output crackle, high noise, dead channel.
  - Loop logic stuck: stuck notes, looping errors.
- **Service**:
  - In-circuit test: check address/data bus, probe DAC output.
  - Out-of-circuit: power with bench supply, inject test data, scope output.
  - Replace socketed ICs, reflow solder on connectors, clean ribbon cables.

---

## 30.243 MIDI and External Control: Hardware, Integration, and Mapping

### 30.243.1 MIDI Hardware: UART, Optoisolation, and Buffering

- **UART**: 6850/8251 or similar, interrupt-driven.
- **Input**: Optoisolator (6N138, PC900), suppresses ground loops and protects CPU.
- **Buffering**: 128–256 byte FIFO, overflow/underrun flags.
- **MIDI Out/Thru**: Buffered with 74LS244, supports chaining.

### 30.243.2 MIDI Software: Parsing, Channel Mapping, Voice Assignment

- **Parser**:
  - Handles running status, real-time, and system messages.
  - Filters by channel, note, velocity, CC, program change.
- **Channel Mapping**:
  - Maps incoming MIDI channel to internal voice/channel card.
  - Supports splits/layers, velocity mapping, poly/mono modes.
- **Voice Assignment**:
  - Scheduler allocates note-on to free channel; implements voice stealing as needed.
  - Handles note-off, sustain, pedal, and other real-time CCs.

### 30.243.3 MIDI Implementation Chart, Limitations, and Sysex

| Message      | Supported | Comments                    |
|--------------|-----------|-----------------------------|
| Note On/Off  | Yes       | Full polyphony              |
| Velocity     | Yes       | 0–127 range                 |
| Aftertouch   | No/Partial| Not supported in Series II  |
| Program Chg  | Yes       | Patch select                |
| CC           | Partial   | Volume, pan, limited params |
| Sysex        | Partial   | Dump/load, system exclusive |
| Clock/MTC    | Yes       | Sync, start/stop supported  |

- **Limitations**:  
  - No MPE, limited CC map, no high-resolution CC, limited Sysex in Series II.

### 30.243.4 Example MIDI Event Handling and C Code

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
    // Example: Handle Note On/Off, velocity, and mapping
    if ((status & 0xF0) == 0x90) {
        uint8_t channel = status & 0x0F;
        uint8_t note = data;
        uint8_t vel = midi_in_buf[midi_tail++];
        assign_voice(channel, note, vel);
    }
    // Add more handling for CC, PC, etc.
}
```

---

## 30.244 Modernization and Upgrades: Storage, Display, and Connectivity

### 30.244.1 Floppy/Hard Disk Replacement: SCSI2SD, USB, and SD Solutions

- **SCSI2SD/BlueSCSI**: Replaces MFM/SCSI hard disk; emulates SCSI at hardware level, stores images on SD card.
- **HXC/Gotek Floppy Emulator**: Replaces 8"/5.25" FDD, uses USB stick or SD card to load/save disk images.
- **Compatibility**: Requires matching block size, sector translation; some OS patching may be needed.

### 30.244.2 CRT to LCD/HDMI: Video Conversion and Display Emulation

- **Video Conversion**: VGA/Composite/SCART to HDMI converters, or CRT controller replacement.
- **LCD Drop-in**: Custom LCD kits to fit original case, map video input to modern display.
- **Emulated Display**: Software emulation of CRT/graphics for remote/modern UI.

### 30.244.3 Panel/Keyboard Upgrades: USB and Matrix Scan Emulation

- **Panel**: Microcontroller (Teensy, Arduino) emulates softkey/keyboard matrix, presents as USB HID or MIDI.
- **Keybed**: Modern Fatar or Doepfer keybeds can be adapted; velocity and aftertouch mapped to Fairlight protocol.

### 30.244.4 Audio Output: New DACs, Summing, and Interface Cards

- **DAC Upgrade**: Modern 16–24 bit DAC boards can replace or supplement R-2R, improving SNR, lowering distortion.
- **Balanced Outputs**: Add line drivers, XLR/TRS jacks for studio integration.
- **Digital Output**: Optional S/PDIF or AES3 output for direct digital capture.

---

## 30.245 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation

### 30.245.1 ROM Dump Process, Structure, and Tools

- **ROM Dump**: Extract with programmer (TL866, MiniPro, Batronix), save as raw binary.
- **Structure**: Entry vectors at 0x0000, main loop, ISRs, OS code, softkey/graphics tables.
- **Tools**: Ghidra, IDA Pro, m6809/m68000 disassemblers; annotate jump tables, label handlers.

### 30.245.2 Firmware Disassembly: Vector Tables, ISRs, Main Loops

- **Vectors**: IRQ, NMI, RESET, light pen, timer, disk, keyboard.
- **ISRs**: Service each device, queue events, update state machines.
- **Main Loop**: Polls for UI input, schedules sequencer, handles file I/O, manages voice allocation.

### 30.245.3 System Emulation: Bus, Timing, Peripherals

- **Bus**: Simulate Q-bus protocol, memory-mapped I/O, bus arbitration and timing.
- **Timing**: Cycle-accurate CPU, timer tick, DMA for sample fetch/playback.
- **Peripherals**: Floppy, disk, panel, CRT, light pen, channel cards, MIDI.

### 30.245.4 Recreating the Channel Card in Software/FPGA

- **Software**: Emulate full playback logic, pitch stepping, loop logic, envelope, DAC, AA filter.
- **FPGA**: RTL for address counter, loop logic, envelope, sample RAM, DAC interface.
- **Integration**: Software or hardware core can drop into full CMI emulator or replacement chassis.

---

## 30.246 Example C Code: Hardware Emulation, MIDI Engine, and Service Utilities

### 30.246.1 Channel Card Emulation: Sample Playback, Pitch, and Envelope

```c
typedef struct {
    uint32_t addr;      // Current sample address
    uint32_t start;     // Loop/start address
    uint32_t end;       // End address
    uint32_t step;      // Pitch increment
    uint8_t  envelope;  // Envelope value
    uint8_t  active;    // Playing/not
} ch_card_t;

uint8_t sample_ram[1 << 20]; // 1MB sample RAM

void tick_channel(ch_card_t* ch) {
    if (!ch->active) return;
    ch->addr += ch->step;
    if (ch->addr >= ch->end) {
        if (loop_enabled) ch->addr = ch->start;
        else ch->active = 0;
    }
    uint8_t sample = sample_ram[ch->addr >> 8]; // 24.8 fixed point
    int16_t out = (sample * ch->envelope) >> 7;
    output_to_dac(out);
}
```

### 30.246.2 MIDI Event Parsing and Voice Assignment

```c
void assign_voice(uint8_t channel, uint8_t note, uint8_t velocity) {
    int free = find_free_channel();
    if (free < 0) free = steal_voice();
    ch_card_t* ch = &channels[free];
    ch->addr = note_to_addr(note);
    ch->step = note_to_step(note);
    ch->envelope = velocity;
    ch->active = 1;
}
```

### 30.246.3 Storage Abstraction: Disk/FDD/SD Read/Write

```c
int read_block(uint32_t lba, uint8_t* buf) {
    // Abstract over disk, FDD, SD, or image
    if (storage_type == TYPE_SCSI2SD)
        return scsi2sd_read(lba, buf);
    else if (storage_type == TYPE_FDD)
        return fdd_read(lba, buf);
    else if (storage_type == TYPE_IMAGE)
        return image_read(lba, buf);
    return -1;
}
```

### 30.246.4 CRT/LCD UI Emulation: Page R and Softkeys

```c
void draw_grid() {
    for (int t = 0; t < TRACKS; ++t)
        for (int s = 0; s < STEPS; ++s)
            if (page_r_grid[t][s].note)
                draw_note_cell(t, s, page_r_grid[t][s].note, page_r_grid[t][s].velocity);
}

void softkey_press(int idx) {
    if (softkey_map[idx].handler) softkey_map[idx].handler();
}
```

### 30.246.5 Panel/Keyboard Scan and Debounce

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

## 30.247 Appendices: Schematics, Pinouts, MIDI Charts, Service Tables

### 30.247.1 Channel Card Schematic (Text, Partial)

```
[Sample RAM]---[Address Counter]<--[Pitch Reg]---[Adder]
                                  |                |
                              [Envelope]        [Loop Logic]
                                  |                |
                              [Playback]-----[DAC]---[AA Filter]---[Opamp]---[Sum Bus]
```

### 30.247.2 MIDI Implementation Chart

| Message     | Supported | Notes                  |
|-------------|-----------|------------------------|
| Note On/Off | Yes       | Full range             |
| Velocity    | Yes       | 0–127                  |
| Aftertouch  | No/Partial| Series III only        |
| CC          | Partial   | Vol/pan, limited       |
| Sysex       | Partial   | Dump/load, some config |
| Clock/MTC   | Yes       | Sync, SPP, start/stop  |

### 30.247.3 Service Table

| Component    | Symptom               | Test/Remedy         |
|--------------|-----------------------|---------------------|
| DRAM         | Missing voice, noise  | RAM test, swap      |
| DAC          | Distortion, silence   | Scope/test, replace |
| Opamp        | Noise, weak out       | Audio probe, swap   |
| FDD/HDD      | Boot fail, I/O error  | Replace/emulate     |
| Panel        | Dead keys, stuck LEDs | Scan, clean, swap   |

### 30.247.4 Floppy/SD Pinout (Excerpt)

| Pin | Signal   | Description           |
|-----|----------|-----------------------|
| 1   | GND      | Ground                |
| 2   | +5V      | Power                 |
| 3   | D0       | Data 0                |
| 4   | D1       | Data 1                |
| ... | ...      | ...                   |

---