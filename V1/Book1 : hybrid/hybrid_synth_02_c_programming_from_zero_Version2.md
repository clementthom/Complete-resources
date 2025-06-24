# Hybrid Synthesizer Project – Document 2
## C Programming from Zero: Your First Steps

---

### Table of Contents

1. What is C? Why Use It?
2. Setting Up: Installing a Compiler and Editor
3. Your First Program: Hello, World!
4. Variables, Types, and Arithmetic
5. Loops and Conditionals
6. Functions: Reusable Code Blocks
7. Arrays and Strings
8. Pointers and Memory
9. Structs and Header Files
10. Makefiles: Automating Builds
11. Debugging: Finding and Fixing Bugs
12. Exercises and Mini-Projects

---

## 1. What is C? Why Use It?

C is a powerful programming language that runs close to the hardware—perfect for embedded systems, real-time audio, and electronics projects. Most synthesizer firmware and audio engines are written in C or C++.

---

## 2. Setting Up: Installing a Compiler and Editor

**On Solus Linux:**
```bash
sudo eopkg install gcc clang make git
```
**Pick an editor:** VSCode, Geany, Sublime, Vim, or Emacs.

---

## 3. Your First Program: Hello, World!

Create a file `hello.c`:

```c
#include <stdio.h>

int main() {
    printf("Hello, World!\n");
    return 0;
}
```

**Compile and run:**
```bash
gcc hello.c -o hello
./hello
```

---

## 4. Variables, Types, and Arithmetic

```c
int a = 5;
float b = 3.14;
char c = 'A';
```
Operators: `+`, `-`, `*`, `/`, `%`

---

## 5. Loops and Conditionals

```c
for (int i = 0; i < 10; i++) {
    printf("%d\n", i);
}

if (a > 0) {
    printf("Positive\n");
} else {
    printf("Non-positive\n");
}
```

---

## 6. Functions: Reusable Code Blocks

```c
int add(int x, int y) {
    return x + y;
}
```

---

## 7. Arrays and Strings

```c
int nums[5] = {1, 2, 3, 4, 5};
char name[] = "synth";
```

---

## 8. Pointers and Memory

```c
int val = 10;
int *ptr = &val;     // pointer to val
printf("%d\n", *ptr); // dereference
```

---

## 9. Structs and Header Files

**Struct:**
```c
typedef struct {
    float freq, amp;
    int active;
} Voice;
```

**Header: `voice.h`**
```c
#ifndef VOICE_H
#define VOICE_H
typedef struct {
    float freq, amp;
    int active;
} Voice;
#endif
```

---

## 10. Makefiles: Automating Builds

Create a file `Makefile`:
```makefile
CC=gcc
CFLAGS=-Wall -O2

all: hello
hello: hello.c
	$(CC) $(CFLAGS) -o hello hello.c
clean:
	rm -f hello
```
Run `make` to build.

---

## 11. Debugging: Finding and Fixing Bugs

- Add `printf()` statements to check values.
- Use `gdb` for interactive debugging:  
  `gdb ./hello`

---

## 12. Exercises and Mini-Projects

- Modify `hello.c` to print your name and age.
- Write a function that multiplies two numbers.
- Make a struct for a simple oscillator (with phase, frequency).
- Write a loop to sum an array of numbers.

---

**Next:**  
*hybrid_synth_03_project_management_git_basics.md* — How to organize your code, use Git, and work like a pro.

---