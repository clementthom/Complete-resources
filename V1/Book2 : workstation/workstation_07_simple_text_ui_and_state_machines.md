# Workstation Synth Project – Document 7  
## Simple Text UI and State Machines

---

### Table of Contents

1. Why Start with a Text UI?
2. State Machines: The Basis of UI Logic
3. Console Menus in C
4. Handling User Input (Keyboard, Buttons)
5. Switching Screens and Modes
6. UI Navigation Patterns
7. Hands-On: Build a Menu System in C
8. Exercises

---

## 1. Why Start with a Text UI?

- Easy to debug and adapt
- Logic is the same for graphical UIs

---

## 2. State Machines

- Each screen or mode = a state
- Events (key presses, MIDI, touch) cause transitions

---

## 3. Console Menus in C

- `printf()` to show options, `scanf()` or `getchar()` for input

---

## 4. Handling User Input

- Keyboard: `getchar()`, non-blocking reads
- Buttons: GPIO or simulated

---

## 5. Switching Screens and Modes

- Use an enum for states
- Main loop checks current state and draws UI accordingly

---

## 6. UI Navigation Patterns

- Up/down for selection, enter for confirm
- Back/cancel for navigation

---

## 7. Hands-On: Build a Menu System

- Main menu: Play, Edit, Settings, About
- Each menu leads to a different function

---

## 8. Exercises

- Add a submenu for patch editing
- Implement a “return to main menu” option
- Simulate button input with keys

---

**Next:**  
*workstation_08_monochrome_graphics_fundamentals.md* — Drawing pixels, lines, and text for your GUI.

---