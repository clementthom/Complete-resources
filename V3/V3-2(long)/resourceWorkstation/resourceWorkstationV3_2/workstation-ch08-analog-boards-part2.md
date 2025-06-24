# Chapter 8: Analog Boards — Mixing, Filtering, and Output  
## Part 2: Analog Filters, Output Stages, Protection, and Digital-Analog Integration

---

## Table of Contents

- 8.7 Introduction: Analog Signal Processing Beyond Mixing
- 8.8 Analog Filters: Lowpass, Highpass, Bandpass, State Variable, and More
  - 8.8.1 Filter Basics: Why Filters are Needed
  - 8.8.2 Passive vs. Active Filters
  - 8.8.3 Lowpass Filter (LPF) Circuits and Design
  - 8.8.4 Highpass Filter (HPF) Circuits and Design
  - 8.8.5 Bandpass (BPF) and Notch Filters
  - 8.8.6 State Variable Filters (SVF): Multi-mode and Modular Synth Use
  - 8.8.7 Resonance and Q: How to Control and Use
  - 8.8.8 Filter Component Selection: Capacitors, Resistors, Op-Amps
  - 8.8.9 Filter PCB Layout Tips
- 8.9 Output Stages: Headphone, Line, and Speaker Drivers
  - 8.9.1 Output Level and Impedance Matching
  - 8.9.2 Headphone Amplifier Circuits
  - 8.9.3 Line Driver Circuits
  - 8.9.4 Speaker Output Basics (Active vs Passive)
  - 8.9.5 Balanced Output Circuits (Impedance and Transformer)
  - 8.9.6 Mute, Soft-Start, and Pop Protection
- 8.10 Protection Circuits for Analog Boards
  - 8.10.1 Power Supply Protection: Fuses, Diodes, TVS
  - 8.10.2 ESD Protection on Jacks
  - 8.10.3 Overvoltage and Overcurrent Protection
  - 8.10.4 Hot-Swap, Reverse Polarity, and Power Sequencing
  - 8.10.5 Output Short-Circuit and Speaker Protection
- 8.11 Integrating Analog and Digital Boards
  - 8.11.1 Analog-to-Digital (ADC) and Digital-to-Analog (DAC) Interfaces
  - 8.11.2 Grounding, Shielding, and Mixed-Signal PCB Layout
  - 8.11.3 Power Supply Partitioning: Analog, Digital, and Phantom Power
  - 8.11.4 Level Shifting and Signal Conditioning
  - 8.11.5 Anti-Aliasing and Reconstruction Filters
  - 8.11.6 Clocking, Jitter, and Synchronization Issues
- 8.12 Glossary and Reference Tables

---

## 8.7 Introduction: Analog Signal Processing Beyond Mixing

Mixing is just the start—analog boards also shape, protect, and deliver your audio.  
Key jobs:
- Filtering noise and unwanted frequencies
- Protecting circuits and gear from damage
- Delivering clean, strong output to headphones, mixers, speakers
- Ensuring clean handoff between analog/digital domains

This part builds a practical, **beginner-friendly, step-by-step, and exhaustive** guide for real analog workstation boards.

---

## 8.8 Analog Filters: Lowpass, Highpass, Bandpass, State Variable, and More

### 8.8.1 Filter Basics: Why Filters are Needed

- Remove unwanted frequencies (hiss, rumble, aliasing)
- Shape sound for tone (synths, EQ, anti-alias, anti-imaging)
- Protect downstream circuits (remove DC, limit bandwidth)

### 8.8.2 Passive vs. Active Filters

| Type     | Components           | Pros/Cons                          | Use Case         |
|----------|----------------------|------------------------------------|------------------|
| Passive  | Resistors, caps, inductors | Simple, no power needed, limited gain/Q | Simple HPF/LPF, DC block |
| Active   | Adds op-amp(s)       | Precise, flexible, can add gain, low Z | Audio, synths, EQ |

### 8.8.3 Lowpass Filter (LPF) Circuits and Design

#### 8.8.3.1 RC Lowpass (Passive)

```plaintext
IN ---[R]---+--- OUT
           [C]
            |
           GND
```
- Cutoff freq: `fc = 1/(2πRC)`
- Simple, good for anti-alias or DC removal

#### 8.8.3.2 Active 1st-Order LPF

- Add op-amp buffer to improve drive/load

#### 8.8.3.3 Sallen-Key 2nd-Order LPF

```plaintext
IN ----[R1]-----+-----[R2]----+--- OUT
               [C1]         [C2]
                |             |
               GND           GND
```
- Use op-amp for feedback; higher Q, steeper slope

### 8.8.4 Highpass Filter (HPF) Circuits and Design

#### 8.8.4.1 RC Highpass (Passive)

```plaintext
IN ---[C]---+--- OUT
           [R]
            |
           GND
```
- Cutoff freq: `fc = 1/(2πRC)`
- DC blocking, remove rumble, pop

#### 8.8.4.2 Active HPF

- Same as above, but with buffer/op-amp for drive

### 8.8.5 Bandpass (BPF) and Notch Filters

- **Bandpass:** Only allows a band of frequencies (e.g., wah pedal, EQ)
- **Notch:** Rejects a narrow band (e.g., 50/60Hz hum removal)

#### 8.8.5.1 Twin-T Notch (Passive)

```plaintext
IN --[R1]--+----[C1]---+--- OUT
           |    |      |
          [C2] [R2]   GND
           |    |
          GND  GND
```
- Center freq: `f0 = 1/(2πRC)`

### 8.8.6 State Variable Filters (SVF): Multi-mode and Modular Synth Use

- **State Variable Filter:** Uses 2+ op-amps, outputs LP, HP, BP, Notch simultaneously
- Cutoff, resonance (Q), and mode all voltage-controllable

```plaintext
[Input]--[Op-Amp1]--[Op-Amp2]--[Op-Amp3]
                |           |
              HP Out      BP Out
                |           |
              LP Out     Notch Out
```

- Famous in analog synths for flexibility

### 8.8.7 Resonance and Q: How to Control and Use

- **Q (Quality Factor):** Sharpness of filter peak, resonance
- Add feedback from output to input (via resistor, VCA, or OTA) to make filter “ring” or self-oscillate

### 8.8.8 Filter Component Selection: Capacitors, Resistors, Op-Amps

- Use film (polyester, polypropylene) or C0G/NP0 ceramic caps for critical audio paths
- Metal film resistors for low noise
- Choose low-noise, high-bandwidth op-amps (see previous table)

### 8.8.9 Filter PCB Layout Tips

- Keep filter signal paths short and away from digital traces
- Star ground for analog sections
- Decouple op-amp power near each IC
- Avoid ground loops; use solid ground plane

---

## 8.9 Output Stages: Headphone, Line, and Speaker Drivers

### 8.9.1 Output Level and Impedance Matching

- Match output level to destination (line, headphones, speakers)
- Output impedance should be <100Ω for line/headphones

### 8.9.2 Headphone Amplifier Circuits

- Use dedicated IC (e.g., TPA6120, OPA1622) or op-amp buffer with enough current
- Add series resistor (1–10Ω) for protection

#### 8.9.2.1 Split vs. Single-Ended Outputs

- **Split:** Uses both + and - outputs (better for balanced headphones)
- **Single-Ended:** Standard TRS jack, ground as return

### 8.9.3 Line Driver Circuits

- Op-amp buffer or balanced driver (e.g., DRV134, THAT1646)
- Protect against short to ground with 100Ω series resistor

### 8.9.4 Speaker Output Basics (Active vs Passive)

- **Active speakers:** Contain their own amp, need line-level input
- **Passive speakers:** Need external amp; don’t drive directly from op-amp!

### 8.9.5 Balanced Output Circuits

- Differential driver ICs, transformer (for galvanic isolation), or op-amp pairs
- Use for long cable runs, pro audio gear

### 8.9.6 Mute, Soft-Start, and Pop Protection

- Use analog switches, relays, or FETs to mute output on power-up/down
- Soft-start circuits ramp up signal or power rails to avoid “thump”
- Add series cap to block DC

---

## 8.10 Protection Circuits for Analog Boards

### 8.10.1 Power Supply Protection: Fuses, Diodes, TVS

- **Fuses:** Protect against overcurrent; slow-blow for audio
- **Diodes:** Reverse polarity protection (Schottky for low drop)
- **TVS (Transient Voltage Suppressor):** Protect against voltage spikes

### 8.10.2 ESD Protection on Jacks

- Connect input/output jack sleeves to chassis ground
- Use ESD protection diodes (e.g., PESD, SP050x) on signal lines

### 8.10.3 Overvoltage and Overcurrent Protection

- Use polyfuses, PTC resettable fuses for self-resetting protection
- Clamp overvoltage with zener diodes or TVS

### 8.10.4 Hot-Swap, Reverse Polarity, and Power Sequencing

- Hot-swap: Use FETs, protection ICs for safe plug/unplug of modules
- Reverse polarity: Diode or FET “ideal diode” at DC input
- Power sequencing: Analog and digital rails on in proper order to avoid latch-up

### 8.10.5 Output Short-Circuit and Speaker Protection

- Series resistor limits current
- Output relay disconnects load on fault
- DC detection shuts off relay if output goes “live” (protects speakers from DC)

---

## 8.11 Integrating Analog and Digital Boards

### 8.11.1 Analog-to-Digital (ADC) and Digital-to-Analog (DAC) Interfaces

- **ADC:** Converts analog audio to digital (ICs: PCM1802, AK4556, TLV320AIC)
- **DAC:** Converts digital audio to analog (ICs: PCM5102, AK4490, CS4398)
- **Serial Buses:** I2S, TDM, SPDIF, ADAT, or parallel for older chips

### 8.11.2 Grounding, Shielding, and Mixed-Signal PCB Layout

- Star ground: Separate analog and digital grounds join at one point (near ADC/DAC)
- Shields: Metal case, shielded cables for EMI
- Avoid running digital clock/data lines near sensitive analog traces

### 8.11.3 Power Supply Partitioning: Analog, Digital, and Phantom Power

- Separate regulators for analog and digital (LDOs)
- Use ferrites or resistors between analog/digital power
- Phantom power (48V) for mics: Isolate from audio path with DC blocking caps

### 8.11.4 Level Shifting and Signal Conditioning

- Use resistor dividers, op-amp buffers to scale signals to ADC/DAC input range
- Clamp signals to safe range with diodes/zener

### 8.11.5 Anti-Aliasing and Reconstruction Filters

- **Anti-aliasing:** LPF before ADC, cutoff just below Nyquist (fs/2)
- **Reconstruction:** LPF after DAC to smooth stepped output

#### 8.11.5.1 Simple Filter Example

- 2nd-order Sallen-Key LPF at 20kHz for 44.1kHz ADC

### 8.11.6 Clocking, Jitter, and Synchronization Issues

- Clock quality affects audio quality (jitter = timing error)
- Use clean, low-jitter oscillators (TCXO, crystal)
- For multi-board: distribute master clock or use clock recovery ICs

---

## 8.12 Glossary and Reference Tables

| Term           | Definition                                 |
|----------------|--------------------------------------------|
| LPF            | Lowpass filter                             |
| HPF            | Highpass filter                            |
| BPF            | Bandpass filter                            |
| Notch          | Filter that attenuates a specific frequency|
| SVF            | State variable filter                      |
| Sallen-Key     | Common op-amp filter topology              |
| TVS            | Transient voltage suppressor diode         |
| ESD            | Electrostatic discharge                    |
| Star ground    | Single-point ground for all sections       |
| Anti-Alias     | Filter to remove out-of-band noise before ADC|
| Reconstruction | Filter to smooth DAC output                |

### 8.12.1 Reference Table: Common Audio Filter Cutoff Frequencies

| Application         | Cutoff Frequency (Hz) | Type      |
|---------------------|----------------------|-----------|
| DC Block            | 10–20                | HPF       |
| Rumble Removal      | 20–40                | HPF       |
| Anti-Aliasing (44k) | 19,000–20,500        | LPF       |
| Subsonic Synth      | 30–100               | HPF       |
| Drum Machine BPF    | 100–5,000            | BPF       |
| Hum Notch           | 50 or 60             | Notch     |

### 8.12.2 Reference Table: Headphone/Line Output Levels

| Output Type      | Typical Level (Vrms) | Peak-to-Peak (Vpp) | Impedance (Ω) |
|------------------|---------------------|--------------------|---------------|
| Line Out (pro)   | 1.23                | 3.5                | <100          |
| Line Out (cons.) | 0.316               | 0.9                | <1k           |
| Headphone        | 0.3–2.0             | 0.8–5.6            | 16–150        |
| Speaker (amp)    | 1–20+               | 2.8–56+            | 4–8           |

---

**End of Part 2 and Chapter 8: Analog Boards — Mixing, Filtering, and Output.**

**You now have a comprehensive, beginner-friendly, and exhaustive reference for analog mixing, filtering, output, protection, and digital-analog integration in workstation projects.  
If you want to proceed to the next chapter (Control Surfaces: Buttons, Encoders, Touch, and UI Hardware), or want deeper expansion on any topic, just say so!**