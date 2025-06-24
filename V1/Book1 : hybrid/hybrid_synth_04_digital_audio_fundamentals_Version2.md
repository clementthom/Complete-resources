# Hybrid Synthesizer Project – Document 4
## Digital Audio Fundamentals

---

### Table of Contents

1. What is Sound? (Waves and Frequencies)
2. Analog vs Digital Audio
3. Sampling: Sample Rate and Bit Depth
4. Audio Data in C (Arrays and Samples)
5. Digital-to-Analog Conversion (DACs)
6. Aliasing and Anti-Aliasing
7. Polyphony and Mixing
8. Hands-On: Generating and Saving a Sine Wave in C
9. Exercises

---

## 1. What is Sound? (Waves and Frequencies)

Sound is a vibration of air, described as a wave with frequency (Hz) and amplitude (loudness).

---

## 2. Analog vs Digital Audio

- **Analog:** Smooth, continuous voltages (e.g., from a microphone).
- **Digital:** Discrete samples (numbers), e.g., 44100 per second.

---

## 3. Sampling: Sample Rate and Bit Depth

- **Sample rate:** Number of samples per second (e.g., 44100 Hz).
- **Bit depth:** How many bits per sample (e.g., 16-bit = 65536 levels).

---

## 4. Audio Data in C (Arrays and Samples)

```c
#define SAMPLE_RATE 44100
short buffer[SAMPLE_RATE]; // One second of mono audio at 16 bits/sample
```

---

## 5. Digital-to-Analog Conversion (DACs)

- DACs turn numbers (digital) into voltages (analog).
- Quality depends on sample rate, bit depth, and circuit design.

---

## 6. Aliasing and Anti-Aliasing

- **Aliasing:** High frequencies “fold” into lower ones if above half the sample rate.
- Use a lowpass filter (anti-aliasing) before/after conversion.

---

## 7. Polyphony and Mixing

- **Monophonic:** One note at a time.
- **Polyphonic:** Many notes (voices) at once, summed together.

```c
float mix = voice1 + voice2 + ...;
```
Scale to avoid clipping.

---

## 8. Hands-On: Generating and Saving a Sine Wave in C

```c
#include <stdio.h>
#include <math.h>
#define SAMPLE_RATE 44100
#define PI 3.1415926535

int main() {
    FILE *f = fopen("sine.raw", "wb");
    for (int i = 0; i < SAMPLE_RATE; i++) {
        float t = (float)i / SAMPLE_RATE;
        short sample = (short)(32767 * sinf(2 * PI * 440 * t));
        fwrite(&sample, sizeof(short), 1, f);
    }
    fclose(f);
    return 0;
}
```
Open `sine.raw` in Audacity as 44100 Hz, 16-bit PCM.

---

## 9. Exercises

- Change the frequency to 220 Hz and listen.
- Generate a triangle wave.
- Try mixing two different frequencies.

---

**Next:**  
*hybrid_synth_05_synthesis_algorithms_in_c.md* — Writing oscillators and envelopes in C.

---