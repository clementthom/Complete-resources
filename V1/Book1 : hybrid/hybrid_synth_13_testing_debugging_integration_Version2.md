# Hybrid Synthesizer Project – Document 13  
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