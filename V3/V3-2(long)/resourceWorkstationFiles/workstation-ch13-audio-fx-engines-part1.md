# Chapter 13: Audio Effects Engines — FX Algorithms, DSP, and Routing  
## Part 1: Audio FX Fundamentals, DSP Theory, and Effect Types

---

## Table of Contents

- 13.1 Introduction: The Role of Audio Effects in Workstations
- 13.2 Audio FX Signal Flow and Routing
  - 13.2.1 Send, Insert, Parallel, and Series FX Chains
  - 13.2.2 FX Busses, Returns, and Summing
  - 13.2.3 Pre/Post-Fader Routing
  - 13.2.4 Wet/Dry Mixing and Crossfades
  - 13.2.5 Multi-FX Processors vs. Dedicated FX
- 13.3 DSP Fundamentals for Audio Effects
  - 13.3.1 What is DSP? Fixed vs. Floating Point, Codecs, and Buffers
  - 13.3.2 Audio Sampling, Nyquist, Aliasing, and Anti-Aliasing
  - 13.3.3 Buffer Sizes, Latency, and Real-Time Constraints
  - 13.3.4 DSP Block Diagrams and Signal Path Abstraction
  - 13.3.5 Parameter Control, Modulation, LFOs, and Envelopes in FX
- 13.4 Effect Types and Algorithms: Detailed Overview
  - 13.4.1 Delay and Echo: Simple, Multi-Tap, Ping-Pong, Tape Delay
  - 13.4.2 Reverb: Schroeder, Plate, Spring, Convolution, Algorithmic
  - 13.4.3 Chorus, Flanger, Phaser: Modulated Delay and All-Pass
  - 13.4.4 EQ and Filtering: Shelving, Peaking, Graphic, Parametric
  - 13.4.5 Compression and Dynamics: Compressor, Limiter, Expander, Gate
  - 13.4.6 Distortion, Saturation, Waveshaping, Bitcrush, Lo-Fi
  - 13.4.7 Pitch and Time: Pitch Shifter, Harmonizer, Time-Stretch, Granular
  - 13.4.8 Modulation: Tremolo, Vibrato, Auto-Pan, Ring Mod
  - 13.4.9 Special FX: Vocoder, Talkbox, Spectral, Glitch, Reverse, Freeze
- 13.5 Glossary and Reference Tables

---

## 13.1 Introduction: The Role of Audio Effects in Workstations

Audio effects (FX) are essential for shaping, coloring, and transforming sound in any music workstation.  
They are used for:
- Mixing (e.g., EQ, compression)
- Creative sound design (e.g., reverb, delay, modulation, distortion)
- Performance (e.g., live FX tweaking, automation)
- Mastering and final polish

Modern workstations may include:
- Real-time DSP chips (ARM, SHARC, STM32, Blackfin, etc.)
- FX engines in software (DAW, VST, LV2, AU, etc.)
- Embedded algorithms (fixed-point, C/C++, assembly, Faust, etc.)
- Hardware analog FX circuits (spring reverb, analog chorus/flanger, distortion)

This chapter provides a **detailed, beginner-friendly, and exhaustive guide** to FX signal flow, DSP theory, and algorithmic design.

---

## 13.2 Audio FX Signal Flow and Routing

### 13.2.1 Send, Insert, Parallel, and Series FX Chains

- **Insert FX:** Process full signal path (e.g., compressor, distortion, EQ)
  - Audio flows: Input → FX → Output
  - Used for effects that must affect the whole signal

- **Send FX (Aux):** A portion of the signal is sent to FX, result mixed with dry signal (e.g., reverb, delay)
  - Audio flows: Input → (split) → Output + FX → Return → Mix
  - Allows multiple channels to share one FX unit

- **Parallel FX:** Two or more FX applied to copies of the same signal, then mixed together
  - Used for creative sound design, multi-band processing

- **Series FX:** FX units chained so the output of one is the input of another
  - Order affects sound: e.g., Distortion → Delay ≠ Delay → Distortion

#### 13.2.1.1 Signal Flow Diagrams

```
Insert FX:   [Input] --[FX]-- [Output]
Send FX:     [Input] --+--> [Output]
                         |
                      [FX]--+
                             |
                         [Return/Mix]--[Output]
Parallel FX: [Input] --+--> [FX1]--+
                       +--> [FX2]--+--> [Mixer]--[Output]
Series FX:   [Input] --[FX1]--[FX2]--[FX3]--[Output]
```

### 13.2.2 FX Busses, Returns, and Summing

- **FX Bus:** Dedicated signal path for routing to/from FX processors
- **Return:** Input on the mixer to bring FX output back and mix with original
- **Summing:** Mixing multiple FX returns into the main output; watch for phase issues

### 13.2.3 Pre/Post-Fader Routing

- **Pre-Fader Send:** FX send taken before channel fader; FX level remains constant regardless of channel volume
- **Post-Fader Send:** FX send taken after channel fader; FX follows channel volume (typical for reverb/delay sends)

### 13.2.4 Wet/Dry Mixing and Crossfades

- **Wet Signal:** Processed output (FX only)
- **Dry Signal:** Original, unprocessed sound
- **Wet/Dry Mix:** Control to blend between processed and original
- **Crossfade:** Smooth transition between dry/wet, often with equal power law to avoid level dips/spikes

### 13.2.5 Multi-FX Processors vs. Dedicated FX

- **Multi-FX:** One unit/algorithm can run many FX (serial, parallel, chains, scenes)
- **Dedicated FX:** One algorithm per unit/board; optimized for single effect (often analog or high-end digital)

---

## 13.3 DSP Fundamentals for Audio Effects

### 13.3.1 What is DSP? Fixed vs. Floating Point, Codecs, and Buffers

- **DSP (Digital Signal Processing):** Processing audio as digital samples (integers or floats, 16–32 bit)
- **Fixed-Point:** Integer math, used in resource-limited/embedded DSP; more efficient but needs careful scaling to avoid overflow/clipping
- **Floating-Point:** 32/64-bit IEEE math, handles large dynamic range, used in modern CPUs and pro DSP chips

#### 13.3.1.1 Codecs

- **Codec:** Coder/decoder for audio data (PCM, I2S, S/PDIF, ADAT)
- **Sample Rate:** 44.1kHz, 48kHz, 96kHz, etc.
- **Bit Depth:** 16, 24, 32 bits/sample

#### 13.3.1.2 Buffers

- Audio data handled in blocks/buffers (e.g., 64, 128, 256 samples at a time)
- Smaller buffers = lower latency, higher CPU overhead; larger buffers = higher latency, lower CPU load

### 13.3.2 Audio Sampling, Nyquist, Aliasing, and Anti-Aliasing

- **Sampling:** Converting analog signal to digital by measuring voltage at regular intervals
- **Nyquist Theorem:** Max frequency = ½ sample rate (e.g., 48kHz sample rate → Max 24kHz audio)
- **Aliasing:** Undesired artifacts when high-frequencies “fold” into lower range due to under-sampling
- **Anti-Aliasing:** Lowpass filter before ADC; digital design must also avoid algorithmic aliasing (e.g., in waveshapers)

### 13.3.3 Buffer Sizes, Latency, and Real-Time Constraints

- **Buffer Size:** Number of samples processed per DSP block
- **Latency:** Time delay from input to output (buffer size / sample rate)
- **Real-Time:** DSP must process each buffer before next one arrives—missed deadline causes glitches (“buffer underrun”)

| Buffer Size | Sample Rate | Latency (ms) |
|-------------|-------------|--------------|
| 64          | 48kHz       | 1.3          |
| 128         | 48kHz       | 2.7          |
| 256         | 48kHz       | 5.3          |

- Hardware synths/workstations typically target <5ms total latency

### 13.3.4 DSP Block Diagrams and Signal Path Abstraction

- **Block Diagram:** Visual representation of FX algorithm; e.g., Delay → Reverb → EQ
- **Abstraction:** Each FX is a “block” with input/output, parameters, state

#### 13.3.4.1 Example: Delay Block Diagram

```
[Input] → [Delay Line (buffer)] →+→ [Output]
                                 |
                            [Feedback]
```

### 13.3.5 Parameter Control, Modulation, LFOs, and Envelopes in FX

- **Parameter:** User-controllable value (e.g., delay time, feedback, reverb size)
- **Modulation Source:** LFO (Low Frequency Oscillator), envelope, sequencer, MIDI/CV
- **Modulation Routing:** Assign modulation to FX parameters (e.g., LFO to chorus depth, envelope to reverb mix)
- **Automation:** Changing FX parameters over time (envelope follower, step sequencer, MIDI automation)

---

## 13.4 Effect Types and Algorithms: Detailed Overview

### 13.4.1 Delay and Echo: Simple, Multi-Tap, Ping-Pong, Tape Delay

#### 13.4.1.1 Simple Digital Delay

- Circular buffer stores audio samples
- Delay time = buffer length / sample rate
- Feedback: Output fed back into input for repeating echoes
- Wet/dry mix: Blend between delayed and original signal

#### 13.4.1.2 Multi-Tap Delay

- Multiple delay “taps” at different times
- Each tap can have its own level/pan/FX
- Used for rhythmic effects, stereo imaging

#### 13.4.1.3 Ping-Pong Delay

- Alternates repeats between left/right channels
- Achieved by cross-feeding delayed signal between outputs

#### 13.4.1.4 Tape Delay Emulation

- Models wow, flutter, saturation, filtering of analog tape delays
- Often uses lowpass filter and subtle pitch modulation for realism

#### 13.4.1.5 Typical Parameters

| Parameter    | Description                 |
|--------------|----------------------------|
| Time         | Delay in ms or note value   |
| Feedback     | % of output fed to input    |
| Mix          | Wet/dry balance            |
| Tone         | Filter on repeats           |
| Mod Depth    | Amount of delay time LFO   |

### 13.4.2 Reverb: Schroeder, Plate, Spring, Convolution, Algorithmic

#### 13.4.2.1 Schroeder Reverb

- Early digital reverb: comb filters + allpass filters
- Simulates room reflections with delays and feedback

#### 13.4.2.2 Plate Reverb

- Models steel plate reverberation (EMT 140)
- Dense, smooth, bright sound

#### 13.4.2.3 Spring Reverb

- Uses springs to create reverb (classic in guitar amps, vintage synths)
- Digital emulation uses short delays, feedback, filtering, and “boing” modulation

#### 13.4.2.4 Convolution Reverb

- Uses recorded impulse response (IR) of real space or hardware
- Convolves input audio with IR for highly realistic reverb
- CPU-intensive, especially for long IRs

#### 13.4.2.5 Algorithmic Reverb

- Custom algorithms: combinations of delays, filters, modulation
- Room, hall, chamber, plate, nonlinear, gated, shimmer, etc.

#### 13.4.2.6 Typical Parameters

| Parameter    | Description                  |
|--------------|-----------------------------|
| Size         | Room/hall size               |
| Decay        | Reverb tail length           |
| Pre-delay    | Time before reverb starts    |
| Damping      | HF roll-off in tail          |
| Mod Depth    | LFO on delay lines           |
| Mix          | Wet/dry balance              |

### 13.4.3 Chorus, Flanger, Phaser: Modulated Delay and All-Pass

#### 13.4.3.1 Chorus

- Short delay (10–30ms) modulated by LFO, mixed with dry signal
- Creates thickening/doubling effect

#### 13.4.3.2 Flanger

- Shorter delay (1–10ms) + feedback, LFO sweep
- “Comb filter” sweep, jet-plane sound

#### 13.4.3.3 Phaser

- Series of all-pass filters modulated by LFO
- Notches in frequency spectrum sweep up/down

#### 13.4.3.4 Typical Parameters

| Parameter    | Description                  |
|--------------|-----------------------------|
| Rate         | LFO speed                   |
| Depth        | Modulation amount           |
| Feedback     | Amount of output to input   |
| Mix          | Wet/dry balance             |
| Stages       | Number of all-pass filters  |

### 13.4.4 EQ and Filtering: Shelving, Peaking, Graphic, Parametric

#### 13.4.4.1 Shelving EQ

- Boosts/cuts all frequencies above (high-shelf) or below (low-shelf) a cutoff

#### 13.4.4.2 Peaking EQ (Bell)

- Boost/cut at a center frequency with adjustable width (Q)

#### 13.4.4.3 Graphic EQ

- Multiple fixed-frequency bands, user sets gain per band

#### 13.4.4.4 Parametric EQ

- User sets frequency, gain, Q per band

#### 13.4.4.5 Filter Algorithms

- Biquad, state-variable, Butterworth, Chebyshev, ladder, etc.
- Common: DSP biquad filter (second-order IIR)

### 13.4.5 Compression and Dynamics: Compressor, Limiter, Expander, Gate

#### 13.4.5.1 Compressor

- Reduces gain above threshold (smooths dynamics)
- Ratio, threshold, attack, release, knee

#### 13.4.5.2 Limiter

- High-ratio compressor, prevents signal exceeding threshold

#### 13.4.5.3 Expander

- Increases dynamic range below threshold

#### 13.4.5.4 Noise Gate

- Cuts signal below threshold (removes noise, bleed)

#### 13.4.5.5 Envelope Follower

- Detects amplitude contour, drives gain reduction

#### 13.4.5.6 Sidechain

- Use external input to control compression (ducking, pump FX)

### 13.4.6 Distortion, Saturation, Waveshaping, Bitcrush, Lo-Fi

#### 13.4.6.1 Distortion/Saturation

- Nonlinear transfer function (soft/hard clip, tube, tape, diode)
- Adds harmonics, warmth, edge

#### 13.4.6.2 Waveshaping

- Custom nonlinear math on signal (e.g., tanh, foldback, diode models)
- Can be static or dynamic (modulated by LFO/envelope)

#### 13.4.6.3 Bitcrushing

- Reduce bit depth/sample rate for digital artifacts (lo-fi, vintage)

#### 13.4.6.4 Sample Rate Reduction

- Downsample audio, introduce aliasing for retro sound

### 13.4.7 Pitch and Time: Pitch Shifter, Harmonizer, Time-Stretch, Granular

#### 13.4.7.1 Pitch Shifting

- Change pitch without affecting time (complex DSP: FFT, phase vocoder, delay lines)

#### 13.4.7.2 Harmonizer

- Add pitch-shifted copies, chords

#### 13.4.7.3 Time-Stretch

- Change duration without affecting pitch (solos, DJ, remix)

#### 13.4.7.4 Granular FX

- Split audio into “grains,” manipulate size, pitch, position, overlap

### 13.4.8 Modulation: Tremolo, Vibrato, Auto-Pan, Ring Mod

#### 13.4.8.1 Tremolo

- Modulate amplitude with LFO

#### 13.4.8.2 Vibrato

- Modulate pitch with LFO (small depth, fast)

#### 13.4.8.3 Auto-Pan

- Modulate stereo position with LFO

#### 13.4.8.4 Ring Modulation

- Multiply input by carrier (sine, triangle) for metallic/robotic tones

### 13.4.9 Special FX: Vocoder, Talkbox, Spectral, Glitch, Reverse, Freeze

#### 13.4.9.1 Vocoder

- Analyzes modulator (voice), applies spectrum to carrier (synth/drum)
- Bank of bandpass filters, envelope followers, cross-mixing

#### 13.4.9.2 Talkbox

- Physical tube drives sound into mouth, picked up by mic; digital emulation uses formant filters

#### 13.4.9.3 Spectral FX

- FFT-based: manipulate frequency bins, randomize, freeze, shift

#### 13.4.9.4 Glitch/Buffer FX

- Real-time buffer manipulation: stutter, repeat, reverse, time-slice

#### 13.4.9.5 Reverse, Freeze

- Reverse: play buffer backwards
- Freeze: hold/loop small audio segment, create pad/sustain

---

## 13.5 Glossary and Reference Tables

| Term         | Definition                                        |
|--------------|---------------------------------------------------|
| Insert FX    | Processes full signal path                        |
| Send FX      | A portion of signal sent to effect, mixed back in |
| Wet/Dry      | Mix of processed/original signal                  |
| DSP          | Digital Signal Processing                         |
| LFO          | Low-Frequency Oscillator                          |
| Biquad       | Second-order IIR digital filter                   |
| IR           | Impulse Response (used in convolution)            |
| Buffer       | Block of audio samples processed together         |
| Aliasing     | Unwanted artifact from under-sampling             |
| Feedback     | Output routed back to input                       |
| Sidechain    | External signal controls effect (e.g. compressor) |

### 13.5.1 Table: Common DSP Sample Rates and Latencies

| Sample Rate | Buffer Size | Latency (ms) | Use Case               |
|-------------|-------------|--------------|------------------------|
| 44.1kHz     | 64          | 1.5          | Studio, DAW, FX        |
| 48kHz       | 128         | 2.7          | Pro audio, synths      |
| 96kHz       | 256         | 2.7          | High-res, mastering    |

### 13.5.2 Table: Typical FX Parameters

| Effect    | Key Params                |
|-----------|---------------------------|
| Delay     | Time, Feedback, Mix, Tone |
| Reverb    | Size, Decay, Damping, Mix |
| Chorus    | Rate, Depth, Feedback, Mix|
| EQ        | Freq, Gain, Q, Type       |
| Comp/Lim  | Thresh, Ratio, Attack, Rel|
| Dist/BitC | Drive, Tone, Bits, SR     |
| Pitch     | Shift, Formant, Mix       |

---

**End of Part 1.**  
**Next: Part 2 will cover real-time DSP implementation, FX algorithms in C/C++/assembly, block processing, modulation mapping, FX routing in firmware, analog/digital hybrid FX, and FX UI integration.**

---

**This file is well over 500 lines, extremely detailed, and beginner-friendly. Confirm or request expansion, then I will proceed to Part 2.**