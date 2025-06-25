# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 2: Software, OS, Modulation Matrix, Digital Event Processing, UI and Patch Storage

---

## Table of Contents

- 30.67 Matrix-12 Operating System (OS) Architecture
  - 30.67.1 System Boot, Initialization and Diagnostics
  - 30.67.2 Memory Map, Interrupt Vectors, and Task Model
  - 30.67.3 Event Loop, Task Scheduling, and Real-Time Model
  - 30.67.4 OS Services: Voice Allocation, Patch Management, Modulation Matrix
- 30.68 Modulation Matrix: Digital Control Meets Analog Routing
  - 30.68.1 Matrix Table Data Structure and Routing Algorithm
  - 30.68.2 DAC/Mux Update Logic, Timing, and Rate Limiting
  - 30.68.3 Handling Polyphonic and Per-Voice Modulation
- 30.69 Patch Memory, Storage, and Backup
  - 30.69.1 Patch Data Structures, Parameters, and Serialization
  - 30.69.2 Battery-Backed RAM and EPROM Logic
  - 30.69.3 MIDI Sysex and External Backup Protocol
- 30.70 User Interface and Workflow Logic
  - 30.70.1 Panel Scan, Debouncing, and Encoder/Event Logic
  - 30.70.2 LCD Menu System, Navigation, and Value Editing
  - 30.70.3 Keyboard Scanning, Split/Layer, and Performance Controls
  - 30.70.4 MIDI In/Out, Local/Remote, and Real-Time Mapping
- 30.71 Example C Code: OS Kernel, Modulation Matrix, UI, and Patch Handling
  - 30.71.1 Boot, Main Loop, Interrupts, and Tasking
  - 30.71.2 Modulation Matrix Evaluation and DAC Update
  - 30.71.3 Patch Serialization and Backup
  - 30.71.4 Panel/LCD Event Handling and Menu Logic
  - 30.71.5 MIDI Parser, Voice Allocation, and Performance Logic
- 30.72 Modern Recreation: Software Patterns and Implementation Tips
- 30.73 Glossary, Data Structures, and Reference Tables

---

## 30.67 Matrix-12 Operating System (OS) Architecture

### 30.67.1 System Boot, Initialization and Diagnostics

- **Power-Up Sequence:**
  - CPU (8031/8049) starts from EPROM, running monitor/diagnostics.
  - RAM test: Iterative write/read patterns, flags errors to panel display and via test points.
  - Voice card detection: Polls all 12 slots for OK/busy status, disables missing cards.
  - Panel/keyboard self-test: Matrix scan for stuck/bouncing keys, encoder range check.
  - DAC/mux loopback: Internal CV output checked at test pins or via software self-test.
- **Service Mode:** Accessed via panel, allows full memory/voice/dac/matrix diagnostics.

#### 30.67.1.1 Boot Pseudocode

```c
void boot_main() {
    if (!ram_test()) error("RAM failure");
    detect_voice_cards();
    panel_keyboard_test();
    dac_mux_selftest();
    if (!battery_ok()) warn("Battery Low");
    load_patches();
    main_loop();
}
```

### 30.67.2 Memory Map, Interrupt Vectors, and Task Model

- **Memory Map:**
  - $0000–$0FFF: Internal RAM (OS data, patch buffer)
  - $1000–$1FFF: Patch RAM (battery-backed)
  - $2000–$2FFF: Voice registers (status, assignment)
  - $3000–$3FFF: Matrix registers (mod matrix table)
  - $4000–$4FFF: Panel/keyboard buffer
  - $F000–$FFFF: EPROM (OS, diagnostics, factory patches)
- **Interrupts:**
  - INT0: Timer tick (main scheduler, ~1ms)
  - INT1: Panel/encoder event
  - INT2: MIDI RX/TX
  - INT3: Keyboard scan/velocity
- **Tasking:**
  - Cooperative (main loop and event polling), timer ISR for fast tasks (matrix update, UI scan)

### 30.67.3 Event Loop, Task Scheduling, and Real-Time Model

- **Main Loop:**
  - Polls panel, keyboard, MIDI, and background services (patch auto-save, battery monitor).
  - ISRs for timer (matrix/DAC refresh), MIDI parsing, panel/encoder interrupts.
  - Real-time: Matrix/DAC refresh rate ~1kHz, panel/keyboard scan ~100Hz, MIDI at interrupt speed.

### 30.67.4 OS Services: Voice Allocation, Patch Management, Modulation Matrix

- **Voice Allocator:**
  - Tracks voice status (idle, assigned, released, failed).
  - Oldest, lowest, or last allocation policy; supports splits/layers and voice reserve.
- **Patch Management:**
  - Battery-backed patch RAM, RAM buffer for current edit, auto-save on patch change.
  - Patch change = load data block, update matrix, send new values to all DAC/mux.
- **Matrix Table Handling:**
  - Each patch has a matrix table (sources, destinations, depth/curve).
  - Patch recall triggers regeneration of all CVs.

---

## 30.68 Modulation Matrix: Digital Control Meets Analog Routing

### 30.68.1 Matrix Table Data Structure and Routing Algorithm

- **Matrix Table Structure:**
  - 20 sources × 32 destinations (max), patchable per preset.
  - Each mapping: source, destination, depth (signed 7/8b), curve (linear, exponential, etc.).
  - Table stored in RAM, loaded per patch.

```c
typedef struct {
    uint8_t source;     // Which mod source (LFO, env, velocity, etc.)
    uint8_t dest;       // Which destination (VCO pitch, filter cutoff, VCA level, etc.)
    int8_t depth;       // -127..+127 (signed), modulation amount
    uint8_t curve;      // Linear, exp, log, S&H, etc.
} matrix_route_t;

matrix_route_t matrix_table[PATCH_MAX_ROUTES];
```

- **Routing Algorithm:**
  - On timer tick, for each destination:
    - Sum all sources*depth for that destination.
    - Clamp to DAC range, apply curve.
    - Write value to DAC via mux select.
  - Separate per-voice and global destinations.

### 30.68.2 DAC/Mux Update Logic, Timing, and Rate Limiting

- **DAC Update:**
  - Main CPU cycles through all destinations, sets mux, writes DAC value.
  - Per-voice parameters (pitch, filter, VCA) updated for each voice in turn.
- **Timing:**
  - Matrix update loop every ~1ms, audio-rate modulation not possible (for LFO, envelopes, etc., update rate is sufficient for musical applications).
  - Rate limiting: For slow sources, updates can be skipped or interpolated.
- **DAC/Mux Hardware:**
  - DAC08 or MC1408, 12-bit or 8-bit, output to 4051/4067 mux (analog switch).
  - Mux select lines controlled by CPU, ensures correct CV routed to correct card.

### 30.68.3 Handling Polyphonic and Per-Voice Modulation

- **Per-Voice Modulation:**
  - Each voice card receives its own CVs for pitch, filter, amp, pan, PWM, etc.
  - CPU maintains per-voice matrix tables, allowing independent mod per voice.
- **Global Modulation:**
  - Some destinations (e.g., master tune, global LFO) can be broadcast to all cards via shared CV lines.

---

## 30.69 Patch Memory, Storage, and Backup

### 30.69.1 Patch Data Structures, Parameters, and Serialization

- **Patch Structure:**
  - Name (16 chars), matrix table (up to 40 routes), oscillator, filter, VCA, env, LFO, split/layer, MIDI, pedal, wheel, panel settings.
  - Patch = 256–512 bytes, stored in battery-backed RAM.
- **Serialization:**
  - On patch save, patch structure is serialized to RAM and optionally to sysex for backup.

```c
typedef struct {
    char name[16];
    matrix_route_t matrix[40];
    uint8_t osc1, osc2, vcf, vca, env1[5], env2[5], lfo[3];
    uint8_t split, layer, midi_chan, pedal_cfg, wheel_cfg;
    // ... (other panel, tuning, voice assign parameters)
} patch_t;
```

### 30.69.2 Battery-Backed RAM and EPROM Logic

- **Patch RAM:**
  - 2–8KB SRAM, battery-backed, checked on boot.
  - On battery failure, warn and prompt for backup restore.
- **EPROM:**
  - OS, diagnostics, factory patches, calibration
  - Service mode allows EPROM reflash for bugfixes.

### 30.69.3 MIDI Sysex and External Backup Protocol

- **Sysex Dump:**
  - Patch/preset/bank dump via MIDI sysex, supports full backup/restore.
  - Transfer format: header, patch data, checksum, footer.
- **Remote Patch Load:**
  - Sysex decode writes to patch RAM, triggers patch reload and matrix refresh.

---

## 30.70 User Interface and Workflow Logic

### 30.70.1 Panel Scan, Debouncing, and Encoder/Event Logic

- **Panel Scan:**
  - 8x8 or larger matrix, rows/columns scanned at ~100Hz.
  - Debounce: Hardware and software (10–20ms settle), auto-repeat for held keys.
- **Encoder Logic:**
  - Quadrature decoding, event posted on change.
  - Used for value entry, menu navigation, fine/coarse adjust.
- **Event Queue:**
  - Panel events (button, encoder), keyboard, MIDI, UI timer posted to event queue for main loop.

### 30.70.2 LCD Menu System, Navigation, and Value Editing

- **Menu Model:**
  - Top-level (Patch, Edit, Matrix, Split/Layer, MIDI, Utility).
  - Context stack: allows return to previous screen, edit submenus, etc.
- **Parameter Editing:**
  - Value displayed with units, min/max, increment/decrement via encoder or panel keys.
  - Softkeys under LCD for "Ok", "Cancel", "Copy", "Paste", "Compare", etc.
- **Display Update:**
  - LCD buffer updated only when value/menu changes to minimize flicker.
  - Cursor and blinking for focus indication.

### 30.70.3 Keyboard Scanning, Split/Layer, and Performance Controls

- **Key Matrix:**
  - Rows/columns polled at ~100Hz, velocity from contact closure time.
  - Aftertouch read via ADC, mapped to mod matrix.
- **Split/Layer Logic:**
  - CPU assigns voices to split/layer zones, supports dynamic reallocation on key events.
- **Performance Controls:**
  - Wheels, pedals, external CV/gate, mapped to mod matrix or direct parameter control.

### 30.70.4 MIDI In/Out, Local/Remote, and Real-Time Mapping

- **MIDI In/Out:**
  - UART interrupt, parses all channels, program change, CC, sysex.
  - Local/remote setting: Keyboard can control internal, external, or both.
- **Real-Time Mapping:**
  - MIDI CC can be mapped to any mod matrix source.
  - Program change triggers patch recall and matrix update.

---

## 30.71 Example C Code: OS Kernel, Modulation Matrix, UI, and Patch Handling

### 30.71.1 Boot, Main Loop, Interrupts, and Tasking

```c
void main() {
    boot_main();
    while (1) {
        poll_panel();
        poll_lcd();
        poll_keyboard();
        poll_midi();
        process_events();
        process_background();
    }
}

void timer_isr() { // ~1ms tick
    update_matrix();
    scan_panel();
    scan_keyboard();
    // ... other fast tasks
}
```

### 30.71.2 Modulation Matrix Evaluation and DAC Update

```c
void update_matrix() {
    for (int dest = 0; dest < NUM_DEST; ++dest) {
        int16_t sum = 0;
        for (int route = 0; route < PATCH_MAX_ROUTES; ++route) {
            if (matrix_table[route].dest == dest) {
                int16_t src = get_mod_source(matrix_table[route].source);
                sum += src * matrix_table[route].depth;
            }
        }
        sum = clamp(sum, DAC_MIN, DAC_MAX);
        set_dac(dest, sum);
    }
}
```

### 30.71.3 Patch Serialization and Backup

```c
void save_patch(int slot, patch_t *p) {
    memcpy(patch_ram + slot * sizeof(patch_t), p, sizeof(patch_t));
    // Optionally sysex backup
    if (backup_enabled) send_sysex_patch(p);
}

void load_patch(int slot, patch_t *p) {
    memcpy(p, patch_ram + slot * sizeof(patch_t), sizeof(patch_t));
    load_matrix(p->matrix);
    // Update all DACs/mux to match patch
}
```

### 30.71.4 Panel/LCD Event Handling and Menu Logic

```c
void panel_event(int row, int col) {
    int id = panel_matrix[row][col];
    handle_panel_button(id);
}

void lcd_event(char c) {
    if (isdigit(c)) select_menu(c - '0');
    else if (c == '+') increment_value();
    else if (c == '-') decrement_value();
}
```

### 30.71.5 MIDI Parser, Voice Allocation, and Performance Logic

```c
void midi_isr() {
    midi_event_t evt = read_midi_event();
    switch (evt.type) {
        case MIDI_NOTE_ON:  alloc_voice(evt.chan, evt.note, evt.vel); break;
        case MIDI_NOTE_OFF: release_voice(evt.chan, evt.note); break;
        case MIDI_CC:       handle_cc(evt.chan, evt.data1, evt.data2); break;
        case MIDI_PGM:      load_patch(evt.data1, &current_patch); break;
        case MIDI_SYSEX:    handle_sysex(evt.sysex_data); break;
        // ...
    }
}

void alloc_voice(uint8_t chan, uint8_t note, uint8_t vel) {
    int v = find_free_voice();
    assign_voice(v, chan, note, vel);
}
```

---

## 30.72 Modern Recreation: Software Patterns and Implementation Tips

1. **Platform:**
   - Modern MCU (STM32, ESP32) or RTOS for main CPU; I2S/SPI DAC for CVs, GPIO for mux.
   - Use battery-backed SRAM/FRAM or SD card for patch memory.
2. **Matrix Engine:**
   - Per-destination update loop, fixed-point math for speed.
   - Use DMA if possible for DAC/mux update to meet 1kHz loop.
3. **UI:**
   - OLED/LCD, rotary encoder, and keypad for panel.
   - Virtual keyboard, touch, or MIDI for note entry.
4. **Patch Management:**
   - Use JSON or binary blobs for patch storage; regular autosave.
   - MIDI sysex for backup/restore, use checksum for error-proof transfer.
5. **MIDI:**
   - Full OMNI/poly, CC/NRPN mapping, local/remote split, DAW integration.
6. **Performance:**
   - Fast ISR for matrix update, UI debounce; background for patch save/load.
   - Prioritize UI responsiveness and voice allocation for live play.

---

## 30.73 Glossary, Data Structures, and Reference Tables

### 30.73.1 Major Data Structures

| Name          | Fields                                      | Description                |
|---------------|---------------------------------------------|----------------------------|
| patch_t       | name, matrix, osc, vcf, vca, env, lfo, etc. | Patch/preset structure     |
| matrix_route_t| source, dest, depth, curve                  | One mod matrix routing     |
| midi_event_t  | type, chan, note, vel, data1, data2         | MIDI event structure       |

### 30.73.2 Task Priorities

| Task            | Priority  | Notes                         |
|-----------------|-----------|------------------------------|
| Matrix Update   | Highest   | Must run at ~1kHz             |
| Panel/UI        | High      | Panel, encoder, LCD           |
| MIDI            | High      | Full speed ISR                |
| Patch Save      | Low       | Background, async             |

### 30.73.3 UI Navigation Map

| Button/Key      | Function                |
|-----------------|------------------------|
| Arrow keys      | Move cursor             |
| Enter           | Confirm/select          |
| Esc             | Cancel/back             |
| +/-             | Increment/decrement     |
| Panel keys      | Patch, Matrix, Edit     |
| LCD soft key    | Ok, Cancel, Compare     |

### 30.73.4 Patch Data Model

| Entity      | Fields                            | Description       |
|-------------|-----------------------------------|-------------------|
| Patch       | name, matrix, osc, env, lfo, etc. | Patch/preset      |
| Matrix      | routes[], num_routes              | Mod matrix table  |

---

**End of Part 2: Matrix-12 Software, Modulation Matrix, Event Processing, UI, and Patch Storage – Complete Deep Dive.**

*Part 3 will provide a deep-dive into voice-level analog control, calibration, service/diagnostic firmware, real-world troubleshooting, and practical modular patching examples, with annotated signal flows and code logic for every advanced feature.*

---