# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 6: Panel/Keyboard Hardware, Encoders, Advanced UI Flow, MIDI Implementation, and Full System Integration

---

## Table of Contents

- 30.94 Panel and Keyboard Hardware: Detailed Schematic and Operation
  - 30.94.1 Panel Matrix: Buttons, Encoders, LEDs – Scanning and Debounce
  - 30.94.2 LCD Display: Interface, Timing, Contrast, and Upgrade Paths
  - 30.94.3 Keyboard Matrix: Velocity, Aftertouch, Split/Layer Logic, and Buffering
  - 30.94.4 Integration of Wheels, Pedals, CV/Gate, and External Controllers
- 30.95 Advanced UI/UX: Menu System, Parameter Editing, and Performance Modes
  - 30.95.1 Menu Tree Structure, Context Stack, and Navigation Algorithms
  - 30.95.2 Editing Modes: Patch, Matrix, Macro, Split/Layer, and Utility
  - 30.95.3 Real-Time Display Update, Softkey Logic, and Status Indication
  - 30.95.4 Error Reporting, User Prompts, and Data Validation
- 30.96 MIDI Implementation: Hardware, Protocol, and Feature Mapping
  - 30.96.1 MIDI UART Circuit, Opto-Isolation, and Buffering
  - 30.96.2 MIDI Message Parsing, Channel Assignment, and OMNI/Poly Modes
  - 30.96.3 Program Change, CC, Sysex, and Real-Time Remote Control
  - 30.96.4 Local/Remote Modes, Thru/Soft Thru, and MIDI Clock Handling
- 30.97 System Integration and Performance
  - 30.97.1 Split/Layer Voice Allocation and Realtime Polyphony Management
  - 30.97.2 Panel/Keyboard Event Routing: Logic, Buffering, and Latency
  - 30.97.3 Synchronization: Panel, Matrix, MIDI, and Voice Engine
  - 30.97.4 Failure Modes, Recovery, and User Feedback
- 30.98 Example C Code: Panel/UI State Machine, Keyboard Buffer, and MIDI Layer
  - 30.98.1 Panel Matrix Scan, Debounce, and Event Queue
  - 30.98.2 LCD Update and Menu Navigation Logic
  - 30.98.3 Keyboard Scan, Velocity, Aftertouch, and Split Layer Assignment
  - 30.98.4 MIDI RX/TX, Parsing, Channel Logic, and Sysex Handler
  - 30.98.5 Error/Status Messaging and Realtime UI Feedback
- 30.99 System Design Patterns, Modernization, and Serviceability Notes
- 30.100 Glossary, Reference Schematics, and Data Tables

---

## 30.94 Panel and Keyboard Hardware: Detailed Schematic and Operation

### 30.94.1 Panel Matrix: Buttons, Encoders, LEDs – Scanning and Debounce

- **Button Matrix**:  
  - 8x8 or larger grid – each row driven by CPU port, columns read via buffer (74LS245) and strobe.
  - **Debounce**: Hardware RC on each input, plus software debounce (ignore toggles <10ms).
  - **Ghost Key Handling**: Diode isolation or software ghost suppression for multi-button presses.
- **Encoders**:  
  - Incremental quadrature, two-bit Gray code per detent.
  - Decoded by CPU or dedicated IC (e.g., LS7183/LS7184); events posted to UI handler.
- **LEDs**:  
  - Row/column or serial shift-register (4094/74HC595) driven for mode, patch, and error display.
  - Multiplexed to minimize power and pin count; soft PWM for intensity control.

#### 30.94.1.1 Panel Scan Pseudocode

```c
for (int row = 0; row < NUM_ROWS; ++row) {
    set_row(row);
    delay_us(10);
    uint8_t cols = read_columns();
    debounce_and_queue_events(row, cols);
}
```

### 30.94.2 LCD Display: Interface, Timing, Contrast, and Upgrade Paths

- **Display**:  
  - 2x40 or 4x20 character LCD, parallel interface (HD44780 or compatible), strobe, data bus, R/W.
  - **Timing**: CPU waits ~40us for command, ~2us for data write, checks busy flag for longer ops.
  - **Contrast**: Potentiometer sets Vo pin; backlight powered by 12V rail (with series resistor).
- **Upgrade**:  
  - OLED drop-in or I2C/SPI LCD modules possible with firmware patch; allows for higher contrast and reliability.

### 30.94.3 Keyboard Matrix: Velocity, Aftertouch, Split/Layer Logic, and Buffering

- **Matrix**:  
  - 8x8–8x12 grid (5-octave), scanned by CPU or PIO (8255).
  - **Velocity**: Dual-contact per key; time between make and break measured for velocity value.
  - **Aftertouch**: Resistive/force-sensing strip, voltage sampled via CPU ADC, per-key or channel.
- **Split/Layer**:  
  - CPU maintains keyzone table; assigns key to split/layer/zone, routes event to appropriate voice group and patch.
- **Buffering**:  
  - Circular event buffer holds most recent key events for processing in main loop and for MIDI TX.

#### 30.94.3.1 Keyboard Scan Pseudocode

```c
for (int row = 0; row < KB_ROWS; ++row) {
    set_kb_row(row);
    delay_us(10);
    uint8_t cols = read_kb_columns();
    process_kb_events(row, cols);
}
```

### 30.94.4 Integration of Wheels, Pedals, CV/Gate, and External Controllers

- **Wheels**:  
  - Pitch and mod wheels: potentiometer or Hall sensor, buffered, ADC sampled.
- **Pedals**:  
  - Sustain, volume, assignable expression; analog or digital input, ADC or logic buffer.
- **CV/Gate**:  
  - External analog in/out for integration with modular gear, buffered, opto-isolated for gate.
- **External Controllers**:  
  - MIDI, plus potential for future USB or wireless with hardware/firmware update.

---

## 30.95 Advanced UI/UX: Menu System, Parameter Editing, and Performance Modes

### 30.95.1 Menu Tree Structure, Context Stack, and Navigation Algorithms

- **Menu Tree**:  
  - Nodes for Patch, Edit, Matrix, Split/Layer, MIDI, Utility, Service.
  - Each node has children (e.g., Edit > OSC, VCF, VCA, ENV, LFO); stack allows for return/back navigation.
- **Context Stack**:  
  - Last 2–4 menus stored, quick return after deep editing.
- **Navigation**:  
  - Panel buttons for up/down/left/right/select, encoder for value scroll, softkeys for Ok/Cancel/Copy/Paste.

### 30.95.2 Editing Modes: Patch, Matrix, Macro, Split/Layer, and Utility

- **Patch Mode**:  
  - Select, load, save, compare, copy patches.  
- **Matrix Mode**:  
  - Add, remove, edit mod routes; depth and curve set per route.
- **Macro Mode**:  
  - Assign physical controls to matrix sources; create real-time morphs.
- **Split/Layer Mode**:  
  - Zone assignment, per-zone patch and output select.
- **Utility**:  
  - Backup, restore, calibration, diagnostics.

### 30.95.3 Real-Time Display Update, Softkey Logic, and Status Indication

- **Display Update**:  
  - Only on value/menu change; partial redraw when possible to minimize flicker.
- **Softkey Logic**:  
  - LCD bottom row mapped to panel softkeys; dynamic labels shown for context.
- **Status**:  
  - Error, warning, and busy states shown via LED and LCD (e.g., "Voice 8 Fail", "Battery Low").

### 30.95.4 Error Reporting, User Prompts, and Data Validation

- **Error Reporting**:  
  - Hardware errors, patch load failures, and calibration alerts shown on LCD and via LEDs.
- **User Prompts**:  
  - Confirm actions (save, overwrite, restore, calibrate), clear prompts for destructive actions.
- **Data Validation**:  
  - Limits enforced on all inputs (e.g., mod depth -127..+127), reject invalid matrix routes, alert on overflow.

---

## 30.96 MIDI Implementation: Hardware, Protocol, and Feature Mapping

### 30.96.1 MIDI UART Circuit, Opto-Isolation, and Buffering

- **MIDI In**:  
  - 6N138 opto-isolator, 220Ω input, UART (6850/8251), interrupt on byte received.
- **MIDI Out/Thru**:  
  - Output buffer to DIN, optional merge of local and external events.
- **Buffering**:  
  - Circular RX and TX buffers, overflow detection and recovery.

### 30.96.2 MIDI Message Parsing, Channel Assignment, and OMNI/Poly Modes

- **Parsing**:  
  - State machine parses running status, data bytes, and system messages.
- **Channel Assignment**:  
  - OMNI mode (all channels), POLY mode (user channel), per-zone channel for splits/layers.
- **Filtering**:  
  - User can filter out specific channels, types (CC, aftertouch, program change).

### 30.96.3 Program Change, CC, Sysex, and Real-Time Remote Control

- **Program Change**:  
  - Loads patch, updates all matrix/DACs, triggers recall logic.
- **CC**:  
  - Mapped to mod sources; can assign any CC to any source in matrix.
- **Sysex**:  
  - Used for patch/bank dump and restore, firmware update, and diagnostics.
- **Remote Control**:  
  - Full patch editing, matrix update, and system control via sysex.

### 30.96.4 Local/Remote Modes, Thru/Soft Thru, and MIDI Clock Handling

- **Local/Remote**:  
  - Local Off: Keyboard outputs only MIDI, not routed to internal voices.
- **Thru/Soft Thru**:  
  - Hardware Thru: Direct connection; Soft Thru: CPU merges local and incoming events.
- **MIDI Clock**:  
  - Used for LFO/sync, arpeggiator (if present); CPU can send clock if acting as master.

---

## 30.97 System Integration and Performance

### 30.97.1 Split/Layer Voice Allocation and Realtime Polyphony Management

- **Split/Layer**:  
  - Keyboard zones mapped to voice groups; CPU manages allocation to ensure even distribution and priority handling.
  - Polyphony reallocated dynamically on voice failure or mode change.

### 30.97.2 Panel/Keyboard Event Routing: Logic, Buffering, and Latency

- **Event Routing**:  
  - All panel and keyboard events pass through event buffer for processing in main loop; priority given to note on/off and macro triggers.
- **Latency**:  
  - Typical <10ms for note-to-audio, <2ms for panel/encoder to LCD.

### 30.97.3 Synchronization: Panel, Matrix, MIDI, and Voice Engine

- **Synchronize**:  
  - Timer tick ensures matrix, DAC, panel, and key events are processed in lockstep.
  - MIDI events timestamped and processed on schedule for tight timing.

### 30.97.4 Failure Modes, Recovery, and User Feedback

- **Voice Fault**:  
  - Faulty voice masked, status shown on panel/LCD; user can retry or remap.
- **Panel or Keyboard Stuck**:  
  - Debounce error detected, panel lockout until resolved or power cycle.
- **Patch RAM Failure**:  
  - Immediate warning, operation continues in volatile mode.

---

## 30.98 Example C Code: Panel/UI State Machine, Keyboard Buffer, and MIDI Layer

### 30.98.1 Panel Matrix Scan, Debounce, and Event Queue

```c
#define NUM_P_ROWS 8
#define NUM_P_COLS 8
uint8_t panel_state[NUM_P_ROWS][NUM_P_COLS];
uint8_t panel_debounce[NUM_P_ROWS][NUM_P_COLS];
event_t panel_events[MAX_PANEL_EVENTS];

void scan_panel() {
    for (int row = 0; row < NUM_P_ROWS; ++row) {
        set_panel_row(row);
        delay_us(10);
        uint8_t cols = read_panel_cols();
        for (int col = 0; col < NUM_P_COLS; ++col) {
            uint8_t pressed = (cols >> col) & 1;
            if (pressed != panel_state[row][col]) {
                if (++panel_debounce[row][col] > DEBOUNCE_THRESH) {
                    panel_state[row][col] = pressed;
                    queue_event(PANEL_EVENT, row, col, pressed);
                    panel_debounce[row][col] = 0;
                }
            } else {
                panel_debounce[row][col] = 0;
            }
        }
    }
}
```

### 30.98.2 LCD Update and Menu Navigation Logic

```c
menu_t *current_menu = &main_menu;
int menu_stack[MENU_STACK_DEPTH];
int menu_stack_ptr = 0;

void lcd_update() {
    lcd_clear();
    lcd_print(current_menu->title);
    for (int i = 0; i < current_menu->num_entries; ++i) {
        lcd_print_entry(current_menu->entries[i]);
    }
    lcd_print_softkeys(current_menu->softkeys);
}

void navigate_menu(int direction) {
    // direction: -1 = up, +1 = down
    current_menu = get_menu_sibling(current_menu, direction);
    lcd_update();
}
```

### 30.98.3 Keyboard Scan, Velocity, Aftertouch, and Split Layer Assignment

```c
#define KB_ROWS 8
#define KB_COLS 12
uint8_t kb_state[KB_ROWS][KB_COLS];
event_t kb_events[MAX_KB_EVENTS];

void scan_keyboard() {
    for (int row = 0; row < KB_ROWS; ++row) {
        set_kb_row(row);
        delay_us(10);
        uint8_t cols = read_kb_cols();
        for (int col = 0; col < KB_COLS; ++col) {
            uint8_t pressed = (cols >> col) & 1;
            if (pressed != kb_state[row][col]) {
                kb_state[row][col] = pressed;
                queue_event(KEY_EVENT, row, col, pressed);
            }
        }
    }
}

void process_key_event(event_t *e) {
    int zone = get_zone(e->row, e->col);
    assign_voice_to_zone(e, zone);
}
```

### 30.98.4 MIDI RX/TX, Parsing, Channel Logic, and Sysex Handler

```c
#define MIDI_BUF_SIZE 256
uint8_t midi_rx_buf[MIDI_BUF_SIZE], midi_tx_buf[MIDI_BUF_SIZE];
int midi_rx_head, midi_rx_tail, midi_tx_head, midi_tx_tail;

void midi_rx_isr() {
    uint8_t byte = midi_uart_read();
    midi_rx_buf[midi_rx_head++] = byte;
    if (midi_rx_head >= MIDI_BUF_SIZE) midi_rx_head = 0;
}

void process_midi() {
    while (midi_rx_tail != midi_rx_head) {
        uint8_t byte = midi_rx_buf[midi_rx_tail++];
        parse_midi_byte(byte);
        if (midi_rx_tail >= MIDI_BUF_SIZE) midi_rx_tail = 0;
    }
}

void parse_midi_byte(uint8_t byte) {
    // state machine for MIDI message assembly and dispatch
    // handles note on/off, CC, program change, sysex, etc.
}
```

### 30.98.5 Error/Status Messaging and Realtime UI Feedback

```c
void display_status(const char* msg) {
    lcd_clear_line(STATUS_LINE);
    lcd_print_at(STATUS_LINE, 0, msg);
    flash_led(STATUS_LED);
}

void report_voice_fault(int v) {
    char buf[32];
    sprintf(buf, "Voice %d Fault", v+1);
    display_status(buf);
}
```

---

## 30.99 System Design Patterns, Modernization, and Serviceability Notes

- **Patterns**:  
  - Event queue decouples hardware scan from UI logic.
  - State machine for menu navigation and editing; context stack for deep workflow.
  - Modular driver model for panel, keyboard, MIDI, and matrix allows upgrades.
- **Modernization**:  
  - OLED/LCD upgrade; USB MIDI; web UI over serial-to-ethernet; flash or FRAM for patch RAM.
- **Serviceability**:  
  - All boards socketed, clear labeling, trimmers and testpoints accessible.
  - Built-in diagnostics, firmware backup/restore via MIDI or USB.

---

## 30.100 Glossary, Reference Schematics, and Data Tables

### 30.100.1 Panel/Keyboard Matrix Sample

| Panel Row | Buttons/Functions         | Encoder | LEDs       |
|-----------|---------------------------|---------|------------|
| 0         | Patch Up, Patch Down      | Yes     | Patch      |
| 1         | Edit, Compare, Copy       | No      | Edit       |
| 2         | Matrix, Macro, Split      | Yes     | Matrix     |
| ...       | ...                       | ...     | ...        |

### 30.100.2 MIDI Message Table

| Status Byte | Message Type   | Data Bytes | Usage Example             |
|-------------|---------------|------------|---------------------------|
| 0x90+n      | Note On       | Note, Vel  | Play note                 |
| 0x80+n      | Note Off      | Note, Vel  | Release note              |
| 0xB0+n      | CC            | CC#, Val   | Mod wheel, pedal, etc.    |
| 0xC0+n      | Program Change| Patch#     | Patch recall              |
| 0xF0        | Sysex         | ...        | Patch dump/restore        |

### 30.100.3 Error/Status Codes

| Code      | Meaning                       |
|-----------|------------------------------|
| 0x00      | OK/Ready                     |
| 0x01      | Panel Fault                  |
| 0x02      | Keyboard Fault               |
| 0x03      | Voice Fault                  |
| 0x04      | Patch RAM Error              |
| 0x10      | MIDI Buffer Overflow         |
| 0x20      | LCD/Display Error            |

---

**End of Part 6: Matrix-12 Panel/Keyboard Hardware, UI, MIDI, and System Integration – Complete Deep Dive.**

*This concludes the case study series on the Matrix-12, encompassing every subsystem required for full hardware/software retroengineering and practical recreation. For ROM disassemblies, advanced mods, and expansion bus details, refer to the full technical appendix.*

---