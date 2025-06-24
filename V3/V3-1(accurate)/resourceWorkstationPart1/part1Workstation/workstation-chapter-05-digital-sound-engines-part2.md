# Workstation Chapter 05: Digital Sound Engines — PCM, Wavetable, FM, Additive, Sampling (Part 2)
## FM Synthesis, Additive Synthesis, Advanced Sampling, Multisamples, Pitch Shifting, Time Stretching

---

## Table of Contents

1. FM Synthesis (Frequency Modulation)
   - Introduction to FM Synthesis
   - Operators, Algorithms, and Envelopes
   - FM Data Structures
   - Basic FM Engine: Algorithms and C Implementation
   - Yamaha DX7 and Beyond
   - Practice: Implementing a 2-Operator FM Synth
2. Additive Synthesis
   - What is Additive Synthesis?
   - Sine Bank Synthesis
   - Partial Control and Envelopes
   - Data Structures for Additive Engines
   - Practice: Sine Bank Synth in C
3. Advanced Sampling
   - Multisamples and Keymaps
   - Velocity Layers and Round-Robin
   - Sample Zones, Crossfades, and Dynamic Mapping
   - Sample Playback with Pitch Shifting
   - Time Stretching and Formant Correction
   - Practice: Multisample Engine in C
4. Pitch Shifting and Time Stretching
   - Introduction and Applications
   - Time-Domain Algorithms (Overlap-Add, WSOLA)
   - Frequency-Domain Algorithms (Phase Vocoder)
   - Formant Preservation and Smart Algorithms
   - Practical Limitations on Embedded Hardware
   - Practice: Simple Pitch Shift/Time Stretch in C
5. Practice Section 2: Implementing FM, Additive, and Sampler Basics
6. Exercises

---

## 1. FM Synthesis (Frequency Modulation)

### 1.1 Introduction to FM Synthesis

- **FM Synthesis** (Frequency Modulation) creates complex waveforms by modulating the frequency of one oscillator (the carrier) with another (the modulator).
- Famous in the Yamaha DX7, TX81Z, and many modern synthesizers.
- Capable of metallic, bell-like, and evolving digital timbres.

### 1.2 Operators, Algorithms, and Envelopes

- **Operator:** A sine oscillator with its own envelope and gain.
- **Algorithm:** The wiring diagram of how operators modulate each other (which is carrier, which is modulator, serial/parallel, etc.).
- **Envelope:** Controls amplitude over time (attack, decay, sustain, release).

**Basic FM block:**
```
Modulator ----> Carrier ----> Output
    |            |
 Envelope     Envelope
```

### 1.3 FM Data Structures

```c
typedef struct {
    float freq;         // Frequency (Hz)
    float phase;        // Phase (radians)
    float amp;          // Amplitude
    Envelope env;       // ADSR envelope
} FMOperator;

typedef struct {
    FMOperator carrier;
    FMOperator modulator;
    float mod_index;    // Modulation index (depth)
    int active;
} FMVoice;
```

### 1.4 Basic FM Engine: Algorithms and C Implementation

**FM Synthesis Core Equation:**
```
output = carrier_amp * sin(2π * carrier_freq * t + mod_index * sin(2π * mod_freq * t))
```
- `mod_index` determines how much the modulator influences the carrier.

**C Pseudocode for One Sample:**
```c
float mod = sinf(2.0f * M_PI * mod_freq * t) * mod_index;
float sample = sinf(2.0f * M_PI * carrier_freq * t + mod) * carrier_env;
```

### 1.5 Yamaha DX7 and Beyond

- 6 operators, 32 algorithms (chains/trees of operator connections)
- Each operator has envelope, rate scaling, velocity sensitivity
- Classic "electric piano", bell, and metallic sounds

**Modern FM synths:** Add feedback, non-sine waveforms, multi-stage envelopes

---

## 2. Additive Synthesis

### 2.1 What is Additive Synthesis?

- Builds complex sounds by summing many sine waves (partials or harmonics), each with its own amplitude and frequency.
- “If you can draw it, you can synthesize it” — any periodic sound can, in theory, be broken down into a sum of sines (Fourier theorem).

### 2.2 Sine Bank Synthesis

- Each partial/harmonic is a sine oscillator.
- The sum of all active oscillators is the output.

**Equation:**
```
output = sum_{n=1}^N (amp_n * sin(2π * freq_n * t + phase_n))
```

### 2.3 Partial Control and Envelopes

- Each sine may have its own envelope, detune, or amplitude.
- For realism and expressiveness, partials may shift or morph over time.

### 2.4 Data Structures for Additive Engines

```c
#define MAX_PARTIALS 64

typedef struct {
    float freq;
    float amp;
    float phase;
    Envelope env;
} Partial;

typedef struct {
    Partial partials[MAX_PARTIALS];
    int num_partials;
    int active;
} AdditiveVoice;
```

### 2.5 Practice: Sine Bank Synth in C

**Additive Voice Next Sample:**
```c
float additive_voice_next(AdditiveVoice *v, float t) {
    float sum = 0.0f;
    for (int i = 0; i < v->num_partials; ++i) {
        float env = envelope_next(&v->partials[i].env);
        sum += v->partials[i].amp * env *
               sinf(2.0f * M_PI * v->partials[i].freq * t + v->partials[i].phase);
    }
    return sum;
}
```

---

## 3. Advanced Sampling

### 3.1 Multisamples and Keymaps

- **Multisample:** Set of samples mapped to different keys (zones) and velocities.
- Each key/velocity range triggers a different sample (e.g., piano, drums).
- Large sample sets are organized into keymaps with zone definitions.

**Data Structure:**
```c
#define NUM_KEYS 128
#define NUM_VELOCITIES 8

typedef struct {
    int16_t *data;
    size_t length;
    size_t loop_start, loop_end;
    int looping;
} SampleZone;

typedef struct {
    SampleZone *keymap[NUM_KEYS][NUM_VELOCITIES]; // Pointers to sample zones
} MultisampleInstrument;
```

### 3.2 Velocity Layers and Round-Robin

- **Velocity Layers:** Multiple samples per key, triggered depending on velocity (for expressive instruments).
- **Round-Robin:** Rotates through a set of samples to avoid “machine gun” effect (especially for drums).

### 3.3 Sample Zones, Crossfades, and Dynamic Mapping

- **Zone:** Sample assigned to a region of keys/velocities.
- **Crossfade:** Smooth transitions between zones/layers for realistic playing.
- **Dynamic Mapping:** Change sample zones in real time (e.g., via mod wheel).

### 3.4 Sample Playback with Pitch Shifting

- To play a sample at different pitches, resample by changing playback increment:
```c
float pitch_ratio = powf(2.0f, (midi_note - sample_root_note) / 12.0f);
sample_pos += pitch_ratio;
```
- Use interpolation (linear or cubic) for smooth sound.

### 3.5 Time Stretching and Formant Correction

- **Time Stretching:** Change duration without affecting pitch (for loops, tempo sync).
- **Formant Correction:** Maintains natural “color” of sound (avoids “chipmunk” effect).

---

## 4. Pitch Shifting and Time Stretching

### 4.1 Introduction and Applications

- **Pitch Shifting:** Change pitch up or down, keep duration constant (for harmonizers, effects).
- **Time Stretching:** Change speed/duration, keep pitch constant (for loop sync, DJ, etc.).

### 4.2 Time-Domain Algorithms

#### Overlap-Add (OLA)

- Split audio into overlapping frames/windows.
- Shift and overlap frames to stretch/compress duration.

#### WSOLA (Waveform Similarity Overlap-Add)

- Like OLA, but aligns frames using waveform similarity to avoid artifacts.
- Good for moderate stretches (±25%).

### 4.3 Frequency-Domain Algorithms

#### Phase Vocoder

- Convert to frequency domain (FFT), manipulate bins, then resynthesize.
- Can stretch/compress and shift pitch independently.
- More CPU/memory, but higher quality.

### 4.4 Formant Preservation and Smart Algorithms

- Simple pitch shifting raises formants (chipmunk effect).
- Algorithms like PSOLA, elastique, and Melodyne attempt to preserve formants.
- On embedded, use lighter algorithms (formant shifting may be limited).

### 4.5 Practical Limitations on Embedded Hardware

- Time-domain: less CPU, moderate quality, real time on microcontrollers.
- Frequency-domain: more CPU/RAM, best for ARM Cortex/Raspberry Pi-class systems.

---

## 5. Practice Section 2: Implementing FM, Additive, and Sampler Basics

### 5.1 FM Voice

- Implement a 2-operator FM synth: one carrier, one modulator, both with envelopes.
- Map MIDI note to carrier frequency, modulator as a ratio (1.5x, 2x, etc.).
- Add modulation index as a parameter.

### 5.2 Additive Synth

- Implement a sine bank engine with at least 8 partials.
- Assign amplitude/envelope for each partial.
- Allow user to draw/edit partial amplitudes for custom waveforms.

### 5.3 Multisample Engine

- Create a keymap with at least 4 sample zones (e.g., bass, mid, high, velocity).
- Implement round robin and simple crossfade between velocity layers.
- Support pitch shifting by changing sample increment (use linear interpolation).

### 5.4 Pitch Shifting

- Implement a basic OLA pitch/time shifter.
- Bonus: Try a simple phase vocoder using an FFT library.

---

## 6. Exercises

1. **FM Synthesis Basics**
   - Write C code for a 2-operator FM synth. Trigger different notes and modulation indices. Output a buffer and plot or listen.

2. **FM Algorithm Variations**
   - Modify your FM engine to support parallel (both operators to output) and serial (modulator into carrier) algorithms.

3. **Additive Synthesis**
   - Implement a 16-partial sine bank. Experiment with harmonic and inharmonic spectra.

4. **Multisample Keymaps**
   - Write code to map MIDI notes to different sample zones. Trigger samples and crossfade between velocity layers.

5. **Round Robin Sampler**
   - Add round-robin support to your keymap so repeated notes rotate through multiple samples.

6. **Pitch Shifting**
   - Implement a simple pitch shifter using OLA. Test shifting up and down by a few semitones.

7. **Time Stretching Experiment**
   - Implement a WSOLA or phase vocoder time stretcher using an FFT library (e.g., KissFFT, FFTW). Stretch loops to half/double speed and listen for artifacts.

8. **Formant Correction (Research)**
   - Research how formant preservation works in commercial pitch shifters. Summarize one method and discuss how it might be adapted for embedded use.

9. **Performance Measurement**
   - Profile CPU usage of your sampler, FM, and additive engines. Test on PC and embedded hardware. What are the bottlenecks?

10. **Audio Quality Testing**
    - For each engine, listen and/or plot output at various pitches and speeds. Document aliasing, artifacts, and suggest improvements.

---

**End of Part 2.**  
_Part 3 will cover digital effects, mixing, layering, modulation matrices, and practical real-world digital audio engine design for your workstation._
