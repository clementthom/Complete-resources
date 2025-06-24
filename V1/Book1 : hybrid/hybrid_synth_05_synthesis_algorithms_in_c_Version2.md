# Hybrid Synthesizer Project – Document 5
## Sound Synthesis Algorithms in C

---

### Table of Contents

1. What is a Digital Oscillator?
2. Sine, Square, Saw, and Triangle Waves
3. Wavetable Synthesis
4. Envelopes (ADSR)
5. Polyphony Manager (Allocating Voices)
6. Mixing and Output Scaling
7. Hands-On: Multi-Voice Synth in C (PC)
8. Exercises

---

## 1. What is a Digital Oscillator?

A function that outputs a value (sample) for a given phase or time.  
E.g., `sin(phase)`, or reading from a waveform table.

---

## 2. Sine, Square, Saw, and Triangle Waves

```c
float sine(float phase) { return sinf(phase); }
float square(float phase) { return phase < M_PI ? 1.0f : -1.0f; }
float saw(float phase) { return 2.0f * (phase / (2*M_PI)) - 1.0f; }
float triangle(float phase) { return 2.0f * fabsf(saw(phase)) - 1.0f; }
```
Phase advances by `2 * PI * freq / sample_rate` each sample.

---

## 3. Wavetable Synthesis

Store one cycle of a waveform in an array, read with interpolation.

---

## 4. Envelopes (ADSR)

Attack, Decay, Sustain, Release—controls amplitude over time.

```c
typedef struct { float a, d, s, r; float value; int state; } ADSR;
```

---

## 5. Polyphony Manager (Allocating Voices)

- Array of `Voice` structs.
- On note-on: find an inactive voice, assign note/freq.
- On note-off: release voice.

---

## 6. Mixing and Output Scaling

Sum all voices, divide by number of active voices or use a limiter to prevent clipping.

---

## 7. Hands-On: Multi-Voice Synth in C (PC)

Set up a struct for `Voice`, manage an array, and mix their output for playback.

---

## 8. Exercises

- Implement a 4-voice sawtooth synth.
- Add an ADSR envelope to each voice.
- Change the code to read from a wavetable.

---

**Next:**  
*hybrid_synth_06_realtime_audio_on_pc_portaudio.md* — Making your synth play in real time!

---