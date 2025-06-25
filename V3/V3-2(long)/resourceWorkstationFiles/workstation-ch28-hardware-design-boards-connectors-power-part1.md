# Chapter 28: Hardware Design – Boards, Connectors, Power  
## Part 1: Theory, System Design, and Core Components

---

## Table of Contents

- 28.1 Introduction: Why Hardware Design Matters
- 28.2 System Architecture and Partitioning
  - 28.2.1 Block Diagrams: From Concept to Schematic
  - 28.2.2 Digital, Analog, and Mixed-Signal Partitioning
  - 28.2.3 Embedded vs. Modular vs. Hybrid Architectures
  - 28.2.4 Expandability and Serviceability Considerations
- 28.3 Board Design Fundamentals
  - 28.3.1 PCB Types: Single, Double, Multi-Layer
  - 28.3.2 Substrates and Materials
  - 28.3.3 Trace Width, Clearance, and Controlled Impedance
  - 28.3.4 Power and Ground Planes
  - 28.3.5 Isolation and Signal Integrity
- 28.4 Core Components and Subsystems
  - 28.4.1 Microprocessors, DSPs, FPGAs: Selection and Placement
  - 28.4.2 Memory: RAM, Flash, EEPROM, Buffering
  - 28.4.3 Audio Codec, ADC/DACs, Clocking and Jitter
  - 28.4.4 Power Management ICs and Regulators
  - 28.4.5 Discrete Analog: Op-amps, Buffers, Protection
  - 28.4.6 Connectors: Audio, MIDI, USB, Network, Power, Expansion
- 28.5 Schematic Design Patterns and Best Practices
- 28.6 Glossary and Reference Tables

---

## 28.1 Introduction: Why Hardware Design Matters

The physical design of your workstation—boards, connectors, and power—defines its reliability, expandability, sonic quality, and manufacturability.  
A poor hardware design can lead to:

- Noise, hum, and crosstalk that ruin audio quality
- Overheating or brownouts that cause dropouts or component failure
- Difficult manufacturing, expensive rework, or impossible repairs
- Incompatibility with industry-standard gear (MIDI, USB, audio, network)
- Safety hazards (shock, fire, ESD damage)

A robust hardware design is the bedrock of every professional instrument, from boutique synths to flagship workstations.

---

## 28.2 System Architecture and Partitioning

### 28.2.1 Block Diagrams: From Concept to Schematic

- **Block diagrams** clarify the system at a high level, showing all major subsystems and their interconnection.
- Components: CPU/DSP, RAM, audio I/O, power, controls, network, displays, storage, expansion slots.
- **Signal flow:** Show data, audio, power, control, and clock paths.

#### 28.2.1.1 Example: Basic Workstation Block Diagram

```
[Power]---+
          |
    [CPU/DSP]----[RAM]
      |             |
[Audio IO]    [Storage]
      |             |
  [MIDI IO]    [Display/UI]
      |             |
 [USB/Net]     [Exp Bus]
```

### 28.2.2 Digital, Analog, and Mixed-Signal Partitioning

- **Digital Blocks:** CPU, RAM, USB, display, network—noisy, high-speed signals.
- **Analog Blocks:** Audio input/output, preamps, filters—low-noise, sensitive to interference.
- **Mixed-Signal:** ADC/DAC, clocks, CODECs—critical for audio quality.
- **Partitioning:** Keep analog and digital physically and electrically separated; use ground planes, guard traces, and shielding.

#### 28.2.2.1 Layout Rule

- Place analog and digital components on opposite sides of the board where possible.
- Route analog traces direct and short; avoid running parallel to digital buses.

### 28.2.3 Embedded vs. Modular vs. Hybrid Architectures

- **Embedded:** All subsystems on a single PCB (common for compact, cost-sensitive devices).
- **Modular:** Separate boards for CPU, I/O, power, etc.; connected via backplane or ribbon cable (high-end, expandable).
- **Hybrid:** Core board + plug-in modules (FX, expansion IO, etc.).

#### 28.2.3.1 Pros/Cons Table

| Architecture | Pros                        | Cons                      |
|--------------|-----------------------------|---------------------------|
| Embedded     | Cheap, compact, robust      | Harder to upgrade/repair  |
| Modular      | Expandable, serviceable     | Expensive, complex        |
| Hybrid       | Best of both, flexible      | Design complexity         |

### 28.2.4 Expandability and Serviceability Considerations

- **Connectors:** Use sockets for key ICs, RAM, and expansion slots.
- **Physical access:** Place test points, jumpers, and headers for debugging.
- **Mounting:** Plan for standoffs, mechanical support, cable routing.
- **Field Service:** Label test points and connectors clearly; design for easy disassembly.

---

## 28.3 Board Design Fundamentals

### 28.3.1 PCB Types: Single, Double, Multi-Layer

- **Single-Layer:** Cheap, easy, but poor for complex/low-noise designs.
- **Double-Layer:** Most hobby and some pro gear; allows for ground/power planes.
- **Multi-Layer (4, 6, 8+):** Required for high-speed, low-noise, or dense boards (modern synths, pro audio).
- **Cost vs. Performance:** More layers = higher cost, but better signal integrity and density.

#### 28.3.1.1 Typical Board Stackups

| Layers | Usage Example           | Comments                      |
|--------|------------------------|-------------------------------|
| 1      | Simple MIDI controller | No ground plane               |
| 2      | Small synth, pedals    | Good for analog/digital split |
| 4      | Pro workstation        | Separate power/ground planes  |
| 6+     | High-speed, FPGA, DSP  | Critical for fast buses       |

### 28.3.2 Substrates and Materials

- **FR-4:** Standard glass-epoxy for most audio and digital boards.
- **High TG FR-4:** Higher temperature, better for lead-free solder/reflow.
- **Rogers, Teflon:** Used for RF, critical analog (not typical in audio).
- **Thickness:** 1.6mm is standard; consider for mechanical stability.

### 28.3.3 Trace Width, Clearance, and Controlled Impedance

- **Trace Width:** Calculated based on expected current, length, and board copper weight (see IPC-2221).
- **Clearance:** Minimum distance between traces—affects voltage isolation, crosstalk.
- **Controlled Impedance:** Required for USB, Ethernet, high-speed memory; match trace width/spacing to board stackup.

#### 28.3.3.1 Example: Calculating Minimum Trace Width

- Use online calculators (Saturn PCB Toolkit, KiCAD calculator).
- For audio lines: 6–10 mil (0.15–0.25mm) typical.
- For 1A power trace on 1oz copper: ~40–60 mil (1–1.5mm).

### 28.3.4 Power and Ground Planes

- **Ground Plane:** Essential for low-noise, EMI control, and signal return paths.
- **Power Plane:** Reduces voltage drop, noise, and allows wide current distribution.
- **Star Ground:** All grounds return to a single central point (prevents ground loops).
- **Split Analog/Digital Grounds:** Sometimes used—must be joined at a single point near ADC/DAC.

#### 28.3.4.1 Layer Usage Example

| Layer | Purpose         |
|-------|-----------------|
| Top   | Signal, analog  |
| L2    | Ground plane    |
| L3    | Power plane     |
| Bottom| Signal, digital |

### 28.3.5 Isolation and Signal Integrity

- **Isolation Gaps:** Physical separation between high-voltage/power and low-level analog.
- **Guard Traces:** Grounded traces between sensitive lines to prevent crosstalk.
- **Differential Pairs:** Used for balanced audio, USB, Ethernet; match length and spacing.
- **Termination:** Series/parallel resistors to avoid reflections on high-speed lines.

#### 28.3.5.1 Critical Guidelines

- Never run power traces under analog inputs.
- Always cross traces at 90° if crossing is unavoidable.
- Place decoupling caps close to every IC Vcc pin.

---

## 28.4 Core Components and Subsystems

### 28.4.1 Microprocessors, DSPs, FPGAs: Selection and Placement

- **Microcontrollers (MCU):** ARM Cortex-M, STM32, NXP, Atmel—good for control, MIDI, basic DSP.
- **DSPs:** Analog Devices SHARC/Blackfin, Texas Instruments C6000—pro audio processing.
- **FPGAs:** For custom logic, glue chips, high-speed parallel processing.
- **Placement:** Center of board, short traces to RAM/flash, avoid long stubs.

#### 28.4.1.1 Processor Selection Criteria

| Feature      | MCU        | DSP         | FPGA        |
|--------------|------------|-------------|-------------|
| Ease of Dev  | Easy       | Moderate    | Complex     |
| DSP Perf     | Low-Med    | High        | Very High   |
| Flexibility  | Moderate   | Low-Med     | Extreme     |
| Cost         | Low        | Med-High    | High        |
| Use Case     | UI, MIDI   | Audio FX    | Custom IO   |

### 28.4.2 Memory: RAM, Flash, EEPROM, Buffering

- **RAM:** For code, data, audio buffers; place close to CPU/DSP.
- **Flash:** Program storage; NOR (execute-in-place), NAND (bulk storage).
- **EEPROM:** Small, for user settings, calibration.
- **Buffering:** FIFO chips, dual-port RAM for audio/MIDI streaming.
- **Layout:** Short, direct traces; avoid crossing clock lines over noisy areas.

### 28.4.3 Audio Codec, ADC/DACs, Clocking and Jitter

- **CODEC:** Integrated ADC/DAC (e.g., Cirrus Logic, AKM, WM), I2S/I2C/SPI interface.
- **Discrete ADC/DAC:** Used for high-end or multi-channel systems.
- **Clocking:** Low-jitter crystal oscillator, PLL, or external word clock.
- **Jitter:** Avoids sample timing errors; use dedicated clock lines, keep away from noisy signals.

#### 28.4.3.1 Clocking Best Practices

- Use separate ground/power for clock, bypass with small (100nF, 10nF) caps.
- Keep clock traces short, shielded, and away from switching regulators.

### 28.4.4 Power Management ICs and Regulators

- **Linear Regulators:** Clean, low-noise (LDO), lower efficiency, heat.
- **Switching Regulators:** High efficiency (buck, boost), more noise—careful layout/filters needed.
- **Sequencing:** Some chips require power rails to come up in order.
- **Protection:** TVS diodes, PTC resettable fuses, reverse-polarity protection.

#### 28.4.4.1 Example: Power Tree

```
[DC In]---[Fuse]---[Switching Reg]---+---[3.3V LDO]---[Analog]
                                     +---[5V Rail]----[Digital]
```

### 28.4.5 Discrete Analog: Op-amps, Buffers, Protection

- **Op-Amps:** For preamps, filters, line drivers; pick low-noise, audio-grade.
- **Buffers:** Isolate high-impedance circuits, drive long cables/loads.
- **Protection:** ESD diodes, input clamping, series resistors on IOs.
- **Reference Voltages:** Precision references for ADC/DAC.

### 28.4.6 Connectors: Audio, MIDI, USB, Network, Power, Expansion

- **Audio:** 1/4" TRS, XLR, RCA, minijack; balanced/unbalanced, ground lift.
- **MIDI:** 5-pin DIN, USB MIDI, TRS MIDI (Type A/B/C), opto-isolated.
- **USB:** Type A/B/C, Micro/mini, with proper ESD protection.
- **Network:** RJ-45 (Ethernet), shielded, with magnetics.
- **Power:** Barrel jack, locking, with polarity and voltage marks.
- **Expansion:** PCIe, edge connectors, ribbon cable, custom headers.

#### 28.4.6.1 Connector Placement Guidelines

- Place connectors on board edge for easy access.
- Allow physical clearance for plugs and strain relief.
- Use keyed connectors to prevent mis-insertion.

---

## 28.5 Schematic Design Patterns and Best Practices

- **Hierarchical Schematics:** Break into sheets by subsystem (CPU, power, IO, audio).
- **Reusable Blocks:** Use proven reference designs from chip vendors.
- **Label Nets Clearly:** VCC, GND, SIGNAL names must match layout and silk.
- **Test Points:** Place test pads for all power rails, main buses, and key signals.
- **Design for Test (DFT):** Allow in-circuit test, programming, and debugging.

#### 28.5.1 Example: Minimal Audio Buffer Schematic

```
[IN]--[R1]--+--[Op-amp]--[OUT]
      |     |
     [C1]  [R2]
      |     |
     GND   GND
```

---

## 28.6 Glossary and Reference Tables

| Term       | Definition                                          |
|------------|-----------------------------------------------------|
| PCB        | Printed Circuit Board                               |
| Ground Loop| Unwanted current loop causing noise/hum             |
| LDO        | Low Dropout (linear) regulator                      |
| Ferrite    | Inductor bead for RF/EMI suppression                |
| CODEC      | Audio coder/decoder (ADC+DAC)                       |
| TVS Diode  | Transient voltage suppressor for ESD protection     |
| Star Ground| Topology where all grounds meet at single point     |

### 28.6.1 Table: Minimum Trace Width for Common Currents

| Current (A) | 1oz Cu Width (mm) | 2oz Cu Width (mm) |
|-------------|-------------------|-------------------|
| 0.1         | 0.13              | 0.07              |
| 0.5         | 0.5               | 0.25              |
| 1.0         | 1.0               | 0.5               |
| 2.0         | 2.0               | 1.0               |

### 28.6.2 Typical Audio Connector Pinouts

| Type      | Tip | Ring | Sleeve | Notes            |
|-----------|-----|------|--------|------------------|
| 1/4" TRS  | L   | R    | GND    | Stereo/Balance   |
| 1/4" TS   | Sig | -    | GND    | Mono/Unbalanced  |
| XLR       | 2   | 3    | 1      | Hot, Cold, GND   |
| MIDI DIN  | 4   | 5    | 2      | Data, Data, GND  |

### 28.6.3 Best Practices Checklist

- [ ] Keep analog and digital isolated as much as possible
- [ ] Always use ground/power planes for low noise
- [ ] Place decoupling caps at every IC Vcc pin
- [ ] Never route signals under high-power traces
- [ ] Use ESD protection on all external IO
- [ ] Label all test points and connectors
- [ ] Plan for expandability and field service

---

**End of Part 1.**  
**Next: Part 2 will go in depth into board layout, EMI/ESD mitigation, audio signal path optimization, connector/panel design, real-world example schematics, compliance, design for manufacture/test/service, and extensive layout code/guides.**

---