# Workstation Synth Project – Document 8  
## Monochrome Graphics Fundamentals

---

### Table of Contents

1. What is Monochrome Graphics?
2. Pixels, Bitmaps, and Framebuffers
3. Drawing Primitives: Pixels, Lines, Rectangles
4. Coordinate Systems and Screen Layout
5. Efficient Rendering and Double Buffering
6. Implementing a Basic Framebuffer in C
7. Hands-On: Draw Your First Grid
8. Exercises

---

## 1. What is Monochrome Graphics?

- Each pixel is on (1) or off (0)
- Efficient, retro look; easy to use in embedded/UI

---

## 2. Pixels, Bitmaps, and Framebuffers

- Framebuffer: array storing pixel states
- Bitmaps: arrays for icons, fonts

---

## 3. Drawing Primitives

- Set pixel: `fb[y][x] = 1;`
- Bresenham’s algorithm for lines
- Rectangles: fill or outline

---

## 4. Coordinate Systems

- (0,0) is usually top-left
- x = columns, y = rows

---

## 5. Efficient Rendering

- Only redraw changed areas (dirty rectangles)
- Double buffering: draw off-screen, then swap

---

## 6. Basic Framebuffer in C

```c
#define WIDTH 128
#define HEIGHT 64
uint8_t fb[WIDTH * HEIGHT / 8];
// Set/Clear pixel functions
```

---

## 7. Hands-On: Draw a Grid

- Write code to draw a 16x8 grid on a 128x64 display

---

## 8. Exercises

- Draw text using a bitmap font
- Animate a rectangle moving across the screen
- Implement a function to invert a region

---

**Next:**  
*workstation_09_font_and_bitmap_rendering.md* — Rendering fonts and icons for your UI.

---