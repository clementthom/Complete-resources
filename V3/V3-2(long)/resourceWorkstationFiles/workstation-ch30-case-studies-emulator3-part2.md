# Chapter 30: Case Studies – Emulator III (Complete Deep-Dive)
## Part 2: Operating System, UI, Sequencing, MIDI, and SCSI Integration

---

## Table of Contents

- 30.257 Operating System: Structure, Scheduling, and File System
  - 30.257.1 OS Architecture: Kernel, Interrupts, and Task Scheduler
  - 30.257.2 File System: Bank, Sample, Sequence Storage, and Directory
  - 30.257.3 Disk and SCSI I/O: Controller, DMA, and Error Handling
  - 30.257.4 Boot Process, Error Handling, and Recovery
- 30.258 User Interface: LCD, Panel, Softkeys, and Remote Control
  - 30.258.1 LCD Control: Memory Mapping, Update Logic, and Custom Characters
  - 30.258.2 Panel and Encoder: Scan Logic, Debounce, and Event Mapping
  - 30.258.3 Softkey Table: Dynamic Assignment and Contextual Menus
  - 30.258.4 Remote UI: MIDI/SCSI, RS-232, and Computer Integration
- 30.259 Sequencer Engine: Event Model, Playback, and Synchronization
  - 30.259.1 Event Storage: Song, Pattern, Track, and Step Encoding
  - 30.259.2 Playback Engine: Timing, Quantization, and Voice Allocation
  - 30.259.3 Synchronization: Internal Clock, Tape Sync, MIDI Sync
  - 30.259.4 Editing Features: Cut, Paste, Repeat, Transform, Undo
- 30.260 MIDI Engine: Hardware, Parsing, Mapping, and Automation
  - 30.260.1 UART, Optoisolation, and Buffering
  - 30.260.2 MIDI Parsing: Event Handling and Running Status
  - 30.260.3 Mapping Table: Multi-Timbral Assignment and Macros
  - 30.260.4 MIDI Automation, Clock, and Sync
- 30.261 Example C Code: File I/O, Panel/LCD, Sequencer, and MIDI Logic
  - 30.261.1 File System Handler, Bank Load/Save, and SCSI Abstraction
  - 30.261.2 LCD Buffer and Update Logic
  - 30.261.3 Panel/Softkey Event Dispatcher
  - 30.261.4 Sequencer Track/Event Model
  - 30.261.5 MIDI Event Parser, Channel, and Voice Assignment
- 30.262 Appendices: OS Memory Map, LCD/Panel Map, Sequencer Data Layout

---

## 30.257 Operating System: Structure, Scheduling, and File System

### 30.257.1 OS Architecture: Kernel, Interrupts, and Task Scheduler

- **Kernel Model**:  
  - Cooperative multitasking with prioritized event loop (main loop, interrupt handlers).
  - Interrupts: timer, disk/SCSI, panel/encoder, MIDI, voice card, and error/exception.
  - Event queue with time-stamped events for real-time sequencing, audio, and UI responsiveness.
- **Task Scheduling**:  
  - High-priority for audio (sample playback, buffer refill, DMA interrupts).
  - Background for file I/O, SCSI scans, display refresh, and UI event polling.

### 30.257.2 File System: Bank, Sample, Sequence Storage, and Directory

- **File System**:  
  - Hierarchical (bank > sample > sequence), stored on floppy, SCSI, or RAM disk.
  - Directory/metadata structure: file name, size, type, date, format version.
  - File types: Bank (.BNK), Sample (.SMP), Sequence (.SEQ), Settings (.CFG), System (.SYS).
- **Block Size**:  
  - 512–2048 bytes per block; supports large samples via chain/paging.
- **Bank/Sequence Storage**:  
  - Each bank contains sample keymaps, velocity splits, and controller assignments; sequence is pattern-based with tracks/events.

### 30.257.3 Disk and SCSI I/O: Controller, DMA, and Error Handling

- **Floppy Controller**:  
  - WD1772 (or similar), mapped to I/O space; IRQ-driven transfer, supports single/double density.
  - OS manages sector allocation, directory, error retries.
- **SCSI Controller**:  
  - NCR53C94/53C400 or custom ASIC; supports multiple LUNs, DMA transfer.
  - Block-level DMA for fast sample/bank loading; background scan for new devices.
- **Error Handling**:  
  - CRC, block remap, retry logic; user visible error codes/log.

### 30.257.4 Boot Process, Error Handling, and Recovery

- **Boot**:  
  - ROM POST (power-on self-test), memory/RAM check, bus and card test.
  - Loads kernel from floppy or SCSI, then user settings/banks.
  - Boot error displays on LCD, logs to error buffer.
- **Recovery**:  
  - Diagnostics menu, user-initiated reformat, backup/restore, and SCSI scan tools.

---

## 30.258 User Interface: LCD, Panel, Softkeys, and Remote Control

### 30.258.1 LCD Control: Memory Mapping, Update Logic, and Custom Characters

- **LCD**:  
  - 4x40 or 2x40 alphanumeric, mapped to parallel bus; hardware busy flag and strobe for update sync.
  - Custom character generator for waveform, envelope, and meter display.
  - LCD buffer is double-buffered to avoid flicker; updated at panel event or timer tick.

### 30.258.2 Panel and Encoder: Scan Logic, Debounce, and Event Mapping

- **Panel**:  
  - Matrix scan (8x8 or larger), multiplexed with 74LS138/595, debounce in firmware.
  - Softkeys map to dynamic menu functions; rotary encoder for data entry, scanned by phase detect logic.
  - Panel events queued as OS events for immediate or deferred handling.

### 30.258.3 Softkey Table: Dynamic Assignment and Contextual Menus

- **Softkey Table**:  
  - Each UI “page” has a softkey assignment table (label, function pointer).
  - OS updates both LCD labels and event handlers on context/page change.
  - Supports user macro assignment for custom workflows.

### 30.258.4 Remote UI: MIDI/SCSI, RS-232, and Computer Integration

- **Remote Control**:  
  - MIDI SysEx for patch/bank management from remote computer.
  - SCSI for direct sample upload/download, editor integration.
  - RS-232 (service/debug) for diagnostics, firmware updates, or advanced control.

---

## 30.259 Sequencer Engine: Event Model, Playback, and Synchronization

### 30.259.1 Event Storage: Song, Pattern, Track, and Step Encoding

- **Sequencer Model**:  
  - Song = list of patterns; pattern = set of tracks; track = events/steps.
  - Events: {time, note, velocity, duration, channel, controller, program change}.
  - Step data: packed for efficiency, per-track or per-pattern quantization.
- **RAM Layout**:  
  - Sequencer RAM holds current song, edit buffer, undo stack, and event queue.

### 30.259.2 Playback Engine: Timing, Quantization, and Voice Allocation

- **Timing**:  
  - Timer interrupt sets sequencer tick; BPM and time signature user-selectable.
  - Quantization: Non-destructive, real-time or offline, with swing/humanize.
- **Voice Allocation**:  
  - Scheduler assigns events to available voices, supports multi-timbral splits, velocity zones, and release tails.
  - Voice stealing policy: oldest, lowest velocity, or release-phase preferred.

### 30.259.3 Synchronization: Internal Clock, Tape Sync, MIDI Sync

- **Internal Sync**:  
  - Master timer and sequencer clock; all playback and LFOs in sync.
- **Tape Sync**:  
  - FSK/SMPTE in/out, with auto-jitter correction and chase lock.
- **MIDI Sync**:  
  - Sends/receives MIDI clock, start/stop/continue, SPP, and MTC for DAW sync.

### 30.259.4 Editing Features: Cut, Paste, Repeat, Transform, Undo

- **Editing**:  
  - Select/cut/copy/paste events or tracks; block repeat, quantize, transpose, randomize velocity/duration.
  - Undo/redo for up to N operations; song/pattern structure edit with drag/drop on LCD menu.

---

## 30.260 MIDI Engine: Hardware, Parsing, Mapping, and Automation

### 30.260.1 UART, Optoisolation, and Buffering

- **UART**:  
  - 6850/8251, interrupt-driven, opto-isolated input, buffered output/thru.
  - FIFO buffer, overflow/underrun detection; real-time message priority.

### 30.260.2 MIDI Parsing: Event Handling and Running Status

- **Parser**:  
  - Handles running status, system real-time, and Sysex.
  - Filters by channel, note, velocity, CC, program change, and Sysex header.
- **Event Handling**:  
  - Note on/off, velocity, aftertouch, pitch bend, CC, program change, macro triggers.

### 30.260.3 Mapping Table: Multi-Timbral Assignment and Macros

- **Mapping Table**:  
  - User-assignable: MIDI channel/note to internal sample/voice/bank.
  - Macro assignments for CC/pedal input, pitch wheel, aftertouch, and patch change.

### 30.260.4 MIDI Automation, Clock, and Sync

- **Automation**:  
  - Sequencer and external MIDI can automate any assignable parameter, with interpolation and tempo sync.
- **Clock/Sync**:  
  - MIDI clock in/out, SPP, MTC; start/stop/continue; DAW/remote sequencer sync.

---

## 30.261 Example C Code: File I/O, Panel/LCD, Sequencer, and MIDI Logic

### 30.261.1 File System Handler, Bank Load/Save, and SCSI Abstraction

```c
typedef struct {
    char name[16];
    uint8_t type;
    uint32_t start_block;
    uint32_t length;
    uint32_t mod_date;
} fs_entry_t;

fs_entry_t fs_dir[128];

uint8_t disk_blocks[8192][2048];

int find_bank(const char* name) {
    for (int i = 0; i < 128; ++i)
        if (strcmp(fs_dir[i].name, name) == 0) return i;
    return -1;
}

void load_bank(const char* name, uint8_t* buf, uint32_t maxlen) {
    int idx = find_bank(name);
    if (idx < 0) return;
    uint32_t block = fs_dir[idx].start_block;
    uint32_t rem = fs_dir[idx].length;
    uint32_t pos = 0;
    while (rem && block) {
        memcpy(buf + pos, disk_blocks[block], 2048);
        pos += 2048;
        block = get_next_block(block);
        rem -= 2048;
    }
}

int scsi_read(uint32_t lba, uint8_t* buf) {
    // SCSI abstraction: send read command, wait for IRQ, handle errors
    // ...
    return 1; // Success
}
```

### 30.261.2 LCD Buffer and Update Logic

```c
#define LCD_ROWS 4
#define LCD_COLS 40

char lcd_buf[LCD_ROWS][LCD_COLS+1];

void lcd_update(int row, int col, const char* text) {
    strncpy(&lcd_buf[row][col], text, LCD_COLS-col);
    lcd_buf[row][LCD_COLS] = '\0';
    update_lcd_hw(row);
}

void lcd_show_menu(const char* menu[], int n) {
    for (int i = 0; i < n && i < LCD_ROWS; ++i)
        lcd_update(i, 0, menu[i]);
}
```

### 30.261.3 Panel/Softkey Event Dispatcher

```c
#define SOFTKEYS 16

typedef struct {
    char label[12];
    void (*handler)();
} softkey_t;

softkey_t softkey_map[SOFTKEYS];

void softkey_press(int idx) {
    if (softkey_map[idx].handler)
        softkey_map[idx].handler();
}

void update_softkeys_for_page(const char* page) {
    // Assign softkeys for context
    if (strcmp(page, "Sequencer") == 0) {
        set_softkey(0, "Play", seq_play);
        set_softkey(1, "Stop", seq_stop);
        set_softkey(2, "Copy", seq_copy);
        set_softkey(3, "Paste", seq_paste);
        // etc...
    }
}
```

### 30.261.4 Sequencer Track/Event Model

```c
#define TRACKS 16
#define STEPS  128

typedef struct {
    uint8_t note;
    uint8_t velocity;
    uint8_t duration;
    uint8_t channel;
} seq_step_t;

seq_step_t seq_grid[TRACKS][STEPS];

typedef struct {
    uint8_t playing;
    uint8_t playhead;
    uint16_t bpm;
} seq_state_t;

seq_state_t seq_state = {0, 0, 120};

void tick_sequencer() {
    if (!seq_state.playing) return;
    for (int t = 0; t < TRACKS; ++t)
        if (seq_grid[t][seq_state.playhead].note)
            trigger_note(t, seq_grid[t][seq_state.playhead].note,
                         seq_grid[t][seq_state.playhead].velocity);
    seq_state.playhead = (seq_state.playhead + 1) % STEPS;
}
```

### 30.261.5 MIDI Event Parser, Channel, and Voice Assignment

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
        assign_voice(channel, note, vel);
    }
    // Add more parsing for CC, PC, etc.
}
```

---

## 30.262 Appendices: OS Memory Map, LCD/Panel Map, Sequencer Data Layout

### 30.262.1 OS Memory Map

| Region      | Start    | End      | Function        |
|-------------|----------|----------|-----------------|
| OS ROM      | 0x000000 | 0x03FFFF | Boot/monitor    |
| OS RAM      | 0x040000 | 0x07FFFF | Variables, stack|
| Sample RAM  | 0x080000 | 0x3FFFFF | Samples/voice   |
| Voice Reg   | 0x400000 | ...      | Playback ctrl   |

### 30.262.2 LCD/Panel Map

| Softkey | Label    | Function    |
|---------|----------|------------|
| 1       | Play     | Start Seq  |
| 2       | Stop     | Stop Seq   |
| 3       | Copy     | Copy Block |
| 4       | Paste    | Paste Blk  |
| 5       | Undo     | Undo       |
| 6       | Quant    | Quantize   |
| 7       | Swing    | Swing      |
| 8       | Exit     | Leave Menu |

### 30.262.3 Sequencer Data Layout

- **Grid**:  
  - 2D array: tracks (vertical), steps (horizontal).
  - Each cell: note, velocity, duration, channel, CC.
- **Pattern**:  
  - Header (length, tempo, swing), grid data, pointer to next.
- **Song**:  
  - List of patterns, order, repeats, transitions.

---