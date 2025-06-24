# Hybrid Synthesizer Project – Document 7
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