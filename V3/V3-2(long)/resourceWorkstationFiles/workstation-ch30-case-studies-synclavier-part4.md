# Chapter 30: Case Studies – Synclavier (Complete Deep-Dive)
## Part 4: Card-Level Hardware, Service, Reverse Engineering, and Complete System Emulation

---

## Table of Contents

- 30.220 Card-Level Hardware: Schematics, Logic, and Signal Flow
  - 30.220.1 CPU Board: 68000/68020, Memory, Address Decoding
  - 30.220.2 Voice Card: FM/Partial Logic, Phase Accum, Envelope, DAC
  - 30.220.3 Sample Card: ADC, DMA, Sample RAM, Bus Arbitration
  - 30.220.4 Effects/DSP Card: DSP56000, RAM, Audio Bus, Host Interface
  - 30.220.5 Disk/Storage Card: Controller ASIC, SCSI/MFM, Buffering
  - 30.220.6 I/O Card: Panel, Keyboard, MIDI, Sync, NEDNet
- 30.221 Full Reverse Engineering of Electronics: Schematic Tracing and Behavior
  - 30.221.1 Power Distribution, Grounding, and Filtering
  - 30.221.2 Clock Distribution, Timing, and Reset
  - 30.221.3 Signal Integrity, Noise, and EMI Analysis
  - 30.221.4 Failure Modes, Diagnostics, and Repair
- 30.222 OS, UI, and Emulation: Firmware, Boot, and System Integration
  - 30.222.1 ROM Dumping, Firmware Disassembly, and OS Structure
  - 30.222.2 UI Emulation: Terminal, Panel Matrix, Keyboard Logic
  - 30.222.3 Full Software Emulation: Bus, Memory Map, Timing Accuracy
  - 30.222.4 Integration of FM, Sampling, Sequencer, and Effects Engines
- 30.223 Real-World Service: Troubleshooting, Rework, and Long-Term Support
  - 30.223.1 PSU and Regulator Service, Recapping, and Fusing
  - 30.223.2 Card Testing: In-Circuit, Out-of-Circuit, and Signal Injection
  - 30.223.3 Connector, Cable, and Backplane Reliability
  - 30.223.4 RAM/ROM Upgrades, Disk Replacements, and Modernization
- 30.224 Example C/Assembly Code: Bus Emulation, Register Access, and Real-Time Audio
  - 30.224.1 68k Memory/Bus Cycles and Wait State Logic
  - 30.224.2 Voice Card Register Interface, Phase Accumulation, Envelope Gen
  - 30.224.3 Sample Card DMA, ADC, and Buffer Management
  - 30.224.4 Effects Board DSP Command, Parameter Exchange
  - 30.224.5 Panel/Keyboard Emulation, Event Handling, and LED Logic
- 30.225 Appendices: Full Card Schematics, Bus Waveforms, Service Reference, and Emulator Design

---

## 30.220 Card-Level Hardware: Schematics, Logic, and Signal Flow

### 30.220.1 CPU Board: 68000/68020, Memory, Address Decoding

- **CPU**:  
  - Motorola 68000/68020, 8/16/32 MHz variants, with 16/24-bit address and 16-bit data.
  - Connected directly to backplane via bus transceivers (74LS245/244), with address decoding via PAL/GAL or discrete logic.
- **SRAM/ROM**:  
  - 32–512KB SRAM (62256, 6116), banked for OS, data, and fast patch loads.
  - 32–128KB EPROM (27C256, 27C512) for OS/boot/diagnostics.
- **Support**:  
  - Watchdog (MAX690 or discrete), reset logic, NMI generation for panel/keyboard interrupts.
- **Bus**:  
  - Buffered, with wait-state logic for slow peripherals; supports DMA requests from sample/disk/effects cards.

### 30.220.2 Voice Card: FM/Partial Logic, Phase Accum, Envelope, DAC

- **FM Logic**:
  - Each card contains 4–8 “partial” engines, implemented with:
    - Phase accumulator (32-bit counter, 74LS counters/PLD)
    - Sine ROM (2K–4K x 12 bits, fast bipolar ROM IC or PROM)
    - Multiplier (74LS181 ALU, custom gate array, or DSP block)
    - Envelope generator (74123 monostables, or ramp DAC via logic)
    - Modulation matrix implemented with analog switches or digital mux.
  - Accumulators incremented each sample by frequency register + modulator output.
- **DAC**:
  - 16-bit R-2R or hybrid DAC (PCM54, AD1860), driven by system clock, mutiplexed for each partial.
  - Analog antialiasing filter (Bessel 7th order), opamp buffer, relay to main sum bus.
- **Sum Bus**:
  - All cards output to analog or digital sum bus, with relay switching for mute/service.

### 30.220.3 Sample Card: ADC, DMA, Sample RAM, Bus Arbitration

- **ADC**:
  - Successive approximation, 16-bit (AD1674, AD676), 50–100kHz max.
  - Line receiver, anti-aliasing input filter, relay bypass for direct line in.
- **Sample RAM**:
  - 256KB–2MB DRAM or SRAM, dual-ported for DMA and CPU access.
- **DMA**:
  - DMA controller (8237, or custom PAL), arbitrates bus access with CPU.
  - Handles direct-to-disk, RAM-to-DAC, and block DMA for sample streaming.
- **Arbitration**:
  - Bus busy/acknowledge lines, DMA requests, priority logic to prevent audio underrun.

### 30.220.4 Effects/DSP Card: DSP56000, RAM, Audio Bus, Host Interface

- **DSP**:
  - Motorola DSP56000 @ 20–40MHz, 24-bit fixed point.
  - 64–256KB fast SRAM for code/data, mapped to backplane for host access.
- **Audio Bus**:
  - Digital or analog input/output; routed via programmable mux from sum bus.
  - Double-buffered RAM for block audio processing.
- **Host Interface**:
  - Command/status registers mapped to CPU bus; fast handshaking for parameter updates.

### 30.220.5 Disk/Storage Card: Controller ASIC, SCSI/MFM, Buffering

- **Controller**:
  - WD1010 (MFM), NCR53C94 (SCSI), or custom ASIC.
  - Registers mapped to CPU bus, interrupt-driven for transfer completion.
- **Buffer**:
  - 8–32KB SRAM for sector buffering, allows burst transfer to/from main RAM.
- **Upgrade**:
  - Later systems replace with SCSI2SD or BlueSCSI for silent, reliable storage.
- **Firmware**:
  - Disk BIOS handles formatting, ECC, directory management, and error recovery.

### 30.220.6 I/O Card: Panel, Keyboard, MIDI, Sync, NEDNet

- **Panel/Keyboard**:
  - Matrix scanned via 8255 PPI or custom ASIC; debounced in hardware/firmware.
  - LED drivers (ULN2803, 74LS595), multiplexed for large panel.
- **MIDI**:
  - Opto-isolated UART, hardware THRU, merge logic.
- **Sync/NEDNet**:
  - RS-422/485 transceivers, ESD protection, protocol implemented in firmware.

---

## 30.221 Full Reverse Engineering of Electronics: Schematic Tracing and Behavior

### 30.221.1 Power Distribution, Grounding, and Filtering

- **PSU**:
  - Linear supply, ±15V, +5V, +12V, massive toroidal transformer, large filter banks.
- **Distribution**:
  - Star topology; separate analog/digital returns, all meet at PSU star ground.
- **Filtering**:
  - Per-card bulk electrolytics (470–1000uF), per-IC 0.1uF ceramics.
  - Ferrite beads on power entry to cards; chassis earth bonded.

### 30.221.2 Clock Distribution, Timing, and Reset

- **Clocks**:
  - Main crystal (8–16MHz), divided for CPU, voice, and sample cards.
  - Clock buffers (74LS240/244), matched-length traces for timing accuracy.
- **Reset**:
  - MAX690 supervisor or RC network, delayed power-on reset.
  - NMI generation for panel/keyboard “panic” or watchdog.

### 30.221.3 Signal Integrity, Noise, and EMI Analysis

- **Signal Integrity**:
  - Short, direct bus traces; ground/power planes on 4-layer boards.
  - Termination resistors on high-speed lines.
- **Noise/EMI**:
  - Separate analog/digital planes; shielded audio paths.
  - Ferrites on all external I/O; careful separation of AC power and audio.

### 30.221.4 Failure Modes, Diagnostics, and Repair

- **Common Failures**:
  - Electrolytic cap leakage, failed DRAM, oxidized connectors, DAC/ADC drift, relay wear.
- **Diagnostics**:
  - Loopback tests, service ROM, panel error codes, bus analyzer (HP/Agilent/Keysight).
- **Repair**:
  - Full board-level replacement, socketed ICs, hot-swap cards, modern replacement parts (FRAM, SD storage).

---

## 30.222 OS, UI, and Emulation: Firmware, Boot, and System Integration

### 30.222.1 ROM Dumping, Firmware Disassembly, and OS Structure

- **ROM Dumping**:
  - EPROM programmer (TL866, MiniPro, etc.) extracts binary.
  - Disassemble with Ghidra, IDA Pro, or M68k tools; comment routines, identify vector tables, ISRs, OS entry points.
- **Firmware Map**:
  - Boot vector at 0x0000, jump table for panel/keyboard/voice/sample handlers.
  - Interrupt vectors for timer, panel, disk, DMA, MIDI.
- **OS Structure**:
  - Cooperative multitasking: event loop, task queue, interrupt handlers.
  - Command interpreter for terminal, panel state machine, sequencer/voice management.

### 30.222.2 UI Emulation: Terminal, Panel Matrix, Keyboard Logic

- **Terminal UI**:
  - VT100/ANSI emulation, 80x24 text, graphics mode for waveform/sample view.
  - Keyboard input mapped to OS command interpreter; scripting support.
- **Panel Matrix**:
  - 64–128 button matrix, scanned in software; debounced and queued as events.
- **Keyboard Logic**:
  - Velocity/aftertouch via dual-contact scan; split/layer logic per-patch.

### 30.222.3 Full Software Emulation: Bus, Memory Map, Timing Accuracy

- **Bus Emulation**:
  - Memory-mapped I/O, register access, wait-state logic, DMA cycles.
  - Accurate timing: cycle-accurate M68k core, real-time task scheduling.
- **Memory Map**:
  - Emulate SRAM, DRAM, VRAM, mapped I/O, and ROM windows.
- **Timing**:
  - Simulate sample-accurate audio, sequencer microtiming, and response to panel/keyboard input.

### 30.222.4 Integration of FM, Sampling, Sequencer, and Effects Engines

- **FM Engine**:
  - Software partial engine matches hardware: phase accum, sine lookup, mod matrix.
- **Sampling**:
  - Disk-backed sample RAM, real-time ADC/DAC emulation.
- **Sequencer**:
  - Event queue, time delta, playback engine, sync to emulated clock.
- **Effects**:
  - DSP emulation, block-based processing, parameter automation.

---

## 30.223 Real-World Service: Troubleshooting, Rework, and Long-Term Support

### 30.223.1 PSU and Regulator Service, Recapping, and Fusing

- **PSU Service**:
  - Replace all electrolytics every 10–15 years.
  - Check all regulator heat sinks, replace LM7815/7915 as needed.
- **Fusing**:
  - Dual fusing on IEC, check for correct slow-blow type.
  - Test inrush/overcurrent protection.

### 30.223.2 Card Testing: In-Circuit, Out-of-Circuit, and Signal Injection

- **In-Circuit**:
  - Logic probe, oscilloscope on address/data bus, check for stuck bits.
- **Out-of-Circuit**:
  - Bench PSU, signal generator for input, scope for output; test with known-good ROM.
- **Signal Injection**:
  - Inject known clock, CV, or audio; track through system to isolate faults.

### 30.223.3 Connector, Cable, and Backplane Reliability

- **Connectors**:
  - DIN-41612 gold-plated, clean and retension regularly.
  - Ribbon cables: check for bent pins, cracked insulation.
- **Backplane**:
  - Inspect for corrosion, broken traces, cold solder joints.

### 30.223.4 RAM/ROM Upgrades, Disk Replacements, and Modernization

- **RAM/ROM**:
  - Replace failed DRAM with modern equivalents; burn new EEPROM/EPROM for firmware upgrades.
- **Disks**:
  - Swap SCSI for SCSI2SD/BlueSCSI or SD storage.
- **Panel/Display**:
  - Replace CRT with LCD or HDMI bridge; USB keyboard/panel retrofits.

---

## 30.224 Example C/Assembly Code: Bus Emulation, Register Access, and Real-Time Audio

### 30.224.1 68k Memory/Bus Cycles and Wait State Logic

```c
// Bus cycle emulation for M68k read/write
uint16_t m68k_read(uint32_t addr) {
    if (addr < ROM_END) return rom[addr];
    if (addr < SRAM_END) return sram[addr - ROM_END];
    if (addr >= IO_BASE && addr < IO_END) return io_read(addr);
    // Wait states for slow peripherals
    delay_cycles(wait_states(addr));
    return 0xFFFF;
}
void m68k_write(uint32_t addr, uint16_t val) {
    if (addr < SRAM_END) sram[addr - ROM_END] = val;
    else if (addr >= IO_BASE && addr < IO_END) io_write(addr, val);
    delay_cycles(wait_states(addr));
}
```

### 30.224.2 Voice Card Register Interface, Phase Accumulation, Envelope Gen

```c
typedef struct {
    uint32_t phase;
    uint32_t freq_reg;
    uint16_t amp_reg;
    uint16_t mod_index;
    uint16_t env_state;
} partial_t;

void tick_partial(partial_t* p, uint16_t mod_val) {
    p->phase += p->freq_reg + ((mod_val * p->mod_index) >> 8);
    uint16_t idx = (p->phase >> 20) & 0xFFF;
    int16_t wave = sine_rom[idx];
    int32_t out = ((int32_t)wave * p->amp_reg * env_table[p->env_state]) >> 20;
    // Output to DAC
}
```

### 30.224.3 Sample Card DMA, ADC, and Buffer Management

```c
void sample_dma_copy(uint32_t src, uint32_t dst, uint32_t len) {
    for (uint32_t i = 0; i < len; ++i)
        sample_ram[dst + i] = sample_ram[src + i];
}
void adc_sample_tick() {
    uint16_t val = adc_read();
    sample_ram[sample_head++] = val;
    if (sample_head >= SAMPLE_RAM_SIZE) sample_head = 0;
}
```

### 30.224.4 Effects Board DSP Command, Parameter Exchange

```c
void dsp_send_cmd(uint8_t cmd, uint16_t param, uint16_t val) {
    dsp_cmd_reg = cmd;
    dsp_param_reg = param;
    dsp_val_reg = val;
    dsp_start_reg = 1; // trigger DSP
    // Wait for ack, etc.
}
```

### 30.224.5 Panel/Keyboard Emulation, Event Handling, and LED Logic

```c
void scan_panel_matrix() {
    for (int row = 0; row < ROWS; ++row) {
        set_panel_row(row);
        uint8_t cols = read_panel_cols();
        for (int col = 0; col < COLS; ++col) {
            bool pressed = (cols >> col) & 1;
            if (pressed != panel_state[row][col]) {
                queue_event(row, col, pressed);
                panel_state[row][col] = pressed;
            }
        }
    }
}
void update_panel_leds() {
    for (int i = 0; i < NUM_LEDS; ++i)
        set_led(i, led_state[i]);
}
```

---

## 30.225 Appendices: Full Card Schematics, Bus Waveforms, Service Reference, and Emulator Design

### 30.225.1 Voice Card Schematic (Text, Partial)

```
[Freq Reg]---[Phase Accum]---[Sine ROM]---[Multiplier]<---[Amp Reg]
   |                |                |            |
[Mod Index]         |                |         [Envelope]
   |                |                |            |
   +---------------[Adder]<----------+------------+
                        |
                    [DAC]---[AA Filter]---[Sum Bus]
```

### 30.225.2 Bus Waveforms

- **Address/Data**:  
  - Address stable, data valid within 80ns of clock.
- **Bus Arbitration**:  
  - DMA asserts BUSREQ, CPU releases BUSACK, DMA takes control for burst transfer.

### 30.225.3 Service Reference Table

| Component    | Failure Symptom         | Test/Remedy           |
|--------------|-------------------------|-----------------------|
| PSU Caps     | Hum, dropout            | ESR/cap replace       |
| DRAM         | Boot fail, audio noise  | RAM test, swap        |
| Voice Card   | Missing voice, detune   | Test tone, swap card  |
| Disk         | Boot fail, I/O error    | SCSI2SD, cable check  |
| Panel        | Dead keys, stuck LEDs   | Scan, clean, swap ICs |

### 30.225.4 Emulator Design Block Diagram

```
[68k Core]---[Bus Emu]---[Voice/Sample/Eff RAM]
    |             |         |
[ROM Loader]---[Panel/Key Emu]---[Audio Out]
    |             |
[File System]---[Disk Emu]---[SCSI2SD/SD]
```

---