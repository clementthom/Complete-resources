# Chapter 30: Case Studies – PPG Wave (Complete Deep-Dive)
## Part 4: Advanced Modulation, Sequencer, System Service, Calibration, and Complete Emulation

---

## Table of Contents

- 30.289 Advanced Modulation and Routing
  - 30.289.1 LFOs: Architecture, Waveforms, Rate, Sync, and Destinations
  - 30.289.2 Envelopes: Multi-Stage, Looping, and Modulation
  - 30.289.3 Keytracking, Velocity, Aftertouch, and Macro Routing
  - 30.289.4 External Modulation: CV/Gate, MIDI CC, and Performance Controls
- 30.290 Sequencer and Arpeggiator: Hardware, Data Model, and Sync
  - 30.290.1 Internal Step Sequencer: Architecture, Modes, and Programming
  - 30.290.2 Arpeggiator: Latch, Direction, Timing, and Pattern
  - 30.290.3 Sync: DIN, FSK, MIDI Clock, Tape, and Cross-Modulation
  - 30.290.4 Sequencer Data Structures and C Code
- 30.291 System Service, Calibration, and Diagnostics
  - 30.291.1 Panel/Test Modes, Calibration Routines, and Error Handling
  - 30.291.2 DAC/VCF/VCA Trimming, Keybed Scanning, and Tuning
  - 30.291.3 Firmware Update, ROM Swap, and System Recovery
  - 30.291.4 Service Menus and Field Diagnostics
- 30.292 Complete System Emulation: Design, Firmware, and Hardware
  - 30.292.1 Firmware ROM Mapping, Patch/Parameter Table, and Jump Table Reverse Engineering
  - 30.292.2 Emulating the Hybrid Digital/Analog Path in Software
  - 30.292.3 FPGA and DSP Emulation: Timing, Bus, and Wave ROM
  - 30.292.4 Integrating UI, Panel, Tape, MIDI, and Service Routines
- 30.293 Example C Code: Sequencer Engine, Modulation Routing, Calibration, and UI
  - 30.293.1 Step Sequencer Data Model and Playback
  - 30.293.2 LFO/Envelope Engine and Mod Matrix Routing
  - 30.293.3 DAC/VCF/VCA Calibration and Tuning
  - 30.293.4 Service/Test Menu and Panel Feedback
  - 30.293.5 Full Voice/Panel/UI Emulation Skeleton
- 30.294 Appendices: Mod Matrix Tables, Sequencer/Event Layout, Service Flowcharts, Emulation API

---

## 30.289 Advanced Modulation and Routing

### 30.289.1 LFOs: Architecture, Waveforms, Rate, Sync, and Destinations

- **LFO Hardware/Software**:
  - 2–3 LFOs per voice; triangle, square, ramp, random/S&H, user.
  - LFOs clocked by timer interrupt or voice tick, phase-accumulated for each voice.
- **Waveform Generation**:
  - Table-based (ROM or RAM), or computed on the fly for triangle/square.
  - Rate: 0.1–20 Hz typical, adjustable in fine steps.
- **Sync**:
  - Free-running, key-sync (reset on note-on), or MIDI/DIN-sync to external clock.
- **Destinations**:
  - Pitch, wavetable position, filter cutoff, VCA, pan, mod depth, macro.
  - Multiple LFOs can modulate the same or different destinations, with independent depths.

### 30.289.2 Envelopes: Multi-Stage, Looping, and Modulation

- **Envelope Engine**:
  - 2–3 per voice: amp, filter, mod.
  - Multi-stage (ADSR, ADBDSR, looped, etc.), with time/level per stage.
  - Looping: can loop attack-decay or other segments for evolving timbres.
- **Modulation**:
  - Envelope outputs routed to any mod destination via mod matrix.
  - Depth and polarity per route.

### 30.289.3 Keytracking, Velocity, Aftertouch, and Macro Routing

- **Keytracking**:
  - Maps keyboard position to pitch, filter cutoff, envelope times, or wavetable pos.
  - User-definable curves (linear, exponential, custom).
- **Velocity**:
  - Affects amp, filter, mod depth, macro, etc.
  - Split/layer: velocity switches between patches or timbres.
- **Aftertouch**:
  - Channel or poly, mapped to any parameter (VCF, vibrato, wavetable scan, etc.).
- **Macros**:
  - User-assignable combinations of parameters, triggered by panel, MIDI, or performance control.

### 30.289.4 External Modulation: CV/Gate, MIDI CC, and Performance Controls

- **CV/Gate**:
  - Inputs mapped to mod matrix, can control pitch, filter, or any assignable destination.
  - Gate triggers envelopes or sequencer steps.
- **MIDI CC**:
  - Full support for CC1–CC119, NRPN/extended control if available.
  - Assignable to any mod destination with depth and scaling.
- **Performance Controls**:
  - Wheels, pedals, breath controller, ribbon, mapped via mod matrix.

---

## 30.290 Sequencer and Arpeggiator: Hardware, Data Model, and Sync

### 30.290.1 Internal Step Sequencer: Architecture, Modes, and Programming

- **Step Sequencer**:
  - 16–64 steps per pattern, multiple patterns per song.
  - Polyphonic or monophonic per step, velocity and duration per note.
  - Store up to 64 patterns; chain into songs with repeats, jumps, and fills.
- **Programming**:
  - Step input via panel or MIDI, real-time or step-time.
  - Editing: insert/delete steps, quantize, swing/humanize.

### 30.290.2 Arpeggiator: Latch, Direction, Timing, and Pattern

- **Modes**:
  - Up, down, up/down, random, chord, as played.
  - Latch: holds notes until key off or mode change.
- **Timing**:
  - Divisions: 1/4, 1/8, 1/16, triplet, dotted, etc.
  - Syncs to internal or external clock; swing/humanize for groove.

### 30.290.3 Sync: DIN, FSK, MIDI Clock, Tape, and Cross-Modulation

- **DIN Sync**:  
  - 24 or 48 ppqn; start/stop, clock in/out.
- **FSK/Tape**:  
  - Tape sync for legacy sequencers, with auto-jitter correction.
- **MIDI Clock**:  
  - Start/stop/continue, SPP, MTC; follows DAW or other instrument.
- **Cross-Modulation**:  
  - LFO or sequencer can modulate each other for complex rhythms.

### 30.290.4 Sequencer Data Structures and C Code

```c
#define SEQ_STEPS 64
#define SEQ_PATTERNS 16

typedef struct {
    uint8_t note;
    uint8_t velocity;
    uint8_t duration;
    uint8_t channel;
    uint8_t gate;
} seq_step_t;

typedef struct {
    seq_step_t steps[SEQ_STEPS];
    uint8_t length;
    uint8_t swing;
    uint8_t quantize;
    uint8_t repeats;
} seq_pattern_t;

seq_pattern_t patterns[SEQ_PATTERNS];

void play_pattern(int pat) {
    for (int s = 0; s < patterns[pat].length; ++s) {
        seq_step_t* st = &patterns[pat].steps[s];
        if (st->gate)
            trigger_note(st->channel, st->note, st->velocity);
        wait_ms(step_time(patterns[pat].swing, s));
    }
}
```

---

## 30.291 System Service, Calibration, and Diagnostics

### 30.291.1 Panel/Test Modes, Calibration Routines, and Error Handling

- **Panel/Test Modes**:
  - Service/test menu accessed via hidden panel combo.
  - Tests: panel scan, display, DAC/VCF/VCA sweep, keybed, MIDI/Sync loopback.
- **Calibration Routines**:
  - DAC trim: outputs stepped voltages, user trims for full-scale and zero.
  - VCF/VCA: self-oscillation, resonance, and amplitude checked with scope or meter.
  - Keybed: velocity and aftertouch calibration, note triggering.

### 30.291.2 DAC/VCF/VCA Trimming, Keybed Scanning, and Tuning

- **DAC**:
  - Trimmer pots on board for offset and gain.
  - CPU outputs test pattern, user adjusts for 0V, full scale.
- **VCF/VCA**:
  - Calibrated via test mode; user sets reference cutoff/resonance, trims for unity gain and correct frequency.
- **Keybed**:
  - Scan rate checked, velocity/aftertouch curves set via diagnostic menu.
- **Tuning**:
  - Master tune via panel or trimpot; pitch scaling checked across full key range.

### 30.291.3 Firmware Update, ROM Swap, and System Recovery

- **Firmware**:
  - EPROM swap for new OS or features; verify with ROM checksum.
- **Recovery**:
  - System defaults loaded on error, patch bank backup/restore via tape or modern interface.

### 30.291.4 Service Menus and Field Diagnostics

- **Service Menu**:
  - LCD shows real-time status of all voice cards, VCF/VCA, panel state.
  - Field diagnostics: error code log, status LEDs, audio probe points.

---

## 30.292 Complete System Emulation: Design, Firmware, and Hardware

### 30.292.1 Firmware ROM Mapping, Patch/Parameter Table, and Jump Table Reverse Engineering

- **ROM Mapping**:
  - Entry vectors, main loop, ISRs, UI, panel, LFO, envelope, sequencer routines mapped to addresses.
- **Patch Table**:
  - All patch/parameter data mapped in RAM; reverse engineering reveals structure for emulation.
- **Jump Table**:
  - Table of pointers to main subsystems; enables modular emulation and code tracing.

### 30.292.2 Emulating the Hybrid Digital/Analog Path in Software

- **Digital Path**:
  - Cycle-accurate phase accumulator, wavetable ROM, interpolation, envelope/LFO.
- **Analog Path**:
  - VCF/VCA modeled with DSP algorithms (Moog ladder, SSM2044 emulation).
  - Noise, nonlinearity, and temperature effects optionally modeled.
- **Timing**:
  - Emulated timer ticks, voice updates, UI polling in sync with original clock.

### 30.292.3 FPGA and DSP Emulation: Timing, Bus, and Wave ROM

- **FPGA**:
  - RTL for bus, phase logic, wavetable ROM, DAC interface, VCF/VCA CVs.
  - Real-time, parallel voice processing for polyphony.
- **DSP**:
  - Software emulation for VCF/VCA, modulation matrix, sequencer, UI, and panel.

### 30.292.4 Integrating UI, Panel, Tape, MIDI, and Service Routines

- **UI/Panel**:
  - Emulate display, panel, and all edit/test menus; map to keyboard/mouse or MIDI.
- **Tape/MIDI**:
  - File-based emulation of tape/patch IO; virtual MIDI ports for DAW/remote control.
- **Service**:
  - Diagnostics, calibration, and error routines integrated for full maintenance emulation.

---

## 30.293 Example C Code: Sequencer Engine, Modulation Routing, Calibration, and UI

### 30.293.1 Step Sequencer Data Model and Playback

```c
#define SEQ_STEPS 64
typedef struct {
    uint8_t note, velocity, gate, duration;
} seq_step_t;

seq_step_t seq_steps[SEQ_STEPS];

void run_sequencer() {
    for (int i = 0; i < SEQ_STEPS; ++i) {
        if (seq_steps[i].gate)
            trigger_note(seq_steps[i].note, seq_steps[i].velocity);
        wait_ms(seq_steps[i].duration);
    }
}
```

### 30.293.2 LFO/Envelope Engine and Mod Matrix Routing

```c
#define LFO_COUNT 3
uint16_t lfo_table[256];

typedef struct {
    uint16_t val, rate, phase;
    uint8_t waveform;
} lfo_t;

lfo_t lfos[LFO_COUNT];

void tick_lfos() {
    for (int i = 0; i < LFO_COUNT; ++i) {
        lfos[i].phase += lfos[i].rate;
        lfos[i].val = lfo_table[(lfos[i].phase >> 8) & 0xFF];
    }
}

typedef struct {
    uint8_t src, dst;
    int8_t depth;
} mod_route_t;

#define MOD_ROUTES 16
mod_route_t mod_matrix[MOD_ROUTES];

void apply_mod_matrix() {
    for (int i = 0; i < MOD_ROUTES; ++i) {
        int modval = get_mod_source(mod_matrix[i].src);
        set_mod_dest(mod_matrix[i].dst, modval * mod_matrix[i].depth / 128);
    }
}
```

### 30.293.3 DAC/VCF/VCA Calibration and Tuning

```c
void calibrate_dac() {
    for (int val = 0; val < 256; val += 32) {
        output_to_dac(val);
        wait_ms(200);
        display_voltage(val);
    }
}

void calibrate_vcf() {
    for (int cv = 0; cv < 128; cv += 16) {
        set_filter_cv(cv);
        wait_ms(200);
        display_freq(cv);
    }
}
```

### 30.293.4 Service/Test Menu and Panel Feedback

```c
void show_service_menu() {
    lcd_update(0, 0, "Service Menu");
    lcd_update(1, 0, "1: Panel Test");
    lcd_update(2, 0, "2: DAC Calib");
    lcd_update(3, 0, "3: VCF/VCA Calib");
}

void run_panel_test() {
    for (int r = 0; r < PANEL_ROWS; ++r)
        for (int c = 0; c < PANEL_COLS; ++c)
            if (panel_matrix[r][c]) lcd_update(r, c, "*");
}
```

### 30.293.5 Full Voice/Panel/UI Emulation Skeleton

```c
typedef struct {
    voice_t voices[8];
    lfo_t lfos[3];
    env_t envs[8];
    mod_route_t mod_matrix[16];
    panel_state_t panel;
    lcd_t lcd;
    sequencer_t seq;
    // ...
} ppg_wave_state_t;

void ppg_wave_tick(ppg_wave_state_t* s) {
    scan_panel(&s->panel);
    tick_lfos(s->lfos);
    run_sequencer(&s->seq, s->voices);
    apply_mod_matrix(s->mod_matrix, s->voices, s->lfos, s->envs);
    update_lcd(&s->lcd, &s->panel, s->voices, s->seq);
}
```

---

## 30.294 Appendices: Mod Matrix Tables, Sequencer/Event Layout, Service Flowcharts, Emulation API

### 30.294.1 Mod Matrix Table Example

| Source      | Destination        | Depth | Comment           |
|-------------|-------------------|-------|-------------------|
| LFO1        | Filter Cutoff     | +60   | Vibrato/Filter    |
| LFO2        | Wavetable Pos     | +40   | Table sweep       |
| Env1        | Amp               | +127  | ADSR to amp       |
| Velocity    | Filter Cutoff     | +80   | Harder = brighter |
| Aftertouch  | LFO Depth         | +90   | Expression        |
| CV In       | Macro             | +127  | External pedal    |

### 30.294.2 Sequencer/Event Data Layout

- **Pattern**:  
  - Header (length, swing, repeats), step data (note, velocity, duration, gate).
- **Song**:  
  - List of patterns, order, jumps, repeats, fills.

### 30.294.3 Service/Test Flowchart

```
[Start] -> [Panel Test?] -> [Key Scan] -> [LED Feedback]
         -> [DAC Calib?]  -> [Output Stepped Voltage] -> [User Trim]
         -> [VCF Calib?]  -> [Sweep CV] -> [User Trim/Observe]
         -> [Keybed Test?]-> [Scan/Show Velocity]
         -> [End]
```

### 30.294.4 Emulation API Outline

```c
// Emulate panel, UI, voice, mod matrix, sequencer, and all hardware
typedef struct { ... } ppg_wave_state_t;
void ppg_wave_init(ppg_wave_state_t*);
void ppg_wave_tick(ppg_wave_state_t*);
void ppg_wave_load_patch(ppg_wave_state_t*, const char* name);
void ppg_wave_save_patch(ppg_wave_state_t*, const char* name);
void ppg_wave_set_param(ppg_wave_state_t*, int param, int val);
// etc.
```

---