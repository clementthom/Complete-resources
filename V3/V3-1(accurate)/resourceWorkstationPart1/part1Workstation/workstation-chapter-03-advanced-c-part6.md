# Workstation Chapter 03: Advanced C for Large Projects (Part 6)
## Advanced Data Structures, Real-Time Scheduling, and Synchronization

---

## Table of Contents

1. Introduction: Why Advanced Data Structures Matter in Audio/Embedded C
2. Linked Lists: Singly, Doubly, and Circular
3. Stacks and Queues: Managing Undo, Redo, and Event Buffers
4. Trees: Organizing Patches, Presets, and Hierarchies
5. Hash Tables: Fast Lookup for Patch Names, MIDI Mappings, and Caching
6. Designing a Modular, Multi-Voice, Multi-Timbral Engine
7. Real-Time Scheduling: Audio and MIDI Event Timing
8. Synchronization and Concurrency: Safe Data Sharing in Audio Systems
9. Practice Section 6: Implementing Data Structures for a Synth Engine
10. Exercises

---

## 1. Introduction: Why Advanced Data Structures Matter in Audio/Embedded C

Modern workstation synths are complex, “living” systems:
- Dozens or hundreds of voices and effects
- Real-time MIDI, audio, and UI events
- Large patch libraries, fast lookup for names and parameters
- Undo/redo, non-destructive editing, automation lanes, and more

**The only way to handle this complexity is with appropriate data structures:**
- Lists for voices, event queues, parameters
- Trees for organizing objects and UI menus
- Hash tables for fast lookup (patch names, MIDI mappings)
- Stacks for undo/redo, event history

**Mastering these structures is a must to build a robust, scalable workstation.**

---

## 2. Linked Lists: Singly, Doubly, and Circular

### 2.1 Singly Linked List

Perfect for dynamic voice allocation, event queues, or plugin chains.

**Definition:**
```c
typedef struct Voice {
    float freq;
    int active;
    struct Voice *next;
} Voice;
```

**Basic Operations:**
- Insert at head/tail
- Delete node
- Traverse list

**Insert at head:**
```c
Voice *add_voice(Voice *head, float freq) {
    Voice *newNode = malloc(sizeof(Voice));
    if (!newNode) return head; // handle error
    newNode->freq = freq;
    newNode->active = 1;
    newNode->next = head;
    return newNode;
}
```

**Traverse:**
```c
for (Voice *v = head; v != NULL; v = v->next) {
    process_voice(v);
}
```

### 2.2 Doubly Linked List

Bidirectional traversal; useful for undo/redo, playlist, or patch editing.

```c
typedef struct Event {
    int type;
    struct Event *prev;
    struct Event *next;
} Event;
```

**Insert, remove, and walk in both directions.**

### 2.3 Circular List

Head’s `next` points to tail, or tail’s `next` points to head; good for round-robin scheduling.

---

## 3. Stacks and Queues: Managing Undo, Redo, and Event Buffers

### 3.1 Stack (LIFO: Last-In, First-Out)

Used for:
- Undo/redo (store previous states)
- Nested menu navigation

**Implementation:**
```c
typedef struct StackNode {
    void *data;
    struct StackNode *next;
} StackNode;

void push(StackNode **top, void *data) {
    StackNode *node = malloc(sizeof(StackNode));
    node->data = data;
    node->next = *top;
    *top = node;
}

void *pop(StackNode **top) {
    if (!*top) return NULL;
    StackNode *node = *top;
    void *data = node->data;
    *top = node->next;
    free(node);
    return data;
}
```

### 3.2 Queue (FIFO: First-In, First-Out)

Used for:
- MIDI/event scheduling
- Audio buffers

**Implementation:**
```c
typedef struct QueueNode {
    void *data;
    struct QueueNode *next;
} QueueNode;

typedef struct {
    QueueNode *front, *rear;
} Queue;

void enqueue(Queue *q, void *data) {
    QueueNode *node = malloc(sizeof(QueueNode));
    node->data = data;
    node->next = NULL;
    if (q->rear) q->rear->next = node;
    else q->front = node;
    q->rear = node;
}

void *dequeue(Queue *q) {
    if (!q->front) return NULL;
    QueueNode *node = q->front;
    void *data = node->data;
    q->front = node->next;
    if (!q->front) q->rear = NULL;
    free(node);
    return data;
}
```

---

## 4. Trees: Organizing Patches, Presets, and Hierarchies

### 4.1 Why Trees?

- Represent hierarchical data: menus, patch banks, modulation routings
- Fast search, insert, and delete

### 4.2 Binary Trees

**Basic binary tree for patch organization:**
```c
typedef struct PatchNode {
    char name[32];
    struct PatchNode *left, *right;
} PatchNode;
```

### 4.3 Traversal

- In-order (alphabetical)
- Pre-order, post-order (for saving/loading)

**In-order traversal:**
```c
void print_tree(PatchNode *node) {
    if (node) {
        print_tree(node->left);
        printf("%s\n", node->name);
        print_tree(node->right);
    }
}
```

### 4.4 Other Trees

- N-ary trees for UI menus (each node has a list of children)
- Balanced trees (AVL, red-black) for very large collections

---

## 5. Hash Tables: Fast Lookup for Patch Names, MIDI Mappings, and Caching

### 5.1 Why Hash Tables?

- O(1) average time for insert/search/delete
- Essential for fast UI, patch and event lookup

### 5.2 Basic Hash Table Implementation

**Simple example:**
```c
#define TABLE_SIZE 128

typedef struct Entry {
    char key[32];
    void *value;
    struct Entry *next;
} Entry;

Entry *hash_table[TABLE_SIZE] = {0};

unsigned int hash(const char *key) {
    unsigned int h = 0;
    while (*key) h = (h << 5) + *key++;
    return h % TABLE_SIZE;
}

void insert(const char *key, void *value) {
    unsigned int idx = hash(key);
    Entry *e = malloc(sizeof(Entry));
    strncpy(e->key, key, 32);
    e->value = value;
    e->next = hash_table[idx];
    hash_table[idx] = e;
}
```

### 5.3 Collisions and Chaining

- Multiple entries at the same index are handled by linked lists (“chaining”)

### 5.4 Usage in Audio Workstations

- Patch and parameter lookup by name
- MIDI note/event mapping
- Cache for sample files, plugin handles

---

## 6. Designing a Modular, Multi-Voice, Multi-Timbral Engine

### 6.1 Modular Architecture

- Each voice is an independent module (oscillator, envelope, filter)
- Voices managed in a list or pool
- Each patch is a collection of parameter sets and modules

### 6.2 Multi-Timbral Support

- Multiple independent “parts,” each with its own patch, MIDI channel, and output routing

**Example:**
```c
typedef struct {
    Voice *voices; // array or list
    int num_voices;
    char patch_name[32];
} Part;

typedef struct {
    Part parts[16];
} MultiTimbralEngine;
```

### 6.3 Dynamic Allocation and Voice Stealing

- If all voices are in use, choose one to “steal” for new notes
- Use linked lists or pools for efficient allocation

---

## 7. Real-Time Scheduling: Audio and MIDI Event Timing

### 7.1 Why Scheduling?

- Audio and MIDI events must happen at precise times
- Buffer-based processing: schedule events for the correct sample

### 7.2 Event Structures

- Timestamped events: `sample_time`, `midi_event`, `note_on`, `note_off`

```c
typedef struct MidiEvent {
    unsigned int time; // sample time
    uint8_t status, data1, data2;
    struct MidiEvent *next;
} MidiEvent;
```

### 7.3 Scheduling Algorithm

- Maintain a queue of future events (sorted by time)
- On each audio callback, process all events due in the current buffer

### 7.4 Interrupts and Timers

- Use hardware timers or audio callbacks for real-time scheduling
- Respond to MIDI input or UI events quickly, queue for processing in audio thread

---

## 8. Synchronization and Concurrency: Safe Data Sharing in Audio Systems

### 8.1 The Problem

- UI, MIDI, and audio processing may run on different threads or interrupts
- Data shared across threads must be protected to prevent corruption

### 8.2 Lock-Free Techniques

- Use ring buffers for communication between threads (UI → audio, MIDI → audio)
- Avoid mutexes in the audio thread (may cause dropouts)

**Example: Lock-Free MIDI Queue**
```c
typedef struct {
    MidiEvent buffer[128];
    int head, tail;
} MidiQueue;
```
- Producer (MIDI thread) writes to head; consumer (audio thread) reads from tail

### 8.3 Atomic Operations

- Use `stdatomic.h` (C11) for atomic variables (e.g., flags, counters)
- Ensures thread-safe updates without locks

### 8.4 Volatile Keyword

- Use `volatile` for variables modified in interrupts (prevents compiler optimization from caching)

---

## 9. Practice Section 6: Implementing Data Structures for a Synth Engine

### 9.1 Voice List

- Implement a singly linked list of voices
- Add, remove, and traverse voices

### 9.2 Undo Stack

- Implement a stack for undo/redo of parameter changes

### 9.3 Patch Tree

- Build a binary tree of patch names, search and print them in order

### 9.4 Hash Table

- Implement a hash table for fast patch name lookup

### 9.5 MIDI Event Scheduler

- Queue MIDI events with sample timestamps, process them in order

### 9.6 Lock-Free MIDI Queue

- Use a ring buffer to pass MIDI events from UI thread to audio thread

---

## 10. Exercises

1. **Linked List Mastery**
   - Write functions to add/remove voices from a linked list. Traverse and print all active voices, then free the list.

2. **Undo/Redo Stack**
   - Implement push/pop for undoing patch parameter changes. Test with a series of changes and undos/redos.

3. **Patch Tree**
   - Build a binary tree of patch names. Implement search, insert, and in-order traversal to list all patches alphabetically.

4. **Hash Table**
   - Write a hash table for patch name → patch pointer. Test with collisions.

5. **Event Scheduler**
   - Create a sorted queue of MIDI events by timestamp. Write code to process all events due in a given audio buffer.

6. **Lock-Free Ring Buffer**
   - Implement a circular buffer for MIDI events. Simulate producer/consumer in separate threads (if possible).

7. **Synchronization Challenge**
   - Demonstrate a data race with unsynchronized access to a shared variable. Then fix it using a lock-free or atomic solution.

8. **Real-Time Audio Scheduling**
   - Write a scheduler that triggers note on/off events at precise sample times in a simulated audio callback loop.

9. **Documentation**
   - Document all your new data structures with diagrams (ASCII or otherwise), comments, and example usage.

---

**End of Part 6.**  
_Next: Advanced modularization, plugin and scripting architectures, building your own effect/plugin system, and integrating analog/digital domains._
