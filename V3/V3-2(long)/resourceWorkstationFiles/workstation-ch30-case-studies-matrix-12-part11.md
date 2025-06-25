# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 11: Service Mode Firmware, Embedded Diagnostics, and Manufacturing Perspectives

---

## Table of Contents

- 30.128 Service Mode Firmware: Internal Routines and User Flow
  - 30.128.1 Service Menu Structure: Boot, Entry, and Privilege Levels
  - 30.128.2 Firmware Test Routines: RAM, ROM, Voice Card, Panel, and Matrix
  - 30.128.3 Guided Calibration: User Prompts, Automated Tests, and Result Logging
  - 30.128.4 Error Handling: Voice Muting, Fault Logging, and Recovery
- 30.129 Embedded Diagnostics: Hardware and Software Perspectives
  - 30.129.1 RAM/ROM Checksum, Voice Card Presence, and Peripheral Health
  - 30.129.2 Analog Path Tests: Sine, Saw, PWM, VCF Sweep, and VCA Gain
  - 30.129.3 Panel/Keyboard Self-Test, LED/LCD Check, and Encoders
  - 30.129.4 MIDI Loopback, DAC/Mux Verification, and Patch RAM
- 30.130 Manufacturing and Production Testing
  - 30.130.1 Assembly Line Test Fixtures and Automated Procedures
  - 30.130.2 Serial Numbering, Calibration Certificate, and QA Documentation
  - 30.130.3 Burn-In, Final Audio Test, and Shipping Protocol
- 30.131 Example C Code: Service Menu, Test Handlers, and Log System
  - 30.131.1 Service Menu State Machine and User Navigation
  - 30.131.2 Test Pattern Dispatch and Measurement
  - 30.131.3 Error Logging, Reporting, and Panel Notification
  - 30.131.4 Factory Reset, Patch RAM Clear, and Backup
- 30.132 Manufacturing Data: Test Results, Certificates, and Field History
  - 30.132.1 Typical Test Sheet Layout and Log Fields
  - 30.132.2 Calibration Data Printout Example
  - 30.132.3 User-Accessible Service Report Format
- 30.133 Glossary, Data Tables, and Test Reference

---

## 30.128 Service Mode Firmware: Internal Routines and User Flow

### 30.128.1 Service Menu Structure: Boot, Entry, and Privilege Levels

- **Service Menu Entry**:  
  - Entered by holding a specific panel button (e.g., “Compare” or “Split”) at power-on, or by secret sequence in the Utility menu.
  - Three levels: Basic (user), Advanced (technician), Factory (manufacturing/QA).
- **Menu Flow**:
  - Main Menu: Calibration, Diagnostics, Patch Tools, Backup/Restore, Factory Reset.
  - Submenus: Voice Test, Panel Test, MIDI Test, Patch Memory, Expansion Test.
  - Navigation: Up/Down/Select/Back keys; LCD context-sensitive prompts.

### 30.128.2 Firmware Test Routines: RAM, ROM, Voice Card, Panel, and Matrix

- **RAM Test**:  
  - Write/read patterns: 0xAA/0x55, incrementing, walking ones/zeros.
  - Panel/LCD status: “RAM TEST OK” or “RAM ERR @0x1234”.
- **ROM Test**:  
  - Checksum validation; fails if bit rot or reflash needed.
- **Voice Card Test**:  
  - Each slot polled for presence (ID code or logic level), then stepped through VCO/VCF/VCA test patterns.
  - Failures: Muted and flagged in Voice Status Table.
- **Panel/Keyboard Test**:  
  - Button matrix scanned for stuck or bouncing keys, encoder rotation checked, LEDs and LCD cycled.
- **Matrix Test**:  
  - Modulation matrix routes swept through typical sources/destinations; DAC/mux output verified at testpoints.

### 30.128.3 Guided Calibration: User Prompts, Automated Tests, and Result Logging

- **Guided Flow**:
  - LCD displays step-by-step instructions, e.g., “Connect probe to Voice 1 TP1. Press OK.”
  - Automated: Voice swept through calibration points, frequency/output measured and logged.
  - Confirmation: User accepts/adjusts, or repeats step if out of tolerance.
- **Result Logging**:
  - Each calibration event logged in nonvolatile memory; results printed to LCD and optionally exported via MIDI sysex.

### 30.128.4 Error Handling: Voice Muting, Fault Logging, and Recovery

- **Voice Muting**:
  - Failed voice muted from polyphony; UI displays “Voice 5 Muted – VCO Fault”.
- **Fault Logging**:
  - Error type, timestamp, and affected component recorded; rolling buffer keeps last N events.
- **Recovery**:
  - Power cycle or service menu “Unmask All” re-tests all voices; user can override muting for troubleshooting.

---

## 30.129 Embedded Diagnostics: Hardware and Software Perspectives

### 30.129.1 RAM/ROM Checksum, Voice Card Presence, and Peripheral Health

- **RAM/ROM Checksum**:
  - CRC-16 or XOR for fast boot checks. Failures halt boot or flag service needed.
- **Voice Card Presence**:
  - Each slot checked for logic high/low or ID code; missing/faulty boards flagged.
- **Peripheral Health**:
  - Panel, keyboard, and expansion detected via address lines and logic reads.

### 30.129.2 Analog Path Tests: Sine, Saw, PWM, VCF Sweep, and VCA Gain

- **Waveform Test**:
  - VCO set to Sine, Saw, Pulse; outputs measured (auto or user scope).
  - Pass/fail criteria: frequency accuracy, symmetry, amplitude.
- **VCF Sweep**:
  - CV swept 0–100%, output recorded, resonance/peak measured.
- **VCA Gain**:
  - Reference input, CV stepped; output measured for linearity.

### 30.129.3 Panel/Keyboard Self-Test, LED/LCD Check, and Encoders

- **Self-Test**:
  - All buttons prompted to be pressed; failure to register triggers error.
  - LED/LCD cycled; missing segment/pixel flagged.
  - Encoders: Rotation and press events checked for direction and bounce.

### 30.129.4 MIDI Loopback, DAC/Mux Verification, and Patch RAM

- **MIDI Loopback**:
  - MIDI Out to In; device sends/receives test pattern, verifies byte-for-byte.
- **DAC/Mux**:
  - Reference CVs sent, outputs compared to expected at testpoints.
- **Patch RAM**:
  - Write/read test patterns, check for stuck bits or battery fault.

---

## 30.130 Manufacturing and Production Testing

### 30.130.1 Assembly Line Test Fixtures and Automated Procedures

- **Test Fixtures**:
  - Bed-of-nails for voice card edge, panel harness for buttons/LEDs/LCD.
  - PC-driven scripts step through full test; pass/fail logged against serial number.
- **Automated Tests**:
  - Power-on self-test, waveform and filter sweep, panel scan, MIDI test, RAM/ROM pattern.

### 30.130.2 Serial Numbering, Calibration Certificate, and QA Documentation

- **Serial Number**:
  - EEPROM/ROM or sticker, logged in test system.
- **Calibration Certificate**:
  - Printed/readout of calibration values at ship, attached to instrument or stored in flash.
- **QA Doc**:
  - Pass/fail per station, operator initials, date/time, environmental data.

### 30.130.3 Burn-In, Final Audio Test, and Shipping Protocol

- **Burn-In**:
  - 24–72h continuous cycling, all voices triggered, modulated, LFOs swept.
- **Audio Test**:
  - Final measurement: THD, SNR, crosstalk, noise floor.
- **Shipping**:
  - Patch RAM verified, battery checked, all test logs archived.

---

## 30.131 Example C Code: Service Menu, Test Handlers, and Log System

### 30.131.1 Service Menu State Machine and User Navigation

```c
typedef enum { SVC_MAIN, SVC_CAL, SVC_DIAG, SVC_BACKUP, SVC_RESET } svc_state_t;
svc_state_t svc_state = SVC_MAIN;

void service_menu() {
    while (svc_state != SVC_EXIT) {
        switch (svc_state) {
            case SVC_MAIN:
                show_menu("1:Cal 2:Diag 3:Backup 4:Reset");
                int sel = get_panel_input();
                if (sel == 1) svc_state = SVC_CAL;
                else if (sel == 2) svc_state = SVC_DIAG;
                else if (sel == 3) svc_state = SVC_BACKUP;
                else if (sel == 4) svc_state = SVC_RESET;
                break;
            case SVC_CAL: run_calibration(); svc_state = SVC_MAIN; break;
            case SVC_DIAG: run_diagnostics(); svc_state = SVC_MAIN; break;
            case SVC_BACKUP: backup_patches(); svc_state = SVC_MAIN; break;
            case SVC_RESET: factory_reset(); svc_state = SVC_MAIN; break;
        }
    }
}
```

### 30.131.2 Test Pattern Dispatch and Measurement

```c
void run_diagnostics() {
    for (int v = 0; v < NUM_VOICES; ++v) {
        set_vco_waveform(v, SAW);
        set_vco_pitch_cv(v, TEST_CV);
        measure_output(v, "VCO");
        set_vco_waveform(v, SQR);
        set_vcf_cutoff_cv(v, TEST_CUTOFF);
        measure_output(v, "VCF");
        set_vca_cv(v, UNITY);
        measure_output(v, "VCA");
    }
    for (int b = 0; b < PANEL_BUTTONS; ++b) {
        prompt_press_button(b);
        if (!button_pressed(b)) log_error("Panel", b);
    }
    // ...etc.
}
```

### 30.131.3 Error Logging, Reporting, and Panel Notification

```c
typedef struct {
    uint32_t time;
    char comp[8];
    int code;
    char desc[32];
} svc_log_entry_t;

svc_log_entry_t svc_log[128];
int svc_log_ptr = 0;

void log_error(const char* comp, int code) {
    svc_log[svc_log_ptr].time = get_time();
    strncpy(svc_log[svc_log_ptr].comp, comp, 7);
    svc_log[svc_log_ptr].code = code;
    sprintf(svc_log[svc_log_ptr].desc, "Error code %d", code);
    svc_log_ptr = (svc_log_ptr+1) % 128;
    display_status("ERR: %s %d", comp, code);
}
```

### 30.131.4 Factory Reset, Patch RAM Clear, and Backup

```c
void factory_reset() {
    clear_patch_ram();
    clear_correction_tables();
    log_event("Factory Reset");
    display_status("FACTORY RESET DONE");
}

void backup_patches() {
    midi_send_sysex(PATCH_RAM_DUMP, patch_ram, PATCH_RAM_SIZE);
    display_status("BACKUP DONE");
}
```

---

## 30.132 Manufacturing Data: Test Results, Certificates, and Field History

### 30.132.1 Typical Test Sheet Layout and Log Fields

| Field         | Value         |
|---------------|--------------|
| Serial Number | 123456       |
| Date/Time     | 2025-06-25   |
| Operator      | J. Smith     |
| Burn-In Hrs   | 72           |
| VCO Drift     | 1.2c/hr      |
| VCF Track     | 3c/oct       |
| VCA THD       | 0.03%        |
| Panel Test    | PASS         |
| MIDI Test     | PASS         |

### 30.132.2 Calibration Data Printout Example

| Voice | Note | Measured | Correction |
|-------|------|----------|------------|
| 1     | C4   | 261.61Hz | +2c        |
| 1     | C5   | 523.22Hz | -1c        |
| ...   | ...  | ...      | ...        |

### 30.132.3 User-Accessible Service Report Format

```
Matrix-12 Service Report
------------------------
Serial: 123456         Date: 2025-06-25

All voices calibrated and PASS
Voice 7 VCA noise slightly high (+3dB)
Panel and keyboard: OK
Patch RAM battery: OK (3.0V)
Last factory reset: 2025-06-10
Recent errors: None
```

---

## 30.133 Glossary, Data Tables, and Test Reference

### 30.133.1 Glossary

- **Service Mode**: Special firmware state for diagnostics and calibration.
- **Burn-In**: Extended functional test at elevated temperature/load.
- **Calibration Table**: Digital correction values for accurate pitch/gain.
- **Patch RAM**: Battery-backed memory for user data.

### 30.133.2 Data Tables

| Test Type   | Pass Threshold   | Typical Result |
|-------------|------------------|---------------|
| VCO Drift   | <5c/°C           | 2c/°C         |
| VCA THD     | <0.05%           | 0.03%         |
| MIDI Loop   | 100% echo        | 100%          |

---

**End of Part 11: Matrix-12 Service Mode, Diagnostics, and Manufacturing – Complete Deep Dive.**

*This installment documents the firmware, procedures, and data handling necessary for expert service, QA, and reliable manufacturing or modern remanufacture of the Matrix-12.*

---