# Workstation Chapter 03: Advanced C for Large Projects (Part 3)
## Advanced Structs, Modularization, and Building Complex Data Structures

---

## Table of Contents

1. Introduction to Modular C Programming
2. Deep Dive on Structs, Typedef, and Unions
3. Organizing Code: Header and Source Files
4. Project-Wide Data Structures for Workstation Engines
5. Modularization Patterns: Encapsulation, Separation of Concerns
6. Building and Using Linked Data Structures
7. Enumerations, Flags, and Bitfields for State and Control
8. Callback Functions and Function Pointers
9. Practice Section 3: Defining and Using Modules
10. Exercises

---

## 1. Introduction to Modular C Programming

As your workstation project grows, organizing your code into clear, maintainable modules becomes essential.  
**Modular programming** means breaking your program into separate, reusable pieces (“modules”), each with a well-defined interface and responsibility.

### Why Modularize?

- **Clarity:** Each file/module does one job—oscillator, envelope, filter, MIDI, etc.
- **Reusability:** Modules can be tested or reused in other projects.
- **Teamwork:** Multiple people can work on different modules without stepping on each other’s toes.
- **Scalability:** Easier to add features or fix bugs.

### The Anatomy of a Module

A typical C module has:
- A **header file** (`.h`): contains public declarations, types, and documentation.
- A **source file** (`.c`): contains the actual implementation.

**Example:**
- `oscillator.h`: Declares the Oscillator struct, function prototypes.
- `oscillator.c`: Implements oscillator creation, waveform generation, etc.

---

## 2. Deep Dive on Structs, Typedef, and Unions

### 2.1 Advanced Structs

Structs can contain other structs, arrays, and pointers. This is crucial for representing complex audio objects.

**Example: Voice with Envelope and Oscillator**
```c
typedef struct {
    float attack, decay, sustain, release;
} Envelope;

typedef struct {
    float frequency, amplitude, phase;
    int waveform;
} Oscillator;

typedef struct {
    Oscillator osc;
    Envelope env;
    int active;
    float velocity;
    char patchName[32];
} Voice;
```

### 2.2 Typedef for Cleaner Code

- `typedef` creates an alias for a type.
- Makes code more readable and maintainable.

**Example:**
```c
typedef struct Oscillator Oscillator;
struct Oscillator {
    float freq;
    // ...
};
```

Now you can write `Oscillator` instead of `struct Oscillator`.

### 2.3 Unions for Memory Efficiency

Unions allow different fields to share the same memory, useful for efficient DSP buffers or polymorphic data.

**Example:**
```c
typedef union {
    int i;
    float f;
    void *ptr;
} DataValue;
```

---

## 3. Organizing Code: Header and Source Files

### 3.1 Why Separate .h and .c Files?

- **Header files** expose the public API (application programming interface) of your module.
- **Source files** contain the private implementation.

This separation:
- Prevents code duplication.
- Allows the compiler to check for consistent declarations.
- Enables modular builds and faster compilation.

### 3.2 Header Guards

Every header should use guards to prevent multiple inclusion.

**Example:**
```c
#ifndef OSCILLATOR_H
#define OSCILLATOR_H

typedef struct Oscillator Oscillator;
Oscillator* oscillator_create(float freq);
void oscillator_destroy(Oscillator *osc);

#endif // OSCILLATOR_H
```

### 3.3 Including Headers

- Use `#include "oscillator.h"` for your own headers.
- Use `#include <stdio.h>` for system headers.

### 3.4 Source File Implementation

**oscillator.c**
```c
#include "oscillator.h"
#include <stdlib.h>

struct Oscillator {
    float freq;
    // ...
};

Oscillator* oscillator_create(float freq) {
    Oscillator *osc = malloc(sizeof(Oscillator));
    if (osc) osc->freq = freq;
    return osc;
}

void oscillator_destroy(Oscillator *osc) {
    free(osc);
}
```

---

## 4. Project-Wide Data Structures for Workstation Engines

### 4.1 Hierarchy of Audio Objects

- **Voice**: One note, one oscillator and envelope.
- **Patch**: One playable sound, with parameters and FX.
- **Multi**: Multiple patches (multi-timbral).
- **Project**: Complete set of patches, multis, sequences, etc.

**Example:**
```c
typedef struct {
    Voice voices[16];
} Patch;
typedef struct {
    Patch patches[8];
} Multi;
typedef struct {
    Multi multis[4];
    char projectName[64];
} Project;
```

### 4.2 Pointers for Dynamic Data

- For variable numbers (e.g., user can load any number of samples), use pointers and dynamic allocation.

**Example:**
```c
typedef struct {
    char *name;
    float *samples;
    int length;
} Sample;
```

### 4.3 Linked Lists for Flexible Management

**Example:**
```c
typedef struct SampleNode {
    Sample sample;
    struct SampleNode *next;
} SampleNode;
```

---

## 5. Modularization Patterns: Encapsulation, Separation of Concerns

### 5.1 Encapsulation

- Hide internal details of a module.
- Only expose necessary API via the header file.

### 5.2 Separation of Concerns

- Each module should do **one thing**: oscillator generation, envelope shaping, etc.
- High-level modules combine these for more complex tasks.

### 5.3 Static Functions for Private Implementation

- Use `static` in `.c` files to restrict function scope to the file.

**Example:**
```c
// oscillator.c
static float generate_sine(float phase) {
    // Only visible in oscillator.c
}
```

---

## 6. Building and Using Linked Data Structures

### 6.1 Why Linked Lists?

- Dynamic resource management: e.g., voices, MIDI events, effect chains.
- Efficient insert/remove operations.

**Example: Dynamic Voice List**
```c
typedef struct VoiceNode {
    Voice voice;
    struct VoiceNode *next;
} VoiceNode;
```

### 6.2 Creating and Traversing a List

```c
VoiceNode *head = NULL;

// Add a voice
VoiceNode *newNode = malloc(sizeof(VoiceNode));
newNode->voice = myVoice;
newNode->next = head;
head = newNode;

// Traverse and process
for (VoiceNode *cur = head; cur != NULL; cur = cur->next) {
    process_voice(&cur->voice);
}
```

### 6.3 Removing Nodes and Memory Management

- Always free nodes when removing them to avoid leaks.

---

## 7. Enumerations, Flags, and Bitfields for State and Control

### 7.1 Enumerations: Named States and Types

```c
typedef enum {
    STATE_IDLE,
    STATE_ATTACK,
    STATE_DECAY,
    STATE_SUSTAIN,
    STATE_RELEASE
} EnvState;
```

### 7.2 Flags and Bitfields

- Use for efficient status tracking (e.g., voice active, muted, soloed)
- Bitwise operations (`|`, `&`, `~`, `^`) let you set/clear/test flags.

**Example:**
```c
#define VOICE_ACTIVE (1 << 0)
#define VOICE_MUTED  (1 << 1)

uint8_t status = 0;
status |= VOICE_ACTIVE; // Set active
if (status & VOICE_ACTIVE) { /* ... */ }
status &= ~VOICE_ACTIVE; // Clear active
```

### 7.3 Struct Bitfields

- Save space in embedded contexts.

**Example:**
```c
typedef struct {
    unsigned int active : 1;
    unsigned int muted : 1;
    unsigned int soloed : 1;
} VoiceFlags;
```

---

## 8. Callback Functions and Function Pointers

### 8.1 What Is a Function Pointer?

- A variable that stores the address of a function.
- Used for callbacks, plugin APIs, flexible DSP chains.

**Example:**
```c
typedef float (*WaveformFunction)(float phase);

float sine(float phase) { return sinf(phase); }
float square(float phase) { return (phase < 0.5f) ? 1.0f : -1.0f; }

WaveformFunction oscFunc = sine;
float output = oscFunc(0.25f);
```

### 8.2 Registering Callbacks

- User interface, MIDI, or real-time audio systems often use callbacks.

**Example:**
```c
typedef void (*MidiCallback)(uint8_t status, uint8_t data1, uint8_t data2);
void set_midi_callback(MidiCallback cb);
```

---

## 9. Practice Section 3: Defining and Using Modules

### 9.1 Oscillator Module

- Define a header with the oscillator struct and API.
- Implement functions to create, destroy, and set parameters.
- Use function pointers for waveform selection.

### 9.2 Voice Management Module

- Use a linked list to manage active voices.
- Implement add, remove, and search functions.

### 9.3 Patch Management

- Use structs with pointers for flexible patch storage.
- Implement load, save, and recall functions.

---

## 10. Exercises

1. **Module Creation**
   - Write `filter.h` and `filter.c` for a basic low-pass filter module. Define the struct, API, and implementation.

2. **Linked List Practice**
   - Write code to add, remove, and traverse nodes in a list of MIDI events.

3. **Bitfield Usage**
   - Implement a `VoiceFlags` struct with at least three flags and test setting/clearing them.

4. **Function Pointer Table**
   - Create an array of function pointers for oscillator waveforms. Write code to select and call them based on an enum.

5. **Encapsulation**
   - Modify an existing module to hide all implementation details (using `typedef struct X X;` in the header).

6. **Callback Registration**
   - Implement a simple callback system for UI button presses.

7. **Project-Wide Data Structure**
   - Design a struct for a “project” that includes multis, patches, and user metadata. Write initialization and cleanup code.

---

**End of Part 3.**  
_Part 4 will cover memory management in large projects, advanced modularization, error handling, and defensive programming—all with practical examples and exercises for your workstation._
