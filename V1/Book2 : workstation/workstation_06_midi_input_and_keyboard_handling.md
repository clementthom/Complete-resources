# Workstation Synth Project – Document 6  
## MIDI Input and Keyboard Handling

---

### Table of Contents

1. What is MIDI? Protocol Overview
2. MIDI Data: Note On/Off, Velocity, CC
3. Connecting a MIDI Keyboard (PC, Pi)
4. Reading MIDI in C (PortMIDI, ALSA, or UART)
5. Parsing MIDI Messages
6. Managing Polyphony and Note Allocation
7. Simulating Keyboard Input for Testing
8. Exercises

---

## 1. What is MIDI?

- Musical Instrument Digital Interface
- Serial protocol (31,250 bps), 5-pin DIN or USB

---

## 2. MIDI Data

- **Note On:** 0x90, note number (0–127), velocity (0–127)
- **Note Off:** 0x80, note, velocity
- **Control Change (CC):** 0xB0, controller, value

---

## 3. Connecting a MIDI Keyboard

- **PC:** USB MIDI, PortMIDI or ALSA library
- **Pi:** USB or UART (DIN jack, opto-isolator)

---

## 4. Reading MIDI in C

- **PortMIDI:** `Pm_Read`, `Pm_Poll`
- **ALSA:** `snd_seq_event_input`
- **UART:** Read serial, parse bytes

---

## 5. Parsing MIDI Messages

- State machine: track status, data bytes
- Handle running status and channel messages

---

## 6. Managing Polyphony

- Note-on: find a free voice, set note/freq
- Note-off: release voice

---

## 7. Simulating Keyboard Input

- For debugging, send fake MIDI messages in your code

---

## 8. Exercises

- Read and print incoming MIDI notes.
- Implement voice allocation for 4-voice polyphony.
- Simulate a keyboard scale in software.

---

**Next:**  
*workstation_07_simple_text_ui_and_state_machines.md* — Building your first user interface logic.

---