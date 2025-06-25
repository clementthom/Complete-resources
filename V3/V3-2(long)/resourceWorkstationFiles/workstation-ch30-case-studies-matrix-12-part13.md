# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 13: Deep Reverse Engineering—Clock, Reset, Power, and Peripheral Subsystems

---

## Table of Contents

- 30.141 Clock Subsystem: Oscillator, Buffers, Distribution, and Failures
  - 30.141.1 Oscillator Circuit: Crystal, Caps, Drive, and Buffer Topology
  - 30.141.2 Clock Buffers, Skew, and Trace Topology
  - 30.141.3 Distribution to CPU, Timers, Panel, and Expansion
  - 30.141.4 Power-On Clock/Reset, Glitch Handling, and Diagnostics
- 30.142 Reset and Watchdog: Hardware, Software, and Startup Sequences
  - 30.142.1 Power-On Reset: RC, Supervisor, and Brownout
  - 30.142.2 Manual Reset, Watchdog Timer, and Panic Recovery
  - 30.142.3 Reset Vector Handling in Firmware
  - 30.142.4 Failure Modes and Safe Recovery
- 30.143 Power Supply, Rails, and Protection: Retro and Modern
  - 30.143.1 Original PSU: Linear Supply, Transformer, and Rails
  - 30.143.2 Regulation: 7805, 7815, 7915, and Tracking
  - 30.143.3 Power Sequencing, Soft Start, and Protection (Fuses, TVS)
  - 30.143.4 Modern PSU Substitution and Noise Mitigation
- 30.144 Peripheral Subsystems: Panel, Keyboard, Wheels, Pedals, and Analog Inputs
  - 30.144.1 Panel Matrix: Button Debounce, Scan, and Latch
  - 30.144.2 Keyboard Matrix: Dual-Contact Velocity, Scan, Aftertouch
  - 30.144.3 Wheels, Pedals, and Analog CVs: Buffering and ADC
  - 30.144.4 Peripheral Expansion: Bus, Protocol, and Timing
- 30.145 Full System Startup, Safety Interlocks, and Field Robustness
  - 30.145.1 Boot Flow: Clock/Reset, RAM Test, Voice Presence, Panel Init
  - 30.145.2 Error/Interlock: PSU Fail, Overcurrent, Overtemp, and User Alerts
  - 30.145.3 Service Mode Entry, Emergency Save, and Data Integrity
- 30.146 Example C Code: Clock, Reset, Watchdog, and Peripheral Scan
  - 30.146.1 Clock Setup, Skew Detect, and Fault Response
  - 30.146.2 Reset/Watchdog Logic and Handler
  - 30.146.3 Panel/Keyboard Scan, Debounce, and Analog Input
  - 30.146.4 Power Fail/Recovery, Data Save, and User Prompt
- 30.147 Appendices: Schematics, Power Rails, and Peripheral Pinouts

---

## 30.141 Clock Subsystem: Oscillator, Buffers, Distribution, and Failures

### 30.141.1 Oscillator Circuit: Crystal, Caps, Drive, and Buffer Topology

- **Crystal Oscillator**:
  - 12MHz AT-cut crystal, parallel mode, with loading caps (typically 22pF) to ground.
  - Inverter-based oscillator (74HC04 or similar), with feedback resistor (1–10MΩ) and series-damping resistor.
- **Drive Strength**:
  - Output of inverter buffered by 1–2 additional inverters for fan-out.
  - Drive matched to minimize ringing and EMI.
- **Startup**:
  - RC delay ensures stable oscillation before releasing clock to system.

### 30.141.2 Clock Buffers, Skew, and Trace Topology

- **Buffering**:
  - Clock signal passes through 74HC04 or 74LS244 to isolate CPU, timer, and peripherals.
- **Skew Management**:
  - PCB traces routed with equal length to critical chips (CPU, timer, panel controller).
  - Star topology preferred; avoid daisy-chaining.
- **EMI/Ringing**:
  - Series resistors (33–100Ω) at buffer outputs dampen reflections.

### 30.141.3 Distribution to CPU, Timers, Panel, and Expansion

- **CPU**:
  - Main clock to 8031/8051 core.
- **Timers**:
  - 8253/8254 or custom logic; programmable for tick rate.
- **Panel/Keyboard**:
  - Slow clock for scan logic; may be divided from main by flip-flops or counter.
- **Expansion Bus**:
  - System clock and timer supplied to expansion header for external peripherals.

### 30.141.4 Power-On Clock/Reset, Glitch Handling, and Diagnostics

- **Power-On Sequence**:
  - RC delay or supervisor chip holds reset until clock is stable.
- **Glitch Detection**:
  - Optional monoflop or supervisor monitors clock continuity; if missing, triggers reset or fault.
- **Diagnostics**:
  - Service menu can display clock health, frequency, and last reset cause.

---

## 30.142 Reset and Watchdog: Hardware, Software, and Startup Sequences

### 30.142.1 Power-On Reset: RC, Supervisor, and Brownout

- **RC Circuit**:
  - Large cap and pull-up resistor delay reset line; ensures minimum reset pulse.
- **Supervisor IC**:
  - Modern builds use voltage supervisor (e.g., MAX809) to monitor +5V; asserts reset if Vcc dips below threshold.
- **Brownout Protection**:
  - Prevents CPU from running at low voltage, which can corrupt RAM/patch data.

### 30.142.2 Manual Reset, Watchdog Timer, and Panic Recovery

- **Manual Reset**:
  - Panel pushbutton, debounced in hardware, pulls reset line low.
- **Watchdog**:
  - 555 or dedicated IC (e.g., MAX1232) monitors CPU activity (periodic strobe from firmware).
  - If missed, triggers hardware reset.
- **Panic Recovery**:
  - If watchdog reset occurs, firmware logs event and enters safe mode on next boot.

### 30.142.3 Reset Vector Handling in Firmware

- **Reset Vector**:
  - On 8031/8051, reset jumps to address 0x0000; bootloader/OS starts here.
  - Bootloader checks RAM/ROM, voice presence, and sets interrupt vectors.
- **Safe Mode**:
  - On repeated resets, firmware can skip normal boot and enter diagnostic/service menu.

### 30.142.4 Failure Modes and Safe Recovery

- **Failure Modes**:
  - Clock fail, brownout, stuck bus, RAM/ROM error, panel stuck.
- **Safe Recovery**:
  - On fault, mask all voices, disable outputs, display error, log to patch RAM.
  - Allow user to recover data if possible.

---

## 30.143 Power Supply, Rails, and Protection: Retro and Modern

### 30.143.1 Original PSU: Linear Supply, Transformer, and Rails

- **Transformer**:
  - Toroidal or EI core, 2×18V secondary (for ±15V), 1×9V (for +5V).
- **Rectifiers**:
  - Bridge rectifiers (1N5402 or similar), with snubber caps for noise.
- **Filter Caps**:
  - 4700–10000uF electrolytic for bulk smoothing.
- **Linear Regulators**:
  - 7815 (+15V), 7915 (–15V), 7805 (+5V), heatsinks mounted to chassis.

### 30.143.2 Regulation: 7805, 7815, 7915, and Tracking

- **Tracking**:
  - Negative rail tracking circuit ensures –15V follows +15V for balanced analog.
- **Bypass/Decoupling**:
  - 0.1uF ceramics at every IC, 10uF tantalum for local regulation.

### 30.143.3 Power Sequencing, Soft Start, and Protection (Fuses, TVS)

- **Power Sequencing**:
  - +5V comes up first; analog ±15V after, to avoid latch-up in digital logic.
- **Soft Start**:
  - NTC thermistor or relay bypass for inrush limit.
- **Protection**:
  - Fuses on all rails, TVS diodes at supply inputs, MOVs for surge.
- **Modern Substitution**:
  - Switch-mode supply with low ripple, high-efficiency, overcurrent and thermal shutdown.

### 30.143.4 Modern PSU Substitution and Noise Mitigation

- **Switch-Mode Retrofit**:
  - High-quality switcher (Meanwell or custom) with linear post-regulation for analog rails.
  - Shielded supply, careful grounding to avoid digital noise on audio.
- **Noise Mitigation**:
  - Star ground, shielded cabling, chassis bonding.

---

## 30.144 Peripheral Subsystems: Panel, Keyboard, Wheels, Pedals, and Analog Inputs

### 30.144.1 Panel Matrix: Button Debounce, Scan, and Latch

- **Button Matrix**:
  - Rows driven by CPU port, columns read via buffer.
  - Hardware debounce: RC filter on each line (typ. 10kΩ, 100nF).
  - Software debounce: ignore toggles <10ms.
- **Latch**:
  - 74HC573 or 74LS259 used for LED or softkey latching.

### 30.144.2 Keyboard Matrix: Dual-Contact Velocity, Scan, Aftertouch

- **Rows/Cols**:
  - Typical 8×12 grid (96 keys); rows driven, cols read.
- **Dual Contact**:
  - Two switches per key: “make” (initial) and “break” (after delay).
  - Velocity calculated from time between make and break; stored in event buffer.
- **Aftertouch**:
  - Resistive strip, read via ADC, per-key or global.
  - Sampled during key press, mapped to matrix.

### 30.144.3 Wheels, Pedals, and Analog CVs: Buffering and ADC

- **Wheels**:
  - Potentiometer or Hall sensor, buffered by op-amp, read by ADC.
- **Pedals**:
  - Sustain (switch), expression (pot), assignable inputs.
  - Buffered, protected by diode clamp, read by ADC.
- **Analog CVs**:
  - External CV input mapped to mod matrix; protected by clamp diodes and resistors.

### 30.144.4 Peripheral Expansion: Bus, Protocol, and Timing

- **Expansion Bus**:
  - Address/data bus, clock, chip select; supports new panel/keyboard modules.
- **Protocol**:
  - Handshake lines for ready/busy, interrupt, and data valid.
- **Timing**:
  - Peripheral scan integrated in main timer ISR; supports up to 2–4 additional modules.

---

## 30.145 Full System Startup, Safety Interlocks, and Field Robustness

### 30.145.1 Boot Flow: Clock/Reset, RAM Test, Voice Presence, Panel Init

- **Sequence**:
  1. Power On: RC/supervisor holds reset, clock stabilizes.
  2. CPU starts; RAM/ROM checks, voice cards polled.
  3. Panel/keyboard, wheels/pedals initialized.
  4. Last patch loaded, matrix updated, DAC/mux primed.
  5. Ready for user input; errors shown if hardware fails.

### 30.145.2 Error/Interlock: PSU Fail, Overcurrent, Overtemp, and User Alerts

- **PSU Fail**:
  - Supervisor or ADC monitors all rails; drop triggers error and safe shutdown.
- **Overcurrent/Overtemp**:
  - Heatsink, supply, or board-mounted thermistor triggers shutdown or fan.
- **User Alerts**:
  - Panel LEDs and LCD display error/alert; MIDI sysex for remote notification.

### 30.145.3 Service Mode Entry, Emergency Save, and Data Integrity

- **Service Mode**:
  - Entered on repeated reset, error, or user request.
- **Emergency Save**:
  - On error, firmware copies edit buffer and patch RAM to backup SRAM/EEPROM or prompts user to backup via MIDI.
- **Data Integrity**:
  - All patch/corr tables CRC-checked at boot and periodically during operation.

---

## 30.146 Example C Code: Clock, Reset, Watchdog, and Peripheral Scan

### 30.146.1 Clock Setup, Skew Detect, and Fault Response

```c
void clock_init() {
    set_crystal_oscillator(12e6);
    enable_inverter_buffer();
    for (int i = 0; i < NUM_CLOCK_OUTS; ++i) {
        route_clock_to(i);
        check_skew(i);
    }
    if (clock_fault()) {
        display_error("CLOCK FAULT");
        enter_safe_mode();
    }
}
```

### 30.146.2 Reset/Watchdog Logic and Handler

```c
void reset_handler() {
    if (is_power_on_reset()) display_status("POWER ON");
    else if (is_watchdog_reset()) {
        log_event("WATCHDOG RESET");
        display_status("WDOG RESET");
        enter_service_mode();
    }
    else if (is_brownout()) {
        display_status("BROWNOUT");
        enter_safe_mode();
    }
    // On all resets: re-init RAM, reload patch, check error log
}

void watchdog_kick() {
    output_high(WATCHDOG_PIN);
    delay_us(10);
    output_low(WATCHDOG_PIN);
}
```

### 30.146.3 Panel/Keyboard Scan, Debounce, and Analog Input

```c
void scan_panel() {
    for (int row = 0; row < PANEL_ROWS; ++row) {
        set_panel_row(row);
        delay_us(10);
        uint8_t cols = read_panel_cols();
        for (int col = 0; col < PANEL_COLS; ++col) {
            if (debounce(cols, row, col))
                queue_panel_event(row, col);
        }
    }
}

void scan_keyboard() {
    for (int row = 0; row < KB_ROWS; ++row) {
        set_kb_row(row);
        delay_us(10);
        uint8_t cols = read_kb_cols();
        for (int col = 0; col < KB_COLS; ++col) {
            if (debounce(cols, row, col))
                queue_kb_event(row, col);
        }
    }
}

uint16_t read_analog(uint8_t channel) {
    select_adc_channel(channel);
    delay_us(5);
    return adc_read();
}
```

### 30.146.4 Power Fail/Recovery, Data Save, and User Prompt

```c
void power_monitor() {
    if (get_psu_voltage() < MIN_VOLTAGE) {
        display_status("POWER FAIL");
        backup_patch_ram();
        enter_safe_mode();
    }
    if (get_temp() > MAX_TEMP) {
        display_status("OVERHEAT");
        shutdown_outputs();
    }
}
```

---

## 30.147 Appendices: Schematics, Power Rails, and Peripheral Pinouts

### 30.147.1 Example Clock/Reset Schematic (Textual)

```
[12MHz Crystal]
   |---[22pF]---GND
   |---[22pF]---GND
   |---[HC04 Inv]---[HC04 Inv]---[HC04 Inv]---CPU CLK IN
   |---[HC04 Inv]---Timer/Panel/Expansion
   |---[RC]---[Reset Pin CPU]
   |---[Supervisor IC]---[Reset Pin CPU]
```

### 30.147.2 Power Rail Table

| Rail    | Nominal | Tolerance | Loads           | Protection        |
|---------|---------|-----------|-----------------|-------------------|
| +15V    | 15.0V   | ±0.2V     | Analog, VCO/VCF | Fuse, TVS         |
| –15V    | –15.0V  | ±0.2V     | Analog, VCA     | Fuse, TVS         |
| +5V     | 5.0V    | ±0.1V     | Digital, Panel  | Fuse, TVS         |

### 30.147.3 Peripheral Pinout (Example Panel Header)

| Pin | Signal       | Function           |
|-----|--------------|--------------------|
| 1   | +5V          | Power              |
| 2   | GND          | Ground             |
| 3   | ROW0         | Panel row select   |
| ... | ...          | ...                |
| 10  | COL0         | Panel col read     |
| ... | ...          | ...                |
| 20  | LED0         | Panel LED drive    |
| ... | ...          | ...                |

---

**End of Part 13: Matrix-12 Deep Reverse Engineering—Clock, Reset, Power, and Peripheral Subsystems – Complete Deep Dive.**

*This installment documents the low-level hardware essentials for reliable and serviceable Matrix-12 recreation, including all timing, reset, and power details for robust real-world builds.*

---