# Chapter 30: Case Studies – Fairlight CMI (Complete Deep-Dive)
## Part 3: Voice Card Hardware, Filter/Envelope Electronics, Service, Modernization, and Reverse Engineering

---

## Table of Contents

- 30.420 Voice Card Hardware: Schematics, Digital/Analog Path, and Retro-Engineering
  - 30.420.1 Block Diagram Overview
  - 30.420.2 Sample RAM, Address Logic, Looping, and DAC
  - 30.420.3 Analog Smoothing, SSM2044/Opamp Output, and Noise Suppression
  - 30.420.4 Voice Card Schematic Walkthrough (Text)
  - 30.420.5 Voice Card Failure Modes, Testing, and Service
- 30.421 Filters, Envelope Generators, and Output Summing
  - 30.421.1 SSM2044/2040 Filter: Circuit, CV Control, and Modulation
  - 30.421.2 Envelope Generators: Hardware/Software, Curve, and Timing
  - 30.421.3 Output Summing: Mix Bus, Opamp Stages, and Individual Outs
- 30.422 Service, Troubleshooting, and Modernization
  - 30.422.1 Service Modes, Failure Diagnostics, and Field Repair
  - 30.422.2 Modernization: Flash Storage, CPU Upgrades, and Patch Editors
  - 30.422.3 Audio Upgrades: Output Buffer, Noise Floor, and Grounding
- 30.423 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation
  - 30.423.1 ROM Dump Process, Structure, and Tools
  - 30.423.2 Firmware Disassembly: Entry Points, ISRs, Main Loops
  - 30.423.3 System Emulation: Bus, Voice Logic, and Peripherals
  - 30.423.4 Recreating the Voice Card in Software/FPGA
- 30.424 Example C Code: Voice Emulation, Filter Envelope, Tape Handler, and UI Logic
  - 30.424.1 Voice Card Emulation: Sample Playback, Filter, Envelope
  - 30.424.2 Tape IO, Patch Block Transfer, and Verification
  - 30.424.3 Panel/Lightpen UI Emulation
  - 30.424.4 Service/Test Menu, Voice Diagnostics
- 30.425 Appendices: Schematics, Filter Tables, Pinouts, Service Flowcharts, Emulation API

---

## 30.420 Voice Card Hardware: Schematics, Digital/Analog Path, and Retro-Engineering

### 30.420.1 Block Diagram Overview

```
[CPU Bus]--[Addr/Control Logic]--[Sample RAM]--[Counter/Loop Logic]--[DAC]--[RC Filter]--[SSM2044]--[Envelope]--[Opamp]--[Mix Bus]
    |            |                |                   |                |         |           |              |        |
[DMA/IRQ]   [Start/End/Loop]  [Pitch/Step]       [Env/LFO]        [CV DAC]  [Sweep CV]   [VCA/Panel]    [LEDs]  [Output]
```
- Each voice card includes digital address logic, sample RAM, DAC, analog smoothing, VCF (SSM2044/2040), envelope generation, and output buffer.
- Parameters (sample start/end, loop, pitch, env, filter) are CPU-addressable for modulation and automation.

### 30.420.2 Sample RAM, Address Logic, Looping, and DAC

- **Sample RAM**:
  - Typically 4–16KB SRAM or DRAM per voice (Series I/II), up to 32KB+ in Series III.
  - Organized as linear, with programmable start, end, and loop pointers.
- **Address Logic**:
  - Counter increments at “pitch” clock; pointer wraps to loop or disables voice at end.
  - Pitch control: programmable divider, can use hardware multiplier for fine pitch sweeps.
- **Looping**:
  - Simple “start–end” or crossfade (in Series III).
  - Logic can be polled by CPU for real-time editing or automated looping.
- **DAC**:
  - 8-bit (DAC08, AD558), 12-bit (AD7541, AD7226), R-2R or monolithic.
  - Output is zero-centered or unipolar, depending on card revision.

### 30.420.3 Analog Smoothing, SSM2044/Opamp Output, and Noise Suppression

- **RC Filter**:
  - Simple RC lowpass after DAC to reduce quantization noise.
- **SSM2044/2040 VCF**:
  - 4-pole lowpass, cutoff and resonance set by CV from env/LFO/CPU.
  - Can self-oscillate at high resonance; cutoff modulated by envelope or velocity.
- **Opamp Output**:
  - NE5532, TL072, or similar; buffers and sums voice outputs.
  - Mixes to stereo, quad, or individual outs; optional output muting relay.
- **Noise Suppression**:
  - Ferrite beads/inductors on power/analog lines, careful PCB layout, ground planes.

### 30.420.4 Voice Card Schematic Walkthrough (Text)

```
[Bus]--[Addr Decoder]--[Start/End/Loop Regs]--[Counter]--[Sample RAM]--[DAC]--[RC Filter]--[SSM2044]--[Envelope]--[Opamp]--[Mix Bus]
    |         |                 |                   |             |     |           |           |             |         |
[DMA/IRQ]  [Pitch CV]     [Pointer Logic]    [Envelope CV]   [Loop Logic]  [Panel LED]    [CV DAC]     [Panel]    [Output]
```
- **Bus**: Controls sample, pitch, and envelope parameters.
- **Addr Logic**: Selects sample regions, handles looping.
- **Counter**: Driven by pitch clock; wraps or loops as programmed.
- **Sample RAM/DAC**: Delivers sample value to analog.
- **RC Filter/VCF/Envelope**: Analog shaping, resonance, amplitude control.
- **Opamp/Mix Bus**: Final buffer, sum, and output to main/individual outs.

### 30.420.5 Voice Card Failure Modes, Testing, and Service

- **Failures**:
  - RAM: stuck notes, noise, silence, aliasing.
  - DAC: distortion, missing/weak output.
  - SSM2044: no sweep, static sound, resonance artifacts.
  - Envelope: no attack/release or stuck amplitude.
  - Logic: stuck note, looping errors, pitch artifacts.
- **Service**:
  - In-circuit: check DAC, VCF, and envelope with scope/audio probe.
  - RAM test and swap, reflow solder, clean sockets, recap, check trimmers.

---

## 30.421 Filters, Envelope Generators, and Output Summing

### 30.421.1 SSM2044/2040 Filter: Circuit, CV Control, and Modulation

- **SSM2044/2040**:
  - 4-pole lowpass, classic “analog” warmth; CV for cutoff/resonance.
  - Filter CV from envelope, keytrack, velocity, or LFO.
  - Resonance trimmer, self-oscillation at max.
  - External CV input (mod wheel, pedal) possible with minor mod.

### 30.421.2 Envelope Generators: Hardware/Software, Curve, and Timing

- **Envelope**:
  - Series I/II: hardware (analog/digital hybrid ADSR), Series III: software-generated, per voice.
  - Curve: classic ADSR, with attack, decay, sustain, release time and level.
  - Envelope output shapes VCA (amplitude) and can modulate VCF cutoff.
  - Retrigger on note-on or loop for evolving sounds.

### 30.421.3 Output Summing: Mix Bus, Opamp Stages, and Individual Outs

- **Mix Bus**:
  - All voice opamp outs summed; stereo, quad, and (Series III) individual outs.
- **Opamp Stages**:
  - Low-noise design; output buffer, level/gain trimmers, optional muting relay.
- **Grounding**:
  - Star ground for analog and digital, shielded cable for outs.

---

## 30.422 Service, Troubleshooting, and Modernization

### 30.422.1 Service Modes, Failure Diagnostics, and Field Repair

- **Diagnostic Mode**:
  - Accessed via panel or system menu; tests RAM, DAC, VCF, envelope.
  - Panel LEDs show error status; CRT displays detailed logs.
- **Repair**:
  - Board swap, IC replacement (socketed), cleaning, recapping, reflow.
  - Calibration: trimmers for DAC offset/gain, VCF cutoff/resonance, output level.

### 30.422.2 Modernization: Flash Storage, CPU Upgrades, and Patch Editors

- **Flash Storage**:
  - Replace floppy/HDD with Flash/SD adapters (SCSI2SD, HxC).
  - Mass storage, faster load/save, reliability.
- **CPU Upgrades**:
  - Rare, but possible (faster 6809/68000); may require firmware mod.
- **Patch Editors**:
  - Modern PC/Mac editors with MIDI/Sysex bulk transfer, waveform editing, librarian.

### 30.422.3 Audio Upgrades: Output Buffer, Noise Floor, and Grounding

- **Output Buffer**:
  - Replace opamps with modern low-noise ICs (OPA2134, etc.).
- **Noise Floor**:
  - Reground, shield, recap; star ground, toroid transformer.
- **Audio Path**:
  - Upgrade cables, switchcraft connectors, balanced outs.

---

## 30.423 Full Reverse Engineering: ROM Dumping, Firmware Disassembly, and Emulation

### 30.423.1 ROM Dump Process, Structure, and Tools

- **ROM Dump**:
  - Use programmer (TL866, MiniPro, etc.) to extract raw binary (.bin/.hex) from EPROMs.
  - Verify CRC, compare with known firmware for Series I/II/III.
- **Structure**:
  - Entry vectors, main loop, ISRs, UI, Page logic, sample engine, voice routines.
- **Tools**:
  - Ghidra, IDA Pro, 6809/68000 disassemblers, annotate jump tables and handlers.

### 30.423.2 Firmware Disassembly: Entry Points, ISRs, Main Loops

- **Entry Points**:
  - RESET, NMI, IRQ, UI event, timer, floppy, MIDI, Page-R tick.
- **ISRs**:
  - Disk, audio tick, lightpen, panel, MIDI, error.
- **Main Loop**:
  - Poll event queue, update UI, scan panel/lightpen, manage sequencer, file I/O.

### 30.423.3 System Emulation: Bus, Voice Logic, and Peripherals

- **Bus**:
  - Emulate 8/16-bit bus, memory-mapped I/O, DMA.
- **Voice Logic**:
  - Accurate sample playback, address counter, DAC, filter, envelope, and output path.
- **Peripherals**:
  - Panel, CRT, lightpen, floppy/disk, MIDI, patch memory.

### 30.423.4 Recreating the Voice Card in Software/FPGA

- **Software**:
  - Emulate full sample playback, looping, envelope, filter, DAC, anti-aliasing.
- **FPGA**:
  - RTL for address counter, RAM, DAC, filter CV, output bus.
- **Integration**:
  - Drop-in for CMI emulator or hybrid upgrade boards.

---

## 30.424 Example C Code: Voice Emulation, Filter Envelope, Tape Handler, and UI Logic

### 30.424.1 Voice Card Emulation: Sample Playback, Filter, Envelope

```c
typedef struct {
    uint32_t pos, step, start, end, loop;
    uint8_t env, active;
} voice_t;
uint8_t sample_ram[65536];

int16_t emulate_voice(voice_t* v) {
    if (!v->active) return 0;
    v->pos += v->step;
    if (v->pos >= v->end) {
        if (v->loop) v->pos = v->loop;
        else v->active = 0;
    }
    uint8_t sample = sample_ram[v->pos];
    int16_t filtered = emulate_vcf(sample * v->env / 255, v->env);
    return filtered;
}
```

### 30.424.2 Tape IO, Patch Block Transfer, and Verification

```c
int tape_read_block(int block, uint8_t* buf, int len) {
    for (int i = 0; i < len; ++i) buf[i] = tape_next_byte();
    uint8_t cs = calc_checksum(buf, len - 1);
    if (cs != buf[len - 1]) return -1;
    return 0;
}
int tape_write_block(int block, uint8_t* buf, int len) {
    for (int i = 0; i < len - 1; ++i) tape_write_byte(buf[i]);
    tape_write_byte(calc_checksum(buf, len - 1));
    return 0;
}
```

### 30.424.3 Panel/Lightpen UI Emulation

```c
void show_page(const char* page, int param, int val) {
    crt_update(0, 0, page);
    char buf[16];
    snprintf(buf, 16, "Param: %d Val: %d", param, val);
    crt_update(1, 0, buf);
}
void run_macro(int macro_id) {
    switch (macro_id) {
        case 0: assign_voice(...); break;
        case 1: show_page("Page2", 3, 64); break;
    }
}
```

### 30.424.4 Service/Test Menu, Voice Diagnostics

```c
void show_service_menu() {
    crt_update(0, 0, "Service Menu");
    crt_update(1, 0, "1: Voice Test");
    crt_update(2, 0, "2: DAC Calib");
    crt_update(3, 0, "3: VCF Calib");
}
void run_voice_test() {
    for (int v = 0; v < VOICES; ++v) {
        assign_voice(...);
        crt_update(4 + v, 0, "Voice OK");
    }
}
```

---

## 30.425 Appendices: Schematics, Filter Tables, Pinouts, Service Flowcharts, Emulation API

### 30.425.1 Voice Card Schematic (Text, Partial)

```
[Bus]--[Addr Decoder]--[Sample RAM]--[Counter]--[DAC]--[RC Filter]--[SSM2044]--[Envelope]--[Opamp]--[Mix Bus]
    |      |         |         |         |         |           |           |            |        |
[DMA/IRQ][Start/End][Pointer][Loop][Panel LED][CV DAC][Panel][CV DAC][Panel][Output]
```

### 30.425.2 Filter Table

| CV (V) | Filter Cutoff (Hz) | Res Peak | VCA Gain (dB) |
|--------|--------------------|----------|---------------|
| 0      |   ~20              |  1.0     | -80           |
| 1      |   ~50              |  1.0     | -40           |
| 2      |  ~250              |  1.2     | -20           |
| 3      | ~1200              |  1.5     |  0            |
| 4      | ~6000              |  2.0     | +10           |
| 5      | ~17000             |  2.2     | +20           |

### 30.425.3 Service Flowchart

```
[Start] -> [Panel Test?] -> [Key Scan] -> [LED Feedback]
         -> [DAC Calib?]  -> [Output Stepped Voltage] -> [Trim]
         -> [VCF Calib?]  -> [Sweep CV] -> [Trim/Observe]
         -> [Voice Test?] -> [Trigger/Check Output]
         -> [End]
```

### 30.425.4 Emulation API Outline

```c
typedef struct { ... } fairlight_state_t;
void fairlight_init(fairlight_state_t*);
void fairlight_tick(fairlight_state_t*);
void fairlight_load_patch(fairlight_state_t*, const char* name);
void fairlight_save_patch(fairlight_state_t*, const char* name);
void fairlight_set_param(fairlight_state_t*, int param, int val);
// etc.
```
---