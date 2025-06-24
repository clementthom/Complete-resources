# Chapter 9: Polyphony & Voice Allocation – Part 1

---

## Table of Contents

1. Introduction: What is Polyphony? Why is it Important?
2. Monophonic vs Polyphonic Synths
    - Definitions and musical impact
    - Classic examples of each
3. The Concept of a Voice in Synthesis
    - What constitutes a "voice": oscillator, envelope, filter, VCA, etc.
    - Voice architecture in classic and modern synths
4. Polyphony Architectures
    - Paraphonic vs true polyphonic
    - Fixed vs dynamic voice allocation
    - Voice card/chip architectures
    - Hybrid and digital implementations
5. Voice Allocation Algorithms
    - Round-robin
    - Oldest/released voice stealing
    - Priority-based
    - Unison and layering
    - Release/retrigger logic
6. Modular Voice Structures in C
    - Designing modular voice structs
    - Per-voice state: oscillator, envelope, filter, mod sources, note data
    - Global vs per-voice modulation
    - Voice initialization and reset
    - Example code for basic voice struct
7. Building a Voice Manager in C
    - Voice pool and allocation table
    - Algorithms for note-on/note-off handling
    - Voice stealing logic in code
    - Real-time constraints and performance
    - Debugging and visualization

---

## 1. Introduction: What is Polyphony? Why is it Important?

Polyphony refers to a synthesizer’s ability to play multiple notes simultaneously. In the earliest days of synthesis, most synths were monophonic—capable of playing only one note at a time. As technology advanced, polyphony became a defining feature of musical instruments: from piano-like chords to lush pads, string ensembles, and complex textures.

**Key reasons polyphony matters:**
- **Expressive playing:** Chords, arpeggios, overlapping notes.
- **Layering:** Multiple sounds or timbres at once.
- **Unison:** Stacking voices for fatter, richer tones.
- **MIDI integration:** Most modern music expects at least 4–8 voices.

---

## 2. Monophonic vs Polyphonic Synths

### 2.1 Definitions and Musical Impact

- **Monophonic:** Only one note can sound at a time. If a new key is pressed, the previous note is cut off or replaced.
    - *Musical impact:* Forces legato lines, can’t play chords. Great for leads, basses, solos, and expressive pitch bends.
- **Polyphonic:** Multiple notes (voices) can sound together. Essential for chords, pads, complex arrangements.
    - *Musical impact:* Enables harmonies, complex textures, and orchestration.

### 2.2 Classic Examples

- **Monophonic:** Minimoog, ARP Odyssey, TB-303, SH-101, MS-20.
- **Polyphonic:** Prophet-5, Oberheim OB-X, Roland Juno-106, Yamaha DX7, Korg PolySix.

### 2.3 Paraphonic Synths

- *Paraphonic:* Multiple notes share some parts of the signal path (e.g., one filter for all oscillators). Cheaper to implement, but less flexible than true polyphony.
    - Examples: Korg Mono/Poly, ARP Omni.

---

## 3. The Concept of a Voice in Synthesis

### 3.1 What Constitutes a "Voice"?

A **voice** in a synth is a complete signal chain capable of producing an independent note. It typically includes:
- 1 or more oscillators (VCOs, DCOs, or digital)
- Envelope generator(s)
- Filter (VCF)
- Amplifier (VCA)
- Modulation sources (LFO, noise, etc.)
- Per-voice parameters: note number, velocity, pitch bend, etc.

### 3.2 Voice Architecture in Classic and Modern Synths

- **Classic analog polyphony:** Each voice = separate “voice card” (circuit board with VCO, VCF, VCA, etc.)
- **Digital/virtual polyphony:** Each voice = struct/object in code, usually with its own state and parameters.
- **Hybrid:** Digital control of analog voice cards (e.g., Prophet-5 rev 3, modern analog polysynths).

### 3.3 Voice Count

- **Determined by hardware:** Number of voice cards, CPUs, or DSPs.
- **In software:** Limited by CPU/RAM; 8, 16, 32 or more voices are common.

---

## 4. Polyphony Architectures

### 4.1 Paraphonic vs True Polyphonic

- **Paraphonic:** Multiple oscillators, but shared envelopes or filters. Simpler, but less expressive.
    - E.g., four oscillators, one VCF/VCA: chords sound, but all notes share filter/envelope movement.
- **True polyphonic:** Each note has its own complete voice chain; most flexible and expressive.

### 4.2 Fixed vs Dynamic Voice Allocation

- **Fixed:** Each key/note is permanently mapped to a voice (e.g., organ, string machines).
- **Dynamic:** Notes are assigned to free voices as needed; allows more efficient use of voices, but requires allocation logic.

### 4.3 Voice Card/Chip Architectures

- **Voice card:** Dedicated circuit for each voice (classic analogs, some digital hybrids).
- **Voice chip:** ICs like CEM3396, SSM2044, Yamaha FM chips—multiple voices per chip.

### 4.4 Hybrid and Digital Implementations

- **Modern approach:** All voices are software “modules” (structs/classes).
- **Voice pool:** Pool of available voices, assigned as notes are played, released when done.

---

## 5. Voice Allocation Algorithms

### 5.1 Round-Robin

Assigns each new note to the next available voice in a circular fashion.
- Simple, fair.
- Can cause abrupt cutoffs if all voices are in use.

### 5.2 Oldest/Released Voice Stealing

- When all voices are busy, steal the voice that has been sounding the longest or is in release phase.
    - “Voice stealing” logic is critical for smooth transitions.

### 5.3 Priority-Based

- Assign voices based on priority rules (e.g., new notes have higher priority, or prefer to steal voices that are quietest or have lowest velocity).

### 5.4 Unison and Layering

- **Unison:** Multiple voices play the same note, often detuned for fatness.
- **Layering:** Multiple voices play different sounds simultaneously (splits, multi-timbral).

### 5.5 Release/Retrigger Logic

- **Release phase:** When a note-off is received, voice enters release stage rather than stopping abruptly.
- **Retrigger:** If same note is played again, can retrigger envelope or continue from previous state.

---

## 6. Modular Voice Structures in C

### 6.1 Designing Modular Voice Structs

Each voice should encapsulate all state needed to render a note. For a hybrid/digital synth:

```c
typedef struct {
    Oscillator osc[NUM_OSCILLATORS_PER_VOICE];
    Envelope env[NUM_ENVELOPES_PER_VOICE];
    Filter filt;
    float velocity;
    int note;
    int active;
    // Modulation sources, per-voice LFOs, etc.
    // Add more as needed
} Voice;
```

- **osc:** Array for multi-oscillator voices (unison, layering).
- **env:** Envelope generators for amplitude, filter, or other parameters.
- **filt:** Per-voice filter state.
- **velocity:** MIDI velocity or other expressive input.
- **note:** MIDI note number or pitch.
- **active:** Flag for voice allocation (0 = free, 1 = active).

### 6.2 Per-Voice State

- All modulation, envelope, filter, oscillator, and note parameters should be stored per-voice.
- Avoid shared state unless implementing global modulation (e.g., master LFO).

### 6.3 Global vs Per-Voice Modulation

- **Global:** Master LFO, shared effects (e.g., chorus, reverb).
- **Per-voice:** LFO/envelope for individual vibrato, filter sweeps, etc.

### 6.4 Voice Initialization and Reset

- Initialize all struct members to defaults.
- Reset phase/envelope/filter state on note-on or voice allocation.
- Free voice (set active=0) after note release completes.

### 6.5 Example: Voice Struct Initialization

```c
void init_voice(Voice* v) {
    for (int i = 0; i < NUM_OSCILLATORS_PER_VOICE; ++i)
        osc_init(&v->osc[i], OSC_SAW, 0.0f, 0.5f, SAMPLE_RATE);
    for (int i = 0; i < NUM_ENVELOPES_PER_VOICE; ++i)
        env_init(&v->env[i]);
    filt_init(&v->filt);
    v->velocity = 0.0f;
    v->note = -1;
    v->active = 0;
}
```

### 6.6 Example: Voice Struct Usage in Processing

```c
float process_voice(Voice* v) {
    float osc_sum = 0.0f;
    for (int i = 0; i < NUM_OSCILLATORS_PER_VOICE; ++i)
        osc_sum += osc_process(&v->osc[i]);
    osc_sum /= NUM_OSCILLATORS_PER_VOICE;
    float env_out = env_process(&v->env[0]);
    float filt_out = filt_process(&v->filt, osc_sum);
    return env_out * filt_out * v->velocity;
}
```

---

*End of Part 1. Part 2 will cover full voice manager code (allocation, stealing), real-time considerations, practical polyphony tests, MIDI integration, and debugging strategies.*