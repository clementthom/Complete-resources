# Workstation Synth Project – Document 22  
## Power Supply and Safety

---

### Table of Contents

1. Basics of Power for Synths and Embedded Systems
2. Choosing the Right Power Source
3. Voltage Regulation: Linear vs. Switching
4. Supplying Multiple Voltages (3.3V, 5V, ±12V)
5. Fusing, Polarity, and Short Circuit Protection
6. Power Distribution: Wires, Traces, and Connectors
7. Common Power Problems and How to Debug
8. Safety Tips for Lab and Field Use
9. Hands-On: Build and Test a Modular Power Supply
10. Exercises

---

## 1. Basics of Power

- Most digital: 3.3V or 5V (Pi, MCU, logic)
- Most analog: ±12V or ±15V (VCAs, op-amps)
- Wall adapters, USB, or batteries for input

---

## 2. Choosing a Power Source

- **Wall wart:** Easiest, choose regulated and center-positive
- **USB:** For Pi and some displays, limited current
- **Bench supply:** For testing and development

---

## 3. Voltage Regulation

- **Linear (7805, LM317):** Simple, low noise, less efficient
- **Switching (buck/boost):** Efficient, may need extra filtering for analog

---

## 4. Supplying Multiple Voltages

- Use DC-DC converters for ±12V from a single supply
- Split rail circuit for ground reference

---

## 5. Fusing and Protection

- Inline fuse on main input (fast-blow 0.5–1A typical)
- Diode for polarity protection
- TVS diodes for surge

---

## 6. Power Distribution

- Use thick wires for high current
- Star grounding for analog circuits
- Screw terminals or Molex for modularity

---

## 7. Debugging Power Problems

- Use a multimeter to check voltage at all boards
- Check connector seating and wire order
- Look for heat, smell, or visual cues

---

## 8. Safety Tips

- Never touch live wires or exposed mains
- Double check polarity before plugging in
- Use one hand (other in pocket) when probing

---

## 9. Hands-On

- Build a ±12V supply using modules or ICs
- Add a fuse and polarity diode

---

## 10. Exercises

- Measure voltage under full load (everything plugged in)
- Calculate power draw of your full workstation
- Add a power LED and label all voltages

---

**Next:**  
*workstation_23_enclosure_assembly_and_wiring.md* — Building and wiring up your workstation.

---