# Chapter 10: Interfacing Pi 4 with DACs and Analog Circuits – Part 2

---

## Table of Contents

6. Digital Communication Protocols Deep Dive
    - SPI: how it works, timing, multi-device setups, Pi configuration
    - I2C: address structure, clock stretching, pull-ups, multi-master
    - I2S: audio streaming, word clock, bit clock, frame sync
    - Linux device tree overlays for enabling interfaces
7. Low-Level C Code for DAC Communication on Raspberry Pi
    - SPI: wiringPi, spidev, bcm2835 libraries
    - I2C: wiringPi, smbus, native Linux interface
    - I2S: ALSA, custom drivers, challenges and solutions
    - Initializing, sending data, timing, error handling
    - Buffering and real-time constraints
8. Analog Interface Circuits
    - Buffer amplifiers: op-amp circuits for DAC outputs
    - Level shifting and scaling for modular/CV synths
    - Low-pass (reconstruction) filters: removing digital stair-steps
    - Power supply separation, analog/digital ground, shielding
    - Protection: clamping diodes, ESD, overvoltage
    - Practical breadboard and PCB layouts
9. Measurement, Debugging, and Troubleshooting
    - Using an oscilloscope for digital and analog lines
    - Logic analyzers: decoding SPI/I2C/I2S
    - Audio analyzers and software tools
    - Diagnosing common problems: noise, glitches, data corruption
    - Best practices for robust operation
10. Hands-On: Example Projects & Exercises
    - Sending a waveform from Pi to a DAC for audio output
    - Generating CV for analog synth modules
    - Measuring, analyzing, and tuning output with scopes and analyzers
    - Combining digital control and analog sound

---

## 6. Digital Communication Protocols Deep Dive

### 6.1 SPI (Serial Peripheral Interface)

**SPI** is a synchronous serial protocol commonly used for fast communication between microcontrollers and peripherals like DACs, ADCs, and displays.

#### SPI Basics

- **Lines:** MOSI (Master Out, Slave In), MISO (Master In, Slave Out), SCLK (Serial Clock), CS/SS (Chip Select/Slave Select)
- **Full duplex:** Data can be sent and received simultaneously.
- **Speed:** Up to tens of MHz (Pi supports >30MHz on some pins).
- **Multi-device:** Each peripheral gets its own CS line.

#### SPI Timing

- Data is shifted out on one clock edge and sampled on the other.
- SPI mode (0–3) defines clock polarity and phase.

#### Typical Transaction

1. Pull CS low.
2. Clock out data (MOSI), read back (MISO if needed).
3. Raise CS.

#### On Pi

- Hardware SPI on pins 19 (MOSI), 21 (MISO), 23 (SCLK), 24 (CE0), 26 (CE1).
- Enable via `raspi-config` or device tree overlays.

### 6.2 I2C (Inter-Integrated Circuit)

**I2C** is a two-wire, synchronous, multi-master, multi-slave protocol for communication with sensors, EEPROMs, and some low-speed DACs.

#### I2C Basics

- **Lines:** SDA (data), SCL (clock)
- **Addressing:** Each device has a 7- or 10-bit address.
- **Speed:** Standard (100kHz), Fast (400kHz), High-Speed (3.4MHz—rare on Pi).
- **Pull-ups:** Both lines require pull-up resistors (1–10kΩ typical).

#### Protocol

- Master initiates communication.
- Start condition, address + R/W bit, data bytes, stop condition.
- Supports clock stretching (slave can hold SCL low if not ready).

#### Multi-device

- Many devices can share the bus, each with unique address.

### 6.3 I2S (Inter-IC Sound)

**I2S** is a dedicated serial bus for digital audio. Unlike SPI/I2C, it streams audio data synchronously.

#### I2S Basics

- **Lines:** SD (Serial Data), SCK (Serial Clock), WS (Word Select, a.k.a. LRCK), sometimes MCLK (Master Clock)
- **Bit depth and sample rate:** Supports 16–32 bits, 44.1kHz to >192kHz.
- **Frame sync:** WS pin toggles for left/right channels.
- **Data format:** MSB-first, left-justified or right-justified.

#### On Pi

- Hardware I2S available on GPIO 18 (PCM_CLK), 19 (PCM_FS), 20 (PCM_DIN), 21 (PCM_DOUT).
- Must be enabled in `/boot/config.txt` and device tree.

### 6.4 Linux Device Tree Overlays

Device tree overlays are used to enable and configure hardware interfaces on Pi.

- **Edit `/boot/config.txt`** to enable SPI/I2C/I2S:
    ```
    dtparam=spi=on
    dtparam=i2c_arm=on
    dtoverlay=hifiberry-dac
    ```
- **Reboot** after changes.
- **Check with `lsmod` or `dmesg`** that devices are loaded.

---

## 7. Low-Level C Code for DAC Communication on Raspberry Pi

### 7.1 SPI: Libraries and Usage

- **wiringPi:** Simple, but deprecated. Use for legacy code.
- **spidev:** Linux kernel driver, accessible via `/dev/spidev*`. Use for robust, portable code.
- **bcm2835:** Low-level, fast, supports advanced features.

#### Example: SPI Write with spidev

```c
#include <fcntl.h>
#include <sys/ioctl.h>
#include <linux/spi/spidev.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>

int spi_fd;
uint8_t spi_mode = SPI_MODE_0;
uint32_t spi_speed = 1000000; // 1 MHz

void init_spi(const char *device) {
    spi_fd = open(device, O_RDWR);
    ioctl(spi_fd, SPI_IOC_WR_MODE, &spi_mode);
    ioctl(spi_fd, SPI_IOC_WR_MAX_SPEED_HZ, &spi_speed);
}

void spi_write(uint8_t *data, size_t len) {
    write(spi_fd, data, len);
}
```

#### Sending Data to MCP4922

- Build 16-bit word: 4 control bits + 12 data bits.
- Send MSB first.

### 7.2 I2C: Libraries and Usage

- **wiringPi:** Simple, but deprecated.
- **smbus:** Standard Linux interface.
- **Native Linux I2C:** Use `/dev/i2c-*` and ioctl.

#### Example: I2C Write

```c
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <unistd.h>

int i2c_fd;
int addr = 0x60; // DAC I2C address

void init_i2c(const char *device) {
    i2c_fd = open(device, O_RDWR);
    ioctl(i2c_fd, I2C_SLAVE, addr);
}

void i2c_write(uint8_t *data, size_t len) {
    write(i2c_fd, data, len);
}
```

### 7.3 I2S: Audio Streaming

- **ALSA:** Advanced Linux Sound Architecture, handles audio streams.
- **I2S device:** Appears as a sound card after overlay is loaded.
- Use ALSA API for playback (PCM interface).

#### Example: Write Audio Buffer

```c
#include <alsa/asoundlib.h>
snd_pcm_t *pcm_handle;
snd_pcm_open(&pcm_handle, "default", SND_PCM_STREAM_PLAYBACK, 0);
// Configure sample rate, channels, format
// Write audio buffer:
snd_pcm_writei(pcm_handle, audio_buffer, frames);
```

- **Challenges:** Buffer size, underruns/overruns, real-time performance.

### 7.4 Buffering and Real-Time Considerations

- **Double buffering:** Avoids glitches by writing one buffer while the other is played.
- **Timing:** Use timers or real-time threads for precise output.
- **Error handling:** Check return values, handle device disconnects.

---

## 8. Analog Interface Circuits

### 8.1 Buffer Amplifiers: Op-Amp Circuits for DAC Outputs

- Most DACs cannot drive low-impedance loads directly.
- Use a **unity-gain buffer** (op-amp follower, e.g., TL072) to isolate and drive output.
- For modular/CV, use rail-to-rail op-amps for full voltage swing.

#### Example: Buffer Circuit

```
DAC OUT ---[Op-Amp Buffer]--- AUDIO/CV OUT
```

### 8.2 Level Shifting and Scaling

- Many DACs output 0–3.3V or 0–5V, but synth CV often needs ±5V or ±10V.
- Use op-amp circuits to shift and scale voltage range.

#### Example: Level Shifter

- **Non-inverting amplifier with offset voltage** applied to reference pin.

### 8.3 Low-Pass (Reconstruction) Filters

- DAC output is stepped; filter removes high-frequency “stair steps.”
- Simple RC filter: `f_c = 1/(2πRC)`.
- For audio, cutoff 2–5kHz below Nyquist frequency.

#### Example: RC Filter

```
DAC OUT --[R]--+-- AUDIO OUT
               |
             [C]
               |
             GND
```

### 8.4 Power Supply Separation, Analog/Digital Ground, Shielding

- Keep analog and digital power/ground separate to reduce noise.
- Use star grounding; connect analog and digital at one point.
- Shield cables for long runs or noisy environments.

### 8.5 Protection

- Add **clamping diodes** to prevent overvoltage/ESD.
- Use **series resistors** on outputs to limit current.
- Protect analog inputs from static or accidental shorts.

### 8.6 Practical Breadboard and PCB Layouts

- Keep analog traces short and away from digital/SPI/I2S lines.
- Use ground planes on PCBs.
- Decouple every IC with 0.1µF ceramic capacitor.

---

## 9. Measurement, Debugging, and Troubleshooting

### 9.1 Oscilloscope for Digital and Analog Lines

- **Digital:** Check SPI/I2C/I2S clocks, data, chip select timing.
- **Analog:** Measure DAC output, look for glitches, stair-steps, noise.
- **Trigger:** Use oscilloscope trigger to sync with events.

### 9.2 Logic Analyzers

- **Decode SPI/I2C/I2S:** Capture and analyze protocol timing.
- **Cheap options:** Saleae Logic, OpenBench Logic Sniffer, or even Arduino-based analyzers.
- **Software:** sigrok/PulseView.

### 9.3 Audio Analyzers and Software Tools

- **Audio interface + DAW:** Capture and analyze audio output.
- **Software:** Audacity, REW, Voxengo Span for spectrum analysis.

### 9.4 Diagnosing Common Problems

- **No output:** Check wiring, software initialization, power, and pin assignments.
- **Noise:** Isolate analog/digital grounds, check power supply ripple, add more decoupling.
- **Glitches:** Check SPI/I2C timing, buffer underruns, or code bugs.
- **Data corruption:** Use logic analyzer to confirm protocol integrity.

### 9.5 Best Practices

- Always check voltages before connecting expensive gear.
- Test with simple code before integrating with complex synth engine.
- Document pinout, wiring, and code versions for reproducibility.

---

## 10. Hands-On: Example Projects & Exercises

### 10.1 Sending a Waveform from Pi to a DAC

- Generate a sine/square/sawtooth in C.
- Send samples over SPI/I2C/I2S.
- Monitor output on oscilloscope and speakers.

### 10.2 Generating CV for Analog Synth Modules

- Use DAC and buffer op-amp to produce 0–5V or ±5V.
- Control pitch, filter, or envelope of analog synth from Pi.

### 10.3 Measuring, Analyzing, and Tuning Output

- Use scope to calibrate output levels and filter cutoff.
- Use audio analyzer for THD/SNR measurements.

### 10.4 Combining Digital Control and Analog Sound

- Use Pi to send digital envelopes/LFOs to analog VCF/VCA.
- Hybridize: digital oscillators, analog filters, and FX.

---

## 11. Summary and Further Reading

- Pi 4 is a powerful bridge between digital and analog audio worlds.
- Mastering SPI/I2C/I2S protocols and analog interfacing is essential for synth builders.
- Use proper buffering, filtering, and grounding to ensure clean, reliable signals.
- Test and debug with both hardware (scope, analyzer) and software (logging, visualization).
- Combine digital control and analog sound for unique, expressive instruments.

**Further Reading**
- “Raspberry Pi Cookbook” by Simon Monk (hardware projects)
- “Make: Analog Synthesizers” by Ray Wilson (analog circuits)
- Datasheets: MCP4922, PCM5102A, TLV320, etc.
- Pi forums and GitHub projects (search for “Raspberry Pi synth DAC”)

---

*End of Chapter 10. Next: Porting Synth Code from PC to Raspberry Pi (bare-metal vs Linux, CMake, toolchains, performance, and real-world examples).*