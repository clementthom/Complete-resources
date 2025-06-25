# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 15: Comprehensive Voice Firmware, Real-Time Modulation, and Patch Morphing

---

## Table of Contents

- 30.154 Voice Firmware: Per-Voice Microcontroller, Logic, and Subsystem
  - 30.154.1 Voice Card Digital Logic: Address Decoding, Handshaking, and Boot
  - 30.154.2 Firmware Structure: Main Loop, Interrupts, and Modulation Handling
  - 30.154.3 Communication Protocol: Bus, Latches, and Status Reporting
  - 30.154.4 Fault Detection, Watchdog, and Recovery
- 30.155 Real-Time Modulation: Polyphonic Matrix Evaluation and Hardware Update
  - 30.155.1 Modulation Matrix per Voice: Data Flow and Scheduling
  - 30.155.2 Envelope, LFO, Velocity, and Macro Sources: Digital-to-Analog Translation
  - 30.155.3 DAC and S/H Update Cycle: Priority, Jitter, and Performance
  - 30.155.4 Synchronization Across Voices: Phase, Timing, and Spread
- 30.156 Patch Morphing, Macro Assignment, and Live Performance Algorithms
  - 30.156.1 Morphing Two Patches: State Interpolation and Real-Time Calculation
  - 30.156.2 Macro System: Mapping, Live Control, and UI Feedback
  - 30.156.3 Panel and MIDI Mapping: Dynamic Assignment and Automation
  - 30.156.4 C Code for Morph Engine and Macro Matrix Evaluation
- 30.157 Example C Code: Voice Firmware, Modulation Engine, and Macros
  - 30.157.1 Voice Firmware Main Loop and Interrupts
  - 30.157.2 Per-Voice Modulation Calculation and DAC Update
  - 30.157.3 Patch Morphing Algorithm and Real-Time Update
  - 30.157.4 Macro Handler, Mapping Table, and Event Dispatch
- 30.158 Appendices: Voice Card Firmware Map, Bus Protocol, and Debugging Tools

---

## 30.154 Voice Firmware: Per-Voice Microcontroller, Logic, and Subsystem

### 30.154.1 Voice Card Digital Logic: Address Decoding, Handshaking, and Boot

- **Voice Card MCU/Logic**:
  - Each card may have dedicated logic (e.g., 8031/8051 or discrete logic), or be slaved to main CPU.
  - Address latch (74LS373/74HC573) holds address, decoded by 74LS138 for registers, DAC, S/H.
- **Handshaking**:
  - Ready/Busy line signals card status to main CPU.
  - Data valid and strobe lines synchronize DAC and S/H update.
- **Boot/Config**:
  - On power-up, reset line clears registers; card waits for "enable" or "config" from main CPU.
  - Self-test sequence: checks RAM, DAC, S/H, and analog outputs.

### 30.154.2 Firmware Structure: Main Loop, Interrupts, and Modulation Handling

- **Main Loop**:
  - Await command from CPU (e.g., update CV, set param, run test).
  - On data received, update modulation sources, calculate outputs, set DAC/mux.
- **Interrupts**:
  - Timer ISR for envelope/LFO update and S/H refresh.
  - Bus/command ISR for receiving CPU data and status queries.
- **Modulation Handling**:
  - Reads modulation table, calculates per-destination value, applies correction, updates analog outputs.

### 30.154.3 Communication Protocol: Bus, Latches, and Status Reporting

- **Bus**:
  - Shared or daisy-chained parallel bus; CPU addresses each card in turn.
  - Write: Address, command, data; Read: Status, result, error code.
- **Latches**:
  - Data latched on strobe; after holding, output enable line triggers update.
- **Status Reporting**:
  - Each card can signal "OK", "BUSY", or "FAULT" to CPU; error latch holds until cleared.

### 30.154.4 Fault Detection, Watchdog, and Recovery

- **Faults**:
  - Analog out of range, S/H droop, DAC error, bus timeout.
- **Watchdog**:
  - Timer resets card if main loop stalls or no command seen in N ms.
- **Recovery**:
  - Card tries self-reset, signals FAULT if not recoverable.

---

## 30.155 Real-Time Modulation: Polyphonic Matrix Evaluation and Hardware Update

### 30.155.1 Modulation Matrix per Voice: Data Flow and Scheduling

- **Per-Voice Matrix**:
  - Each voice has independent 40-route matrix; sources and destinations unique per voice.
- **Scheduling**:
  - Matrix calculated every timer tick (typically 1ms).
  - Priority: pitch, cutoff, resonance, VCA first; secondary mod (pan, PWM) next.

### 30.155.2 Envelope, LFO, Velocity, and Macro Sources: Digital-to-Analog Translation

- **Envelope/LFO**:
  - EG: DADSR, digital state machine with analog output via DAC or PWM filter.
  - LFO: Triangle/S&H, phase accumulator, can sync to key or clock.
- **Velocity/AT/Macro**:
  - Sampled at event, held for note duration, mapped to matrix sources.
  - Macro values (panel, MIDI) updated in real time; routed to matrix.

### 30.155.3 DAC and S/H Update Cycle: Priority, Jitter, and Performance

- **DAC Update**:
  - Parallel or serial DAC (8 or 12 bits), fast settling, low glitch.
  - Mux steers output to correct S/H cap; hold time > update interval.
- **Cycle**:
  - Update all critical CVs in <1ms to ensure zero-latency mod.
  - Jitter: <25µs between voices for perfect timing in unison.

### 30.155.4 Synchronization Across Voices: Phase, Timing, and Spread

- **LFO Sync**:
  - Global or per-voice; CPU can reset all LFOs on key event.
- **Phase Alignment**:
  - For unison, voices may lock EG/LFO phase for ensemble effect.
- **Spread**:
  - “Analog feel” parameter adds small offset to each voice for organic sound.

---

## 30.156 Patch Morphing, Macro Assignment, and Live Performance Algorithms

### 30.156.1 Morphing Two Patches: State Interpolation and Real-Time Calculation

- **Morphing**:
  - Interpolates between two patches (A/B) per parameter, in real time.
  - User morph value (0..127) determines mix; all params, routes, and matrix depths interpolated.
  - Smooth morphing for live performance and macro sweeps.

### 30.156.2 Macro System: Mapping, Live Control, and UI Feedback

- **Macro Mapping**:
  - Panel encoder, mod wheel, MIDI CC mapped to any matrix source.
  - Each macro can control multiple destinations; depth and curve per mapping.
- **Live Control**:
  - Macro value updated every tick, immediate effect on matrix and output.
- **UI Feedback**:
  - LCD/LED display macro value, affected params, and routing.

### 30.156.3 Panel and MIDI Mapping: Dynamic Assignment and Automation

- **Panel**:
  - Macros can be reassigned in patch or live; panel UI shows current mappings.
- **MIDI**:
  - CCs, AT, or external pedals mapped to macros; editor integration.
- **Automation**:
  - Macro moves can be recorded/replayed as part of patch or sequence.

### 30.156.4 C Code for Morph Engine and Macro Matrix Evaluation

```c
void morph_patch(const m12_patch_t* a, const m12_patch_t* b, float t, m12_patch_t* out) {
    // t: 0.0 = all a, 1.0 = all b
    for (int i = 0; i < sizeof(m12_patch_t); ++i) {
        ((uint8_t*)out)[i] = ((1.0f-t)*((uint8_t*)a)[i] + t*((uint8_t*)b)[i]);
    }
    // Update matrix, correction tables as needed
}
```

---

## 30.157 Example C Code: Voice Firmware, Modulation Engine, and Macros

### 30.157.1 Voice Firmware Main Loop and Interrupts

```c
void main() {
    init_peripherals();
    while (1) {
        if (cmd_ready()) {
            process_cpu_command();
        }
        if (timer_flag) {
            timer_flag = 0;
            update_modulation();
            refresh_dac_mux();
        }
        if (fault_detected()) handle_fault();
    }
}
```

### 30.157.2 Per-Voice Modulation Calculation and DAC Update

```c
void update_modulation() {
    int16_t sources[24], dests[32] = {0};
    read_sources(sources);
    for (int i = 0; i < 40; ++i) {
        int src = matrix[i].src, dst = matrix[i].dst;
        int val = apply_curve(sources[src], matrix[i].curve);
        dests[dst] += val * matrix[i].depth;
    }
    for (int d = 0; d < 32; ++d) {
        set_dac_mux(d, clamp(dests[d]));
    }
}
```

### 30.157.3 Patch Morphing Algorithm and Real-Time Update

```c
void morph_and_update(const m12_patch_t* a, const m12_patch_t* b, float t) {
    m12_patch_t out;
    morph_patch(a, b, t, &out);
    load_patch_to_voice(&out);
    update_modulation();
}
```

### 30.157.4 Macro Handler, Mapping Table, and Event Dispatch

```c
typedef struct {
    uint8_t src;
    uint8_t dst;
    int8_t depth;
    uint8_t curve;
} macro_map_t;

macro_map_t macro_table[8];

void apply_macros(int macro_val[8], int16_t* sources) {
    for (int i = 0; i < 8; ++i) {
        macro_map_t* m = &macro_table[i];
        sources[m->src] += macro_val[i] * m->depth;
    }
}
```

---

## 30.158 Appendices: Voice Card Firmware Map, Bus Protocol, and Debugging Tools

### 30.158.1 Voice Card Firmware Map

| Address | Function       | Description                 |
|---------|---------------|-----------------------------|
| 0x0000  | Bootloader    | Init, self-test, handshake  |
| 0x0100  | Main Loop     | Command, update, status     |
| 0x0200  | Matrix Engine | Modulation eval             |
| 0x0300  | DAC/Mux       | Output update, S/H refresh  |
| 0x0400  | Fault Handler | Watchdog, error, recovery   |

### 30.158.2 Bus Protocol Reference

| Signal   | Direction | Function        |
|----------|-----------|-----------------|
| ADDR     | CPU→Card  | Address         |
| DATA     | CPU↔Card  | Data            |
| STROBE   | CPU→Card  | Data valid      |
| READY    | Card→CPU  | Ready/busy      |
| FAULT    | Card→CPU  | Fault/error     |

### 30.158.3 Debugging Tools

- **Firmware Console**: UART output of status, errors, and modulation metrics.
- **Panel Diagnostics**: LEDs for status, faults, and handshake feedback.
- **Test Points**: S/H, DAC out, gate, CV, and analog outputs accessible for scope/DMM.
- **Logic Analyzer**: Capture bus protocol for timing/debug.

---

**End of Part 15: Matrix-12 Voice Firmware, Real-Time Modulation, and Patch Morphing – Complete Deep Dive.**

*This part completes the full digital/analog voice engine, modulation system, and live morphing/macros for the most detailed recreation and analysis of the Matrix-12.*

---