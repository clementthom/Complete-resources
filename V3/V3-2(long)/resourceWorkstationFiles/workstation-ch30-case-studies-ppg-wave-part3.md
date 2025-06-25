# Chapter 30: Case Studies – PPG Wave (Complete Deep-Dive)
## Part 3: Voice Card Hardware, Filter/VCA Electronics, Service, MIDI, Modernization, and Reverse Engineering

---

## Table of Contents

- 30.283 Voice Card Hardware: Schematics, Digital/Analog Path, and Retro-Engineering
  - 30.283.1 Block Diagram Overview
  - 30.283.2 Wavetable ROM Access, Phase Logic, and Sample Generation
  - 30.283.3 DAC, Analog Smoothing, and Noise Suppression
  - 30.283.4 SSM2044/2040 VCF, SSM2024 VCA, and Output Stage
  - 30.283.5 Voice Card Schematic Walkthrough (Text)
  - 30.283.6 Card Testing, Failure Modes, and Service
- 30.284 MIDI and External Control: Hardware, Integration, and Channel Mapping
  - 30.284.1 MIDI Hardware: UART, Optoisolation, and Merging
  - 30.284.2 MIDI Software: Event Parsing, Channel Map, Voice Assignment
  - 30.284.3 MIDI Implementation Chart, Limitations, and Sysex
  - 30.284.4 Example MIDI Event Handling and C Code
- 30.285 Storage, Modernization, and Computer Integration
  - 30.285.1 Tape/EPROM, Battery RAM, and Patch Management
  - 30.285.2 Modernization: Flash/SD Solutions and CPU Upgrades
  - 30.285.3 Computer Integration: Editors, Patch Dumps, and Remote Control
- 30.286 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation
  - 30.286.1 ROM Dump Process, Structure, and Tools
  - 30.286.2 Firmware Disassembly: Entry Points, ISRs, Main Loops
  - 30.286.3 System Emulation: Bus, Voice Logic, and Peripherals
  - 30.286.4 Recreating the Voice Card in Software/FPGA
- 30.287 Example C Code: Voice Emulation, MIDI Engine, Tape Handler, and Panel Logic
  - 30.287.1 Voice Card Emulation: Wavetable Osc, Filter, Envelope, VCA
  - 30.287.2 MIDI Event Parsing and Assignment
  - 30.287.3 Tape IO, Patch Block Transfer, and Verification
  - 30.287.4 Panel/Display UI Emulation: Page, Edit, Feedback
  - 30.287.5 Panel/Keyboard Scan and Debounce
- 30.288 Appendices: Schematics, Filter Tables, Pinouts, Service Tables

---

## 30.283 Voice Card Hardware: Schematics, Digital/Analog Path, and Retro-Engineering

### 30.283.1 Block Diagram Overview

```
[Wavetable ROM]--[Address Logic]<--[Phase Accum]---[Sample Logic]---[DAC]---[AA Filter]---[SSM2044/2040]---[SSM2024]---[Opamp]---[Sum Bus]
    |                 |                |                 |               |        |             |                |           |
[LFO/Env Mod]    [Wave Pos]       [Loop Logic]   [Noise Filter]    [CV DAC]   [Env/LFO]   [CV DAC]         [CV DAC]   [Mix Out]
```

- Each voice card delivers a complete digital oscillator, phase-accumulation logic, wavetable ROM, DAC, analog smoothing, VCF, VCA, and output buffer.
- All key synthesis parameters (wave, phase, pitch, env, filter, VCA) are software addressable for modulation and automation.

### 30.283.2 Wavetable ROM Access, Phase Logic, and Sample Generation

- **Wavetable ROM**:
  - 2K–8K x 8/12 bits (usually 2764, 27128 EPROMs).
  - Organized as banks of waveforms, each waveform is a single cycle (64–256 samples).
- **Phase Accum/Logic**:
  - 16–20 bit phase accumulator, increments per note pitch, LFO, or mod source.
  - High bits select waveform, lower bits select sample within waveform; fractional interpolation for smooth scan.
- **Sample Generation**:
  - Each tick, accumulator advances, ROM outputs waveform value for current position.
  - Interpolation (linear, sometimes higher order) reduces stepping/aliasing.

### 30.283.3 DAC, Analog Smoothing, and Noise Suppression

- **DAC**:
  - 8/12-bit R-2R (DAC08, AD7541), or monolithic.
  - Output is zero-centered or unipolar, depending on voice card revision.
- **Smoothing/Noise**:
  - Passive RC filter or active opamp lowpass to reduce quantization noise.
  - Ferrite beads or small inductors on DAC output to suppress digital hash.

### 30.283.4 SSM2044/2040 VCF, SSM2024 VCA, and Output Stage

- **SSM2044/2040 VCF**:
  - 4-pole lowpass, cutoff/resonance set by CVs (0–5V, from CPU/LFO/env/velocity).
  - Cutoff modulated by envelope, LFO, or keytrack.
  - Resonance can self-oscillate at high setting.
- **SSM2024 VCA**:
  - Exponential current-control; CV (0–5V) from envelope, velocity, or mod matrix.
  - Response shaped by attack/decay/sustain/release curve, sometimes velocity accent.
- **Output Stage**:
  - Dual opamps (NE5532/TL072) buffer and sum all voices; can route to main, individual, or aux outs.
  - Output protection: series resistors, optional muting relays, overload diodes.

### 30.283.5 Voice Card Schematic Walkthrough (Text)

```
[CPU Bus]->[Voice Card Addr Reg]->[Phase Accum]->[Wavetable ROM]->[DAC]->[RC Filter]->[SSM2044 VCF]->[SSM2024 VCA]->[Opamp]->[Sum Bus]
    |                |                  |             |             |        |             |              |           |       |
    |          [Loop Logic]     [Wave/Pos Logic] [Noise Filter] [CV DAC] [Envelope] [Velocity/Mod]   [CV DAC]   [Panel LED]  |
    |                                                                                                              [Status]
```

- **CPU Bus**: Controls all registers, parameter updates, and modulation assignments.
- **Addr Reg/Phase Accum**: Phase logic calculates sample position for each oscillator tick.
- **Wavetable ROM**: Stores waveform data; outputs sample to DAC each tick.
- **DAC/Filter**: Converts digital sample to analog, applies anti-aliasing.
- **VCF/VCA**: Shaped and amplified; CVs set by software, envelopes, and external controllers.
- **Opamp/Sum Bus**: Buffers, sums, and routes analog signal to output.

### 30.283.6 Card Testing, Failure Modes, and Service

- **Common Failures**:
  - ROM: dead/bad waveform, stuck notes, noise, or silence.
  - DAC: distortion, missing or weak output.
  - SSM2044/2040: no filter sweep, static sound, resonance artifacts.
  - SSM2024: low output, distortion, no amplitude control.
  - Phase/Addr logic: stuck notes, no pitch, or aliasing artifacts.
- **Service**:
  - In-circuit: check phase, DAC, filter, and VCA with scope/audio probe.
  - Out-of-circuit: test with bench supply, dummy input, scope output.
  - Swap socketed ICs, reflow solder, clean contacts, recap as needed.

---

## 30.284 MIDI and External Control: Hardware, Integration, and Channel Mapping

### 30.284.1 MIDI Hardware: UART, Optoisolation, and Merging

- **UART**: 6850, 8251, or Z80 SIO; interrupt-driven, optoisolated, 5-pin DIN.
- **Buffering**: 128–512 byte FIFO, overflow/underrun protected.
- **MIDI Merge**: Some models include hardware/software MIDI merge, combining panel and MIDI events.

### 30.284.2 MIDI Software: Event Parsing, Channel Map, Voice Assignment

- **Parser**:
  - Handles running status, real-time, and system messages.
  - Filters by channel, note, velocity, CC, program change.
- **Channel Map**:
  - User-assignable: MIDI channel to voice/patch/bank.
  - Split/layer: assign key ranges to patches/banks.
- **Voice Assignment**:
  - Scheduler allocates note-on to free voice; supports chord/unison, split/layer.
  - Handles note-off, sustain pedal, CC, aftertouch, macro triggers.

### 30.284.3 MIDI Implementation Chart, Limitations, and Sysex

| Message      | Supported | Comments                         |
|--------------|-----------|----------------------------------|
| Note On/Off  | Yes       | Full poly, chord, split/layer    |
| Velocity     | Yes       | 0–127, per-voice                 |
| Aftertouch   | Yes       | Channel/key, macro-mappable      |
| Program Chg  | Yes       | Patch/bank select                |
| CC           | Yes       | All common, macro-assignable     |
| Sysex        | Yes       | Bulk dump/load, patch edit       |
| Clock/MTC    | Yes       | Sync, start/stop supported       |

- **Limitations**:  
  - No MPE, limited NRPN, Sysex may be slow for large dumps.

### 30.284.4 Example MIDI Event Handling and C Code

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
        else handle_midi_event(status, byte);
    }
}

void handle_midi_event(uint8_t status, uint8_t data) {
    if ((status & 0xF0) == 0x90) { // Note On
        uint8_t channel = status & 0x0F;
        uint8_t note = data;
        uint8_t vel = midi_in_buf[midi_tail++];
        assign_voice(note, vel, midi_channel_to_patch[channel]);
    }
    // Handle CC, program change, aftertouch, macros...
}
```

---

## 30.285 Storage, Modernization, and Computer Integration

### 30.285.1 Tape/EPROM, Battery RAM, and Patch Management

- **Tape**:  
  - Cassette interface supports patch/sequence dump and restore; block/sector with checksum, header, and retry.
  - Patch management: load/save banks, verify/compare, error reporting.
- **EPROM**:  
  - Main OS and waveform data; upgrades for new features.
  - User patches in battery RAM, preserved on power loss.

### 30.285.2 Modernization: Flash/SD Solutions and CPU Upgrades

- **Flash/SD Storage**:  
  - Aftermarket solutions can replace tape/EPROM with SD/USB; requires logic adapter or firmware mod.
  - Flash patch storage: instant recall, bulk dump, PC integration.
- **CPU Upgrades**:  
  - Rare, but possible: faster Z80/6809, higher RAM, extended wavetables, faster panel response.

### 30.285.3 Computer Integration: Editors, Patch Dumps, and Remote Control

- **Patch Editors**:  
  - Modern PC/Mac editors communicate via MIDI Sysex or serial; visualize, edit, and archive patches.
  - Bulk patch dump/load, parameter editing, real-time automation via USB-MIDI.
- **Remote Control**:  
  - MIDI CC/NRPN, program change, macro triggers; sequencer/arpeggiator control via DAW.

---

## 30.286 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation

### 30.286.1 ROM Dump Process, Structure, and Tools

- **ROM Dump**:  
  - Use programmer (TL866, MiniPro, Batronix) to extract raw binary from EPROMs.
  - Save as .bin/.hex; verify CRC, compare to known PPG firmware versions.
- **Structure**:  
  - Entry vectors, main loop, ISRs, panel/display code, wavetable data, patch routines.
- **Tools**:  
  - Ghidra, IDA Pro, Z80/6809 disassemblers; annotate jump tables, label handlers.

### 30.286.2 Firmware Disassembly: Entry Points, ISRs, Main Loops

- **Entry Points**:  
  - RESET, NMI, IRQ, panel, timer, tape, MIDI, voice tick.
- **ISRs**:  
  - Service tape, MIDI, panel, timer; update event queues, handle errors.
- **Main Loop**:  
  - Poll event queues, update UI, scan panel, manage voice allocation, handle patch storage.

### 30.286.3 System Emulation: Bus, Voice Logic, and Peripherals

- **Bus**:  
  - Simulate 8/16-bit bus, memory-mapped I/O, DMA (if present).
- **Voice Logic**:  
  - Cycle-accurate phase accum, wavetable read, DAC output, filter/VCA CV calculation.
- **Peripherals**:  
  - Panel/display, tape, MIDI, voice/parameter registers, patch memory.

### 30.286.4 Recreating the Voice Card in Software/FPGA

- **Software**:  
  - Emulate full wavetable oscillator, interpolation, envelope, filter, VCA, anti-aliasing.
- **FPGA**:  
  - RTL for phase accum, wavetable ROM, DAC, filter/VCA CV, and audio path.
- **Integration**:  
  - Software/FPGA engine can drop into PPG emulator or hybrid upgrade board.

---

## 30.287 Example C Code: Voice Emulation, MIDI Engine, Tape Handler, and Panel Logic

### 30.287.1 Voice Card Emulation: Wavetable Osc, Filter, Envelope, VCA

```c
typedef struct {
    uint32_t phase;
    uint32_t phase_inc;
    uint8_t wavetable;
    uint8_t position;
    uint16_t env_level;
    uint8_t filter_cv;
    uint8_t vca_cv;
    uint8_t active;
} voice_t;

uint8_t wavetable_rom[64][128]; // Example: 64 waves, 128 samples

int16_t playback_voice(voice_t* v) {
    uint16_t idx = (v->phase >> 9) & 0x7F;
    uint8_t wave_a = v->wavetable;
    uint8_t wave_b = (v->wavetable + 1) % 64;
    uint8_t pos_a = wavetable_rom[wave_a][idx];
    uint8_t pos_b = wavetable_rom[wave_b][idx];
    uint16_t frac = v->phase & 0x1FF;
    int16_t val = ((pos_a * (512 - frac)) + (pos_b * frac)) >> 9;
    v->phase += v->phase_inc;
    int32_t env_val = (val * v->env_level) >> 10;
    int32_t filtered = emulate_vcf(env_val, v->filter_cv);
    int32_t out = (filtered * v->vca_cv) >> 8;
    return out;
}
```

### 30.287.2 MIDI Event Parsing and Assignment

```c
void assign_voice(uint8_t note, uint8_t vel, uint8_t patch) {
    int v = find_free_voice();
    if (v < 0) v = steal_voice();
    voices[v].active = 1;
    voices[v].phase = 0;
    voices[v].phase_inc = note_to_phase_inc(note);
    voices[v].wavetable = patch_to_wave(patch);
    voices[v].env_level = vel << 3;
    voices[v].filter_cv = patch_filter(patch, note, vel);
    voices[v].vca_cv = vel;
}
```

### 30.287.3 Tape IO, Patch Block Transfer, and Verification

```c
int tape_read_block(int block, uint8_t* buf, int len) {
    // Block transfer from tape, verify checksum
    for (int i=0; i<len; ++i) buf[i] = tape_next_byte();
    uint8_t cs = calc_checksum(buf, len-1);
    if (cs != buf[len-1]) return -1; // Error
    return 0;
}

int tape_write_block(int block, uint8_t* buf, int len) {
    for (int i=0; i<len-1; ++i) tape_write_byte(buf[i]);
    tape_write_byte(calc_checksum(buf, len-1));
    return 0;
}
```

### 30.287.4 Panel/Display UI Emulation: Page, Edit, Feedback

```c
void show_edit_page(const char* group, const char* param, int val) {
    lcd_update(0, 0, group);
    lcd_update(1, 0, param);
    char buf[8];
    snprintf(buf, 8, "%03d", val);
    lcd_update(1, 12, buf);
}
void run_macro(int macro_id) {
    switch (macro_id) {
        case 0: assign_voice(60, 100, 2); break; // Demo
        case 1: set_edit_page("Filter"); break;
        // ...
    }
}
```

### 30.287.5 Panel/Keyboard Scan and Debounce

```c
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

## 30.288 Appendices: Schematics, Filter Tables, Pinouts, Service Tables

### 30.288.1 Voice Card Schematic (Text, Partial)

```
[CPU Bus]--[Addr Reg]--[Phase Accum]--[Wavetable ROM]--[DAC]--[RC Filter]--[SSM2044]--[SSM2024]--[Opamp]--[Sum Bus]
    |           |            |               |             |       |            |          |         |       |
    |       [Loop]     [Wave Logic]    [Noise]         [CV DAC] [Env/LFO]   [CV DAC]   [CV DAC] [LEDs]  [Status]
```

### 30.288.2 Filter/VCA Table

| CV (V) | Filter Cutoff (Hz) | Res Peak | VCA Gain (dB) |
|--------|--------------------|----------|---------------|
| 0      |   ~20              |  1.0     | -80           |
| 1      |   ~50              |  1.0     | -40           |
| 2      |  ~250              |  1.2     | -20           |
| 3      | ~1200              |  1.5     |  0            |
| 4      | ~6000              |  2.0     | +10           |
| 5      | ~17000             |  2.2     | +20           |

### 30.288.3 Service Table

| Component    | Symptom               | Test/Remedy         |
|--------------|-----------------------|---------------------|
| ROM          | Dead voice, noise     | Swap/test           |
| DAC          | Distortion, silence   | Scope/test, replace |
| SSM2044      | No sweep, static      | CV test, swap       |
| SSM2024      | Low output, dist      | Audio probe, swap   |
| Panel        | Dead keys, stuck LEDs | Scan, clean, swap   |

### 30.288.4 Pinout (Excerpt)

| Pin | Signal   | Description           |
|-----|----------|-----------------------|
| 1   | GND      | Ground                |
| 2   | +5V      | Digital supply        |
| 3   | D0       | Data bus 0            |
| 4   | D1       | Data bus 1            |
| ... | ...      | ...                   |

---