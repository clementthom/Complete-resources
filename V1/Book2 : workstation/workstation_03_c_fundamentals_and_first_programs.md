# Workstation Synth Project – Document 3  
## C Fundamentals and First Programs

---

### Table of Contents

1. What is C? Why Is It Used for Embedded/UI?
2. Variables, Types, and Expressions
3. Loops, Conditionals, and Functions
4. Arrays, Strings, and Structs
5. Pointers and Memory
6. Organizing Code: Header and Source Files
7. Makefiles and Simple Builds
8. Debugging: Printf, gdb, and VSCode Tools
9. Exercises

---

## 1. What is C? Why Is It Used for Embedded/UI?

- C is fast, low-level, and close to hardware.
- Most firmware, synths, and GUIs are written in C or C++.

---

## 2. Variables, Types, and Expressions

```c
int a = 5;
float b = 3.14;
char c = 'X';
```
- Operators: `+`, `-`, `*`, `/`, `%`

---

## 3. Loops, Conditionals, and Functions

```c
for (int i = 0; i < 10; i++) { ... }
if (a > 0) { ... } else { ... }
int add(int x, int y) { return x + y; }
```

---

## 4. Arrays, Strings, and Structs

```c
int arr[4] = {1, 2, 3, 4};
char name[] = "synth";
typedef struct { float freq, amp; } Voice;
```

---

## 5. Pointers and Memory

```c
int v = 10;
int *p = &v;
printf("%d\n", *p);
```

---

## 6. Organizing Code: Header and Source Files

**voice.h:**
```c
#ifndef VOICE_H
#define VOICE_H
typedef struct { float freq, amp; } Voice;
#endif
```

---

## 7. Makefiles and Simple Builds

```makefile
CC=gcc
CFLAGS=-Wall -O2
all: hello
hello: hello.c
	$(CC) $(CFLAGS) -o hello hello.c
```

---

## 8. Debugging: Printf, gdb, and VSCode Tools

- Add `printf` to check variable values.
- Run `gdb ./hello` for step-through debugging.

---

## 9. Exercises

- Write a function to sum an array of floats.
- Make a struct for a GUI widget (with x, y, width, height).
- Build and run your first Makefile.

---

**Next:**  
*workstation_04_project_structure_and_version_control.md* — Organizing, collaborating, and working like a pro.

---