# Chapter 6: Oscillator Theory and Implementation (with DACs) – Part 2

---

## Table of Contents

7. Deep Code Walkthrough (PortAudio/PC)
    - What is PortAudio? Why use it?
    - Setting up PortAudio on PC/Linux
    - Writing a modular oscillator bank
    - Extensive commentary: every function, struct, and argument explained
    - Testing your oscillator code: listening and visualization
    - Adding polyphony and real-time parameter changes
8. Interfacing Digital Oscillators with DACs (Raspberry Pi)
    - DAC selection (bit depth, speed, interface type)
    - SPI, I2C, and parallel interfacing basics
    - Practical circuit: connecting a Pi to a DAC (PCM5102A, MCP4922, etc.)
    - Voltage scaling and output filtering (reconstruction filter)
    - Testing with oscilloscope and speakers
9. Advanced Topics
    - Hard sync, soft sync
    - FM, PM, and AM digital techniques
    - Detuning, drift, and analog modeling
    - Noise shaping and dithering for high fidelity

---

## 7. Deep Code Walkthrough (PortAudio/PC)

### 7.1 What is PortAudio? Why use it?

**PortAudio** is a free, cross-platform, open-source library for real-time audio input/output. It is ideal for synth prototyping on PC:
- Abstracts away hardware details.
- Low latency (important for synths).
- Works on Linux, Windows, and macOS.
- Easy to use from C.

### 7.2 Setting up PortAudio on PC/Linux

**Install PortAudio:**
- On Ubuntu/Debian:
    ```
    sudo apt-get install libportaudio2 portaudio19-dev
    ```
- On Solus:
    ```
    sudo eopkg install portaudio-devel
    ```

**Install on macOS:**
    ```
    brew install portaudio
    ```

**Linking in your Makefile:**
    ```
    gcc synth.c -o synth -lportaudio -lm
    ```

### 7.3 Writing a Modular Oscillator Bank

Below is a **comprehensive example** of a modular, hardware-inspired oscillator bank in C, using PortAudio for real-time output and the modular oscillator code from Part 1. This code is deeply commented for learning.

**oscillator.h** (same as before, but expanded for polyphony and parameter changes)

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
    // For FM, sync, etc., add more fields here
};

void osc_init(Oscillator* osc, OscillatorType type, float freq, float amp, float sr);
float osc_process(Oscillator* osc);
void osc_set_type(Oscillator* osc, OscillatorType type);
void osc_set_freq(Oscillator* osc, float freq);
void osc_set_amp(Oscillator* osc, float amp);
void osc_reset(Oscillator* osc);

#endif
```

**oscillator.c**

```c
#include "oscillator.h"
#include <math.h>
#include <stdlib.h>
#include <time.h>

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
    osc_set_type(osc, type);
}

void osc_set_type(Oscillator* osc, OscillatorType type) {
    osc->type = type;
    switch(type) {
        case OSC_SINE:     osc->waveform_func = sine_wave;    break;
        case OSC_SQUARE:   osc->waveform_func = square_wave;  break;
        case OSC_TRIANGLE: osc->waveform_func = triangle_wave;break;
        case OSC_SAW:      osc->waveform_func = saw_wave;     break;
        case OSC_NOISE:    osc->waveform_func = noise_wave;   break;
        default:           osc->waveform_func = sine_wave;    break;
    }
}

void osc_set_freq(Oscillator* osc, float freq) { osc->frequency = freq; }
void osc_set_amp(Oscillator* osc, float amp) { osc->amplitude = amp; }
void osc_reset(Oscillator* osc) { osc->phase = 0.0f; }

float osc_process(Oscillator* osc) {
    float out = osc->waveform_func(osc);
    osc->phase += osc->frequency / osc->sample_rate;
    if (osc->phase >= 1.0f) osc->phase -= 1.0f;
    return out;
}
```

**main.c** (PortAudio integration, polyphony, parameter changes)

```c
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <portaudio.h>
#include "oscillator.h"

#define NUM_OSCILLATORS 8
#define SAMPLE_RATE 48000
#define FRAMES_PER_BUFFER 256

Oscillator osc_bank[NUM_OSCILLATORS];

static int audio_callback(
    const void* inputBuffer, void* outputBuffer,
    unsigned long framesPerBuffer,
    const PaStreamCallbackTimeInfo* timeInfo,
    PaStreamCallbackFlags statusFlags,
    void* userData
) {
    float* out = (float*)outputBuffer;
    (void)inputBuffer;

    // Polyphonic mixdown (simple sum, divided by num voices)
    for (unsigned long i = 0; i < framesPerBuffer; ++i) {
        float sample = 0.0f;
        for (int v = 0; v < NUM_OSCILLATORS; ++v) {
            sample += osc_process(&osc_bank[v]);
        }
        sample /= NUM_OSCILLATORS; // avoid clipping
        *out++ = sample; // mono output
    }
    return paContinue;
}

int main(void) {
    // Seed random generator for noise
    srand((unsigned)time(NULL));

    // Initialize oscillators
    for (int i = 0; i < NUM_OSCILLATORS; ++i) {
        osc_init(&osc_bank[i], OSC_SAW, 220.0f * powf(2.0f, i / 12.0f), 0.5f, SAMPLE_RATE);
    }

    Pa_Initialize();
    PaStream* stream;

    Pa_OpenDefaultStream(&stream, 0, 1, paFloat32, SAMPLE_RATE, FRAMES_PER_BUFFER, audio_callback, NULL);
    Pa_StartStream(stream);

    printf("Playing modular oscillator bank. Press Enter to exit.\n");
    getchar();

    Pa_StopStream(stream);
    Pa_CloseStream(stream);
    Pa_Terminate();
    return 0;
}
```

### 7.4 Commentary: Understanding the Code

- Each oscillator is its own independent module.
- All parameters (type, freq, amp) are per-oscillator, mimicking hardware modularity.
- The audio callback mixes all oscillators for polyphony.
- You can adjust parameters in real time (e.g., via MIDI, UI, or control code).
- The design is easy to extend with envelopes, filters, and modulation.

### 7.5 Testing: Listening and Visualization

- Listen to the sound output and compare different oscillator types.
- Use an oscilloscope or software analyzer (Audacity, REW) to visualize waveforms.
- Try changing waveforms and frequencies on the fly.

### 7.6 Adding Polyphony and Real-time Parameter Changes

- Link oscillators to envelope and filter structs as you build out your synth.
- Use arrays of structs for complex, hardware-inspired voice allocation.
- Add functions to update frequency, amplitude, or waveform in real time.

---

## 8. Interfacing Digital Oscillators with DACs (Raspberry Pi)

### 8.1 DAC Selection (Bit Depth, Speed, Interface Type)

- **Bit depth:** 8, 10, 12, 16, 24 bits. Higher = better resolution and SNR.
- **Speed:** Must support your sample rate × number of channels.
- **Interface:** SPI (common, easy), I2C (slower), parallel (fast but many pins).

**Popular DAC chips:**
- **MCP4922:** 12-bit, dual channel, SPI (easy to use, cheap)
- **PCM5102A:** 24-bit, I2S (for hi-fi audio, more complex interface)
- **AD5668:** 16-bit, SPI (more expensive, very accurate)

### 8.2 SPI, I2C, and Parallel Interfacing Basics

- **SPI:** Master/slave, fast, full-duplex, uses MOSI, MISO, SCK, CS pins.
- **I2C:** Two-wire, slower, multi-device, uses SDA and SCL.
- **Parallel:** One wire per bit, fast but needs many GPIO pins.

#### SPI Example: Sending Data to a DAC

```c
// Pseudocode for sending 12-bit value to MCP4922 over SPI
uint16_t dac_word = (channel << 15) | (buffered << 14) | (gain << 13) | (shutdown << 12) | (data & 0x0FFF);
wiringPiSPIDataRW(channel, (unsigned char*)&dac_word, 2);
```

### 8.3 Practical Circuit: Connecting a Pi to a DAC

- Connect Pi’s SPI pins (MOSI, SCK, CS) to DAC.
- Power DAC from Pi’s 3.3V or 5V (as required).
- Use decoupling capacitors for stable power.
- Connect DAC output to op-amp buffer before output jack.

#### Example: MCP4922 SPI pinout

| DAC Pin  | Function      | Connect to Pi   |
|----------|---------------|-----------------|
| Vdd      | Power (2.7-5V)| 3.3V/5V         |
| Vss      | Ground        | GND             |
| SCK      | SPI Clock     | GPIO11 (SCLK)   |
| SDI      | SPI Data In   | GPIO10 (MOSI)   |
| CS       | Chip Select   | GPIO8 (CE0)     |
| VOUTA/B  | Analog Out    | Output buffer   |

### 8.4 Voltage Scaling and Output Filtering (Reconstruction Filter)

- **Scaling:** DAC output is often 0–5V or 0–3.3V; may need to shift/buffer to ±5V or ±10V for modular synths.
- **Reconstruction filter:** Low-pass analog filter to remove digital “stair-step” artifacts, typically 1–3 kHz below Nyquist.

**Typical filter:** RC or op-amp-based 2nd/3rd order low-pass, cutoff at ~20 kHz for audio synths.

### 8.5 Testing with Oscilloscope and Speakers

- Test DAC output with an oscilloscope for expected waveform.
- Listen for noise, glitches, or aliasing.
- Adjust filter cutoff and scaling for best sound.

---

## 9. Advanced Topics

### 9.1 Hard Sync, Soft Sync

- **Hard Sync:** Resets slave oscillator phase when master resets; creates rich, “ripping” harmonics.
- **Soft Sync:** Similar, but only partial phase reset; subtler effect.

**Implementation:**  
In `osc_process()`, check if sync input triggers a phase reset.

### 9.2 FM, PM, and AM Digital Techniques

- **FM (Frequency Modulation):** Modulate frequency by another oscillator (carrier + modulator).
    ```c
    osc->frequency += fm_amount * modulator_sample;
    ```
- **PM (Phase Modulation):** Modulate phase directly.
- **AM (Amplitude Modulation):** Multiply oscillator output by modulator (ring mod).

### 9.3 Detuning, Drift, and Analog Modeling

- **Detuning:** Slightly offset oscillator frequencies for “fat” sound.
- **Drift:** Slowly modulate frequency or phase to mimic analog instability.
    - Use low-frequency random or LFO-like input.
- **Analog modeling:** Add small non-linearities, jitter, or filtering for realism.

### 9.4 Noise Shaping and Dithering for High Fidelity

- **Noise shaping:** Pushes quantization noise out of audible range (used in high-end DACs).
- **Dithering:** Adds low-level noise before quantization to mask distortion.

**In DIY/hobby synths, these are advanced but can improve digital sound quality.**

---

## 10. Exercises and Practical Experiments

1. Implement hard and soft sync in your oscillator struct and test with two oscillators.
2. Add frequency or phase modulation (FM/PM) using a second oscillator as a modulator.
3. Build a test harness to send oscillator output to a DAC on your Pi; analyze output on an oscilloscope.
4. Implement PolyBLEP band-limiting for your saw and square oscillators.
5. Experiment with detuning and drift: create “supersaw” or “analog” stacks.
6. Compare sound quality with and without a reconstruction filter on your DAC output.
7. Document your modular oscillator code: explain how each function and struct mimics a hardware board.

---

## 11. Summary

- Oscillators are the fundamental sound source in any synth—design them modularly in C for hardware-like flexibility.
- Understand waveform math, harmonics, and generation methods (both analog and digital).
- Implement modular oscillator code with clear struct-based separation, function pointers, and extensibility.
- Use PortAudio for PC prototyping and a real DAC for Pi/audio hardware, with attention to filtering and scaling.
- Explore advanced concepts (FM, sync, detuning, band-limiting) to enrich your synth’s sonic palette.
- Test, measure, and listen at every step—use your ears, tools, and code!

---

*End of Chapter 6. Next: Analog Electronics for Synthesizers (Filters, VCAs, Signal Routing).*