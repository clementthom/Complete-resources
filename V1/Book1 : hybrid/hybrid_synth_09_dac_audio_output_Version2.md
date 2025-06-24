# Hybrid Synthesizer Project – Document 9  
## DACs and Audio Output: From Bits to Sound

---

### Table of Contents

1. What is a DAC and Why Do We Need One?
2. Types of DACs for DIY Synths
3. Choosing a DAC for Your Project
4. Theory: How a DAC Converts Digital to Analog
5. Wiring Up Your DAC (PCM5102, MCP4922, etc.)
6. Testing DAC Output with a PC or Arduino
7. Interfacing DACs with the Raspberry Pi
8. First Sound: Sending Samples from C
9. Troubleshooting: No Sound, Distortion, Noise
10. Exercises: Making Your First Real Audio

---

## 1. What is a DAC and Why Do We Need One?

A **Digital-to-Analog Converter (DAC)** turns your code's numbers into real-world voltages (analog audio).  
**Without a DAC, your synth can't make sound!**  
The DAC is the bridge between your digital code and the analog world.

---

## 2. Types of DACs for DIY Synths

- **I2S DACs (e.g., PCM5102):** High-quality, stereo audio, used in commercial gear.
- **SPI DACs (e.g., MCP4922):** Simple, mono/stereo, lower sample rates.
- **PWM output:** "Fakes" a DAC; not recommended for high-quality synths.

---

## 3. Choosing a DAC for Your Project

**Recommended:**  
- **PCM5102 (I2S):** Cheap, high quality, lots of guides.  
- **MCP4922 (SPI):** Good for learning, easier to breadboard.  
- **PCM1794, ES9023, etc.:** For advanced users.

**Consider:**  
- Sample rate (44.1kHz or higher)
- Bit depth (16, 24 bits)
- Mono or stereo
- Breadboard friendliness

---

## 4. Theory: How a DAC Converts Digital to Analog

- Code generates discrete samples (integers or floats).
- DAC receives samples at a fixed sample rate (e.g., 44100 per second).
- DAC outputs a voltage corresponding to each sample.
- Output is (usually) centered around 0V (for audio).

---

## 5. Wiring Up Your DAC (PCM5102, MCP4922, etc.)

**PCM5102 (I2S):**
- Connects to Pi's I2S pins (BCLK, LRCK, DIN, GND, 3.3V)
- Ready-made modules available

**MCP4922 (SPI):**
- Connects to SPI lines (SCK, MOSI, CS, LDAC, Vref, GND, Vcc)
- Needs voltage reference (often 3.3V or 5V)

**Check datasheets for pinouts! Always double-check Vcc and GND.**

---

## 6. Testing DAC Output with a PC or Arduino

- Before connecting to the Pi, test your DAC with a simple Arduino or PC project.
- Send a ramp, triangle, or constant value and measure with a multimeter or listen to output.
- Confirm you see expected voltages or hear expected tones.

---

## 7. Interfacing DACs with the Raspberry Pi

- **PCM5102:** Use Pi's I2S hardware (bare-metal or Linux driver).
- **MCP4922:** Bit-bang SPI in C or use SPI hardware.
- Use level shifters if your Pi/DAC voltages don't match.

**Note:** Many tutorials exist for both Pi and Arduino—read a few for confidence!

---

## 8. First Sound: Sending Samples from C

- Modify your sound engine to output to the DAC instead of PortAudio.
- Write a function to fill a buffer with samples and send them out at the correct rate.
- **On Pi:** Use a timer interrupt or DMA (see Circle or Ultibo frameworks).

---

## 9. Troubleshooting: No Sound, Distortion, Noise

- **Check power:** Is the DAC getting the right voltage?
- **Check connections:** Are wires correct, no shorts?
- **Use scope/multimeter:** Is there a signal at the output pin?
- **Buffer underruns:** Make sure your code is filling buffers fast enough.
- **Distortion:** Check scaling and bit depth.

---

## 10. Exercises: Making Your First Real Audio

- Wire up your DAC and send a 1kHz sine wave from the Pi.
- Try outputting a ramp, triangle, and square wave.
- Sweep the frequency and hear the change.
- Try mixing two frequencies.

---

**Next:**  
*hybrid_synth_10_analog_filters_vcas.md* — Shape your sound with analog filters and amplifiers.

---