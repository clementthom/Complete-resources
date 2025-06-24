# Workstation Synth Project – Document 10  
## Touchscreen Technologies and Basics

---

### Table of Contents

1. How Touchscreens Work: Resistive vs Capacitive
2. Choosing the Right Touchscreen for Your Project
3. Touch Controller ICs (XPT2046, FT6206, etc.)
4. Wiring and Powering Your Touchscreen
5. Reading Touch Input (SPI, I2C)
6. Touch Event Processing and Debouncing
7. Mapping Raw Touch to Screen Coordinates
8. Hands-On: Print Touch Coordinates
9. Exercises

---

## 1. How Touchscreens Work

- **Resistive:** Layers pressed together; works with anything; less precise.
- **Capacitive:** Senses finger’s capacitance; more sensitive, requires skin.

---

## 2. Choosing the Right Touchscreen

- Size: 2"–7" typical for workstation synths.
- Interface: SPI or I2C (easy on Pi).
- Module availability: many SPI LCD+Touch modules exist.

---

## 3. Touch Controller ICs

- **XPT2046:** SPI, resistive. Common, cheap, well-documented.
- **FT6206:** I2C, capacitive. More precise, a bit more expensive.

---

## 4. Wiring and Powering

- Power: 3.3V or 5V (check datasheet).
- Connect SPI/I2C lines, chip select, interrupt.
- Keep cables short to reduce noise.

---

## 5. Reading Touch Input

- Use Pi’s SPI/I2C peripheral.
- Read X/Y coordinates, pressure (resistive only).
- Poll or use interrupt pin for new data.

---

## 6. Touch Event Processing

- Debounce: ignore spurious or repeated touches.
- Filter out noise (moving average, simple lowpass).

---

## 7. Mapping Raw Touch to Screen

- Calibrate: map raw min/max values to 0–width/height.
- Use a calibration routine (touch corners, save values).

---

## 8. Hands-On: Print Touch Coordinates

- Write C code to print X/Y on touch.
- Draw a dot where touched on the display.

---

## 9. Exercises

- Calibrate your touchscreen and save mapping.
- Detect tap vs swipe vs hold.
- Implement a simple on-screen “button” activated by touch.

---

**Next:**  
*workstation_11_embedded_gui_libraries_lvgl_ugfx.md* — GUI libraries for embedded C projects.

---