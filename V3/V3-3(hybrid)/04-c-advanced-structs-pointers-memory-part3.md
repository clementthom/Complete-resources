# Chapter 4: C Programming (Advanced Topics: Pointers, Structs, Memory) - Part 3

---

## Table of Contents

11. Deep Dive: Dynamic Memory Allocation in Embedded Systems
    - The heap: how malloc, calloc, realloc, free work (under the hood)
    - Stack vs heap: real-world usage and synth-specific tradeoffs
    - Fragmentation and why it matters for long-running synths
    - Memory leaks, double free, use-after-free: examples and prevention
    - Custom allocators for synth voice pools
    - When to use static vs dynamic allocation (embedded best practices)
    - Debugging heap issues on PC and Pi (tools and strategies)
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

## 11. Deep Dive: Dynamic Memory Allocation in Embedded Systems

### 11.1 The Heap: How `malloc`, `calloc`, `realloc`, `free` Work

#### Heap Overview

The **heap** is a region of memory managed by the programmer, used to allocate memory at runtime (as opposed to the stack, which is managed automatically). In embedded systems, the heap is typically much smaller than on a PC and may not exist at all on very small microcontrollers.

#### How Dynamic Allocation Works

- **malloc(size_t size):** Allocates a block of at least `size` bytes. Returns a pointer to the block, or NULL if out of memory.
    ```c
    float *buf = malloc(256 * sizeof(float));
    if (!buf) { /* handle error */ }
    ```
- **calloc(num, size):** Like malloc, but also zero-initializes the block.
    ```c
    float *buf = calloc(256, sizeof(float));
    ```
- **realloc(ptr, new_size):** Changes the size of a previously allocated block. May move the block in memory.
    ```c
    buf = realloc(buf, 512 * sizeof(float));
    ```
- **free(ptr):** Releases the memory block for future use.
    ```c
    free(buf);
    ```

#### Under the Hood

- The C runtime manages a "free list" of blocks.
- Each allocation may add metadata before or after the block for tracking.
- Fragmentation can occur if you frequently allocate and free blocks of varying sizes.

#### Embedded Note

- On bare-metal Pi or MCUs, you may need to provide your own heap implementation (see linker scripts).
- Memory is precious—allocate only what you need, free as soon as done.

### 11.2 Stack vs Heap: Usage and Tradeoffs

| Feature      | Stack                       | Heap                       |
|--------------|----------------------------|----------------------------|
| Lifetime     | Automatic (function scope) | Manual (until freed)       |
| Speed        | Very fast                  | Slower (managed at runtime)|
| Size         | Limited (KBs-MBs)          | Larger, but still limited  |
| Allocation   | Fixed at compile time      | Variable at runtime        |
| Use case     | Local variables, recursion | Buffers, polyphonic voices |

**Synth Example:**  
- Stack: Temporary filter coefficients in a function.
- Heap: Buffers for 8 voices of audio, where the number of voices can change at runtime.

### 11.3 Fragmentation and Why It Matters

**Fragmentation** occurs when free memory becomes split into small, non-contiguous chunks, making large allocations impossible even if total free memory is sufficient.

- Synths are often real-time and run for hours—fragmentation can cause subtle bugs, dropouts, or crashes.
- **Prevention:** 
    - Allocate large buffers up front and reuse them.
    - Avoid frequent allocation/free cycles inside the audio callback.
    - Use **static allocation** for fixed-size data when possible.

### 11.4 Memory Leaks, Double Free, Use-After-Free

#### Memory Leak

- Forgetting to call `free()`. The memory remains reserved and unusable until the program ends.
    ```c
    float *buf = malloc(1024 * sizeof(float));
    // ... but never call free(buf);
    ```

#### Double Free

- Calling `free()` twice on the same pointer can corrupt the heap.
    ```c
    free(buf);
    free(buf); // ERROR
    ```

#### Use-After-Free

- Accessing memory after it’s been freed. This leads to undefined behavior.
    ```c
    free(buf);
    buf[0] = 1.0f; // ERROR
    ```

#### Prevention Tips

- Always set pointers to NULL after freeing.
    ```c
    free(buf);
    buf = NULL;
    ```
- Use tools (valgrind, sanitizers) on PC to check.

### 11.5 Custom Allocators for Synth Voice Pools

For real-time reliability, you might want to implement a simple pool allocator:

```c
#define MAX_VOICES 16
Voice voice_pool[MAX_VOICES];
int   voice_in_use[MAX_VOICES] = {0};

Voice* alloc_voice(void) {
    for (int i = 0; i < MAX_VOICES; ++i) {
        if (!voice_in_use[i]) {
            voice_in_use[i] = 1;
            return &voice_pool[i];
        }
    }
    return NULL; // No free voices
}

void free_voice(Voice* v) {
    int idx = v - voice_pool;
    if (idx >= 0 && idx < MAX_VOICES) voice_in_use[idx] = 0;
}
```

### 11.6 When to Use Static vs Dynamic Allocation

**Static Allocation:**
- Use for critical, fixed-size data (audio buffers, voices).
- Predictable, no fragmentation.

**Dynamic Allocation:**
- Use for optional or variable-sized data.
- Be careful in real-time code paths (audio callback).

**Embedded Best Practice:**
- Prefer static allocation for anything inside the audio engine.

### 11.7 Debugging Heap Issues

#### PC Tools

- **valgrind**: Detects leaks and invalid accesses.
    ```sh
    valgrind --leak-check=full ./your_synth
    ```
- **AddressSanitizer**: Compile with `-fsanitize=address`.
- **gdb**: Use breakpoints and watch memory.

#### Bare-metal / Pi

- Add debug prints before/after allocation.
- Check heap size at startup and after major allocations.
- Use test harnesses on PC before porting to hardware.

---

## 12. Data Storage: RAM, Flash, SD Card, and Non-volatile Options

### 12.1 Synth Data Types

- **Patches:** Sets of synth parameters (oscillator, filter, envelope settings).
- **Wavetables/Samples:** Audio data for playback or synthesis.
- **Settings:** User preferences, global config.
- **Presets:** Factory or user patches.

### 12.2 Using SD Cards: Low-Level and FatFs

**Why SD cards?**
- Large, inexpensive storage for samples and patches.
- Ubiquitous in Pi projects.

**Low-Level Access:**
- On bare-metal, you may need to write/read blocks directly.
- Libraries like [FatFs](http://elm-chan.org/fsw/ff/00index_e.html) manage FAT filesystems.

**Example: Initializing FatFs (bare-metal)**
```c
FATFS fs;
FRESULT fr = f_mount(&fs, "", 1);
if (fr != FR_OK) { /* handle error */ }
```

### 12.3 Reading/Writing Binary and Text Data

**Writing a struct to a file (patch save):**
```c
FILE *fp = fopen("voice1.pch", "wb");
if (fp) {
    fwrite(&voice, sizeof(Voice), 1, fp);
    fclose(fp);
}
```

**Reading:**
```c
FILE *fp = fopen("voice1.pch", "rb");
if (fp) {
    fread(&voice, sizeof(Voice), 1, fp);
    fclose(fp);
}
```

**Text format (human-editable):**
```c
fprintf(fp, "freq=%f,amp=%f\n", voice.osc.frequency, voice.osc.amplitude);
```

**Binary format (efficient, but not editable):**
- Fast, small, but not portable across architectures if struct layout changes.

### 12.4 Data Structures for Efficient Patch Storage

**Patch struct example:**
```c
typedef struct {
    char name[16];
    Oscillator osc;
    Envelope env;
    Filter    filt;
    // ... more modules ...
} Patch;
```
- You can save/load arrays of Patch structs for multiple presets.

**Considerations:**
- Save/load version numbers for future compatibility.
- Optionally compress large data (samples).

### 12.5 Practical: Save/Load Patch to SD Card (Modular Style)

```c
// Save
Patch mypatch = {/* fill in fields */};
FILE *fp = fopen("patch001.pch", "wb");
if (fp) {
    fwrite(&mypatch, sizeof(Patch), 1, fp);
    fclose(fp);
}

// Load
Patch loadpatch;
FILE *fp = fopen("patch001.pch", "rb");
if (fp && fread(&loadpatch, sizeof(Patch), 1, fp) == 1) {
    // Loaded successfully
}
```

**FatFs note:** Replace `fopen`, `fwrite`, `fread` with `f_open`, `f_write`, `f_read` as per FatFs documentation on bare-metal Pi.

### 12.6 Non-volatile Flash

- On microcontrollers, use built-in flash or external EEPROM for storing small amounts of settings.
- On Pi, this is rarely needed as SD card is primary storage.

---

## 13. Advanced Debugging: Tools and Techniques

### 13.1 Printf Debugging

- Print values of variables, struct fields, and memory addresses.
    ```c
    printf("Osc freq: %f, amp: %f\n", osc.frequency, osc.amplitude);
    ```

- On bare-metal Pi, you may need to implement UART-based logging.

### 13.2 gdb (GNU Debugger)

- Set breakpoints, step through code, inspect memory.
    ```sh
    gdb ./your_synth
    b main
    run
    print osc
    ```

### 13.3 valgrind

- Detects memory leaks, use-after-free, invalid memory access.
    ```sh
    valgrind --leak-check=full ./your_synth
    ```

### 13.4 Static Analysis

- Tools like `cppcheck`, `clang-tidy` help find bugs without running code.

### 13.5 Debugging Struct/Pointer Issues

- Always initialize structs and pointers before use.
- Print pointer addresses for sanity checking.
    ```c
    printf("Oscillator pointer: %p\n", (void*)&osc);
    ```
- Use tools to step through allocation and freeing.

### 13.6 Profiling Memory Usage and Leaks

- Use valgrind’s massif tool or similar to watch memory growth over time.
- Check that all memory allocated is freed before program exit.

### 13.7 Simulating Hardware Faults in Code

- Intentionally corrupt data (e.g., flip a pointer to NULL) to test error handling.
- Write unit tests for all edge cases.

---

## 14. Best Practices, Pitfalls, and Idioms for Synth Code

### 14.1 Common C Idioms for Hardware Projects

- Use `const` for read-only data.
- Use enums for states, modes, and waveforms.
- Use function pointers for polymorphic behavior.

### 14.2 Defensive Programming for Reliability

- Always check pointer validity before use.
- Validate array bounds before writing.
- Use asserts in development to catch bugs early.
    ```c
    assert(ptr != NULL);
    ```

### 14.3 Handling Errors and Edge Cases

- Return error codes from functions, not just void.
    ```c
    int result = f_open(...);
    if (result != 0) { /* handle error */ }
    ```
- Log errors to console, file, or UART.

### 14.4 Checklist Before Going to Hardware

- All pointers initialized and freed.
- No memory leaks or overruns (checked with valgrind).
- Struct sizes known and checked for alignment.
- All buffers zeroed before use.
- Functions documented in headers.

---

## 15. Deep Practice: Full Modular Voice Implementation

### 15.1 Design a Polyphonic Voice Structure

```c
typedef struct {
    Oscillator osc;
    Envelope   env;
    Filter     fil;
    float      buffer[BUFFER_SIZE];
    int        active;
} Voice;

Voice voices[NUM_VOICES];
```

### 15.2 Allocation, Signal Flow, and Lifecycle

- When a note-on event is received, allocate an inactive voice, initialize its modules, and mark it active.
- Each sample/frame:
    1. Generate waveform via oscillator.
    2. Apply envelope to amplitude.
    3. Pass through filter.
    4. Store in buffer.

### 15.3 Example: Polyphonic Processing Loop

```c
for (int v = 0; v < NUM_VOICES; ++v) {
    if (voices[v].active) {
        float osc_out = osc_process(&voices[v].osc);
        float env_out = env_process(&voices[v].env);
        float fil_out = filter_process(&voices[v].fil, osc_out * env_out);
        voices[v].buffer[sample_idx] = fil_out;
    }
}
```

### 15.4 Testing and Extending the Modular Codebase

- Write unit tests for each module.
- Add new waveforms, filter types, modulation sources as needed.
- Profile memory and CPU usage to ensure real-time performance.

### 15.5 Example: Voice Allocation Strategy

Implement round-robin, oldest-release, or priority-based allocation for voice stealing.

```c
int find_free_voice() {
    for (int v = 0; v < NUM_VOICES; ++v)
        if (!voices[v].active) return v;
    // If all active, choose one to steal (e.g., quietest or oldest)
    return 0;
}
```

---

## 16. Summary

- Mastering pointers, structs, and memory is critical for modular, hardware-inspired synth code.
- Use static allocation for real-time reliability, dynamic allocation for flexibility.
- Organize code so each module is self-contained, testable, and reusable—just like a hardware board.
- Use debugging tools and defensive programming to catch bugs early.
- Practice by building, testing, and extending a full modular voice structure.

---

*End of Chapter 4 (Advanced C: Pointers, Structs, Memory)*