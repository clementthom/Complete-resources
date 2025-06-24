# Hybrid Synthesizer Project – Document 14  
## Expanding Controls: MIDI, Buttons, and User Interface

---

### Table of Contents

1. Why Add Controls? Expressivity and Playability
2. MIDI Basics: What, Why, and How
3. Reading MIDI in C (PC and Pi)
4. Wiring MIDI Input (Opto-Isolator Circuits)
5. Parsing MIDI Messages (Note On/Off, Velocity)
6. Adding Buttons and Encoders (GPIO)
7. Basic UI: Text LCD or OLED Displays
8. User Interface Code Structure
9. Exercises and Experiments

---

## 1. Why Add Controls?

- Play your synth with a keyboard, DAW, or knob.
- Make it interactive and expressive.

---

## 2. MIDI Basics

- **MIDI = Musical Instrument Digital Interface**
- Simple serial protocol (31.25 kbaud, 5-pin DIN)
- Common messages: Note On, Note Off, Control Change, Pitch Bend

---

## 3. Reading MIDI in C

- **PC:** Use PortMIDI, RtMidi, or ALSA MIDI.
- **Pi:** Read from UART, parse bytes.

---

## 4. Wiring MIDI Input

- Use 6N138/6N137 opto-isolator for safe input.
- Standard circuit: 220Ω resistors, DIN jack, opto, pull-up resistor.

---

## 5. Parsing MIDI Messages

- MIDI messages are bytes: 0x90 (Note On), note number, velocity.
- State machine to handle running status and multi-byte messages.

---

## 6. Adding Buttons and Encoders

- Use Pi GPIO or Arduino for prototyping.
- Poll or interrupt-driven reads.

---

## 7. Basic UI: Text LCD/OLED

- 16x2 LCD: Easy, cheap, lots of guides.
- I2C/SPI OLED: More modern, supports graphics.

---

## 8. User Interface Code Structure

- Simple event loop: check MIDI, buttons, update display.
- Menu system for patch editing.

---

## 9. Exercises

- Wire up MIDI input and play notes from a keyboard.
- Connect a button to GPIO and trigger a sound.
- Display voice status on LCD.

---

**Next:**  
*hybrid_synth_15_documenting_sharing_next_steps.md* — Documenting, sharing, and going further.

---