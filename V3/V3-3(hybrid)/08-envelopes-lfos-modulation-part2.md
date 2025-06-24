# Chapter 8: Envelopes, LFOs, and Modulation Sources – Part 2

---

## Table of Contents

4. Deep Dive: Low-Frequency Oscillators (LFOs)
    - What is an LFO? How it differs from audio-rate oscillators
    - Waveforms: sine, triangle, square, saw, random, sample & hold
    - LFO destinations: vibrato, tremolo, filter mod, PWM, amplitude, etc.
    - LFO parameters: rate, depth, phase, delay, retrigger, fade-in
    - Syncing LFOs to tempo or events
    - Analog LFO circuits (op-amp, transistor, function generator ICs)
    - Digital LFOs: implementation in C, table lookup, phase accumulation
    - Combining LFOs: cross-modulation, chaos, random walks
    - Practical LFO design and measurement
5. Modulation Routing and Matrixes
    - Patch cables, switches, CV buses (hardware)
    - Modulation matrix: software routing (assignable sources/destinations)
    - Depth, polarity, offset, scaling
    - CV mixing and summing
    - Digital implementation: modulation buses, parameter addressing
6. Advanced Modulation Sources
    - Sample & Hold: theory, circuits, C implementation
    - Random (noise, chaos, pseudo-random sequences)
    - Envelope followers
    - Slew limiters (portamento/glide)
    - Complex/conditional modulators (logic, comparators, function generators, math)
7. Polyphonic Modulation
    - Per-voice envelopes and LFOs
    - Global vs. local modulation
    - Modulation assignment strategies in code
8. Exercises and Practice Projects
9. Summary and Further Reading

---

## 4. Deep Dive: Low-Frequency Oscillators (LFOs)

### 4.1 What is an LFO? How It Differs from Audio-Rate Oscillators

An **LFO** (Low-Frequency Oscillator) is an oscillator designed to operate below the audible frequency range (typically <20 Hz, but sometimes up to several hundred Hz for special effects). While audio oscillators create sound, LFOs shape or modulate parameters of other modules.

- **Typical frequency range:** 0.01 Hz to 20 Hz (periods from milliseconds to minutes)
- **Purpose:** Modulation, not direct sound production (unless used for sub-audio rumble or effects)
- **Example applications:** Vibrato (modulating pitch), tremolo (modulating amplitude), filter sweeps, PWM (pulse width modulation), pan sweeps, rhythmic effects

### 4.2 LFO Waveforms

- **Sine:** Smooth, cyclic oscillation. Good for natural vibrato, tremolo.
- **Triangle:** Linear up/down ramps. Even, symmetrical modulation.
- **Square:** Abrupt on/off switching. Useful for trills, sudden changes, clocking sample & hold.
- **Sawtooth:** Linear ramp up or down. Used for ramp/decay modulation, rhythmic movement.
- **Random (sample & hold):** Steps to new random value at each clock. Used for random filter, pitch, or amplitude modulation.
- **Other:** Exponential/logarithmic, custom shapes, trapezoidal, “shark fin”, chaos.

#### Visual Examples

```
Sine:      ~~~~~~~~
Triangle:  /\/\/\/\
Square:    ┌─┐ ┌─┐
           │ │ │ │
           └─┘ └─┘
Saw:       /| /| /|
Random:    └─┬─┘ ┬─┘ ┬─┘
```

### 4.3 LFO Destinations

- **Pitch (VCO):** Vibrato, siren effects
- **Amplitude (VCA):** Tremolo, chopper effects
- **Filter cutoff (VCF):** Wah, rhythmic filter sweeps
- **Pulse width (oscillator):** PWM, rich evolving timbres
- **Panning:** Auto-pan, spatial movement
- **Other:** Wavetable position, effect parameters, crossfading

### 4.4 LFO Parameters

- **Rate:** Frequency of oscillation (Hz or BPM-synced)
- **Depth:** Amount of modulation applied (0–100%, or in volts)
- **Phase:** Start point of LFO cycle (affects relative timing)
- **Delay:** Time before LFO starts after note-on
- **Retrigger:** Whether LFO resets phase on new note/gate
- **Fade-in:** Gradual increase in depth after start
- **Shape:** Some LFOs allow morphing between waveforms

#### Special Features

- **Sync:** Lock LFO to MIDI clock, sequencer, or tempo grid
- **Retrigger:** Useful for per-note consistency or evolving patterns

### 4.5 Syncing LFOs to Tempo or Events

- **MIDI clock sync:** Divide/multiply clock for synced LFO rates (1/4, 1/8, 1/16 notes)
- **Event sync:** Reset phase on note-on, envelope, or external pulse
- **Free-run:** LFO keeps cycling regardless of events

#### Example: BPM to Hz

`LFO Rate (Hz) = BPM × beats_per_cycle / 60`

For a 1/4 note LFO at 120 BPM:
- 120 BPM × (1/4) = 30 cycles/minute = 0.5 Hz

### 4.6 Analog LFO Circuits

- **Op-amp integrator:** Triangle and square LFOs (classic design)
- **Function generator ICs:** XR2206, ICL8038, produce multiple waveforms
- **OTA-based:** Voltage-controlled rate
- **JFET/diode shaping:** For sine, ramp, or custom curves

#### Example: Classic Integrator LFO

- Square wave toggles integrator charging/discharging a capacitor.
- Output is triangle; square is also available.
- Add wave-shaping for sine.

### 4.7 Digital LFOs: Implementation in C

#### Phase Accumulation (as in audio oscillators)

```c
typedef struct {
    float phase;
    float rate;
    float sample_rate;
    float depth;
    float (*waveform_func)(float phase);
} LFO;

float sine_wave(float phase) { return sinf(2.0f * M_PI * phase); }

void lfo_init(LFO* lfo, float rate, float depth, float sr) {
    lfo->phase = 0.0f;
    lfo->rate = rate;
    lfo->depth = depth;
    lfo->sample_rate = sr;
    lfo->waveform_func = sine_wave;
}

float lfo_process(LFO* lfo) {
    float out = lfo->depth * lfo->waveform_func(lfo->phase);
    lfo->phase += lfo->rate / lfo->sample_rate;
    if (lfo->phase >= 1.0f) lfo->phase -= 1.0f;
    return out;
}
```

#### Table Lookup (for CPU efficiency)

- Precompute waveform table (e.g., 1024 points per cycle)
- Use phase to index table
- Interpolate between points for smoothness

#### Sample & Hold LFO

- Use a timer or clock to update output with new random value at intervals

### 4.8 Combining LFOs

- **Sum:** Add two LFOs for complex motion
- **Multiply:** AM or ring-mod for evolving patterns
- **Cross-modulate:** One LFO modulates rate or amplitude of another (chaos, unpredictability)
- **Random walks:** LFO output drifts smoothly via random increments

### 4.9 Practical LFO Design and Measurement

- **Breadboard analog LFO:** Use dual op-amp (TL072) for triangle/square
- **Visualize:** Use oscilloscope to check shape, rate, range
- **Digital LFO:** Output to DAC and monitor with scope
- **Test modulation:** Apply LFO to VCO/VCF/VCA and listen for expected effect

---

## 5. Modulation Routing and Matrixes

### 5.1 Hardware Modulation Routing

- **Patch cables:** Manual routing in modular/semimodular synths (Moog, Eurorack)
- **Switches:** Select between sources or destinations
- **CV buses:** Common in polyphonic or integrated synths

### 5.2 Modulation Matrix: Software Routing

- **Assign sources to destinations:** Any LFO, envelope, or CV can be routed to any parameter
- **Depth control:** How much modulation is applied
- **Polarity and offset:** Invert or bias the modulation
- **Stacking:** Multiple sources can affect one parameter (sum or mix)

#### Example: Digital Modulation Matrix (C Pseudocode)

```c
typedef struct {
    float* source;
    float depth;
    int polarity; // 1 = normal, -1 = inverted
} ModRoute;

typedef struct {
    ModRoute routes[MAX_ROUTES];
    int num_routes;
} ModMatrix;

float apply_mod_matrix(ModMatrix* m, float base) {
    float mod = base;
    for (int i = 0; i < m->num_routes; ++i)
        mod += m->routes[i].depth * m->routes[i].polarity * (*m->routes[i].source);
    return mod;
}
```

### 5.3 CV Mixing and Summing

- **Passive mixing:** Simple resistor network, but sources interact and signals may attenuate
- **Active mixing:** Op-amp summing, preserves signal strength and isolation
- **Software mixing:** Summing or averaging arrays of modulation sources

### 5.4 Digital Implementation: Modulation Buses, Parameter Addressing

- **Modulation bus:** Array or table where sources write and destinations read
- **Parameter addressing:** Each mod destination has an address/index
- **Dynamic assignment:** Allow user to re-route modulation without rewiring

### 5.5 Best Practices

- Limit modulation depth to avoid parameter overflows
- Provide visual feedback (LEDs, UI) for active modulation
- Use smoothing/lag processors to avoid abrupt changes (especially with digital sources)

---

## 6. Advanced Modulation Sources

### 6.1 Sample & Hold (S&H)

- **Theory:** Samples input (often noise) at a clock rate, holds value until next clock
- **Used for:** Random step modulation; classic “burbling” or “computer” sounds

#### Analog S&H Circuit

- FET switch or analog switch samples voltage
- Capacitor holds voltage until next clock
- Buffer prevents droop

#### C Implementation

```c
typedef struct {
    float current;
    int counter;
    int rate; // in samples
    float (*input_source)();
} SampleHold;

float sample_hold_process(SampleHold* sh) {
    if (++sh->counter >= sh->rate) {
        sh->current = sh->input_source();
        sh->counter = 0;
    }
    return sh->current;
}
```

### 6.2 Random (Noise, Chaos, Pseudo-Random Sequences)

- **White noise:** Equal energy at all frequencies
- **Pink noise:** Energy decreases with frequency (musical, less harsh)
- **Chaos:** Nonlinear systems, e.g., Lorenz attractor, logistic map
- **Pseudo-random sequences:** Deterministic, repeatable “randomness” (LFSR, Xorshift)

### 6.3 Envelope Followers

- Converts incoming audio amplitude to a control signal
- Used for dynamic effects, auto-wah, gating, compression

#### Circuit

- Rectifier (diode or precision op-amp)
- Low-pass filter to smooth output

#### C Implementation

```c
typedef struct {
    float value;
    float attack_coeff;
    float release_coeff;
} EnvFollower;

float env_follower_process(EnvFollower* ef, float input) {
    float abs_in = fabsf(input);
    if (abs_in > ef->value)
        ef->value += ef->attack_coeff * (abs_in - ef->value);
    else
        ef->value += ef->release_coeff * (abs_in - ef->value);
    return ef->value;
}
```

### 6.4 Slew Limiters (Portamento/Glide)

- **Purpose:** Limits rate of change of a control signal
- **Use:** Smooths pitch (glide), filter cutoff, or any modulated parameter

#### C Implementation

```c
typedef struct {
    float value;
    float rate; // max change per sample
} SlewLimiter;

float slew_process(SlewLimiter* sl, float target) {
    if (fabsf(target - sl->value) < sl->rate)
        sl->value = target;
    else if (target > sl->value)
        sl->value += sl->rate;
    else
        sl->value -= sl->rate;
    return sl->value;
}
```

### 6.5 Complex/Conditional Modulators

- **Logic functions:** AND, OR, XOR, NOT applied to gates or triggers
- **Comparators:** Output high/low based on threshold, used for gate extraction
- **Function generators:** Create arbitrary shapes (envelope, LFO, math expressions)
- **Math:** Add, subtract, multiply, divide, invert, scale

---

## 7. Polyphonic Modulation

### 7.1 Per-Voice Modulators

- Each voice has its own envelope(s) and LFO(s)
- Allows for natural “ensemble” effects, detuning, voice-specific mod

#### Example: C Struct

```c
typedef struct {
    Envelope env;
    LFO lfo;
    // more per-voice modulators...
} Voice;
```

### 7.2 Global vs Local Modulation

- **Global:** One mod source affects all voices equally (e.g., master LFO)
- **Local:** Per-voice mod sources, can be detuned or offset for chorus/unison effects

### 7.3 Modulation Assignment Strategies in Code

- Use arrays of structs for each voice
- For each sample/frame, process modulation for each voice individually
- For global sources, share a pointer/reference to save processing

#### Voice Processing Loop

```c
for (int v = 0; v < NUM_VOICES; ++v) {
    float modulated_param = base + voice[v].lfo.value * lfo_depth + voice[v].env.output * env_depth;
    // process oscillator, filter, etc.
}
```

---

## 8. Exercises and Practice Projects

1. **Build an analog LFO on breadboard.** Measure its frequency range and waveform shapes.
2. **Implement a digital LFO in C.** Add morphing between waveforms.
3. **Breadboard a simple envelope follower.** Apply it to a drum machine or guitar signal.
4. **Write a modulation matrix in C.** Allow the user to assign any source to any destination with variable depth.
5. **Implement sample & hold in code and hardware.** Compare analog and digital results.
6. **Simulate polyphonic modulation:** Write C code to process envelopes/LFOs for 8 voices and route to synth parameters.
7. **Patch a complex mod chain:** Use LFO → S&H → slew → filter, and document the results.
8. **Experiment with logic/comparator-based modulation:** Use triggers/gates to switch or combine modulation sources.

---

## 9. Summary and Further Reading

- Modulation is essential for expressive, lively synth sounds.
- Master envelopes and LFOs, both in hardware and C code.
- Use modulation routing and matrixes for maximum flexibility.
- Explore advanced sources (S&H, random, logic) for creative sound design.
- Design for polyphony with per-voice mod sources and efficient code.

**Further Reading:**
- “Make: Analog Synthesizers” by Ray Wilson
- “The Art of Electronics” by Horowitz & Hill
- “Electronotes” archive
- Synth-DIY forums, yusynth.net, Mutable Instruments open-source code

---

*End of Chapter 8. Next: Polyphony & Voice Allocation (deep dive into how synths handle multiple notes, voice stealing, and practical modular C implementations).*