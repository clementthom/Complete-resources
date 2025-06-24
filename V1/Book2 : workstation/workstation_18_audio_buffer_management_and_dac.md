# Workstation Synth Project – Document 18  
## Audio Buffer Management and DAC Output

---

### Table of Contents

1. What is an Audio Buffer?
2. Real-Time Audio: Buffering and Timing
3. Double Buffering and Latency
4. Mixing Voices into a Buffer
5. Sample Rate Conversion and Interpolation
6. DACs: Types, Wiring, and Output
7. Sending Buffers to the DAC (PC and Pi)
8. Handling Buffer Underruns and Glitches
9. Hands-On: Outputting a Mixed Buffer
10. Exercises

---

## 1. What is an Audio Buffer?

- Array of samples (e.g., 256, 512, 1024) sent to DAC
- Filled by synth engine, consumed by audio output

---

## 2. Real-Time Buffering

- Fill buffers at regular intervals (timer, interrupt)
- Keep latency low for playability

---

## 3. Double Buffering

- One buffer being played, one being filled
- Swap when play buffer is empty

---

## 4. Mixing Voices

- Sum all active voices per sample
- Scale to avoid clipping

---

## 5. Sample Rate Conversion

- Resample if engine and DAC rates differ (linear interpolation)

---

## 6. DACs: Types

- I2S, SPI, PWM
- PCM5102 (I2S), MCP4922 (SPI), internal Pi PWM (lower quality)

---

## 7. Sending Buffers

- **PC:** Use PortAudio or SDL2
- **Pi:** Write to I2S/SPI peripheral or driver

---

## 8. Buffer Underruns

- Occur if buffer not filled in time; causes clicks or dropouts
- Monitor timing, optimize code

---

## 9. Hands-On

- Mix 4 voices and output to DAC
- Visualize buffer fill time (UART, LED, or debug print)

---

## 10. Exercises

- Implement double buffering
- Add underrun detection
- Benchmark max polyphony for your Pi

---

**Next:**  
*workstation_19_sequencer_and_song_mode_architecture.md* — Building the brains for composing and playback.

---