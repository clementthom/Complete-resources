# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 14: Digital Control, Voice Management, Interrupts, and Deep OS/Panel Logic

---

## Table of Contents

- 30.148 Digital Control: CPU, Bus, Memory, and Peripheral Interface
  - 30.148.1 CPU Architecture: 8031/8051 Overview, Timing, and Interrupt Map
  - 30.148.2 Data Bus, Address Bus, ROM/RAM Decoding, and Wait States
  - 30.148.3 Peripheral Interface: Mux, DAC, Panel, Keyboard, MIDI, Expansion
  - 30.148.4 Memory Map: Patches, Buffers, OS, and Lookup Tables
- 30.149 Interrupt System: Sources, Priorities, and Firmware Handlers
  - 30.149.1 Timer Interrupt: Scheduling, Matrix Updates, and Scan Loops
  - 30.149.2 MIDI/Serial Interrupt: UART RX/TX, Buffering, and Real-Time Parsing
  - 30.149.3 Panel/Keyboard Interrupt: Event Queue, Debounce, and UI Responsiveness
  - 30.149.4 Nested/Masked Interrupts, ISR Safety, and Latency
- 30.150 Voice Management: Polyphony, Allocation, Stealing, and Split/Layer
  - 30.150.1 Voice Table: State, Priority, Mask, and Health
  - 30.150.2 Allocation Algorithm: Oldest, Quietest, User Override
  - 30.150.3 Split/Layer, Multi-Zone, and Dynamic Grouping
  - 30.150.4 Voice Fault Masking, Recovery, and Dynamic Reallocation
- 30.151 Deep OS Logic: Panel, Display, Parameter Edit, Menu Tree, and Undo
  - 30.151.1 UI State Machine, Menu Stack, and Softkey Mapping
  - 30.151.2 Parameter Editing: Data Entry, Range Limit, and Commit
  - 30.151.3 Patch Save/Load, Compare, Copy, Init, and Randomize
  - 30.151.4 Error Handling, Feedback, and User Guidance
- 30.152 Example C Code: Bus Read/Write, ISR, Voice Table, and UI Handler
  - 30.152.1 Bus Read/Write Functions and Wait State Logic
  - 30.152.2 Timer/MIDI/Panel Interrupt Handlers and Event Dispatch
  - 30.152.3 Voice Allocation, State Machine, and Mask Handling
  - 30.152.4 Menu/UI Stack, Edit Buffer, and Undo Logic
- 30.153 Appendices: CPU Pinout, Panel Map, and Memory Map Reference

---

## 30.148 Digital Control: CPU, Bus, Memory, and Peripheral Interface

### 30.148.1 CPU Architecture: 8031/8051 Overview, Timing, and Interrupt Map

- **CPU Core**:
  - Intel 8031/8051, running at 12MHz, fetch/execute cycle of 1µs per instruction (single-cycle fetch).
  - 256 bytes internal SRAM, 4K–8K external RAM (SRAM or FRAM for modern builds).
- **Interrupt Map**:
  - INT0: Timer tick (matrix, panel/keyboard scan)
  - INT1: MIDI UART RX/TX
  - INT2: External (expansion, service/test)
  - INT3: Panel/Keyboard (if extra logic)
- **Stack and Registers**:
  - 8 general purpose registers, PSW (program status word), SP (stack pointer), DPTR (data pointer).

### 30.148.2 Data Bus, Address Bus, ROM/RAM Decoding, and Wait States

- **Data Bus**:
  - 8-bit multiplexed bus (P0, P2 for high address), latches for demux (ALE/latch enable).
- **Address Bus**:
  - 16-bit (A0–A15) via P0/P2, decoded by glue logic or 74LS138 decoder.
- **ROM/RAM Decoding**:
  - OS ROM at 0x0000–0x1FFF, Patch RAM at 0x2000–0x2FFF.
  - Peripheral select via chip select, IO mapped to high address space.
- **Wait State Logic**:
  - For slow peripherals (panel, expansion), glue logic inserts wait via READY line.

### 30.148.3 Peripheral Interface: Mux, DAC, Panel, Keyboard, MIDI, Expansion

- **DAC/Mux**:
  - 8 or 12-bit parallel DAC (e.g. DAC0800, MC1408), multiplexed via 4051/4067 analog switches.
  - CPU writes: address (mux), value (DAC), triggers S/H update.
- **Panel/Keyboard**:
  - Panel matrix via P1 or mapped via PPI (8255), keyboard via dedicated scan lines.
- **MIDI**:
  - UART (6850/8251), interrupt-driven, buffer for RX/TX.
- **Expansion**:
  - Bus lines on header: data, address, CS, RD/WR, INT, CLK.

### 30.148.4 Memory Map: Patches, Buffers, OS, and Lookup Tables

| Address       | Region          | Size   | Function           |
|---------------|-----------------|--------|--------------------|
| 0x0000–0x1FFF | OS ROM          | 8K     | Boot, OS, handlers |
| 0x2000–0x2FFF | Patch RAM       | 4K     | Patches, edit buf  |
| 0x3000–0x33FF | Voice Table     | 1K     | Voice state        |
| 0x3400–0x37FF | Matrix Tables   | 1K     | Modulation         |
| 0x3800–0x3BFF | UI/Menu Stack   | 1K     | Menu/context       |
| 0x3C00–0x3FFF | Expansion/IO    | 1K     | Peripherals        |

---

## 30.149 Interrupt System: Sources, Priorities, and Firmware Handlers

### 30.149.1 Timer Interrupt: Scheduling, Matrix Updates, and Scan Loops

- **Timer ISR**:
  - Runs every 1ms (programmable), top priority for matrix update and panel/keyboard scan.
  - Increments OS tick, updates envelopes/LFOs, schedules voice events.

### 30.149.2 MIDI/Serial Interrupt: UART RX/TX, Buffering, and Real-Time Parsing

- **UART RX/TX**:
  - RX: On byte received, push to ring buffer, parse for MIDI message.
  - TX: On buffer empty, load next byte.
  - Handles running status, sysex, and real-time MIDI events.
- **Priority**:
  - Lower than timer, but preempts panel/UI tasks for real-time MIDI.

### 30.149.3 Panel/Keyboard Interrupt: Event Queue, Debounce, and UI Responsiveness

- **Panel/Keyboard ISR**:
  - Optionally triggered by scan hardware or run inside timer ISR.
  - Pushes events to queue, debounces, and notifies UI logic.
- **Responsiveness**:
  - Ensures <20ms latency from user action to display/UI update.

### 30.149.4 Nested/Masked Interrupts, ISR Safety, and Latency

- **Nesting**:
  - Timer can mask others; critical sections guarded.
- **Safety**:
  - ISRs reentrant-safe, event queues lock-protected.
- **Latency**:
  - All ISRs <100µs; avoid long loops or blocking in ISR context.

---

## 30.150 Voice Management: Polyphony, Allocation, Stealing, and Split/Layer

### 30.150.1 Voice Table: State, Priority, Mask, and Health

```c
typedef struct {
    uint8_t status;      // 0=idle, 1=active, 2=release, 3=masked
    uint8_t note, velocity, channel;
    uint16_t start_time, last_event;
    uint8_t patch_id, split_id;
    uint8_t health;      // error count or status bits
} voice_entry_t;

voice_entry_t voice_table[12];
```

### 30.150.2 Allocation Algorithm: Oldest, Quietest, User Override

- **Normal**:
  - Allocate lowest-numbered idle voice.
  - If none idle, select oldest (last used) or quietest (lowest envelope output).
- **Split/Layer**:
  - Only voices mapped to correct split/layer group are eligible.
- **User Override**:
  - Service menu can force-assign or mask voices for extended test.

### 30.150.3 Split/Layer, Multi-Zone, and Dynamic Grouping

- **Split/Layer**:
  - Keyboard zones mapped to patch/voice group.
  - Voice assigner tracks per-zone usage, respects zone limits.
- **Dynamic Grouping**:
  - Voices can be reassigned on-the-fly for splits/layers, e.g., 6+6, 8+4, etc.

### 30.150.4 Voice Fault Masking, Recovery, and Dynamic Reallocation

- **Fault Masking**:
  - Voice marked masked/unavailable after repeated faults or test failure.
- **Recovery**:
  - Service menu or power cycle can retest and unmask.
- **Reallocation**:
  - On voice loss, polyphony reduced, allocation tables updated.

---

## 30.151 Deep OS Logic: Panel, Display, Parameter Edit, Menu Tree, and Undo

### 30.151.1 UI State Machine, Menu Stack, and Softkey Mapping

```c
typedef struct {
    uint8_t menu_id;
    uint8_t parent_id;
    void (*handler)(void);
    uint8_t softkeys[4]; // Codes for softkey actions
} menu_node_t;

menu_node_t menu_tree[64];
uint8_t menu_stack[8];
uint8_t menu_stack_ptr;

void push_menu(uint8_t id) { menu_stack[++menu_stack_ptr] = id; }
void pop_menu() { if (menu_stack_ptr) --menu_stack_ptr; }
```

### 30.151.2 Parameter Editing: Data Entry, Range Limit, and Commit

- **Entry**:
  - Encoder or +/- keys select parameter, softkeys for action.
- **Validation**:
  - All entries range-checked on input (e.g., depth –64..+63).
- **Commit**:
  - On confirm, value applied to patch/edit buffer, matrix recalculated, DAC/mux updated.

### 30.151.3 Patch Save/Load, Compare, Copy, Init, and Randomize

- **Save/Load**:
  - Patch RAM mapped in slot order; patch loaded to edit buffer, saved on command.
- **Compare**:
  - “Compare” toggles between edit and stored patch, highlights changes.
- **Copy/Init/Randomize**:
  - Panel menu supports copy between slots, initialize to default, or randomize (for inspiration).

### 30.151.4 Error Handling, Feedback, and User Guidance

- **Error Display**:
  - LCD and LED indicate error codes/messages.
- **Guidance**:
  - Contextual help: “Press softkey to confirm”, “Invalid value”, etc.
- **Undo/Redo**:
  - Parameter changes logged in ring buffer, up to N steps.

---

## 30.152 Example C Code: Bus Read/Write, ISR, Voice Table, and UI Handler

### 30.152.1 Bus Read/Write Functions and Wait State Logic

```c
uint8_t bus_read(uint16_t addr) {
    set_address(addr);
    set_rd_low();
    wait_states(addr);
    uint8_t val = read_data_bus();
    set_rd_high();
    return val;
}

void bus_write(uint16_t addr, uint8_t val) {
    set_address(addr);
    set_data_bus(val);
    set_wr_low();
    wait_states(addr);
    set_wr_high();
}
```

### 30.152.2 Timer/MIDI/Panel Interrupt Handlers and Event Dispatch

```c
void timer_isr() __interrupt(1) {
    ++os_tick;
    update_matrix();
    scan_panel_keyboard();
    update_envelopes_lfos();
    schedule_voice_events();
}

void midi_isr() __interrupt(2) {
    uint8_t b = uart_read();
    midi_buffer[midi_in_ptr++] = b;
    if (midi_in_ptr >= MIDI_BUF) midi_in_ptr = 0;
    parse_midi();
}

void panel_isr() __interrupt(3) {
    scan_panel();
    push_event_queue(PANEL_EVENT);
}
```

### 30.152.3 Voice Allocation, State Machine, and Mask Handling

```c
int alloc_voice(uint8_t zone) {
    for (int v = 0; v < NUM_VOICES; ++v)
        if (voice_table[v].status == 0 && voice_table[v].split_id == zone)
            return v;
    // No free voice: find oldest or quietest
    int oldest = 0, min_time = UINT16_MAX;
    for (int v = 0; v < NUM_VOICES; ++v)
        if (voice_table[v].last_event < min_time && voice_table[v].split_id == zone) {
            oldest = v; min_time = voice_table[v].last_event;
        }
    return oldest;
}

void mask_voice(int v) {
    voice_table[v].status = 3; // masked
    voice_table[v].health |= 0x80;
}
```

### 30.152.4 Menu/UI Stack, Edit Buffer, and Undo Logic

```c
typedef struct {
    m12_patch_t patch;
    uint8_t last_param;
    uint8_t undo_stack[32][sizeof(m12_patch_t)];
    uint8_t undo_ptr;
} edit_buffer_t;

edit_buffer_t edit_buf;

void edit_param(uint8_t param, uint8_t val) {
    memcpy(edit_buf.undo_stack[edit_buf.undo_ptr++], &edit_buf.patch, sizeof(m12_patch_t));
    if (edit_buf.undo_ptr >= 32) edit_buf.undo_ptr = 0;
    set_patch_param(&edit_buf.patch, param, val);
    edit_buf.last_param = param;
    update_matrix_patch();
}

void undo_edit() {
    if (edit_buf.undo_ptr == 0) return;
    --edit_buf.undo_ptr;
    memcpy(&edit_buf.patch, edit_buf.undo_stack[edit_buf.undo_ptr], sizeof(m12_patch_t));
    update_matrix_patch();
}
```

---

## 30.153 Appendices: CPU Pinout, Panel Map, and Memory Map Reference

### 30.153.1 8031/8051 CPU Key Pinout

| Pin | Function      | Notes                  |
|-----|--------------|------------------------|
| 40  | VCC          | +5V                    |
| 20  | GND          |                        |
| 18  | XTAL2        | Main clock out         |
| 19  | XTAL1        | Main clock in          |
| 9   | RST          | Reset, active high     |
| 29  | PSEN         | Program Store Enable   |
| 30  | ALE          | Address Latch Enable   |
| 31  | EA           | External Access        |
| 32–39 | P0.0–P0.7  | AD0–AD7 (data/addr bus)|
| 1–8 | P1.0–P1.7    | Panel, keyboard, IO    |
| 21–28 | P2.0–P2.7  | A8–A15 (high addr)     |
| ... | ...          | ...                    |

### 30.153.2 Panel/Keyboard Map Example

| Panel Row | Panel Function    | Keyboard Row | Note Range      |
|-----------|------------------|--------------|-----------------|
| 0         | Patch Up/Down    | 0            | C2–B2           |
| 1         | Edit, Compare    | 1            | C3–B3           |
| 2         | Matrix, Macro    | 2            | C4–B4           |
| ...       | ...              | ...          | ...             |

### 30.153.3 Memory Map Reference (Summary)

| Region           | Start   | End     | Size   | Use                 |
|------------------|---------|---------|--------|---------------------|
| OS ROM           | 0x0000  | 0x1FFF  | 8K     | Firmware            |
| Patch RAM        | 0x2000  | 0x2FFF  | 4K     | Patch storage       |
| Voice Table      | 0x3000  | 0x33FF  | 1K     | Voice status/state  |
| Matrix Tables    | 0x3400  | 0x37FF  | 1K     | Mod routing         |
| UI/Menu Stack    | 0x3800  | 0x3BFF  | 1K     | UI context          |
| Expansion/IO     | 0x3C00  | 0x3FFF  | 1K     | Peripherals         |

---

**End of Part 14: Matrix-12 Digital Control, Interrupts, Voice Management, and Deep OS/Panel Logic – Complete Deep Dive.**

*This section details the digital backbone, interrupt logic, and panel/UI system critical for Matrix-12 emulation, hacking, or full recreation at the firmware and interface level.*

---