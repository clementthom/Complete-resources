# Hybrid Synthesizer Project – Document 11  
## Bare Metal on the Raspberry Pi: Setup and Toolchain

---

### Table of Contents

1. Bare Metal vs Linux: Why Go Bare Metal?
2. What Happens When the Pi Boots?
3. Toolchain: Installing ARM GCC and Tools
4. Bare-Metal Frameworks: Circle, Ultibo, or DIY?
5. Your First Bare-Metal Program: Blinking an LED
6. Serial Debugging (UART)
7. Building, Flashing, and Testing
8. Exercises

---

## 1. Bare Metal vs Linux: Why Go Bare Metal?

- **Bare Metal:** No OS, your code runs directly on the hardware.
    - Fast boot, low latency, full control, tiny size.
- **Linux:** Easier drivers, more powerful, but more overhead.

---

## 2. What Happens When the Pi Boots?

- GPU runs first, loads `bootcode.bin` and `kernel.img` from SD card.
- Your code (as `kernel.img`) runs as the only program.

---

## 3. Toolchain: Installing ARM GCC and Tools

**On Solus:**
```bash
sudo eopkg install arm-none-eabi-gcc binutils-arm-none-eabi make
```

---

## 4. Bare-Metal Frameworks

- **Circle:** C++ framework with audio, USB, and more. [GitHub](https://github.com/rsta2/circle)
- **Ultibo:** Pascal-based, easy for Pi, but less C-focused.
- **DIY:** Write your own linker script and startup code (advanced).

---

## 5. Your First Bare-Metal Program: Blinking an LED

- Use Circle's `circle-examples/blinky` as a starting point.
- Build with `make`, copy `kernel.img` to SD card, insert in Pi, power up.

---

## 6. Serial Debugging (UART)

- Connect USB-UART adapter to Pi GPIO.
- Use a terminal (minicom, screen) to view debug prints.
- Add `printf` or `puts` calls in your code for status messages.

---

## 7. Building, Flashing, and Testing

- `make` builds your code.
- Copy `kernel.img` to SD card root.
- Power-cycle Pi to load new code.
- Use UART or LED to verify it's running.

---

## 8. Exercises

- Build and run blinky on your Pi.
- Modify code to print "Hello, Synth!" over UART.
- Try toggling GPIO pins in a loop.

---

**Next:**  
*hybrid_synth_12_crossplatform_audio_engine.md* — Making your audio engine run on both PC and Pi.

---