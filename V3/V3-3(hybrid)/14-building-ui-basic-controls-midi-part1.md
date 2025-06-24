# Chapter 14: Building the UI – Basic Controls & MIDI – Part 1

---

## Table of Contents

1. Introduction to Synth User Interfaces
    - What is a UI in hardware/software synths?
    - Balancing accessibility, flexibility, and performance
    - Hardware, software, and hybrid UIs
2. Hardware Controls: Knobs, Sliders, Switches, and Buttons
    - Types of controls and their roles
    - Potentiometers vs encoders
    - Debouncing and input reliability
    - Reading analog and digital controls on Raspberry Pi
3. Designing a User Interface for Embedded Synths
    - Principles of UI design for musical instruments
    - Mapping controls to parameters: best practices
    - Feedback: LEDs, displays, and UI indicators
    - Accessibility and ergonomic considerations
4. Implementing Basic Controls in C
    - GPIO: reading switches and buttons
    - ADCs: reading potentiometers and sliders
    - Handling rotary encoders (incremental, absolute, detented)
    - Debouncing code examples (hardware/software)
    - Scaling and mapping control values to synth parameters
    - Threading and polling strategies
5. Display and Feedback Elements
    - LEDs: single, RGB, bargraphs, and multiplexing
    - 7-segment, character, and graphic OLED/LCD displays
    - SPI/I2C displays: wiring and code
    - Display drivers and framebuffers in C
    - Updating displays efficiently in real time

---

## 1. Introduction to Synth User Interfaces

A synthesizer’s user interface (UI) is the bridge between the musician’s intent and the instrument’s sound. For embedded synths, the UI can be hardware (knobs, buttons, displays), software (GUIs on PC or touchscreen), or a hybrid of both.

### 1.1 What is a UI in Hardware/Software Synths?

- **Hardware UIs:** Direct, tactile control via physical knobs, sliders, switches, and displays.
- **Software UIs:** Mouse, keyboard, touchscreen, or MIDI controller interaction via graphical interfaces.
- **Hybrid UIs:** Combine hardware immediacy with software flexibility, e.g. a synth with a touchscreen and physical knobs.

### 1.2 Balancing Accessibility, Flexibility, and Performance

- **Accessibility:** Easy to understand and use, even for beginners.
- **Flexibility:** Allow deep control of many parameters without overwhelming the user.
- **Performance:** UI must be responsive; no lag between user action and sound change.

### 1.3 Hardware, Software, and Hybrid UIs

- Hardware UIs are prized for live performance and muscle memory.
- Software UIs excel in visualization, patch management, and complex routing.
- Modern synths often use both: physical controls for the essentials, digital menus for advanced features.

---

## 2. Hardware Controls: Knobs, Sliders, Switches, and Buttons

### 2.1 Types of Controls and Their Roles

- **Knobs (Rotary Potentiometers):** Continuous parameter control (cutoff, resonance, volume).
- **Sliders:** Long-throw faders, often for envelopes, mixers, or pitch.
- **Rotary Encoders:** Infinite rotation, can send up/down events or absolute position.
- **Buttons:** Momentary (trigger, tap tempo) or toggle (on/off).
- **Switches:** Selects between discrete modes or routings.

### 2.2 Potentiometers vs Encoders

- **Potentiometers:** Analog, absolute; read by ADC, give direct value.
    - Pros: Intuitive, direct mapping, tactile feedback.
    - Cons: Cannot easily detect position changes after power cycle; can wear out.
- **Encoders:** Digital, relative (incremental) or absolute (rare); interpreted by code.
    - Pros: Unlimited rotation, no end stops, can support push function.
    - Cons: Require more code (debounce, direction detection), can feel less “analog”.

### 2.3 Debouncing and Input Reliability

- **Debouncing:** Mechanical switches and buttons often “bounce” (rapid on/off) when pressed or released.
    - *Hardware debounce:* RC filters, Schmitt triggers.
    - *Software debounce:* Wait for stable state over N reads.

#### Example: Software Debounce Code

```c
#define DEBOUNCE_TIME_MS 10
uint32_t last_press_time = 0;
int last_state = 0;

int debounce_button(int pin) {
    int reading = gpio_read(pin);
    if (reading != last_state) {
        last_press_time = millis();
    }
    if ((millis() - last_press_time) > DEBOUNCE_TIME_MS) {
        last_state = reading;
    }
    return last_state;
}
```

### 2.4 Reading Analog and Digital Controls on Raspberry Pi

- **Analog (pots, sliders):** Pi lacks built-in ADC; use external ADC chips (MCP3008, ADS1115) via SPI/I2C.
- **Digital (buttons, switches, encoders):** Directly connected to GPIO pins.
- **Pull-up/down resistors:** Needed for reliable digital reads.

#### Example: Reading a Button with libgpiod

```c
#include <gpiod.h>
struct gpiod_chip *chip;
struct gpiod_line *line;
chip = gpiod_chip_open("/dev/gpiochip0");
line = gpiod_chip_get_line(chip, 17);
gpiod_line_request_input(line, "synth");
int value = gpiod_line_get_value(line);
gpiod_chip_close(chip);
```

---

## 3. Designing a User Interface for Embedded Synths

### 3.1 Principles of UI Design for Musical Instruments

- **Immediate feedback:** Every control should have an immediate, audible or visible effect.
- **Logical grouping:** Cluster related controls (e.g., filter, envelope) together.
- **Minimal menu-diving:** Keep essential functions on the surface.
- **Consistency:** Similar controls should behave similarly throughout the synth.
- **Error prevention:** Prevent accidental changes to important parameters (e.g., patch save/load).

### 3.2 Mapping Controls to Parameters: Best Practices

- **Direct mapping:** Pot controls filter cutoff directly, not via menu.
- **Parameter scaling:** Linear for some (volume), logarithmic for others (frequency).
- **Soft takeover:** For digital pots/encoders, avoid jumps by syncing control and parameter positions.
- **MIDI learn:** Allow user to map external MIDI controls to synth parameters.

### 3.3 Feedback: LEDs, Displays, and UI Indicators

- **LEDs:** Show status (power, MIDI activity, voice allocation, etc.).
- **Displays:** Provide parameter values, patch names, metering.
- **Bargraphs/meters:** Visualize envelopes, LFOs, audio levels.

### 3.4 Accessibility and Ergonomic Considerations

- **Knob size and spacing:** Large enough for precise control, spaced to avoid accidental bumps.
- **Labeling:** Clear, readable, with logical grouping.
- **Color coding:** Use colored knobs/LEDs for key functions.
- **Physical accessibility:** Consider left/right handedness, reach, and panel angles.

---

## 4. Implementing Basic Controls in C

### 4.1 GPIO: Reading Switches and Buttons

- Use a modern GPIO library (`libgpiod` preferred on Linux/Pi).
- Configure pin as input, enable internal/external pull-up/down resistor.
- Poll or use interrupts for button presses.

#### Example: Polling Button State

```c
int button_state = gpiod_line_get_value(line);
if (button_state == 1) {
    // Button pressed, trigger synth action
}
```

### 4.2 ADCs: Reading Potentiometers and Sliders

- Use SPI/I2C ADC chips; connect analog controls to ADC channels.
- Typical chips: MCP3008 (10-bit, SPI), ADS1115 (16-bit, I2C), MCP3208 (12-bit, SPI).
- Read analog values, scale to parameter range.

#### Example: Reading MCP3008 on Pi (pseudo-code)

```c
int adc_value = mcp3008_read(channel);
float normalized = adc_value / 1023.0f;
set_filter_cutoff(normalized * max_cutoff);
```

### 4.3 Handling Rotary Encoders

- **Incremental encoders:** Two signals (A/B), track direction and speed.
- **Interrupts:** For precise, low-latency response.
- **Debounce:** Required for clean direction changes.

#### Example: Simple Encoder Algorithm

```c
void encoder_update(int a, int b) {
    static int last_a = 0, last_b = 0;
    if (a != last_a || b != last_b) {
        if (a == b) increment_param();
        else decrement_param();
    }
    last_a = a; last_b = b;
}
```

### 4.4 Debouncing Code Examples

- Extend the earlier debounce code for multiple buttons.
- Use a timer or polling interval for regular checks.
- Consider hardware debounce for mission-critical controls.

### 4.5 Scaling and Mapping Control Values

- Map raw ADC values to meaningful synth parameters.
- Use lookup tables or formulas for nonlinear scaling (e.g., exponential for frequency).

#### Example: Logarithmic Scaling

```c
float scale_log(float val, float min, float max) {
    return min * powf((max/min), val);
}
```

### 4.6 Threading and Polling Strategies

- Use a dedicated thread for reading controls if possible.
- Poll at 100–500 Hz for responsive UI.
- Use mutexes/queues to communicate changes to the audio thread.

---

*End of Part 1. Part 2 will cover display feedback, menu systems, advanced UI logic, MIDI implementation (input/output, mapping), MIDI learn, and integrating hardware/software UIs for embedded synths.*