# Workstation Synth Project – Document 17  
## PCM and Wavetable Synth Engine

---

### Table of Contents

1. What is PCM? What is Wavetable Synthesis?
2. PCM Sample Playback: Theory and Practice
3. Wavetable Oscillators: Tables, Interpolation, and Looping
4. Voice Structure and Polyphony
5. Envelope and Filter Implementation
6. Building a Multitimbral Engine
7. Integrating with MIDI and UI
8. Memory Management for Large Samples
9. Hands-On: Play a Sample/Wave Table
10. Exercises

---

## 1. PCM and Wavetable Synthesis

- **PCM:** Playing back recorded audio samples (drums, pianos, etc.).
- **Wavetable:** Cycling through arrays of single-cycle waveforms.

---

## 2. PCM Sample Playback

- Load `.wav` or `.raw` files into memory.
- Step through array at proper rate for pitch.
- Handle looping, start/stop, and velocity.

---

## 3. Wavetable Oscillators

- Array of single-cycle waveforms, e.g., 256 samples each.
- Interpolate between table entries for smooth morphing.
- Use phase accumulator for position.

---

## 4. Voice Structure and Polyphony

```c
typedef struct {
  float phase, freq, amp;
  const int16_t *sample;
  int length;
  int active;
} Voice;
```
- Allocate array for each active voice.

---

## 5. Envelope and Filter

- ADSR: Attack, Decay, Sustain, Release
- Digital lowpass filter per voice or output

---

## 6. Multitimbral Engine

- Support for multiple programs/patches at once
- Channel or layer-based allocation

---

## 7. Integrating with MIDI and UI

- Note-on triggers sample/oscillator playback
- Patch selection via UI

---

## 8. Memory Management

- Use SD card/flash for large banks
- Stream samples if RAM is limited

---

## 9. Hands-On

- Load and play a PCM drum sample on key press
- Play a wavetable sweep via encoder or touch

---

## 10. Exercises

- Add velocity sensitivity to playback
- Implement voice stealing for polyphony
- Morph between two wavetables in real time

---

**Next:**  
*workstation_18_audio_buffer_management_and_dac.md* — Moving samples to analog audio.

---