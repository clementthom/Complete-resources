# Chapter 30: Case Studies – Fairlight CMI (Complete Deep-Dive)
## Part 2: OS, User Interface, Sequencer (Page R), and Reverse Engineering

---

## Table of Contents

- 30.237 Operating System: Structure, Scheduling, and File System
  - 30.237.1 OS Architecture: Kernel, Interrupts, and Task Scheduler
  - 30.237.2 File System: Directory Structure, Sample/Sequence Storage
  - 30.237.3 Disk I/O: Floppy/Hard Disk, FDC/SDC Integration
  - 30.237.4 OS Boot Process, Error Handling, and Recovery
- 30.238 User Interface: CRT, Light Pen, Softkeys, and Page R
  - 30.238.1 CRT Graphics Engine: Timing, Framebuffer, and Video RAM
  - 30.238.2 Light Pen Decoding: Hardware, Timing, and Event Mapping
  - 30.238.3 Softkey Panel: Matrix, Multiplexing, and Dynamic Assignments
  - 30.238.4 Page R Sequencer: Visual Paradigm, Grid Engine, and Editing
- 30.239 Sequencing Engine: Event Model, Playback, and Synchronization
  - 30.239.1 Event Storage: Track Data Structures, Step/Pattern Encoding
  - 30.239.2 Playback Engine: Timing, Quantization, and Voice Assignment
  - 30.239.3 Synchronization: Internal Clock, Tape Sync, MIDI Sync
  - 30.239.4 Editing Features: Cut, Paste, Repeat, Transform, Undo
- 30.240 Example C Code: File I/O, Light Pen, Sequencer Grid, and Softkey Logic
  - 30.240.1 File System Handler and Disk Block Management
  - 30.240.2 Light Pen Position, Debounce, and Event Queue
  - 30.240.3 Page R Sequencer Data Structures and State Machine
  - 30.240.4 Softkey Assignment Table and UI Event Dispatch
- 30.241 Appendices: OS Memory Map, Page R Data Layout, UI/Softkey Map

---

## 30.237 Operating System: Structure, Scheduling, and File System

### 30.237.1 OS Architecture: Kernel, Interrupts, and Task Scheduler

- **Kernel Model**:  
  - Cooperative multitasking in Series I/II; preemptive (Series III, 68000).
  - Interrupt-driven for timer, disk, light pen, keyboard, channel card events.
  - Priority event queue: UI (light pen, keys), audio (sample/voice), storage, background tasks.
- **Task Scheduler**:  
  - Round robin for background; fast event dispatch for UI/audio.
  - Timer tick (e.g., 1ms) drives sequencer, UI updates, and envelope/voice stepping.

### 30.237.2 File System: Directory Structure, Sample/Sequence Storage

- **File System**:  
  - Simple flat file model (Series I/II); hierarchical in Series III.
  - Directory table in reserved disk sector; tracks file name, type, start block, length, metadata (sample rate, date).
  - File types: Sample (.VC), Sequence (.SEQ), Patch (.PTC), Backup (.BAK), System (.SYS).
- **Block Size**:  
  - 256–1024 bytes per block; file allocation table (FAT)-like model.
- **Sample Storage**:  
  - Large samples stored as chained blocks; directory stores pointer to first, length, and chain info.

### 30.237.3 Disk I/O: Floppy/Hard Disk, FDC/SDC Integration

- **Floppy**:  
  - FDC (WD1771, WD1793): supports single/double density, 77 tracks, 26–128 sectors.
  - OS issues read/write/seek; FDC raises IRQ on completion/error.
- **Hard Disk**:  
  - SCSI or MFM controller (Series III); BIOS handles sector translation, bad block mapping.
- **Error Handling**:  
  - Retries on CRC failure, bad block remapping, user prompts for disk change.

### 30.237.4 OS Boot Process, Error Handling, and Recovery

- **Boot Process**:  
  - ROM executes POST, memory test, initializes bus and cards.
  - Loads OS loader from floppy/hard disk, hands control to disk OS.
  - Loads patches, sample sets as needed.
- **Error Handling**:  
  - On boot error: display code on CRT, blink panel LEDs, log to error buffer.
  - User can view error log, run diagnostics, or boot from alternate media.

---

## 30.238 User Interface: CRT, Light Pen, Softkeys, and Page R

### 30.238.1 CRT Graphics Engine: Timing, Framebuffer, and Video RAM

- **Graphics Engine**:  
  - Custom graphics board, bitmapped framebuffer (640x256 or 512x256).
  - Dual-port VRAM: CPU can draw while CRT scans.
  - Hardware cursor, sprite overlay for light pen feedback.
- **Timing**:  
  - Horizontal and vertical sync from master clock; CRT controller generates pixel/line addresses.
  - Video RAM: 16–32KB organized as planar or packed pixels.

### 30.238.2 Light Pen Decoding: Hardware, Timing, and Event Mapping

- **Light Pen Hardware**:  
  - Stylus contains photodiode; pulse generated when CRT beam passes pen.
  - Pulse triggers timing circuit, latches X/Y counter from CRT controller.
- **Event Mapping**:  
  - Pen events generate interrupt or flag; polled by OS.
  - OS debounces pen down/up, maps to UI actions (button, waveform, sequencer grid).

### 30.238.3 Softkey Panel: Matrix, Multiplexing, and Dynamic Assignments

- **Panel**:  
  - 8–24 softkeys, multiplexed scan via 74LS138/74HC595 drivers.
  - LEDs per key for status/feedback.
- **Dynamic Assignment**:  
  - OS maps softkeys to functions based on current UI “page.”
  - CRT overlay shows mnemonic or label for each key; mapping updated on page change.

### 30.238.4 Page R Sequencer: Visual Paradigm, Grid Engine, and Editing

- **Grid Engine**:  
  - 8–32 tracks vertically, time steps horizontally; each cell represents note on/off, velocity, or controller.
  - User draws, erases, or edits notes with light pen or softkeys.
- **Visual Editing**:  
  - Copy/paste, repeat, quantize, transpose, draw velocity/envelope curves.
  - Playhead cursor moves in real time; visual feedback of playback position and active steps.
- **Page R Data Model**:  
  - Each pattern is a 2D array (track x step), stored as bitfields or run-length encoding.

---

## 30.239 Sequencing Engine: Event Model, Playback, and Synchronization

### 30.239.1 Event Storage: Track Data Structures, Step/Pattern Encoding

- **Pattern Model**:  
  - Patterns are blocks (e.g., 16/32/64 steps), each track has note/velocity data per step.
  - Patterns chained into songs; events stored as {track, step, note, velocity, duration}.
- **Encoding**:  
  - Step data: packed bits for efficiency; optional velocity/CC per step (Series III).
  - Patterns stored as linked list; supports repeats, variations, and song structure.
- **RAM Layout**:  
  - Sequencer RAM holds patterns, event queue, playhead, undo buffer.

### 30.239.2 Playback Engine: Timing, Quantization, and Voice Assignment

- **Timing**:  
  - Timer interrupt drives playhead; each step time = (60,000 ms / BPM) / steps per beat.
  - Supports swing/shuffle, real-time quantization.
- **Voice Assignment**:  
  - Scheduler maps track to channel card (voice); dynamic reallocation for polyphony.
  - Voice stealing when all channels busy; oldest/lowest-velocity note replaced.
- **Real-Time Features**:  
  - Play, stop, pause, loop, step, pattern jump, and live edit during playback.

### 30.239.3 Synchronization: Internal Clock, Tape Sync, MIDI Sync

- **Internal**:  
  - Master timer sets global BPM; sequencer and audio clocked from same source.
- **Tape Sync**:  
  - FSK or SMPTE stripe; reads tape, adjusts clock for drift, triggers pattern advances.
- **MIDI Sync**:  
  - MIDI clock in/out; sends/receives start/stop/continue, song position pointer.
  - Optional MTC (Series III), for DAW/video sync.

### 30.239.4 Editing Features: Cut, Paste, Repeat, Transform, Undo

- **Editing**:  
  - Select block (track x steps), cut/copy/paste, repeat, transpose, invert, randomize velocity.
  - Undo/redo buffer for up to N operations.
- **Transform**:  
  - Quantize, swing, humanize, scale time, compress/expand pattern length.

---

## 30.240 Example C Code: File I/O, Light Pen, Sequencer Grid, and Softkey Logic

### 30.240.1 File System Handler and Disk Block Management

```c
#define BLOCK_SIZE 512
#define DIR_SIZE   64

typedef struct {
    char name[12];
    uint8_t type;
    uint16_t start_block;
    uint16_t length;
    uint32_t mod_date;
} dir_entry_t;

dir_entry_t directory[DIR_SIZE];

uint8_t disk_blocks[4096][BLOCK_SIZE];

int find_file(const char* fname) {
    for (int i = 0; i < DIR_SIZE; ++i)
        if (strcmp(directory[i].name, fname) == 0) return i;
    return -1;
}

void read_file(const char* fname, uint8_t* buf, uint16_t maxlen) {
    int idx = find_file(fname);
    if (idx < 0) return;
    uint16_t block = directory[idx].start_block;
    uint16_t rem = directory[idx].length;
    uint16_t pos = 0;
    while (rem && block) {
        memcpy(buf + pos, disk_blocks[block], BLOCK_SIZE);
        pos += BLOCK_SIZE;
        block = get_next_block(block); // from FAT
        rem -= BLOCK_SIZE;
    }
}
```

### 30.240.2 Light Pen Position, Debounce, and Event Queue

```c
typedef struct {
    uint16_t x, y;
    uint8_t  pen_down;
} pen_evt_t;

pen_evt_t pen_evt_queue[16];
uint8_t pen_evt_head = 0, pen_evt_tail = 0;

void poll_light_pen() {
    if (pen_irq_flag()) {
        pen_evt_t evt;
        evt.x = read_pen_x();
        evt.y = read_pen_y();
        evt.pen_down = is_pen_down();
        pen_evt_queue[pen_evt_head++] = evt;
        if (pen_evt_head >= 16) pen_evt_head = 0;
    }
}

pen_evt_t get_next_pen_evt() {
    pen_evt_t evt = pen_evt_queue[pen_evt_tail++];
    if (pen_evt_tail >= 16) pen_evt_tail = 0;
    return evt;
}
```

### 30.240.3 Page R Sequencer Data Structures and State Machine

```c
#define TRACKS 8
#define STEPS  64

typedef struct {
    uint8_t note;     // MIDI note or 0 for off
    uint8_t velocity; // 0–127
} step_t;

step_t page_r_grid[TRACKS][STEPS];

typedef struct {
    uint8_t playing;
    uint8_t playhead;
    uint16_t bpm;
} seq_state_t;

seq_state_t seq_state = {0, 0, 120};

void tick_sequencer() {
    if (!seq_state.playing) return;
    for (int t = 0; t < TRACKS; ++t)
        if (page_r_grid[t][seq_state.playhead].note)
            trigger_note(t, page_r_grid[t][seq_state.playhead].note,
                            page_r_grid[t][seq_state.playhead].velocity);
    seq_state.playhead = (seq_state.playhead + 1) % STEPS;
}

void edit_note(int track, int step, uint8_t note, uint8_t vel) {
    page_r_grid[track][step].note = note;
    page_r_grid[track][step].velocity = vel;
}
```

### 30.240.4 Softkey Assignment Table and UI Event Dispatch

```c
#define SOFTKEYS 16

typedef struct {
    char label[8];
    void (*handler)();
} softkey_t;

softkey_t softkey_map[SOFTKEYS];

void set_softkey(int idx, const char* label, void (*handler)()) {
    strncpy(softkey_map[idx].label, label, 7);
    softkey_map[idx].handler = handler;
}

void handle_softkey_press(int idx) {
    if (softkey_map[idx].handler)
        softkey_map[idx].handler();
}

void update_softkeys_for_page(const char* page) {
    // Example: assign keys for Page R
    if (strcmp(page, "Page R") == 0) {
        set_softkey(0, "Play", seq_play);
        set_softkey(1, "Stop", seq_stop);
        set_softkey(2, "Copy", seq_copy);
        set_softkey(3, "Paste", seq_paste);
        // etc...
    }
}
```

---

## 30.241 Appendices: OS Memory Map, Page R Data Layout, UI/Softkey Map

### 30.241.1 OS Memory Map (Series II Example)

| Region      | Start   | End     | Function        |
|-------------|---------|---------|-----------------|
| OS ROM      | 0x0000  | 0x1FFF  | Boot/monitor    |
| OS RAM      | 0x2000  | 0x3FFF  | Variables, stack|
| Sample RAM  | 0x4000  | 0xFFFF  | Channel/sample  |
| Channel Reg | 0x10000 | ...     | Playback ctrl   |

### 30.241.2 Page R Data Layout

- **Grid**:  
  - 2D array: tracks (vertical), steps (horizontal).
  - Each cell: note, velocity; optional controller/CC.
- **Pattern**:  
  - Header (length, tempo, swing), grid data, pointer to next.
- **Song**:  
  - List of patterns, order, repeats.

### 30.241.3 UI/Softkey Map (Page R Example)

| Softkey | Label    | Function    |
|---------|----------|------------|
| 1       | Play     | Start Seq  |
| 2       | Stop     | Stop Seq   |
| 3       | Copy     | Copy Block |
| 4       | Paste    | Paste Blk  |
| 5       | Undo     | Undo       |
| 6       | Quant    | Quantize   |
| 7       | Swing    | Swing      |
| 8       | Exit     | Leave Page |

---