# Chapter 11: Porting – PC to Raspberry Pi (Bare Metal to Linux) – Part 1

---

## Table of Contents

1. Introduction: Why Port to the Raspberry Pi?
2. The Raspberry Pi Environment
    - Differences from PC (x86_64) to Pi (ARM)
    - Pi hardware: CPU, peripherals, boot process
    - OS choices: Bare-metal, Raspbian/Raspberry Pi OS, other Linux distros
    - Audio, GPIO, and peripheral access on Pi
3. Bare-Metal vs Linux Development
    - What is bare-metal programming?
    - Pros and cons for synth projects
    - Linux: advantages, challenges, libraries
    - Choosing your approach
4. Toolchains and Cross-Compilation
    - Cross-compiling vs native compiling
    - Toolchain basics: GCC, Clang, Make, CMake
    - Setting up a cross-compilation toolchain for Pi
    - Building for Pi from Windows, macOS, Linux
    - Common pitfalls and debugging
5. System Architecture Planning
    - File layout for cross-platform builds
    - Source-level portability best practices
    - Hardware abstraction layers (HAL)
    - Conditional compilation and platform detection

---

## 1. Introduction: Why Port to the Raspberry Pi?

Porting your synthesizer code from PC to Raspberry Pi opens up a world of possibilities. The Pi is affordable, small, and powerful—with GPIO for hardware interfacing, I2S and USB for audio, and enough muscle for even complex real-time synthesis. Learning to port your code also builds skills in embedded development, cross-platform C/C++, and hardware/software integration.

**Key motivations:**
- **Hardware integration:** Add MIDI, knobs, switches, and analog/digital I/O.
- **Portability:** Deploy your synth as a standalone instrument.
- **Learning:** Understand real-world embedded audio and system design.
- **Community:** Huge ecosystem and resources for Pi development.

---

## 2. The Raspberry Pi Environment

### 2.1 Differences from PC (x86_64) to Pi (ARM)

- **CPU architecture:** PC is typically x86_64, Pi uses ARM (Cortex-A series).
- **Endianness:** Both are little endian, but always check when dealing with raw binary data.
- **Instruction set:** ARM vs x86; some assembly code or binaries are not portable.
- **Performance:** Pi 4 is powerful for embedded, but not as fast as a modern PC CPU—optimize code for real-time.
- **Peripherals:** Pi has GPIO, I2C, SPI, I2S, etc. PC usually does not.

### 2.2 Pi Hardware Overview

- **CPU:** Quad-core ARM Cortex-A72
- **RAM:** 2–8GB
- **Storage:** Micro SD card
- **I/O:** 40-pin GPIO header, HDMI, USB 2.0/3.0, Ethernet, Wi-Fi
- **Audio:** I2S (digital audio), PWM (basic audio), USB audio interfaces

### 2.3 Pi Boot Process

- **Bootloader in ROM loads bootcode.bin from SD card**
- **Reads config.txt and device tree overlays**
- **Loads kernel.img (bare-metal) or kernel+initrd (Linux)**
- **Starts user code or OS**

### 2.4 OS Choices

- **Bare-metal:** No OS; you write all drivers, scheduling, etc.
    - Pros: Maximum control, lowest latency, smallest memory footprint.
    - Cons: Complex, steep learning curve, must handle all I/O yourself.
- **Raspberry Pi OS (Raspbian):** Debian-based Linux, full desktop or “Lite” version.
    - Pros: All drivers supported, easy development, rich library support.
    - Cons: Some latency (kernel, multitasking), more overhead.
- **Other distros:** Ubuntu, Arch, custom Linux builds, RT-kernel.

### 2.5 Audio, GPIO, and Peripheral Access

- **On Linux:** Use ALSA/Jack/Pulse for audio, wiringPi/gpio/sysfs/libgpiod for GPIO.
- **Bare-metal:** Write to hardware registers directly, or use libraries like Circle (C++).
- **I2C/SPI/I2S:** Supported in both, but bare-metal needs manual register work.

---

## 3. Bare-Metal vs Linux Development

### 3.1 What is Bare-Metal Programming?

- “Bare-metal” means running your code on the hardware with no OS.
    - You write the main loop, handle all peripherals, interrupts, and memory management.
    - Used in classic synths, microcontrollers, real-time DSP, and critical systems.

### 3.2 Pros and Cons for Synth Projects

#### Pros:
- **Ultra-low latency:** No OS scheduling overhead, direct hardware access.
- **Deterministic timing:** Critical for precise audio and MIDI.
- **Minimal footprint:** Very small binaries, fast boot.

#### Cons:
- **Complexity:** Must write/init all drivers (USB, SD card, audio, display, etc.)
- **Debugging:** No OS tools (gdb, top, syslog); need JTAG, serial debug, LEDs.
- **Portability:** Harder to reuse code, fewer libraries.

### 3.3 Linux: Advantages, Challenges, Libraries

#### Advantages:
- **Rich driver support:** Audio, MIDI, USB, display, networking “just work.”
- **Development tools:** gcc, gdb, valgrind, strace, IDEs, Python, scripting.
- **Libraries:** ALSA, PortAudio, JACK, RtAudio, MIDI, OpenGL, SDL, etc.

#### Challenges:
- **Real-time audio:** Need to tune kernel (preempt-rt), process priorities.
- **Latency:** More overhead from multitasking, interrupts, and kernel scheduling.
- **Timing:** Must account for jitter and non-deterministic I/O.

### 3.4 Choosing Your Approach

- **For beginners:** Start with Linux for ease of development, then explore bare-metal for real-time needs.
- **Hybrid:** Develop/audio on Linux, use microcontroller (e.g., STM32) for ultra-low-latency I/O.

---

## 4. Toolchains and Cross-Compilation

### 4.1 Cross-Compiling vs Native Compiling

- **Native compiling:** Build on the Pi itself. Easiest, but slower for big projects.
- **Cross-compiling:** Build on your PC (x86_64), output ARM binary for Pi.
    - Faster, allows use of desktop IDEs, automation.
    - Requires correct toolchain and libraries.

### 4.2 Toolchain Basics

- **GCC:** Standard C/C++ compiler, available for ARM (arm-linux-gnueabihf-gcc).
- **Clang:** Alternative compiler, supports ARM.
- **Make/CMake:** Build system generators; CMake is cross-platform and integrates well with IDEs.

### 4.3 Setting Up a Cross-Compilation Toolchain

#### On Linux

```bash
sudo apt-get install gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf
```

- **Compiler:** `arm-linux-gnueabihf-gcc`
- **Sysroot:** Copy Pi’s `/usr` and `/lib` directories to PC for correct headers/libs.

#### On Windows/macOS

- Use Docker or cross-compilers from ARM.
- Use VSCode with Remote-SSH extension for direct Pi development.

### 4.4 Building for Pi from Windows, macOS, Linux

#### Example: Compiling a Simple Program

```bash
arm-linux-gnueabihf-gcc -o myprog myprog.c
scp myprog pi@raspberrypi.local:/home/pi/
```

- Run `myprog` directly on Pi after copying.

### 4.5 Common Pitfalls and Debugging

- **Library mismatches:** Ensure your cross-compiler uses the same version as Pi.
- **Endianness:** Pi is little-endian, but always check for binary data.
- **Permissions:** Scripts may not be executable after transfer (`chmod +x`).
- **Missing dependencies:** Use `ldd myprog` on Pi to check for required libraries.

---

## 5. System Architecture Planning

### 5.1 File Layout for Cross-Platform Builds

- **src/:** Common cross-platform code (synth engine, DSP, UI)
- **platform/pc/:** PC-specific drivers (audio, MIDI, GUI)
- **platform/pi/:** Pi-specific drivers (GPIO, DAC, display)
- **include/:** Headers (API, platform abstraction)
- **build/:** Build scripts, Makefiles, CMakeLists.txt

### 5.2 Source-Level Portability Best Practices

- **Avoid platform-specific APIs** in shared code.
- **Abstract hardware:** Use function pointers, interfaces, or #ifdefs to separate platform code.
- **Unit tests:** Run on PC for speed, then deploy to Pi.

### 5.3 Hardware Abstraction Layers (HAL)

A **HAL** lets you write portable code by hiding platform-specific details behind an interface.

#### Example:

```c
// hal_audio.h
void hal_audio_init();
void hal_audio_write(float* buffer, size_t frames);

// hal_audio_pc.c
void hal_audio_init() { /* PC audio init code */ }
void hal_audio_write(float* buffer, size_t frames) { /* ... */ }

// hal_audio_pi.c
void hal_audio_init() { /* Pi audio init code */ }
void hal_audio_write(float* buffer, size_t frames) { /* ... */ }
```

### 5.4 Conditional Compilation and Platform Detection

- Use `#ifdef RASPBERRY_PI` or similar macros to include/exclude code.
- Define macros in your build system or pass with `-D` flag (e.g., `-DRASPBERRY_PI`).
- Use CMake’s `target_compile_definitions()` for cross-platform builds.

---

*End of Part 1. Part 2 will deeply cover CMake, platform abstraction, porting audio I/O, MIDI, GPIO, performance tuning, debugging on Pi, and a step-by-step porting example from PC to Pi.*