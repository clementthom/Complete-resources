# Chapter 15: Synthesis Engines — Subtractive, FM, Wavetable, Physical Modeling, and More  
## Part 2: FM, Wavetable, Granular, Additive, Physical Modeling, Hybrid Synthesis, and Synthesis UI/Performance

---

## Table of Contents

- 15.6 Introduction: Advanced Digital Synthesis for the Beginner
- 15.7 FM Synthesis
  - 15.7.1 FM Basics: Carrier, Modulator, Algorithms
  - 15.7.2 FM Operator Structure and Envelopes
  - 15.7.3 Classic DX7, 4-Op vs. 6-Op, Algorithm Diagrams
  - 15.7.4 FM Implementation: Code, Tables, Anti-Aliasing
  - 15.7.5 FM Sound Design: Bells, Basses, Electric Pianos, Percussion
- 15.8 Wavetable Synthesis
  - 15.8.1 Wavetable Concepts: Tables, Interpolation, Morphing
  - 15.8.2 Table Construction: Single-Cycle Waves, Multisample, User Drawn
  - 15.8.3 Wavetable Playback: Position, Keytracking, Interpolation
  - 15.8.4 Wavetable Modulation: LFO, Envelope, Morph, Sync
  - 15.8.5 Wavetable Engines in Hardware and Software
- 15.9 Granular Synthesis
  - 15.9.1 Granular Basics: Grains, Density, Size, Envelope
  - 15.9.2 Granular Playback: Time-Stretch, Pitch-Shift, Scrub
  - 15.9.3 Real-Time Granular Engines: Live Audio, Streaming, Slicing
  - 15.9.4 Granular Sound Design: Clouds, Textures, Glitch, Ambient
- 15.10 Additive Synthesis
  - 15.10.1 Additive Theory: Harmonics, Partials, Amplitude/Phase
  - 15.10.2 Additive Engine Architecture: Sine Banks, FFT, Resynthesis
  - 15.10.3 Control: Envelopes, Spectral Morph, User Editing
  - 15.10.4 Additive Sound Design: Organs, Bells, Digital Pads
- 15.11 Physical Modeling Synthesis
  - 15.11.1 Physical Modeling Overview: What, Why, How
  - 15.11.2 Simple Models: Karplus-Strong, Plucked String, Drum Membrane
  - 15.11.3 Advanced Models: Waveguide, Mass-Spring, Modal, Finite Element
  - 15.11.4 Physical Modeling Sound Design: Strings, Winds, Percussion, Hybrid
- 15.12 Hybrid Synthesis
  - 15.12.1 Combining Engines: PCM+Analog, FM+Wavetable, Additive+Granular
  - 15.12.2 Hybrid Signal Routing, Layering, and Modulation
  - 15.12.3 Hybrid Synthesis in Famous Workstations
- 15.13 Advanced Modulation, Macro, and Performance Control
  - 15.13.1 Modulation Sources: LFO, Envelope, Step Seq, MIDI, CV, Random
  - 15.13.2 Modulation Matrix: Routing, Depth, Polarity, Curves
  - 15.13.3 Macro Controls: Assign, Morph, Scene, Mod Wheel, XY Pad
  - 15.13.4 Performance Features: Polyphonic Modulation, MPE, Aftertouch
  - 15.13.5 Synthesis UI: Patch Editing, Visualization, Learn Modes
- 15.14 Synthesis Engine Optimization and Integration
  - 15.14.1 DSP Load, Polyphony, Voice Stealing, Priority
  - 15.14.2 Memory, Tables, and Data Structures
  - 15.14.3 Integration with Sequencer, FX, and Sampling Engines
  - 15.14.4 Preset Management, Patch Morphing, and Randomization
  - 15.14.5 Real-Time Performance, Low-Latency, and Glitch Handling
- 15.15 Glossary and Reference Tables

---

## 15.6 Introduction: Advanced Digital Synthesis for the Beginner

This section demystifies advanced synthesis engines for beginners, explaining every key concept, algorithm, and practical implementation with clarity and depth.  
FM, wavetable, granular, additive, and physical modeling synthesis each unlock unique creative and technical possibilities in workstations.  
Hybrid engines blend these techniques for powerful modern sound design.

---

## 15.7 FM Synthesis

### 15.7.1 FM Basics: Carrier, Modulator, Algorithms

- **FM (Frequency Modulation) Synthesis:** One oscillator (modulator) modulates the frequency of another (carrier).
- **Result:** Complex, evolving waveforms with rich harmonic content, far beyond simple subtractive.
- **Terminology:**
  - **Carrier:** Oscillator you hear.
  - **Modulator:** Oscillator that affects the pitch of the carrier.
  - **Index:** How much modulation is applied (depth).
  - **Ratio:** Frequency relationship between carrier and modulator.
  - **Algorithm:** Network of operators (oscillators) and their connections.

#### 15.7.1.1 Simple 2-Op FM Diagram

```
[Modulator] --+
              |
           [FM Index] --[Carrier]--> [Output]
```

#### 15.7.1.2 Classic DX7: 6 Operators, 32 Algorithms

- Each “operator” is an oscillator+envelope block.
- Operators can be arranged in series (modulation chains) or parallel (stacks), allowing additive and FM possibilities.

### 15.7.2 FM Operator Structure and Envelopes

- **Operator:** Sine wave oscillator with individual envelope (attack, decay, sustain, release)
- **Envelope:** Controls loudness or modulation depth per operator, shapes sound over time
- **Feedback:** Some algorithms allow an operator to modulate itself, creating noise/chaos

#### 15.7.2.1 Operator Envelope Example

- Attack: 0–100ms
- Decay: 100–300ms
- Sustain: level held as long as key is pressed
- Release: fade to zero after key release

### 15.7.3 Classic DX7, 4-Op vs. 6-Op, Algorithm Diagrams

- **4-Op FM:** Simpler, found in Yamaha FB-01, TX81Z, etc. Fewer harmonics, less complexity.
- **6-Op FM:** DX7, SY77, Reface DX, etc. Full complexity, lush pads, realistic electric pianos.
- **Algorithm Diagrams:** Show how operators are connected; more feedback and parallel paths = more complex sounds.

### 15.7.4 FM Implementation: Code, Tables, Anti-Aliasing

- **Core Equation:**  
  `output = sin(2πf_c t + I * sin(2πf_m t))`  
  where f_c = carrier freq, f_m = modulator freq, I = index
- **Tables:** Use sine lookup tables for speed (as in subtractive engines)
- **Anti-Aliasing:** Use limited modulation index at high frequencies, or oversample, to avoid digital artifacts

#### 15.7.4.1 Simple C Pseudocode

```c
phase_mod += 2 * PI * mod_freq / sample_rate;
mod = sin(phase_mod) * index;
phase_car += 2 * PI * car_freq / sample_rate;
output = sin(phase_car + mod);
```

### 15.7.5 FM Sound Design: Bells, Basses, Electric Pianos, Percussion

- **Bells/Chimes:** High modulation index, non-integer ratios
- **Electric Piano:** 1:1, 2:1 ratios, short operator envelopes, feedback on carrier
- **Basses:** Lower index, 1:1 or subharmonic ratios, envelope for pluck
- **Percussion:** Use noise operator or self-feedback, fast decay

---

## 15.8 Wavetable Synthesis

### 15.8.1 Wavetable Concepts: Tables, Interpolation, Morphing

- **Wavetable:** Set of single-cycle waveforms (tables), can morph or fade between them
- **Playback:** Move through the table at a rate proportional to pitch; position in table defines timbre
- **Interpolation:** Linear, Hermite, or spline interpolation for smooth wavetable scan

### 15.8.2 Table Construction: Single-Cycle Waves, Multisample, User Drawn

- **Single-Cycle:** Each table holds one repeating period of a waveform (sine, square, custom)
- **Multisample:** Tables for different notes/ranges to reduce aliasing
- **User Drawn:** Some synths allow freehand drawing or import of waveforms

### 15.8.3 Wavetable Playback: Position, Keytracking, Interpolation

- **Table Position:** Index within the wavetable set; can be modulated for evolving timbre
- **Keytracking:** Use different tables at different pitches for consistent sound quality
- **Interpolation:** Blends between adjacent tables for smooth morph

#### 15.8.3.1 Wavetable Playback Pseudocode

```c
table_idx = (position * (num_tables-1));
low = floor(table_idx);
high = ceil(table_idx);
frac = table_idx - low;
output = (1-frac)*table[low][sample_pos] + frac*table[high][sample_pos];
```

### 15.8.4 Wavetable Modulation: LFO, Envelope, Morph, Sync

- **LFO:** Sweep table position for movement
- **Envelope:** Morph through tables as note evolves
- **Sync:** Restart table at sync points for classic “hard sync” effects
- **Performance:** Mod wheel, velocity, aftertouch mapped to table position

### 15.8.5 Wavetable Engines in Hardware and Software

- **Classic:** PPG Wave, Waldorf Microwave, Ensoniq Mirage
- **Modern:** Waldorf Blofeld, ASM Hydrasynth, Arturia Pigments, Serum, Vital

---

## 15.9 Granular Synthesis

### 15.9.1 Granular Basics: Grains, Density, Size, Envelope

- **Granular Synthesis:** Plays back audio as many small grains (5–100ms), layered for complex textures
- **Grain Parameters:**
  - **Size:** Duration of each grain
  - **Density:** Number of grains per second
  - **Envelope:** Shape of each grain (fade in/out, window)
  - **Pitch/Position:** Each grain can sample any part of the source

### 15.9.2 Granular Playback: Time-Stretch, Pitch-Shift, Scrub

- **Time-Stretch:** Change rate at which grains scan through source, independent of pitch
- **Pitch-Shift:** Play grains faster/slower, or transpose each
- **Scrub:** Real-time movement of playhead through source sample

### 15.9.3 Real-Time Granular Engines: Live Audio, Streaming, Slicing

- **Live Granular:** Process incoming audio in real time (e.g., Clouds, GR-1)
- **Streaming:** Stream grains from long samples (disk/SD)
- **Slicing:** Chop input into grains on the fly, rearrange or randomize for variation

### 15.9.4 Granular Sound Design: Clouds, Textures, Glitch, Ambient

- **Clouds:** Dense overlapping grains for pads, ambient
- **Glitch:** Sparse, randomized grains, stutter FX
- **Pitch/Time FX:** Granular is ideal for time-stretch, freeze, reverse, harmonic drones

---

## 15.10 Additive Synthesis

### 15.10.1 Additive Theory: Harmonics, Partials, Amplitude/Phase

- **Additive Synthesis:** Build sound by adding many sine waves (partials), each with independent amplitude, frequency, and phase
- **Partial:** Individual sine wave, may be harmonic (integer multiple of fundamental) or inharmonic

### 15.10.2 Additive Engine Architecture: Sine Banks, FFT, Resynthesis

- **Sine Bank:** Array of oscillators, one per partial (can be hundreds)
- **FFT-Based:** Analyze spectrum of sample, reconstruct with additive engine (resynthesis)
- **Control:** Envelope and modulation for each partial; often grouped for efficiency

### 15.10.3 Control: Envelopes, Spectral Morph, User Editing

- **Envelope:** Per-partial, per-group, or global amplitude envelope
- **Spectral Morph:** Crossfade between spectra, sweep through harmonic structures
- **User Editing:** Graphical tools to draw, copy, randomize, or import spectra

### 15.10.4 Additive Sound Design: Organs, Bells, Digital Pads

- **Organs:** Drawbar or harmonic sliders
- **Bells/Metals:** Inharmonic partials, time-varying amplitude
- **Pads:** Slow-moving spectra, morphing between shapes

---

## 15.11 Physical Modeling Synthesis

### 15.11.1 Physical Modeling Overview: What, Why, How

- **Physical Modeling:** Simulates how real instruments produce sound, using math/physics (strings, air columns, membranes)
- **Why:** Realistic, expressive, dynamic sound with small memory footprint

### 15.11.2 Simple Models: Karplus-Strong, Plucked String, Drum Membrane

- **Karplus-Strong:** Short delay line with feedback and filter simulates plucked string
- **Drum Membrane:** 2D grids of interconnected nodes (mass-spring), or modal synthesis (sum of resonant modes)

#### 15.11.2.1 Karplus-Strong Pseudocode

```c
buffer[N]; // N = delay length = pitch
for each sample:
    out = buffer[read_idx];
    buffer[write_idx] = (out + buffer[read_idx+1]) * 0.5 * decay;
    read_idx = (read_idx+1) % N;
    write_idx = (write_idx+1) % N;
```

### 15.11.3 Advanced Models: Waveguide, Mass-Spring, Modal, Finite Element

- **Waveguide:** Models wave propagation/reflection in tubes/strings (used in Yamaha VL1, Korg Prophecy)
- **Mass-Spring:** Simulates physical objects as points (masses) connected by springs; can model complex shapes
- **Modal Synthesis:** Sum of resonators, each with its own frequency/decay (good for bells, percussion)
- **Finite Element:** Numerical solution for complex objects; rare in real-time synths

### 15.11.4 Physical Modeling Sound Design: Strings, Winds, Percussion, Hybrid

- **Strings:** Bowed, plucked, struck, with position and force parameters
- **Winds:** Reed, tube, mouthpiece, breath, pitch bend (embouchure)
- **Percussion:** Drum heads, mallets, membranes, stick position
- **Hybrid:** Combine physical model with samples or subtractive for realism and flexibility

---

## 15.12 Hybrid Synthesis

### 15.12.1 Combining Engines: PCM+Analog, FM+Wavetable, Additive+Granular

- **PCM+Analog:** Sampled attacks, analog sustain (Korg M1, JD-800)
- **FM+Wavetable:** Use FM operators with wavetables as source, for richer spectra (Waldorf Quantum, Arturia Pigments)
- **Additive+Granular:** Additive control over grains, morphing and spectral filtering

### 15.12.2 Hybrid Signal Routing, Layering, and Modulation

- **Layering:** Stack engines (e.g., sample+FM+analog) for thick, rich sounds
- **Routing:** Parallel or serial processing, cross-modulation between engines
- **Modulation:** Macro controls affect multiple engine types for dynamic performance

### 15.12.3 Hybrid Synthesis in Famous Workstations

- **Korg Kronos:** Multiple engines (PCM, analog, FM, physical model)
- **Roland Fantom:** PCM, analog modeling, sample playback, VA, partials
- **Kurzweil K2/K2700:** VAST engine (variable architecture, signal routing, multi-layer)

---

## 15.13 Advanced Modulation, Macro, and Performance Control

### 15.13.1 Modulation Sources: LFO, Envelope, Step Seq, MIDI, CV, Random

- **LFO:** Multiple shapes, sync to tempo, phase offset, random
- **Envelope:** Multiple per voice, assignable to pitch, filter, amp, FX, table position
- **Step Sequencer:** Sequence parameter changes, steps per beat, per voice or global
- **MIDI/CV:** Mod wheel, aftertouch, velocity, MPE, external CV (modular)
- **Random:** Sample & hold, smoothed noise, chaos, probability

### 15.13.2 Modulation Matrix: Routing, Depth, Polarity, Curves

- **Matrix:** Assign any source to any destination (unlimited or fixed slots)
- **Depth:** Sets modulation amount (positive/negative)
- **Polarity:** Invert or unipolar/bipolar response
- **Curves:** Linear, exponential, custom mapping for expressive depth

#### 15.13.2.1 Mod Matrix Data Structure Example

```c
typedef struct {
    ModSource src;
    ModTarget dst;
    float depth;
    CurveType curve;
} ModRoute;
```

### 15.13.3 Macro Controls: Assign, Morph, Scene, Mod Wheel, XY Pad

- **Macro:** One control moves multiple parameters (e.g., “Timbre,” “Intensity”)
- **Morphing:** Interpolate between parameter sets (patch A–B), scene changes
- **Performance Controls:** Mod wheel, ribbon, XY pad, external MIDI/CC, aftertouch

### 15.13.4 Performance Features: Polyphonic Modulation, MPE, Aftertouch

- **Polyphonic Mod:** Per-note modulation, independent LFO/envelope per voice
- **MPE (MIDI Polyphonic Expression):** Per-note pitch bend, aftertouch, CC (ROLI, LinnStrument)
- **Aftertouch:** Channel or polyphonic, assignable to any parameter

### 15.13.5 Synthesis UI: Patch Editing, Visualization, Learn Modes

- **Patch Editing:** Parameter pages, quick assign, randomize/init, compare
- **Visualization:** Oscilloscope, spectrum, modulation path overlays
- **Learn Modes:** Touch target, move controller to assign modulation
- **Beginner UI:** Tooltips, wizards, preset templates, undo/redo

---

## 15.14 Synthesis Engine Optimization and Integration

### 15.14.1 DSP Load, Polyphony, Voice Stealing, Priority

- **DSP Load:** Monitor CPU use, optimize “hot” code (SIMD, fixed-point, lookup tables)
- **Polyphony:** Limit per patch, dynamic allocation, user override
- **Voice Stealing:** Choose which voice to release (oldest, quietest, priority)
- **Priority:** High for lead, melody; low for background, FX

### 15.14.2 Memory, Tables, and Data Structures

- **Tables:** Precompute waveforms, envelopes, filter coefficients for speed
- **Data Structures:** Efficient per-voice state, minimal cache misses
- **Memory Management:** Allocate voices, tables, buffers statically for reliability

### 15.14.3 Integration with Sequencer, FX, and Sampling Engines

- **Sequencer:** Trigger notes/events, parameter locks, automation
- **FX Engine:** Send synth output through FX chain or insert
- **Sampler:** Layer with or modulate by samples, granular engines

### 15.14.4 Preset Management, Patch Morphing, and Randomization

- **Preset:** Save/load all engine state; meta-data for search/tagging
- **Morphing:** Smooth interpolation between two or more presets
- **Randomization:** Smart random (keep musical/usable), randomize sections (osc only, env only, FX only)

### 15.14.5 Real-Time Performance, Low-Latency, and Glitch Handling

- **Low-Latency:** Minimize processing/buffer size, prioritize real-time threads
- **Glitch Handling:** Drop polyphony, freeze voices, or mute if overloaded
- **Startup/Resume:** Fast patch changes, seamless scene/preset switching

---

## 15.15 Glossary and Reference Tables

| Term         | Definition                                         |
|--------------|----------------------------------------------------|
| FM           | Frequency Modulation synthesis                     |
| Operator     | Oscillator+envelope unit in FM synth               |
| Algorithm    | Operator routing/network in FM                     |
| Wavetable    | Array of single-cycle waveforms                    |
| Granular     | Synthesis from small overlapping grains            |
| Additive     | Synthesis by summing sine/partials                 |
| Physical Mod | Synthesis modeling real-world physics              |
| Macro        | One control mapped to multiple synth parameters    |
| Polyphony    | Maximum simultaneous notes/voices                  |
| MPE          | MIDI Polyphonic Expression (per-note control)      |

### 15.15.1 Table: Synthesis Engine Comparison

| Engine      | Strengths             | Weaknesses         | Example Sounds         |
|-------------|----------------------|--------------------|-----------------------|
| Subtractive | Classic, warm, intuitive | Can be limited   | Brass, synths, basses |
| FM          | Complex, evolving, expressive | Difficult to program | Rhodes, bells, chimes |
| Wavetable   | Animated, digital, morphing | Can sound cold  | Pads, motion, leads   |
| Granular    | Textures, stretch, glitch | CPU intensive    | Ambience, stutter, FX |
| Additive    | Detailed, flexible, clean  | Hard to control  | Organ, bells, pads    |
| Physical Mod| Realistic, expressive      | CPU, complex     | Strings, winds, pluck |
| Hybrid      | Versatile, modern         | Complex to design| Modern workstations   |

### 15.15.2 Table: FM Ratios and Sound Examples

| Carrier:Modulator | Ratio | Example Sound       |
|-------------------|-------|--------------------|
| 1:1               | 1     | Electric piano     |
| 2:1               | 2     | Bass, bell         |
| 3:2               | 1.5   | Inharmonic bell    |
| 4:1               | 4     | Percussive, metal  |
| 1:3               | 0.33  | Strange, metallic  |

### 15.15.3 Table: Granular Parameters

| Parameter    | Range      | Effect                           |
|--------------|------------|----------------------------------|
| Grain Size   | 5–100 ms   | Small = glitchy, large = smooth  |
| Density      | 1–100/sec  | Sparse = stutter, dense = pad    |
| Position     | 0–sample   | Which part of audio is played    |
| Pitch        | ±24 semitones | Transpose grain               |
| Envelope     | Sine, Hann | Shape of grain (attack/release)  |

### 15.15.4 Table: Synthesis UI Widgets for Beginners

| Widget      | Function                           |
|-------------|------------------------------------|
| Knob        | Adjust parameter (freq, filter, env)|
| Button      | Enable/disable modulation            |
| Matrix      | Assign modulation sources to targets |
| Oscilloscope| View waveform/osc output            |
| Spectrum    | Visualize harmonics/partials         |
| Macro       | Control many params with one knob    |
| XY Pad      | Control 2 params at once             |
| Preset      | Save/recall patch                    |

---

**End of Part 2 and Chapter 15: Synthesis Engines — Subtractive, FM, Wavetable, Physical Modeling, and More.**

**You now have a comprehensive, beginner-friendly, and detailed reference for every major synthesis method, with code, diagrams, sound design, and practical advice for workstation projects.  
If you want to proceed to the next chapter (Analog Boards: Mixing, Filtering, and Output) or want even deeper explanation on any synthesis engine, just say so!**