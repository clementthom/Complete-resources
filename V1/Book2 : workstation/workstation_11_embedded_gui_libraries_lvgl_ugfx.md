# Workstation Synth Project – Document 11  
## Embedded GUI Libraries: LVGL, µGUI, and uGFX

---

### Table of Contents

1. Why Use a GUI Library?
2. Overview of Popular Embedded GUI Libraries
3. LVGL: Features, Setup, and Integration
4. uGFX and µGUI: Alternatives and When to Use
5. Porting a GUI Library to Raspberry Pi
6. Writing Custom Widgets
7. Touch and Display Driver Integration
8. Hands-On: Build a Simple Button Grid
9. Exercises

---

## 1. Why Use a GUI Library?

- Save time: prebuilt widgets (buttons, sliders, lists)
- Smooth graphics and touch handling
- Reskin and expand easily

---

## 2. Overview of Embedded GUI Libraries

- **LVGL:** Large, modern, supports themes, animations, touch, mono/color.
- **uGFX:** Lightweight, modular, good for mono.
- **µGUI:** Tiny, simple, good for learning.

---

## 3. LVGL: Features and Setup

- [LVGL (Light and Versatile Graphics Library)](https://lvgl.io/)
- Supports 1-bit monochrome
- Add to your project: clone repo, configure `lv_conf.h`
- Implement display and touch drivers

---

## 4. uGFX and µGUI

- **uGFX:** [ugfx.io](https://ugfx.io/)
- **µGUI:** [oliver](https://github.com/olikraus/u8g2) or [micropendous](https://github.com/embeddedartists/micropendous-micropendous/tree/master/software/ugui)

---

## 5. Porting to Raspberry Pi

- Implement framebuffer or SPI display driver
- Touch: map X/Y to LVGL/uGFX events

---

## 6. Writing Custom Widgets

- LVGL: extend `lv_obj_t`
- uGFX: custom draw functions

---

## 7. Driver Integration

- Display: flush framebuffer to screen
- Touch: pass new point to library

---

## 8. Hands-On: Button Grid

- Use LVGL to build an 8x4 on-screen button array
- Change color/state on press

---

## 9. Exercises

- Port a monochrome LVGL project to your Pi
- Implement a knob widget
- Display a MIDI note grid

---

**Next:**  
*workstation_12_bare_metal_vs_linux_on_raspberry_pi.md* — Picking your embedded OS layer.

---