# Chapter 7: Analog Electronics for Synthesizers (Filters, VCAs, Signal Routing) – Part 2

---

## Table of Contents

4. Analog Filters: Types, Theory, and Implementation
    - Filter types: low-pass, high-pass, band-pass, notch, all-pass
    - Passive filter theory: RC and RLC filters, transfer functions
    - Active filter theory: Sallen-Key, Multiple-Feedback, State-Variable
    - Cutoff frequency, resonance (Q), slope, and filter order
    - Voltage-Controlled Filters (VCF): Transistor Ladder, OTA/CEM/SSM, Steiner, state-variable
    - Practical filter design: breadboarding, simulation, tuning
5. Voltage-Controlled Amplifiers (VCAs)
    - VCA theory: what is amplitude control?
    - Types of VCAs: OTA (CA3080/13700), SSM/CEM, discrete, modern ICs
    - Linear vs exponential response
    - VCA circuits: design, biasing, noise, distortion
    - Building and testing a simple VCA
6. Signal Routing and Mixing
    - Mixing: passive and active summing
    - Panning, crossfading, and matrix routing
    - Switches, multiplexers, and analog switches (4016, 4051, DG-series)
    - Buffering and impedance matching
    - Grounding, shielding, and noise management

---

## 4. Analog Filters: Types, Theory, and Implementation

### 4.1 Filter Types: Low-pass, High-pass, Band-pass, Notch, All-pass

- **Low-pass filter (LPF):** Passes frequencies below a cutoff frequency; attenuates higher frequencies.
- **High-pass filter (HPF):** Passes frequencies above a cutoff frequency; attenuates lower frequencies.
- **Band-pass filter (BPF):** Passes a band of frequencies; attenuates frequencies outside this band.
- **Notch (Band-stop) filter:** Attenuates a narrow band of frequencies; passes others.
- **All-pass filter:** Passes all frequencies, but changes phase. Used for phase shifters, not tone shaping.

#### Visualizing Filter Response

- **Frequency response graph:** Shows output amplitude vs input frequency.
- **Slope:** Measured in dB/octave (6, 12, 18, 24 dB/octave common in synths).
- **Cutoff frequency (f_c):** Where the filter’s response drops -3 dB from the passband.

### 4.2 Passive Filter Theory: RC and RLC Filters, Transfer Functions

#### RC Low-pass Filter

- **Schematic:**
    ```
    IN ---[R]---+--- OUT
                |
               [C]
                |
               GND
    ```
- **Cutoff frequency:**  
    `f_c = 1 / (2πRC)`

#### RC High-pass Filter

- **Schematic:**
    ```
    IN --+----[R]--- OUT
         |
        [C]
         |
        GND
    ```
- **Cutoff frequency:**  
    `f_c = 1 / (2πRC)`

#### RLC Filters

- Add an inductor (L) for sharper slopes and resonance.

#### Transfer Function

- **Describes output/input ratio as a function of frequency (`H(f)` or `H(s)`).**
- For an RC LPF:  
    `H(s) = 1 / (1 + sRC)`, with `s = j2πf` in Laplace domain.

#### Limitations

- Passive filters can only attenuate; cannot amplify or provide voltage control.
- Slope is limited by number of stages (6 dB/octave per RC stage).

### 4.3 Active Filter Theory: Sallen-Key, Multiple-Feedback, State-Variable

#### Sallen-Key Filter

- Uses an op-amp for buffering and amplification.
- Common for 2nd-order (12 dB/oct) LPF and HPF.

- **Schematic:**
    ```
    IN ---[R1]---+---[C2]--- GND
                [C1]        |
                 |          |
                GND       [R2]
                            |
                           OUT
    ```

#### State-Variable Filter (SVF)

- Allows simultaneous LP, HP, BP, and notch outputs.
- Core to many classic synth VCFs (e.g., Oberheim SEM).

- **Features:**
    - Voltage-controlled cutoff and resonance.
    - Smooth, stable operation.

#### Multiple-Feedback Filter

- Used for band-pass and notch.
- More complex, allows precise control of center frequency and Q.

### 4.4 Cutoff Frequency, Resonance (Q), Slope, and Filter Order

- **Cutoff frequency (f_c):** The frequency at which output drops to 70.7% (-3 dB) of input.
- **Resonance (Q):** Boost of frequencies near cutoff; higher Q = sharper peak.
- **Slope:** Rate of attenuation beyond cutoff (6 dB/octave per filter “pole”).
- **Order:** Number of reactive components (capacitors/inductors) in the filter.

#### Synth Examples

- Moog Ladder: 4-pole (24 dB/oct), with transistor-based resonance.
- Roland Juno: 2- or 4-pole (OTA-based), smooth resonance.

### 4.5 Voltage-Controlled Filters (VCF): Moog Ladder, OTA/CEM/SSM, Steiner, State-Variable

#### Moog Transistor Ladder

- Classic “warm” Moog sound.
- Uses series of transistor pairs for exponential control and resonance feedback.

#### OTA-Based (CEM, SSM, LM13700)

- OTA = Operational Transconductance Amplifier.
- Voltage controls the transconductance—directly modulates cutoff.
- Used in Roland, Oberheim, Sequential Circuits, and many DIY synths.

- **ICs:** CEM3320, SSM2044, LM13700.

#### Steiner-Parker Filter

- Unique topology, used in Steiner synths and Arturia Minibrute.
- Offers LP, HP, BP, and all-pass from a single circuit.

#### State-Variable

- Most flexible; simultaneous outputs.
- Easy to voltage-control cutoff and resonance via OTAs or FETs.

### 4.6 Practical Filter Design: Breadboarding, Simulation, Tuning

- **Breadboarding:** Build and test with real components before soldering.
- **Simulation:** Use SPICE-based tools (LTspice, Falstad’s Circuit Simulator) to model response.
- **Tuning:** Use trimmers or precision resistors/capacitors for accurate cutoff/Q.

#### Example: Breadboard a Sallen-Key LPF

- Choose R and C for desired f_c.
- Use a TL072 op-amp.
- Inject signal, measure output with oscilloscope and spectrum analyzer.

#### Common Pitfalls

- Power supply noise: Use bypass capacitors.
- Ground loops: Keep grounds star-connected.
- Component tolerances: Use matched pairs for stereo.

---

## 5. Voltage-Controlled Amplifiers (VCAs)

### 5.1 VCA Theory: What is Amplitude Control?

- **VCA:** An amplifier whose gain is set by a control voltage.
- Essential for envelopes, velocity sensitivity, and modulation in synths.
- VCA placement: typically after filter, before output.

### 5.2 Types of VCAs

#### OTA (Operational Transconductance Amplifier)

- CA3080, LM13700: Classic OTA chips, used in many synths.
- Control voltage sets output current (and thus amplitude).

#### SSM/CEM

- SSM2164, CEM3360: High-performance, low-noise, multi-channel VCA chips.
- Found in many classic and modern synths.

#### Discrete and Modern ICs

- Discrete: Built from transistors, used in vintage gear.
- Modern: THAT2180, Coolaudio V2164, SSI2164 for current projects.

### 5.3 Linear vs Exponential Response

- **Linear VCA:** Output level is proportional to control voltage.
- **Exponential VCA:** Output changes exponentially with control voltage—matches human hearing and musical envelopes.

#### Synth context:  
- Use exponential response for amplitude envelopes (sounds natural).
- Use linear for mixing and CV (control voltage) processing.

### 5.4 VCA Circuits: Design, Biasing, Noise, Distortion

- **Biasing:** Proper DC bias ensures distortion-free operation.
- **Noise:** VCAs add noise—choose low-noise ICs and design layout carefully.
- **Distortion:** Some VCAs distort at high gains or with high-level signals. Can be musical or undesirable.

#### Simple OTA VCA Example

```
Audio IN --[R]--+-- OTA IN+
                |
              [CV] (control voltage to OTA bias)
OTA OUT --[Buffer]-- Audio OUT
```

### 5.5 Building and Testing a Simple VCA

- Breadboard with LM13700, use potentiometer or LFO as CV.
- Test with audio signal generator, measure output with scope.
- Observe gain changes as you vary CV.

#### Common Troubleshooting

- No output: Check power, input/output wiring, CV range.
- Distortion: Reduce input level or check for clipping in buffer stage.
- Noise: Use shielded cables, good power supply filtering.

---

## 6. Signal Routing and Mixing

### 6.1 Mixing: Passive and Active Summing

- **Passive mixer:** Resistor network sums signals; simple, but signals lose strength and can interact.
- **Active mixer:** Uses op-amp; sums multiple signals without loss or crosstalk.

#### Active Mixer Example

```
IN1 ---[R1]--+
IN2 ---[R2]--+---(-)op-amp(+)--- OUT
IN3 ---[R3]--+
```
- Output is inverted sum; add a second inverting stage to restore phase if needed.

### 6.2 Panning, Crossfading, and Matrix Routing

- **Panning:** Split signal between left/right outputs using potentiometer or VCA pair.
- **Crossfading:** Transition between two sources; use VCAs or crossfade pots.
- **Matrix routing:** Multiple inputs to multiple outputs; analog switches or patch matrices.

### 6.3 Switches, Multiplexers, and Analog Switches

- **Mechanical switches:** Simple, reliable, but bulky.
- **Multiplexers (mux):** 4051, 4067 chips route one of many signals to one output.
- **Analog switches (DG-series, 4016):** Route audio/CV without relays; fast and quiet.

### 6.4 Buffering and Impedance Matching

- **Buffer:** Op-amp follower; isolates stages, prevents signal loss.
- **Impedance matching:** Ensures signal is transferred efficiently, prevents tone loss.

### 6.5 Grounding, Shielding, and Noise Management

- **Grounding:** Use star ground configuration, avoid loops.
- **Shielding:** Use shielded cable for long runs or sensitive signals.
- **Noise sources:** Power supply hum, digital switching, electromagnetic interference.
- **Best practices:** Keep audio and digital grounds separate, use ground planes on PCBs, filter power rails.

---

## 7. Exercises and Practical Projects

1. Breadboard a passive RC low-pass filter. Measure cutoff frequency with a sine wave generator and oscilloscope.
2. Simulate a Sallen-Key filter in LTspice or Falstad. Observe the effect of changing R and C.
3. Build an OTA-based VCA using an LM13700. Use an LFO as control voltage and listen to the tremolo effect.
4. Design an active mixer with three inputs. Test crosstalk and summing.
5. Use a 4051 multiplexer IC to route signals between sources and destinations. Control with switches or microcontroller GPIO.
6. Analyze the grounding and shielding in a vintage synth service manual. What techniques are used to minimize noise?

---

## 8. Summary and Further Reading

- Analog electronics bring warmth, character, and flexibility to synths.
- Mastering filters and VCAs gives you control over timbre and dynamics.
- Proper routing, mixing, and grounding are essential for reliable, noise-free operation.
- Next: Modulation sources—envelopes, LFOs, and advanced signal transformation.

**Recommended books and resources:**
- “The Art of Electronics” by Horowitz & Hill
- “Make: Analog Synthesizers” by Ray Wilson
- “Electronotes” (archive)
- Synth-DIY forums and yusynth.net

---

*End of Chapter 7. Continue to Chapter 8: Envelopes, LFOs, and Modulation Sources.*