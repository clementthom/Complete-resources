# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 17: Matrix-12 Modulation Matrix Internals, Algorithmic Routing, and Custom Mod Sources

---

## Table of Contents

- 30.164 Modulation Matrix: Architecture, Data Structures, and Scheduling
  - 30.164.1 Matrix Concept: Origins and Signal Routing Capabilities
  - 30.164.2 Hardware/Software Hybrid Implementation
  - 30.164.3 Data Structures: Route Table, Source/Dest Enumeration, Curves
  - 30.164.4 Scheduling: Update Cycle, Real-Time Constraints, and Jitter
- 30.165 Algorithmic Routing: Dynamic, Conditional, and Automated Modulation
  - 30.165.1 Conditional Routing: Key Zone, Velocity, and Poly Mode
  - 30.165.2 Dynamic Depths: Macros, Aftertouch, and Real-Time Automation
  - 30.165.3 Algorithmic Sources: Random, S&H, Ramps, and User Functions
  - 30.165.4 Route Chaining, Feedback, and Modulation Trees
- 30.166 Custom Modulation Sources: Expanding Beyond Original Hardware
  - 30.166.1 User-Defined LFOs, Curves, and Macro Shapes
  - 30.166.2 Advanced Randomization: Probability, Chaos, and Per-Step Scripting
  - 30.166.3 External Modulation: CV/Gate Inputs, OSC, MIDI CC, and DAW Integration
  - 30.166.4 High-Rate Modulation: Audio-Rate Updates, Aliasing, and Anti-Aliasing
- 30.167 Example C Code: Mod Matrix Engine, Conditional Routing, and Custom Mod Sources
  - 30.167.1 Modulation Route Evaluation and Data Flow
  - 30.167.2 Conditional/Algorithmic Routing Example
  - 30.167.3 Custom Source Registration and Real-Time Update
  - 30.167.4 Audio-Rate Modulation and Anti-Aliasing Handling
- 30.168 Appendices: Source/Dest Tables, Curves, and Routing Diagrams

---

## 30.164 Modulation Matrix: Architecture, Data Structures, and Scheduling

### 30.164.1 Matrix Concept: Origins and Signal Routing Capabilities

- **Origins**:  
  - The Matrix-12’s modulation matrix was conceived as a “virtual patchbay,” bridging modular flexibility with polyphonic digital control.
  - Every voice contains its own full matrix, allowing for highly independent polyphonic modulation routing.
- **Routing Capabilities**:
  - Up to 40 routes per voice, each mapping a modulation source (LFO, envelope, velocity, macro, pedal, etc.) to a destination (VCO pitch, PWM, filter cutoff/resonance, VCA level, pan, etc.).
  - Depth, curve/shape, and conditional logic per route.

### 30.164.2 Hardware/Software Hybrid Implementation

- **Hardware**:  
  - DAC and analog mux implement the final CVs to the voice cards, but the matrix logic is handled in software (main CPU).
  - Fast update cycle (typ. 1ms for all voices), with critical modulations prioritized.
- **Software**:  
  - Real-time OS tracks source values, evaluates all active routes, sums and clips per-destination CVs.
  - Use of lookup tables for nonlinear curves, envelope shapes, and velocity response.

### 30.164.3 Data Structures: Route Table, Source/Dest Enumeration, Curves

- **Route Table**:
  - Each route: 4 bytes (see Part 10), packed as {source, dest, depth, curve/conditional}.
- **Source Enumeration (example)**:
  | ID | Source         |
  |----|---------------|
  | 0  | None          |
  | 1  | LFO1          |
  | 2  | LFO2          |
  | 3  | LFO3          |
  | 4  | ENV1          |
  | 5  | ENV2          |
  | 6  | ENV3          |
  | 7  | ENV4          |
  | 8  | ENV5          |
  | 9  | Velocity      |
  | 10 | Aftertouch    |
  | 11 | Mod Wheel     |
  | 12 | Macro1        |
  | 13 | Macro2        |
  | ...| ...           |

- **Destination Enumeration (example)**:
  | ID | Destination     |
  |----|-----------------|
  | 0  | None            |
  | 1  | VCO1 Pitch      |
  | 2  | VCO2 Pitch      |
  | 3  | VCO1 PWM        |
  | 4  | VCO2 PWM        |
  | 5  | VCF Cutoff      |
  | 6  | VCF Resonance   |
  | 7  | VCA Level       |
  | 8  | Pan             |
  | ...| ...             |

- **Curves**:
  - Linear, exponential, logarithmic, S&H, quantize, bipolar/unipolar, etc.
  - Curve lookup tables for fast mapping of source value to CV.

### 30.164.4 Scheduling: Update Cycle, Real-Time Constraints, and Jitter

- **Cycle**:
  - For each tick (1ms):  
    1. Update all sources (EGs, LFOs, macros, etc.) for all voices.
    2. For each voice, for each route:
      - Read source, apply curve, multiply by depth.
      - If conditional, evaluate condition (e.g., key zone, velocity).
      - Add to destination accumulator.
    3. Clamp, apply correction, and output to DAC/mux/S&H.
- **Real-Time Constraints**:
  - Must ensure all routes for 12 voices are evaluated in <1ms.
  - Priority scheduling for time-critical destinations (pitch, cutoff).
- **Jitter**:
  - DAC update jitter must be <25us for unison accuracy; CPU load balanced to avoid latency spikes.

---

## 30.165 Algorithmic Routing: Dynamic, Conditional, and Automated Modulation

### 30.165.1 Conditional Routing: Key Zone, Velocity, and Poly Mode

- **Key Zone**:
  - Route only active for certain key ranges (e.g., LFO mod only on upper keys).
- **Velocity/AT**:
  - Route enabled or depth modified based on velocity/aftertouch threshold.
- **Poly Mode**:
  - Route enabled only when in poly, unison, or specific split/layer.
- **Implementation**:
  - Per-route conditional bits and optional comparator value (e.g., key > 60, vel > 80).

### 30.165.2 Dynamic Depths: Macros, Aftertouch, and Real-Time Automation

- **Dynamic Depth**:
  - Route depth modulated by macro, pedal, or any assignable controller.
  - E.g., Macro1 modulates ENV3→VCF depth for morphing effects.
- **Automation**:
  - Depth/curve modulated by automation envelope or DAW/remote control.

### 30.165.3 Algorithmic Sources: Random, S&H, Ramps, and User Functions

- **Random**:
  - Per-voice or global random source, updated per tick or on event (e.g., key press).
- **S&H**:
  - Sample and hold, typically from LFO or noise source.
- **Ramps/Logic**:
  - Up/down ramps, conditional toggles, step sequencer.
- **User Functions**:
  - In extended firmware: user-uploaded modulation scripts or custom curves.

### 30.165.4 Route Chaining, Feedback, and Modulation Trees

- **Chaining**:
  - Destination of one route can be used as source for another (e.g., ENV4 modulates LFO1 depth).
- **Feedback**:
  - Modulation amount or rate controlled by other matrix routes for recursive effects.
- **Trees**:
  - Graph representation of routing for complex modulation cascades.

---

## 30.166 Custom Modulation Sources: Expanding Beyond Original Hardware

### 30.166.1 User-Defined LFOs, Curves, and Macro Shapes

- **Custom LFOs**:
  - User can define waveform (step, drawn, harmonic mix), rate, sync, phase.
- **Curves**:
  - User-definable response curves, e.g., velocity to exponential or custom lookup.
- **Macro Shapes**:
  - Macros can be mapped to curves, e.g., nonlinear ramp, S-curve, or custom automation.

### 30.166.2 Advanced Randomization: Probability, Chaos, and Per-Step Scripting

- **Probability**:
  - Routes can have probabilistic activation, e.g., 50% chance per note.
- **Chaos**:
  - Low-dimensional chaotic generators (e.g., logistic map) for organic mod.
- **Scripting**:
  - Scripting language for modulation logic, e.g., “if velocity > 100, double LFO depth”.

### 30.166.3 External Modulation: CV/Gate Inputs, OSC, MIDI CC, and DAW Integration

- **CV/Gate**:
  - Analog input mapped to any source, quantized or smoothed as needed.
- **OSC/MIDI**:
  - Open Sound Control and MIDI CC routable to matrix.
- **DAW**:
  - VST/AU plugin or web UI sends mod data live to hardware.

### 30.166.4 High-Rate Modulation: Audio-Rate Updates, Aliasing, and Anti-Aliasing

- **Audio-Rate Mod**:
  - Destinations (e.g., VCO pitch) can be modulated at audio rates for FM and AM effects.
- **Aliasing**:
  - High update rates can cause aliasing; anti-aliasing filtering or oversampling needed.
- **Implementation**:
  - Critical destinations updated at 48kHz+; non-critical remain at 1kHz.

---

## 30.167 Example C Code: Mod Matrix Engine, Conditional Routing, and Custom Mod Sources

### 30.167.1 Modulation Route Evaluation and Data Flow

```c
void eval_mod_matrix(voice_t* v) {
    int16_t dest[32] = {0};
    for (int i = 0; i < 40; ++i) {
        mod_route_t* r = &v->matrix[i];
        if (!route_enabled(r, v)) continue;
        int16_t src_val = get_mod_source(r->src, v);
        int16_t cv = apply_curve(src_val, r->curve);
        cv = (cv * r->depth) / 64; // Depth scaling, signed
        dest[r->dst] += cv;
    }
    for (int d = 0; d < 32; ++d) {
        v->cv_out[d] = clamp(dest[d], v->cv_min[d], v->cv_max[d]);
    }
}
```

### 30.167.2 Conditional/Algorithmic Routing Example

```c
bool route_enabled(const mod_route_t* r, const voice_t* v) {
    if (r->cond & COND_KEYZONE) return (v->note >= r->key_min && v->note <= r->key_max);
    if (r->cond & COND_VELOCITY) return (v->velocity >= r->vel_min);
    if (r->cond & COND_SPLIT) return (v->split == r->split_id);
    return true;
}
```

### 30.167.3 Custom Source Registration and Real-Time Update

```c
typedef int16_t (*mod_source_fn)(const voice_t*);

mod_source_fn custom_sources[MAX_CUSTOM_SOURCES];

void register_mod_source(uint8_t id, mod_source_fn fn) {
    if (id < MAX_CUSTOM_SOURCES) custom_sources[id] = fn;
}

int16_t get_mod_source(uint8_t src, const voice_t* v) {
    if (src < NUM_BUILTIN_SOURCES) return builtin_mod_source(src, v);
    else if (src < NUM_BUILTIN_SOURCES + MAX_CUSTOM_SOURCES)
        return custom_sources[src - NUM_BUILTIN_SOURCES](v);
    else return 0;
}
```

### 30.167.4 Audio-Rate Modulation and Anti-Aliasing Handling

```c
void audio_rate_mod_update(voice_t* v) {
    // Called at audio rate (e.g., 48kHz)
    int16_t mod = get_mod_source(SRC_AUDIO_LFO, v);
    // Apply simple FIR filter for anti-aliasing
    static int16_t fir_buf[4] = {0};
    fir_buf[0] = fir_buf[1]; fir_buf[1] = fir_buf[2]; fir_buf[2] = fir_buf[3]; fir_buf[3] = mod;
    int16_t filtered = (fir_buf[0] + 2*fir_buf[1] + 2*fir_buf[2] + fir_buf[3]) / 6;
    v->cv_out[VCO_PITCH] += filtered;
}
```

---

## 30.168 Appendices: Source/Dest Tables, Curves, and Routing Diagrams

### 30.168.1 Full Modulation Source Table (Excerpt)

| ID | Source           | Type      | Range       | Comments           |
|----|------------------|-----------|-------------|--------------------|
| 0  | None             | ---       | ---         | Disabled           |
| 1  | LFO1             | Bipolar   | –127..+127  | Per voice          |
| 2  | LFO2             | Bipolar   | –127..+127  | Per voice          |
| 3  | LFO3             | Bipolar   | –127..+127  | Per voice          |
| 4  | ENV1             | Unipolar  | 0..127      | Per voice          |
| 9  | Velocity         | Unipolar  | 0..127      | Per note           |
| 10 | Aftertouch       | Bipolar   | –127..+127  | Per note/global    |
| 12 | Macro1           | Bipolar   | –127..+127  | Panel/MIDI         |
| 20 | Random           | Bipolar   | –127..+127  | Per voice/tick     |
| 30 | Audio-Rate LFO   | Bipolar   | –127..+127  | Audio-rate only    |
| 40 | Custom Script 1  | User      | user-def.   | Registered source  |

### 30.168.2 Destination Table (Excerpt)

| ID | Destination     | CV Range | Hardware Path       |
|----|----------------|----------|---------------------|
| 1  | VCO1 Pitch     | 0–10V    | DAC→mux→S/H→Expo    |
| 3  | VCO2 PWM       | 0–10V    | DAC→mux→S/H→PWM     |
| 5  | VCF Cutoff     | 0–10V    | DAC→mux→S/H→FCV     |
| 7  | VCA Level      | 0–10V    | DAC→mux→S/H→VCA     |
| 8  | Pan            | 0–10V    | DAC→mux→S/H→Pan VCA |

### 30.168.3 Curve Table

| ID | Curve Name    | Mapping Function   | Description            |
|----|--------------|-------------------|------------------------|
| 0  | Linear       | y = x             | Direct, 1:1            |
| 1  | Exponential  | y = exp(ax)       | Steep response         |
| 2  | Logarithmic  | y = log(x+1)      | Gentle rise            |
| 3  | S&H          | y = sample(x)     | Stepwise, random       |
| 4  | Quantized    | y = step(x, n)    | n steps, stair-step    |
| 5  | Bipolar      | y = x – 64        | Signed mapping         |
| 6  | User Table   | y = LUT[x]        | User defined curve     |

### 30.168.4 Routing Diagram Example

```
[Macro1]--+->(depth,curve)->[VCO1 Pitch]
          +->(depth,curve)->[VCF Cutoff]
[LFO1]----+->(depth,curve)->[PWM]
[Random]--+->(depth,curve,prob)->[Pan]
[ENV3]----+->(depth,curve,cond:vel>100)->[VCA Level]
```

---

**End of Part 17: Matrix-12 Modulation Matrix Internals, Algorithmic Routing, and Custom Mod Sources – Complete Deep Dive.**

*This chapter unveils the full flexibility and technical depth of the modulation system, enabling expert reverse-engineering, expansion, and advanced patch design.*

---