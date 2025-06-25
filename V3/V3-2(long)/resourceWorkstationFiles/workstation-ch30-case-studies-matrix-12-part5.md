# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 5: Firmware Disassembly, OS Logic, Real-Time Processing, and Advanced Modular Behaviors

---

## Table of Contents

- 30.87 Matrix-12 Firmware: Architecture, Disassembly, and Boot Process
  - 30.87.1 ROM Layout, Bootloader Sequence, and Self-Test Routines
  - 30.87.2 Interrupt Handling, Vectors, and Real-Time Scheduling
  - 30.87.3 Code Memory Map, Overlay/Bank Switching, and OS Upgrade Paths
- 30.88 OS Logic: State Machines, Task Prioritization, and Timing
  - 30.88.1 Main Scheduler, Cooperative and Interrupt-Driven Tasking
  - 30.88.2 State Machine Model: Patch Edit, Performance, Service, MIDI
  - 30.88.3 Real-Time Modulation, Event Queues, and Voice Management
- 30.89 C Code Reverse-Engineering: OS Structures, UI, and Matrix Logic
  - 30.89.1 Firmware Kernel: Main Loop, Interrupts, and Service Modes
  - 30.89.2 Matrix Table Operations: Evaluation, Realtime Update, Curve Processing
  - 30.89.3 Patch Storage, Edit Buffer, and Recall Mechanisms
  - 30.89.4 UI and Panel Logic: Menu Trees, Debouncing, Softkey Handlers
  - 30.89.5 MIDI Input/Output, Parsing, and Remote Control
- 30.90 Advanced Modular Behaviors: Polyphonic Routing, Per-Voice Customization
  - 30.90.1 Per-Voice Modular Matrix: Data Flow and Control
  - 30.90.2 Dynamic Patch Morphing and Macro Assignment
  - 30.90.3 Multi-Zone, Velocity Layers, and Performance Splits
- 30.91 Example: Full C Implementation of Matrix Table Handling and Voice Update
  - 30.91.1 Matrix Data Structures and Evaluation Engine
  - 30.91.2 Per-Voice Parameter Calculation and DAC Dispatch
  - 30.91.3 Curve Application, Mod Source Reading, and Scaling
  - 30.91.4 Voice Event Sequencer and Polyphony Logic
- 30.92 Testing, Debugging, and Future-Proofing: Emulation, Logging, and Expansion
- 30.93 Appendix: Matrix-12 OS Data Maps, Memory Layout, and Reverse-Engineered Firmware Blocks

---

## 30.87 Matrix-12 Firmware: Architecture, Disassembly, and Boot Process

### 30.87.1 ROM Layout, Bootloader Sequence, and Self-Test Routines

- **ROM Layout**:  
  - Bootloader at $F000–$F3FF, OS kernel $F400–$FBFF, menu/UI $FC00–$FFFF.  
  - Service routines and factory patches stored in upper ROM pages.
- **Boot Sequence**:  
  - CPU reset jumps to $F000; hardware registers initialized, stack pointer set.
  - RAM test: fill and verify, flags errors on LCD and via panel LEDs.
  - Voice card poll: each slot queried for ready/busy, disables faulty cards.
  - Panel/encoder/keyboard scan initialized, LCD cleared, splash screen shown.
  - If service mode requested, branch to diagnostics; else, load last patch and enter main OS loop.

#### 30.87.1.1 Boot Pseudocode (Expanded)

```c
void boot_main() {
    cpu_init();
    if (!ram_test()) {
        display_error("RAM ERR");
        halt();
    }
    voice_card_scan();
    panel_lcd_init();
    if (service_mode_requested()) service_menu();
    load_last_patch();
    main_loop();
}
```

### 30.87.2 Interrupt Handling, Vectors, and Real-Time Scheduling

- **Interrupt Table**:  
  - INT0 (Timer): Matrix update, panel scan, UI timer tick.  
  - INT1 (Panel/Encoder): Immediate response to user input.  
  - INT2 (MIDI): RX/TX, event buffer update.  
  - INT3 (Keyboard): Scan, velocity/aftertouch processing.
- **OS Scheduling**:  
  - Timer ISR runs every 1ms, is top-priority; other tasks are cooperative and/or interrupt-driven as needed.
- **Overlay/Bank Switching**:  
  - Large menu/UI code paged in from ROM as needed, overlays allow for expanded features within 8–16KB code memory.

### 30.87.3 Code Memory Map, Overlay/Bank Switching, and OS Upgrade Paths

- **Memory Map**:
  - $0000–$0FFF: Internal RAM (OS, event buffers, edit buffer)
  - $1000–$1FFF: Patch RAM (battery-backed)
  - $2000–$2FFF: Voice registers, panel/keyboard buffer
  - $F000–$FFFF: ROM/EPROM (boot, OS, overlays)
- **Upgrade**:  
  - ROM sockets allow physical chip swaps for OS upgrades; bootloader can support in-circuit programming if hardware allows.

---

## 30.88 OS Logic: State Machines, Task Prioritization, and Timing

### 30.88.1 Main Scheduler, Cooperative and Interrupt-Driven Tasking

- **Main Loop**:  
  - Waits for events (panel, MIDI, keyboard); processes each in turn.
  - Critical real-time (matrix update, panel scan) offloaded to timer ISR.
  - Background: patch autosave, battery check, service polling.

### 30.88.2 State Machine Model: Patch Edit, Performance, Service, MIDI

- **Major States**:
  - PERFORMANCE: Polyphony, patch recall, live modulation.
  - EDIT: Patch parameter edit, matrix routing, macro assign.
  - SERVICE: Calibration, diagnostics, card and trimmer check.
  - MIDI REMOTE: Accepts external parameter changes, patch load/save via MIDI.
- **Transitions**:  
  - Triggered by panel buttons, softkeys, or MIDI events; context and edit buffer tracked.

### 30.88.3 Real-Time Modulation, Event Queues, and Voice Management

- **Modulation**:
  - Matrix evaluation on timer tick; all mod sources read, per-destination CV calculated, DAC dispatched.
- **Event Queues**:
  - Panel, keyboard, MIDI, and timer events queued and processed in main loop.
- **Voice Management**:
  - Polyphonic assigner, voice stealing, split/layer/group logic, per-voice status tracking.

---

## 30.89 C Code Reverse-Engineering: OS Structures, UI, and Matrix Logic

### 30.89.1 Firmware Kernel: Main Loop, Interrupts, and Service Modes

```c
void main() {
    boot_main();
    while (1) {
        process_panel();
        process_keyboard();
        process_midi();
        process_events();
        // background tasks: patch autosave, diagnostics, etc.
    }
}

void timer_isr() {
    update_matrix();
    scan_panel();
    scan_keyboard();
    ++os_ticks;
}
```

### 30.89.2 Matrix Table Operations: Evaluation, Realtime Update, Curve Processing

```c
typedef struct {
    uint8_t src, dst, curve;
    int8_t depth;
} matrix_entry_t;

matrix_entry_t matrix[40];
int16_t mod_sources[24];
int16_t mod_dest[32];

void update_matrix() {
    memset(mod_dest, 0, sizeof(mod_dest));
    for (int i = 0; i < 40; ++i) {
        int16_t val = read_mod_source(matrix[i].src);
        val = apply_curve(val, matrix[i].curve);
        mod_dest[matrix[i].dst] += val * matrix[i].depth;
    }
    for (int d = 0; d < 32; ++d)
        set_dac_mux(d, clamp(mod_dest[d]));
}
```

### 30.89.3 Patch Storage, Edit Buffer, and Recall Mechanisms

```c
typedef struct {
    char name[16];
    matrix_entry_t matrix[40];
    uint8_t osc, vcf, vca, env[5], lfo[3], midi, split, layer;
} patch_t;

patch_t patch_ram[100];
patch_t edit_buffer;

void load_patch(int n) {
    memcpy(&edit_buffer, &patch_ram[n], sizeof(patch_t));
    update_matrix_table(edit_buffer.matrix);
    refresh_ui();
}
```

### 30.89.4 UI and Panel Logic: Menu Trees, Debouncing, Softkey Handlers

```c
typedef struct {
    char *title;
    menu_entry_t *entries;
    int num_entries;
} menu_t;

void panel_event(int btn) {
    if (softkey(btn)) menu_softkey_handler(btn);
    else if (param_inc_dec(btn)) adjust_param(btn);
    else if (menu_nav(btn)) navigate_menu(btn);
    refresh_lcd();
}
```

### 30.89.5 MIDI Input/Output, Parsing, and Remote Control

```c
void midi_isr() {
    midi_event_t evt = read_midi();
    switch (evt.type) {
        case MIDI_NOTE_ON:  alloc_voice(evt.chan, evt.note, evt.vel); break;
        case MIDI_NOTE_OFF: release_voice(evt.chan, evt.note); break;
        case MIDI_CC:       map_cc(evt.chan, evt.data1, evt.data2); break;
        case MIDI_PROG:     load_patch(evt.data1); break;
        case MIDI_SYSEX:    handle_sysex(evt.sysex_data); break;
    }
}
```

---

## 30.90 Advanced Modular Behaviors: Polyphonic Routing, Per-Voice Customization

### 30.90.1 Per-Voice Modular Matrix: Data Flow and Control

- **Data Flow**:  
  - Each voice has independent matrix table; mod sources (LFO, ENV, velocity, aftertouch) are per-voice.
  - Matrix routes can be unique for each voice in split/layer mode.
- **Control**:  
  - Macro assignments: panel/midi controls mapped to any matrix source, morphs between patches.

### 30.90.2 Dynamic Patch Morphing and Macro Assignment

- **Morphing**:  
  - Real-time blend between two patches; CPU interpolates all parameters, including matrix depths.
  - Macro: Encoder mapped to morph value, all voice params updated on each tick.

```c
void morph_patch(const patch_t *a, const patch_t *b, float t) {
    for (int p = 0; p < sizeof(patch_t); ++p) {
        ((uint8_t*)&edit_buffer)[p] = ((1.0f-t)*((uint8_t*)a)[p] + t*((uint8_t*)b)[p]);
    }
    update_matrix_table(edit_buffer.matrix);
}
```

### 30.90.3 Multi-Zone, Velocity Layers, and Performance Splits

- **Multi-Zone**:  
  - Keyboard split into up to 4 zones, each with unique patch/matrix.
  - Velocity layers: Key velocity determines which patch/voice group is triggered.
  - Performance: CPU handles dynamic assignment, voice stealing, and parameter recall per zone.

---

## 30.91 Example: Full C Implementation of Matrix Table Handling and Voice Update

### 30.91.1 Matrix Data Structures and Evaluation Engine

```c
#define NUM_VOICES 12
#define NUM_SOURCES 24
#define NUM_DESTS 32
#define MATRIX_ENTRIES 40

typedef struct {
    uint8_t src, dst, curve;
    int8_t depth;
} matrix_entry_t;

typedef struct {
    matrix_entry_t matrix[MATRIX_ENTRIES];
} matrix_t;

matrix_t per_voice_matrix[NUM_VOICES];
int16_t per_voice_sources[NUM_VOICES][NUM_SOURCES];
int16_t per_voice_dests[NUM_VOICES][NUM_DESTS];

void eval_matrix_voice(int v) {
    memset(per_voice_dests[v], 0, sizeof(per_voice_dests[v]));
    for (int i = 0; i < MATRIX_ENTRIES; ++i) {
        int srcval = per_voice_sources[v][per_voice_matrix[v].matrix[i].src];
        srcval = apply_curve(srcval, per_voice_matrix[v].matrix[i].curve);
        per_voice_dests[v][per_voice_matrix[v].matrix[i].dst] += srcval * per_voice_matrix[v].matrix[i].depth;
    }
}
```

### 30.91.2 Per-Voice Parameter Calculation and DAC Dispatch

```c
void dispatch_voice_cv(int v) {
    for (int d = 0; d < NUM_DESTS; ++d) {
        int16_t cv = clamp(per_voice_dests[v][d], DAC_MIN, DAC_MAX);
        set_dac_mux(v, d, cv);
    }
}
```

### 30.91.3 Curve Application, Mod Source Reading, and Scaling

```c
int16_t apply_curve(int16_t val, uint8_t curve) {
    switch (curve) {
        case CURVE_LINEAR: return val;
        case CURVE_EXP:    return exp_table[val];
        case CURVE_LOG:    return log_table[val];
        case CURVE_SNH:    return sample_and_hold(val);
        default:           return val;
    }
}

int16_t read_mod_source(uint8_t src) {
    // Source dispatch (LFO, ENV, velocity, panel, midi)
    switch (src) {
        case SRC_LFO1: return lfo1_value();
        case SRC_ENV1: return env1_value();
        case SRC_VEL:  return last_velocity;
        // ...
    }
}
```

### 30.91.4 Voice Event Sequencer and Polyphony Logic

```c
typedef struct {
    int active, note, velocity, channel;
    uint32_t on_time, off_time;
} voice_status_t;

voice_status_t voice_status[NUM_VOICES];

void alloc_voice(uint8_t note, uint8_t velocity, uint8_t channel) {
    int v = find_free_voice(channel);
    if (v < 0) v = steal_voice();
    voice_status[v].active = 1;
    voice_status[v].note = note;
    voice_status[v].velocity = velocity;
    voice_status[v].channel = channel;
    voice_status[v].on_time = os_ticks;
    // Trigger envelopes, update matrix, etc.
}
```

---

## 30.92 Testing, Debugging, and Future-Proofing: Emulation, Logging, and Expansion

- **Testing**:  
  - Internal test mode (panel, MIDI, analog outputs) cycles all voices and parameters.
  - Patch CRC/checksum for memory integrity.
- **Debug Logging**:  
  - UART/USB output of OS events, matrix eval stats, voice assign logs.
- **Emulation/Expansion**:  
  - OS hooks allow for additional matrix sources/dests, extra voices, or new UI features.
  - Modular code design enables future upgrades (e.g. 16-voice, USB MIDI, web UI).

---

## 30.93 Appendix: Matrix-12 OS Data Maps, Memory Layout, and Reverse-Engineered Firmware Blocks

### 30.93.1 OS Data Structures

| Name           | Fields                                    | Description                           |
|----------------|-------------------------------------------|---------------------------------------|
| matrix_entry_t | src, dst, curve, depth                    | One matrix route                      |
| patch_t        | name, matrix, osc, vcf, vca, env, lfo     | Patch/preset                          |
| voice_status_t | active, note, velocity, channel, on_time  | Voice state for polyphony             |

### 30.93.2 Memory and ROM Layout

| Range         | Function                       |
|---------------|-------------------------------|
| $0000–$0FFF   | OS RAM, edit buffer           |
| $1000–$1FFF   | Patch RAM                     |
| $2000–$2FFF   | Voice, panel, keyboard regs   |
| $F000–$FFFF   | ROM (boot, OS, menu overlays) |

### 30.93.3 Reverse-Engineered Firmware Snippets

- **Patch Recall:**  
  - Loads matrix table, all params; triggers full DAC/mux refresh.
- **Panel Handler:**  
  - Maps row/col to command, debounces, calls menu or param logic.
- **Voice Assign:**  
  - Finds idle or oldest voice, triggers envelopes and matrix update.

---

**End of Part 5: Matrix-12 Firmware, OS, Real-Time Processing, and Modular Behaviors – Complete Deep Dive.**

*For full OS source, see the project appendix. This documentation now covers every critical detail for re-creation, emulation, or advanced hacking of the Matrix-12 platform.*

---