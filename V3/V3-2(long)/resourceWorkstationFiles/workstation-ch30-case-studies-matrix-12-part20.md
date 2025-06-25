# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 20: System Timing, Polyphony Scaling, External Control, and Total Recap

---

## Table of Contents

- 30.180 System Timing: Master Clock, Event Scheduling, and Jitter Analysis
  - 30.180.1 Master Clock Design: Crystal, Dividers, and Distribution
  - 30.180.2 Timing Wheel: Scheduling, Priority Queues, and Soft Timers
  - 30.180.3 Jitter Sources: Interrupts, Bus Contention, and Mitigation
  - 30.180.4 Benchmarking: Real-World Timing, Measurement, and Optimization
- 30.181 Polyphony Scaling: Multi-Matrix, Chaining, and Voice Expansion
  - 30.181.1 Hardware Limits: Original Design and Bus Load
  - 30.181.2 Multi-Unit Chaining: MIDI, Net, and Clock Sync
  - 30.181.3 Voice Expansion: Bus Arbitration, ID, and Auto-Detection
  - 30.181.4 Dynamic Polyphony Allocation: Load Balancing and Split Modes
- 30.182 External Control: Editors, Automation, and DAW Integration
  - 30.182.1 Sysex Editors: Patch Management, Parameter Morph, and Bulk Dump
  - 30.182.2 Automation: Real-Time CC, NRPN, and Macro Sync
  - 30.182.3 DAW Integration: Plugin, Web UI, and Live Feedback
  - 30.182.4 API/Protocol Extensions: For Community Firmware
- 30.183 Example C Code: Event Scheduler, Chained Polyphony, and External API
  - 30.183.1 Event Queue, Timer Wheel, and Soft Interrupts
  - 30.183.2 Polyphony Chaining, Voice Arbitration, and Message Passing
  - 30.183.3 Sysex/CC Automation, Real-Time API Handler, and Editor Hooks
  - 30.183.4 Command Parser, Error Reporting, and User Extensibility
- 30.184 Recap: System Integration, Key Learnings, and Forward Path
  - 30.184.1 Full System Block Diagram: From Key to Output
  - 30.184.2 Table: All Subsystems, Main ICs, and Pin/Bus Maps
  - 30.184.3 Maintenance, Upgrades, and Best Practices
  - 30.184.4 Where to Go Next: Open Firmware, Modern Clones, and Resources

---

## 30.180 System Timing: Master Clock, Event Scheduling, and Jitter Analysis

### 30.180.1 Master Clock Design: Crystal, Dividers, and Distribution

- **Crystal Source**:  
  - 12MHz quartz crystal, buffered by inverter chain (74HC04), distributed via star topology.
- **Frequency Dividers**:  
  - Synchronous counters (74HC393) divide master clock into 1MHz (CPU), 1kHz (panel/UI), and 31.25kHz (UART/MIDI).
- **Distribution**:  
  - Matched-length traces, series resistors for signal integrity.
  - Each domain (CPU, panel, MIDI, expansion) receives dedicated buffer.

### 30.180.2 Timing Wheel: Scheduling, Priority Queues, and Soft Timers

- **Timing Wheel**:  
  - Ring buffer of N slots, each slot contains list of events scheduled for that tick.
  - On each tick (e.g., 1ms), wheel advances, executes due events.
- **Priority Queues**:  
  - Critical events (matrix update, DAC refresh) get highest priority.
  - Lower-priority (LCD update, backup) scheduled in slack time.
- **Soft Timers**:  
  - Software timers for envelope/LFO, debounce, menu timeouts.

### 30.180.3 Jitter Sources: Interrupts, Bus Contention, and Mitigation

- **Interrupts**:  
  - Timer, UART/MIDI, panel, voice bus; poorly planned ISRs create jitter.
- **Bus Contention**:  
  - Shared data/address lines: bus arbitration logic prevents conflicts.
- **Mitigation**:  
  - Keep ISRs short, move work to main loop; buffer DAC updates.
  - Use DMA (on modern MCU) for high-precision tasks.

### 30.180.4 Benchmarking: Real-World Timing, Measurement, and Optimization

- **Measurement**:
  - Logic analyzer on DAC, panel, and MIDI lines; measure latency/jitter.
  - CPU cycle counters (where available) log event timing.
- **Optimization**:
  - Profile code to minimize update cycle; optimize matrix and DAC routines.
  - Track missed deadlines, adjust scheduling priorities.

---

## 30.181 Polyphony Scaling: Multi-Matrix, Chaining, and Voice Expansion

### 30.181.1 Hardware Limits: Original Design and Bus Load

- **Original**:  
  - 12 independent voice cards, each with full analog and CV lines.
  - Bus limited by address/data fanout, rise/fall times, capacitance.
- **Scaling**:  
  - Max reliable bus length: ~16 voices; further requires bus repeaters or segmentation.

### 30.181.2 Multi-Unit Chaining: MIDI, Net, and Clock Sync

- **Chaining**:  
  - Multiple Matrix-12s linked via MIDI; one is master, others set to slave.
  - MIDI clock, program change, macro, and patch data broadcast to all.
- **Network**:  
  - RTP-MIDI or OSC over Ethernet for tighter sync and lower latency.
  - Peer-to-peer or star topology for large setups.

### 30.181.3 Voice Expansion: Bus Arbitration, ID, and Auto-Detection

- **Bus Arbitration**:  
  - Each voice card responds to its unique address; expansion cards register on boot.
- **ID/Auto-Detection**:  
  - Cards report ID/version at power-up; main CPU builds polyphony map.
- **Firmware**:  
  - Dynamic allocation, per-card diagnostics, and error/fault masking.

### 30.181.4 Dynamic Polyphony Allocation: Load Balancing and Split Modes

- **Load Balancing**:  
  - When some cards are masked/faulty, available voices are distributed among splits/layers.
- **Split Modes**:  
  - E.g., 6+6, 8+4, 12+0; dynamic adjustment as voices are added/removed.
- **Voice Stealing**:  
  - Least-recently-used or lowest-amplitude voice is reassigned for new notes.

---

## 30.182 External Control: Editors, Automation, and DAW Integration

### 30.182.1 Sysex Editors: Patch Management, Parameter Morph, and Bulk Dump

- **Patch Management**:  
  - Editor reads/writes full patch via sysex (see Part 10/16); supports bank management, metadata, and history.
- **Parameter Morph**:  
  - Editor sends real-time parameter changes; supports morphing between states, macros, and automation curves.
- **Bulk Dump**:  
  - All patches, calibration tables, and user data can be dumped/restored for backup or mass-editing.

### 30.182.2 Automation: Real-Time CC, NRPN, and Macro Sync

- **CC/NRPN**:  
  - Assignable CCs and NRPNs mapped to any parameter or macro; high-resolution (14-bit) where supported.
- **Macro Sync**:  
  - Macros synchronized to DAW/host automation; live or sequenced performance mapped to matrix mod.

### 30.182.3 DAW Integration: Plugin, Web UI, and Live Feedback

- **Plugin**:  
  - VST/AU plugin acts as librarian, real-time controller, and patch editor.
  - Two-way communication: DAW automation updates synth, synth parameter changes update plugin.
- **Web UI**:  
  - Browser-based remote control, patch management, and diagnostics (see Part 16).
- **Live Feedback**:  
  - Parameter changes, errors, and patch morph visualized in real time.

### 30.182.4 API/Protocol Extensions: For Community Firmware

- **API**:  
  - JSON, OSC, or custom binary protocol for third-party apps.
- **Firmware Extensions**:  
  - Open source firmware hooks for custom features, e.g., new mod sources, custom scales, or alternate tuning.

---

## 30.183 Example C Code: Event Scheduler, Chained Polyphony, and External API

### 30.183.1 Event Queue, Timer Wheel, and Soft Interrupts

```c
#define EVENT_WHEEL_SIZE 64
typedef struct {
    uint32_t time;
    void (*handler)(void*);
    void *arg;
} sched_event_t;

sched_event_t event_wheel[EVENT_WHEEL_SIZE];
uint8_t event_head = 0;

void schedule_event(uint32_t delay_ms, void (*handler)(void*), void* arg) {
    uint32_t slot = (event_head + delay_ms) % EVENT_WHEEL_SIZE;
    event_wheel[slot].time = get_time() + delay_ms;
    event_wheel[slot].handler = handler;
    event_wheel[slot].arg = arg;
}

void timer_tick() {
    ++event_head;
    if (event_wheel[event_head].handler && event_wheel[event_head].time <= get_time()) {
        event_wheel[event_head].handler(event_wheel[event_head].arg);
        event_wheel[event_head].handler = NULL;
    }
}
```

### 30.183.2 Polyphony Chaining, Voice Arbitration, and Message Passing

```c
#define MAX_MATRIX_INSTANCES 4
typedef struct {
    uint8_t id;
    uint8_t voices;
    uint8_t base_note;
    uint8_t active;
} matrix12_unit_t;

matrix12_unit_t units[MAX_MATRIX_INSTANCES];

void distribute_note(uint8_t note, uint8_t vel) {
    // Find unit with free voice
    for (int i = 0; i < MAX_MATRIX_INSTANCES; ++i) {
        if (units[i].active && units[i].voices > 0) {
            send_note_to_unit(units[i].id, note, vel);
            units[i].voices--;
            break;
        }
    }
}
```

### 30.183.3 Sysex/CC Automation, Real-Time API Handler, and Editor Hooks

```c
void handle_sysex(uint8_t* data, size_t len) {
    if (data[0] == SYSEX_PATCH_DUMP) import_patch(data+1, len-1);
    else if (data[0] == SYSEX_PARAM_CHANGE) {
        uint16_t param = (data[1] << 8) | data[2];
        uint16_t val = (data[3] << 8) | data[4];
        set_patch_param(&edit_buf.patch, param, val);
    }
}

void handle_cc(uint8_t cc, uint8_t val) {
    if (cc >= MACRO_CC_BASE && cc < MACRO_CC_BASE + 8) {
        set_macro(cc - MACRO_CC_BASE, val);
    } else {
        map_cc_to_param(cc, val);
    }
}

void editor_api_request(const char* req, char* resp) {
    if (strcmp(req, "get_patch") == 0) dump_current_patch(resp);
    else if (strncmp(req, "set_param", 9) == 0) {
        // Parse and set param
    }
}
```

### 30.183.4 Command Parser, Error Reporting, and User Extensibility

```c
typedef void (*cmd_fn)(const char*);

struct {
    const char* cmd;
    cmd_fn fn;
} cmd_table[] = {
    {"note_on", cmd_note_on},
    {"note_off", cmd_note_off},
    {"set_param", cmd_set_param},
    {"morph_patch", cmd_morph_patch},
    {"dump_log", cmd_dump_log},
    {NULL, NULL}
};

void parse_command(const char* line) {
    for (int i = 0; cmd_table[i].cmd; ++i) {
        if (strncmp(line, cmd_table[i].cmd, strlen(cmd_table[i].cmd)) == 0) {
            cmd_table[i].fn(line + strlen(cmd_table[i].cmd));
            return;
        }
    }
    report_error("Unknown command");
}

void report_error(const char* msg) {
    lcd_print("ERROR: ");
    lcd_print(msg);
    log_event(msg);
}
```

---

## 30.184 Recap: System Integration, Key Learnings, and Forward Path

### 30.184.1 Full System Block Diagram: From Key to Output

```
[Keyboard/MIDI/Panel]
   |
[Event Queue/Scheduler]
   |
[Voice Allocation/Matrix]
   |
[Mod Matrix Engine]
   |
[DAC/Mux/Sample-Hold]
   |
[Voice Card]
   |
[VCO/VCF/VCA/Pan]
   |
[Summing Amp]
   |
[Main Output/USB/Network]
```

### 30.184.2 Table: All Subsystems, Main ICs, and Pin/Bus Maps

| Subsystem     | IC(s)         | Pins/Bus        | Function                   |
|---------------|---------------|-----------------|----------------------------|
| CPU           | 8031/8051     | 40 DIP          | Main control               |
| Patch RAM     | 62256/FRAM    | 28 DIP/SOIC     | Patch storage              |
| Panel Logic   | 74HC573/595   | 20+ pins        | LED/button/encoder drive   |
| LCD           | HD44780       | 16 pins         | Display                    |
| Voice Card    | CEM3340/3372  | 16/24 DIP       | VCO/VCF/VCA                |
| DAC           | DAC0800, etc. | 8 bits          | CV output                  |
| MIDI UART     | 6850/8251     | 20 DIP          | MIDI comms                 |

### 30.184.3 Maintenance, Upgrades, and Best Practices

- **Backup**: Regularly sysex dump all patches and calibration.
- **Cleanliness**: Avoid dust/humidity in panel and voice cards.
- **Service**: Use antistatic tools; avoid over-tightening panel screws.
- **Upgrades**: Modern LCD/OLED, FRAM for batteryless storage, USB/MIDI boards.

### 30.184.4 Where to Go Next: Open Firmware, Modern Clones, and Resources

- **Open Firmware**:  
  - See open-source Matrix-12/Xpander projects for firmware mods and new features.
- **Modern Clones**:  
  - ASM, Deckard’s Dream, and other poly-modulars offer new perspectives.
- **Resources**:  
  - Service manuals, schematics, open hardware forum threads, and patch libraries.

---

**End of Part 20: Matrix-12 System Timing, Polyphony Scaling, External Control, and Total Recap – Complete Deep Dive.**

*This final part brings together all hardware, software, and system integration knowledge, ensuring you can build, service, and expand a Matrix-12-level instrument from scratch.*

---