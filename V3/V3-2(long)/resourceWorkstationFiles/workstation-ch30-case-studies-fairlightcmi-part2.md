# Chapter 30: Case Studies – Fairlight CMI (Complete Deep-Dive)
## Part 2: Operating System, UI, Page-R, Software, and Retro-Engineering

---

## Table of Contents

- 30.410 Fairlight Operating System: Kernel, Task Model, and File System
  - 30.410.1 OS Architecture: Host/Terminal Split, Interrupts, Task Scheduling
  - 30.410.2 File System: Directory, Patch/Sample/Sequence Storage, Disk Abstraction
  - 30.410.3 Disk and Tape I/O: Controller, DMA, Error Handling
  - 30.410.4 Boot Sequence, Error Handling, and Diagnostics
- 30.411 User Interface: Lightpen, CRT, Page System, Parameter Editing
  - 30.411.1 Lightpen Hardware, Scan Logic, and Event Buffer
  - 30.411.2 CRT Raster, Graphics, and Custom Drawing Primitives
  - 30.411.3 Page System: Synthesis, Sampling, Sequencer (Page-R), Disk, Patch, System
  - 30.411.4 Parameter Editing: Lightpen, Keyboard, and Panel
- 30.412 Sequencer and Event Engine: Page-R Data Model, Timing, and Playback
  - 30.412.1 Page-R Data Structures: Grid, Track, Step, Pattern
  - 30.412.2 Real-Time Engine: Scheduling, Quantization, Polyphony
  - 30.412.3 Synchronization: Internal Clock, Tape Sync, MIDI Sync
  - 30.412.4 Editing Features: Step/Edit Mode, Block Operations, Undo
- 30.413 MIDI and External Control: Hardware, Parsing, Mapping, Macro
  - 30.413.1 MIDI Hardware: UART, Optoisolation, Buffering
  - 30.413.2 MIDI Parsing: Channel, Note, Velocity, Macro Mapping
  - 30.413.3 System Exclusive, Patch Dump/Load, Automation
- 30.414 Example C Code: File I/O, Page System, Sequencer, MIDI Logic
  - 30.414.1 File System Handler, Patch Load/Save, Disk Abstraction
  - 30.414.2 CRT Buffer, Lightpen Scan, and Page/Parameter Model
  - 30.414.3 Page-R Grid/Event Model and Playback
  - 30.414.4 MIDI Parser, Channel/Voice Assignment, Macro Handler
  - 30.414.5 OS Task/Interrupt Skeleton
- 30.415 Appendices: File System Map, Page/Parameter Table, Page-R Data Layout

---

## 30.410 Fairlight Operating System: Kernel, Task Model, and File System

### 30.410.1 OS Architecture: Host/Terminal Split, Interrupts, Task Scheduling

- **Host/Terminal Split**:
  - Host CPU (6809/68000) handles disk, voice cards, sequencer, and MIDI.
  - CRT terminal (graphics board) manages display; lightpen events are routed to CPU.
- **Task Model**:
  - Cooperative multitasking, prioritized event loop, real-time interrupts for audio tick, sequencer, lightpen, disk, MIDI.
  - Interrupts: Timer, Disk DMA, Lightpen, Keyboard/Panel, Error.
- **Scheduling**:
  - Audio/voice update and sequencer have highest priority; disk and UI tasks are polled or event-driven.

### 30.410.2 File System: Directory, Patch/Sample/Sequence Storage, Disk Abstraction

- **File System**:
  - Flat or shallow directory: /patch, /sample, /sequence, /system.
  - Metadata: name, type, length, date, version, lock.
  - Types: Patch (.PTC), Sample (.SAM), Sequence (.SEQ), System (.SYS).
- **Block Size**:
  - 256–1024 bytes per block; files chained via FAT or equivalent.
- **Disk Abstraction**:
  - Abstraction layer for floppy (WD1772), hard disk (SASI/SCSI), and tape.

### 30.410.3 Disk and Tape I/O: Controller, DMA, Error Handling

- **Disk Controller**:
  - WD1772/SCSI or custom; DMA, interrupt-driven.
  - Multi-sector/block transfer, bad sector remapping.
- **Tape I/O**:
  - Serial/parallel tape interface, block transfer, error correction.
- **Error Handling**:
  - CRC, retry, remap; error codes on CRT, log to system buffer.

### 30.410.4 Boot Sequence, Error Handling, and Diagnostics

- **Boot**:
  - ROM POST, RAM/disk/voice card check, CRT/lightpen test.
  - Loads system and user settings, displays status on CRT.
- **Diagnostics**:
  - Panel or menu-driven: voice card test, lightpen calibration, disk/tape verify.

---

## 30.411 User Interface: Lightpen, CRT, Page System, Parameter Editing

### 30.411.1 Lightpen Hardware, Scan Logic, and Event Buffer

- **Lightpen**:
  - Photodiode detects CRT beam, outputs X/Y, interrupt or polled.
  - Calibration routine aligns X/Y to CRT raster.
- **Scan Logic**:
  - CRT controller sends raster position to CPU; events queued with timestamp and screen location.
- **Event Buffer**:
  - Lightpen events placed in ring buffer, merged with keyboard/panel events for UI dispatch.

### 30.411.2 CRT Raster, Graphics, and Custom Drawing Primitives

- **CRT Graphics**:
  - 512x256–640x400 monochrome or color; bitmap or character cell.
  - Drawing primitives: lines, rectangles, text, waveform/envelope display.
- **Display Buffer**:
  - Double-buffered for flicker-free updates; custom control codes for invert/blink/highlight.
- **Waveform/Envelope**:
  - Real-time drawing/editing of samples, envelopes, and Page-R grid.

### 30.411.3 Page System: Synthesis, Sampling, Sequencer (Page-R), Disk, Patch, System

- **Pages**:
  - Page-2: Synthesis – voice, envelope, parameter control.
  - Page-4: Sampling – waveform editing, truncation, loop.
  - Page-5: Disk – file management, load/save, format.
  - Page-6: Patch – keymaps, splits, velocity.
  - Page-7: System – config, test, calibration, tuning.
  - Page-R: Sequencer grid, event editing, song assembly.
- **Page Navigation**:
  - Lightpen, keyboard hotkeys, panel switches; real-time contextual help.

### 30.411.4 Parameter Editing: Lightpen, Keyboard, and Panel

- **Editing**:
  - Lightpen direct manipulation (drag, select, draw).
  - Keyboard numeric entry, arrow keys, tabbing.
  - Panel: transport, patch, and system functions.

---

## 30.412 Sequencer and Event Engine: Page-R Data Model, Timing, and Playback

### 30.412.1 Page-R Data Structures: Grid, Track, Step, Pattern

- **Grid Model**:
  - Steps (columns) × tracks (rows), typically 32x8; each cell has note, velocity, duration, gate.
- **Pattern**:
  - Array of steps/tracks; can be chained with repeats, jump/skip, and fills.
- **Song**:
  - List of patterns, transitions, tempo changes.

### 30.412.2 Real-Time Engine: Scheduling, Quantization, Polyphony

- **Timing**:
  - Timer interrupt sets sequencer tick, PPQN adjustable.
  - Quantization and swing/humanize per pattern or track.
- **Voice Scheduling**:
  - Allocates notes to available voices; supports real-time layering/splitting, advanced voice stealing.

### 30.412.3 Synchronization: Internal Clock, Tape Sync, MIDI Sync

- **Sync**:
  - Internal clock, tape sync (stripe), MIDI clock in/out.
  - Chase lock for tape/MIDI, resync on tempo change.

### 30.412.4 Editing Features: Step/Edit Mode, Block Operations, Undo

- **Editing**:
  - Step entry, real-time recording, block operations (copy, erase, insert, transpose).
  - Undo/redo stack, pattern variation, event transformation.

---

## 30.413 MIDI and External Control: Hardware, Parsing, Mapping, Macro

### 30.413.1 MIDI Hardware: UART, Optoisolation, Buffering

- **UART**: 6850/8251, optoisolated input, buffered output/thru.
- **FIFO**: 64–256 bytes, overflow detection.
- **Merge**: Hardware/software merge of panel, sequencer, MIDI events.

### 30.413.2 MIDI Parsing: Channel, Note, Velocity, Macro Mapping

- **Parser**:
  - Running status, system real-time, Sysex.
  - Filters: channel, note, velocity, CC, program, macro.
- **Mapping**:
  - User-assignable channel to patch/voice bank; split/layer, macro triggers.

### 30.413.3 System Exclusive, Patch Dump/Load, Automation

- **Sysex**:
  - Bulk dump/load, patch/sequence edit, diagnostics.
- **Automation**:
  - Sequencer and MIDI can automate any assignable parameter.

---

## 30.414 Example C Code: File I/O, Page System, Sequencer, MIDI Logic

### 30.414.1 File System Handler, Patch Load/Save, Disk Abstraction

```c
typedef struct {
    char name[16];
    uint8_t type;
    uint32_t start_block;
    uint32_t length;
    uint32_t mod_date;
} fs_entry_t;

fs_entry_t fs_dir[128];

uint8_t disk_blocks[8192][1024];

int find_patch(const char* name) {
    for (int i = 0; i < 128; ++i)
        if (strcmp(fs_dir[i].name, name) == 0) return i;
    return -1;
}

void load_patch(const char* name, uint8_t* buf, uint32_t maxlen) {
    int idx = find_patch(name);
    if (idx < 0) return;
    uint32_t block = fs_dir[idx].start_block;
    uint32_t rem = fs_dir[idx].length;
    uint32_t pos = 0;
    while (rem && block) {
        memcpy(buf + pos, disk_blocks[block], 1024);
        pos += 1024;
        block = get_next_block(block);
        rem -= 1024;
    }
}
```

### 30.414.2 CRT Buffer, Lightpen Scan, and Page/Parameter Model

```c
#define CRT_ROWS 32
#define CRT_COLS 64

char crt_buf[CRT_ROWS][CRT_COLS+1];

void crt_update(int row, int col, const char* text) {
    strncpy(&crt_buf[row][col], text, CRT_COLS-col);
    crt_buf[row][CRT_COLS] = '\0';
    update_crt_hw(row);
}

// Lightpen scan buffer
typedef struct {
    int x, y;
    int action;
} lp_event_t;

lp_event_t lightpen_events[16];
int lp_head = 0, lp_tail = 0;

void queue_lp_event(int x, int y, int action) {
    lightpen_events[lp_head].x = x;
    lightpen_events[lp_head].y = y;
    lightpen_events[lp_head].action = action;
    lp_head = (lp_head + 1) % 16;
}
```

### 30.414.3 Page-R Grid/Event Model and Playback

```c
#define PAGE_R_STEPS 32
#define PAGE_R_TRACKS 8

typedef struct {
    uint8_t note;
    uint8_t velocity;
    uint8_t duration;
    uint8_t gate;
} page_r_step_t;

page_r_step_t page_r_grid[PAGE_R_TRACKS][PAGE_R_STEPS];

void play_page_r(int pattern) {
    for (int s = 0; s < PAGE_R_STEPS; ++s) {
        for (int t = 0; t < PAGE_R_TRACKS; ++t) {
            page_r_step_t* st = &page_r_grid[t][s];
            if (st->gate) assign_voice(/*map note to sample/voice params*/);
        }
        wait_ms(100); // Step time
    }
}
```

### 30.414.4 MIDI Parser, Channel/Voice Assignment, Macro Handler

```c
#define MIDI_BUF_SIZE 128
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
    // Handle CC, PC, macro triggers...
}
```

### 30.414.5 OS Task/Interrupt Skeleton

```c
void timer_isr() {
    // Audio tick, sequencer, voice update
}
void disk_isr() {
    // Disk DMA complete, error, retry
}
void crt_lp_isr() {
    // Lightpen event, queue to buffer
}
void midi_rx_isr();
void main_loop() {
    while (1) {
        // Poll event queue
        // Dispatch UI, file I/O, sequencer, MIDI, voice tasks
    }
}
```

---

## 30.415 Appendices: File System Map, Page/Parameter Table, Page-R Data Layout

### 30.415.1 File System Map (Excerpt)

| Path      | Type   | Block Size | Comment         |
|-----------|--------|------------|-----------------|
| /patch    | .PTC   | 1024       | Synth patches   |
| /sample   | .SAM   | 1024       | Audio samples   |
| /sequence | .SEQ   | 1024       | Page-R seq      |
| /system   | .SYS   | 1024       | System files    |

### 30.415.2 Page/Parameter Table

| Page   | Function      | Key Params                  |
|--------|---------------|----------------------------|
| 2      | Synthesis     | Sample, envelope, tuning   |
| 4      | Sampling      | Waveform, loop, trim       |
| 5      | Disk          | Load, save, format         |
| 6      | Patch         | Keymap, split, velocity    |
| 7      | System        | Config, test, calibration  |
| R      | Seq (Page-R)  | Grid, tempo, pattern       |

### 30.415.3 Page-R Data Layout

- **Track/Event**:  
  - Step: note, velocity, duration, gate.
- **Pattern**:  
  - Header (length, quantize, swing), track data.
- **Song**:  
  - List of patterns, order, repeats, transitions.

---