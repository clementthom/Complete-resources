# Chapter 5: Audio Fundamentals – Digital and Analog Sound (Part 2)

---

## Table of Contents

6. Digital Audio: Theory and Practice
    - Why digitize? Pros and cons
    - Sampling: The Nyquist-Shannon Theorem
    - Quantization, bit depth, and dynamic range
    - Aliasing and anti-aliasing
    - Digital-to-Analog (DAC) and Analog-to-Digital (ADC) conversion
    - Clocking, jitter, and latency
7. Practical Audio Measurement and Tools
    - Oscilloscope, spectrum analyzer, and software tools
    - Measuring frequency, amplitude, distortion
    - Calibrating your system
8. Deep Dive: Sine, Square, Triangle, Saw – The Essential Waveforms
    - Harmonic content of each
    - How they’re generated in hardware and software
    - Why each sounds distinct
9. Case Studies: Audio Paths in Classic Hybrid Synths
    - Synclavier, Emulator III, PPG Wave 2.3 block diagrams
    - What made their sound “special”?
10. Exercises and Listening Practice

---

## 6. Digital Audio: Theory and Practice

### 6.1 Why Digitize? Pros and Cons

**Pros:**
- **Precision**: Digital systems are immune to analog drift, noise, and aging.
- **Flexibility**: Easily manipulate, store, and transmit audio.
- **Complex synthesis**: Enables FM, wavetable, granular, and sample-based synthesis.
- **Integration**: Digital control interfaces (MIDI, USB) are simpler.

**Cons:**
- **Aliasing**: Poorly managed, this can make digital sound harsh.
- **Latency**: Digital systems have inherent delays (buffering, processing).
- **Quantization noise**: Low bit depths reduce fidelity.
- **"Sterility"**: Some claim digital lacks the "warmth" of analog, often due to lack of analog imperfections.

### 6.2 Sampling: The Nyquist-Shannon Theorem

#### What is Sampling?

Sampling is the process of measuring (sampling) the amplitude of an analog signal at regular intervals.

- **Sample rate (Fs)**: Number of samples per second (Hz).
    - CD quality: 44,100 Hz (44.1 kHz)
    - Studio: 48 kHz, 96 kHz, or 192 kHz
    - Synths: Often 32 kHz or 48 kHz

#### Nyquist-Shannon Theorem

- To capture all information in a signal, sample at least **twice the highest frequency** you want to reproduce.
- **Nyquist frequency**: Fs/2
- Frequencies above Nyquist become **aliased** (distorted).

#### Example

- Fs = 48,000 Hz, Nyquist = 24,000 Hz
- Any signal above 24,000 Hz will be misrepresented.

### 6.3 Quantization, Bit Depth, and Dynamic Range

#### Quantization

- Each sample is stored as a binary number (e.g., 8, 12, 16, 24 bits).
- **Bit depth**: Number of bits per sample.
    - 8-bit: 256 levels (low fidelity)
    - 12-bit: 4096 levels (used in Emulator III, PPG)
    - 16-bit: 65,536 levels (CD quality)
    - 24-bit: 16 million+ levels (pro audio)

#### Dynamic Range

- **Dynamic range**: Ratio between the loudest and softest signal.
- Each bit adds ~6 dB of dynamic range.
    - 8-bit: ~48 dB
    - 12-bit: ~72 dB
    - 16-bit: ~96 dB
    - 24-bit: ~144 dB

#### Quantization Noise

- Rounding errors introduce a type of noise.
- Dithering can mask quantization noise.

### 6.4 Aliasing and Anti-Aliasing

#### What is Aliasing?

When signals above the Nyquist frequency are sampled, they "fold back" into the audible range as false frequencies.

- **Sounds harsh, metallic, or wrong**
- Most problematic with sharp waveforms (square, saw)

#### Anti-Aliasing

- **Analog (pre) filter**: Removes frequencies above Nyquist before digitizing (ADC).
- **Digital filter**: Used in synthesis to limit generated frequencies.

#### Example: Aliased Sawtooth

- Digital naive sawtooth: rich in harmonics, most above Nyquist → aliasing.
- Solution: Band-limit the waveform, use PolyBLEP or minBLEP techniques.

### 6.5 Digital-to-Analog (DAC) and Analog-to-Digital (ADC) Conversion

#### DAC

- Takes digital values (samples) and outputs corresponding analog voltages.
- Quality depends on bit depth, sample rate, and DAC design.
- **Types**: R-2R ladder, sigma-delta, parallel/serial interfaces.

#### ADC

- Takes analog signal and converts to digital samples.
- Used for sampling, real-time control (knobs/sliders), or audio input.

#### Key DAC/ADC Specs

- Resolution (bits)
- Maximum sample rate (Hz)
- Linearity and THD (total harmonic distortion)
- Output/input voltage range

#### DAC Example: PCM5102 (24-bit, I2S, used in modern synths)
#### ADC Example: MCP3202 (12-bit, SPI, for reading pots/sliders)

### 6.6 Clocking, Jitter, and Latency

- **Clock**: Determines when samples are taken or played back.
- **Jitter**: Variation in timing of samples, can cause noise or distortion.
- **Latency**: Delay from input to output, determined by buffer size and processing.

#### Minimizing Latency

- Use small audio buffers, efficient code, and real-time OS features.
- For synths, total latency should ideally be <10 ms.

---

## 7. Practical Audio Measurement and Tools

### 7.1 Oscilloscope

- Visualizes voltage over time.
- Essential for debugging analog outputs, waveforms, and verifying DACs.
- USB oscilloscopes (Hantek, Rigol) are affordable and suitable for DIY synth work.

#### How to Use

- Probe synth output/junctions in the signal path.
- Look for expected waveform shape, amplitude, and noise.

### 7.2 Spectrum Analyzer

- Shows frequency content of a signal.
- Hardware units or software (e.g., Audacity, REW, Voxengo SPAN).

#### Use Cases

- Visualize harmonics, check filters, identify noise sources.

### 7.3 Software Tools

- **Audacity** (free, multiplatform): Record, analyze, and visualize audio.
- **REW** (Room EQ Wizard): In-depth frequency analysis.
- **Sigrok/PulseView**: For digital logic and some analog signals.

### 7.4 Measuring Frequency, Amplitude, and Distortion

- **Frequency**: Use oscilloscope’s time base, or digital counter.
- **Amplitude**: Check peak-to-peak voltage (oscilloscope) or RMS (multimeter).
- **Distortion**: Use spectrum analyzer to measure THD (total harmonic distortion).

### 7.5 Calibrating Your System

- Set reference levels (0 dB = 1V RMS or as needed).
- Adjust trimmers/potentiometers in analog circuits for symmetry, headroom, and minimal distortion/noise.
- Use test signals (sine, square, white noise) for calibration.

---

## 8. Deep Dive: Sine, Square, Triangle, Saw – The Essential Waveforms

### 8.1 Harmonic Content of Each

- **Sine**: Only fundamental frequency, no overtones. Clean, pure.
- **Square**: Odd harmonics only (1st, 3rd, 5th ...). Rich, hollow.
- **Triangle**: Odd harmonics, but amplitude drops off faster than square. Softer.
- **Sawtooth**: All harmonics (odd & even). Brightest, most “aggressive.”

#### Fourier Series

- **Square**: sum of odd harmonics, each decreasing in amplitude.
- **Sawtooth**: sum of all harmonics, each decreasing linearly.

### 8.2 Generating in Hardware

- **Sine**: Difficult to generate directly in analog; usually approximated with filtering or special circuits.
- **Square**: Simple comparator or Schmitt trigger.
- **Triangle**: Integrator circuit on a square wave.
- **Sawtooth**: Ramp generator, typically using charging/discharging of a capacitor.

### 8.3 Generating in Software (C Code Overview)

- **Sine**: Use math library `sinf()`, or lookup table for efficiency.
- **Square**: Phase accumulator, output +1 or -1 depending on phase.
- **Triangle**: Integrate a square.
- **Sawtooth**: Phase accumulator, wrap at 1, output linear ramp.

#### Example: Phase Accumulator

```c
float phase = 0.0f;
float freq = 440.0f;
float sample_rate = 48000.0f;
float phase_inc = freq / sample_rate;

for (int i = 0; i < 512; ++i) {
    float saw = 2.0f * phase - 1.0f; // Sawtooth: -1 to 1
    float square = (phase < 0.5f) ? 1.0f : -1.0f;
    float triangle = 4.0f * fabs(phase - 0.5f) - 1.0f;
    // Next sample
    phase += phase_inc;
    if (phase >= 1.0f) phase -= 1.0f;
}
```

### 8.4 Why Each Sounds Distinct

- Harmonic content, phase relationships, and how the ear interprets these.
- Analog imperfections (slew, rounding, instability) add subtle differences.

---

## 9. Case Studies: Audio Paths in Classic Hybrid Synths

### 9.1 Synclavier

- **Digital**: FM, additive, and sample-based oscillators.
- **Analog**: Discrete output stages, special filtering for warmth.
- **Key characteristic**: Extremely clean, yet “alive” due to analog outputs.

### 9.2 Emulator III

- **Digital**: 16-bit samples, 8-voice stereo polyphony.
- **Analog**: SSM/CEM filters and VCAs.
- **Key characteristic**: Digital clarity plus rich SSM analog coloration.

### 9.3 PPG Wave 2.3

- **Digital**: Wavetable oscillators, 8-bit or 12-bit DACs.
- **Analog**: SSM filters and VCAs.
- **Key characteristic**: Glassy digital sounds, analog “bite” and warmth.

#### Block Diagram Example (PPG Wave 2.3):

```
[Wavetable Oscillators] → [Summing Mixer] → [Analog Filter] → [VCA] → [Output]
```

### 9.4 What Made Their Sound “Special”?

- Interplay of digital precision and analog imperfections
- Use of specific DACs and analog chipsets (SSM, CEM, VCFs)
- Careful gain staging and filtering
- Idiosyncrasies from design (e.g., phase errors, noise floors)

---

## 10. Exercises and Listening Practice

1. **Listen to the classic waveforms** (sine, square, triangle, saw) on a software synth. Use a spectrum analyzer to see their harmonic content.
2. **Try generating waveforms in C** using a phase accumulator.
3. **Measure the output of a real or virtual synth** with an oscilloscope and spectrum analyzer.
4. **Compare a digitally generated waveform with an analog one.** Note differences in shape, harmonics, and noise.
5. **Research the DAC/ADC chips in a classic synth.** What bit depth/rates did they use?
6. **Experiment with aliasing:** Generate a square wave above Nyquist frequency and listen for artifacts.
7. **Draw the block diagram** of your planned synth’s audio path, indicating digital and analog stages.

---

*End of Chapter 5. Next: Oscillator Theory and Implementation (including DAC interfacing and modular C code for both PC and Pi).*