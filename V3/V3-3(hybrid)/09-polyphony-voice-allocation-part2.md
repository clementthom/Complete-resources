# Chapter 9: Polyphony & Voice Allocation – Part 2

---

## Table of Contents

7. Building a Voice Manager in C
    - Voice pool and allocation table
    - Algorithms for note-on/note-off handling
    - Voice stealing logic in code
    - Real-time constraints and performance
    - Debugging and visualization
8. Practical Polyphony: MIDI Integration, Testing, and Edge Cases
    - MIDI note handling and mapping to voices
    - Implementing sustain pedal and legato
    - Handling edge cases: fast trills, repeats, overlapping notes
    - Testing polyphony on PC and Pi
    - Visualization: voice states, debugging tools
9. Advanced Polyphony: Unison, Layering, Multitimbrality
    - Unison detune, stacking, and phase
    - Layered voices with different patches
    - Multitimbral synths (handling multiple MIDI channels)
    - Voice allocation constraints and performance
10. Exercises and Projects
11. Summary and Further Reading

---

## 7. Building a Voice Manager in C

### 7.1 Voice Pool and Allocation Table

A **voice pool** is an array of voice structs, each representing a single playable voice. The voice manager keeps track of which voices are free, in use, or in release (decaying) state. An **allocation table** maps notes to voices.

#### Example: Voice Pool Declaration

```c
#define NUM_VOICES 8

Voice voice_pool[NUM_VOICES];
```

#### Voice Allocation Table

You may use an array or hash table to map MIDI note numbers to their assigned voice index for fast lookup.

```c
int note_to_voice[128]; // MIDI notes 0-127, -1 if not assigned
```

Initialize with -1 to mean “no voice assigned”.

### 7.2 Note-On/Note-Off Handling Algorithms

#### Note-On (Key Down)

1. **Find a free voice:**  
   - Scan `voice_pool` for inactive voice (`active == 0`).
2. **If all voices are in use:**  
   - Apply “voice stealing” (see below).
3. **Assign note to voice:**  
   - Set `voice->note`, `voice->active = 1`, initialize envelopes/oscillators.
   - Update `note_to_voice[note] = voice_index`.

#### Note-Off (Key Up)

1. **Locate assigned voice:**  
   - Lookup `voice_index = note_to_voice[note]`.
2. **Enter release phase:**  
   - Set envelope to release, keep voice active until envelope completes.
3. **Mark as free when done:**  
   - When envelope output reaches zero, set `voice->active = 0`.

#### Example: Basic Voice Assignment

```c
void note_on(int midi_note, float velocity) {
    int v = find_free_voice();
    if (v == -1) v = steal_voice();
    start_voice(&voice_pool[v], midi_note, velocity);
    note_to_voice[midi_note] = v;
}

void note_off(int midi_note) {
    int v = note_to_voice[midi_note];
    if (v >= 0) {
        release_voice(&voice_pool[v]);
        note_to_voice[midi_note] = -1;
    }
}
```

### 7.3 Voice Stealing Logic in Code

When all voices are active, you must decide which to “steal”:

- **Oldest:** Steal the voice that has been active the longest.
- **Quietest:** Steal the voice with lowest envelope output (softest).
- **Released:** Prefer voices already in release phase.
- **Priority:** User can select which voices to protect (e.g., for solo lead).

#### Example: Oldest Voice Stealing

```c
int steal_voice() {
    int oldest = 0;
    uint32_t min_on_time = UINT32_MAX;
    for (int i = 0; i < NUM_VOICES; ++i) {
        if (voice_pool[i].on_time < min_on_time) {
            min_on_time = voice_pool[i].on_time;
            oldest = i;
        }
    }
    return oldest;
}
```
- `on_time` is set when the voice is started (e.g., a global sample count or timestamp).

### 7.4 Real-Time Constraints and Performance

- **Allocate voices outside the audio callback:** To avoid glitches, update voice state in the MIDI/event thread, not in the real-time audio thread.
- **Avoid malloc/free in the audio thread:** Use statically allocated arrays.
- **Fast lookup:** Precompute as much as possible.
- **Avoid race conditions:** Use mutexes or lock-free strategies if using multithreading.

### 7.5 Debugging and Visualization

- **Voice state display:** Print or plot which voices are active, assigned notes, envelope levels, etc.
- **Logging:** Track note-on, note-off, voice assignment, and stealing events.
- **Unit tests:** Simulate MIDI streams and verify voice assignment/stealing works as expected.

#### Example: Console Voice State

```c
void print_voice_states() {
    for (int i = 0; i < NUM_VOICES; ++i) {
        printf("Voice %d: note=%d, active=%d, env=%f\n",
               i, voice_pool[i].note, voice_pool[i].active, voice_pool[i].env[0].output);
    }
}
```

---

## 8. Practical Polyphony: MIDI Integration, Testing, and Edge Cases

### 8.1 MIDI Note Handling and Mapping to Voices

- **MIDI note-on:** Parse MIDI message, extract note and velocity, call `note_on()`.
- **MIDI note-off:** Parse MIDI message, extract note, call `note_off()`.

#### Example: MIDI Event Handler

```c
void midi_event_handler(uint8_t status, uint8_t note, uint8_t velocity) {
    if ((status & 0xF0) == 0x90 && velocity > 0) { // Note on
        note_on(note, velocity / 127.0f);
    } else if ((status & 0xF0) == 0x80 || ((status & 0xF0) == 0x90 && velocity == 0)) { // Note off
        note_off(note);
    }
}
```

### 8.2 Implementing Sustain Pedal and Legato

- **Sustain pedal (MIDI CC64):** When pressed, do not release voices on note-off; release only when pedal is released.
- **Legato:** If a new note is played while previous note is held, keep envelopes from retriggering (or partial retrigger).

#### Example: Sustain Pedal Handling

```c
int sustain_pedal = 0; // 1 = pressed, 0 = released

void note_off(int midi_note) {
    int v = note_to_voice[midi_note];
    if (v >= 0) {
        if (!sustain_pedal)
            release_voice(&voice_pool[v]);
        else
            voice_pool[v].sustained = 1;
        note_to_voice[midi_note] = -1;
    }
}

void sustain_pedal_event(int value) {
    sustain_pedal = value > 63;
    if (!sustain_pedal) {
        for (int i = 0; i < NUM_VOICES; ++i)
            if (voice_pool[i].sustained) {
                release_voice(&voice_pool[i]);
                voice_pool[i].sustained = 0;
            }
    }
}
```

### 8.3 Handling Edge Cases

- **Fast trills:** Rapid alternation between two notes; ensure voices are not stuck or misallocated.
- **Repeated notes:** Same note pressed before release; retrigger or not depending on mode.
- **Overlapping notes:** More notes than voices; voice stealing must not cause clicks/glitches.
- **Stuck notes:** Always provide an “all notes off” function for emergency.

### 8.4 Testing Polyphony on PC and Pi

- **Automated tests:** Simulate MIDI streams with many overlapping notes.
- **Visual feedback:** LEDs, terminal output, or GUI to show voice states.
- **Audio monitoring:** Check for glitches, clicks, or dropped notes.
- **Performance profiling:** Ensure no buffer underruns or CPU overload.

### 8.5 Visualization: Voice States and Debugging Tools

- **Console output:** Simple, but effective for small projects.
- **Graphical tools:** Use SDL, OpenGL, or web interfaces to plot voice activity over time.
- **Logging:** Record all note events and voice assignments for offline analysis.

---

## 9. Advanced Polyphony: Unison, Layering, Multitimbrality

### 9.1 Unison Detune, Stacking, and Phase

- **Unison:** Multiple voices play the same note, slightly detuned for thickness.
    - Split available voices into “unison groups”.
    - For 8-voice synth, 2-note polyphony with 4 unison voices each, etc.
- **Detune:** Slightly offset frequencies per unison voice.
- **Phase spread:** Start each unison voice at a different phase for a wider sound.

#### Example: Unison Implementation

```c
#define UNISON_COUNT 4

void note_on_unison(int note, float velocity) {
    float detune_cents[UNISON_COUNT] = {0.0f, -5.0f, 5.0f, 10.0f};
    for (int i = 0; i < UNISON_COUNT; ++i) {
        int v = find_free_voice();
        if (v == -1) v = steal_voice();
        float detuned_freq = midi_to_freq(note) * powf(2.0f, detune_cents[i] / 1200.0f);
        start_voice_detuned(&voice_pool[v], note, velocity, detuned_freq, i * (1.0f / UNISON_COUNT));
        note_to_voice[note] = v; // For first voice only, or use note-to-voice array of arrays
    }
}
```

### 9.2 Layered Voices with Different Patches

- Assign multiple voices with different patches (sounds) per note.
- Useful for splits, pads, multi-sample pianos, etc.

### 9.3 Multitimbral Synths (Handling Multiple MIDI Channels)

- **Multitimbral:** Synth can play different sounds on different MIDI channels simultaneously.
- Each channel has its own voice pool, patch, and allocation logic.
- Enables drum kits, splits, and complex arrangements.

#### Example: Multitimbral Voice Pool

```c
#define NUM_CHANNELS 4
Voice voice_pools[NUM_CHANNELS][NUM_VOICES_PER_CHANNEL];
int note_to_voice[NUM_CHANNELS][128];
```

### 9.4 Voice Allocation Constraints and Performance

- **CPU/RAM limits:** More voices = more processing.
- **Per-voice effects:** Reverb, chorus, delay multiply CPU cost.
- **Prioritize important voices:** Lead, melody, bass—protect from stealing.

---

## 10. Exercises and Projects

1. **Write a C voice manager:** Implement note-on/note-off, voice stealing, and a test harness that simulates MIDI note streams.
2. **Add unison and detune:** Allow the user to select unison count and detune amount.
3. **Breadboard a polyphonic analog voice controller:** Use digital logic or microcontroller to map keys to voice cards.
4. **Simulate multitimbrality:** Adapt your code to handle multiple MIDI channels and patches.
5. **Log and visualize voice allocation:** Create a tool to display voice state over time.
6. **Stress-test your polyphony:** Simulate rapid note-on/note-off events, check for glitches, stuck notes, or performance problems.
7. **Integrate with your synth engine:** Connect voice manager to oscillator, envelope, and filter modules for a full polyphonic synth.

---

## 11. Summary and Further Reading

- Polyphony enables rich, expressive synth performance—chords, layers, and textures.
- Voice allocation and stealing are crucial for reliability and musicality.
- Modular C code with per-voice structs, voice pool, and robust allocation is essential for hybrid and digital synths.
- Advanced features like unison, layering, and multitimbrality add professional flexibility.
- Testing, debugging, and visualization are critical for development.

**Further Reading:**
- “The Prophet from Silicon Valley” (Prophet-5 history)
- “Make: Analog Synthesizers” by Ray Wilson (polyphony projects)
- Mutable Instruments open-source code (voice allocation in real-world synths)
- MIDI.org (protocol specs, MIDI polyphony details)
- Synth-DIY mailing list archives

---

*End of Chapter 9. Next: Interfacing Pi 4 with DACs and Analog Circuits (deep dive into connecting digital and analog domains, practical circuits, and C code for hardware interfacing).*