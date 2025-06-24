# Workstation Synth Project – Document 20  
## Testing and Debugging GUI and Audio

---

### Table of Contents

1. Why Testing Matters in Embedded/UI Projects
2. Debugging GUI Code: Visual, Logic, and Input Bugs
3. Debugging Audio: Silence, Glitches, and Latency
4. Using UART, LEDs, and On-Screen Logs
5. PC-Based Testing vs Embedded Testing
6. Automated Test Strategies (Unit, Integration)
7. Test Harnesses for GUI (Button/Touch Simulators)
8. Profiling and Optimizing Performance
9. Hands-On: Build a Debug Menu and Log System
10. Exercises

---

## 1. Why Testing Matters

- Embedded bugs can be hard to spot and fix
- UI bugs frustrate users and slow development

---

## 2. Debugging GUI

- Visual bugs: misplaced elements, redraw errors
- Logic bugs: incorrect state transitions, lost inputs
- Input bugs: missed or phantom touches/buttons

---

## 3. Debugging Audio

- Silence: check buffer filling, DAC wiring
- Glitches: buffer underruns, timing issues
- Latency: optimize code, reduce buffer size

---

## 4. Using UART, LEDs, On-Screen Logs

- UART: print debug info from Pi to PC
- LEDs: indicate status (error, play, record)
- On-screen: overlay debug info/log

---

## 5. PC vs Embedded Testing

- Test engine/UI on PC for speed
- Use “fake” drivers for unit testing

---

## 6. Automated Testing

- Unit tests for engine logic, state machines
- Integration tests for screen transitions, audio

---

## 7. GUI Test Harnesses

- Simulate button/touch input in code
- Scripted test cases

---

## 8. Profiling/Optimizing

- Measure frame/audio buffer time
- Optimize slowest routines

---

## 9. Hands-On

- Add debug log overlay to GUI
- Blink LED if audio underrun occurs

---

## 10. Exercises

- Write a test for menu navigation
- Simulate touch input in your code
- Profile your GUI draw speed

---

**Next:**  
*workstation_21_case_panel_and_ergonomics.md* — Designing the physical interface.

---