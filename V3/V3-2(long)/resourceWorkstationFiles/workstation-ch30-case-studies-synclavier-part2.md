# Chapter 30: Case Studies – Synclavier (Complete Deep-Dive)
## Part 2: Operating System, Terminal UI, Sequencing, File System, MIDI, and Software Retro-Engineering

---

## Table of Contents

- 30.310 Synclavier Operating System: Kernel, Task Model, and Scheduling
  - 30.310.1 OS Architecture: Host/Terminal Split, Interrupts, Task Scheduling
  - 30.310.2 File System: Directory, Patch/Sequence/Bank Storage, Disk Abstraction
  - 30.310.3 Disk and Direct-to-Disk I/O: Controller, DMA, and Error Handling
  - 30.310.4 Boot Sequence, Error Handling, and Recovery
- 30.311 Terminal and User Interface: VT100/Plasma, Softkey Model, Page System
  - 30.311.1 Terminal Hardware: VT100, Plasma, Graphics, and Keyboard Matrix
  - 30.311.2 UI Model: Softkey Tables, Menu Pages, Parameter Editing
  - 30.311.3 Custom Terminal Control Codes and Display Buffer
  - 30.311.4 Remote and Networked Control: Multiple Terminals and Workstations
- 30.312 Sequencer and Event Engine: Data Model, Timing, and Playback
  - 30.312.1 Event Storage: Song, Track, Pattern, and Step Encoding
  - 30.312.2 Real-Time Engine: Scheduling, Quantization, and Polyphony
  - 30.312.3 Synchronization: Internal Clock, SMPTE, MIDI Sync, and Chase Lock
  - 30.312.4 Editing Features: Step/Edit Mode, Cut/Copy/Paste, Variations, Undo
- 30.313 MIDI and External Control: Hardware, Parsing, Mapping, and Advanced Features
  - 30.313.1 MIDI Hardware: UART, Optoisolation, and Buffering
  - 30.313.2 MIDI Software: Parsing, Routing, Multi-Timbral Mapping
  - 30.313.3 System Exclusive, Macro Assignment, and Automation
- 30.314 Example C Code: File I/O, Terminal Menu, Sequencer, and MIDI Logic
  - 30.314.1 File System Handler, Patch Load/Save, and Disk Abstraction
  - 30.314.2 Terminal Display Buffer and Softkey Logic
  - 30.314.3 Sequencer Track/Event Model and Playback
  - 30.314.4 MIDI Parser, Channel/Voice Assignment, Macro Handler
  - 30.314.5 OS Task/Interrupt Skeleton
- 30.315 Appendices: File System Map, Terminal/Softkey Map, Sequencer/Event Data Layout

---

## 30.310 Synclavier Operating System: Kernel, Task Model, and Scheduling

### 30.310.1 OS Architecture: Host/Terminal Split, Interrupts, Task Scheduling

- **Host/Terminal Split**:  
  - Host CPU (Nova/68k) manages disk, DSP, file system, sequencing, and MIDI.
  - Terminal (VT100/plasma) runs UI, receives commands/events from host.
- **Task Model**:  
  - Cooperative multitasking, with prioritized event loop and real-time interrupt handlers.
  - Interrupts: Timer (voice ticks), Disk/DMA, Terminal RX, MIDI RX, Panel/Key, Error.
- **Scheduling**:  
  - Audio/DSP and sequencer have highest priority; file I/O, UI, and MIDI polled or serviced as events.

### 30.310.2 File System: Directory, Patch/Sequence/Bank Storage, Disk Abstraction

- **File System Structure**:  
  - Hierarchical directory: /patches, /sequences, /samples, /banks, /sys, /dtd (direct-to-disk).
  - File metadata: name, type, length, date, version, attributes (read-only, locked).
  - Types: Patch (.PAT), Sample (.SMP), Sequence (.SEQ), Bank (.BNK), System (.SYS), Direct-to-Disk (.DTD).
- **Block Size**:  
  - 512–4096 bytes per block; large files chained via FAT or custom table.
- **Disk Abstraction**:  
  - Disk/volume driver layer abstracts SCSI, MFM, floppy, and MO media.

### 30.310.3 Disk and Direct-to-Disk I/O: Controller, DMA, and Error Handling

- **Disk Controller**:  
  - SCSI or custom (DMA, IRQ-driven), supports multi-sector transfer, bad block remapping.
- **Direct-to-Disk I/O**:  
  - Real-time DMA, sector interleaving for glitchless audio, error recovery and buffer underrun protection.
- **Error Handling**:  
  - CRC, sector retry, remap, user-visible error codes, event log.

### 30.310.4 Boot Sequence, Error Handling, and Recovery

- **Boot**:  
  - ROM POST, RAM/disk check, DSP/voice card test, host-terminal handshake.
  - OS and user settings loaded from disk; terminal displays status.
- **Recovery/Diagnostics**:  
  - Diagnostics menu, disk repair, patch/sequence recovery tools, system log.

---

## 30.311 Terminal and User Interface: VT100/Plasma, Softkey Model, Page System

### 30.311.1 Terminal Hardware: VT100, Plasma, Graphics, and Keyboard Matrix

- **Terminal Types**:  
  - Early: VT100 ASCII, 80x24, monochrome; Later: custom plasma panel, color, softkey grid, graphics.
- **Keyboard**:  
  - Proprietary scan matrix, supports QWERTY, function keys, and numeric pad.
  - Key events polled by terminal CPU, sent by serial or parallel to host.

### 30.311.2 UI Model: Softkey Tables, Menu Pages, Parameter Editing

- **UI Model**:  
  - Softkey array (typically 16–32 keys), mapped to dynamic menu functions.
  - Menu pages: Synthesis, Sampling, Sequencer, Disk, Patch, System/Service.
  - Each page has parameter table, hotkey assignments, macro/shortcut support.
- **Parameter Editing**:  
  - Arrow/rotary encoders, numeric pad, direct key entry, softkey selects.
  - Real-time feedback: all changes reflected instantly in sound/sequence.

### 30.311.3 Custom Terminal Control Codes and Display Buffer

- **Display Buffer**:  
  - Double-buffered for flicker-free updates, mapped to ASCII or custom graphics RAM.
  - Custom control codes: cursor move, invert, blink, draw waveform/envelope.
  - Fast redraw for parameter change, softkey, and sequencer/grid views.

### 30.311.4 Remote and Networked Control: Multiple Terminals and Workstations

- **Multi-Terminal**:  
  - Multiple terminals can be connected; host arbitrates I/O and focus.
- **Remote/Network**:  
  - Ethernet, RS-422/232, or proprietary bus for remote control, librarian, and backup.

---

## 30.312 Sequencer and Event Engine: Data Model, Timing, and Playback

### 30.312.1 Event Storage: Song, Track, Pattern, and Step Encoding

- **Data Model**:  
  - Song: List of patterns; Pattern: set of tracks; Track: sequence of events (note, velocity, duration, channel, program, CC, macro).
- **Event Encoding**:  
  - Each event: timestamp, type, data1, data2, channel, link to next.
  - Step data packed for compact storage.

### 30.312.2 Real-Time Engine: Scheduling, Quantization, and Polyphony

- **Timing Engine**:  
  - Timer interrupt sets sequencer tick (PPQN adjustable, typically 96–384).
  - Quantization: adjustable, non-destructive, with swing/humanize.
- **Voice Scheduling**:  
  - Allocates events to available DSP voices, supports layering, splits, and advanced voice stealing.

### 30.312.3 Synchronization: Internal Clock, SMPTE, MIDI Sync, and Chase Lock

- **Sync Sources**:  
  - Internal (master), SMPTE (LTC/VITC), MIDI Clock, FSK, tape sync.
- **Chase Lock**:  
  - Host tracks incoming SMPTE; resynchronizes sequencer and audio playback on-the-fly.

### 30.312.4 Editing Features: Step/Edit Mode, Cut/Copy/Paste, Variations, Undo

- **Editing**:  
  - Step and real-time entry, block select, cut/copy/paste, event insert/delete.
  - Undo/redo stack, pattern variation, event transform (quantize, transpose, scale velocity).

---

## 30.313 MIDI and External Control: Hardware, Parsing, Mapping, and Advanced Features

### 30.313.1 MIDI Hardware: UART, Optoisolation, and Buffering

- **UART**: 6850/8251/16550, optoisolated input, buffered output/thru.
- **FIFO**: 128–1024 bytes, overflow/underrun detection.
- **MIDI Merge**: Hardware/software merge with panel, sequencer, and terminal events.

### 30.313.2 MIDI Software: Parsing, Routing, Multi-Timbral Mapping

- **Parser**:  
  - Handles running status, system realtime, and Sysex.
  - Filters by channel, note, velocity, CC, program, macro trigger.
- **Routing**:  
  - User-assignable: MIDI channel to internal voice/patch/bank, split/layer, macro mapping.
- **Multi-Timbral**:  
  - Each MIDI channel can be mapped to different patch, DSP card, and output.

### 30.313.3 System Exclusive, Macro Assignment, and Automation

- **Sysex**:  
  - Patch/sequence dump/load, parameter edit, diagnostics, macro recall.
- **Macros**:  
  - Assign MIDI CC/PC/aftertouch to parameter sets, with user-defined depth/scaling.
- **Automation**:  
  - Sequencer and external MIDI can automate any assignable parameter, with interpolation and tempo sync.

---

## 30.314 Example C Code: File I/O, Terminal Menu, Sequencer, and MIDI Logic

### 30.314.1 File System Handler, Patch Load/Save, and Disk Abstraction

```c
typedef struct {
    char name[16];
    uint8_t type;
    uint32_t start_block;
    uint32_t length;
    uint32_t mod_date;
} fs_entry_t;

fs_entry_t fs_dir[256];

uint8_t disk_blocks[32768][1024];

int find_patch(const char* name) {
    for (int i = 0; i < 256; ++i)
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

### 30.314.2 Terminal Display Buffer and Softkey Logic

```c
#define SOFTKEYS 32
typedef struct {
    char label[16];
    void (*handler)();
} softkey_t;
softkey_t softkey_map[SOFTKEYS];

#define TERM_ROWS 24
#define TERM_COLS 80

char terminal_buf[TERM_ROWS][TERM_COLS+1];

void terminal_update(int row, int col, const char* text) {
    strncpy(&terminal_buf[row][col], text, TERM_COLS-col);
    terminal_buf[row][TERM_COLS] = '\0';
    update_terminal_hw(row);
}

void show_menu(const char* menu[], int n) {
    for (int i = 0; i < n && i < TERM_ROWS; ++i)
        terminal_update(i, 0, menu[i]);
}

void softkey_press(int idx) {
    if (softkey_map[idx].handler)
        softkey_map[idx].handler();
}
```

### 30.314.3 Sequencer Track/Event Model and Playback

```c
#define TRACKS 32
#define STEPS  256

typedef struct {
    uint32_t time;
    uint8_t type;
    uint8_t data1, data2;
    uint8_t channel;
} seq_event_t;

typedef struct {
    seq_event_t events[STEPS];
    uint16_t length;
} seq_track_t;

seq_track_t seq_tracks[TRACKS];

void play_tracks() {
    for (int t = 0; t < TRACKS; ++t)
        for (int s = 0; s < seq_tracks[t].length; ++s)
            handle_seq_event(&seq_tracks[t].events[s]);
}
```

### 30.314.4 MIDI Parser, Channel/Voice Assignment, Macro Handler

```c
#define MIDI_BUF_SIZE 512
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
    // Handle CC, PC, aftertouch, macro triggers...
}

void assign_voice(uint8_t channel, uint8_t note, uint8_t vel) {
    // Map channel to patch, assign polyphonic voice
}
```

### 30.314.5 OS Task/Interrupt Skeleton

```c
void timer_isr() {
    // Audio tick, sequencer, LFO, envelope update
}
void disk_isr() {
    // Disk DMA complete, error, retry
}
void terminal_rx_isr() {
    // Terminal key/softkey event
}
void midi_rx_isr();
void main_loop() {
    while (1) {
        // Poll event queue
        // Dispatch UI, file I/O, sequencer, MIDI, DSP tasks
    }
}
```

---

## 30.315 Appendices: File System Map, Terminal/Softkey Map, Sequencer/Event Data Layout

### 30.315.1 File System Map (Excerpt)

| Path         | Type   | Block Size | Comment         |
|--------------|--------|------------|-----------------|
| /patches     | .PAT   | 1024       | Synth patches   |
| /samples     | .SMP   | 2048       | Audio samples   |
| /sequences   | .SEQ   | 1024       | MIDI/step seq   |
| /banks       | .BNK   | 2048       | Patch banks     |
| /dtd         | .DTD   | 4096       | Direct-to-disk  |
| /sys         | .SYS   | 1024       | System files    |

### 30.315.2 Terminal/Softkey Map

| Softkey | Label   | Function      |
|---------|---------|--------------|
| 1       | Play    | Start Seq    |
| 2       | Stop    | Stop Seq     |
| 3       | Edit    | Edit Event   |
| 4       | Save    | Save Patch   |
| 5       | Load    | Load Patch   |
| ...     | ...     | ...          |
| 32      | Macro   | User Macro   |

### 30.315.3 Sequencer/Event Data Layout

- **Track/Event**:  
  - Array of events: time, type, data1, data2, channel.
- **Pattern**:  
  - Header (length, quantize, swing), track data.
- **Song**:  
  - List of patterns, order, repeats, transitions.

---
