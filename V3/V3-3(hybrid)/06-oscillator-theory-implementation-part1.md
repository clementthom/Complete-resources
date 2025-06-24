# Chapter 6: Oscillator Theory and Implementation (with DACs) – Part 1

---

## Table of Contents

1. Introduction: The Role of Oscillators in Synthesizers
2. Waveform Theory: Sine, Square, Triangle, Saw, and Beyond
    - Mathematical definitions
    - Harmonic analysis
    - Audible effects of each waveform
3. Historical Oscillator Designs
    - Analog: Discrete, IC-based (CEM, SSM, Curtis, Moog, Roland)
    - Digital: Early hybrids, DCOs, wavetable, and FM
    - Modern approaches: FPGA, microcontrollers, Pi, and PC
4. Modular Hardware/Software Mapping: Each Oscillator as a Module
    - Hardware: Classic “voice card” design
    - Software: Modular C code to mimic physical modules
    - Interfacing between modules (signal, control, modulation)
5. Digital Oscillator Implementation in C
    - Phase accumulator principle
    - Floating-point vs fixed-point: pros and cons
    - Phase, frequency, and sample rate relations
    - Polyphony: managing multiple oscillators
    - Bandlimiting and aliasing reduction (PolyBLEP, minBLEP)
6. Practical: Building a Modular Oscillator in C
    - Struct-based design (mimicking hardware boards)
    - Function pointers for wave shape selection
    - Example: Sine, Square, Sawtooth, Triangle, and Noise
    - Initializing, processing, and resetting oscillators
    - Parameter updates (frequency, amplitude, phase mod)
    - Buffer and sample-based use
7. Deep Code Walkthrough (PortAudio/PC)
    - Setting up PortAudio for real-time audio output
    - Writing a modular oscillator bank
    - Extensive commentary: every function, struct, and argument explained
    - Testing with different waveforms, frequencies, and polyphony
8. Interfacing Digital Oscillators with DACs (Raspberry Pi)
    - DAC selection (bit depth, speed, interface type)
    - SPI, I2C, and parallel interfacing basics
    - Practical circuit: connecting a Pi to a DAC (PCM5102A, MCP4922, etc.)
    - Voltage scaling, analog output filtering (reconstruction filter)
    - Testing with oscilloscope and speakers
9. Advanced Topics (to be continued in Part 2)
    - Hard sync, soft sync
    - FM, PM, and AM digital techniques
    - Detuning, drift, and analog modeling
    - Noise shaping and dithering for high fidelity

---

## 1. Introduction: The Role of Oscillators in Synthesizers

Oscillators are the **sound source** of any synthesizer. They generate periodic or aperiodic signals (waveforms) that form the raw material for all further processing (filtering, enveloping, mixing, etc.). In a hybrid synth, oscillators may be digital, analog, or a mix (e.g., digital core with analog “back end”).

**Key ideas:**
- Oscillators create the **fundamental tone** and harmonic content.
- Multiple oscillators (polyphony) allow for chords, layering, detuning, and thick sounds.
- Modulation (LFO, envelope, FM/PM) transforms simple waveforms into complex sonic textures.

---

## 2. Waveform Theory: Sine, Square, Triangle, Saw, and Beyond

### 2.1 Mathematical Definitions

- **Sine wave:** `y(t) = A * sin(2πft + φ)`
- **Square wave:** Alternates between +A and -A; can be defined with a sign function.
- **Triangle wave:** Linear rise and fall between -A and +A.
- **Sawtooth wave:** Ramps up (or down) linearly, then jumps back.
- **Noise:** Random values, white (flat spectrum), pink (1/f spectrum), etc.

#### Table: Waveform Equations

| Waveform  | Equation (as a function of phase 0..1)         |
|-----------|------------------------------------------------|
| Sine      | `A * sin(2π * phase)`                          |
| Square    | `A * (phase < 0.5 ? 1 : -1)`                   |
| Triangle  | `A * (4 * abs(phase - 0.5) - 1)`               |
| Sawtooth  | `A * (2 * phase - 1)`                          |
| Noise     | random value in `[-A, +A]`                     |

### 2.2 Harmonic Analysis

- **Sine**: Only fundamental.
- **Square**: Odd harmonics (1, 3, 5...), amplitude drops as 1/n.
- **Triangle**: Odd harmonics, drops faster (1/n²).
- **Sawtooth**: All harmonics, drops as 1/n.

**Why does this matter?**  
Filters, envelopes, and analog quirks all interact with these harmonics to create musical or noisy timbres.

### 2.3 Audible Effects

- **Sine**: Pure, flute-like, often used as a building block.
- **Square**: Hollow, clarinet-like, good for leads/bass.
- **Triangle**: Soft, mellow, good for pads.
- **Sawtooth**: Bright, buzzy, brassy, classic synth sound.

---

## 3. Historical Oscillator Designs

### 3.1 Analog

#### Discrete Transistor Oscillators

- Early Moog, ARP, Oberheim used discrete transistor circuits.
- Known for drift (pitch instability) and unique “musical” imperfections.

#### IC-Based: Curtis (CEM), SSM, Roland

- **CEM3340**: Legendary VCO chip (Prophet-5, SH-101, Memorymoog).
    - Features: accurate exponential conversion, triangle core, temperature compensation.
- **SSM2033, SSM2044**: Famous for lush, fat analog tones.
- **Roland DCOs**: Digitally Controlled Oscillators—analog core, digital timing.

#### Sourcing Advice

- NOS (new old stock) is expensive and rare.
- Modern clones: AS3340, Coolaudio V3340, SSI2130.
- Test chips for authenticity—counterfeits are common!

### 3.2 Digital

#### Early Hybrids (Emulator, PPG)

- Used DACs to turn digital waveforms into analog signals.
- Polyphony achieved by multiplexing or having multiple oscillators per voice.

#### DCOs (Juno, Polysix)

- Analog waveform generation, but frequency set digitally for stability.

#### Wavetable (PPG, Prophet VS)

- Digital memory stores sets of waveforms; oscillator selects and interpolates.

#### FM (Yamaha DX series, Synclavier)

- Frequency/phase modulation of oscillators to generate complex spectra.

#### Modern Approaches

- **Microcontrollers (STM32, Teensy)**: Affordable high-speed digital oscillators, easy to code in C.
- **FPGAs**: True parallelism, great for high-voice-count synths.
- **Raspberry Pi/PC**: Leverage powerful CPUs for complex synthesis (but may need external DAC for fidelity).

---

## 4. Modular Hardware/Software Mapping: Each Oscillator as a Module

### 4.1 Hardware: Classic “Voice Card” Design

- Each card = 1 or more oscillators + envelope, filter, VCA.
- Early synths: individual PCBs per voice (e.g., Oberheim OB-X, Prophet-5).
- Modern: voice implemented as a struct or object in code, matching hardware modularity.

### 4.2 Software: Modular C Code to Mimic Physical Modules

- **Each oscillator = C struct, with state + function pointers.**
- **Separation of concerns:** oscillator code doesn’t know about filters, envelopes, or UI—just like a real hardware board.
- **Interfacing:** Connect modules via function arguments (pass pointers to audio buffers or structs).

### 4.3 Interfacing Between Modules

- **Signal path:** Pass output of oscillator to filter/envelope.
- **Control path:** Update frequency, amplitude, phase from UI, MIDI, or modulation sources.
- **Modulation:** LFOs or envelopes can modulate oscillator parameters dynamically.

---

## 5. Digital Oscillator Implementation in C

### 5.1 Phase Accumulator Principle

Most digital oscillators use a **phase accumulator**:
- Store the current “phase” (0..1 or 0..2π).
- Each sample, increment phase by `freq / sample_rate`.
- Generate output based on phase.

```c
typedef struct {
    float frequency;
    float phase;
    float sample_rate;
    float amplitude;
    // function pointer for waveform
} Oscillator;

void osc_update(Oscillator *osc) {
    osc->phase += osc->frequency / osc->sample_rate;
    if (osc->phase >= 1.0f) osc->phase -= 1.0f;
}
```

### 5.2 Floating-point vs Fixed-point

- **Floating-point:** Easier to code, more flexible, but slower on older microcontrollers.
- **Fixed-point:** Faster on some hardware, but tricky to implement.
- **Raspberry Pi/PC:** Floating-point is fine; on MCUs, consider fixed-point for efficiency.

### 5.3 Phase, Frequency, and Sample Rate Relations

- **Increment per sample:** `phase_inc = frequency / sample_rate`
- **Phase wraps:** Keep phase in [0,1) for simplicity (or [0,2π) if using trig functions).

### 5.4 Polyphony: Managing Multiple Oscillators

- Use an array of structs (one per voice).
- Each oscillator has its own frequency, phase, and other state.
- Efficient for “voice stealing” and dynamic allocation.

### 5.5 Bandlimiting and Aliasing Reduction

#### Why Bandlimit?

- Naive digital waveforms (especially square/saw) have harmonics above Nyquist, causing aliasing.
- Aliasing sounds harsh and digital.

#### Solutions

- **PolyBLEP (Polynomial Band-Limited Step):** Adds a correction at waveform discontinuities to suppress aliasing.
- **minBLEP:** Similar, but uses precomputed tables for higher quality.
- **Oversampling + filtering:** Generate at higher rate, then low-pass filter and decimate.

**PolyBLEP Example (conceptual):**

```c
float poly_blep(float t, float dt) {
    if (t < dt) {
        float x = t / dt;
        return x + x - x * x - 1.0f;
    } else if (t > 1.0f - dt) {
        float x = (t - 1.0f) / dt;
        return x * x + x + x + 1.0f;
    } else {
        return 0.0f;
    }
}
```

Apply this correction at discontinuities in saw/square oscillators.

---

## 6. Practical: Building a Modular Oscillator in C

### 6.1 Struct-Based Design (Hardware-Inspired)

Define a struct for each oscillator, including:
- Parameters: frequency, amplitude, phase, waveform type
- State: current phase, modulation input
- Function pointers: for waveform generation

**oscillator.h**
```c
#ifndef OSCILLATOR_H
#define OSCILLATOR_H

typedef enum {
    OSC_SINE,
    OSC_SQUARE,
    OSC_TRIANGLE,
    OSC_SAW,
    OSC_NOISE
} OscillatorType;

typedef struct Oscillator Oscillator;

typedef float (*WaveformFunc)(Oscillator*);

struct Oscillator {
    OscillatorType type;
    float frequency;
    float amplitude;
    float phase;
    float sample_rate;
    WaveformFunc waveform_func;
    // Add modulation sources, etc.
};

void osc_init(Oscillator* osc, OscillatorType type, float freq, float amp, float sr);
float osc_process(Oscillator* osc);

#endif
```

**oscillator.c**
```c
#include "oscillator.h"
#include <math.h>
#include <stdlib.h> // for rand()

#define TWO_PI 6.283185307179586476925286766559f

static float sine_wave(Oscillator *osc) {
    return osc->amplitude * sinf(TWO_PI * osc->phase);
}

static float square_wave(Oscillator *osc) {
    return osc->amplitude * ((osc->phase < 0.5f) ? 1.0f : -1.0f);
}

static float triangle_wave(Oscillator *osc) {
    float val = 4.0f * fabsf(osc->phase - 0.5f) - 1.0f;
    return osc->amplitude * val;
}

static float saw_wave(Oscillator *osc) {
    return osc->amplitude * (2.0f * osc->phase - 1.0f);
}

static float noise_wave(Oscillator *osc) {
    return osc->amplitude * ((float)rand() / (float)RAND_MAX * 2.0f - 1.0f);
}

void osc_init(Oscillator* osc, OscillatorType type, float freq, float amp, float sr) {
    osc->type = type;
    osc->frequency = freq;
    osc->amplitude = amp;
    osc->phase = 0.0f;
    osc->sample_rate = sr;
    switch(type) {
        case OSC_SINE:    osc->waveform_func = sine_wave;    break;
        case OSC_SQUARE:  osc->waveform_func = square_wave;  break;
        case OSC_TRIANGLE:osc->waveform_func = triangle_wave;break;
        case OSC_SAW:     osc->waveform_func = saw_wave;     break;
        case OSC_NOISE:   osc->waveform_func = noise_wave;   break;
        default:          osc->waveform_func = sine_wave;    break;
    }
}

float osc_process(Oscillator* osc) {
    float out = osc->waveform_func(osc);
    osc->phase += osc->frequency / osc->sample_rate;
    if (osc->phase >= 1.0f) osc->phase -= 1.0f;
    return out;
}
```

### 6.2 Initializing, Processing, and Resetting Oscillators

- `osc_init()` sets up all fields and selects the correct waveform function.
- `osc_process()` generates one sample, advances phase.
- To reset, set `osc->phase = 0.0f;`.

### 6.3 Buffer and Sample-Based Use

To generate a buffer of audio:

```c
void osc_fill_buffer(Oscillator* osc, float* buf, int n) {
    for (int i = 0; i < n; ++i) {
        buf[i] = osc_process(osc);
    }
}
```

### 6.4 Parameter Updates

Change frequency or amplitude on the fly:

```c
osc->frequency = new_freq;
osc->amplitude = new_amp;
```

Phase modulation/FM:

```c
osc->phase += mod_input; // mod_input = phase offset (in 0..1 units)
```

---

*End of Part 1. Part 2 will cover deep PortAudio/PC implementation, detailed code walkthrough, Pi DAC interfacing, and hands-on testing.*