# Workstation Chapter 06: Analog Boards — Mixing, Filtering, and Output (Part 1)
## Analog Fundamentals, Audio Signal Paths, and Essential Circuits

---

## Table of Contents

1. Introduction: The Role of Analog in Digital Workstations
2. Audio Signal Path Fundamentals
    - Analog vs. Digital Domains
    - Typical Audio Flow in a Workstation
    - Gain Staging and Signal Integrity
3. Analog Components and Circuits
    - Resistors, Capacitors, and Inductors
    - Op-Amps: The Heart of Analog Audio
    - Audio-Grade ICs and Their Selection
    - Common Analog ICs (TL07x, NE5532, etc.)
    - Basics of Schematic Reading
4. Audio Mixing Circuits
    - Summing Amplifiers (Passive, Active)
    - Pan Circuits
    - Fader and Level Control Circuits
    - Headroom and Clipping in Analog Mixers
    - Mix Bus Topologies (Mono, Stereo, Multibus)
5. Analog Filters for Synths and Workstations
    - RC, RLC, and Op-Amp Filter Types
    - Low-Pass, High-Pass, Band-Pass, Notch
    - Filter Orders and Slope
    - Voltage-Controlled Filters (VCF)
    - Famous Synth Filter Topologies (Moog Ladder, Sallen-Key, State Variable)
6. Output Stages and Line Drivers
    - Impedance Matching and Balanced/Unbalanced Outputs
    - Headphone Drivers
    - Output Protection (Short-Circuit, DC Offset)
    - Mute Circuits and Power-On/Off Thump Prevention
7. Power Supply Considerations for Audio
    - Dual Rails, Grounding, Star Grounds
    - Power Supply Rejection Ratio (PSRR)
    - Decoupling and Noise Suppression
    - Linear vs. Switching Regulators
8. Practice Section 1: Designing, Simulating, and Building Basic Audio Circuits
9. Exercises

---

## 1. Introduction: The Role of Analog in Digital Workstations

Even the most advanced digital workstation ends its journey in the analog domain—speakers, headphones, and amplifiers are always analog.  
Analog boards do more than just output sound:
- They shape and color the audio (filters, VCAs, distortion, EQ)
- Mix and route signals from various sources (synth, sampler, external inputs)
- Provide robust, noise-free line and headphone outputs

**Classic Workstations:**  
Synclavier, Fairlight, Emulator, and PPG all had custom analog boards for mixing, filtering, and output.  
Modern digital designs still rely on analog for the “final mile”—and for that classic warmth and character.

---

## 2. Audio Signal Path Fundamentals

### 2.1 Analog vs. Digital Domains

- **Digital:** Audio is numbers (PCM samples); easy to process, store, and manipulate.
- **Analog:** Audio is voltages; sensitive to noise, distortion, and component quality.
- **Conversion:** DAC (digital to analog) and ADC (analog to digital) bridges the two worlds.

### 2.2 Typical Audio Flow in a Workstation

**Block Diagram Example:**
```
[Digital Audio Engine] --> [DAC] --> [Anti-Aliasing Filter] --> [Analog Mixer/VCF] --> [Output Amp] --> [Line Out/Headphones]
```
- Optional: [External Analog Input] --> [Preamp] --> [ADC] --> [Digital FX]

### 2.3 Gain Staging and Signal Integrity

- **Gain Staging:** Setting correct signal levels at each stage to maximize SNR (signal-to-noise ratio) and avoid clipping/distortion.
- **Unity Gain:** Output level equals input level (no amplification or attenuation).
- **Headroom:** Extra space before clipping; critical for dynamic sources.
- **Impedance Matching:** Ensures maximal power transfer and minimal signal loss.

---

## 3. Analog Components and Circuits

### 3.1 Resistors, Capacitors, and Inductors

- **Resistors (R):** Set gain, define filter cutoff, limit current.
- **Capacitors (C):** Block DC, couple stages, frequency-dependent elements in filters.
- **Inductors (L):** Rare in audio (bulky, pick up hum), used in some high-end EQs or filters.

### 3.2 Op-Amps: The Heart of Analog Audio

- **Op-Amp (Operational Amplifier):** High-gain DC-coupled amplifier; used in mixers, filters, buffers, VCAs.
- **Ideal Op-Amp:** Infinite gain, input impedance; zero output impedance, offset, and noise (real op-amps are close, but not perfect).

### 3.3 Audio-Grade ICs and Their Selection

- **Key Parameters:** Noise, bandwidth, slew rate, input offset, supply voltage
- **Popular Choices:** TL07x (low noise, low cost), NE5532 (pro audio standard), OPA2134, LM4562, etc.

### 3.4 Common Analog ICs

- **TL072:** Very low noise, JFET input, classic in synths.
- **NE5532:** Hi-fi dual op-amp, low distortion.
- **LF353, LM358:** Cheaper, but more noise.

### 3.5 Basics of Schematic Reading

- Learn to read and draw circuit diagrams (symbols, nets, labels).
- Practice tracing signal flow, identifying key components.

---

## 4. Audio Mixing Circuits

### 4.1 Summing Amplifiers

#### Passive Summing

- Uses only resistors to sum signals; output is attenuated, needs a buffer/amp.

```
Input1 --R1--+ 
             |----+----> Output (to buffer/amp)
Input2 --R2--+    |
             |    Rload
Input3 --R3--+    |
```

#### Active Summing (Op-Amp Mixer)

- Maintains unity (or higher) gain, low output impedance, less noise.

```
         R1    R2    R3
Input1--/\/\/\-/\/\/\-/\/\/\---+
                               |
                             |\
                             | >---- Output
                             |/
                               |
                              GND
```

**Equation:**  
Output = - ( (V1/R1) + (V2/R2) + (V3/R3) ) * Rf

### 4.2 Pan Circuits

- Use dual-gang potentiometers or crossfade resistors to send signal to left/right in stereo.
- Some modern designs use voltage-controlled panning (VCA-based).

### 4.3 Fader and Level Control Circuits

- **Potentiometers:** Variable resistors for manual volume control.
- **VCAs:** Voltage-Controlled Amplifiers for automated/midi control.

### 4.4 Headroom and Clipping in Analog Mixers

- **Headroom:** Ensure mixer can handle peaks without distortion.
- **Clipping:** Occurs when the op-amp runs out of supply voltage; causes harsh distortion.

### 4.5 Mix Bus Topologies

- **Mono Bus:** All channels sum to one output.
- **Stereo Bus:** Pan, then sum to left/right.
- **Multibus:** Used for submixes, aux sends, and complex routing.

---

## 5. Analog Filters for Synths and Workstations

### 5.1 RC, RLC, and Op-Amp Filter Types

- **RC Filter:** Simple, one pole (6 dB/octave); low- or high-pass.
  - Cutoff = 1/(2πRC)
- **RLC Filter:** Adds resonance, but inductors are rare in synths.
- **Op-Amp Filters:** Multiple poles, active gain, tunable.

### 5.2 Low-Pass, High-Pass, Band-Pass, Notch

- **Low-Pass:** Passes lows, cuts highs (classic synth “filter sweep”)
- **High-Pass:** Passes highs, cuts lows (thin out sound)
- **Band-Pass:** Passes a band (wah, phaser)
- **Notch:** Cuts a band (humbucker, anti-feedback)

### 5.3 Filter Orders and Slope

- **1st Order:** 6dB/octave
- **2nd Order:** 12dB/octave (Sallen-Key)
- **4th Order:** 24dB/octave (Moog ladder)

### 5.4 Voltage-Controlled Filters (VCF)

- **VCF:** Filter cutoff frequency modulated by control voltage (envelope, LFO, key tracking)
- **OTA (CA3080, LM13700):** Classic VCF chips
- **Digital Control:** Use DAC to generate control voltage

### 5.5 Famous Synth Filter Topologies

- **Moog Ladder:** 4-pole, transistor ladder; classic “fat” sound.
- **Sallen-Key:** Simple, stable, 2-pole; easy to build.
- **State Variable:** Simultaneous LP, HP, BP, Notch outputs.
- **SEM/Oberheim:** State variable, smooth resonance.
- **Korg MS-20:** Unique, aggressive, diode-based.

---

## 6. Output Stages and Line Drivers

### 6.1 Impedance Matching and Balanced/Unbalanced Outputs

- **Unbalanced:** One signal, one ground (TS jack, RCA). Prone to noise over long cables.
- **Balanced:** Signal+, Signal-, ground (TRS, XLR): cancels noise, pro standard.
- **Line Level:** +4dBu (pro), -10dBV (consumer); match levels to avoid distortion.

### 6.2 Headphone Drivers

- Need higher current than line out; use dedicated op-amps or discrete transistors.
- Beware of load impedance (32Ω - 600Ω headphones).

### 6.3 Output Protection

- **Short-Circuit Protection:** Prevents damage if outputs shorted.
- **DC Offset Protection:** Blocks DC to avoid speaker/headphone damage (series caps, relay muting).
- **Overvoltage/ESD Protection:** TVS diodes, series resistors.

### 6.4 Mute Circuits and Power-On/Off Thump Prevention

- FET or relay mutes disconnect output during power up/down.
- Large caps slowly ramp up output voltage to prevent “thumps.”

---

## 7. Power Supply Considerations for Audio

### 7.1 Dual Rails, Grounding, Star Grounds

- **Dual Rails:** ±12V or ±15V for op-amps; allows for headroom and symmetric swing.
- **Star Grounding:** All grounds meet at one point to avoid ground loops/hum.
- **Chassis Ground:** Connect to earth for shielding, but isolate from signal ground.

### 7.2 Power Supply Rejection Ratio (PSRR)

- Op-amp’s ability to ignore noise/ripple on supply lines.
- Higher PSRR op-amps mean less “power supply hiss” in audio.

### 7.3 Decoupling and Noise Suppression

- Place 0.1uF ceramic caps close to every op-amp power pin.
- Bulk electrolytic caps (10-100uF) for local energy storage.
- Ferrite beads or LC filters to block high-frequency noise.

### 7.4 Linear vs. Switching Regulators

- **Linear:** Simple, low noise, inefficient for big current (heat).
- **Switching:** Efficient, can be noisy (add filters, shield from analog).
- Use linear for analog, switching for digital (with good filtering).

---

## 8. Practice Section 1: Designing, Simulating, and Building Basic Audio Circuits

### 8.1 Op-Amp Audio Buffer

- Design a unity-gain buffer (follower) using TL072.
- Simulate in LTspice or Falstad; measure input/output, distortion.

### 8.2 Passive and Active Mixers

- Build a passive mixer with resistors; compare with active op-amp mixer.
- Measure levels, noise, and headroom.

### 8.3 Simple RC Low-Pass Filter

- Build and simulate an RC LPF for anti-aliasing or tone shaping.
- Sweep input frequency, measure output -3dB point.

### 8.4 VCF (Voltage-Controlled Filter) Module

- Build a Sallen-Key or Moog ladder filter (breadboard or simulate).
- Modulate cutoff with a control voltage.

### 8.5 Output Stage

- Design a line out circuit with DC blocking cap and protection resistors.
- Build a simple headphone amp (op-amp + buffer transistor).

---

## 9. Exercises

1. **Schematic Reading**
   - Find and annotate an op-amp mixer schematic. Identify all resistors, feedback paths, and decoupling caps.

2. **Op-Amp Selection**
   - Compare TL072, NE5532, and LM358 for noise, bandwidth, and cost. Which would you use in your design?

3. **Mixer Experiment**
   - Breadboard a passive and active audio mixer. Feed two signals and compare output levels and noise.

4. **Filter Simulation**
   - Use Falstad or LTspice to simulate a 2-pole Sallen-Key low-pass filter. Measure cutoff and resonance.

5. **VCF Research**
   - Research and report on a classic VCF design (Moog ladder, SEM, MS-20). What makes it unique?

6. **Output Protection**
   - Design and simulate a mute circuit for power-on thump prevention. Try using a relay or FET.

7. **Power Rail Testing**
   - Build/test a ±12V supply with star grounding. Measure ripple with and without decoupling caps.

8. **Impedance Matching**
   - Calculate output impedance for your line out circuit. Test with different cable lengths and loads.

9. **Headphone Driver**
   - Design a simple op-amp-based headphone amplifier. Test with 32Ω and 300Ω headphones.

10. **Documentation**
    - Write a step-by-step build guide for a simple op-amp mixer, including schematic, layout, part list, and testing steps.

---

**End of Part 1.**  
_Part 2 will cover advanced analog circuits: VCA, envelope followers, analog effects, measuring and debugging, integration with digital control, and practical analog board design for modern workstations._
