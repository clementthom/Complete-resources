# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 4: Full Voice Card Schematic Analysis, Analog/Digital Timing, and In-Depth Modular Emulation

---

## Table of Contents

- 30.81 Full Voice Card Schematic: Block-by-Block Analysis
  - 30.81.1 VCO Section: CEM3340, Exponential Converter, Glide Circuit
  - 30.81.2 VCO Mixer, Waveshaping, and Cross-Modulation
  - 30.81.3 VCF Section: CEM3372, CV Sums, Resonance Behavior, Nonlinearities
  - 30.81.4 VCA and Pan: CEM3360 Topology, VC Gain, Pan Law, Summing
  - 30.81.5 Envelope and LFO Generators: Analog Core, Digital Control, Polyphonic Sync
  - 30.81.6 Control Voltage Distribution: Matrix Updates, Slew, Sample/Hold
- 30.82 Digital/Analog Interface: DACs, Multiplexers, Sample-and-Hold, and CV Distribution
  - 30.82.1 DAC Output Buffering, Settling, and Glitch Suppression
  - 30.82.2 Multiplexer/Switch Matrix: Logic, Timing, and Bus Contention
  - 30.82.3 Sample-and-Hold Array: Droop Rate, Isolation, and Slew Rate
  - 30.82.4 Analog Grounding, Star Topology, and Crosstalk Avoidance
- 30.83 Modular Emulation: Detailed Mapping of Modular Functions to Matrix-12 Architecture
  - 30.83.1 Patching Examples: Ring Mod, Audio Rate FM, Serial/Parallel Filters
  - 30.83.2 Limitations and Workarounds: What a Matrix-12 Can and Cannot Do vs. True Modular
  - 30.83.3 Polyphonic Modular: Unique Features, Voice-Level Independence
- 30.84 Advanced Service, Repair, and Upgrade Scenarios
  - 30.84.1 Voice Card Swap, Burn-In, and Matching
  - 30.84.2 Upgrading for Modern Reliability: Power Supply, DACs, and Panel
  - 30.84.3 Signal Integrity Checks: Oscilloscope, Audio Analyzer, and Logic Probes
- 30.85 Example C Code: Voice-Level Parameter Management, Real-Time CV Update, Diagnostic Hooks
  - 30.85.1 Voice Parameter Table Management and Real-Time Sync
  - 30.85.2 Polyphonic Modulation Matrix Evaluation
  - 30.85.3 Analog Test Routines: Output Level, Frequency, and Filter Response
  - 30.85.4 Modular Patch Template Storage and Recall
- 30.86 Circuit-Level Reference Tables, Data Maps, and IC Pinouts

---

## 30.81 Full Voice Card Schematic: Block-by-Block Analysis

### 30.81.1 VCO Section: CEM3340, Exponential Converter, Glide Circuit

- **CEM3340 Core**:  
  - Exponential CV input (pin 15) sums pitch, glide, bend, LFO, env, and mod matrix CVs.
  - Reference current set by resistor to pin 14; temperature compensation via matched NTC or network.
  - **Glide circuit**: CV from DAC passes through OTA-based integrator (CA3080/LM13700), slew rate set by timing cap and resistor (trimmable).
  - **Sync**: Hard/soft sync via logic from CPU; resets integrator at specific phase (pin 9).
  - **FM/PM**: Linear FM input (pin 10) can accept audio-rate mod from other VCO or matrix CV.

#### 30.81.1.1 Schematic Fragment

```
[Sum Node]--[OTA Glide]--[CEM3340 Pin 15]
  |            |
[Pitch CV]  [Rate Pot/CPU]
  |            |
[Mod CVs]   [Glide CV]
```

- **Temperature Compensation**:  
  - Matched transistor pair in expo converter; often on-chip or with external NTC for scale stability.

### 30.81.2 VCO Mixer, Waveshaping, and Cross-Modulation

- **Mixer**:  
  - Summing op amp for saw, triangle, PWM outs from CEM3340.
  - Each wave can be enabled/disabled via analog switch (4066 or similar), under CPU control.
- **Pulse Width Modulation**:  
  - Pulse input (pin 4) modulated by matrix CV, routed through dedicated S/H and buffer.
- **Cross-Modulation**:  
  - VCO2 out routed to VCO1 FM input (or vice versa) via switchable path, depth set by mod matrix.
  - Audio path isolated via high-impedance buffer; CPU enables via analog switch.

#### 30.81.2.1 Mixer Schematic Fragment

```
[VCO1 Saw]--+
[VCO1 Tri]--+--[Analog Switches]--[Sum Amp]--[VCF In]
[VCO1 PWM]--+
```

- **Audio Rate Modulation**:  
  - Achievable for some destinations, limited by CV update speed; audio path modulation via analog switch for true FM.

### 30.81.3 VCF Section: CEM3372, CV Sums, Resonance Behavior, Nonlinearities

- **CEM3372**:  
  - Pinout: CV cutoff, resonance, input, output, env mod.
  - **Cutoff CV**: Sum of keyboard tracking, envelope, LFO, mod matrix, panel offset, and calibration offset.
  - **Resonance**: Modulated via separate CV; maximum Q can self-oscillate.
  - **Nonlinearities**: Input buffer can be overdriven (for distortion), resonance path can 'ring' at high Q.

#### 30.81.3.1 VCF Schematic Fragment

```
[Sum Node]--[Buffer]--[CEM3372 Cutoff CV]
[Res CV]---[Buffer]--[CEM3372 Res CV]
[VCF Input]--------->[CEM3372 In]
[VCF Output]<-------[CEM3372 Out]
```

- **Filter Modes**:  
  - Primarily 4-pole lowpass; some units allow jumper-based alternate modes (HP, BP via unused pins).

### 30.81.4 VCA and Pan: CEM3360 Topology, VC Gain, Pan Law, Summing

- **CEM3360 VCA**:  
  - Two OTAs per chip, one for amplitude, one for pan (L/R).
  - VC Gain input receives sum of envelope, velocity, aftertouch, and mod matrix CVs.
- **Pan Control**:  
  - Pan CV from matrix, summed and applied to pan OTA; law is usually linear.
- **Summing**:  
  - Outputs from all voice cards summed at op-amp bus, routed to main out, sub out, or phones.

#### 30.81.4.1 VCA/Pan Schematic

```
[VCF Out]--[Amp OTA]--[Pan OTA]--[L/R Out]
[Gain CV]            [Pan CV]
```

### 30.81.5 Envelope and LFO Generators: Analog Core, Digital Control, Polyphonic Sync

- **Envelope Gen**:  
  - DADSR: Digital control of rate/level, analog core (cap charging via current mirror).
  - Attack, decay, release set by CPU via matrix CV to OTA controlling cap charge/discharge.
  - Sustain/level direct CV; curves can be linear or exponential.
- **LFO**:  
  - Triangle/square, analog core, speed and depth set by CV from DAC/matrix.
  - Sync: CPU can reset LFOs for polyphonic LFO phase coherence.
- **Polyphonic**:  
  - Each voice has independent EG/LFO, all parameters digitally controllable.

#### 30.81.5.1 Envelope/LFO Schematic

```
[CPU/Matrix]--[DAC/S&H]--[OTA]--[Envelope Cap]
                                |
                        [Analog Switch] (reset)
```

### 30.81.6 Control Voltage Distribution: Matrix Updates, Slew, Sample/Hold

- **CV Distribution**:  
  - CPU serially updates all destinations: selects voice, destination, writes CV via DAC/mux.
  - Each CV line buffered and held by S&H circuit (polypropylene cap, low-leak op-amp buffer).
- **Slew**:  
  - Some destinations (e.g., filter cutoff) have analog slew circuits for smooth parameter changes.
- **Timing**:  
  - Full update cycle <1ms for 120+ CVs (12 voices × 10 params), slew rate and S&H droop <1% per cycle.

---

## 30.82 Digital/Analog Interface: DACs, Multiplexers, Sample-and-Hold, and CV Distribution

### 30.82.1 DAC Output Buffering, Settling, and Glitch Suppression

- **DAC**: MC1408/DAC08, 8/12-bit resolution.
- **Output Buffer**: Precision op-amp (TL071/NE5534), unity gain, low offset.
- **Glitch Suppression**:  
  - RC filter at DAC output, analog switch disconnects during mux switching to avoid glitch bleed.
  - Settling time <10μs; CPU waits for buffer ready before latching next value.

### 30.82.2 Multiplexer/Switch Matrix: Logic, Timing, and Bus Contention

- **Multiplexer**: 4051 (8:1), 4067 (16:1); digital select lines from CPU.
- **Timing**:  
  - CPU sets mux address, enables switch, writes DAC, disables, steps to next.
  - Careful timing avoids bus contention or 'ghosting' between CV destinations.

### 30.82.3 Sample-and-Hold Array: Droop Rate, Isolation, and Slew Rate

- **S&H**:  
  - Poly cap (100nF–1uF), low bias op-amp buffer, isolation resistor.
  - Droop rate <1mV/sec, enough to hold CV between updates.
  - Slew rate: For fast mod, cap can be reduced or buffer sped up; trade-off noise vs. response.

### 30.82.4 Analog Grounding, Star Topology, and Crosstalk Avoidance

- **Star Ground**:  
  - All analog grounds return to single point at PSU; digital and analog grounds separated and joined at star only.
- **Shielding**:  
  - Audio and CV lines shielded, chassis grounded; bypass caps at each IC and CV input.
- **Crosstalk**:  
  - Careful layout, short traces, and ground plane minimize mod bleed and hum.

---

## 30.83 Modular Emulation: Detailed Mapping of Modular Functions to Matrix-12 Architecture

### 30.83.1 Patching Examples: Ring Mod, Audio Rate FM, Serial/Parallel Filters

- **Ring Mod**:  
  - VCO2 routed to VCO1 FM via matrix, both at audio rates.
  - Output: Metallic, bell-like overtones, polyphonic per voice.
- **Audio Rate FM**:  
  - Set matrix route: VCO2 as FM source for VCO1 or VCF cutoff.
  - Depth/curve set per patch; max rate limited by mod bus update (~1kHz), but direct audio path available for some routings.
- **Serial/Parallel Filters**:  
  - Within one voice: VCF output can be routed back to VCO FM or via pan VCA for serial/parallel effects.
  - Not true patch-cable modular, but matrix allows many routing permutations.

### 30.83.2 Limitations and Workarounds: What a Matrix-12 Can and Cannot Do vs. True Modular

- **Limitations**:  
  - No true cross-voice audio patching (all patching is per voice).
  - Some routings limited by CV update rate (not true audio-rate for all destinations).
  - No custom filter topologies (VCF is always 4-pole LP unless hardware-modded).
- **Workarounds**:  
  - Use external modular integration (CV/Gate I/O).
  - Stack similar mod sources for richer effects (ENV+LFO+wheel to same dest).
  - Use pan and output bus creatively for "serial" modulations.

### 30.83.3 Polyphonic Modular: Unique Features, Voice-Level Independence

- **Individual Voice Modulation**:  
  - Each voice can have completely different routings, sources, and depths (per patch).
  - Split/layer: Different sound engines on same keyboard, each a full modular patch.
- **Polyphony**:  
  - 12 completely independent analog synths in one instrument, all patchable as a modular.

---

## 30.84 Advanced Service, Repair, and Upgrade Scenarios

### 30.84.1 Voice Card Swap, Burn-In, and Matching

- **Swap**:  
  - Power down, remove card, replace with tested spare; test points and silkscreen make identification easy.
- **Burn-In**:  
  - New/repaired cards run through auto-cal, full range sweep, and soak test for 24h.
- **Matching**:  
  - For best sound, VCO/VCF ICs can be hand-matched for offset, scale, and leakage.

### 30.84.2 Upgrading for Modern Reliability: Power Supply, DACs, and Panel

- **Power Supply**:  
  - Replace old linear supply with modern low-noise switcher, or recap original for reliability.
- **DACs**:  
  - Upgrade to 12/16-bit for smoother CVs (requires firmware patch).
- **Panel**:  
  - Modern OLED/LCD drop-in for original display; replace failing encoders/keys with modern parts.

### 30.84.3 Signal Integrity Checks: Oscilloscope, Audio Analyzer, and Logic Probes

- **Oscilloscope**:  
  - Verify VCO waveform, envelope shape, VCF sweep, VCA/Pan gain law.
- **Audio Analyzer**:  
  - Test THD, noise floor, crosstalk; compare to factory spec.
- **Logic Probe**:  
  - Check DAC, mux, and CPU lines for timing glitches or stuck bits.

---

## 30.85 Example C Code: Voice-Level Parameter Management, Real-Time CV Update, Diagnostic Hooks

### 30.85.1 Voice Parameter Table Management and Real-Time Sync

```c
typedef struct {
    uint16_t vco_pitch, vco_pwm, vco2_pitch, vcf_cutoff, vcf_res, vca_amp, pan;
    uint16_t env1_attack, env1_decay, env1_sustain, env1_release;
    // ... etc.
} voice_params_t;

voice_params_t voice_table[12];

void update_voice_params(int v, const patch_t* p) {
    voice_table[v].vco_pitch = calc_vco_pitch(p, v);
    voice_table[v].vcf_cutoff = calc_vcf_cutoff(p, v);
    // ... update all params
}
```

### 30.85.2 Polyphonic Modulation Matrix Evaluation

```c
void eval_mod_matrix(int v) {
    for (int dest = 0; dest < NUM_DEST; ++dest) {
        int sum = 0;
        for (int r = 0; r < p->matrix_count; ++r) {
            if (p->matrix[r].dest == dest) {
                int src = get_mod_source(p->matrix[r].source, v);
                sum += src * p->matrix[r].depth;
            }
        }
        set_dac_mux(v, dest, clamp(sum));
    }
}
```

### 30.85.3 Analog Test Routines: Output Level, Frequency, and Filter Response

```c
void voice_test_pattern(int v) {
    set_vco_wave(v, SAW);
    set_vco_pitch_cv(v, TEST_CV);
    set_vcf_cutoff_cv(v, TEST_CUTOFF);
    set_vca_cv(v, UNITY);
    // Output should be 440Hz saw at unity gain
}

void measure_voice(int v) {
    float freq = measure_frequency(v);
    float level = measure_output_level(v);
    // Display or log result for diagnostics
}
```

### 30.85.4 Modular Patch Template Storage and Recall

```c
typedef struct {
    char name[16];
    matrix_route_t routes[32];
    uint8_t osc_mode, filter_mode, lfo_mode;
    // ...
} modular_patch_t;

void save_modular_patch(int slot, modular_patch_t* mp) {
    memcpy(mod_patch_ram + slot * sizeof(modular_patch_t), mp, sizeof(modular_patch_t));
}

void load_modular_patch(int slot, modular_patch_t* mp) {
    memcpy(mp, mod_patch_ram + slot * sizeof(modular_patch_t), sizeof(modular_patch_t));
}
```

---

## 30.86 Circuit-Level Reference Tables, Data Maps, and IC Pinouts

### 30.86.1 CEM3340 (VCO) Key Pins

| Pin | Function         | Notes                      |
|-----|------------------|----------------------------|
| 15  | Expo CV In       | Main pitch control         |
| 14  | Ref Resistor     | Sets current, scaling      |
| 4   | Pulse Out        | Pulse width mod            |
| 3   | Tri Out          | Triangle                   |
| 5   | Saw Out          | Sawtooth                   |
| 9   | Sync In          | Hard/soft sync             |

### 30.86.2 CEM3372 (VCF) Key Pins

| Pin | Function           | Notes                      |
|-----|--------------------|----------------------------|
| 1   | Audio In           | Input Buffer               |
| 2   | Cutoff CV          | Filter freq control        |
| 3   | Res CV             | Resonance control          |
| 9   | Audio Out          | Main output                |

### 30.86.3 CEM3360 (VCA) Key Pins

| Pin | Function         | Notes                      |
|-----|------------------|----------------------------|
| 1   | In A             | Amp input                  |
| 2   | Out A            | Amp output                 |
| 6   | VC Gain A        | Gain CV                    |
| 8   | In B             | Pan input                  |
| 9   | Out B            | Pan output                 |
| 11  | VC Gain B        | Pan CV                     |

---

**End of Part 4: Matrix-12 Voice Card Schematic, Timing, Modular Emulation, and Service Procedures – Complete Deep Dive.**

*For even greater detail, refer to the full service manual, calibration charts, and source code listings in the project appendix. All hardware, software, and modular behaviors are now documented for accurate reproduction and advanced engineering.*

---