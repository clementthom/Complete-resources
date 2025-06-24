# Hybrid Synthesizer Project
## Introduction, Mindset, and Project Overview

---

### Table of Contents

1. Welcome: Why Build Your Own Synth?
2. How to Use This Course
3. Learning by Doing: Philosophy and Structure
4. What is a Hybrid Synthesizer?
5. What Will You Build?
6. How to Learn: Mindset and Best Practices
7. Safety, Community, and Open Source
8. Essential Tools and Supplies Checklist

---

## 1. Welcome: Why Build Your Own Synth?

Have you ever dreamed of designing your own musical instrument?
This course will teach you, from scratch, how to create a professional, playable hybrid synthesizer using C code, a Raspberry Pi, and real analog electronics—just like the legendary machines (Emulator III, Synclavier, PPG Wave, etc.) that shaped modern music.

---

## 2. How to Use This Course

- **Read each document carefully:** Every concept is explained from the ground up—no prior experience needed.
- **Do the hands-on exercises:** Each section includes practical steps and mini-projects.
- **Keep a project log:** Write notes, take pictures of your breadboard, and commit code regularly.
- **Don’t skip exercises:** Real learning happens when you make mistakes and fix them.

---

## 3. Learning by Doing: Philosophy and Structure

This is not just a book—it's a course and a workshop.
You will **write code, wire circuits, debug problems, and build a real instrument**.
Every new idea is followed by a practical “do it now” assignment.
Expect to spend time **coding, breadboarding, and testing**.
You will learn not just how to build a synth, but how to learn and create technology on your own.

---

## 4. What is a Hybrid Synthesizer?

A hybrid synthesizer combines **digital sound generation** (oscillators, samplers, etc.) with **analog signal processing** (filters, VCAs), blending the best of both worlds:

- **Digital:** Precise, flexible, polyphonic, and programmable.
- **Analog:** Warm, smooth, and “alive” sound; hands-on tweaking.

**Classic Hybrids:**
- E-mu Emulator III: Digital sample playback, analog SSM2044 filters.
- PPG Wave 2.x: Digital wavetable oscillators, analog filters/VCAs.
- Prophet VS, Korg DW8000, and more.

---

## 5. What Will You Build?

By the end, you’ll have:

- A playable hybrid synthesizer with:
    - 8+ voices (polyphonic)
    - Digital oscillators coded in C
    - Audio output via a DAC (PCM5102, MCP4922, etc.)
    - Analog lowpass filter and VCA, breadboarded or soldered
    - MIDI, button, or keyboard input (bonus)
- A complete project repository (code, docs, schematics)
- The confidence and skill to expand or design your own instruments

---

## 6. How to Learn: Mindset and Best Practices

- **Be patient:** You will face bugs, mistakes, and confusion. That’s normal!
- **Debugging is learning:** Don’t fear error messages or weird sounds—they mean you’re making progress.
- **Experiment:** Try changing numbers, circuit parts, or code to see what happens.
- **Ask for help:** Use online forums, friends, and mentors.
- **Document your journey:** Comment code, photograph circuits, keep a “build diary.”

---

## 7. Safety, Community, and Open Source

- **Electronics can be dangerous:** Always unplug before changing wiring; use low-voltage circuits; double-check power before connecting.
- **Be kind and curious:** The synth DIY and maker communities are supportive—share your work and help others.
- **Open source:** You are encouraged to share your code, schematics, and learnings!

---

## 8. Essential Tools and Supplies Checklist

**For Coding:**
- Computer with Linux (Solus), Windows, or Mac
- Text editor (VSCode, Geany, Sublime, Vim, etc.)
- C compiler (GCC or Clang)
- PortAudio library for sound on PC
- Git for version control

**For Electronics (Start Simple):**
- Breadboard
- Jumper wires
- Multimeter
- Soldering iron (later)
- Oscilloscope (USB or cheap handheld is OK)
- Basic components (resistors, capacitors, op-amps, IC sockets)
- DAC module (PCM5102 or MCP4922)
- Raspberry Pi (3 or 4 recommended)
- Analog filter ICs (optional, e.g. AS3320, SSM2044, or build your own with LM13700)

---

**Next:**
*hybrid_synth_02_c_programming_from_zero.md* will start you writing your first C code step by step—even if you’ve never programmed before.

---


## C Programming from Zero: Your First Steps

---

### Table of Contents

1. What is C? Why Use It?
2. Setting Up: Installing a Compiler and Editor
3. Your First Program: Hello, World!
4. Variables, Types, and Arithmetic
5. Loops and Conditionals
6. Functions: Reusable Code Blocks
7. Arrays and Strings
8. Pointers and Memory
9. Structs and Header Files
10. Makefiles: Automating Builds
11. Debugging: Finding and Fixing Bugs
12. Exercises and Mini-Projects

---

## 1. What is C? Why Use It?

C is a powerful programming language that runs close to the hardware—perfect for embedded systems, real-time audio, and electronics projects. Most synthesizer firmware and audio engines are written in C or C++.

---

## 2. Setting Up: Installing a Compiler and Editor

**On Solus Linux:**
```bash
sudo eopkg install gcc clang make git
```
**Pick an editor:** VSCode, Geany, Sublime, Vim, or Emacs.

---

## 3. Your First Program: Hello, World!

Create a file `hello.c`:

```c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
```

**Compile and run:**
```bash
gcc hello.c -o hello
./hello
```

---

## 4. Variables, Types, and Arithmetic

```c
int a = 5;
float b = 3.14;
char c = 'A';
```
Operators: `+`, `-`, `*`, `/`, `%`

---

## 5. Loops and Conditionals

```c
for (int i = 0; i < 10; i++) {
    printf("%d\n", i);
}

if (a > 0) {
    printf("Positive\n");
} else {
    printf("Non-positive\n");
}
```

---

## 6. Functions: Reusable Code Blocks

```c
int add(int x, int y) {
    return x + y;
}
```

---

## 7. Arrays and Strings

```c
int nums[5] = {1, 2, 3, 4, 5};
char name[] = "synth";
```

---

## 8. Pointers and Memory

```c
int val = 10;
int *ptr = &val;     // pointer to val
printf("%d\n", *ptr); // dereference
```

---

## 9. Structs and Header Files

**Struct:**
```c
typedef struct {
    float freq, amp;
    int active;
} Voice;
```

**Header: `voice.h`**
```c
#ifndef VOICE_H
#define VOICE_H
typedef struct {
    float freq, amp;
    int active;
} Voice;
#endif
```

---

## 10. Makefiles: Automating Builds

Create a file `Makefile`:
```makefile
CC=gcc
CFLAGS=-Wall -O2

all: hello
hello: hello.c
	$(CC) $(CFLAGS) -o hello hello.c
clean:
	rm -f hello
```
Run `make` to build.

---

## 11. Debugging: Finding and Fixing Bugs

- Add `printf()` statements to check values.
- Use `gdb` for interactive debugging:
  `gdb ./hello`

---

## 12. Exercises and Mini-Projects

- Modify `hello.c` to print your name and age.
- Write a function that multiplies two numbers.
- Make a struct for a simple oscillator (with phase, frequency).
- Write a loop to sum an array of numbers.

---

**Next:**
*hybrid_synth_03_project_management_git_basics.md* — How to organize your code, use Git, and work like a pro.

---


## Project Management, Git, and Directory Structure

---

### Table of Contents

1. Why Project Management Matters
2. Directory Structures for Clarity
3. Using Git: Version Control Basics
4. Getting Started with GitHub
5. README Files and Documentation
6. Branches, Commits, and Collaboration
7. Issue Tracking and Planning
8. Exercises: Your First Repo

---

## 1. Why Project Management Matters

Good organization saves time, reduces errors, and makes sharing/collaborating easy.
Even solo projects benefit from clear structure and version control.

---

## 2. Directory Structures for Clarity

Recommended tree for your synth project:

```
hybrid_synth/
  src/            # Your C code
  include/        # .h files
  pc_test/        # PC-only test code
  pi_baremetal/   # Pi-only code
  electronics/    # Schematics, PCB files
  assets/         # Fonts, wavetables, etc.
  doc/            # Markdown guides, logs
  Makefile
  README.md
```

---

## 3. Using Git: Version Control Basics

- Tracks changes to your code over time.
- Lets you revert, branch, or collaborate.

**Initialize:**
```bash
cd hybrid_synth
git init
```
**First commit:**
```bash
git add .
git commit -m "Initial project structure"
```

---

## 4. Getting Started with GitHub

- Create a free account at [github.com](https://github.com)
- Create a new repository (public or private)
- Push your local repo:
```bash
git remote add origin https://github.com/YOUR_USER/hybrid_synth.git
git push -u origin master
```

---

## 5. README Files and Documentation

- `README.md` explains what your project does, how to build it, and credits.
- Use Markdown for formatting:
  ```markdown
  # Hybrid Synth
  A digital-analog synth from scratch!
  ```

---

## 6. Branches, Commits, and Collaboration

- **Branch:** A separate line of development (e.g., `feature-oscillator`)
- **Commit:** A snapshot of your work
- **Merge:** Combine branches

**Example:**
```bash
git checkout -b feature-oscillator
# work...
git add src/oscillator.c
git commit -m "Add sine oscillator"
git checkout master
git merge feature-oscillator
```

---

## 7. Issue Tracking and Planning

- Use GitHub Issues to track bugs, ideas, features.
- Example:
  - #1: "Add triangle oscillator"
  - #2: "Fix filter noise"

---

## 8. Exercises: Your First Repo

- Make your own `hybrid_synth` directory with subfolders.
- Initialize Git and push to GitHub.
- Write a short `README.md` describing your ambitions.
- Make your first commit.

---

**Next:**
*hybrid_synth_04_digital_audio_fundamentals.md* — The sound science behind your synth.

---

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


## Hybrid Architecture: Block Diagrams and System Design

---

### Table of Contents

1. Overview: Block Diagram of the Synth
2. Digital and Analog Signal Paths
3. Voice Allocation and Polyphony Flow
4. Buffer Management and Timing
5. Modularizing Your Code
6. Platform Abstraction (PC vs Pi)
7. Exercises: Draw and Annotate Your Synth’s Block Diagram

---

## 1. Overview: Block Diagram of the Synth

**Typical Block Diagram:**

```
[Input (MIDI, knob)]
  → [Voice Allocator]
    → [Oscillators & Envelopes]
      → [Mixer]
        → [DAC]
          → [Analog Filter (VCF)]
            → [Analog VCA]
              → [Output Jack]
```

---

## 2. Digital and Analog Signal Paths

- **Digital:** Everything up to (and including) the DAC.
- **Analog:** Filter, VCA, output buffer, amplifier.

---

## 3. Voice Allocation and Polyphony Flow

- Note-on event triggers a free voice.
- Voice stores frequency, envelope state, phase.
- Mixer sums active voices into output buffer.

---

## 4. Buffer Management and Timing

- DSP code fills an audio buffer.
- Buffer sent to DAC at fixed intervals (sample rate).
- **Critical:** No buffer underruns—keep data flowing!

---

## 5. Modularizing Your Code

- Separate modules for:
    - Oscillators
    - Envelopes
    - MIDI input
    - Audio output (DAC or PortAudio)
    - Analog hardware (documented in code and diagrams)

---

## 6. Platform Abstraction (PC vs Pi)

- Use interface functions for audio output.
- Only change the hardware layer when porting.

---

## 7. Exercises

- Draw your own block diagram, labeling digital/analog sections.
- Annotate the flow of a note from input to output.

---

**Next:**
*hybrid_synth_08_basic_electronics_safety_workbench.md* — Your first steps in practical electronics.

---


## Basic Electronics, Safety, and Setting Up Your Workbench

---

### Table of Contents

1. Why Learn Electronics?
2. Essential Tools and Workspace Setup
3. Understanding Electricity and Safety
4. Identifying Components (Resistors, Capacitors, Op-Amps, ICs)
5. Breadboarding and Prototyping
6. Soldering Basics
7. Using a Multimeter and Oscilloscope
8. Static Electricity and ESD Safety
9. Your First Circuit: Blinking an LED
10. Exercises

---

## 1. Why Learn Electronics?

You need to build, test, and debug analog/physical circuits to create a hybrid synth.
Electronics skills are essential for wiring DACs, building filters, and troubleshooting.

---

## 2. Essential Tools and Workspace Setup

- **Breadboard, jumper wires**
- **Multimeter** (for voltage, current, resistance)
- **Oscilloscope** (even a USB one)
- **Soldering iron, solder**
- **Wire cutters/strippers**
- **Power supply (bench or wall wart)**

---

## 3. Understanding Electricity and Safety

- **Voltage (V), Current (A), Resistance (Ω)**
- **Ohm’s Law:** V = I * R
- Always turn off power before changing wiring.
- Use low voltages for experiments (<12V).

---

## 4. Identifying Components

- **Resistors:** Color bands (value)
- **Capacitors:** µF or nF, polarity for electrolytic
- **ICs:** Pin 1 marker; datasheets are your friend
- **Op-amps:** Used for filters, buffers, and mixing

---

## 5. Breadboarding and Prototyping

- Push components into breadboard, use jumper wires
- Avoid shorts, double-check power rails

---

## 6. Soldering Basics

- Use a clean, tinned tip
- Heat both pad and lead, apply solder
- Don’t breathe fumes, work in ventilated area

---

## 7. Using a Multimeter and Oscilloscope

- Multimeter: Check power, continuity, component values
- Oscilloscope: Visualize waveforms, measure frequency, check for noise

---

## 8. Static Electricity and ESD Safety

- Touch grounded object before handling ICs
- Use anti-static wrist strap if possible

---

## 9. Your First Circuit: Blinking an LED

- Connect a resistor (220Ω) and LED in series from +5V to ground, with a switch.

---

## 10. Exercises

- Identify and measure resistors and capacitors in your kit.
- Build and test the LED circuit.
- Use your multimeter to check voltages on your breadboard.

---

**Next:**
*hybrid_synth_09_dac_audio_output.md* — Getting sound out of your code and into the real world.

---


## DACs and Audio Output: From Bits to Sound

---

### Table of Contents

1. What is a DAC and Why Do We Need One?
2. Types of DACs for DIY Synths
3. Choosing a DAC for Your Project
4. Theory: How a DAC Converts Digital to Analog
5. Wiring Up Your DAC (PCM5102, MCP4922, etc.)
6. Testing DAC Output with a PC or Arduino
7. Interfacing DACs with the Raspberry Pi
8. First Sound: Sending Samples from C
9. Troubleshooting: No Sound, Distortion, Noise
10. Exercises: Making Your First Real Audio

---

## 1. What is a DAC and Why Do We Need One?

A **Digital-to-Analog Converter (DAC)** turns your code's numbers into real-world voltages (analog audio).
**Without a DAC, your synth can't make sound!**
The DAC is the bridge between your digital code and the analog world.

---

## 2. Types of DACs for DIY Synths

- **I2S DACs (e.g., PCM5102):** High-quality, stereo audio, used in commercial gear.
- **SPI DACs (e.g., MCP4922):** Simple, mono/stereo, lower sample rates.
- **PWM output:** "Fakes" a DAC; not recommended for high-quality synths.

---

## 3. Choosing a DAC for Your Project

**Recommended:**
- **PCM5102 (I2S):** Cheap, high quality, lots of guides.
- **MCP4922 (SPI):** Good for learning, easier to breadboard.
- **PCM1794, ES9023, etc.:** For advanced users.

**Consider:**
- Sample rate (44.1kHz or higher)
- Bit depth (16, 24 bits)
- Mono or stereo
- Breadboard friendliness

---

## 4. Theory: How a DAC Converts Digital to Analog

- Code generates discrete samples (integers or floats).
- DAC receives samples at a fixed sample rate (e.g., 44100 per second).
- DAC outputs a voltage corresponding to each sample.
- Output is (usually) centered around 0V (for audio).

---

## 5. Wiring Up Your DAC (PCM5102, MCP4922, etc.)

**PCM5102 (I2S):**
- Connects to Pi's I2S pins (BCLK, LRCK, DIN, GND, 3.3V)
- Ready-made modules available

**MCP4922 (SPI):**
- Connects to SPI lines (SCK, MOSI, CS, LDAC, Vref, GND, Vcc)
- Needs voltage reference (often 3.3V or 5V)

**Check datasheets for pinouts! Always double-check Vcc and GND.**

---

## 6. Testing DAC Output with a PC or Arduino

- Before connecting to the Pi, test your DAC with a simple Arduino or PC project.
- Send a ramp, triangle, or constant value and measure with a multimeter or listen to output.
- Confirm you see expected voltages or hear expected tones.

---

## 7. Interfacing DACs with the Raspberry Pi

- **PCM5102:** Use Pi's I2S hardware (bare-metal or Linux driver).
- **MCP4922:** Bit-bang SPI in C or use SPI hardware.
- Use level shifters if your Pi/DAC voltages don't match.

**Note:** Many tutorials exist for both Pi and Arduino—read a few for confidence!

---

## 8. First Sound: Sending Samples from C

- Modify your sound engine to output to the DAC instead of PortAudio.
- Write a function to fill a buffer with samples and send them out at the correct rate.
- **On Pi:** Use a timer interrupt or DMA (see Circle or Ultibo frameworks).

---

## 9. Troubleshooting: No Sound, Distortion, Noise

- **Check power:** Is the DAC getting the right voltage?
- **Check connections:** Are wires correct, no shorts?
- **Use scope/multimeter:** Is there a signal at the output pin?
- **Buffer underruns:** Make sure your code is filling buffers fast enough.
- **Distortion:** Check scaling and bit depth.

---

## 10. Exercises: Making Your First Real Audio

- Wire up your DAC and send a 1kHz sine wave from the Pi.
- Try outputting a ramp, triangle, and square wave.
- Sweep the frequency and hear the change.
- Try mixing two frequencies.

---

**Next:**
*hybrid_synth_10_analog_filters_vcas.md* — Shape your sound with analog filters and amplifiers.

---

## Analog Filters and VCAs: Giving Your Synth Its Voice

---

### Table of Contents

1. Why Analog? Character and Color
2. What Is a Filter (VCF)? Types and Theory
3. What Is a VCA? Why You Need One
4. Choosing Filter/VCA Circuits: Classic Designs and Modern ICs
5. Breadboarding a Simple Lowpass Filter
6. Building a Basic VCA (Options)
7. Powering Your Analog Section (+/-12V, Single Supply)
8. Testing Your Filter and VCA
9. Integrating DAC → Filter → VCA → Output
10. Debugging Analog Circuits
11. Exercises and Experiments

---

## 1. Why Analog? Character and Color

Analog filters/VCA give warmth, presence, and "life" to sound.
Digital can sound sterile—analog shapes and saturates in unique ways.

---

## 2. What Is a Filter (VCF)? Types and Theory

- **VCF = Voltage Controlled Filter**
- Types: Lowpass (removes highs), Highpass, Bandpass, Notch
- Resonance: Boosts frequencies near cutoff

**Popular Designs:**
- Sallen-Key
- Moog Ladder
- State-Variable
- OTA (e.g., LM13700, AS3320)

---

## 3. What Is a VCA? Why You Need One

- **VCA = Voltage Controlled Amplifier**
- Shapes the volume of each note (envelope, LFO, etc.)
- Can be simple (op-amp, FET) or complex (OTA, SSM2164, BA6110, etc.)

---

## 4. Choosing Filter/VCA Circuits

- **IC-based:** AS3320, SSM2044, LM13700 (OTA), BA6110
- **Discrete:** Moog, MS-20, Steiner-Parker—see online schematics
- **DIY:** Simple op-amp lowpass for testing

**Datasheets and synth DIY forums are your best friends!**

---

## 5. Breadboarding a Simple Lowpass Filter

- Use a Sallen-Key or RC circuit for quick test:
```text
Input → [10kΩ] →+----→ Output
                |
               [10nF]
                |
               GND
```
- For more “synthy” sound, try OTA or ladder filter.

---

## 6. Building a Basic VCA (Options)

- LM13700 datasheet shows a simple VCA.
- JFET or opto-isolator circuits for basic control.

---

## 7. Powering Your Analog Section

- Most synth ICs need ±12V or ±15V.
- Use a dual-output bench supply or build one from DC-DC converters.
- Keep analog and digital grounds connected at one point.

---

## 8. Testing Your Filter and VCA

- Feed a sine/saw from your DAC.
- Sweep cutoff and resonance (potentiometer).
- Modulate amplitude with a knob (VCA control) or envelope from Pi.

---

## 9. Integrating DAC → Filter → VCA → Output

- DAC output → filter input → VCA input → output buffer → headphones/speakers.
- Use a scope to watch the waveform at each stage.

---

## 10. Debugging Analog Circuits

- Check power rails.
- Measure voltages at IC pins.
- Look for oscillation, noise, or unstable signals.
- Compare to schematic expectations.

---

## 11. Exercises and Experiments

- Build a Sallen-Key lowpass and sweep its cutoff.
- Try swapping op-amps (TL072, NE5532, etc.).
- Add resonance to your filter.
- Experiment with overdriving filter input for distortion.

---

**Next:**
*hybrid_synth_11_bare_metal_pi_setup_toolchain.md* — Bootstrapping your synth on the Raspberry Pi.

---

## Bare Metal on the Raspberry Pi: Setup and Toolchain

---

### Table of Contents

1. Bare Metal vs Linux: Why Go Bare Metal?
2. What Happens When the Pi Boots?
3. Toolchain: Installing ARM GCC and Tools
4. Bare-Metal Frameworks: Circle, Ultibo, or DIY?
5. Your First Bare-Metal Program: Blinking an LED
6. Serial Debugging (UART)
7. Building, Flashing, and Testing
8. Exercises

---

## 1. Bare Metal vs Linux: Why Go Bare Metal?

- **Bare Metal:** No OS, your code runs directly on the hardware.
    - Fast boot, low latency, full control, tiny size.
- **Linux:** Easier drivers, more powerful, but more overhead.

---

## 2. What Happens When the Pi Boots?

- GPU runs first, loads `bootcode.bin` and `kernel.img` from SD card.
- Your code (as `kernel.img`) runs as the only program.

---

## 3. Toolchain: Installing ARM GCC and Tools

**On Solus:**
```bash
sudo eopkg install arm-none-eabi-gcc binutils-arm-none-eabi make
```

---

## 4. Bare-Metal Frameworks

- **Circle:** C++ framework with audio, USB, and more. [GitHub](https://github.com/rsta2/circle)
- **Ultibo:** Pascal-based, easy for Pi, but less C-focused.
- **DIY:** Write your own linker script and startup code (advanced).

---

## 5. Your First Bare-Metal Program: Blinking an LED

- Use Circle's `circle-examples/blinky` as a starting point.
- Build with `make`, copy `kernel.img` to SD card, insert in Pi, power up.

---

## 6. Serial Debugging (UART)

- Connect USB-UART adapter to Pi GPIO.
- Use a terminal (minicom, screen) to view debug prints.
- Add `printf` or `puts` calls in your code for status messages.

---

## 7. Building, Flashing, and Testing

- `make` builds your code.
- Copy `kernel.img` to SD card root.
- Power-cycle Pi to load new code.
- Use UART or LED to verify it's running.

---

## 8. Exercises

- Build and run blinky on your Pi.
- Modify code to print "Hello, Synth!" over UART.
- Try toggling GPIO pins in a loop.

---

**Next:**
*hybrid_synth_12_crossplatform_audio_engine.md* — Making your audio engine run on both PC and Pi.

---

## Cross-Platform Audio Engine: PC and Pi

---

### Table of Contents

1. Why Make Code Portable?
2. Abstracting Audio Output: Hardware Layers
3. Structuring Your Code for Portability
4. Writing Platform-Specific Audio Drivers (PC: PortAudio, Pi: I2S/SPI)
5. Handling Endianness and Bit Depth
6. Managing Audio Buffers and Timing
7. Testing Your Engine on Both Platforms
8. Exercises

---

## 1. Why Make Code Portable?

- Write once, run everywhere.
- Debug audio logic on PC, then deploy on Pi.
- Only swap the hardware access layer.

---

## 2. Abstracting Audio Output

- Use `audio_output_init()`, `audio_output_write(buffer, frames)` in your main code.
- Implement these differently for PC (PortAudio) and Pi (I2S/SPI).

---

## 3. Structuring Your Code

- `src/` for platform-independent logic.
- `pc_test/audio_output_portaudio.c` for PC.
- `pi_baremetal/audio_output_i2s.c` for Pi.
- Use `#ifdef` or build system to select.

---

## 4. Writing Platform-Specific Audio Drivers

- **PC:** Use PortAudio (see previous docs).
- **Pi:** Use Circle's I2S or SPI classes, or roll your own.

---

## 5. Handling Endianness and Bit Depth

- Make sure your sample formats match (16-bit, 24-bit, etc.).
- Convert floats to integers carefully.

---

## 6. Managing Audio Buffers and Timing

- Use double buffering or DMA if possible.
- On Pi, use timer interrupt or Circle's audio buffer callback.

---

## 7. Testing Your Engine

- Test all synthesis and mixing on PC first.
- When porting, debug with UART and scope.
- Compare output from both platforms for correctness.

---

## 8. Exercises

- Refactor your code to use an audio abstraction layer.
- Implement audio output for both PC and Pi.
- Test a 4-voice synth on both platforms.

---

**Next:**
*hybrid_synth_13_testing_debugging_integration.md* — Finding and fixing bugs, and making your synth robust.

---

## Testing, Debugging, and Integration

---

### Table of Contents

1. Why Testing and Debugging Matter
2. Unit Testing in C (Simple Approaches)
3. Debugging Audio Code: Printfs and Visualization
4. Debugging Embedded Code: UART, LEDs, Oscilloscope
5. Debugging Analog Circuits: Multimeter and Scope
6. Integration Workflow: Step-by-Step
7. Common Bugs and How to Fix Them
8. Exercises and Challenges

---

## 1. Why Testing and Debugging Matter

- Bugs are inevitable; catching them early saves time.
- Embedded and analog systems are tricky—be methodical.

---

## 2. Unit Testing in C

- Write small test programs for each function.
- Example: Test your oscillator function with known inputs.

---

## 3. Debugging Audio Code

- Use `printf()` to log variable values.
- Output buffers to files and view in Audacity.
- Listen for clicks, dropouts, or distortion.

---

## 4. Debugging Embedded Code

- Use UART for status printout (`printf("voice %d active\n", v);`)
- Blink LEDs for simple status/error codes.
- Use oscilloscope to probe DAC output, GPIO, etc.

---

## 5. Debugging Analog Circuits

- Check all voltages and grounds.
- Trace signal path with oscilloscope.
- Compare to expected waveforms.

---

## 6. Integration Workflow

- Test PC code first, then port to Pi.
- Test digital and analog sections separately.
- Integrate and test together, fixing issues as they arise.

---

## 7. Common Bugs and Fixes

- **Silence:** Check power, connections, buffer underruns.
- **Distortion:** Check scaling, clipping, filter stability.
- **Noise:** Separate digital/analog grounds, shield cables.
- **Crashes:** Check pointer use, memory allocation in C.

---

## 8. Exercises

- Write a test for your envelope function.
- Use UART to debug voice allocation on Pi.
- Record and analyze your DAC output waveform.

---

**Next:**
*hybrid_synth_14_expanding_controls_midi_ui.md* — Control your synth: MIDI, buttons, and basic UI.

---



## Expanding Controls: MIDI, Buttons, and User Interface

---

### Table of Contents

1. Why Add Controls? Expressivity and Playability
2. MIDI Basics: What, Why, and How
3. Reading MIDI in C (PC and Pi)
4. Wiring MIDI Input (Opto-Isolator Circuits)
5. Parsing MIDI Messages (Note On/Off, Velocity)
6. Adding Buttons and Encoders (GPIO)
7. Basic UI: Text LCD or OLED Displays
8. User Interface Code Structure
9. Exercises and Experiments

---

## 1. Why Add Controls?

- Play your synth with a keyboard, DAW, or knob.
- Make it interactive and expressive.

---

## 2. MIDI Basics

- **MIDI = Musical Instrument Digital Interface**
- Simple serial protocol (31.25 kbaud, 5-pin DIN)
- Common messages: Note On, Note Off, Control Change, Pitch Bend

---

## 3. Reading MIDI in C

- **PC:** Use PortMIDI, RtMidi, or ALSA MIDI.
- **Pi:** Read from UART, parse bytes.

---

## 4. Wiring MIDI Input

- Use 6N138/6N137 opto-isolator for safe input.
- Standard circuit: 220Ω resistors, DIN jack, opto, pull-up resistor.

---

## 5. Parsing MIDI Messages

- MIDI messages are bytes: 0x90 (Note On), note number, velocity.
- State machine to handle running status and multi-byte messages.

---

## 6. Adding Buttons and Encoders

- Use Pi GPIO or Arduino for prototyping.
- Poll or interrupt-driven reads.

---

## 7. Basic UI: Text LCD/OLED

- 16x2 LCD: Easy, cheap, lots of guides.
- I2C/SPI OLED: More modern, supports graphics.

---

## 8. User Interface Code Structure

- Simple event loop: check MIDI, buttons, update display.
- Menu system for patch editing.

---

## 9. Exercises

- Wire up MIDI input and play notes from a keyboard.
- Connect a button to GPIO and trigger a sound.
- Display voice status on LCD.

---

**Next:**
*hybrid_synth_15_documenting_sharing_next_steps.md* — Documenting, sharing, and going further.

---


## Documenting, Sharing, and Next Steps

---

### Table of Contents

1. Why Documentation Matters
2. Writing Good READMEs and Code Comments
3. Sharing Your Project: GitHub Best Practices
4. Community: Forums, Social Media, and Collaborators
5. Open Source Licenses and Ethics
6. Expanding Your Synth: Modularity and New Features
7. Continuing Your Learning: Books, Courses, and Makerspaces
8. Your Portfolio: Presenting Your Work
9. Final Exercises and Challenges

---

## 1. Why Documentation Matters

- Makes your project usable by others (and future-you).
- Saves time, builds community, and helps you debug.

---

## 2. Writing Good READMEs and Code Comments

- Explain what each file/module does.
- At the top of each file: who wrote it, what it does, license.
- Inline comments for tricky code or design choices.

---

## 3. Sharing Your Project: GitHub Best Practices

- Use issues, pull requests, and releases.
- Tag versions (v0.1, v1.0, etc.).
- Write clear commit messages.

---

## 4. Community

- Share progress on forums (r/synthdiy, EEVblog, Muff Wiggler).
- Ask questions and be open to feedback.
- Collaborate on code and hardware.

---

## 5. Open Source Licenses and Ethics

- Choose a license: MIT, GPL, CC, etc.
- Give credit to others’ work.
- Respect copyright.

---

## 6. Expanding Your Synth

- Add more voices, new filter types, effects, sequencers.
- Build a full enclosure, custom panel, or even a PCB.
- Experiment with microcontrollers, FPGA, or custom analog circuits.

---

## 7. Continuing Your Learning

- Recommended books:
  - "The Art of Electronics" (Horowitz & Hill)
  - "Making Embedded Systems" (O'Reilly)
  - "Audio Programming Book" (MIT)
- Online courses: Coursera, Udemy, YouTube synth DIY channels.
- Find a local makerspace or hacklab.

---

## 8. Your Portfolio

- Document your build: photos, videos, write-ups.
- Share code and schematics.
- Present at meetups, workshops, or online.

---

## 9. Final Exercises and Challenges

- Publish your synth on GitHub with a full README.
- Write a blog post about your build.
- Teach someone else what you’ve learned.
- Invent a new feature and add it!

---

**Congratulations! You’ve completed the Hybrid Synthesizer Project Course.
Keep building, keep learning, and share your music with the world!**

---
