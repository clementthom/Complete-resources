# Chapter 12: Audio I/O on Linux with PortAudio – Part 1

---

## Table of Contents

1. Introduction: What is PortAudio, and Why Use It?
2. Audio I/O Fundamentals on Linux
    - The Linux audio stack: ALSA, PulseAudio, JACK, OSS
    - Real-time audio requirements for synthesizers
    - Audio devices, sample rates, buffer sizes, and latency
    - Enumerating, selecting, and configuring audio devices
3. Deep Dive: PortAudio Architecture
    - What is PortAudio? Cross-platform philosophy
    - How PortAudio abstracts audio hardware
    - Callback vs blocking APIs
    - Key concepts: streams, buffers, host APIs, sample formats
    - PortAudio on the Raspberry Pi: ALSA backend and alternatives
4. Installing and Building PortAudio on Linux and Raspberry Pi
    - Downloading, building, and installing PortAudio from source
    - Linking PortAudio to your synth project
    - Troubleshooting library and header issues
5. Writing Basic Audio Code with PortAudio in C
    - Opening and configuring a stream
    - Writing your first callback (sine wave, silence, noise)
    - Handling errors and stream statuses
    - Stopping, closing, and cleaning up

---

## 1. Introduction: What is PortAudio, and Why Use It?

**PortAudio** is a cross-platform, open-source audio I/O library designed to provide a uniform interface to audio hardware on Windows, macOS, and Linux—including the Raspberry Pi. It’s widely used in digital audio applications, from synths and DAWs to analysis tools and effects processors.

**Why use PortAudio?**
- **Cross-platform:** Write code once for PC, Mac, Linux, Pi.
- **Low-level control:** Direct access to hardware, low latency.
- **Flexible:** Supports both callback and blocking APIs.
- **Actively maintained:** Community-driven, supports new hardware and APIs.
- **Integration:** Plays well with other libraries (e.g. RtAudio, JUCE, SuperCollider).

**Alternatives:** ALSA (Linux-only), JACK (pro/low-latency), PulseAudio (consumer desktop), RtAudio (higher-level, less control), SDL/SDL2 (game audio).

---

## 2. Audio I/O Fundamentals on Linux

### 2.1 The Linux Audio Stack

- **ALSA (Advanced Linux Sound Architecture):** Kernel-level audio driver and API. Forms the foundation of Linux audio.
- **PulseAudio:** Sound server sitting atop ALSA, handles mixing and routing for desktop apps. Not ideal for real-time synths.
- **JACK (Jack Audio Connection Kit):** Pro-grade low-latency audio server, supports flexible routing and sync. Used in studios, DAWs, modular synth software.
- **OSS (Open Sound System):** Legacy, mostly replaced by ALSA.
- **Direct Hardware:** For bare-metal or custom drivers.

#### Synth Tuning:
- For lowest latency and direct access, prefer ALSA or JACK backends in PortAudio.
- Avoid PulseAudio for synths unless targeting desktop convenience over real-time performance.

### 2.2 Real-Time Audio Requirements for Synthesizers

- **Low latency:** <10ms round-trip is ideal for live performance.
- **Stable buffer:** No dropouts (xruns), glitches, or underruns.
- **Consistent timing:** Time-critical for envelopes, LFOs, and MIDI-to-audio response.
- **Sample accuracy:** Every sample must be delivered on time, in order.

#### Key Terms:
- **Buffer size:** Number of samples between callbacks. Smaller = lower latency, higher CPU.
- **Sample rate:** Hz (e.g., 44100, 48000, 96000). Must match your DAC and synth engine.
- **Frames per buffer:** Usually “buffer size / channels”.

### 2.3 Audio Devices, Sample Rates, Buffer Sizes, and Latency

- **Audio interface:** Can be on-board (Pi headphone jack), USB, I2S DAC, HDMI, or pro-audio card.
- **Default sample rates:** 44100 Hz (CD), 48000 Hz (pro audio), higher for audiophile.
- **Buffer size:** Common values: 32, 64, 128, 256, 512, 1024 samples.
    - Lower buffer = lower latency, but higher risk of underruns.
- **Latency:** The time between producing sound and hearing it. Calculated as:
    ```
    Latency (ms) = (buffer size / sample rate) * 1000
    ```
    E.g., 128 samples at 48000 Hz = 2.67ms.

### 2.4 Enumerating, Selecting, and Configuring Audio Devices

- **PortAudio can list all available devices and their capabilities.**
- You can select device by index or name.
- Each device may support different sample rates, buffer sizes, channel counts.
- Use PortAudio’s `Pa_GetDeviceInfo()`, `Pa_GetHostApiInfo()`.

#### Practical Tips:

- On Pi, USB audio devices often have better DACs/ADCs than built-in analog.
- I2S DACs (HiFiBerry, IQaudio) offer highest quality and lowest noise.
- Some cheap USB devices only support 16-bit/44100 Hz.

---

## 3. Deep Dive: PortAudio Architecture

### 3.1 What is PortAudio? Cross-Platform Philosophy

- PortAudio provides a uniform C API for audio input/output across platforms.
- Supports multiple backends (“host APIs”): ALSA, JACK, Pulse, CoreAudio, WASAPI, ASIO, DirectSound, OSS, WDM-KS, etc.
- Abstracts device enumeration, stream management, and buffer handling from OS specifics.

### 3.2 How PortAudio Abstracts Audio Hardware

- **Host API:** A wrapper for underlying OS audio (e.g., ALSA on Linux, CoreAudio on Mac).
- **Device:** Represents an audio input/output device.
- **Stream:** Connection for audio data between your code and device (input, output, or both).
- **StreamParameters:** Structure to describe channel count, sample format, latency, etc.

### 3.3 Callback vs Blocking APIs

- **Callback API:** Your function is called by PortAudio when it needs more audio data (preferred for synths, lowest latency).
- **Blocking API:** You push/pull audio to/from PortAudio buffers (simpler, more overhead, not real-time safe).

#### Callback Example:

```c
static int audioCallback(const void *input, void *output,
                        unsigned long frameCount,
                        const PaStreamCallbackTimeInfo* timeInfo,
                        PaStreamCallbackFlags statusFlags,
                        void *userData) {
    float *out = (float*)output;
    // Fill output buffer with samples
    // Return paContinue, paComplete, or paAbort
}
```

- Callback must be fast, non-blocking, and avoid malloc/free or I/O.

### 3.4 Key Concepts: Streams, Buffers, Host APIs, Sample Formats

- **Stream:** The main audio I/O connection. Open, start, stop, close.
- **Buffers:** Chunks of audio samples processed each callback/block.
- **Sample formats:** `paFloat32`, `paInt16`, etc. Always match to device capabilities.
- **Channels:** Mono (1), stereo (2), multichannel (4, 6, 8+).

### 3.5 PortAudio on Raspberry Pi

- **Default backend:** ALSA.
- **Alternatives:** JACK, PulseAudio.
- **I2S DACs:** Appear as ALSA devices when driver overlay is enabled.
- **USB audio:** Also appear as ALSA devices.

#### Performance Tips:

- Use real-time scheduling (`chrt` or `SCHED_FIFO`) for synth process.
- Use buffer sizes that match your audio device’s hardware buffer for best results.
- Monitor for xruns and handle errors gracefully.

---

## 4. Installing and Building PortAudio on Linux and Raspberry Pi

### 4.1 Downloading and Installing PortAudio

#### From Source

```bash
git clone https://github.com/PortAudio/portaudio.git
cd portaudio
./configure
make
sudo make install
```

- Installs libportaudio and headers to system.
- Use `pkg-config --cflags --libs portaudio-2.0` to get include/lib paths.

#### From Package Manager (Debian/Raspbian/Ubuntu)

```bash
sudo apt-get update
sudo apt-get install portaudio19-dev
```

### 4.2 Linking PortAudio to Your Synth Project

- Add `-lportaudio` to your linker flags.
- Include `#include <portaudio.h>` in your code.
- With CMake:

```cmake
find_package(PkgConfig REQUIRED)
pkg_check_modules(PORTAUDIO REQUIRED portaudio-2.0)
target_include_directories(your_target PRIVATE ${PORTAUDIO_INCLUDE_DIRS})
target_link_libraries(your_target PRIVATE ${PORTAUDIO_LIBRARIES})
```

### 4.3 Troubleshooting Library and Header Issues

- If your build can’t find portaudio, check `pkg-config` output.
- If linking fails, ensure `/usr/local/lib` or `/usr/lib` is in your linker path.
- On Pi, sometimes `/usr/local/include` and `/usr/local/lib` aren’t searched by default—add with `-I` and `-L` flags, or update `/etc/ld.so.conf.d/`.

---

## 5. Writing Basic Audio Code with PortAudio in C

### 5.1 Opening and Configuring a Stream

- **Initialize PortAudio:**
    ```c
    Pa_Initialize();
    ```
- **Set up `PaStreamParameters` for input and/or output:**
    ```c
    PaStreamParameters outputParams;
    outputParams.device = Pa_GetDefaultOutputDevice();
    outputParams.channelCount = 2; // stereo
    outputParams.sampleFormat = paFloat32;
    outputParams.suggestedLatency = Pa_GetDeviceInfo(outputParams.device)->defaultLowOutputLatency;
    outputParams.hostApiSpecificStreamInfo = NULL;
    ```
- **Open a stream:**
    ```c
    PaStream *stream;
    Pa_OpenStream(&stream, NULL, &outputParams, 48000, 256,
                  paClipOff, audioCallback, userData);
    ```
- **Start the stream:**
    ```c
    Pa_StartStream(stream);
    ```
- **Stop and close:**
    ```c
    Pa_StopStream(stream);
    Pa_CloseStream(stream);
    Pa_Terminate();
    ```

### 5.2 Writing Your First Callback

- **Sine wave example:**
    ```c
    static int audioCallback(const void *input, void *output,
                            unsigned long frameCount,
                            const PaStreamCallbackTimeInfo* timeInfo,
                            PaStreamCallbackFlags statusFlags,
                            void *userData) {
        float *out = (float*)output;
        double *phase = (double*)userData;
        double freq = 440.0, sampleRate = 48000.0;
        for (unsigned long i = 0; i < frameCount; i++) {
            out[2*i] = out[2*i+1] = (float)sin(*phase);
            *phase += 2.0 * M_PI * freq / sampleRate;
            if (*phase > 2.0 * M_PI) *phase -= 2.0 * M_PI;
        }
        return paContinue;
    }
    ```

### 5.3 Handling Errors and Stream Statuses

- Check return values of all PortAudio calls.
- Print error messages with `Pa_GetErrorText(err)`.
- Handle underflow/overflow (xruns) in callback via statusFlags.

### 5.4 Stopping, Closing, and Cleaning Up

- Always stop and close streams before terminating PortAudio.
- Use `Pa_AbortStream()` if you need immediate stop.
- Free any user data allocated for audio processing.

---

*End of Part 1. Part 2 will deeply explore advanced callback design, multi-threading, integrating PortAudio with synth engines, MIDI/audio sync, low-latency tuning, and real-world troubleshooting on the Pi and Linux desktops.*