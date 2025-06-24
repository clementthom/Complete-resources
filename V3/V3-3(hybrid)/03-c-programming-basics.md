# Chapter 3: C Programming for Embedded Systems (Basics)

---

## Table of Contents

1. Introduction to C
2. Setting Up Your Development Environment
3. Compilers, Editors, and Tools
4. Your First C Program: Hello, World!
5. Anatomy of a C Program
6. Variables and Data Types
7. Operators and Expressions
8. Flow Control: if, else, switch, loops
9. Functions and Modularity
10. Input/Output in C
11. Compiling, Running, and Debugging
12. Practical Exercises
13. Summary and Next Steps

---

## 1. Introduction to C

### What is C?

C is a powerful, general-purpose programming language invented in the early 1970s by Dennis Ritchie at Bell Labs. It's considered the "lingua franca" of embedded systems because:  
- It is close to the hardware ("low-level"), so you can control memory and peripherals directly.
- It is standardized, portable, and efficient.
- It is widely used in operating systems, microcontrollers, and synthesizer firmware.

### Why Use C for Embedded Synthesizers?

- **Performance:** C code compiles to efficient machine code, suitable for real-time audio.
- **Portability:** You can run the same code on PC, Raspberry Pi, or microcontrollers with minimal changes.
- **Hardware Access:** C lets you directly talk to hardware registers, useful for bare-metal programming.

---

## 2. Setting Up Your Development Environment

### What Do You Need?

- A computer with Linux (Solus in your case), macOS, or Windows.
- A text editor or IDE (VS Code, Vim, Emacs, Sublime, Geany, etc.).
- A C compiler (GCC for Linux, Clang for macOS, MinGW or WSL for Windows).
- Make (build automation).
- (Optionally) Debugger (gdb).
- For Raspberry Pi: Cross-compilation toolchain OR build on Pi itself.

### Installing GCC on Linux (Solus Example)

```bash
sudo eopkg install -c system.devel
sudo eopkg install gcc make gdb
```

### Installing GCC on Raspberry Pi

```bash
sudo apt-get update
sudo apt-get install build-essential gdb
```

### Installing VS Code (Optional, for Beginners)

- Download from [https://code.visualstudio.com/](https://code.visualstudio.com/)
- Install the "C/C++" extension from Microsoft.

---

## 3. Compilers, Editors, and Tools

### What is a Compiler?

A compiler translates your C source code (human-readable) into machine code (binary executable).

- **Source code:** `main.c`
- **Compiler:** `gcc main.c -o main`
- **Executable:** `main` (or `main.exe` on Windows)

### Recommended Editors

- **VS Code:** Beginner-friendly, extensible, cross-platform.
- **Vim/Neovim:** Powerful for advanced users.
- **Geany, Sublime Text:** Lightweight and fast.

### Make and Makefiles

- Automate compiling multiple files.
- We'll cover makefiles in detail in later chapters.

---

## 4. Your First C Program: Hello, World!

Let's write and run the classic "Hello, World!" program.

### Step 1: Create the File

Open your editor, create a file called `hello.c`:

```c
#include <stdio.h>

int main(void) {
    printf("Hello, World!\n");
    return 0;
}
```

### Step 2: Compile

```bash
gcc hello.c -o hello
```

### Step 3: Run

```bash
./hello
```

You should see:
```
Hello, World!
```

---

## 5. Anatomy of a C Program

Let's break down the example above.

```c
#include <stdio.h> // Includes Standard I/O functions

int main(void) {   // main() is the entry point
    printf("Hello, World!\n"); // Print to the console
    return 0;      // End program and return 0 to OS
}
```

**Key Points:**
- `#include <stdio.h>`: Includes the Standard Input/Output library.
- `int main(void)`: The starting point of every C program.
- `printf(...)`: Prints formatted text.
- `return 0;`: Signals successful completion.

---

## 6. Variables and Data Types

Variables hold data your program uses.  
C is a statically typed language: you must declare a variable's type.

### Basic Data Types

| Type        | Description              | Size (Typical) |
|-------------|--------------------------|----------------|
| `int`       | Integer                  | 4 bytes        |
| `float`     | Floating-point (decimal) | 4 bytes        |
| `double`    | Double-precision float   | 8 bytes        |
| `char`      | Character                | 1 byte         |

### Declaration and Initialization

```c
int a = 5;
float b = 2.5;
char c = 'A';
double pi = 3.14159;
```

### Constants

```c
#define PI 3.14159       // Preprocessor constant
const int MAX_VOICES = 8; // Constant variable
```

### Arrays

```c
int numbers[5] = {1, 2, 3, 4, 5};
float buffer[1024]; // Array of 1024 floats
```

---

## 7. Operators and Expressions

### Arithmetic Operators

```c
int sum = a + b;
int diff = a - b;
int prod = a * b;
int quot = a / b;
int mod = a % b;
```

### Assignment Operators

```c
a += 1; // Increment a by 1
b *= 2; // Multiply b by 2
```

### Comparison Operators

```c
if (a == b) { ... }
if (a != b) { ... }
if (a < b) { ... }
if (a > b) { ... }
if (a <= b) { ... }
if (a >= b) { ... }
```

### Logical Operators

```c
if (a > 0 && b > 0) { ... }
if (a == 0 || b == 0) { ... }
if (!done) { ... }
```

---

## 8. Flow Control: if, else, switch, loops

### if-else

```c
if (a > b) {
    printf("a is greater than b\n");
} else {
    printf("a is not greater than b\n");
}
```

### switch

```c
switch(option) {
    case 1:
        printf("Option 1\n");
        break;
    case 2:
        printf("Option 2\n");
        break;
    default:
        printf("Other option\n");
}
```

### Loops: while, for, do-while

#### while

```c
int i = 0;
while (i < 10) {
    printf("%d\n", i);
    i++;
}
```

#### for

```c
for (int i = 0; i < 10; i++) {
    printf("%d\n", i);
}
```

#### do-while

```c
int i = 0;
do {
    printf("%d\n", i);
    i++;
} while (i < 10);
```

---

## 9. Functions and Modularity

Functions group code into reusable blocks.

### Defining and Calling Functions

```c
int add(int x, int y) {
    return x + y;
}

int main(void) {
    int result = add(3, 4);
    printf("Result: %d\n", result);
    return 0;
}
```

### Function Prototypes

Always declare function prototypes at the top or in header files.

```c
int add(int x, int y); // Prototype
```

### Modular Code Structure

- Place each logical part of your synth in its own `.c` and `.h` files.
- E.g., `oscillator.c`, `oscillator.h`, `envelope.c`, `envelope.h`
- Use function prototypes in `.h` files.

---

## 10. Input/Output in C

### Standard Input/Output

- `printf(...)`: Print to stdout.
- `scanf(...)`: Read from stdin.

```c
int number;
printf("Enter a number: ");
scanf("%d", &number);
printf("You entered: %d\n", number);
```

### File I/O

```c
FILE *fp = fopen("data.txt", "w");
if (fp != NULL) {
    fprintf(fp, "Hello, file!\n");
    fclose(fp);
}
```

---

## 11. Compiling, Running, and Debugging

### Compiling

```bash
gcc main.c -o main
```

### Compiling Multiple Files

```bash
gcc main.c oscillator.c envelope.c -o synth
```

### Using Make

`Makefile` example:

```makefile
CC=gcc
CFLAGS=-Wall

synth: main.o oscillator.o envelope.o
	$(CC) $(CFLAGS) -o synth main.o oscillator.o envelope.o

main.o: main.c
	$(CC) $(CFLAGS) -c main.c

oscillator.o: oscillator.c
	$(CC) $(CFLAGS) -c oscillator.c

envelope.o: envelope.c
	$(CC) $(CFLAGS) -c envelope.c

clean:
	rm -f *.o synth
```

Compile with:

```bash
make
```

Clean with:

```bash
make clean
```

### Debugging with gdb

```bash
gcc -g main.c -o main
gdb ./main
```

Inside gdb:

- `run` — start the program
- `break main` — set a breakpoint at main
- `next` — step to next line
- `print variable` — print value of variable

---

## 12. Practical Exercises

1. Install GCC and your preferred editor.
2. Compile and run the "Hello, World!" program.
3. Write a program to add two numbers and print the result.
4. Make a for-loop that prints numbers 1 to 10.
5. Write a function to compute the maximum of two numbers.
6. Organize your code into `main.c` and a module (e.g., `mathutils.c`, `mathutils.h`) with at least one function.
7. Create a Makefile for your project.

---

## 13. Summary and Next Steps

- You now know how to set up a C development environment, write, compile, and run C programs, and structure your code for modularity.
- Practice these basics until they're second nature.
- In the next chapter, we'll dive deep into advanced C concepts—pointers, structs, arrays, memory management, and how to use them to build modular, hardware-inspired synthesizer code.

---

*End of Chapter 3*