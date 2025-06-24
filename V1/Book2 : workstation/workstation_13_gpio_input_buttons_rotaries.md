# Workstation Synth Project – Document 13  
## GPIO Input: Buttons, Rotaries, and Switches

---

### Table of Contents

1. What is GPIO? Basics for Beginners
2. Reading Buttons and Switches on the Pi
3. Debouncing: Hardware and Software
4. Adding Rotary Encoders for UI Navigation
5. Multiplexing Inputs for Many Controls
6. Polling vs Interrupts
7. Hands-On: Volume Knob and Patch Select
8. Exercises

---

## 1. What is GPIO?

- **General Purpose Input/Output** pins on Pi
- Control/read digital signals (0 or 1)

---

## 2. Reading Buttons and Switches

- Wire to GPIO and ground; use internal pull-ups
- Read pin in C (bare metal or Linux via `/sys/class/gpio` or a C library)

---

## 3. Debouncing

- Mechanical switches “bounce” (on/off rapidly)
- Hardware: RC filter, Schmitt trigger
- Software: ignore rapid changes within X ms

---

## 4. Rotary Encoders

- Two pins (A, B): read phase to detect clockwise/counterclockwise
- Used for data entry, menu navigation

---

## 5. Multiplexing Inputs

- Use shift registers or analog multiplexers to read many buttons with few pins

---

## 6. Polling vs Interrupts

- **Polling:** check input in main loop
- **Interrupts:** hardware triggers a function on change (advanced)

---

## 7. Hands-On

- Add a button for “Next Patch”
- Add an encoder for “Value” and “Menu” navigation

---

## 8. Exercises

- Read multiple buttons and print their state
- Debounce a button in software
- Add encoder support to your menu

---

**Next:**  
*workstation_14_display_drivers_and_framebuffers.md* — Getting pixels onto your screen.

---