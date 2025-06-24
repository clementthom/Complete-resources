# Hybrid Synthesizer Project – Document 6
## Real-Time Audio on PC with PortAudio

---

### Table of Contents

1. Why Use PortAudio?
2. Installing PortAudio on Solus Linux
3. PortAudio Program Structure
4. Writing a Callback Synth
5. Multi-Voice Example
6. Troubleshooting Audio Glitches
7. Exercises

---

## 1. Why Use PortAudio?

PortAudio is a cross-platform, open-source audio library.  
- Real-time, low-latency audio
- Runs on Windows, Linux, macOS

---

## 2. Installing PortAudio on Solus Linux

```bash
sudo eopkg install portaudio-devel
```

---

## 3. PortAudio Program Structure

- Initialize PortAudio
- Define a callback to generate audio samples
- Open and start a stream
- Wait (e.g., with `getchar()`)
- Stop and close stream

---

## 4. Writing a Callback Synth

```c
#include <portaudio.h>
#include <math.h>
#define SAMPLE_RATE 44100
#define TAU 6.2831853071f

typedef struct { float phase, freq; } Osc;

static int cb(const void *in, void *out, unsigned long frames,
        const PaStreamCallbackTimeInfo* time, PaStreamCallbackFlags flags, void *user) {
    Osc *osc = (Osc*)user;
    float *o = (float*)out;
    for (unsigned long i = 0; i < frames; i++) {
        o[i] = 0.2f * sinf(osc->phase);
        osc->phase += TAU * osc->freq / SAMPLE_RATE;
        if (osc->phase > TAU) osc->phase -= TAU;
    }
    return paContinue;
}

int main() {
    Pa_Initialize();
    Osc osc = {0, 440.0f};
    PaStream *stream;
    Pa_OpenDefaultStream(&stream, 0, 1, paFloat32, SAMPLE_RATE, 256, cb, &osc);
    Pa_StartStream(stream);
    getchar();
    Pa_StopStream(stream); Pa_CloseStream(stream); Pa_Terminate();
    return 0;
}
```

---

## 5. Multi-Voice Example

Define and mix several oscillators in the callback.

---

## 6. Troubleshooting Audio Glitches

- Increase buffer size (256 → 512 or 1024)
- Close all other audio apps
- Use `top` to check CPU usage

---

## 7. Exercises

- Make 4 voices, play a chord.
- Change the callback to output a square wave.
- Add a basic envelope to the synth.

---

**Next:**  
*hybrid_synth_07_hybrid_architecture_block_diagrams.md* — How your whole synth fits together.

---