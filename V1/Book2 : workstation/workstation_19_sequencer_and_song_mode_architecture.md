# Workstation Synth Project – Document 19  
## Sequencer and Song Mode Architecture

---

### Table of Contents

1. What is a Step Sequencer? Song Mode?
2. Data Structures for Patterns, Steps, and Songs
3. Timing and Clock Management (Internal/External Sync)
4. Editing Patterns: Touch and Encoder Input
5. Playback Engine: Scheduling Notes and Events
6. Track Management (Mute/Solo, Channel Assignment)
7. Saving and Loading Patterns/Songs
8. Visualization: Step Grids, Progress Bars
9. Hands-On: Build a Simple 8-step Sequencer
10. Exercises

---

## 1. Step Sequencer and Song Mode

- **Step Sequencer:** Fixed grid (e.g., 16 steps), on/off per step per track
- **Song Mode:** Arrange patterns into a timeline

---

## 2. Data Structures

```c
typedef struct { uint8_t steps[16]; } Pattern;
typedef struct { Pattern patterns[8]; } Song;
```

---

## 3. Timing and Clock

- Use timer interrupt or audio callback as clock
- Support tempo adjustment (BPM)

---

## 4. Editing Patterns

- Touch: tap to toggle step
- Encoder: select step/track

---

## 5. Playback Engine

- On each clock, scan active steps, trigger notes
- Send note-on/note-off to engine

---

## 6. Track Management

- Mute/solo tracks
- Assign tracks to parts/voices

---

## 7. Saving and Loading

- Store patterns/songs in flash or SD card
- Simple binary or JSON format

---

## 8. Visualization

- Grid with active steps lit
- Progress bar for play position

---

## 9. Hands-On

- Code a 16-step drum sequencer
- Save/load patterns with buttons

---

## 10. Exercises

- Add copy/paste for patterns
- Implement swing/shuffle modes
- Support external MIDI clock

---

**Next:**  
*workstation_20_testing_debugging_gui_and_audio.md* — Debugging your workstation like a pro.

---