# Hybrid Synthesizer Project – Document 12  
## Cross-Platform Audio Engine: PC and Pi

---

### Table of Contents

1. Why Make Code Portable?
2. Abstracting Audio Output: Hardware Layers
3. Structuring Your Code for Portability
4. Writing Platform-Specific Audio Drivers (PC: PortAudio, Pi: I2S/SPI)
5. Handling Endianness and Bit Depth
6. Managing Audio Buffers and Timing
7. Testing Your Engine on Both Platforms
8. Exercises

---

## 1. Why Make Code Portable?

- Write once, run everywhere.
- Debug audio logic on PC, then deploy on Pi.
- Only swap the hardware access layer.

---

## 2. Abstracting Audio Output

- Use `audio_output_init()`, `audio_output_write(buffer, frames)` in your main code.
- Implement these differently for PC (PortAudio) and Pi (I2S/SPI).

---

## 3. Structuring Your Code

- `src/` for platform-independent logic.
- `pc_test/audio_output_portaudio.c` for PC.
- `pi_baremetal/audio_output_i2s.c` for Pi.
- Use `#ifdef` or build system to select.

---

## 4. Writing Platform-Specific Audio Drivers

- **PC:** Use PortAudio (see previous docs).
- **Pi:** Use Circle's I2S or SPI classes, or roll your own.

---

## 5. Handling Endianness and Bit Depth

- Make sure your sample formats match (16-bit, 24-bit, etc.).
- Convert floats to integers carefully.

---

## 6. Managing Audio Buffers and Timing

- Use double buffering or DMA if possible.
- On Pi, use timer interrupt or Circle's audio buffer callback.

---

## 7. Testing Your Engine

- Test all synthesis and mixing on PC first.
- When porting, debug with UART and scope.
- Compare output from both platforms for correctness.

---

## 8. Exercises

- Refactor your code to use an audio abstraction layer.
- Implement audio output for both PC and Pi.
- Test a 4-voice synth on both platforms.

---

**Next:**  
*hybrid_synth_13_testing_debugging_integration.md* — Finding and fixing bugs, and making your synth robust.

---