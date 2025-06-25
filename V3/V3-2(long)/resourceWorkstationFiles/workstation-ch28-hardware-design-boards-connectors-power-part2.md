# Chapter 28: Hardware Design – Boards, Connectors, Power  
## Part 2: In-Depth Board Layout, EMI/ESD, Audio Path, Connectors, Compliance, and DFM

---

## Table of Contents

- 28.7 Board Layout: Step-by-Step Process and Tools
  - 28.7.1 Schematic Capture and Netlist Generation
  - 28.7.2 Component Placement: Priorities and Strategies
  - 28.7.3 Trace Routing: Manual, Autoroute, and Best Practice
  - 28.7.4 Layer Stackup Optimization and High-Speed Design
  - 28.7.5 Placement of Decoupling, Filtering, and Power Distribution
  - 28.7.6 Grounding and Shielding: Analog, Digital, Mixed
  - 28.7.7 Panelization, Fiducials, and Mechanical Integration
- 28.8 EMI/ESD Mitigation and EMC Compliance
  - 28.8.1 Sources of EMI in Audio Workstations
  - 28.8.2 Layout Strategies for EMI Reduction
  - 28.8.3 ESD Protection Techniques: Board-Level and System
  - 28.8.4 Shielding: Cans, Coatings, and Chassis Ground
  - 28.8.5 EMC Pre-Compliance: Measurement and Remediation
- 28.9 Audio Signal Path Optimization
  - 28.9.1 Input/Output Stages: Balanced, Unbalanced, Differential Routing
  - 28.9.2 Ground Loops, Hum, and Isolation
  - 28.9.3 Analog Filtering, Anti-Aliasing, and Protection
  - 28.9.4 Minimize Crosstalk and Channel Bleed
  - 28.9.5 Using Relays, Soft-Start, and Muting Circuits
- 28.10 Connectors and Panel Design
  - 28.10.1 Mechanical Considerations: Placement, Strength, Accessibility
  - 28.10.2 Connector Types: Audio, MIDI, USB, Power, Network, Expansion
  - 28.10.3 Strain Relief, Locking, and Cable Management
  - 28.10.4 Panel Cutouts, Silkscreen, and Labeling
  - 28.10.5 Integration with Enclosure: Tolerances and Assembly
- 28.11 Compliance, DFM, and Documentation
  - 28.11.1 Regulatory Compliance: CE, FCC, RoHS, REACH, WEEE
  - 28.11.2 Design for Manufacturability (DFM)
  - 28.11.3 Design for Test (DFT) and Service (DFS)
  - 28.11.4 Board Files, Assembly Drawings, and Change Control
  - 28.11.5 BOM, Procurement, and Component Sourcing
- 28.12 Real-World Example: Workstation Audio Mainboard Layout Walkthrough
- 28.13 Glossary and Reference Tables

---

## 28.7 Board Layout: Step-by-Step Process and Tools

### 28.7.1 Schematic Capture and Netlist Generation

- **Schematic Capture:** Use EDA tools (KiCAD, Altium, Eagle, OrCAD) to draw every connection/symbol.
- **Netlist:** Software-generated list of all electrical connections; forms the basis for board layout.
- **Annotation:** Number and label every part; assign reference designators (U1, R2).
- **ERC/DRC:** Run Electrical Rule Check and Design Rule Check for mistakes before layout.

#### 28.7.1.1 Typical Schematic Sheet Organization

- Power Input/Regulation
- Processor/DSP Core
- Memory
- Audio I/O and CODEC
- MIDI/USB/Network
- User Interface
- Connectors

### 28.7.2 Component Placement: Priorities and Strategies

- **Place Connectors First:** Board edge for easy panel integration.
- **Critical Components:** CPU, RAM, CODEC near each other to minimize trace length.
- **Analog vs. Digital:** Analog parts as far from digital/clock as possible.
- **Thermal Considerations:** Heatsinks, airflow, keep hot parts away from heat-sensitive analog.
- **Height and Clearance:** Observe max height for case, keep tall parts away from connectors.
- **Mechanical:** Mounting holes, standoffs, and keep-out zones for screws and assembly.

#### 28.7.2.1 Iterative Placement

- Place, simulate, check for bottlenecks, move as needed.
- Print 1:1 for physical fit check before routing.

### 28.7.3 Trace Routing: Manual, Autoroute, and Best Practice

- **Manual Routing:** Control over critical nets (audio, clock, high-speed).
- **Autorouter:** Use for bulk digital signals, never for sensitive analog.
- **Width and Clearance:** Use wider traces for power, minimum for signal.
- **Avoid 90° Corners:** Use 45° or curved bends to reduce impedance discontinuities.
- **Shortest Path:** For analog and clock, keep as direct as possible.

#### 28.7.3.1 Example: Audio Path Routing

- Route left/right audio as parallel, spaced pairs, away from digital buses.
- Differential signals (balanced): Match trace length to within 0.5mm.

### 28.7.4 Layer Stackup Optimization and High-Speed Design

- **Signal Layers:** Top/bottom; for high-speed, use buried layers for critical nets.
- **Power/Ground Planes:** Always adjacent to signal layers where possible.
- **Microstrip/Stripline:** For controlled impedance in USB, Ethernet, DDR.
- **Reference Planes:** Every signal layer should reference an uninterrupted ground or power plane.

#### 28.7.4.1 Typical 4-Layer Stackup (Top to Bottom)

1. Signal (components, critical analog)
2. Ground plane (reference for analog, digital)
3. Power plane (split analog/digital if required)
4. Signal (digital, less-critical analog)

### 28.7.5 Placement of Decoupling, Filtering, and Power Distribution

- **Decoupling Caps:** Place 100nF cap directly at every IC Vcc pin; bulk 10uF near power entry.
- **Ferrite Beads:** Isolate analog and digital power; use as needed on supply lines.
- **Bulk Caps:** Near power entry, for surge and brownout protection.
- **Filters:** Pi or LC filters on supply rails for ultra-low noise analog power.

#### 28.7.5.1 Example: Decoupling Plan for MCU

- 100nF per Vcc, 10uF per supply, all as close as possible to pin.

### 28.7.6 Grounding and Shielding: Analog, Digital, Mixed

- **Single Point Ground:** Connect analog and digital grounds at one point only (usually near ADC/DAC).
- **Guard Traces:** Grounded traces between analog and digital signals.
- **Chassis Ground:** Connect to enclosure at one point; use safety earth for AC-powered gear.
- **Shield Cans:** Metal cans over critical analog sections; soldered or clipped to ground.

### 28.7.7 Panelization, Fiducials, and Mechanical Integration

- **Panelization:** Multiple boards per panel for efficient assembly; add breakaway tabs.
- **Fiducials:** Reference marks for pick-and-place machines.
- **Tooling Holes:** For alignment during assembly/test.
- **Mechanical Drawings:** DXF/SVG overlays for case, connector, and mounting alignment.

---

## 28.8 EMI/ESD Mitigation and EMC Compliance

### 28.8.1 Sources of EMI in Audio Workstations

- **High-Frequency Digital:** CPU, USB, DDR, switching power supplies.
- **Clock Lines:** Especially master clock, crystal oscillators.
- **Cables and Connectors:** Act as antennas, radiate or pick up EMI.
- **Ground Loops:** Cause hum, especially in analog audio.

### 28.8.2 Layout Strategies for EMI Reduction

- **Short Traces:** Shorter traces radiate less.
- **Minimize Loops:** Route returns close to signals.
- **Flood Fill:** Unused areas filled with ground plane to absorb EMI.
- **Stitching Vias:** Connect all ground planes together at regular intervals.
- **Keep High-Speed Traces Away from Analog:** Maintain at least 3–5mm separation.

### 28.8.3 ESD Protection Techniques: Board-Level and System

- **TVS Diodes:** On all external connectors; clamp fast voltage spikes.
- **Series Resistors:** Small (10–100Ω) in series with data lines to reduce ESD current.
- **Ferrite Beads:** On power and signal lines for high-frequency suppression.
- **Connector Shielding:** Connect shield to ground at entry point.

#### 28.8.3.1 ESD Protection Schematic for USB

```
[USB D+]---[R1]---+---[MCU]
                 |
               [TVS]
                 |
                GND
```

### 28.8.4 Shielding: Cans, Coatings, and Chassis Ground

- **Metal Cans:** Over analog or RF sections; soldered for best performance.
- **Conductive Coating:** Spray inside plastic enclosures for EMI absorption.
- **Chassis Ground:** Connect shields to case at single point.

### 28.8.5 EMC Pre-Compliance: Measurement and Remediation

- **EMC Test Chamber:** In-house or external; measure radiated/conducted emissions.
- **Near-Field Probes:** Detect EMI “hot spots” on board.
- **Remediation:** Add caps, ferrites, shielding, or reroute traces as needed.
- **Iterate:** Test, fix, retest—never assume first layout will pass.

---

## 28.9 Audio Signal Path Optimization

### 28.9.1 Input/Output Stages: Balanced, Unbalanced, Differential Routing

- **Balanced Audio:** Uses two signal wires plus ground; cancels common-mode noise.
- **Differential Routing:** Traces run as matched pairs; length-matched within 1–2mm.
- **Unbalanced:** Simpler, more susceptible to noise/hum; use for short internal runs only.
- **Impedance Matching:** Prevents reflections and signal loss.

#### 28.9.1.1 Example: Balanced Audio Stage

- Input: XLR or TRS → Differential Op-Amp → ADC
- Output: DAC → Differential Driver → XLR/TRS

### 28.9.2 Ground Loops, Hum, and Isolation

- **Ground Loops:** Caused by multiple ground paths; break with isolation transformers or “lift” switches.
- **Optical Isolation:** For MIDI, digital control lines.
- **Star Ground:** All grounds meet at single point.

### 28.9.3 Analog Filtering, Anti-Aliasing, and Protection

- **Anti-Aliasing Filter:** Low-pass filter before ADC (e.g., 48kHz sample, cutoff ~20kHz).
- **DC Blocking:** Capacitors on input to remove DC offset.
- **Input Protection:** Clamp diodes, series resistors, ESD TVS.

### 28.9.4 Minimize Crosstalk and Channel Bleed

- **Trace Separation:** At least 2–3x trace width between audio traces.
- **Shielding:** Guard traces, ground pours between channels.
- **Orthogonal Routing:** Run left/right at 90° to each other where possible.

### 28.9.5 Using Relays, Soft-Start, and Muting Circuits

- **Relay Bypass:** Physically disconnect input/output for true “hard bypass.”
- **Soft-Start:** Prevent “pop” on power-on by ramping audio path with FETs or relays.
- **Muting:** Mute output during startup, reset, or error; use MOSFETs or relay mute.

---

## 28.10 Connectors and Panel Design

### 28.10.1 Mechanical Considerations: Placement, Strength, Accessibility

- **Board Edge:** Place connectors for easy access and shortest internal cable runs.
- **Reinforcement:** Use through-hole, metal-shielded connectors and anchor to panel.
- **Accessibility:** Leave room for fingers, cable strain relief, and locking mechanisms.

### 28.10.2 Connector Types: Audio, MIDI, USB, Power, Network, Expansion

- **Audio:** Neutrik XLR/TRS, Amphenol, Switchcraft—choose for durability.
- **MIDI:** Standard 5-pin DIN, TRS, or USB-C for modern controllers.
- **USB:** Type B for devices, Type A/C for hosts; ESD protection required.
- **Network:** Shielded RJ-45, with LEDs for link/activity indication.
- **Power:** Locking barrel, XLR, Molex, or screw-terminal for high-current.
- **Expansion:** Edge-card, PCIe, or custom keyed headers.

### 28.10.3 Strain Relief, Locking, and Cable Management

- **Strain Relief:** Prevents force on board; use tie-downs, clamps, or molded connectors.
- **Locking Connectors:** Prevent accidental unplugging; use latches or thumbscrews.
- **Cable Routing:** Keep internal cables short, avoid running over/under sensitive analog.

### 28.10.4 Panel Cutouts, Silkscreen, and Labeling

- **Precision Cutouts:** CNC, punch, or laser for tight tolerances.
- **Silkscreen:** Clear, high-contrast labels for every connector.
- **Standard Icons:** Use MIDI, USB, headphone, and power symbols for clarity.

### 28.10.5 Integration with Enclosure: Tolerances and Assembly

- **Tolerances:** Allow extra 0.5–1mm for manufacturing variation.
- **Assembly:** Ensure connectors align with panel; use jigs for repeatability.
- **Serviceability:** Connectors should be replaceable from front/rear panel without full disassembly.

---

## 28.11 Compliance, DFM, and Documentation

### 28.11.1 Regulatory Compliance: CE, FCC, RoHS, REACH, WEEE

- **CE (Europe):** EMC, safety, RoHS, LVD directives.
- **FCC (USA):** Part 15B/C—EMC for digital devices, intentional radiators.
- **RoHS:** Restricts hazardous substances (Pb, Cd, Hg, etc.).
- **REACH:** Chemical safety, SVHC declarations.
- **WEEE:** Waste Electrical and Electronic Equipment—recycling.

#### 28.11.1.1 Compliance Steps

1. Design to spec (EMC, safety, RoHS).
2. Pre-compliance test in lab.
3. Submit to certified test house.
4. Keep all test reports and Declarations of Conformity.

### 28.11.2 Design for Manufacturability (DFM)

- **Standard Footprints:** Use IPC-compliant pads and spacing.
- **Component Sourcing:** Avoid exotic or obsolete parts.
- **Assembly Aids:** Silkscreen outlines, pin 1 indicators, polarity marks.
- **Panelization:** Use standard board sizes, v-scoring, or breakaway tabs.
- **BOM Optimization:** Reduce component count for lower cost, higher reliability.

### 28.11.3 Design for Test (DFT) and Service (DFS)

- **Test Points:** Expose all key nets, power rails, and buses.
- **Boundary Scan/JTAG:** For automated test and programming.
- **In-Circuit Test (ICT):** Pads for “bed of nails” testers.
- **Service Access:** Removable panels, socketed components, labeled jumpers.

### 28.11.4 Board Files, Assembly Drawings, and Change Control

- **Gerber/X2 Files:** Standard for PCB fab; include all layers and drill data.
- **Pick-and-Place Files:** For assembly robots—reference designators, XY, rotation.
- **Assembly Drawings:** Show component side, orientation, and notes for human/robot assemblers.
- **Revision Control:** Use Git or PDM for all design files; track changes with ECO (Engineering Change Order) process.

### 28.11.5 BOM, Procurement, and Component Sourcing

- **BOM (Bill of Materials):** List part number, description, footprint, supplier, and alternates.
- **Approved Vendors:** Use reliable, authorized distributors (Mouser, Digi-Key, Arrow, Avnet).
- **Lifecycle Management:** Track end-of-life (EOL), last time buy, and replacements.
- **Supply Chain Risk:** Dual-source critical parts, plan for shortages.

---

## 28.12 Real-World Example: Workstation Audio Mainboard Layout Walkthrough

### 28.12.1 Schematic Review

- Power: 12V DC in → buck regulator → 3.3V digital, 5V analog rails.
- CPU: STM32H7, placed center for shortest trace to RAM, SD card, CODEC.
- Audio: WM8731 CODEC, analog section isolated, short traces to input/output.

### 28.12.2 Placement and Partitioning

- TRS and XLR audio connectors at rear; USB, MIDI, network at side.
- Analog circuits (preamp, filter) in upper left, digital in lower right.
- Shield can over CODEC and preamp; separate ground returns.

### 28.12.3 Decoupling and Power

- 0.1uF MLCC at every Vcc, 10uF at supply entry, ferrite bead to analog.
- Star ground at single point near CODEC.

### 28.12.4 Routing

- Audio traces on top, shortest path, wide separation from digital.
- USB and Ethernet as matched impedance pairs, minimum stubs.
- All signals reference solid ground plane underneath.

### 28.12.5 EMC and ESD

- TVS diodes on every external connector.
- Shield can soldered to ground plane, chassis ground at single point.

### 28.12.6 Panel and Assembly

- Panel silkscreen with all connector labels, icons, and safety marks.
- All connectors reinforced to panel; all cables short and tied.

### 28.12.7 DFM and Compliance

- Test points on all rails, programming header, JTAG.
- BOM with alternates, compliance certificates on file.

---

## 28.13 Glossary and Reference Tables

| Term        | Definition                                           |
|-------------|------------------------------------------------------|
| DFM         | Design for Manufacturability                         |
| DFT         | Design for Test                                      |
| DFS         | Design for Service                                   |
| BOM         | Bill of Materials                                    |
| EMC         | Electromagnetic Compatibility                        |
| ESD         | Electrostatic Discharge                              |
| Pre-compliance | Lab testing before official compliance            |
| X2 Gerber   | Extended Gerber format for PCB fab                   |
| Fiducial    | Printed mark for machine vision alignment            |
| Panelization| Multiple boards per panel for fab/assembly           |

### 28.13.1 Table: EMI/ESD Checklist

| Task                        | Required For         | Notes                          |
|-----------------------------|---------------------|--------------------------------|
| TVS on all IO               | ESD                 | Fast clamp diodes              |
| Grounded shield can         | EMI                 | Over analog/digital junction   |
| Stitching vias              | EMI                 | Every 1–2cm on ground planes   |
| Short, direct clock traces  | EMI                 | Minimize radiation             |
| Star ground                 | Hum, loops          | One-point return               |

### 28.13.2 Typical Regulatory Test List

| Standard | Test Type           | Sample Limit | Pass Criteria                 |
|----------|---------------------|--------------|-------------------------------|
| CE       | EMC, Safety         | 1 production | Emissions, immunity, LVD      |
| FCC B    | EMC                 | 3-5 units    | Radiated, conducted emission  |
| RoHS     | Hazardous material  | BOM check    | All parts compliant           |
| WEEE     | Recycling           | N/A          | Marking, documentation        |

### 28.13.3 Best Practices Checklist

- [ ] Place all IO at board edge, reinforce with panel
- [ ] Separate analog/digital, shield as needed
- [ ] Use TVS, ferrite, and caps on all external lines
- [ ] Use star ground, avoid loops, provide test points
- [ ] Panelize for fab, include fiducials and tooling holes
- [ ] Keep all documentation and compliance records up to date

---

**End of Part 2 and Chapter 28: Hardware Design – Boards, Connectors, Power.**

**You now have an in-depth, industry-level reference for layout, EMI/ESD, audio signal integrity, connector/panel design, compliance, manufacturability, and real-world implementation.  
To proceed to Manufacturing and Assembly, or for deeper dive into any layout or design topic, just ask!**