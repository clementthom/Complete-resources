# Workstation Chapter 07: Multi-Voice, Multi-Timbral Architecture (Part 1)
## Polyphony, Layering, Splits, and Professional Patch Management

---

## Table of Contents

1. Introduction: Why Multi-Voice and Multi-Timbrality Matter
2. Polyphony Fundamentals
    - What Is a Voice?
    - Voice Allocation and Management
    - Polyphony vs. Timbrality
    - Monophonic, Polyphonic, Paraphonic Modes
3. Multi-Timbral Workstations: Concepts and Design
    - What Is Multi-Timbrality?
    - Historical and Modern Examples
    - Parts, Layers, and Zones
    - Use Cases: Live Performance, Studio, Sequencing
4. Voice Structures and Data Management
    - Voice Data Structures in C
    - Parameter Handling (Per-Voice, Per-Part, Global)
    - Voice State Machines
    - Real-Time Voice Allocation (Stealing, Priority, Dynamic Allocation)
5. Multi-Part Engines: Layers, Splits, and Key Mapping
    - Layering Sounds (Velocity, Key Range, Zone)
    - Key Splits and Multi-Zone Setups
    - Channel/Part Routing (MIDI, Sequencer, UI)
    - Polyphony Sharing and Limits
6. Practice Section 1: Building Polyphonic and Multi-Timbral Engines
7. Exercises

---

## 1. Introduction: Why Multi-Voice and Multi-Timbrality Matter

Modern workstations must:
- Play many notes (polyphony), each with its own envelope, filter, sample, or synth voice.
- Layer and split different sounds across keyboard zones, velocities, and MIDI channels.
- Handle complex performances, sequences, and patch setups with ease.

**Classic Examples:**
- Roland JD-800: 24-voice polyphony, 4-part multi-timbral
- Yamaha Motif, Korg Kronos: 16+ parts, hundreds of voices
- Emulator III, Synclavier: Multi-part, multi-sample playback, advanced layering

**Why is this hard?**
- CPU, RAM, and audio bandwidth must be managed across all voices and parts.
- Complex user interfaces and patch management are required.
- Real-time voice allocation and dynamic resource sharing are needed for seamless performance.

---

## 2. Polyphony Fundamentals

### 2.1 What Is a Voice?

- **Voice:** An independent sound-generating path (oscillator, envelope, filter, amp, etc.) that can play one note at a time.
- Each key press (or sequencer event) triggers a new voice instance.

*Example:*
- 8-voice synth: can play 8 notes at once (chords, overlapping notes).
- Each voice has its own state: on/off, envelope, current note, parameters.

### 2.2 Voice Allocation and Management

- **Voice Pool:** Array or list of voice structs, each representing one possible simultaneous note.
- **Idle/Active State:** Voice is either in use (playing a note) or idle (available).
- **Voice Allocation:** When a new note arrives, find a free voice; if none, decide which to steal (oldest, quietest, etc.).

**Simple Voice Pool in C:**
```c
#define MAX_VOICES 32
typedef struct {
    int active;
    int midi_note;
    float velocity;
    // Envelope, oscillator, filter, etc.
} Voice;
Voice voices[MAX_VOICES];
```

### 2.3 Polyphony vs. Timbrality

- **Polyphony:** How many notes can play at once (total voices).
- **Timbrality:** How many different sound programs/patches can play at once (parts, layers).

*Example:*
- 64-voice, 16-part synth: 64 total notes, up to 16 different sounds (one per MIDI channel).

### 2.4 Monophonic, Polyphonic, Paraphonic Modes

- **Monophonic:** Only one note at a time (classic bass, lead).
- **Polyphonic:** Multiple notes (chords, layers).
- **Paraphonic:** Multiple notes share some components (e.g., single filter or envelope for all notes).

---

## 3. Multi-Timbral Workstations: Concepts and Design

### 3.1 What Is Multi-Timbrality?

- The ability to play multiple different sounds (timbres) at the same time, each with its own MIDI channel, patch, and settings.
- “Parts” or “zones” are assigned to different instruments, drums, splits, etc.

### 3.2 Historical and Modern Examples

- **Roland D-50:** 8-part multi-timbral, each part assigned to a MIDI channel.
- **EMU Emulator III:** Multi-sample instruments, each mapped to different keys/velocities.
- **Korg Triton/Kronos:** 16-part, each part with its own effects, zones, and splits.

### 3.3 Parts, Layers, and Zones

- **Part:** One sound/program/patch with its own MIDI channel, volume, pan, FX, etc.
- **Layer:** Multiple sounds triggered together (stacked for richer timbre).
- **Zone:** Key and/or velocity range for a part/layer (e.g., bass below C3, strings above).

### 3.4 Use Cases

- **Live Performance:** One keyboard split into bass, piano, and pad zones.
- **Studio:** Multiple MIDI tracks control different sounds (drums, synth, keys).
- **Sequencer:** Multiple parts play different patterns simultaneously.

---

## 4. Voice Structures and Data Management

### 4.1 Voice Data Structures in C

**Basic Voice Structure:**
```c
typedef struct {
    int active;
    int midi_note;
    float velocity;
    float env_phase;
    float filter_cutoff;
    // Add more: oscillator, LFO, etc.
    int part_id; // Which part/layer this voice belongs to
} Voice;
```

**Voice Pool:**
```c
Voice voices[MAX_VOICES];
```

### 4.2 Parameter Handling (Per-Voice, Per-Part, Global)

- **Per-Voice:** Envelope, oscillator phase, filter cutoff, amplitude, current note state.
- **Per-Part:** Patch parameters (waveform, filter type, FX send), MIDI channel, pan, volume.
- **Global:** Master volume, tempo, global FX, routing.

### 4.3 Voice State Machines

- Each voice walks through states: Idle → Attack → Decay → Sustain → Release → Idle
- State machine handles envelope transitions and voice deallocation.

**State Machine Example:**
```c
typedef enum { IDLE, ATTACK, DECAY, SUSTAIN, RELEASE } EnvState;
typedef struct {
    EnvState state;
    float envelope;
    float env_time;
    // ...
} Voice;
```

### 4.4 Real-Time Voice Allocation

- On new note-on event:
    - Find inactive voice (active == 0).
    - If all voices are active, steal according to policy (oldest, quietest, lowest priority).
- Track which part/layer each voice belongs to for proper routing.

**Voice Stealing Example:**
```c
int find_voice_to_steal(Voice *voices, int n) {
    int oldest = 0;
    float max_age = 0;
    for (int i = 0; i < n; ++i) {
        if (voices[i].active && voices[i].env_time > max_age) {
            oldest = i;
            max_age = voices[i].env_time;
        }
    }
    return oldest;
}
```

---

## 5. Multi-Part Engines: Layers, Splits, and Key Mapping

### 5.1 Layering Sounds

- **Velocity Layering:** Different samples/synths triggered depending on velocity (soft = piano, hard = synth).
- **Key Splits:** Assign parts/layers to specific key ranges (bass low, lead high).
- **Zone Mapping:** Combine key and velocity for complex setups.

**Layer Example:**
```c
typedef struct {
    int min_note, max_note;
    int min_vel, max_vel;
    int part_id; // Which part/layer to trigger
} Zone;
Zone zones[MAX_ZONES];
```

### 5.2 Key Splits and Multi-Zone Setups

- Assign MIDI note ranges to parts (splits).
- Overlapping zones allow for crossfade/blending between layers.

### 5.3 Channel/Part Routing

- Each part can be assigned a MIDI channel, receive from keyboard, sequencer, or external MIDI.
- Internal routing allows complex setups (e.g., split keyboard + sequencer tracks).

### 5.4 Polyphony Sharing and Limits

- Total polyphony is shared across all parts/layers.
- Each part/layer may have its own polyphony limit (e.g., drums = 4 voices, pads = 8).
- Dynamic allocation: unused voices can be “loaned” to busy parts.

---

## 6. Practice Section 1: Building Polyphonic and Multi-Timbral Engines

### 6.1 Polyphonic Synth Voice Pool

- Implement a C struct for a pool of 16–32 voices.
- Add functions for note-on, note-off, voice allocation, and stealing.
- Track which part/layer each voice belongs to.

### 6.2 Layer and Split Assignment

- Create an array of layers/parts, each with its own patch and MIDI channel.
- Map incoming MIDI notes to the correct part/layer based on key range and channel.

### 6.3 State Machine Implementation

- Write a state machine for your voices (attack, decay, sustain, release, idle).
- Handle envelope progression and deallocation in real time.

### 6.4 Dynamic Polyphony Management

- Allow dynamic sharing of voices between parts/layers.
- Implement priority or user-adjustable “reserve” for important sounds.

---

## 7. Exercises

1. **Voice Pool Basics**
   - Write C code to define a voice pool of 16 voices, each with note, velocity, active state, and envelope phase.

2. **Voice Allocation**
   - Implement a function to allocate a voice on note-on, and steal the oldest voice if all are busy.

3. **Polyphony and Timbrality**
   - Define data structures for 8-part multi-timbral engine with 32 voices total. Each part should have its own patch parameters.

4. **Key Split Mapping**
   - Write code to assign incoming notes to parts/layers based on key and velocity range.

5. **Layered Patch Design**
   - Create a patch with at least three layers (e.g., piano, pad, bell), each triggered across overlapping key/velocity zones.

6. **Voice State Machine**
   - Implement a state machine for attack, decay, sustain, release, and idle states.

7. **Dynamic Polyphony**
   - Allow unused voices to be dynamically allocated to busy parts/layers.

8. **Part Routing**
   - Assign MIDI channels to parts, and route events from sequencer/keyboard to the correct part.

9. **Voice Stealing Strategy**
   - Write and compare at least two voice stealing algorithms (oldest, lowest amplitude, round robin).

10. **Performance Testing**
    - Measure and log maximum polyphony with all layers active. Document CPU usage and bottlenecks.

---

**End of Part 1.**  
_Part 2 will cover advanced multi-timbral setups, real-world performance scenarios, patch switching, dynamic resource reallocation, and best practices for professional-grade workstation engines._
