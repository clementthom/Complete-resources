# Workstation Synth Project – Document 12  
## Bare Metal vs Linux on Raspberry Pi

---

### Table of Contents

1. What is “Bare Metal” Programming?
2. Linux: Pros, Cons, and Use Cases
3. Bare Metal: Pros, Cons, and Use Cases
4. Choosing the Right Platform for Your Project
5. Minimal Linux Distributions: Buildroot, Raspbian Lite
6. Getting Started with Each Approach
7. Developing Cross-Platform Code
8. Exercises

---

## 1. What is “Bare Metal” Programming?

- No operating system—your code runs directly after boot.
- Maximum performance, minimum latency, full hardware control.

---

## 2. Linux: Pros, Cons, Use Cases

- **Pros:** Easy driver support, huge libraries, multitasking, networking.
- **Cons:** Slower boot, more complexity, more memory.

---

## 3. Bare Metal: Pros, Cons, Use Cases

- **Pros:** Instant boot, low latency, small footprint, learn hardware deeply.
- **Cons:** Must write or port all device drivers; harder debugging.

---

## 4. Choosing the Right Platform

- **Bare Metal:** Real-time audio, instant-on, learning embedded C.
- **Linux:** Rapid prototyping, GUI-heavy apps, easier networking.

---

## 5. Minimal Linux Distros

- **Buildroot:** Roll your own tiny Linux.
- **Raspbian Lite:** Prebuilt, easy to use, many packages.

---

## 6. Getting Started

- Bare metal: install `arm-none-eabi-gcc`, try [Circle](https://github.com/rsta2/circle) or [Ultibo](https://ultibo.org/)
- Linux: Write code on Pi, use ALSA or PortAudio for audio.

---

## 7. Developing Cross-Platform Code

- Abstract away OS-specific calls (audio, display, touch).
- Use `#ifdef` or build system to switch.

---

## 8. Exercises

- Write “Hello, World!” for both bare metal and Linux.
- Compare boot times on your Pi.
- List pros/cons for your own project goals.

---

**Next:**  
*workstation_13_gpio_input_buttons_rotaries.md* — Adding hardware controls to your synth.

---