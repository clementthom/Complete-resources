# Chapter 15: Final Assembly, Calibration, and Sound Design – Part 2

---

## Table of Contents

5. Power-Up, Safety Checks & First Boot
    - Power sequencing and monitoring
    - Initial safety checks (shorts, overcurrent, overheating)
    - First power-on: what to expect and look for
    - Troubleshooting boot and power issues
6. Calibration of Analog and Digital Subsystems
    - Why calibrate? Tuning, accuracy, and musicality
    - Tools for calibration: multimeter, oscilloscope, signal generator, software tools
    - Calibrating oscillators (VCOs), filters (VCFs), envelopes, and CV outputs
    - Adjusting DAC/ADC reference voltages and offsets
    - Software calibration routines: auto-tune, service menus, and test modes
7. Tuning VCOs and Filters: Best Practices
    - Analog VCO calibration: scaling, offset, and temperature compensation
    - Digital oscillator calibration: DAC scaling, anti-aliasing, and reference frequency
    - Filter tuning: cutoff, resonance, self-oscillation
    - Long-term drift and compensation techniques
8. Final System Checks & Burn-In
    - Polyphony and voice allocation stress tests
    - Checking MIDI, CV, and user interface response
    - Audio quality: SNR, noise floor, distortion, crosstalk
    - Burn-in: running for extended periods to catch early failures
    - Documenting and logging test results
9. Sound Design: Programming Patches, Presets, and Performance
    - Principles of sound design for your synth architecture
    - Creating, saving, and managing patches/presets
    - Classic sounds: emulating analogs and building new timbres
    - Layering, splits, and performance setups
    - Tips for expressive playability

---

## 5. Power-Up, Safety Checks & First Boot

### 5.1 Power Sequencing and Monitoring

- Always power analog and digital sections according to recommended sequence (digital first, then analog, or as per datasheets).
- Use bench power supply with current limiting for first power-up.
- Monitor voltages at key test points before connecting sensitive components.

### 5.2 Initial Safety Checks

- **Check for shorts:** Use a multimeter on continuity mode across power rails and ground before applying power.
- **Overcurrent:** Monitor current draw during first power-on—unexpectedly high current suggests a short or miswiring.
- **Overheating:** Touch-test (carefully!) for hot ICs, regulators, or components; immediately power down if any are found.

### 5.3 First Power-On: What to Expect

- LEDs should illuminate as designed.
- No smoke, burning smells, or excessive heat!
- Microcontroller or Pi should boot (watch serial or display output).
- No unusual noises from audio outputs (hum, hiss, pops).

### 5.4 Troubleshooting Boot and Power Issues

- **Nothing powers up:** Check switch, fuses, connectors.
- **High current:** Power off, check for shorts.
- **No Pi/MCU boot:** Check supply voltage, re-seat SD card, check boot messages.
- **No display/UI:** Confirm power to display, communication lines, code initialization.

---

## 6. Calibration of Analog and Digital Subsystems

### 6.1 Why Calibrate?

- Ensures oscillators are in tune across the keyboard.
- Filters track cutoff points accurately.
- Envelopes behave as programmed.
- CV outs match expected voltage ranges.
- Compensates for component tolerances, temperature drift, aging.

### 6.2 Tools for Calibration

- **Multimeter:** For measuring voltages, especially CVs and references.
- **Oscilloscope:** For visualizing audio, envelopes, LFOs, and CV waveforms.
- **Signal generator:** For injecting test signals.
- **Test software:** Built-in test modes or external calibration scripts.

### 6.3 Calibrating VCOs, VCFs, Envelopes, and CV Outputs

#### VCOs (Analog)

- Send precise CVs (e.g., 1V, 2V, 3V) and measure frequency output.
- Adjust trimmers for scaling (octave/volt) and offset.
- Use frequency counter or tuner for accuracy.

#### Filters

- Feed in known frequency sweeps.
- Adjust cutoff trimmer so self-oscillation matches expected note (e.g., C4 at self-oscillation).
- Tweak resonance for smooth self-oscillation and even response.

#### Envelopes

- Measure attack, decay, sustain, release with scope.
- Adjust timing components or software calibration tables.

#### CV Outputs

- Output min/max values from synth to CV out.
- Measure with multimeter; adjust DAC scaling/offset in software or with trimmers.

### 6.4 Adjusting DAC/ADC Reference Voltages and Offsets

- DACs and ADCs often have reference pins—set or trim for exact 3.3V/5V as needed.
- For digital-to-analog, output a known binary value, measure voltage, and adjust reference/offset.

### 6.5 Software Calibration Routines

- Implement “service mode” in your synth firmware for automated calibration:
    - Step through CVs, check/adjust output.
    - Use test signals for filter/oscillator tuning.
    - Store calibration data in EEPROM/SD card for future boots.

---

## 7. Tuning VCOs and Filters: Best Practices

### 7.1 Analog VCO Calibration

- **Scaling:** Tune the 1V/octave response (or other standard) via scaling trimmer.
- **Offset:** Use offset trimmer to zero the pitch at lowest CV.
- **Thermal compensation:** Use tempco resistors or heater circuits for stability.

### 7.2 Digital Oscillator Calibration

- **DAC scaling:** Use software to adjust output scale so a programmed frequency matches measured pitch.
- **Anti-aliasing:** Confirm that digital oscillators don’t alias at high frequencies (test with spectrum analyzer).
- **Reference frequency:** Use crystal oscillator or external reference for best tuning stability.

### 7.3 Filter Tuning

- **Cutoff tracking:** Apply keyboard CV to filter cutoff, ensure musically useful scaling.
- **Self-oscillation:** Adjust to get clean sine output at high resonance.
- **Resonance balance:** Avoid excessive gain or instability at max resonance.

### 7.4 Long-Term Drift and Compensation

- Periodically retune, especially after thermal cycles.
- Implement auto-tune routines (as in some classic synths).
- Monitor calibration data and warn user if drift exceeds threshold.

---

## 8. Final System Checks & Burn-In

### 8.1 Polyphony and Voice Allocation Stress Tests

- Play maximum number of simultaneous notes; check for voice stealing or glitches.
- Use test MIDI files with dense chords/riffs.

### 8.2 Checking MIDI, CV, and User Interface Response

- Confirm all MIDI functions: note on/off, CC, program change.
- Test CV/gate outputs with external gear or scope.
- Exercise all UI controls, verify display updates, and feedback.

### 8.3 Audio Quality

- Measure SNR, noise floor, distortion, and crosstalk with audio analyzer or DAW.
- Listen for hum, buzz, clicks, or aliasing.

### 8.4 Burn-In

- Run the synth continuously for 24–72 hours, cycling through all functions.
- Watch for failures, thermal issues, or degradation.
- Log errors and anomalies for later analysis.

### 8.5 Documenting and Logging Test Results

- Maintain a test log for each unit (serial number, date, results, calibration values).
- Archive photos of internal assembly and wiring.
- Keep all calibration and test data for future service.

---

## 9. Sound Design: Programming Patches, Presets, and Performance

### 9.1 Principles of Sound Design for Your Synth Architecture

- Understand your synth’s signal flow: oscillator → filter → amp → effects.
- Explore modulation sources (LFOs, envelopes, velocity, aftertouch).
- Layer and split voices for complex textures.

### 9.2 Creating, Saving, and Managing Patches/Presets

- Use onboard UI or external editor to create and edit patches.
- Save patches to non-volatile memory (EEPROM, SD, file system).
- Implement patch naming, category tagging, and bank management.

### 9.3 Classic Sounds: Emulating Analogs and Building New Timbres

- Study vintage patch sheets for classic sounds (bass, lead, pad, brass).
- Use filter/envelope settings to mimic famous synths.
- Experiment with unconventional routings and modulations for unique voices.

### 9.4 Layering, Splits, and Performance Setups

- Allow layering of multiple voices for thick sounds.
- Implement keyboard splits for multi-timbral setups.
- Save and recall performance setups (combos, multi-patches).

### 9.5 Tips for Expressive Playability

- Map aftertouch, velocity, mod wheel, and pedals to important parameters.
- Use macro controls (one knob changes several parameters for live morphing).
- Prioritize smooth, artifact-free parameter changes.

---

## 10. Summary and Further Reading

- Final assembly and calibration transform a project into a true musical instrument.
- Careful mechanical, electrical, and software attention ensures reliability and musicality.
- Sound design unlocks the creative potential of your synth—explore, document, and share!
- Reference classic synth service manuals and patch books for inspiration and calibration details.

**Further Reading:**
- “Synthesizer Service Manual” (various manufacturers)
- “Make: Analog Synthesizers” by Ray Wilson
- “Electronic Musician’s Dictionary” by Craig Anderton
- Synth DIY Wiki: https://sdiy.info/
- Patch storage and librarian projects: Dexed, Ctrlr, Edisyn

---

*End of Chapter 15. Next: Annex – Storing Data (Samples, Presets, etc.) on an External SD Drive (Deep dive: principles, C code, bare-metal vs. Linux, and Emulator III/Emax strategies).*