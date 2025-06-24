# Hybrid Synthesizer Project – Document 10  
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