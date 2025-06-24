# Chapter 4: C Programming (Advanced Topics: Pointers, Structs, Memory) - Part 1

---

## Table of Contents

1. Introduction: The Importance of Advanced C for Synth Programming
2. Deep Dive: Memory in C
   - Types of Memory (Stack, Heap, Static, Registers)
   - The C Memory Model (Variables in Memory)
   - Memory and Embedded Systems Constraints
3. Pointers: The Foundation of Modular, Hardware-Like C
   - What Is a Pointer?
   - Declaring, Assigning, and Using Pointers
   - The Address-of (`&`) and Dereference (`*`) Operators
   - Pointers and Function Arguments (By Value vs By Reference)
   - Pointers to Pointers
   - Pointer Arithmetic
   - Common Pointer Bugs and How to Avoid Them
   - Practical Examples: Manipulating Arrays, Strings, and Structs with Pointers
4. Arrays, Multidimensional Arrays, and Pointer Relationships
   - Declaring and Using Arrays
   - The Array-Pointer Duality in C
   - Passing Arrays to Functions
   - Dynamic Arrays (Heap Allocation)
   - Multidimensional Arrays in Audio Buffers
   - Cautions: Buffer Overflows, Bounds Checking
5. Practical Example: Building an Audio Buffer System (Mono and Polyphonic) Using Pointers and Arrays
6. Exercises and Practice Problems

---

## 1. Introduction: The Importance of Advanced C for Synth Programming

To emulate hardware modules in a synthesizer, your C code must be **modular** and **efficient**. This means:
- Structuring your code so each function (envelope, oscillator, filter) is its own “module,” just like a physical board.
- Passing data between modules safely and efficiently.
- Managing memory explicitly, especially in embedded contexts (where RAM is limited).
- Handling complex data structures (arrays of voices, parameter sets, audio buffers) using pointers and structs.

**Why care about modularity and memory?**
- **Portability:** Makes it easy to move code between PC/PortAudio and Pi/bare metal.
- **Maintainability:** Each module can be developed, tested, and reused separately.
- **Performance:** Proper memory usage is crucial for real-time audio.
- **Hardware Mapping:** Directly mimics how synths like the Emulator III or Synclavier were architected.

---

## 2. Deep Dive: Memory in C

### 2.1 Types of Memory in C

Understanding memory is essential for embedded programming.

| Memory Type  | Lifetime              | Scope                   | Use Cases                                   |
|--------------|----------------------|-------------------------|---------------------------------------------|
| Stack        | Function call/return  | Local to function       | Local variables, function calls             |
| Heap         | Allocated/freed by you| Global (via pointer)    | Dynamic arrays, buffers, objects            |
| Static       | Whole program run     | Local/global            | Static vars, globals, constants             |
| Registers    | CPU instruction cycle | Local to code section   | Optimized variables (rarely explicit in C)  |

#### A. Stack

- Fast, but limited in size (esp. on microcontrollers)
- Auto-cleaned when function returns
- Example:  
  ```c
  void foo() {
      int x = 5; // on the stack
  }
  ```

#### B. Heap

- Large, but you must manage lifetime
- Slower than stack
- Must be explicitly freed
- Example:  
  ```c
  int *buf = malloc(1024 * sizeof(int));
  // ... use buf ...
  free(buf);
  ```

#### C. Static

- Exists for whole program
- Use `static` keyword or global variables
- Example:  
  ```c
  static int counter = 0; // persists across calls
  ```

### 2.2 The C Memory Model (Variables in Memory)

A variable’s **scope** (where it can be accessed) and **lifetime** (how long it exists) are crucial.

#### Example: Local vs Global

```c
int global_var = 42; // global

void func() {
    int local_var = 5; // stack
    static int static_var = 0; // persists
}
```

**Embedded tip:**  
On a bare-metal Pi, global/static data is reserved at startup; stack is usually small (often a few KB to a few MB).

### 2.3 Memory Constraints in Embedded Systems

- RAM is limited: Pi 4 has much more than microcontrollers, but bare-metal code should be frugal.
- No virtual memory: Out-of-bounds pointers can crash or corrupt your program.
- Peripheral memory-mapped registers (e.g. for DACs) are accessed via specific addresses.

---

## 3. Pointers: The Foundation of Modular, Hardware-Like C

### 3.1 What Is a Pointer?

A pointer is a variable that **contains the address** of another variable.  
Think of a pointer as a “wire” running between boards/modules in your synth.

#### Basic Pointer Declaration

```c
int x = 10;
int *p; // p is a pointer to int
p = &x; // p now points to x
```

### 3.2 The Address-of (`&`) and Dereference (`*`) Operators

- `&x` gives the address of `x`.
- `*p` gives the value at the address `p` points to.

#### Example

```c
int y = 5;
int *ptr = &y;
printf("%d\n", *ptr); // prints 5
*ptr = 12; // changes y to 12
```

### 3.3 Declaring, Assigning, and Using Pointers

```c
float f = 3.14;
float *fp = &f; // fp points to f

char c = 'A';
char *cp = &c; // cp points to c
```

### 3.4 Pointers and Function Arguments

**By Value (default in C):**  
Passing a variable copies its value.

```c
void inc(int x) { x += 1; } // does NOT change original

int a = 10;
inc(a); // a is still 10
```

**By Reference (using pointers):**  
Passing a pointer allows the function to modify the original.

```c
void inc(int *x) { (*x) += 1; }

int a = 10;
inc(&a); // a is now 11
```

#### Why does this matter?

- To write modular code: e.g., pass a struct pointer to an oscillator module, so it can update its state.
- To avoid copying large data (e.g., audio buffers).

### 3.5 Pointers to Pointers

A pointer to a pointer is often needed for dynamic memory, arrays of pointers, and certain hardware APIs.

```c
int x = 7;
int *p = &x;
int **pp = &p;

printf("%d\n", **pp); // prints 7
```

#### Example Use Case: Voice Allocation Table

- An array of pointers to Oscillator structs: `Oscillator *voices[8];`
- A pointer to the array: `Oscillator **voice_table = voices;`

### 3.6 Pointer Arithmetic

You can add integers to pointers to “move” through memory.

```c
int arr[5] = {1,2,3,4,5};
int *ap = arr;
printf("%d\n", *(ap + 2)); // prints 3
```

**Caution:**  
Pointer arithmetic is type-aware: `ap + 2` advances by `2 * sizeof(int)` bytes.

### 3.7 Common Pointer Bugs and How to Avoid Them

- **Uninitialized pointers:** Always assign before use.
- **Dangling pointers:** Don’t use after free.
- **NULL pointers:** Check for `NULL` before dereferencing.
- **Buffer overruns:** Always stay within array bounds.

### 3.8 Practical Examples: Manipulating Arrays, Strings, and Structs with Pointers

#### Modifying an Array

```c
void fill_zeros(int *arr, int len) {
    for(int i = 0; i < len; ++i) arr[i] = 0;
}
```

#### Working with Strings (char arrays)

```c
void print_string(const char *s) {
    while(*s) {
        putchar(*s++);
    }
}
```

#### Passing Structs by Pointer

```c
typedef struct {
    float freq;
    float amp;
} LFO;

void set_lfo_freq(LFO *lfo, float freq) {
    lfo->freq = freq;
}
```

---

## 4. Arrays, Multidimensional Arrays, and Pointer Relationships

### 4.1 Declaring and Using Arrays

Arrays are blocks of contiguous memory.

```c
float audio_buf[512]; // mono buffer

// Access elements
audio_buf[0] = 0.0f;
audio_buf[511] = 1.0f;
```

### 4.2 The Array-Pointer Duality

- `audio_buf` is equivalent to `&audio_buf[0]` in expressions.
- Arrays are passed to functions as pointers.

### 4.3 Passing Arrays to Functions

```c
void process(float *buf, int len) {
    for(int i = 0; i < len; ++i) {
        buf[i] *= 0.5f; // halve amplitude
    }
}
```

### 4.4 Dynamic Arrays (Heap Allocation)

For large or variable-sized buffers:

```c
float *stereo_buf = malloc(2 * 1024 * sizeof(float)); // stereo, 1024 samples/ch
if (stereo_buf == NULL) {/* handle error */}
free(stereo_buf);
```

### 4.5 Multidimensional Arrays for Audio Buffers

**Static:**
```c
float poly_buf[8][512]; // 8 voices, 512 samples each
```

**Dynamic:**
```c
float **poly_buf = malloc(num_voices * sizeof(float *));
for (int v = 0; v < num_voices; ++v) {
    poly_buf[v] = malloc(bufsize * sizeof(float));
}
...
for (int v = 0; v < num_voices; ++v) free(poly_buf[v]);
free(poly_buf);
```

### 4.6 Bounds Checking and Buffer Overflows

**ALWAYS** check array sizes before writing:

```c
void safe_write(float *buf, int len, int idx, float val) {
    if(idx >= 0 && idx < len) buf[idx] = val;
}
```

### 4.7 Practical Example: Combining Arrays, Pointers, and Structs

Suppose you have a struct for a voice:

```c
typedef struct {
    float freq;
    float amp;
    float buffer[256];
} Voice;
```

You can make an array of voices:

```c
Voice voices[8];
for(int v = 0; v < 8; ++v) {
    voices[v].freq = 440.0f * (v+1);
}
```

You can pass pointers to these to functions, mimicking passing hardware signals/patch cords.

---

## 5. Practical Example: Building an Audio Buffer System (Mono and Polyphonic) Using Pointers and Arrays

### 5.1 Mono Buffer

```c
#define BUF_SIZE 512
float mono_buf[BUF_SIZE];

// Fill with a sine wave
for(int i = 0; i < BUF_SIZE; ++i) {
    mono_buf[i] = sinf(2.0f * M_PI * 440.0f * i / 48000.0f);
}
```

### 5.2 Polyphonic Buffer

```c
#define NUM_VOICES 8
float poly_buf[NUM_VOICES][BUF_SIZE];

// Fill with different frequencies
for(int v = 0; v < NUM_VOICES; ++v) {
    for(int i = 0; i < BUF_SIZE; ++i) {
        poly_buf[v][i] = sinf(2.0f * M_PI * (220.0f + 110.0f * v) * i / 48000.0f);
    }
}
```

### 5.3 Modular Processing

Pass each buffer to an effect/filter/envelope module via pointer:

```c
void apply_gain(float *buf, int len, float gain) {
    for(int i = 0; i < len; ++i) buf[i] *= gain;
}

for(int v = 0; v < NUM_VOICES; ++v) {
    apply_gain(poly_buf[v], BUF_SIZE, 0.7f);
}
```

### 5.4 Dynamic Allocation for Arbitrary Polyphony

```c
int voices = 16;
float **dyn_poly_buf = malloc(voices * sizeof(float *));
for (int v = 0; v < voices; ++v) {
    dyn_poly_buf[v] = malloc(BUF_SIZE * sizeof(float));
}

// ... use buffers ...

for (int v = 0; v < voices; ++v) free(dyn_poly_buf[v]);
free(dyn_poly_buf);
```

---

## 6. Exercises and Practice Problems

1. Write a function that takes a pointer to an array, its length, and fills it with a sawtooth wave.
2. Write a function that inverts (negates) all values in a float array, given the pointer and length.
3. Dynamically allocate a 2D buffer for 16 voices, each with 1024 samples. Free all memory after use.
4. Modify a struct from earlier to include a pointer to a dynamic buffer as a member.
5. Write a function to copy one audio buffer to another using pointers.

---

**End of Part 1. Continue to Part 2 for structs, modular code organization, memory management, file separation, and advanced debugging.**