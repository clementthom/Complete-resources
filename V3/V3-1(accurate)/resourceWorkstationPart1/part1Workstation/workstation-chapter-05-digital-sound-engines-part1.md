# Workstation Chapter 05: Digital Sound Engines — PCM, Wavetable, FM, Additive, Sampling (Part 1)
## Fundamentals of Digital Sound Synthesis and Sampling

---

## Table of Contents

1. Introduction: Why Digital Sound Engines Matter
2. Digital Audio Basics
   - What is a Digital Sound Engine?
   - Digital vs. Analog Sound Generation
   - Key Terms: Sample Rate, Bit Depth, Aliasing, Nyquist
3. PCM Synthesis (Pulse Code Modulation)
   - PCM Theory
   - Simple PCM Playback
   - Building a PCM Voice Module
   - Polyphony, Mixing, and Buffering
   - Handling Loop Points and Release Tails
   - Practical PCM Example (C Code)
4. Wavetable Synthesis
   - What is a Wavetable?
   - Classic and Modern Wavetable Synths
   - Wavetable Data Structures
   - Interpolation and Morphing
   - Anti-aliasing
   - Wavetable Engine Example (C Code)
5. Practice Section 1: Implementing PCM and Wavetable Basics
6. Exercises

---

## 1. Introduction: Why Digital Sound Engines Matter

Digital sound engines are the “heart” of modern workstations—from classic samplers like the Emulator and Fairlight, to modern wavetable, FM, and sample-based synths.

A digital sound engine:
- Generates, processes, and mixes audio entirely in the digital domain (as streams of numbers).
- Enables polyphony, layering, sample playback, and complex modulation.
- Can emulate classic analog sounds and create entirely new textures.

**You cannot design a capable workstation without understanding digital audio basics and synthesis engine architectures.**

---

## 2. Digital Audio Basics

### 2.1 What is a Digital Sound Engine?

- A **digital sound engine** is a collection of algorithms and data structures that produce and process audio signals using a CPU or DSP.
- It takes musical events (notes, velocities, controllers), generates sample values, and outputs a digital audio stream.

### 2.2 Digital vs. Analog Sound Generation

- **Analog:** Sound created by manipulating electrical voltages/currents (oscillators, filters, VCAs).
- **Digital:** Sound created by mathematical models, lookup tables, or sample playback, then converted to analog by a DAC.

**Pros of Digital:**
- Massive polyphony, flexibility, perfect recall, complex modulation, and effects.
- Easy to store, edit, and recall sounds (patches).
- Can emulate analog or go beyond.

**Cons:**
- Aliasing, quantization noise, and CPU load.
- Some prefer the “character” of analog imperfections.

### 2.3 Key Terms

#### Sample Rate

- Number of samples per second (Hz).
- Common: 44,100 Hz (CD), 48,000 Hz (pro audio), up to 192,000 Hz.

#### Bit Depth

- Number of bits per sample (8, 12, 16, 24, 32).
- Higher = lower noise floor, more dynamic range.

#### Aliasing

- Undesired artifacts when signals above half the sample rate (Nyquist) are present.
- Must be filtered or avoided (see anti-aliasing).

#### Nyquist Theorem

- Maximum frequency you can represent is half the sample rate (`f_max = sample_rate / 2`).

---

## 3. PCM Synthesis (Pulse Code Modulation)

### 3.1 PCM Theory

- **PCM**: The most basic form of digital audio, each sample is a number (voltage, at a moment in time).
- Used for sample playback, drum machines, classic ROMplers.

**PCM File Structure:**
- Header (WAV, AIFF, RAW)
- Data: Array of signed or unsigned integers/floats

### 3.2 Simple PCM Playback

**Algorithm:**
1. Read audio file (WAV/RAW) into buffer.
2. For each output sample, read from buffer, convert to float (if needed).
3. Output to DAC or audio buffer.

**Simplest C code:**
```c
int16_t *pcm_data; // loaded from file
size_t pcm_length;
float output_sample = pcm_data[sample_index] / 32768.0f; // -1.0 to 1.0 float
```

### 3.3 Building a PCM Voice Module

**PCM Voice Structure:**
```c
typedef struct {
    int16_t *data;
    size_t length;
    size_t pos;      // Current sample index
    float gain;
    int active;
} PCMVoice;
```

#### Voice Playback Logic

- On Note On: set `active=1`, `pos=0`
- On Note Off: optional, for one-shot or looped samples
- On each audio frame:
    - If `active`, output sample at `pos`, multiply by gain, increment `pos`
    - If `pos >= length`, set `active=0` (voice ends)

### 3.4 Polyphony, Mixing, and Buffering

- Multiple PCMVoice instances for polyphony.
- Mix: sum all active voices, then divide (normalize) to prevent clipping.

```c
float mix = 0.0f;
for (int i = 0; i < NUM_VOICES; ++i) {
    if (voices[i].active)
        mix += voices[i].data[voices[i].pos++] / 32768.0f * voices[i].gain;
}
// Normalize if necessary
mix /= NUM_ACTIVE_VOICES;
```

### 3.5 Handling Loop Points and Release Tails

- Many samples loop (sustain) and have release tails (sample continues after note-off).
- Store loop start/end in voice struct.
- On note-off, switch to release region or ramp-down gain.

```c
typedef struct {
    int16_t *data;
    size_t length;
    size_t pos;
    size_t loop_start, loop_end;
    int looping;
    int active;
    // ... other fields
} PCMVoice;
```

### 3.6 Practical PCM Example (C Code)

**Basic PCM Voice Playback**
```c
typedef struct {
    int16_t *data;
    size_t length;
    size_t pos;
    float gain;
    int active;
} PCMVoice;

void pcm_voice_start(PCMVoice *v, int16_t *data, size_t len, float gain) {
    v->data = data;
    v->length = len;
    v->pos = 0;
    v->gain = gain;
    v->active = 1;
}

float pcm_voice_next(PCMVoice *v) {
    if (!v->active) return 0.0f;
    if (v->pos >= v->length) {
        v->active = 0;
        return 0.0f;
    }
    float sample = v->data[v->pos++] / 32768.0f * v->gain;
    return sample;
}
```

---

## 4. Wavetable Synthesis

### 4.1 What is a Wavetable?

- A fixed or variable-length table storing one or more cycles of a waveform.
- Each note is generated by “reading” through the table at the right rate.
- Can morph between waves, scan tables, or interpolate for evolving sounds.

**Classic: PPG, Waldorf Microwave, Korg Wavestate, Serum, etc.**

### 4.2 Classic and Modern Wavetable Synths

- **PPG Wave**: Early digital wavetable, limited RAM, creative use of small tables
- **Waldorf Microwave/Bloch**: Multi-segment morphing, high-res tables
- **Modern VSTs:** Serum, Massive, many others—complex morphing, huge tables

### 4.3 Wavetable Data Structures

**One Table, One Wave:**
```c
#define WAVETABLE_SIZE 2048
float wavetable[WAVETABLE_SIZE]; // one cycle of a waveform
```

**Multiple Tables (for morphing):**
```c
#define NUM_TABLES 64
float wavetables[NUM_TABLES][WAVETABLE_SIZE];
```

### 4.4 Interpolation and Morphing

- To avoid stepping/aliasing, interpolate between table values.
- Linear interpolation is simplest:
```c
// Assume phase is between 0 and WAVETABLE_SIZE
int idx = (int)phase;
float frac = phase - idx;
float sample = wavetab[idx] * (1.0f - frac) + wavetab[(idx+1)%WAVETABLE_SIZE] * frac;
```

- For morphing, interpolate between two tables:
```c
float sample = tableA[idx] * (1.0f - morph) + tableB[idx] * morph;
```

### 4.5 Anti-aliasing

- Aliasing occurs when wavetables are read too fast (high notes).
- Solution: Use bandlimited tables (different tables per octave), or low-pass filter output.

### 4.6 Wavetable Engine Example (C Code)

```c
typedef struct {
    float *table;     // pointer to wavetable data
    float phase;      // current phase (0..WAVETABLE_SIZE)
    float phase_inc;  // phase increment per sample (freq/sample_rate * size)
    float gain;
} WTVoice;

void wt_voice_start(WTVoice *v, float *table, float freq, float gain, float sample_rate) {
    v->table = table;
    v->phase = 0.0f;
    v->phase_inc = freq * WAVETABLE_SIZE / sample_rate;
    v->gain = gain;
}

float wt_voice_next(WTVoice *v) {
    int idx = (int)v->phase;
    float frac = v->phase - idx;
    float s0 = v->table[idx];
    float s1 = v->table[(idx+1)%WAVETABLE_SIZE];
    float sample = s0 * (1.0f - frac) + s1 * frac;
    v->phase += v->phase_inc;
    if (v->phase >= WAVETABLE_SIZE) v->phase -= WAVETABLE_SIZE;
    return sample * v->gain;
}
```

---

## 5. Practice Section 1: Implementing PCM and Wavetable Basics

### 5.1 PCM Player

- Load a short WAV file (mono, 16-bit, 44.1kHz) into a buffer
- Implement a PCMVoice struct and playback logic
- Add polyphony by instantiating multiple voices and mixing results

### 5.2 Wavetable Oscillator

- Generate a sine table (2048 samples)
- Implement a WTVoice struct and oscillator function
- Play different notes by changing `phase_inc` according to frequency
- Add a simple morphing oscillator (crossfade two wavetables)

---

## 6. Exercises

1. **PCM Basics**
   - Write C code to load a 16-bit mono WAV file into a buffer (hint: skip the WAV header, read data into `int16_t *`).

2. **Polyphonic PCM Synth**
   - Implement a polyphonic PCM synth with 8 voices. Trigger voices on demand, mix to a single output buffer.

3. **Wavetable Generation**
   - Write code to fill a wavetable with a sine wave, a sawtooth, and a square wave. Plot the results if possible.

4. **Wavetable Oscillator**
   - Write a function that plays a note at any frequency using your wavetable.

5. **Morphing Tables**
   - Implement a function that morphs between two wavetables by crossfading.

6. **Aliasing Experiment**
   - Play your wavetable at high frequencies (above Nyquist/2). Listen for aliasing artifacts. Try low-pass filtering the output.

7. **Loop Points**
   - Modify your PCMVoice to support looping a region of the sample (settable loop start/end).

8. **Release Tails**
   - Add support for a “release” segment after note-off (sample continues playing at lower gain/fades out).

9. **Audio Buffering**
   - Write a function that fills an output buffer (e.g., 256 samples) by mixing all active voices.

---

**End of Part 1.**  
_Part 2 will cover FM synthesis, additive synthesis, advanced sampling, multisamples, pitch shifting, time stretching, and more, with detailed C implementations and project-ready code._
