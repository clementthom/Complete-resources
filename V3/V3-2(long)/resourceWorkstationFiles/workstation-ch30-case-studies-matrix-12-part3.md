# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 3: Voice-Level Analog Control, Calibration, Diagnostics, Modular Patching, and Service Procedures

---

## Table of Contents

- 30.74 Voice-Level Analog Control and Signal Calibration
  - 30.74.1 Per-Voice Calibration: VCO, VCF, VCA, Pan, and Pitch
  - 30.74.2 Hardware Trimmers, Test Points, and Auto-Calibration Routines
  - 30.74.3 Voice Card Failure Detection, Auto-Muting, and Fault Isolation
- 30.75 Service and Diagnostic Firmware Features
  - 30.75.1 Service Mode Entry, Board Presence, and Status Reporting
  - 30.75.2 Diagnostic Test Patterns, Measurement, and Reporting
  - 30.75.3 Real-World Troubleshooting and User-Accessible Service
- 30.76 Modular Patching with the Matrix-12: Practical Examples
  - 30.76.1 CV Routing: Mod Source to Destination, Polyphonic Flexibility
  - 30.76.2 Building Classic Modular Patches with the Matrix
  - 30.76.3 Advanced Techniques: Feedback, Audio-Rate Modulation, and Nonlinear Routing
- 30.77 Annotated Signal Flows: From Key Press to Output
  - 30.77.1 Full Signal Path (Block and Schematic-Level)
  - 30.77.2 Voice Card Audio and CV Timing Diagrams
  - 30.77.3 Matrix Update, DAC Settling, and Modulation Slew
- 30.78 Example C Code: Calibration, Diagnostics, and Patch Logic
  - 30.78.1 Calibration Routines (VCO Tuning, VCF Tracking, VCA Gain)
  - 30.78.2 Fault Detection, Voice Masking, and Reporting
  - 30.78.3 Patch Logic for Modular Routing and Polyphony Management
  - 30.78.4 Service Mode Menu and Display Flow
- 30.79 Best-Practices for Modern Recreation, Calibration, and Maintenance
- 30.80 Glossary, Reference Tables, and Service Data

---

## 30.74 Voice-Level Analog Control and Signal Calibration

### 30.74.1 Per-Voice Calibration: VCO, VCF, VCA, Pan, and Pitch

- **VCO Calibration**: Each CEM3340 requires adjustment for scale (1V/oct) and offset (tune). Trimmers (VR1, VR2) on each voice card.
  - **Procedure**: CPU enters calibration mode, outputs known CVs for 0V, 5V, 8V; reads frequency via testpoint or counter. Adjust trimmers until frequencies match reference.
  - **Digital Correction**: Calibration table in RAM (per voice) for fine correction via DAC offset.
- **VCF Calibration**: CEM3372 cutoff/scale, resonance center, and Q. Trimmers (VR3, VR4) for scaling and resonance symmetry.
  - **Procedure**: Sweep cutoff CV, check filter tracking/linearity, adjust for even response and correct resonance at key points.
- **VCA/Pan Calibration**: CEM3360 gain symmetry. Trimmers (VR5, VR6) on each card; CPU outputs reference level, service measures output, adjusts for unity gain and pan center.
- **Pitch/Glide**: Portamento circuit is analog integrator; timing capacitor can be trimmed for precise glide times.

### 30.74.2 Hardware Trimmers, Test Points, and Auto-Calibration Routines

- **Trimmers**: Multi-turn potentiometers, high-reliability. Labeled on silkscreen, easily accessible with chassis open.
- **Test Points**: Gold-plated pads for scope/meter probes. Typical: VCO out, VCF out, VCA out, pan sum, CV lines, DAC output, reference voltages.
- **Auto-Calibration**:
  - CPU initiates calibration sweep, measures result (frequency, output level) via ADC or frequency counter logic.
  - Correction table updated in RAM, applied to DAC outputs for each voice.
  - User can initiate from panel service menu.

#### 30.74.2.1 Example: Auto-Cal C Routine Skeleton

```c
void calibrate_vco(int voice) {
    for (int cv = 0; cv < 8; ++cv) {
        set_dac(voice, VCO_PITCH, cv_table[cv]);
        wait_settle();
        freq[cv] = measure_frequency(voice);
    }
    calc_and_store_scale_offset(voice, freq);
}
```

### 30.74.3 Voice Card Failure Detection, Auto-Muting, and Fault Isolation

- **Startup**: CPU polls each card for presence (busy/OK line) and self-test status.
- **Run-Time**: Monitors voice for stuck/bad output (e.g. VCO not oscillating, VCA stuck open/closed, filter not tracking).
- **Fault Response**:
  - Faulty voice isolated (auto-mute), error reported on panel and testpoint.
  - Remaining voices reallocated for polyphony (11-voice, 10-voice, etc.).
- **User Diagnostics**: Service menu displays voice status; can solo/mute/test each card.

---

## 30.75 Service and Diagnostic Firmware Features

### 30.75.1 Service Mode Entry, Board Presence, and Status Reporting

- **Entry**: Hold specific panel buttons at boot, or via secret menu.
- **Board Presence**: CPU queries each slot for card signature, disables empty or failed slots.
- **Status Report**: Panel displays overall health: voice map, trimmer status, battery, patch RAM, DAC/mux self-test, panel/keyboard OK.

### 30.75.2 Diagnostic Test Patterns, Measurement, and Reporting

- **Voice Test**: CPU cycles each voice through test patterns: VCO square/tri/saw, filter sweep, VCA gain, pan center.
- **Measurement**: User observes output at testpoint or via panel meter display. For modern recreation, readings can be digitized to automate.
- **Reporting**: Error states (e.g. "Voice 7 VCO Fail", "VCF Offset Bad") shown on LCD and via MIDI sysex for remote diagnostics.

### 30.75.3 Real-World Troubleshooting and User-Accessible Service

- **Live Diagnostics**: Panel can solo/mute/test any voice; useful for tracking down intermittent faults.
- **Patch Compare**: Service menu allows user to compare current patch to factory defaults, highlight parameter drift.
- **Backup/Restore**: Full backup via MIDI sysex, restore after board replacement or battery loss.

---

## 30.76 Modular Patching with the Matrix-12: Practical Examples

### 30.76.1 CV Routing: Mod Source to Destination, Polyphonic Flexibility

- **Example 1: Aftertouch to Filter Cutoff**
  - Matrix route: Source=Aftertouch, Dest=VCF Cutoff, Depth=+64, Curve=Linear.
  - Per-voice: Each voice gets its own aftertouch value (channel pressure mapped through split/layer logic).
- **Example 2: LFO to VCO Pitch**
  - Matrix route: Source=LFO1, Dest=VCO1 Pitch, Depth=+32, Curve=Triangle.
  - Updates per voice, allows polyphonic vibrato; LFO phase can be per-voice or global.
- **Example 3: Velocity to VCA**
  - Matrix route: Source=Velocity, Dest=VCA, Depth=+80, Curve=Exp.
  - Key velocity sets amplitude, with exponential sensitivity.

### 30.76.2 Building Classic Modular Patches with the Matrix

- **Ring Modulation**: Route VCO2 output to VCO1 FM input via matrix; set depth for subtle to extreme metallic tones.
- **Self-Oscillating Filter**: Set VCF resonance to max, route ENV to filter cutoff for percussive effects.
- **Audio-Rate Modulation**: Assign VCO2 as mod source for VCF or PWM; matrix supports up to audio-rate CV updates for certain destinations.
- **Complex Envelopes**: Stack multiple ENV/LFO mod sources to a single destination with different curves/depths for evolving modulation.

### 30.76.3 Advanced Techniques: Feedback, Audio-Rate Modulation, and Nonlinear Routing

- **Feedback**: Patch VCF output as a mod source to VCO pitch or filter cutoff for chaotic effects.
- **Audio-Rate LFO**: Set LFO max speed, route to VCO PWM or filter for FM-like sounds.
- **Nonlinear Routing**: Use matrix curve parameter for S&H, exponential, or logarithmic responses; create "compressor," "expander," or pseudo-random modulations.

---

## 30.77 Annotated Signal Flows: From Key Press to Output

### 30.77.1 Full Signal Path (Block and Schematic-Level)

```
[Key Event]--[CPU]--[Voice Assign]--[Matrix Table]--[DAC/Mux]
                                |        |
                                |        +-->[Modulation CVs]
                                |        
                      [Voice Card: VCO1, VCO2, VCF, VCA, Pan]
                                |
                   [Audio Output]--[Summing Amp]--[Main Output]
```

### 30.77.2 Voice Card Audio and CV Timing Diagrams

- **Audio Path**:  
  - Key press → VCO pitch CV set → VCO output → VCF CV set → VCF output → VCA CV set → VCA output → pan → main sum.
- **Timing**:  
  - Matrix update: ~1ms for all CVs per voice (e.g., 12 voices × 10 CVs = 120 updates in 1ms loop).
  - DAC settling: <10μs, mux switching <1μs, audio path latency negligible.

### 30.77.3 Matrix Update, DAC Settling, and Modulation Slew

- **Matrix Update**:  
  - On each timer tick, CPU evaluates all matrix routes, sums CVs for each destination, updates DAC/mux.
- **DAC Settling**:  
  - Output stable within 10μs; CPU waits before switching mux or updating next channel.
- **Modulation Slew**:  
  - High-rate mod sources (LFO, ENV) updated every tick; for audio-rate modulation, updates may be skipped/interpolated.

---

## 30.78 Example C Code: Calibration, Diagnostics, and Patch Logic

### 30.78.1 Calibration Routines (VCO Tuning, VCF Tracking, VCA Gain)

```c
void calibrate_voice_card(int voice) {
    // VCO scale/offset
    for (int oct = 0; oct < NUM_OCTAVES; ++oct) {
        set_vco_pitch_cv(voice, cv_table[oct]);
        freq[oct] = freq_counter(voice);
    }
    calc_and_store_vco_curve(voice, freq);

    // VCF tracking
    for (int note = 0; note < NUM_NOTES; ++note) {
        set_vcf_cutoff_cv(voice, cutoff_table[note]);
        measure_filter_response(voice);
    }
    adjust_vcf_tracking(voice);

    // VCA unity gain
    set_vca_cv(voice, UNITY_CV);
    measure_output_level(voice);
    adjust_vca_trim(voice);
}
```

### 30.78.2 Fault Detection, Voice Masking, and Reporting

```c
void check_voice_health() {
    for (int v=0; v<NUM_VOICES; ++v) {
        if (!voice_response_ok(v)) {
            mask_voice(v);
            report_fault(v);
        }
    }
}

void mask_voice(int v) {
    voice_status[v] = VOICE_FAULTY;
    silence_voice(v);
}
```

### 30.78.3 Patch Logic for Modular Routing and Polyphony Management

```c
void update_patch_matrix(const patch_t *p) {
    for (int i=0; i<p->matrix_count; ++i) {
        matrix_table[i] = p->matrix[i];
    }
    refresh_matrix();
}

void assign_voice(int note, int velocity, int channel) {
    int v = find_free_voice(channel);
    if (v < 0) v = steal_voice();
    activate_voice(v, note, velocity, channel);
    update_matrix_for_voice(v);
}
```

### 30.78.4 Service Mode Menu and Display Flow

```c
void service_menu() {
    while (!exit_requested()) {
        display_status();
        int cmd = read_panel_input();
        switch(cmd) {
            case CMD_CALIBRATE: calibrate_voice_card(selected_voice); break;
            case CMD_TEST: test_voice(selected_voice); break;
            case CMD_MUTE: mask_voice(selected_voice); break;
            case CMD_SOLO: solo_voice(selected_voice); break;
            case CMD_BACKUP: backup_patch_memory(); break;
            // etc.
        }
    }
}
```

---

## 30.79 Best-Practices for Modern Recreation, Calibration, and Maintenance

1. **Calibration**:  
   - Use auto-cal routines with testpoint feedback; store correction tables in non-volatile storage.
   - Digital trimmers (via DAC offset tables) can replace manual pots in modern builds.
2. **Voice Health**:  
   - Implement real-time health monitoring, auto-mute/solo, and user alerts (LCD or LED).
3. **Modular Patching**:  
   - Expose mod matrix and routing to MIDI/OSC or web UI for modern flexibility.
4. **Persistence**:  
   - Use robust battery backup or FRAM; autosave on patch edit and backup to external storage.
5. **Diagnostics**:  
   - Provide service/diagnostic mode in firmware, and remote logging for field support.
6. **Maintenance**:  
   - Socketed analog ICs, gold test points, and labeled trimmers make servicing and upgrades easier.

---

## 30.80 Glossary, Reference Tables, and Service Data

### 30.80.1 Calibration Points and Test Procedures

| Point      | Measurement   | Target Value    | Adjustment          |
|------------|---------------|-----------------|---------------------|
| VCO1/2     | Frequency     | 440Hz @ A4      | VCO scale/offset    |
| VCF        | Cutoff        | ~1kHz at center | VCF scaling/res     |
| VCA        | Output level  | 0dB unity       | VCA trim            |
| Pan        | Output L/R    | Centered        | Pan trim            |

### 30.80.2 Voice Health Status Codes

| Code       | Meaning                  |
|------------|--------------------------|
| OK         | Voice healthy            |
| FAIL_VCO   | Oscillator not running   |
| FAIL_VCF   | Filter not tracking      |
| FAIL_VCA   | Output stuck/muted       |
| FAIL_PAN   | Pan out of range         |
| MASKED     | Voice masked (user/auto) |

### 30.80.3 Service Menu Functions

| Function       | Description                        |
|----------------|------------------------------------|
| Calibrate      | Run auto-cal for selected voice     |
| Test           | Output test patterns on voice       |
| Mute           | Mask voice from polyphony           |
| Solo           | Solo voice for diagnostics          |
| Backup         | Backup RAM to MIDI sysex            |
| Compare        | Compare patch to factory default    |

---

**End of Part 3: Matrix-12 Voice Calibration, Diagnostics, Modular Patching, and Service – Complete Deep Dive.**

*This concludes the Matrix-12 multi-part case study. For further expansion, refer to the circuit diagrams, original service manuals, and firmware ROM listings provided in the Appendix, or request code for specific patching or analog control routines.*

---