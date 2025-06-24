# Chapter 11: Porting – PC to Raspberry Pi (Bare Metal to Linux) – Part 2

---

## Table of Contents

6. Deep Dive: CMake and Platform Abstraction
    - Why use CMake? Advantages for cross-platform synth projects
    - Basic CMakeLists.txt structure
    - Platform detection, conditional sources, and definitions
    - Linking platform-specific libraries (ALSA, PortAudio, wiringPi, etc.)
    - Out-of-source builds, build types, and configuration
    - CMake presets and toolchain files for ARM cross-compilation
7. Porting Audio I/O: PC (PortAudio) to Pi (ALSA, I2S, others)
    - Audio backends: ALSA, PulseAudio, JACK, I2S, USB audio
    - Writing a HAL for audio (init, process, shutdown)
    - Handling different sample rates, buffer sizes, and under/overruns
    - Real-time tuning: scheduling, priorities, and xrun handling
    - Debugging audio on Pi: tools and practical tips
8. Porting MIDI and GPIO
    - MIDI on PC vs. Pi: ALSA MIDI, RtMidi, USB MIDI, UART
    - Handling GPIO: digital in/out, interrupts, PWM, I2C/SPI devices
    - Abstraction for control surfaces and CV/gate
    - Safety and debouncing in hardware controls
9. Performance Tuning and Debugging on Raspberry Pi
    - Profiling CPU, memory, and I/O bottlenecks
    - Real-time OS tweaks: kernel configuration, priority, isolcpus, etc.
    - Measuring and minimizing latency
    - Debugging tools: gdb, valgrind, strace, htop, custom logging
    - Remote debugging and headless workflows
10. Example: Step-by-Step Port of a Synth Prototype
    - Setting up codebase and CMake for PC + Pi
    - Adapting audio and MIDI drivers
    - Testing and troubleshooting on both platforms
    - Final integration: analog, digital, and UI elements

---

## 6. Deep Dive: CMake and Platform Abstraction

### 6.1 Why Use CMake? Advantages for Cross-Platform Synth Projects

- **CMake** is a powerful, open-source build system generator, widely used for C/C++.
- Generates native build files (Makefiles, Ninja, Visual Studio, Xcode).
- Excellent for managing complex dependency trees and platform-specific code.
- Supports cross-compiling, build presets, and toolchain files for ARM/embedded.
- Makes code maintenance and collaboration easier.

### 6.2 Basic CMakeLists.txt Structure

```cmake
cmake_minimum_required(VERSION 3.13)
project(hybrid_synth C)

set(CMAKE_C_STANDARD 11)
set(SRC
    src/main.c
    src/synth_engine.c
    src/hal_audio.c
    # Add all common sources
)

add_executable(hybrid_synth ${SRC})

# Platform-specific sources
if(RASPBERRY_PI)
    target_sources(hybrid_synth PRIVATE platform/pi/hal_audio_pi.c)
    target_compile_definitions(hybrid_synth PRIVATE RASPBERRY_PI=1)
else()
    target_sources(hybrid_synth PRIVATE platform/pc/hal_audio_pc.c)
endif()
```

### 6.3 Platform Detection, Conditional Sources, and Definitions

- Use variables to detect/define platform (e.g., `-DRASPBERRY_PI`).
- Use `target_sources` and `target_compile_definitions` for clean builds.

### 6.4 Linking Platform-Specific Libraries

```cmake
if(RASPBERRY_PI)
    target_link_libraries(hybrid_synth PRIVATE asound wiringPi m)
else()
    target_link_libraries(hybrid_synth PRIVATE portaudio m)
endif()
```

- **ALSA:** Pi/Linux native audio
- **PortAudio:** Cross-platform audio
- **wiringPi:** GPIO access (deprecated, use libgpiod for new projects)
- **m:** Math library

### 6.5 Out-of-Source Builds, Build Types, and Configuration

- **Out-of-source build:** Keeps build files separate from source.
    ```bash
    mkdir build && cd build
    cmake ..
    make
    ```
- **Build types:** Debug, Release, RelWithDebInfo, etc.
    ```bash
    cmake -DCMAKE_BUILD_TYPE=Release ..
    ```

### 6.6 CMake Presets and Toolchain Files for ARM Cross-Compilation

- **Presets:** Store build configs (`CMakePresets.json`).
- **Toolchain files:** Specify compiler, sysroot, options for cross-compile.

#### Example: ARM Toolchain File

```cmake
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_FIND_ROOT_PATH /path/to/sysroot)
```

- Invoke with `cmake -DCMAKE_TOOLCHAIN_FILE=toolchain-arm.cmake ..`

---

## 7. Porting Audio I/O: PC (PortAudio) to Pi (ALSA, I2S, others)

### 7.1 Audio Backends

- **PC:** PortAudio, JACK, PulseAudio, ASIO (Windows), CoreAudio (macOS)
- **Pi/Linux:** ALSA (default), JACK, PortAudio, I2S, USB audio interfaces

### 7.2 Writing a Hardware Abstraction Layer (HAL) for Audio

**Example: hal_audio.h**

```c
void hal_audio_init(int sample_rate, int buffer_size);
void hal_audio_start();
void hal_audio_stop();
void hal_audio_write(float* buffer, size_t frames);
void hal_audio_shutdown();
```

- Implemented separately for PC (PortAudio) and Pi (ALSA/I2S).

**hal_audio_pc.c** (PortAudio)
- Use `Pa_Initialize`, `Pa_OpenDefaultStream`, `Pa_StartStream`, etc.

**hal_audio_pi.c** (ALSA)
- Use `snd_pcm_open`, `snd_pcm_writei`, etc.

### 7.3 Handling Sample Rates, Buffer Sizes, and Underruns

- **Negotiation:** Query hardware for supported rates/buffers.
- **Buffer size:** Low = lower latency, but higher risk of underruns; high = more latency.
- **Underruns/Overruns:** Handle with callbacks or error codes; fill silence if needed.
- **Latency tuning:** Use ALSA’s `snd_pcm_set_params` or PortAudio’s stream settings.

### 7.4 Real-Time Tuning: Scheduling, Priorities, and xrun Handling

- **Set real-time priority:** Use `chrt` or `sched_setscheduler` for audio threads.
- **Isolate CPUs:** Use `isolcpus` Linux kernel param for dedicated audio core.
- **Xruns:** Track with ALSA/PortAudio APIs, log and handle gracefully.

### 7.5 Debugging Audio on Pi

- Use `aplay`, `arecord`, `aplaymidi` for testing.
- Use `alsamixer` to check volume/mute/channel routing.
- Use tools like `jack_lsp`, `jack_connect` if using JACK.
- Check system logs (`dmesg`, `journalctl`) for device and driver messages.

---

## 8. Porting MIDI and GPIO

### 8.1 MIDI on PC vs. Pi

- **PC:** PortMidi, RtMidi, ALSA MIDI, USB MIDI devices.
- **Pi:** ALSA MIDI (`/dev/snd/midi*`), USB MIDI, UART (for DIN connectors).

#### Example: ALSA MIDI Input

```c
#include <alsa/asoundlib.h>
snd_seq_t *seq_handle;
snd_seq_open(&seq_handle, "default", SND_SEQ_OPEN_INPUT, 0);
snd_seq_create_simple_port(seq_handle, "Input",
    SND_SEQ_PORT_CAP_WRITE|SND_SEQ_PORT_CAP_SUBS_WRITE,
    SND_SEQ_PORT_TYPE_APPLICATION);
```

- Poll with `snd_seq_event_input`.

### 8.2 Handling GPIO: Digital In/Out, Interrupts, PWM, I2C/SPI

- **GPIO libraries:** `wiringPi` (deprecated), `pigpio`, `libgpiod` (modern).
- **Digital in/out:** Reading switches, buttons, LEDs.
- **PWM:** For CV/gate or LED dimming.
- **I2C/SPI:** For displays, encoders, additional DAC/ADC.

#### Example: Reading a Button with libgpiod

```c
#include <gpiod.h>
struct gpiod_chip *chip = gpiod_chip_open("/dev/gpiochip0");
struct gpiod_line *line = gpiod_chip_get_line(chip, 17);
gpiod_line_request_input(line, "synth");
int value = gpiod_line_get_value(line);
gpiod_chip_close(chip);
```

### 8.3 Abstraction for Control Surfaces and CV/Gate

- Write platform-agnostic interfaces for reading controls (knobs, switches), sending CV/gate.
- Use callbacks or event queues for decoupling hardware and synth logic.

### 8.4 Safety and Debouncing in Hardware Controls

- **Debounce:** Remove spurious transitions from physical switches.
- **Software debounce:** Check value stability over several reads.
- **Hardware debounce:** Use RC filters or Schmitt triggers.

---

## 9. Performance Tuning and Debugging on Raspberry Pi

### 9.1 Profiling CPU, Memory, and I/O Bottlenecks

- Use `htop`, `top`, `vmstat` for system stats.
- Use `gprof`, `perf`, or `valgrind` for detailed profiling.
- Focus on tight DSP loops, memory allocation, and I/O calls.

### 9.2 Real-Time OS Tweaks

- **Kernel tuning:** Use PREEMPT-RT kernel for low latency.
- **Priorities:** Set audio threads to SCHED_FIFO or SCHED_RR.
- **CPU isolation:** Boot with `isolcpus=3` to reserve core for audio.
- **Disable power management:** Prevent CPU frequency scaling.

### 9.3 Measuring and Minimizing Latency

- Use `jack_delay`, `latencytop`, or custom test signals.
- Optimize buffer sizes, thread priorities, and avoid blocking calls in audio thread.

### 9.4 Debugging Tools

- **gdb:** Source-level debugging for C.
- **valgrind:** Memory leak and performance analysis.
- **strace:** Monitor system calls for I/O issues.
- **custom logging:** Printf/logfile for real-time event tracing.

### 9.5 Remote Debugging and Headless Workflows

- Use SSH for remote terminal access.
- Use `gdbserver` for remote debugging from desktop IDE.
- Use VNC or web-based tools for graphical access.

---

## 10. Example: Step-by-Step Port of a Synth Prototype

### 10.1 Setting Up Codebase and CMake

- Organize code into `src/`, `platform/pc/`, `platform/pi/`.
- Add CMake conditionals for audio, MIDI, GPIO.
- Define build targets and link platform libraries.

### 10.2 Adapting Audio and MIDI Drivers

- Implement `hal_audio_*` and `hal_midi_*` for both PC and Pi.
- Test with minimal “audio pass-through” and “MIDI echo” programs.

### 10.3 Testing and Troubleshooting

- Start with known-good code on PC.
- Cross-compile and deploy to Pi, run from terminal.
- Use simple test signals (sine, noise) and MIDI streams for validation.

### 10.4 Final Integration: Analog, Digital, and UI

- Connect DAC, MIDI, and control surface.
- Validate latency, buffer stability, and feature parity.
- Document all platform-specific changes and test cases.

---

## 11. Summary and Further Reading

- Porting from PC to Pi requires careful attention to hardware, OS, toolchain, and code structure.
- Use CMake and HAL layers for maintainability and portability.
- Test all hardware interfaces in isolation.
- Profile and optimize for real-time audio.
- Document and automate your build and deployment process.

**Recommended Resources:**
- “Mastering Embedded Linux Programming” by Chris Simmonds
- “CMake Cookbook” by Radovan Bast
- Raspberry Pi forums, Stack Overflow, and GitHub codebases

---

*End of Chapter 11. Next: Audio I/O on Linux with PortAudio (deep dive into building robust, low-latency audio applications, troubleshooting, and advanced usage).*