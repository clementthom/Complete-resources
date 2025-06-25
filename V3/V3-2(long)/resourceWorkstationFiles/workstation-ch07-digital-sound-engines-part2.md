# Chapter 7: Digital Sound Engines — PCM, Wavetable, FM, Additive, Sampling  
## Part 2: FM Synthesis, Additive Synthesis, Sampling Engines, Multi-Engine Design, and Advanced Modulation

---

## Table of Contents

- 7.6 FM Synthesis (Frequency Modulation)
  - 7.6.1 What is FM Synthesis?
  - 7.6.2 History and Instruments
  - 7.6.3 FM Synthesis Theory: Operators, Algorithms, and Envelopes
  - 7.6.4 Coding a Simple FM Synth (Step-by-Step)
  - 7.6.5 Multi-Operator, Multi-Voice FM
  - 7.6.6 Tips for Implementing FM Engines on Embedded Systems
- 7.7 Additive Synthesis
  - 7.7.1 What is Additive Synthesis?
  - 7.7.2 Mathematical Basis: Harmonics and Fourier Synthesis
  - 7.7.3 Coding a Simple Additive Synth (Step-by-Step)
  - 7.7.4 Performance Optimization and Memory Tricks
- 7.8 Sampling Engines: Advanced Samplers
  - 7.8.1 Beyond Simple PCM: Keygroups, Zones, and Mapping
  - 7.8.2 Time-Stretch, Pitch-Shift, and Granular Engines
  - 7.8.3 Slicing, Chopping, and Real-Time Sample Manipulation
  - 7.8.4 Sample Streaming from Storage
  - 7.8.5 Memory Management and Buffering
- 7.9 Multi-Engine and Hybrid Architectures
  - 7.9.1 Why Combine Engines?
  - 7.9.2 Engine Routing, Mixing, and Layering
  - 7.9.3 Example Hybrid Architectures
- 7.10 Advanced Modulation, Macro Controls, and Automation
  - 7.10.1 Modulation Matrix: Sources, Destinations, Depth
  - 7.10.2 LFOs, Envelopes, and User Macros
  - 7.10.3 Automation Recording and Playback
- 7.11 Glossary and Reference Tables

---

## 7.6 FM Synthesis (Frequency Modulation)

### 7.6.1 What is FM Synthesis?

- Uses one oscillator (the modulator) to modulate the frequency of another (the carrier).
- Produces bright, complex, and evolving timbres not easily achievable with analog subtractive synthesis.
- Famous for electric pianos, bells, metallic sounds, and more.

### 7.6.2 History and Instruments

- Invented by John Chowning in the 1960s.
- First consumer synth: Yamaha GS-1 (1980), then DX7 (1983) — hugely influential.
- Still used in modern digital synths, VSTs, and workstations.

### 7.6.3 FM Synthesis Theory: Operators, Algorithms, and Envelopes

#### 7.6.3.1 Operators

- **Operator:** An independent oscillator with its own envelope.
- Operators can be chained (modulator -> carrier), or arranged in various topologies.

#### 7.6.3.2 Algorithms

- Define how operators are connected (which modulate which).
- DX7: 32 algorithms (e.g., 6-op linear chains, stacks, feedback loops).

#### 7.6.3.3 The FM Equation

```plaintext
output(t) = A * sin(2πf_c t + I * sin(2πf_m t))
```
- `A`: amplitude
- `f_c`: carrier frequency
- `f_m`: modulator frequency
- `I`: modulation index (depth)

#### 7.6.3.4 Envelopes

- Each operator typically has an envelope (ADSR or multi-stage).
- Fast attacks make percussive FM sounds; long decays for pads.

### 7.6.4 Coding a Simple FM Synth (Step-by-Step)

#### 7.6.4.1 Operator Struct

```c
typedef struct {
    float freq;    // Frequency
    float amp;     // Amplitude
    float env;     // Envelope value (0-1)
    float phase;   // Current phase
    float phase_inc; // Phase increment per sample
    // Envelope, feedback, etc.
} FMOperator;
```

#### 7.6.4.2 Main FM Voice Struct

```c
typedef struct {
    FMOperator carrier;
    FMOperator modulator;
    float mod_index;
} FMVoice;
```

#### 7.6.4.3 Rendering One FM Sample

```c
float mod = sinf(modulator.phase) * mod_index * modulator.env;
carrier.phase_inc = 2.0f * M_PI * carrier.freq / sample_rate + mod;
float sample = sinf(carrier.phase) * carrier.amp * carrier.env;
carrier.phase += carrier.phase_inc;
modulator.phase += 2.0f * M_PI * modulator.freq / sample_rate;
```

#### 7.6.4.4 Polyphony

- Use array of FMVoice structs, one per active note.

#### 7.6.4.5 Envelopes

- Update envelopes per sample or per block; exponential or linear decay.

### 7.6.5 Multi-Operator, Multi-Voice FM

- Real FM synths use 4-6 operators per voice.
- Each operator can modulate others (feedback, stacks, parallel).
- Efficient implementation: process in blocks, cache envelopes, use lookup tables for sine.

### 7.6.6 Tips for Implementing FM Engines on Embedded Systems

- Use fixed-point math for phase and envelopes if no FPU.
- Precompute sine tables and use linear interpolation.
- Limit polyphony and operator count for low-memory MCUs.
- Parameter smoothing avoids zipper noise on control changes.

---

## 7.7 Additive Synthesis

### 7.7.1 What is Additive Synthesis?

- Builds complex tones by summing many sine waves (harmonics).
- Based on Fourier’s theorem: any periodic waveform can be reconstructed from sines.

### 7.7.2 Mathematical Basis: Harmonics and Fourier Synthesis

- Sine wave: `sin(2πft)`
- Add harmonics: `sum_{n=1}^N a_n * sin(2π f_n t + φ_n)`
- `a_n`: amplitude of nth harmonic; `f_n = n * f0`; `φ_n`: phase

### 7.7.3 Coding a Simple Additive Synth (Step-by-Step)

#### 7.7.3.1 Data Structures

```c
#define MAX_HARMONICS 32
typedef struct {
    float freq;                // Fundamental
    float amp[MAX_HARMONICS];  // Amplitudes per harmonic
    float phase[MAX_HARMONICS];// Phase per harmonic
    float env;                 // Overall envelope
} AdditiveVoice;
```

#### 7.7.3.2 Rendering One Sample

```c
float out = 0.0f;
for (int h=0; h<num_harmonics; ++h) {
    out += amp[h] * sinf(2.0f * M_PI * freq * (h+1) * t + phase[h]);
}
out *= env;
```

#### 7.7.3.3 Envelope and Spectral Animation

- Animate `amp[h]` values for evolving timbres (e.g., morphing from sine to saw).

#### 7.7.3.4 Polyphony

- Use array of AdditiveVoice structs.

### 7.7.4 Performance Optimization and Memory Tricks

- Use lookup tables for sine waves.
- Restrict number of harmonics per voice.
- Sum in blocks for SIMD optimization.

---

## 7.8 Sampling Engines: Advanced Samplers

### 7.8.1 Beyond Simple PCM: Keygroups, Zones, and Mapping

- **Keygroup:** Range of keys mapped to a sample or group of samples.
- **Velocity Layer:** Different samples for hard/soft playing.
- **Round Robin:** Alternate between samples to avoid “machine gun” effect.

#### 7.8.1.1 Sample Mapping Table

```c
typedef struct {
    int low_key, high_key;
    int low_vel, high_vel;
    int16_t* sample;
    uint32_t length;
} SampleZone;
```

- On note-on, search for the best matching zone.

### 7.8.2 Time-Stretch, Pitch-Shift, and Granular Engines

#### 7.8.2.1 Time-Stretch

- Change playback speed without changing pitch.
- Techniques: phase vocoder, PSOLA, granular.

#### 7.8.2.2 Pitch-Shift

- Change pitch without affecting duration.
- Use resampling + time-stretch.

#### 7.8.2.3 Granular Synthesis

- Split sample into tiny grains (10–100 ms).
- Play grains at varying positions, rates, envelopes for rich textures.

### 7.8.3 Slicing, Chopping, and Real-Time Sample Manipulation

- **Slicing:** Detect peaks/transients (drum hits) and split sample.
- **Chopping:** Manually set slice points.
- Launch slices via MIDI, sequencer, or pads.

### 7.8.4 Sample Streaming from Storage

- Load only a window of the sample into RAM; stream from SD/SSD as needed.
- Double-buffering: While one buffer plays, next chunk loads in background.

### 7.8.5 Memory Management and Buffering

- Use circular buffers for streaming.
- Pin critical samples in RAM, less important ones in “virtual memory.”

---

## 7.9 Multi-Engine and Hybrid Architectures

### 7.9.1 Why Combine Engines?

- Get the best of all synthesis methods.
- Layer PCM samples with FM, add wavetable suboscillators, etc.

### 7.9.2 Engine Routing, Mixing, and Layering

- **Serial:** Output of one engine feeds another (e.g., FM into filter, then PCM sample).
- **Parallel:** Engines mixed at output (e.g., layer piano and string sample).
- **Cross-Modulation:** Output of one modulates another’s parameter.

### 7.9.3 Example Hybrid Architectures

- **Kurzweil V.A.S.T.:** Modular blocks (oscillators, DSP, sample playback) chained in custom order.
- **Roland Fantom:** PCM + virtual analog + digital filter + effects.
- **DIY:** User-configurable routing matrix.

---

## 7.10 Advanced Modulation, Macro Controls, and Automation

### 7.10.1 Modulation Matrix: Sources, Destinations, Depth

- **Sources:** LFO, envelope, velocity, aftertouch, MIDI CC, step sequencer.
- **Destinations:** Pitch, filter cutoff, amplifier, FM index, wavetable position.
- **Depth:** Amount of modulation (positive/negative).

#### 7.10.1.1 Example Modulation Matrix Entry

```c
typedef struct {
    int src;      // Source (LFO1, ENV2, etc.)
    int dest;     // Destination (pitch, cutoff)
    float depth;  // Modulation amount
} ModMatrixEntry;
```

- Evaluate matrix per voice each sample/block.

### 7.10.2 LFOs, Envelopes, and User Macros

- Multiple LFOs with different shapes (sine, triangle, random).
- Multi-stage envelopes (ADSR, DAHDSR, custom curves).
- Macros: User assigns multiple destinations to one knob/slider.

### 7.10.3 Automation Recording and Playback

- Record parameter changes over time (knobs, CCs, macros).
- Playback automation with sequencer or DAW sync.
- Interpolate between points for smooth automation.

---

## 7.11 Glossary and Reference Tables

| Term         | Definition                                      |
|--------------|-------------------------------------------------|
| FM           | Frequency Modulation synthesis                  |
| Operator     | Oscillator + envelope in FM engine              |
| Algorithm    | Connection pattern for FM operators             |
| Additive     | Synthesis by summing sine harmonics             |
| Keygroup     | Range of keys mapped to sample(s)               |
| Zone         | Region of key/velocity assigned to a sample     |
| Granular     | Synthesis by playing micro-slices (“grains”)    |
| Mod Matrix   | Routing grid for modulation sources/dests       |
| Macro        | User control mapped to multiple parameters      |
| Automation   | Recording/playback of parameter changes         |

### 7.11.1 Table: FM Operator Arrangements (DX7 Examples)

| Algorithm | # of Operators | Connection Pattern              |
|-----------|----------------|---------------------------------|
| 1         | 6              | Linear chain (Op6->5->4->3->2->1)|
| 5         | 6              | Two stacks: (Op6->5->4) + (Op3->2->1)|
| 32        | 6              | All parallel (all modulate output)|

### 7.11.2 Table: Granular Engine Parameters

| Parameter      | Typical Range         | Effect                         |
|----------------|----------------------|--------------------------------|
| Grain size     | 1–100 ms              | Texture smoothness             |
| Grain rate     | 5–100 grains/sec      | Density, thickness             |
| Start position | 0–sample length       | Scrub, time-stretch            |
| Envelope type  | Sine, triangle, gauss | Grain attack/decay shape       |

---

**End of Part 2 and Chapter 7: Digital Sound Engines.**

**You now have a comprehensive, beginner-friendly, and exhaustive reference for PCM, wavetable, FM, additive, and sampling synthesis engines.  
If you want to proceed to the next chapter (Analog Boards: Mixing, Filtering, and Output), or want deeper expansion on any topic, just say so!**