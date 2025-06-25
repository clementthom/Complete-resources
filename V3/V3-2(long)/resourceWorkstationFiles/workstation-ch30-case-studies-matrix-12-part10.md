# Chapter 30: Case Studies – Oberheim Matrix-12 (Complete Deep-Dive)
## Part 10: Full Matrix-12 Patch Data Format, Sysex, and Cross-Compatibility for Re-Creation

---

## Table of Contents

- 30.122 Matrix-12 Patch Data Format: Internal Storage, Serialization, and Physical Layout
  - 30.122.1 Internal Patch Structure: Parameter Map and Data Packing
  - 30.122.2 Modulation Matrix Serialization and Per-Route Encoding
  - 30.122.3 Voice-Specific Offsets, Correction Tables, and Storage Optimization
- 30.123 Sysex Protocol: Dump, Restore, and External Editor Support
  - 30.123.1 Sysex Message Structure, Handshake, and Error Checking
  - 30.123.2 Full Patch Dump: Header, Data, Checksum, and Footer
  - 30.123.3 Bank Dump, Multi-Patch, and Cross-Model Compatibility
- 30.124 Patch Editing, Recall, and UI Logic
  - 30.124.1 Patch Buffer, Edit Buffer, and Non-Destructive Editing
  - 30.124.2 Patch Compare, Undo, and Parameter Change Tracking
  - 30.124.3 Patch Recall: Fast Loading, Matrix Refresh, and Voice Update
- 30.125 Cross-Compatibility: Matrix-12, Xpander, and Modern Clones
  - 30.125.1 Patch Format Differences, Parameter Mapping, and Scaling
  - 30.125.2 Sysex Translation, Editor Integration, and Automation
  - 30.125.3 Issues with Non-Standard Data, Unknown Parameters, and User Notes
- 30.126 Example C Code: Patch Serialization, Sysex Packing, and Editor API Skeleton
  - 30.126.1 Patch Struct, Matrix Table, and Correction Table Serialization
  - 30.126.2 Sysex Dump/Restore Handler and Error Correction
  - 30.126.3 Patch Compare, Undo Stack, and Editor Integration API
- 30.127 Reference Tables: Parameter Map, Sysex Byte Layout, and Compatibility Matrices

---

## 30.122 Matrix-12 Patch Data Format: Internal Storage, Serialization, and Physical Layout

### 30.122.1 Internal Patch Structure: Parameter Map and Data Packing

- **Patch Structure**:  
  - Name (16 bytes, ASCII, padded with spaces)
  - Modulation Matrix (40 routes × 4 bytes = 160 bytes)
  - OSC1/2 parameters (wave, freq, pulse, sync, detune, FM, etc.; ~16 bytes)
  - VCF settings (type, cutoff, res, env mod, key track, etc.; ~8 bytes)
  - VCA/AMP (env assign, velocity curve, pan, etc.; ~6 bytes)
  - Envelopes (5 × 6 bytes = 30 bytes: rate, level, curve)
  - LFOs (3 × 6 bytes = 18 bytes: rate, shape, delay, sync, assign)
  - Split/layer/zone data (key range, MIDI ch, voice group; ~12 bytes)
  - Correction tables (if stored per patch; otherwise, global)
  - Panel and macro assignments (~12 bytes)
  - Padding/reserved for future use (~10 bytes)
  - **Total typical patch size:** 256–320 bytes (rounded to 256 or 320 for alignment)

#### 30.122.1.1 Patch Struct Example (C)

```c
typedef struct {
    char name[16];
    matrix_route_t matrix[40]; // see below
    uint8_t osc1[8], osc2[8];
    uint8_t vcf[8];
    uint8_t vca[6];
    uint8_t env[5][6]; // DADSR: rates, levels, curves
    uint8_t lfo[3][6];
    uint8_t split[6], layer[6]; // zones, MIDI channels
    uint8_t macro[12];
    uint8_t reserved[10]; // for expansion/compatibility
} m12_patch_t;
```

### 30.122.2 Modulation Matrix Serialization and Per-Route Encoding

- **Matrix Route**:  
  - Each route is 4 bytes:
    - Source (6 bits), Destination (6 bits)
    - Depth (signed 7 bits, -64..+63)
    - Curve (3 bits: linear, exp, log, S&H, etc.)
  - Unused routes set to "off" (source/dest=0, depth=0)
- **Packing**:  
  - Bitfields packed to minimize size and support future expansion.
  - For sysex, each field is split into 7-bit bytes to fit MIDI data spec.

#### 30.122.2.1 Matrix Route Struct Example (C)

```c
typedef struct {
    uint8_t src_dst; // 0bSSSSSSDD
    int8_t depth; // -64..+63
    uint8_t curve; // 0..7 (3 bits)
} matrix_route_t;
```

### 30.122.3 Voice-Specific Offsets, Correction Tables, and Storage Optimization

- **Correction Tables**:
  - Typically stored globally, not per-patch; can be included in sysex for full backup.
  - Each table is per-voice, per-octave for VCO, and per-destination for VCF/VCA calibration.
- **Storage**:
  - Patch RAM is battery-backed SRAM or FRAM, organized in slots (100 slots for Matrix-12).
  - Alignment ensures fast block load on recall; edit buffer always in RAM for atomic edits.

---

## 30.123 Sysex Protocol: Dump, Restore, and External Editor Support

### 30.123.1 Sysex Message Structure, Handshake, and Error Checking

- **Sysex Structure**:
  - Start: 0xF0
  - Manufacturer ID: 0x10 (Oberheim), Device ID, Model ID
  - Command: Patch Dump, Patch Load, Bank Dump, etc.
  - Data: Patch bytes (7-bit encoding, see below)
  - Checksum: XOR or sum of all data bytes
  - End: 0xF7
- **Handshake**:
  - Editor sends "request dump", device replies with patch data.
  - For restore, device sends ACK/NACK after checksum validation.

#### 30.123.1.1 Example Patch Dump Sysex

```
F0 10 06 0C 01 [patch data ...] [checksum] F7
```

### 30.123.2 Full Patch Dump: Header, Data, Checksum, and Footer

- **Patch Data**:
  - Patch struct packed into 7-bit bytes for MIDI (no byte >0x7F).
  - Each 8 bytes of data are split into 7 bytes + 1 "packing" byte.
- **Checksum**:
  - Simple XOR or sum modulo 128; failing checksum triggers NACK and retransmit.

### 30.123.3 Bank Dump, Multi-Patch, and Cross-Model Compatibility

- **Bank Dump**:
  - Multiple patch dumps concatenated, with header/footer for each patch.
- **Cross-Model**:
  - Xpander and Matrix-12: nearly identical patch format, but some parameters (e.g., pan, extra matrix slots) differ.
  - Editors translate parameters, fill missing fields with defaults, or mark as "not available".

---

## 30.124 Patch Editing, Recall, and UI Logic

### 30.124.1 Patch Buffer, Edit Buffer, and Non-Destructive Editing

- **Patch Buffer**:
  - Patch RAM: persistent storage for all saved patches.
- **Edit Buffer**:
  - Volatile RAM: holds current patch under edit, not committed until saved.
  - Supports undo/redo by storing diff stack.
- **Non-Destructive**:
  - Edits not committed to patch RAM until explicit save or program change with confirmation.

### 30.124.2 Patch Compare, Undo, and Parameter Change Tracking

- **Compare**:
  - "Compare" function toggles between current edit buffer and original patch.
  - Differences shown on LCD, with highlight of changed parameters.
- **Undo Stack**:
  - Parameter changes logged in ring buffer; undo/redo possible for up to N steps.
- **Parameter Tracking**:
  - Each change triggers matrix/DAC update and UI redraw; history metadata stored for editor integration.

### 30.124.3 Patch Recall: Fast Loading, Matrix Refresh, and Voice Update

- **Recall**:
  - Patch loaded from RAM into edit buffer, triggers full matrix recalculation and DAC/mux update.
  - Voice engine notified of parameter changes for real-time update.
- **Atomicity**:
  - Patch recall is atomic; no partial state possible.

---

## 30.125 Cross-Compatibility: Matrix-12, Xpander, and Modern Clones

### 30.125.1 Patch Format Differences, Parameter Mapping, and Scaling

- **Xpander**:
  - 6 voices, 6 LFOs, more matrix slots in some firmware versions.
  - Matrix-12 patches can be loaded on Xpander if parameters are mapped/scaled.
- **Modern Clones**:
  - Parameter superset/subset logic; unknown fields ignored or mapped to nearest match.
  - Pan and split/layer often not present on Xpander, so set to defaults.

### 30.125.2 Sysex Translation, Editor Integration, and Automation

- **Sysex Editors**:
  - Translate between formats (Matrix-12 to Xpander, vice versa).
  - UI shows which parameters do not map 1:1; user can assign defaults or interpolate.
- **Automation**:
  - DAW/host can send parameter changes as sysex or CC mapped to matrix sources.

### 30.125.3 Issues with Non-Standard Data, Unknown Parameters, and User Notes

- **Non-Standard Data**:
  - Some patches from older firmware or clones may have unknown fields; editors must ignore or mark as "unknown".
- **User Notes**:
  - Some patch formats allow for comment field or metadata for editor use.
  - Notes are not sent to hardware, just used for librarian/backup.

---

## 30.126 Example C Code: Patch Serialization, Sysex Packing, and Editor API Skeleton

### 30.126.1 Patch Struct, Matrix Table, and Correction Table Serialization

```c
void serialize_patch(const m12_patch_t* p, uint8_t* buf) {
    memcpy(buf, p, sizeof(m12_patch_t));
    // Optionally encode for sysex (7-bit)
}

void encode_sysex(const uint8_t* data, int len, uint8_t* syx) {
    // Pack 8 bytes into 7, add packing byte
    int in = 0, out = 0;
    while (in < len) {
        uint8_t pack = 0;
        for (int i = 0; i < 7 && in < len; i++, in++) {
            syx[out++] = data[in] & 0x7F;
            if (data[in] & 0x80) pack |= (1 << i);
        }
        syx[out++] = pack;
    }
}
```

### 30.126.2 Sysex Dump/Restore Handler and Error Correction

```c
void send_patch_sysex(const m12_patch_t* p, uint8_t dev_id) {
    uint8_t buf[320], syx[370];
    serialize_patch(p, buf);
    encode_sysex(buf, sizeof(buf), syx);

    midi_send(0xF0); // Sysex start
    midi_send(0x10); // Oberheim
    midi_send(0x06); // Model: Matrix-12
    midi_send(dev_id);
    midi_send(0x01); // Patch dump
    for (int i = 0; i < sizeof(syx); ++i)
        midi_send(syx[i]);
    midi_send(calc_checksum(syx, sizeof(syx)));
    midi_send(0xF7); // Sysex end
}

int verify_sysex(const uint8_t* syx, int len) {
    // Checksum verification
    uint8_t sum = 0;
    for (int i = 0; i < len-1; ++i) sum ^= syx[i];
    return sum == syx[len-1];
}
```

### 30.126.3 Patch Compare, Undo Stack, and Editor Integration API

```c
typedef struct {
    m12_patch_t old_patch;
    m12_patch_t new_patch;
    int param_changed[128];
} patch_undo_t;

patch_undo_t undo_stack[16];
int undo_ptr = 0;

void patch_compare(const m12_patch_t* a, const m12_patch_t* b, int* diff) {
    const uint8_t* pa = (const uint8_t*)a;
    const uint8_t* pb = (const uint8_t*)b;
    for (int i = 0; i < sizeof(m12_patch_t); ++i) {
        diff[i] = (pa[i] != pb[i]);
    }
}

void push_undo(const m12_patch_t* before, const m12_patch_t* after) {
    undo_stack[undo_ptr].old_patch = *before;
    undo_stack[undo_ptr].new_patch = *after;
    patch_compare(before, after, undo_stack[undo_ptr].param_changed);
    undo_ptr = (undo_ptr+1) % 16;
}
```

---

## 30.127 Reference Tables: Parameter Map, Sysex Byte Layout, and Compatibility Matrices

### 30.127.1 Matrix-12 Parameter Map (Partial Example)

| Offset | Parameter         | Type     | Range      | Notes            |
|--------|-------------------|----------|------------|------------------|
| 0      | Patch Name        | ASCII    | 16 chars   |                 |
| 16     | Matrix Table      | 40 × 4   | See above  |                 |
| 176    | Osc1 Wave         | Enum     | 0-7        | Saw, Tri, Pulse |
| 177    | Osc1 Freq Mod     | Int      | 0-127      |                 |
| 178    | Osc1 Detune       | Int      | -64–+63    |                 |
| ...    | ...               | ...      | ...        | ...             |

### 30.127.2 Sysex Byte Packing

| Data Bytes | MIDI Bytes | Packing Byte | Notes                 |
|------------|------------|--------------|-----------------------|
| b0-b6      | s0-s6      | pack7        | 7 data, 1 pack        |
| b7-b13     | s7-s13     | pack14       | ...                   |

### 30.127.3 Compatibility Matrix (Matrix-12, Xpander, Modern)

| Param         | Matrix-12 | Xpander | Modern Clone | Notes     |
|---------------|-----------|---------|-------------|-----------|
| Pan           | Yes       | No      | Yes         |           |
| Split/Layer   | Yes       | No      | Yes         |           |
| 4+ LFOs       | 3         | 6       | 6+          |           |
| Matrix Slots  | 40        | 46      | 64+         |           |
| Correction Tbl| Global    | Global  | Patch/Global|           |

---

**End of Part 10: Matrix-12 Patch Data, Sysex, and Cross-Compatibility – Complete Deep Dive.**

*This section provides the ground truth for patch format, sysex handling, and compatibility required for full Matrix-12 recreation and advanced editor/librarian support.*

---