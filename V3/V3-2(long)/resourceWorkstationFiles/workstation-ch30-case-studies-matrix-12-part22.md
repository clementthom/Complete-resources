# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 22: Calibration, Tuning Algorithms, and Self-Test/Autotune Logic

---

## Table of Contents

- 30.191 Calibration Overview: Why Calibration Matters
  - 30.191.1 Analog Drift, Tuning Instability, and Environmental Factors
  - 30.191.2 Types of Calibration: VCO, VCF, VCA, S/H Offsets, Panel
  - 30.191.3 Required Tools and Test Points
- 30.192 VCO Calibration: Theory, Procedure, and Digital Compensation
  - 30.192.1 VCO Core: CEM3340/AS3340 Characteristics
  - 30.192.2 Expo Converter, Scale, and Offset Trimmers
  - 30.192.3 Digital Tuning Tables and Correction Algorithms
  - 30.192.4 Step-by-Step VCO Calibration Routine
- 30.193 VCF Calibration: Cutoff, Resonance, and Tracking
  - 30.193.1 CEM3372/AS3372 Filter Topology
  - 30.193.2 Key Tracking Compensation and Correction
  - 30.193.3 Resonance Self-Oscillation and Q Tuning
  - 30.193.4 Step-by-Step VCF Calibration Routine
- 30.194 VCA and S/H Calibration: Level, Balance, and Droop
  - 30.194.1 VCA Linearity and Gain Trims
  - 30.194.2 Pan Law, Stereo Balance, and VCA Matching
  - 30.194.3 Sample & Hold Offset, Droop, and Correction
  - 30.194.4 Step-by-Step VCA and S/H Calibration Routine
- 30.195 Panel and Macro Calibration: Encoder, Velocity, Aftertouch, and Macros
  - 30.195.1 Encoder Centering, Acceleration, and Deadband
  - 30.195.2 Velocity Curve Matching
  - 30.195.3 Aftertouch Range, Slope, and Matrix Mapping
  - 30.195.4 Macro Range, Curve, and Cross-Mapping
- 30.196 Self-Test and Autotune: Firmware Routines, Error Detection, and Recovery
  - 30.196.1 Boot-Time Self-Test: RAM, Voice Cards, Panel, LCD
  - 30.196.2 Voice Autotune: Process, Algorithms, and Cycle Times
  - 30.196.3 Error Codes, Logging, and Service Mode
  - 30.196.4 Real-World Failure Cases and Recovery Logic
- 30.197 Example C Code: Calibration Tables, Autotune Algorithms, and Service Handlers
  - 30.197.1 Calibration Table Structures and Nonvolatile Storage
  - 30.197.2 VCO/VCF Autotune State Machine
  - 30.197.3 Panel Calibration, Macro Curve Mapping, and Error Logging
  - 30.197.4 Service Menu, Test Sequencer, and User Feedback
- 30.198 Appendices: Calibration Schematics, Typical Values, and Error Code Reference

---

## 30.191 Calibration Overview: Why Calibration Matters

### 30.191.1 Analog Drift, Tuning Instability, and Environmental Factors

- **Analog Drift**:  
  - VCOs and VCFs depend on precise currents and voltages; temperature, humidity, power supply, and aging cause drift.
  - Regular calibration ensures tuning, filter response, and amplitude accuracy.
- **Tuning Instability**:  
  - Even with precision ICs, reference voltages and expo converters drift over time.
  - Sample & hold circuits can leak, causing CV droop and tuning errors.
- **Environmental Factors**:  
  - Temperature changes (studio, stage, transport) shift pitch/filter unless compensated.
  - Power supply ripple and ground bounce can introduce further errors.

### 30.191.2 Types of Calibration: VCO, VCF, VCA, S/H Offsets, Panel

- **VCO Calibration**:  
  - Scale (1V/oct), offset (A440), and high/low note accuracy per voice.
- **VCF Calibration**:  
  - Cutoff tracking (key follow), resonance behavior, and Q matching.
- **VCA Calibration**:  
  - Unity gain, pan/balance, and noise floor.
- **S/H Offsets**:  
  - Correction for voltage droop and offset in sample & hold circuits.
- **Panel Calibration**:  
  - Encoder detent mapping, velocity and aftertouch curves, macro mapping.

### 30.191.3 Required Tools and Test Points

- **Tools**:  
  - Precision DMM, oscilloscope, tuner (hardware or software), audio interface, service ROM or firmware.
- **Test Points**:  
  - Each voice card: VCO CV in/out, VCF CV in/out, VCA out, S/H out, reference voltages.
  - Panel: encoder lines, velocity/AT ADC, macro voltage.

---

## 30.192 VCO Calibration: Theory, Procedure, and Digital Compensation

### 30.192.1 VCO Core: CEM3340/AS3340 Characteristics

- **VCO Core**:  
  - CEM3340: high-stability, tempco resistor, precision current starved oscillator.
  - Linear and exponential CV inputs, pulse width, sync, and triangle/saw/pulse outs.
- **Factory Specs**:  
  - 1V/oct, ±2 cents over 10 octaves; tempco heater for thermal stability.

### 30.192.2 Expo Converter, Scale, and Offset Trimmers

- **Expo Converter**:  
  - Sets scaling; trimmer adjusts 1V/oct slope.
- **Offset Trim**:  
  - Sets base frequency (e.g., A440 at CV=5V).
- **Procedure**:  
  - Send known CV, measure output frequency, adjust trimmers for correct scale and offset.

### 30.192.3 Digital Tuning Tables and Correction Algorithms

- **Tuning Tables**:  
  - Firmware stores per-voice correction tables (linear or nonlinear) for each note/octave.
  - On each note event, table value added to CV for per-voice correction.
- **Compensation**:  
  - Table built during autotune; corrects for expo mismatch, S/H error, and VCO drift.

### 30.192.4 Step-by-Step VCO Calibration Routine

1. Warm up synth for 30+ minutes.
2. Enter service mode; select VCO tune.
3. Play reference note (e.g., C3, C7), measure output (tuner or scope).
4. Adjust scale trimmer for 1V/oct (octave interval).
5. Adjust offset trimmer for A440 at correct key/CV.
6. For digital correction: run autotune, confirm table is populated.
7. Repeat for all voices; log failures or excessive drift.

---

## 30.193 VCF Calibration: Cutoff, Resonance, and Tracking

### 30.193.1 CEM3372/AS3372 Filter Topology

- **Multimode VCF**:  
  - 2/4 pole lowpass, bandpass, highpass outputs.
  - Exponential current-in, resonance feedback with OTA.
- **Factory Specs**:  
  - Cutoff range 16Hz–16kHz; resonance to self-oscillation.

### 30.193.2 Key Tracking Compensation and Correction

- **Tracking**:  
  - Key-follow trimmer sets CV scale for cutoff vs. keyboard position.
  - Firmware applies further correction per voice/note.
- **Test**:  
  - Play low/high notes, measure cutoff frequency with keys; adjust for equal interval.

### 30.193.3 Resonance Self-Oscillation and Q Tuning

- **Resonance**:  
  - Q trimmer sets feedback level for onset of self-oscillation.
  - Check for smooth resonance onset, no instability or squeal.
- **Q Matching**:  
  - Match Q across voices for uniformity.

### 30.193.4 Step-by-Step VCF Calibration Routine

1. Enter service mode; select VCF tune.
2. Set filter to self-oscillate; measure frequency vs. key.
3. Adjust tracking trimmer for 1V/oct (octave jump).
4. Adjust Q trimmer for self-oscillation at max resonance.
5. Run firmware correction (if available).
6. Test for filter stability and crosstalk.

---

## 30.194 VCA and S/H Calibration: Level, Balance, and Droop

### 30.194.1 VCA Linearity and Gain Trims

- **OTA-based VCA**:  
  - Linear control; trimmer for unity gain.
  - Test: output amplitude at min/max VCA CV.
- **Linearity**:  
  - Test midpoints; adjust for minimal distortion/compression.

### 30.194.2 Pan Law, Stereo Balance, and VCA Matching

- **Pan VCA**:  
  - Dual VCA, trimmer for center balance.
- **Balance**:  
  - Test with mono and stereo signals; adjust for equal L/R output.

### 30.194.3 Sample & Hold Offset, Droop, and Correction

- **S/H Offset**:  
  - Measure CV at output vs. input; adjust buffer or firmware compensation.
- **Droop**:  
  - Observe decay of held CV over 1–10 seconds; replace cap if excessive.

### 30.194.4 Step-by-Step VCA and S/H Calibration Routine

1. Enter service menu; select VCA/Pan tune.
2. Play reference note, measure output at min/mid/max.
3. Adjust VCA trimmer for unity gain.
4. Pan: play center, measure L/R, adjust for balance.
5. S/H: hold CV, measure over time; log and compensate in firmware.

---

## 30.195 Panel and Macro Calibration: Encoder, Velocity, Aftertouch, and Macros

### 30.195.1 Encoder Centering, Acceleration, and Deadband

- **Centering**:  
  - Map encoder detents to logical values; check for skips or repeats.
- **Acceleration**:  
  - Fast spin increases increment; adjust for user preference.
- **Deadband**:  
  - Ignore jitter near center; set threshold in firmware.

### 30.195.2 Velocity Curve Matching

- **Velocity Sensor**:  
  - Dual-contact scan, measures time difference.
- **Curve**:  
  - Map raw value to musical velocity with linear/exponential/log or custom curve.
  - Firmware table editable by user.

### 30.195.3 Aftertouch Range, Slope, and Matrix Mapping

- **Aftertouch**:  
  - Test full key pressure; calibrate min/max, linearity.
- **Mapping**:  
  - Assign to any matrix destination; check for full-range response.

### 30.195.4 Macro Range, Curve, and Cross-Mapping

- **Macro**:  
  - Panel knobs/sliders mapped to matrix; test for full range and curve.
  - Cross-mapping: one macro affects several destinations, can be calibrated for proportionality.

---

## 30.196 Self-Test and Autotune: Firmware Routines, Error Detection, and Recovery

### 30.196.1 Boot-Time Self-Test: RAM, Voice Cards, Panel, LCD

- **RAM Test**:  
  - Write/read pattern test; log failures.
- **Voice Cards**:  
  - Poll presence, run basic function test (gate, CV, audio out).
- **Panel/LCD**:  
  - Scan buttons, LEDs, encoder, display fill.

### 30.196.2 Voice Autotune: Process, Algorithms, and Cycle Times

- **Process**:  
  1. Play known CV/note on each voice.
  2. Measure output frequency (using frequency counter or FFT on audio).
  3. Calculate correction, update per-voice table.
  4. Iterate over all octaves/notes.
- **Cycle Time**:  
  - Full autotune: ~30s for all voices; partial tune: <10s.

### 30.196.3 Error Codes, Logging, and Service Mode

- **Error Codes**:  
  - Each failure maps to code (e.g., 0x11=VCO fail, 0x22=VCF fail, etc.).
- **Logging**:  
  - Last N errors stored in NVRAM; viewed in service menu.
- **Service Mode**:  
  - User can run individual tests, view logs, export via MIDI/Sysex.

### 30.196.4 Real-World Failure Cases and Recovery Logic

- **Failure Cases**:  
  - Voice out of tune: flagged, masked from polyphony.
  - S/H droop: flagged, user warned to replace cap.
  - Panel/encoder stuck: log, suggest cleaning or replacement.

---

## 30.197 Example C Code: Calibration Tables, Autotune Algorithms, and Service Handlers

### 30.197.1 Calibration Table Structures and Nonvolatile Storage

```c
#define NUM_VOICES 12
#define NUM_NOTES 128

typedef struct {
    int16_t vco_tune[NUM_NOTES];
    int16_t vcf_tune[NUM_NOTES];
    int16_t vca_balance;
    int16_t sh_offset;
    uint8_t flags;
} cal_table_t;

cal_table_t cal_data[NUM_VOICES];

void save_calibration() {
    eeprom_write(CAL_ADDR, (uint8_t*)cal_data, sizeof(cal_data));
}

void load_calibration() {
    eeprom_read(CAL_ADDR, (uint8_t*)cal_data, sizeof(cal_data));
}
```

### 30.197.2 VCO/VCF Autotune State Machine

```c
enum { AUTOTUNE_IDLE, AUTOTUNE_START, AUTOTUNE_VCO, AUTOTUNE_VCF, AUTOTUNE_DONE } autotune_state;

void autotune_tick() {
    switch (autotune_state) {
    case AUTOTUNE_START:
        autotune_voice = 0;
        autotune_note = BASE_NOTE;
        autotune_state = AUTOTUNE_VCO;
        break;
    case AUTOTUNE_VCO:
        set_note(autotune_voice, autotune_note);
        wait_settle();
        freq = measure_freq();
        cal_data[autotune_voice].vco_tune[autotune_note] = compute_correction(freq, autotune_note);
        if (++autotune_note >= NUM_NOTES) { autotune_note = BASE_NOTE; autotune_state = AUTOTUNE_VCF; }
        break;
    case AUTOTUNE_VCF:
        set_filter(autotune_voice, autotune_note);
        wait_settle();
        fcut = measure_fcut();
        cal_data[autotune_voice].vcf_tune[autotune_note] = compute_correction(fcut, autotune_note);
        if (++autotune_note >= NUM_NOTES) {
            autotune_voice++;
            autotune_note = BASE_NOTE;
            if (autotune_voice >= NUM_VOICES) autotune_state = AUTOTUNE_DONE;
            else autotune_state = AUTOTUNE_VCO;
        }
        break;
    case AUTOTUNE_DONE:
        save_calibration();
        report_status("Autotune Complete");
        autotune_state = AUTOTUNE_IDLE;
        break;
    }
}
```

### 30.197.3 Panel Calibration, Macro Curve Mapping, and Error Logging

```c
#define NUM_MACRO 8

uint8_t macro_curve[NUM_MACRO][128];

void calibrate_macro(int macro, uint8_t* raw_curve) {
    memcpy(macro_curve[macro], raw_curve, 128);
    save_macro_curve();
}

void log_panel_error(const char* err, int code) {
    panel_error_log[panel_err_ptr++] = (panel_error_t){get_time(), code, err};
    if (panel_err_ptr >= PANEL_ERR_LOG_SIZE) panel_err_ptr = 0;
}
```

### 30.197.4 Service Menu, Test Sequencer, and User Feedback

```c
void service_menu() {
    lcd_print("Service Mode >");
    while (1) {
        show_menu_options();
        int sel = get_user_input();
        switch (sel) {
        case 1: run_vco_calibration(); break;
        case 2: run_vcf_calibration(); break;
        case 3: test_panel(); break;
        case 4: show_error_log(); break;
        case 5: return; // Exit
        }
    }
}
```

---

## 30.198 Appendices: Calibration Schematics, Typical Values, and Error Code Reference

### 30.198.1 Calibration Schematics

```
[VCO CAL]
CV_IN ---[Expo]---[VCO Core]---[Audio Out]
          |          |
     [Trim: Scale] [Trim: Offset]
Test Points: CV_IN, Audio Out

[VCF CAL]
CV_IN ---[OTA]---[Filter Core]---[Audio Out]
          |         |
     [Trim: Tracking] [Trim: Q]
Test Points: CV_IN, Audio Out
```

### 30.198.2 Typical Calibration Values (Factory)

| Parameter         | Value/Range            | Notes         |
|-------------------|-----------------------|--------------|
| VCO Scale         | 1.000 V/oct ±0.5%     | Trimmer set   |
| VCO Offset        | A440 @ 5V CV          |               |
| VCF Tracking      | 1.00 V/oct            | Trimmer set   |
| VCF Q             | Self-osc. @ 75–95%    |               |
| VCA Gain          | 0dB (unity ±0.1dB)    |               |
| S/H Droop         | <2mV/sec              |               |
| Macro Range       | 0–127 full scale      |               |

### 30.198.3 Error Code Reference

| Code  | Meaning                | Subsystem   |
|-------|------------------------|-------------|
| 0x10  | RAM Test Fail          | CPU         |
| 0x11  | VCO Out of Tune        | Voice Card  |
| 0x12  | VCO No Output          | Voice Card  |
| 0x21  | VCF Track Fail         | Voice Card  |
| 0x22  | VCF No Output          | Voice Card  |
| 0x31  | VCA Gain Error         | Voice Card  |
| 0x40  | Panel Button Stuck     | Panel       |
| 0x41  | Encoder Fault          | Panel       |
| 0x50  | S/H Droop              | Voice Card  |
| 0x60  | Macro Mapping Error    | Panel/Macro |

---

**End of Part 22: Matrix-12 Calibration, Tuning, and Self-Test/Autotune Logic – Complete Deep Dive.**

*This section ensures every voice, filter, and panel component is precise for world-class sound and reliability, rounding out the most comprehensive Matrix-12 analysis and recreation resource.*

---