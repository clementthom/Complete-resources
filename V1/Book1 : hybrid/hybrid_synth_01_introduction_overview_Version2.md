# Hybrid Synthesizer Project – Document 1  
## Introduction, Mindset, and Project Overview

---

### Table of Contents

1. Welcome: Why Build Your Own Synth?
2. How to Use This Course
3. Learning by Doing: Philosophy and Structure
4. What is a Hybrid Synthesizer?
5. What Will You Build?
6. How to Learn: Mindset and Best Practices
7. Safety, Community, and Open Source
8. Essential Tools and Supplies Checklist

---

## 1. Welcome: Why Build Your Own Synth?

Have you ever dreamed of designing your own musical instrument?  
This course will teach you, from scratch, how to create a professional, playable hybrid synthesizer using C code, a Raspberry Pi, and real analog electronics—just like the legendary machines (Emulator III, Synclavier, PPG Wave, etc.) that shaped modern music.

---

## 2. How to Use This Course

- **Read each document carefully:** Every concept is explained from the ground up—no prior experience needed.
- **Do the hands-on exercises:** Each section includes practical steps and mini-projects.
- **Keep a project log:** Write notes, take pictures of your breadboard, and commit code regularly.
- **Don’t skip exercises:** Real learning happens when you make mistakes and fix them.

---

## 3. Learning by Doing: Philosophy and Structure

This is not just a book—it's a course and a workshop.  
You will **write code, wire circuits, debug problems, and build a real instrument**.  
Every new idea is followed by a practical “do it now” assignment.  
Expect to spend time **coding, breadboarding, and testing**.  
You will learn not just how to build a synth, but how to learn and create technology on your own.

---

## 4. What is a Hybrid Synthesizer?

A hybrid synthesizer combines **digital sound generation** (oscillators, samplers, etc.) with **analog signal processing** (filters, VCAs), blending the best of both worlds:

- **Digital:** Precise, flexible, polyphonic, and programmable.
- **Analog:** Warm, smooth, and “alive” sound; hands-on tweaking.

**Classic Hybrids:**  
- E-mu Emulator III: Digital sample playback, analog SSM2044 filters.
- PPG Wave 2.x: Digital wavetable oscillators, analog filters/VCAs.
- Prophet VS, Korg DW8000, and more.

---

## 5. What Will You Build?

By the end, you’ll have:

- A playable hybrid synthesizer with:
    - 8+ voices (polyphonic)
    - Digital oscillators coded in C
    - Audio output via a DAC (PCM5102, MCP4922, etc.)
    - Analog lowpass filter and VCA, breadboarded or soldered
    - MIDI, button, or keyboard input (bonus)
- A complete project repository (code, docs, schematics)
- The confidence and skill to expand or design your own instruments

---

## 6. How to Learn: Mindset and Best Practices

- **Be patient:** You will face bugs, mistakes, and confusion. That’s normal!
- **Debugging is learning:** Don’t fear error messages or weird sounds—they mean you’re making progress.
- **Experiment:** Try changing numbers, circuit parts, or code to see what happens.
- **Ask for help:** Use online forums, friends, and mentors.
- **Document your journey:** Comment code, photograph circuits, keep a “build diary.”

---

## 7. Safety, Community, and Open Source

- **Electronics can be dangerous:** Always unplug before changing wiring; use low-voltage circuits; double-check power before connecting.
- **Be kind and curious:** The synth DIY and maker communities are supportive—share your work and help others.
- **Open source:** You are encouraged to share your code, schematics, and learnings!

---

## 8. Essential Tools and Supplies Checklist

**For Coding:**
- Computer with Linux (Solus), Windows, or Mac
- Text editor (VSCode, Geany, Sublime, Vim, etc.)
- C compiler (GCC or Clang)
- PortAudio library for sound on PC
- Git for version control

**For Electronics (Start Simple):**
- Breadboard
- Jumper wires
- Multimeter
- Soldering iron (later)
- Oscilloscope (USB or cheap handheld is OK)
- Basic components (resistors, capacitors, op-amps, IC sockets)
- DAC module (PCM5102 or MCP4922)
- Raspberry Pi (3 or 4 recommended)
- Analog filter ICs (optional, e.g. AS3320, SSM2044, or build your own with LM13700)

---

**Next:**  
*hybrid_synth_02_c_programming_from_zero.md* will start you writing your first C code step by step—even if you’ve never programmed before.

---