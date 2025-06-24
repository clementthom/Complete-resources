# Workstation Synth Project – Document 5  
## Digital Audio Principles and PC Testing

---

### Table of Contents

1. What is Sound? (Waves, Frequency)
2. Digital Audio: Sampling and Bit Depth
3. Audio Buffers and Data Types in C
4. Generating Waves: Sine, Square, Saw, Triangle
5. Playing Sound on Your PC (PortAudio or SDL2)
6. Polyphony and Mixing
7. Hands-On: Outputting a Chord
8. Exercises

---

## 1. What is Sound?

- Vibrations of air, measured in Hertz (Hz)
- Sine wave: pure tone; square/saw: rich in harmonics

---

## 2. Digital Audio

- **Sample rate:** Number of samples per second (44.1kHz = CD)
- **Bit depth:** Number of levels per sample (16/24 bits)

---

## 3. Audio Buffers in C

```c
#define SAMPLE_RATE 44100
short buffer[SAMPLE_RATE];
```
- 16-bit PCM: -32768 to +32767

---

## 4. Generating Waves

```c
float sine(float phase) { return sinf(phase); }
float square(float phase) { return phase < M_PI ? 1.0f : -1.0f; }
```

---

## 5. Playing Sound on PC

- **PortAudio:** Cross-platform C audio library
- **SDL2:** Also works for simple audio

---

## 6. Polyphony and Mixing

- Multiple voices = sum signals, scale to prevent clipping

---

## 7. Hands-On: Outputting a Chord

- Write code to play C, E, G (three oscillators)
- Listen with PortAudio or output to `.wav`

---

## 8. Exercises

- Output a 440Hz sine for 1 second.
- Output a major triad (C, E, G).
- Try a sawtooth or triangle wave.

---

**Next:**  
*workstation_06_midi_input_and_keyboard_handling.md* — Getting notes and velocity from MIDI.

---