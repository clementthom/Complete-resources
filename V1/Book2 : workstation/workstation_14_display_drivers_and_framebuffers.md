# Workstation Synth Project – Document 14  
## Display Drivers and Framebuffers

---

### Table of Contents

1. What is a Display Driver?
2. Display Types: OLED, LCD, TFT
3. Communication Protocols: SPI, I2C, Parallel
4. Writing a Framebuffer Driver in C
5. Optimizing Refresh and Update Speed
6. Double Buffering and Flicker-Free Drawing
7. Integrating with GUI Libraries
8. Hands-On: Draw Shapes and Text
9. Exercises

---

## 1. What is a Display Driver?

- Software that sends pixel data to your physical screen.
- Converts framebuffer changes into SPI/I2C/Parallel signals.

---

## 2. Display Types

- **OLED:** Sharp, true black, small (128x64/128x32)
- **LCD:** Cheap, widespread, backlit.
- **TFT:** Color, sometimes used in mono mode.

---

## 3. Communication Protocols

- **SPI:** Fast, simple, most common for small displays.
- **I2C:** Slower, fewer wires.
- **Parallel:** Fast but many wires, used in old LCDs.

---

## 4. Writing a Framebuffer Driver

- Set up a 1-bit framebuffer in RAM.
- Update display by sending framebuffer to device.
- Use datasheet/Adafruit guides for command sequences.

---

## 5. Optimizing Refresh

- Only send changed parts (“dirty rectangles”).
- Batch updates to avoid tearing.

---

## 6. Double Buffering

- Draw to a hidden buffer, swap with visible buffer.
- Eliminates flicker and partial updates.

---

## 7. GUI Library Integration

- LVGL/uGFX/µGUI need a flush/display driver callback.
- Pass framebuffer pointer and size.

---

## 8. Hands-On

- Write a driver for SSD1306 or ST7565 OLED.
- Display a scrolling text banner.

---

## 9. Exercises

- Implement double buffering.
- Benchmark update speed for your display.
- Draw a simple animation.

---

**Next:**  
*workstation_15_gui_design_for_workstation_synths.md* — Designing an effective, musical UI.

---