# Chapter 4: C Programming (Advanced Topics: Pointers, Structs, Memory) - Part 2

---

## Table of Contents

7. Deep Dive: Structures in C
   - What are structs and why do we use them?
   - Defining, declaring, and initializing structs
   - Structs as hardware modules: modeling boards and components
   - Nested structs, arrays of structs, and struct pointers
   - Typedefs for clarity
   - Accessing struct members (dot and arrow operators)
   - Passing structs to functions (by value vs by pointer)
   - Memory layout of structs, alignment, and padding
   - Practical synth struct examples: Oscillators, Envelopes, Filters, Voices
8. Unions and Bitfields: Efficient Data Packing
   - What is a union? When to use it?
   - Union syntax, declaration, and usage
   - Bitfields: packing flags and control words
   - Practical audio applications: MIDI parsing, register simulation
   - Warnings: portability, endianness
9. Organizing Modular Synth Code with Structs and Pointers
   - Hardware mapping: Each board as a struct/module
   - Linking modules with pointers
   - Function pointers in structs: simulating hardware flexibility
   - Example: Polymorphic processing with function pointers
   - Building a modular signal chain
10. Header Files, Include Guards, and Good Practice
    - What goes in headers vs C files
    - Include guards (why and how)
    - Modular folder structure for large projects
    - Documenting module APIs (doxygen comments, usage examples)
11. Deep Dive: Dynamic Memory Allocation in Embedded Systems
    - How malloc, calloc, realloc, free work (under the hood)
    - Fragmentation and why it matters
    - Memory leaks, double free, use-after-free
    - Custom allocators for synth voice pools
    - When to use static vs dynamic allocation (embedded best practices)
    - Debugging heap issues on PC and Pi
12. Data Storage: RAM, Flash, SD Card, and Non-volatile Options
    - Synth data types: patches, wavetables, samples, settings
    - Using SD cards: low-level and FatFs
    - Reading/writing binary and text data
    - Data structures for efficient patch storage
    - Practical: Save/load a patch to SD card in modular style
13. Advanced Debugging: Tools and Techniques
    - Printf, gdb, valgrind, static analysis
    - Debugging struct/pointer issues
    - Profiling memory usage and leaks
    - Simulating hardware faults in code
14. Best Practices, Pitfalls, and Idioms for Synth Code
    - Common C idioms for hardware projects
    - Defensive programming for reliability
    - Handling errors and edge cases
    - Checklist before going to hardware
15. Deep Practice: Full Modular Voice Implementation
    - Design and code a full polyphonic voice structure (oscillator, envelope, filter, routing)
    - Allocation, signal flow, and lifecycle
    - Testing and extending the modular codebase

---

## 7. Deep Dive: Structures in C

### 7.1 What are structs and why do we use them?

A **struct** (structure) is a user-defined data type in C that allows you to group variables of different types together under a single name. This is critical for modeling hardware modules (oscillators, filters, envelopes, etc.) in a way that directly reflects the physical boards and chips in classic synthesizers.

#### Why use structs?

- Encapsulate all the parameters/state for a module in one place.
- Simplify function interfaces (pass a pointer to a struct instead of dozens of arguments).
- Enable modular, maintainable code (each struct = one hardware-like "unit").
- Make code extensible (add new fields without breaking existing code).

### 7.2 Defining, declaring, and initializing structs

#### Struct definition

```c
struct Oscillator {
    float frequency;
    float amplitude;
    float phase;
    int   waveform; // 0=sine, 1=triangle, etc.
};
```

#### Declaring and initializing

```c
struct Oscillator osc1;
osc1.frequency = 440.0f;
osc1.amplitude = 1.0f;
osc1.phase = 0.0f;
osc1.waveform = 0; // sine

// Or with initializer
struct Oscillator osc2 = {220.0f, 0.8f, 0.0f, 1}; // triangle
```

#### Typedef for clarity

```c
typedef struct {
    float frequency;
    float amplitude;
    float phase;
    int   waveform;
} Oscillator;

Oscillator osc3 = {.frequency=330.0f, .amplitude=0.5f, .phase=0.0f, .waveform=2};
```

### 7.3 Structs as hardware modules: modeling boards and components

Think of each hardware board (e.g., an analog VCA, a digital oscillator) as a C struct:
- **Oscillator struct**: Models waveform generation, state, tuning.
- **Envelope struct**: Holds ADSR parameters, current stage, output value.
- **Filter struct**: Holds cutoff, resonance, filter state variables.

You can have arrays of these structs to model polyphony, just like a synth has multiple voice cards.

#### Example: Envelope Generator

```c
typedef struct {
    float attack;
    float decay;
    float sustain;
    float release;
    float output;
    int   stage;
    float timer;
} Envelope;
```

### 7.4 Nested structs, arrays of structs, and struct pointers

#### Nested structs

```c
typedef struct {
    Oscillator osc;
    Envelope   env;
    float      velocity;
    int        note;
} Voice;
```

#### Array of structs

```c
Voice voices[8]; // 8-voice polyphony
```

#### Struct pointers

```c
void trigger_voice(Voice *v, int note, float velocity) {
    v->note = note;
    v->velocity = velocity;
    // initialize other members as needed
}
```

### 7.5 Typedefs for clarity

Use `typedef` to avoid typing `struct` everywhere and for readability.

```c
typedef struct {
    // fields
} ModuleName;
```

### 7.6 Accessing struct members (dot and arrow operators)

- Use `.` to access members from a struct variable.
- Use `->` to access members from a pointer to a struct.

```c
Voice v;
v.velocity = 0.8f;

Voice *vp = &v;
vp->velocity = 0.9f;
```

### 7.7 Passing structs to functions (by value vs by pointer)

- **By value**: Copies the whole struct (costly, rarely used for large structs).
- **By pointer**: Passes the address, so the function can modify the original.

**Best practice:** Always pass large structs by pointer.

```c
void process_voice(Voice *v) {
    // modify v->env, v->osc, etc.
}
```

### 7.8 Memory layout of structs, alignment, and padding

- Compilers may add padding between struct members for alignment.
- Memory layout matters for hardware mapping, file I/O, and optimization.
- Use `sizeof()` to check struct size.

```c
printf("Voice struct size: %zu\n", sizeof(Voice));
```

#### Packing structs

To minimize padding (not always portable):

```c
#pragma pack(push, 1)
typedef struct {
    // fields
} PackedStruct;
#pragma pack(pop)
```

---

## 8. Unions and Bitfields: Efficient Data Packing

### 8.1 What is a union? When to use it?

A **union** allows different data types to share the same memory. Only one member can be used at a time.

**When to use:**
- To save memory (e.g., MIDI message bytes).
- To reinterpret data (e.g., raw register data).

#### Union example

```c
union Data {
    uint32_t as_int;
    float    as_float;
    uint8_t  bytes[4];
};

union Data d;
d.as_float = 3.14f;
printf("%x %x %x %x\n", d.bytes[0], d.bytes[1], d.bytes[2], d.bytes[3]);
```

### 8.2 Bitfields: packing flags and control words

A **bitfield** lets you pack multiple "flags" into a single integer, useful for hardware-like control registers.

```c
typedef struct {
    unsigned isActive : 1;
    unsigned note     : 7;
    unsigned velocity : 8;
} VoiceFlags;
```

**Practical:** Simulate hardware registers or efficiently store settings.

### 8.3 Practical audio applications: MIDI parsing, register simulation

**MIDI 1.0 status byte:**

```c
typedef union {
    uint8_t byte;
    struct {
        uint8_t channel : 4;
        uint8_t command : 4;
    };
} MidiStatus;
```

### 8.4 Warnings: portability, endianness

- Bitfield layout and union interpretation are compiler-dependent.
- Endianness: The order of bytes in memory varies between CPUs.
- Always test and explicitly document layout if sharing data between systems.

---

## 9. Organizing Modular Synth Code with Structs and Pointers

### 9.1 Hardware mapping: Each board as a struct/module

- Oscillator board: `Oscillator` struct.
- VCF board: `Filter` struct.
- Envelope board: `Envelope` struct.
- Voice card: `Voice` struct (contains pointers/instances of above).

### 9.2 Linking modules with pointers

Modules can be linked (like patch cables) using pointers.

```c
typedef struct Envelope Envelope;
typedef struct Oscillator Oscillator;

typedef struct {
    Oscillator *osc;
    Envelope   *env;
} Voice;
```

### 9.3 Function pointers in structs: simulating hardware flexibility

You can assign different processing functions at runtime.

```c
typedef float (*OscProcessFn)(Oscillator *);

typedef struct {
    float frequency;
    float phase;
    OscProcessFn process;
} Oscillator;
```

Assign different processing functions for sine, triangle, etc.

### 9.4 Example: Polymorphic processing with function pointers

```c
float sine_process(Oscillator *osc) { /* ... */ }
float square_process(Oscillator *osc) { /* ... */ }

Oscillator osc;
osc.process = sine_process;
float out = osc.process(&osc);

osc.process = square_process;
out = osc.process(&osc);
```

This pattern mimics the flexibility of hardware patching.

### 9.5 Building a modular signal chain

Define a chain of processing modules, passing audio buffers/pointers between them.

```c
typedef struct Module {
    void (*process)(struct Module *, float *in, float *out, int len);
    void *state;
    struct Module *next;
} Module;

void process_chain(Module *first, float *audio, int len) {
    Module *m = first;
    float buffer1[len], buffer2[len];
    float *in = audio, *out = buffer1;
    while (m) {
        m->process(m, in, out, len);
        in = out;
        out = (out == buffer1) ? buffer2 : buffer1;
        m = m->next;
    }
    // Final output is in in
}
```

---

## 10. Header Files, Include Guards, and Good Practice

### 10.1 What goes in headers vs C files

- **Headers (.h):** Struct definitions, typedefs, function prototypes, macros.
- **C files (.c):** Function implementations, static helpers.

### 10.2 Include guards (why and how)

Prevents multiple inclusion.

```c
#ifndef ENVELOPE_H
#define ENVELOPE_H
// header content
#endif
```

### 10.3 Modular folder structure for large projects

```
src/
  oscillators/oscillator.h
  oscillators/oscillator.c
  filters/filter.h
  filters/filter.c
  envelopes/envelope.h
  envelopes/envelope.c
  voices/voice.h
  voices/voice.c
main.c
```

### 10.4 Documenting module APIs

Use comments to describe each function and struct.  
For large projects, consider [Doxygen](https://www.doxygen.nl/) for automatic documentation.

---

*End of Part 2. Continue to next part for dynamic memory allocation, persistent data, advanced debugging, and a full practical modular synth voice example.*