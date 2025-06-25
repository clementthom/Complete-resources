# Chapter 30: Case Studies – PPG Wave (Complete Deep-Dive)
## Part 2: Operating System, UI, Voice Management, MIDI, and Retro-Engineering

---

## Table of Contents

- 30.277 Operating System: Structure, Scheduling, and File System
  - 30.277.1 OS Architecture: Kernel, Interrupts, Task Flow
  - 30.277.2 Patch Storage: Bank Management, Tape/EPROM, Battery RAM
  - 30.277.3 Parameter System: Patch Buffers, Edit Buffer, System Settings
  - 30.277.4 Boot Process, Error Handling, and Diagnostics
- 30.278 User Interface: Panel, Display, Edit Pages, and Softkeys
  - 30.278.1 LCD/VFD Control: Memory Mapping, Update Logic, Custom Fonts
  - 30.278.2 Panel Matrix: Scan Logic, Debounce, Event Mapping
  - 30.278.3 Edit Pages: Parameter Grouping, Page Navigation, Direct Access
  - 30.278.4 Macro/Quick Access: Assignable Buttons, Patch Recall
- 30.279 Voice Assignment, Scheduling, and Modulation Matrix
  - 30.279.1 Polyphony Architecture: Voice Pool and Allocator
  - 30.279.2 Dynamic Voice Assignment: Stealing, Chord/Unison, Split/Layer
  - 30.279.3 Modulation Matrix: Sources, Destinations, Routing Table
  - 30.279.4 Real-time Control: Wheels, Pedals, Aftertouch, External CV/MIDI
- 30.280 MIDI and External Sync: Hardware, Mapping, and Automation
  - 30.280.1 MIDI Hardware: UART, Optoisolation, and Buffering
  - 30.280.2 MIDI Parsing: Running Status, Channel Assignment, Mapping
  - 30.280.3 MIDI Implementation Chart, System Exclusive, Macro Control
  - 30.280.4 Sync: DIN/FSK, Tape, Arpeggiator/Sequencer Integration
- 30.281 Example C Code: Patch IO, Panel/LCD, Voice Scheduler, MIDI Logic
  - 30.281.1 Patch Save/Load, Tape Handler, Battery RAM Management
  - 30.281.2 LCD/VFD Buffer and Parameter Display Logic
  - 30.281.3 Panel Event and Edit Page Dispatcher
  - 30.281.4 Voice Assignment, Chord/Unison
  - 30.281.5 MIDI Event Parser, Channel Map, Macro Handler
- 30.282 Appendices: OS Memory Map, Panel Map, Patch/Voice Data Layout

---

## 30.277 Operating System: Structure, Scheduling, and File System

### 30.277.1 OS Architecture: Kernel, Interrupts, Task Flow

- **Kernel Model**:  
  - Cooperative multitasking (main loop, periodic timer interrupt).
  - Interrupts: timer (voice tick), panel scan, MIDI RX, tape IO, error/exception.
  - Task flow: High-priority voice update and envelope tick, lower for UI and storage.
- **Event Queue**:  
  - Buffers for panel, MIDI, tape, and voice events; timestamped for deterministic handling.

### 30.277.2 Patch Storage: Bank Management, Tape/EPROM, Battery RAM

- **Bank Model**:  
  - 32–128 patch slots in battery-backed SRAM; organized in banks for quick recall.
- **Tape Storage**:  
  - Cassette interface uses block/sector with checksum, header, and retry.
  - Tape loader/saver in OS, with verify and error correction.
- **EPROM Upgrade**:  
  - System/OS and waveform updates via EPROM swap; user banks preserved in RAM.

### 30.277.3 Parameter System: Patch Buffers, Edit Buffer, System Settings

- **Patch Buffer**:  
  - Active patch copied to edit buffer upon recall. Edits written back on save.
- **System Settings**:  
  - Global: tuning, MIDI channel, split/layer config, velocity curve, aftertouch map.
- **Edit Buffer**:  
  - Holds current parameter values for all voice, mod, and system parameters.
  - Undo/compare buffer for A/B patch comparison.

### 30.277.4 Boot Process, Error Handling, and Diagnostics

- **Boot**:  
  - ROM POST (checksum, RAM check, panel/display test, basic voice test).
  - Loads system settings, recalls last used patch.
- **Error Handling**:  
  - Error codes on display, fallback to default patch, log to error buffer.
- **Diagnostics**:  
  - Panel test, DAC/VCF/VCA calibration, tape verify, MIDI loopback.

---

## 30.278 User Interface: Panel, Display, Edit Pages, and Softkeys

### 30.278.1 LCD/VFD Control: Memory Mapping, Update Logic, Custom Fonts

- **Display**:  
  - 2x16 or 2x24 alphanumeric, mapped via parallel bus.
  - Custom fonts for parameter names, envelope/wave display, meters.
  - Double-buffered to avoid flicker; updated on parameter/event change or timer tick.

### 30.278.2 Panel Matrix: Scan Logic, Debounce, Event Mapping

- **Panel**:  
  - 8x8 matrix (typ), scanned with 74LS138/595; debounce in firmware.
  - Assignable function buttons, direct parameter access, bank select.
  - Panel events queued to main event buffer, timestamped for priority.

### 30.278.3 Edit Pages: Parameter Grouping, Page Navigation, Direct Access

- **Edit Pages**:  
  - Parameters grouped: Oscillator, Wavetable, Filter, Envelope, Modulation, System.
  - Page navigation via panel or encoder; context-sensitive display.
  - Direct access: one-touch for most-used parameters; macro support.

### 30.278.4 Macro/Quick Access: Assignable Buttons, Patch Recall

- **Macros**:  
  - Assign panel buttons to patch, parameter group, or system command.
  - Quick recall for live performance (patch, split, layer, arpeggiator state).

---

## 30.279 Voice Assignment, Scheduling, and Modulation Matrix

### 30.279.1 Polyphony Architecture: Voice Pool and Allocator

- **Polyphony**:  
  - 8–16 voices, each with own digital oscillator, envelope, VCF, VCA.
  - Voice pool: status table (active, free, release, stolen).
- **Allocator**:  
  - On note-on: assign to free voice, or steal oldest/release-phase.
  - Note-off: marks voice for envelope release and possible reallocation.

### 30.279.2 Dynamic Voice Assignment: Stealing, Chord/Unison, Split/Layer

- **Voice Stealing**:  
  - Oldest, lowest amplitude, or longest-release voice is reallocated.
- **Chord/Unison**:  
  - Multiple voices per note for thickening; detune/phase spread per voice.
- **Split/Layer**:  
  - Keyboard split: assign lower/higher key ranges to different patches/banks.
  - Layer: simultaneous different timbres on same key (e.g. bass+pad).

### 30.279.3 Modulation Matrix: Sources, Destinations, Routing Table

- **Sources**:  
  - LFOs (2–3 per voice), envelopes (amp, filter, pitch), velocity, aftertouch, panel wheel, external MIDI/CV.
- **Destinations**:  
  - Osc phase, wavetable pos, filter cutoff/res, VCA, pitch, pan.
- **Routing Table**:  
  - Patchable via UI, matrix or list; each source can modulate multiple destinations with independent depth.

### 30.279.4 Real-time Control: Wheels, Pedals, Aftertouch, External CV/MIDI

- **Wheels/Pedals**:  
  - Pitch and modulation wheel, assignable foot pedals; read by ADC, mapped to routing table.
- **Aftertouch**:  
  - Per-key or channel, mapped to pitch, filter, VCA, or custom macro.
- **External**:  
  - MIDI CC, velocity, aftertouch, pitch bend, external CV/gate for modular integration.

---

## 30.280 MIDI and External Sync: Hardware, Mapping, and Automation

### 30.280.1 MIDI Hardware: UART, Optoisolation, and Buffering

- **UART**: 6850/8251, optoisolated input, 128–512 byte FIFO.
- **MIDI Out/Thru**: Buffered, supports daisy chaining and merge.
- **External Sync**: DIN, FSK, tape sync (for arpeggiator/sequencer).

### 30.280.2 MIDI Parsing: Running Status, Channel Assignment, Mapping

- **Parser**:  
  - Handles running status, realtime, and Sysex; maps input channel to internal voice/patch.
  - CC, program change, pitch bend, aftertouch, NRPN, and macro mapping.
- **Event Handling**:  
  - Note on/off, velocity, channel/key aftertouch, CC, program change, macro triggers.

### 30.280.3 MIDI Implementation Chart, System Exclusive, Macro Control

| Message      | Supported | Comments                    |
|--------------|-----------|-----------------------------|
| Note On/Off  | Yes       | Poly, chord, split/layer    |
| Velocity     | Yes       | 0–127, per-voice            |
| Aftertouch   | Yes       | Channel/key, mapped         |
| Program Chg  | Yes       | Patch/bank select           |
| CC           | Yes       | All common, macro mappable  |
| Sysex        | Yes       | Bulk dump/load, patch edit  |
| Clock/MTC    | Yes       | Sync, start/stop supported  |

### 30.280.4 Sync: DIN/FSK, Tape, Arpeggiator/Sequencer Integration

- **DIN/FSK**:  
  - Clock input/output, mapped to sequencer/arpeggiator BPM.
- **Tape Sync**:  
  - Stripe/tape interface for legacy sequencer sync.
- **Arpeggiator/Sequencer**:  
  - Internal or slaved to external sync; all events timestamped for tight timing.

---

## 30.281 Example C Code: Patch IO, Panel/LCD, Voice Scheduler, MIDI Logic

### 30.281.1 Patch Save/Load, Tape Handler, Battery RAM Management

```c
#define PATCH_SIZE 128
#define BANK_SIZE  32

typedef struct {
    char name[12];
    uint8_t params[PATCH_SIZE];
} patch_t;

patch_t patch_bank[BANK_SIZE];

void save_patch_to_ram(int idx, patch_t* patch) {
    memcpy(&patch_bank[idx], patch, sizeof(patch_t));
    battery_ram_write((uint8_t*)&patch_bank, sizeof(patch_bank));
}

void load_patch_from_tape(int idx) {
    // Tape handler: read block, verify checksum, load into patch_bank[idx]
    tape_read_block(idx, (uint8_t*)&patch_bank[idx], sizeof(patch_t));
    if (!verify_checksum(&patch_bank[idx], sizeof(patch_t)))
        error("Tape checksum fail");
}
```

### 30.281.2 LCD/VFD Buffer and Parameter Display Logic

```c
#define LCD_ROWS 2
#define LCD_COLS 24

char lcd_buf[LCD_ROWS][LCD_COLS+1];

void lcd_update(int row, int col, const char* text) {
    strncpy(&lcd_buf[row][col], text, LCD_COLS-col);
    lcd_buf[row][LCD_COLS] = '\0';
    update_lcd_hw(row);
}

void show_patch_name(int idx) {
    lcd_update(0, 0, patch_bank[idx].name);
}

void show_param_val(const char* param, int val) {
    char buf[16];
    snprintf(buf, 16, "%s: %03d", param, val);
    lcd_update(1, 0, buf);
}
```

### 30.281.3 Panel Event and Edit Page Dispatcher

```c
#define PANEL_ROWS 8
#define PANEL_COLS 8

uint8_t panel_matrix[PANEL_ROWS][PANEL_COLS];
uint8_t panel_debounce[PANEL_ROWS][PANEL_COLS];

void scan_panel() {
    for (int r = 0; r < PANEL_ROWS; ++r) {
        select_panel_row(r);
        delay_us(2);
        uint8_t cols = read_panel_cols();
        for (int c = 0; c < PANEL_COLS; ++c) {
            bool pressed = (cols >> c) & 1;
            if (pressed != panel_matrix[r][c]) {
                if (++panel_debounce[r][c] > 2) {
                    panel_matrix[r][c] = pressed;
                    queue_panel_event(r, c, pressed);
                    panel_debounce[r][c] = 0;
                }
            } else {
                panel_debounce[r][c] = 0;
            }
        }
    }
}

void dispatch_panel_event(int row, int col, bool pressed) {
    if (pressed) {
        if (is_edit_page_key(row, col))
            set_edit_page(get_page_from_key(row, col));
        else if (is_param_key(row, col))
            select_param(get_param_from_key(row, col));
        else if (is_macro_key(row, col))
            run_macro(get_macro_from_key(row, col));
    }
}
```

### 30.281.4 Voice Assignment, Chord/Unison

```c
#define VOICES 8

typedef struct {
    uint8_t active;
    uint8_t note;
    uint8_t velocity;
    uint8_t patch;
    uint8_t state;
    uint16_t timer;
} voice_t;

voice_t voices[VOICES];

int find_free_voice() {
    for (int i = 0; i < VOICES; ++i)
        if (!voices[i].active) return i;
    return -1;
}

int steal_voice() {
    int oldest = 0;
    for (int i = 1; i < VOICES; ++i)
        if (voices[i].timer > voices[oldest].timer) oldest = i;
    return oldest;
}

void assign_voice(uint8_t note, uint8_t vel, uint8_t patch) {
    int v = find_free_voice();
    if (v < 0) v = steal_voice();
    voices[v].active = 1;
    voices[v].note = note;
    voices[v].velocity = vel;
    voices[v].patch = patch;
    voices[v].state = 0; // Attack
    voices[v].timer = 0;
}
```

### 30.281.5 MIDI Event Parser, Channel Map, Macro Handler

```c
#define MIDI_BUF_SIZE 256
uint8_t midi_in_buf[MIDI_BUF_SIZE];
uint8_t midi_head = 0, midi_tail = 0;

void midi_rx_isr() {
    uint8_t byte = uart_read();
    midi_in_buf[midi_head++] = byte;
    if (midi_head >= MIDI_BUF_SIZE) midi_head = 0;
}

void process_midi() {
    static uint8_t status = 0;
    while (midi_tail != midi_head) {
        uint8_t byte = midi_in_buf[midi_tail++];
        if (midi_tail >= MIDI_BUF_SIZE) midi_tail = 0;
        if (byte & 0x80) status = byte;
        else handle_midi_event(status, byte);
    }
}

void handle_midi_event(uint8_t status, uint8_t data) {
    if ((status & 0xF0) == 0x90) { // Note On
        uint8_t channel = status & 0x0F;
        uint8_t note = data;
        uint8_t vel = midi_in_buf[midi_tail++];
        assign_voice(note, vel, midi_channel_to_patch[channel]);
    }
    // Handle CC, program change, aftertouch, macros...
}
```

---

## 30.282 Appendices: OS Memory Map, Panel Map, Patch/Voice Data Layout

### 30.282.1 OS Memory Map

| Region      | Start   | End     | Function        |
|-------------|---------|---------|-----------------|
| OS ROM      | 0x0000  | 0x1FFF  | Boot/monitor    |
| RAM         | 0x2000  | 0x3FFF  | Patch, params   |
| Wavetable   | 0x4000  | 0x4FFF  | Wave ROM        |
| Voice Reg   | 0x5000  | ...     | Playback ctrl   |

### 30.282.2 Panel Map

| Row | Col | Function            |
|-----|-----|---------------------|
| 0   | 0   | Patch Up            |
| 0   | 1   | Patch Down          |
| 0   | 2   | Save                |
| 0   | 3   | Load                |
| ... | ... | ...                 |
| 7   | 7   | Macro/Assignable    |

### 30.282.3 Patch/Voice Data Layout

- **Patch**:  
  - Name, wavetable, filter, env, mod, macro, split/layer, system.
- **Voice**:  
  - Note, velocity, phase, pitch, env, filter, amp, mod sources, status.

---