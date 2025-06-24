# Workstation Synth Project – Document 2  
## Tools, Installation, and Setup

---

### Table of Contents

1. Your Development Computer: Requirements
2. Installing a C Compiler and Tools (Solus/Other OS)
3. Recommended Editors and IDEs
4. Installing Git and GUI Clients
5. Installing Audio Libraries for PC Testing
6. Optional: Installing Electronics Design Tools (KiCad, FreeCAD)
7. Setting Up a Project Directory Structure
8. Testing Your Setup
9. Exercises

---

## 1. Your Development Computer: Requirements

- Linux (Solus), Windows, or macOS; 4GB+ RAM, 10GB+ free space
- SD card reader/writer for Raspberry Pi

---

## 2. Installing a C Compiler and Tools

**Solus:**
```bash
sudo eopkg install gcc clang make git cmake gdb
```
**Other OS:**  
- Windows: [MSYS2](https://www.msys2.org/), [MinGW](https://www.mingw-w64.org/), or [WSL](https://docs.microsoft.com/en-us/windows/wsl/)
- Mac: Xcode Command Line Tools

---

## 3. Recommended Editors and IDEs

- VSCode, Geany, Sublime, Atom, Vim, Emacs
- For beginners: VSCode or Geany are easiest

---

## 4. Installing Git and GUI Clients

**Solus:**
```bash
sudo eopkg install git
```
**GUI:** [GitKraken](https://www.gitkraken.com/), [GitHub Desktop](https://desktop.github.com/), or built into VSCode.

---

## 5. Installing Audio Libraries for PC Testing

- **PortAudio:**  
  ```bash
  sudo eopkg install portaudio-devel
  ```
- **SDL2 (alternative):**  
  ```bash
  sudo eopkg install libSDL2-devel
  ```

---

## 6. Optional: Electronics Design Tools

- **KiCad:** PCB and schematic design  
  ```bash
  sudo eopkg install kicad
  ```
- **FreeCAD:** Case/enclosure design  
  ```bash
  sudo eopkg install freecad
  ```

---

## 7. Setting Up a Project Directory Structure

```
workstation_synth/
  src/
  include/
  pc_test/
  pi_baremetal/
  gui/
  electronics/
  doc/
  assets/
  Makefile
  README.md
```

---

## 8. Testing Your Setup

- Open your editor, create `hello.c`, and run:
```c
#include <stdio.h>
int main() { printf("Hello, Synth!\n"); return 0; }
```
```bash
gcc hello.c -o hello
./hello
```

---

## 9. Exercises

- Set up your directory and editor.
- Install and test PortAudio or SDL2.
- Commit your first README.md to Git.

---

**Next:**  
*workstation_03_c_fundamentals_and_first_programs.md* — C programming from zero, for embedded and UI.

---