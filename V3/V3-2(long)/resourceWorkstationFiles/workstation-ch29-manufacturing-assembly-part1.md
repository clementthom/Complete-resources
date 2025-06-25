# Chapter 29: Manufacturing and Assembly  
## Part 1: Manufacturing Theory, PCB Fabrication, and Sourcing

---

## Table of Contents

- 29.1 Introduction: The Stakes and Challenges of Manufacturing
- 29.2 Manufacturing Strategy and Planning
  - 29.2.1 Prototyping vs. Production Manufacturing
  - 29.2.2 In-House vs. Outsourced Manufacturing
  - 29.2.3 Cost Analysis: NRE, BOM, Labor, Overhead
  - 29.2.4 Minimum Order Quantities and Scaling
- 29.3 PCB Fabrication: Processes and Quality Control
  - 29.3.1 PCB Fabrication Flow: Step-by-Step
  - 29.3.2 Stackup, Vias, and Material Choices
  - 29.3.3 DFM Rules for PCB
  - 29.3.4 Surface Finishes: HASL, ENIG, OSP, Immersion Silver/Gold
  - 29.3.5 Soldermask, Silkscreen, and Markings
  - 29.3.6 Panelization, Scoring, and Depanelization
  - 29.3.7 PCB Quality Control and Test Coupons
- 29.4 Sourcing: Components, Vendors, and Logistics
  - 29.4.1 BOM Management and Approved Vendor List
  - 29.4.2 Procuring Common, Custom, and Long-Lead Parts
  - 29.4.3 Counterfeit Avoidance and Traceability
  - 29.4.4 Logistics: Shipping, Warehousing, and Lead Times
  - 29.4.5 International Sourcing: Tariffs, Customs, and Documentation
- 29.5 Glossary and Reference Tables

---

## 29.1 Introduction: The Stakes and Challenges of Manufacturing

Manufacturing bridges design and the real world. A perfect schematic is worthless if it cannot be built reliably, affordably, and at scale.  
Manufacturing and assembly transform your workstation from prototype to product, but introduce:

- New risks: defects, delays, shortages, and unforeseen costs
- Quality demands: every board must meet spec, not just the first
- Compliance: regulatory, safety, and environmental standards must be met
- Logistics: supply chains, shipping, and storage can make or break a launch

Success in manufacturing is as much about planning, process, and partnerships as it is about technology.

---

## 29.2 Manufacturing Strategy and Planning

### 29.2.1 Prototyping vs. Production Manufacturing

- **Prototyping:** Small runs (1–10 units), manual assembly, quick-turn PCB, possible 3D-printed or CNC-milled enclosures.
  - Fast iteration, higher per-unit cost, relaxed DFM rules.
- **Production:** 100s–1000s+ units, automated SMT assembly, strict DFM, dedicated tooling, and jigs.
  - Lower per-unit cost at scale, higher up-front cost (NRE—Non-Recurring Engineering).

#### 29.2.1.1 Prototyping Steps

1. Order small-quantity PCBs from quick-turn fab (JLCPCB, PCBWay, OSH Park).
2. Hand-solder or use reflow oven/hot plate for SMT parts.
3. Validate with debug headers, test points, and easy access to all nets.
4. Iterate hardware and firmware rapidly.

#### 29.2.1.2 Production Steps

1. Lock BOM and design files.
2. Order PCBs in panelized form.
3. Ship parts to assembly house (or buy turn-key).
4. Use automated pick-and-place, reflow, AOI, and functional test.
5. Prepare for compliance and mass testing.

### 29.2.2 In-House vs. Outsourced Manufacturing

- **In-House:** Full control, fast iteration, limited by equipment and expertise.
  - Suitable for small startups, R&D, or high-mix/low-volume.
- **Outsourced (CM):** Contract Manufacturer handles assembly, test, and sometimes procurement.
  - Suitable for scaling, cost efficiency, and access to advanced processes.
- **Hybrid:** In-house for prototype, CM for production; maintain ability to build small runs yourself.

#### 29.2.2.1 Table: Manufacturing Models

| Model         | Control | Cost | Flexibility | Speed to Scale | Risk |
|---------------|--------|------|-------------|---------------|------|
| In-House      | High   | High | Very High   | Low           | High |
| Outsourced CM | Low    | Low  | Medium      | High          | Low  |
| Hybrid        | Med    | Med  | High        | Med           | Med  |

### 29.2.3 Cost Analysis: NRE, BOM, Labor, Overhead

- **NRE (Non-Recurring Engineering):** Tooling, programming, assembly setup, test fixtures.
- **BOM (Bill of Materials):** All components, PCB, connectors, enclosures, with price breaks for volume.
- **Labor:** Assembly, test, rework—varies by geography, automation, and complexity.
- **Overhead:** Shipping, storage, scrap, rework, quality assurance.
- **Yield:** Account for board failures, rework, and scrap (~1–5% typical loss).

#### 29.2.3.1 Example Cost Breakdown for 1000 Units

| Item           | Cost/Unit | Qty   | Total    |
|----------------|-----------|-------|----------|
| PCB            | $8.00     | 1000  | $8,000   |
| Assembly       | $7.00     | 1000  | $7,000   |
| BOM (parts)    | $30.00    | 1000  | $30,000  |
| Enclosure      | $15.00    | 1000  | $15,000  |
| Test/QA        | $2.00     | 1000  | $2,000   |
| NRE (divided)  | $5.00     | 1000  | $5,000   |
| Shipping/Log.  | $2.50     | 1000  | $2,500   |
| TOTAL          | $69.50    | 1000  | $69,500  |

### 29.2.4 Minimum Order Quantities and Scaling

- **MOQ (Minimum Order Quantity):** Many CMs and fab houses require 50, 100, or 500+ units per run for cost efficiency.
- **Scaling:** Unit cost drops as quantity increases, but NRE and inventory risk rise.
- **Flexible Scaling:** Start with small runs (pilot), ramp to mass production after QA and market validation.

#### 29.2.4.1 Example: Price Break Table

| Qty | PCB Cost/Unit | Assembly Cost/Unit | BOM Cost/Unit | Total/Unit |
|-----|---------------|--------------------|---------------|------------|
| 10  | $30           | $20                | $45           | $95        |
| 100 | $10           | $8                 | $35           | $53        |
| 1000| $8            | $7                 | $30           | $45        |

---

## 29.3 PCB Fabrication: Processes and Quality Control

### 29.3.1 PCB Fabrication Flow: Step-by-Step

1. **DFM Check:** Review Gerber, BOM, and stackup for manufacturing rules.
2. **Panelization:** Arrange multiple boards per panel, add fiducials, tooling holes, test coupons.
3. **Imaging:** Photoresist applied, UV-exposed for copper trace patterning.
4. **Etching:** Remove unwanted copper; define traces and pads.
5. **Drilling:** CNC drills for vias, holes for through-hole parts.
6. **Plating:** Copper applied in holes (via barrels) and on surface.
7. **Soldermask:** Green/blue/black resist applied to define solderable areas.
8. **Silkscreen:** Text, labels, and markings printed on board.
9. **Surface Finish:** ENIG, HASL, OSP, etc. for pad protection and solderability.
10. **V-Scoring/Depanelization:** Pre-score or route for easy board separation post-assembly.
11. **Electrical Test:** Flying probe or bed-of-nails test to verify connectivity.
12. **Final Inspection:** Visual, AOI (automatic optical inspection), and sometimes X-ray for BGA.

#### 29.3.1.1 DFM (Design for Manufacture) Check

- Minimum trace width/spacing (e.g., 6/6mil)
- Drill size, aspect ratio
- Annular ring
- Silkscreen over pads
- Soldermask clearance

### 29.3.2 Stackup, Vias, and Material Choices

- **Stackup:** Defines layer order, thickness, copper weight.
  - Typical: Signal / Ground / Power / Signal (4-layer)
- **Vias:** Plated through-hole (PTH), blind/buried (for high-density), microvias (laser-drilled).
- **Material:** Almost always FR-4 for audio, but high-Tg for lead-free or high-temp.
- **Copper Weight:** 1oz (35μm) standard; 2oz for high-current.

#### 29.3.2.1 Via Cost/Complexity Table

| Via Type   | Cost   | Complexity | Use Case                 |
|------------|--------|------------|--------------------------|
| PTH        | Low    | Simple     | Most boards              |
| Blind      | Med    | Med        | Dense, high speed        |
| Buried     | High   | High       | Complex, multi-layer     |
| Microvia   | High   | High       | HDI, BGA, fine pitch     |

### 29.3.3 DFM Rules for PCB

- **Trace/space:** Minimum width/spacing per fab (6/6mil typical for 2-layer, 4/4mil for 4-layer).
- **Pad size:** Sufficient for part and soldering process (IPC-7351).
- **Thermal reliefs:** On pads to make hand/smt soldering easier.
- **Fiducials:** Required for automated assembly.
- **No soldermask over pads:** Prevents poor solder joints.

### 29.3.4 Surface Finishes: HASL, ENIG, OSP, Immersion Silver/Gold

- **HASL (Hot Air Solder Level):** Cost-effective, good for hand solder, not flat (bad for BGA).
- **ENIG (Electroless Nickel Immersion Gold):** Flat, excellent for SMT/BGA, more expensive, longer shelf life.
- **OSP (Organic Solderability Preservative):** Cheap, eco-friendly, short shelf life.
- **Immersion Silver/Gold:** High-end, best for fine-pitch, BGA, or RF.

#### 29.3.4.1 Surface Finish Table

| Finish | Cost | Shelf Life | SMT/BGA | Hand Solder | Notes            |
|--------|------|------------|---------|-------------|------------------|
| HASL   | Low  | Long       | No      | Yes         | Most common      |
| ENIG   | Med  | Long       | Yes     | Yes         | Pro audio/SMT    |
| OSP    | Low  | Short      | Yes     | No          | Eco, low cost    |
| Silver | High | Med        | Yes     | Yes         | Best for RF      |

### 29.3.5 Soldermask, Silkscreen, and Markings

- **Soldermask:** Prevents solder bridges, defines pad area, protects copper.
- **Colors:** Green standard; black/blue/red for aesthetics; white/yellow for silkscreen contrast.
- **Silkscreen:** Place all refdes, pin 1, polarity, test points, and key signal names.
- **Markings:** Date code, revision, fab house marks, RoHS/CE/FCC.

### 29.3.6 Panelization, Scoring, and Depanelization

- **Panelization:** Boards arranged for efficient pick-and-place, reflow, test.
- **V-Scoring:** Shallow cut for snapping boards apart.
- **Tab Routing:** Bridges with “mouse bites” for separation.
- **Depanelization:** Manual (snap), router, or laser.

### 29.3.7 PCB Quality Control and Test Coupons

- **Test Coupons:** Extra sections at panel edge to test via quality, plating, and trace width.
- **Electrical Test:** 100% netlist test for shorts/opens.
- **AOI/X-ray:** Finds solder, BGA, or internal defects.
- **Defect Logging:** All defects tracked, scrap/rework rates recorded.

---

## 29.4 Sourcing: Components, Vendors, and Logistics

### 29.4.1 BOM Management and Approved Vendor List

- **BOM:** Master list of every component, value, footprint, and approved vendor part number.
- **AVL (Approved Vendor List):** At least two vendors per part where possible.
- **BOM Tools:** Excel, Altium, Arena, Component Search Engine.
- **Lifecycle Status:** Avoid NRND (not recommended for new design), EOL, or single-source parts.

### 29.4.2 Procuring Common, Custom, and Long-Lead Parts

- **Common:** Resistors, caps, generic ICs—buy in reels for price breaks.
- **Custom:** Displays, enclosures, key switches—work with vendor for specs, lead time, and minimums.
- **Long-Lead:** FPGAs, DSPs, specialty ICs—order early, monitor allocation, use alternates if possible.
- **Buy Ahead:** For parts with >12 week lead time, purchase at design freeze.

### 29.4.3 Counterfeit Avoidance and Traceability

- **Authorized Distribution:** Buy only from trusted sources (Digi-Key, Mouser, Arrow).
- **Traceability:** Lot code, date code on every reel/tray/bag.
- **Incoming QC:** Visual inspection, X-ray, functional test for high-value ICs.
- **Marking:** Laser, barcode, or RFID on custom/mechanical parts for tracking.

### 29.4.4 Logistics: Shipping, Warehousing, and Lead Times

- **Shipping:** Plan for delays, customs, and climate; use tracked/insured for valuable parts.
- **Warehousing:** Store dry, cool, and ESD-safe; moisture-sensitive parts (MSL) require controlled humidity.
- **Lead Time:** Aggregate all long-lead items; plan builds accordingly.
- **Buffer Stock:** Keep reserve for rework, warranty, and field service.

### 29.4.5 International Sourcing: Tariffs, Customs, and Documentation

- **Tariffs:** Plan costs for import/export duties (especially US, EU, China).
- **Customs Documentation:** Commercial invoice, country of origin, HS code, RoHS/CE/FCC certs.
- **Shipping Terms:** EXW, FOB, DDP—know who pays for what.
- **ITAR/EAR:** Export control for encryption, RF, or critical components.

---

## 29.5 Glossary and Reference Tables

| Term         | Definition                                         |
|--------------|----------------------------------------------------|
| NRE          | Non-Recurring Engineering cost                     |
| BOM          | Bill of Materials                                 |
| AVL          | Approved Vendor List                               |
| DFM          | Design for Manufacturability                       |
| MSL          | Moisture Sensitivity Level (for ICs)               |
| AOI          | Automated Optical Inspection                       |
| ENIG         | Electroless Nickel Immersion Gold surface finish   |
| HASL         | Hot Air Solder Leveling                            |
| Test Coupon  | PCB edge section for process verification          |
| Panelization | Multiple boards per panel for efficient assembly   |

### 29.5.1 Table: PCB Minimum Spec Matrix

| Spec                | Typical Value     | Notes                       |
|---------------------|------------------|-----------------------------|
| Min trace/space     | 6/6 mil (0.15mm) | Lower possible at extra cost|
| Min drill           | 0.3mm            | For vias                    |
| Copper weight       | 1oz/ft²          | 2oz for high-current        |
| Max panel size      | 450x600mm        | Varies by fab               |
| Soldermask color    | Green            | Others available            |

### 29.5.2 Table: Common Component Lead Times

| Component      | Typical Lead Time | Notes                        |
|----------------|------------------|------------------------------|
| Resistors/caps | 2–4 weeks        | Buy in reels                 |
| MCUs/DSPs      | 8–24 weeks       | Buy ahead, check allocation  |
| FPGAs          | 12–52+ weeks     | Watch for shortages          |
| Custom LCD/OLED| 6–16 weeks       | Confirm at design freeze     |
| Enclosures     | 4–12 weeks       | Tooling may add weeks        |

### 29.5.3 Best Practices Checklist

- [ ] Always do DFM/DFT review before sending to fab
- [ ] Dual-source every component possible
- [ ] Track part status, date/lot codes, and shelf life
- [ ] Maintain 5–10% overage for all parts in build
- [ ] Archive all fab/assembly/test docs and logs
- [ ] Plan builds around longest lead-time items

---

**End of Part 1.**  
**Next: Part 2 will cover assembly processes (SMT, THT, reflow, hand assembly), inspection, rework, system-level assembly, burn-in, box build, packaging, and shipping.**

---