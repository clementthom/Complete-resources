# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 12: Advanced Signal Path, Modulation Interactions, and Voice Card Reverse-Engineering

---

## Table of Contents

- 30.134 Full Audio Signal Path: From Key Event to Output Jack
  - 30.134.1 Digital Event Initiation: Keyboard, MIDI, and Panel
  - 30.134.2 Voice Assignment, Trigger Routing, and Gate Logic
  - 30.134.3 CV Generation, DAC/Mux, and Analog Path Entry
- 30.135 Analog Signal Flow: In-Depth Per-Voice Card Analysis
  - 30.135.1 VCO1 and VCO2: Expo Input, Mixer, Sync, and PWM
  - 30.135.2 VCO Cross-Modulation, Feedback, and True Analog FM
  - 30.135.3 VCF: CEM3372 Topology, Nonlinear Circuit Details, and Q Tweaks
  - 30.135.4 VCA/Pan: OTA Law, Summing, and Output Section
- 30.136 Modulation Interactions: Real-World Signal Summing, Slew, and Crosstalk
  - 30.136.1 Digital Modulation Sources: Envelopes, LFOs, Macros, and External
  - 30.136.2 CV Summing: Analog Buffering, Slew Circuits, and Sample/Hold
  - 30.136.3 Timing, Slew, and Modulation Priority
  - 30.136.4 Crosstalk, Grounding, and Mitigation
- 30.137 Reverse-Engineering Voice Card: Tracing, Schematic Extraction, and Modern Equivalent
  - 30.137.1 Methodology: Visual Inspection, Continuity Testing, and Layer Mapping
  - 30.137.2 Key Functional Blocks and How to Redraw Them
  - 30.137.3 Modern Substitute Parts, Layout, and Adjustments
- 30.138 Case Study: Matrix-12 Modular Emulation Example—Patch Walkthrough
  - 30.138.1 Programming a Complex Patch: Routing Tables, Modulation Trees
  - 30.138.2 Voice Card Signal Path for This Patch: Annotated Diagram
  - 30.138.3 C Code for Patch Setup, Mod Matrix Evaluation, and Real-Time Update
- 30.139 Troubleshooting and Debugging: Real-World Scenarios and Solutions
  - 30.139.1 Voice Dropout, Gate Faults, and Dead Keys
  - 30.139.2 Filter Instability, LFO Bleed, and Envelope Glitches
  - 30.139.3 Diagnosis Workflow and Test Points
- 30.140 Appendices: Full Voice Card Schematic, Bill of Materials, and Measured Data

---

## 30.134 Full Audio Signal Path: From Key Event to Output Jack

### 30.134.1 Digital Event Initiation: Keyboard, MIDI, and Panel

- **Keyboard Matrix Scan**:  
  - CPU scans key matrix at ~100Hz, debounces, and detects velocity via dual-contact mechanism.
  - Key press event triggers note-on, routed to voice assigner.
- **MIDI Input**:  
  - UART interrupt parses MIDI bytes; note-on/off, CC, AT, program change, and sysex all mapped to internal event queue.
  - MIDI events routed identical to local keyboard, with OMNI/poly mode filtering.
- **Panel Controls**:  
  - Panel buttons and encoders modify patch, matrix, and performance parameters, posted as events to main loop.

### 30.134.2 Voice Assignment, Trigger Routing, and Gate Logic

- **Voice Assignment**:
  - Voice allocator chooses free, least recently used, or reserved voice per split/layer/zone.
  - Each voice maintains state: idle, assigned (note/pitch/velocity/channel), release, masked.
- **Trigger Routing**:
  - On note-on, voice's gate is asserted; envelope generator is reset/triggered.
  - Split/layer logic ensures correct patch and matrix for the key zone.
  - Gate logic: TTL line to voice card, sets envelope start and VCO sync.
- **Releases/Stealing**:
  - Released notes enter decay/release phase; voice is freed when envelope completes.
  - If all voices are busy, oldest or quietest is stolen.

### 30.134.3 CV Generation, DAC/Mux, and Analog Path Entry

- **CV Calculation**:
  - For each voice and each destination (VCO pitch, pulse width, filter cutoff, res, etc.):  
    - CPU sums all mod matrix sources × depth, applies curves and correction tables.
  - Each destination value clamped to DAC range.
- **DAC/Mux**:
  - Serial update: CPU sets mux to destination, writes value to DAC, waits for settle, repeats for all params (typically 10–12 per voice).
- **Analog Entry**:
  - CV lines buffered, sent to S/H circuit on voice card.
  - Glide (portamento) implemented via OTA-based integrator before expo converter.

---

## 30.135 Analog Signal Flow: In-Depth Per-Voice Card Analysis

### 30.135.1 VCO1 and VCO2: Expo Input, Mixer, Sync, and PWM

- **Expo Input**:
  - CV sum from DAC/matrix enters at expo converter input (pin 15 on CEM3340).
  - Glide circuit in series for smooth pitch transitions.
- **Mixer**:
  - Saw, triangle, and pulse outputs from CEM3340 routed through analog switches (4066 or similar) to op-amp summing mixer.
  - Each waveform can be enabled/disabled in patch.
- **Sync**:
  - Hard sync implemented via digital transistor or analog switch pulling sync pin low, under CPU control.
- **PWM**:
  - Pulse width CV from DAC/matrix, modulated by LFO/env/AT/velocity as routed in matrix.
  - PWM S/H circuit holds value between DAC updates.

### 30.135.2 VCO Cross-Modulation, Feedback, and True Analog FM

- **Cross-Modulation**:
  - VCO2 output can be routed to VCO1 linear FM input via analog switch and op-amp buffer.
  - Level set by matrix route depth or dedicated hardware trimmer.
- **Feedback**:
  - Output of VCF or VCA can be fed back to VCO or filter via analog switch, for self-oscillation and chaotic modulation.
- **FM**:
  - Linear FM (audio-rate) possible for VCO1/2 via matrix, best for metallic or bell-like sounds.
  - Nonlinear FM via expo input, less stable but more "analog".

### 30.135.3 VCF: CEM3372 Topology, Nonlinear Circuit Details, and Q Tweaks

- **Input Buffer**:
  - Summed VCO signal and external input (if present) routed to VCF input buffer.
- **Cutoff/Resonance**:
  - Cutoff CV is sum of key track, env, LFO, velocity, macro, and panel offset; enters VCF at dedicated pin.
  - Resonance modulated via separate CV; can reach self-oscillation at max.
- **Nonlinearities**:
  - At high input, buffer saturates, adding harmonic distortion.
  - At high resonance, filter "rings" and can clip.
- **Q Tweaks**:
  - PCB traces allow for mod to Q response; factory may have resistor/cap variants for voice matching.

### 30.135.4 VCA/Pan: OTA Law, Summing, and Output Section

- **VCA**:
  - OTA-based, linear gain control over ~60dB.
  - Envelope, velocity, and macro modulate final output level.
- **Pan**:
  - Pan VCA (CEM3360 B) receives pan CV; outputs to stereo L/R summing bus.
- **Summing**:
  - All voices sum to main output bus via op-amp mixer; output buffer drives line out.

---

## 30.136 Modulation Interactions: Real-World Signal Summing, Slew, and Crosstalk

### 30.136.1 Digital Modulation Sources: Envelopes, LFOs, Macros, and External

- **Envelope Generators (EGs)**:
  - DADSR, digitally set rates and levels, analog cap/OTA core.
  - Each EG per voice, values sampled at each matrix update.
- **LFOs**:
  - Triangle/square, analog ramp core, speed/depth set by matrix.
  - LFO phase can be retriggered by key event for sync.
- **Macros**:
  - Panel or MIDI controller mapped to any matrix source (e.g., mod wheel to cutoff and pan).
- **External**:
  - Pedals, CV/Gate inputs, mapped as matrix sources.

### 30.136.2 CV Summing: Analog Buffering, Slew Circuits, and Sample/Hold

- **Buffering**:
  - CV lines buffered by op-amp (TL071/NE5534) before entering S/H.
  - S/H cap (polypropylene, low-leak) holds value for between updates.
- **Slew**:
  - Glide/portamento for pitch, or analog slew for filter cutoff, implemented via OTA integrator.
- **Timing**:
  - S/H droop <1mV/sec; update every ~1ms, so droop negligible.

### 30.136.3 Timing, Slew, and Modulation Priority

- **Timing**:
  - Matrix update must complete within 1ms cycle for zero-latency mod.
- **Slew**:
  - Slew rate for portamento, filter sweep, or pan mod determined by OTA cap/resistor, user programmable in patch.
- **Priority**:
  - Fastest mod sources (envelope, velocity) updated every tick; slower sources (panel, macro) can be rate-limited.

### 30.136.4 Crosstalk, Grounding, and Mitigation

- **Analog Ground**:
  - Separate from digital, star topology.
- **Crosstalk**:
  - Guard traces and short runs for CV, shielded audio lines.
- **Mitigation**:
  - Careful PCB layout, separate power planes, decoupling at every IC.

---

## 30.137 Reverse-Engineering Voice Card: Tracing, Schematic Extraction, and Modern Equivalent

### 30.137.1 Methodology: Visual Inspection, Continuity Testing, and Layer Mapping

- **Visual Inspection**:
  - High-res photos, mark all ICs, passives, connectors, and test points.
- **Continuity Testing**:
  - Use DMM to trace critical nets (CV, audio, power, ground).
- **Layer Mapping**:
  - If multi-layer, use backlight or X-ray to map internal traces.

### 30.137.2 Key Functional Blocks and How to Redraw Them

- **Block Diagram**:
  - VCO1/2 block: expo, core, wave out, sync.
  - VCF block: input, cutoff, res, output.
  - VCA/pan block: gain, pan, output bus.
  - S/H and buffer block: CV entry for each controlled parameter.
- **Schematic Extraction**:
  - Redraw each block, reference original pin numbers, mark all test points.
  - Annotate all trimmers (scale, offset, Q, pan) and calibration points.

### 30.137.3 Modern Substitute Parts, Layout, and Adjustments

- **CEM Replacements**:
  - Alfa AS3340/3372/3360 for CEM chips.
- **Op-Amps**:
  - TL07x/NE5532 for low-noise, low-offset.
- **Switches**:
  - 74HC4066 or modern analog switch for waveform select.
- **PCB Layout**:
  - Modern 4-layer board, dedicated analog/digital planes, SMD passives for compact design.

---

## 30.138 Case Study: Matrix-12 Modular Emulation Example—Patch Walkthrough

### 30.138.1 Programming a Complex Patch: Routing Tables, Modulation Trees

- **Patch Example**:  
  - "Evolving Pad with Random Pan and Filter Movement"
  - Matrix routes:
    - LFO1 → VCF cutoff (Depth +32, Curve: S&H)
    - ENV3 → VCA (Depth +64, Curve: Linear)
    - Mod Wheel → Pan (Depth +63, Curve: Linear)
    - Aftertouch → Resonance (Depth +48)
    - Velocity → ENV3 Attack (Depth -32)
  - LFO1 set to S&H, sync on key press.
  - Split mode: Lower half uses this patch, upper half uses "Bright Brass".

### 30.138.2 Voice Card Signal Path for This Patch: Annotated Diagram

```
[Key Event]    [LFO1 S&H]   [ENV3]           [Mod Wheel]
    |             |           |                  |
    |             V           |                  |
    |----------->[Matrix]-----|------------------|----+
    |               |         |                  |    |
    V               |         +-->[VCA]----------+    |
[Voice Assign]      |                              [Pan VCA]--[Summing Amp]--[Main Out]
    |               |                                   ^
    |               +-->[VCF]----[Audio Path]-----------+
    |                    ^         ^
    |                    |         +-[Aftertouch, Velocity]
    +-> [Split Logic]----+
```

### 30.138.3 C Code for Patch Setup, Mod Matrix Evaluation, and Real-Time Update

```c
void setup_patch(m12_patch_t* patch) {
    // Set up matrix routes for this patch
    add_matrix_route(patch, SRC_LFO1, DST_VCF_CUTOFF, 32, CURVE_SNH);
    add_matrix_route(patch, SRC_ENV3, DST_VCA, 64, CURVE_LINEAR);
    add_matrix_route(patch, SRC_MODWHEEL, DST_PAN, 63, CURVE_LINEAR);
    add_matrix_route(patch, SRC_AFTERTOUCH, DST_RESONANCE, 48, CURVE_LINEAR);
    add_matrix_route(patch, SRC_VELOCITY, DST_ENV3_ATTACK, -32, CURVE_LINEAR);
    // Set LFO1 to S&H, sync to key
    patch->lfo[0][0] = LFO_SNH;
    patch->lfo[0][1] = LFO_SYNC_KEY;
    // Set split/layer
    patch->split[0] = 0; // lower zone
    patch->layer[0] = PATCH_EVOLVING_PAD;
    patch->split[1] = 1; // upper zone
    patch->layer[1] = PATCH_BRIGHT_BRASS;
}

void real_time_update(int v) {
    // Called every matrix update tick
    eval_matrix_voice(v); // as in earlier examples
    dispatch_voice_cv(v);
}
```

---

## 30.139 Troubleshooting and Debugging: Real-World Scenarios and Solutions

### 30.139.1 Voice Dropout, Gate Faults, and Dead Keys

- **Symptoms**:  
  - No sound from a voice, stuck note, or dead key.
- **Diagnosis**:
  - Check Voice Status Table in service menu: masked? failed?
  - Probe gate line at CPU, cable, and voice card.
  - Check for failed S&H cap or buffer op-amp.

### 30.139.2 Filter Instability, LFO Bleed, and Envelope Glitches

- **Symptoms**:  
  - Filter “whistles”, LFO modulates pitch when routed to filter, envelope clicks.
- **Diagnosis**:
  - Sweep filter CV, listen for jumps or instability; check for leaky cap or bad trimmer.
  - LFO bleed: check for crosstalk between LFO and CV lines.
  - Envelope: check for bad solder at envelope cap, or broken OTA.

### 30.139.3 Diagnosis Workflow and Test Points

- **Workflow**:
  - 1. Run service diagnostics; check error logs.
  - 2. Probe test points for VCO, VCF, VCA, and CVs.
  - 3. Replace or swap voice card, retest.
  - 4. If persistent, check panel and CPU for logic faults.

---

## 30.140 Appendices: Full Voice Card Schematic, Bill of Materials, and Measured Data

### 30.140.1 Full Voice Card Schematic

```
[See attached PDF or vector file for redrawn schematic]
- Marked: VCO1/2, Expo, Glide, Mixer, VCF, VCA, Pan, S/H, Buffers, Power, Test Points, Trimmers
- Annotated with IC part numbers, pinouts, signal flow, and calibration points.
```

### 30.140.2 Bill of Materials (BOM)

| Ref | Qty | Value/Type   | Description                 | Notes         |
|-----|-----|--------------|-----------------------------|---------------|
| U1  | 1   | CEM3340      | VCO IC                      | Alfa AS3340 OK|
| U2  | 1   | CEM3372      | VCF IC                      | Alfa AS3372 OK|
| U3  | 1   | CEM3360      | VCA IC                      | Alfa AS3360 OK|
| U4  | 4   | TL071        | Op-amp                      | Audio/CV buf  |
| U5  | 2   | 74HC4066     | Analog switch               | Wave select   |
| Cx  | 8   | 100nF        | Poly cap                    | S/H, bypass   |
| Rx  | 20  | 10k–100k     | Metal film resistor         | All CV/audio  |
| VRx | 4   | 10k          | Trimmer pot                 | Cal points    |
| ... | ... | ...          | ...                         | ...           |

### 30.140.3 Measured Data (Typical)

| Test Point  | Nominal Value | Tolerance | Note           |
|-------------|---------------|-----------|----------------|
| VCO Out     | 440Hz         | ±2c       | A4, after cal  |
| VCF Out     | 1kHz - 8kHz   | ±3c/oct   | Sweep, cal OK  |
| VCA Out     | 0dB           | ±0.1dB    | Unity gain     |
| Pan Ctr     | ±0.5dB        |           | Left/Right     |
| S/H Droop   | <1mV/sec      |           | All CV         |

---

**End of Part 12: Matrix-12 Signal Path, Modulation, and Voice Card Reverse Engineering – Complete Deep Dive.**

*This part details the end-to-end signal path, modulation system, analog block reverse-engineering, and real-world troubleshooting required for authentic Matrix-12 analysis and re-creation.*

---