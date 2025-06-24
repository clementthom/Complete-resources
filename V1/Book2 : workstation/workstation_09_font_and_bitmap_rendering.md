# Workstation Synth Project – Document 9  
## Font and Bitmap Rendering

---

### Table of Contents

1. Why Custom Fonts and Icons Matter
2. Bitmap Fonts: Theory and Formats
3. Drawing Characters: From Bitmap to Framebuffer
4. Rendering Strings and Centering Text
5. Icon and Symbol Bitmaps (Buttons, Controls)
6. Importing and Creating Bitmaps (Tools and Tips)
7. Optimizing for Speed and Memory
8. Hands-On: Render a Menu with Icons
9. Exercises

---

## 1. Why Custom Fonts and Icons Matter

- Give your synth personality and retro vibe.
- Improve readability, menu navigation, and UX.
- Mimic the look of classic Fairlight, Synclavier, or PPG workstations.

---

## 2. Bitmap Fonts: Theory and Formats

- Each glyph is a small pixel map (e.g., 8x8 or 8x16 pixels).
- Stored as arrays: each byte = 8 pixels (on/off).
- Font tables: ASCII code → bitmap.

---

## 3. Drawing Characters

- For each pixel in the glyph, set corresponding pixel in framebuffer.
- Support bold, inverse, or blinking by transforming bits.

Example:  
```c
void draw_char(int x, int y, char c, const uint8_t *font) {
  for (int row = 0; row < FONT_HEIGHT; row++) {
    uint8_t bits = font[(c - 32) * FONT_HEIGHT + row];
    for (int col = 0; col < FONT_WIDTH; col++) {
      set_pixel(x + col, y + row, (bits >> (7 - col)) & 1);
    }
  }
}
```

---

## 4. Rendering Strings and Centering Text

- Loop through characters, advance x by char width.
- Centering: `(screen_width - (strlen(text) * char_width)) / 2`

---

## 5. Icon and Symbol Bitmaps

- Store icons as arrays (e.g., for play, stop, edit).
- Draw like characters, or overlay on buttons/menus.

---

## 6. Importing and Creating Bitmaps

- Tools: GIMP, Aseprite, [font editors](https://fontstruct.com/), [Image2CPP](https://javl.github.io/image2cpp/)
- Save as C arrays for easy inclusion.

---

## 7. Optimizing for Speed and Memory

- Keep font size small (8x8 or 8x16 is classic).
- Store in flash/const arrays if on microcontroller.
- Draw only dirty regions for speed.

---

## 8. Hands-On: Render a Menu with Icons

- Create a simple menu: PLAY [▶], STOP [■], EDIT [✎]
- Draw text and icon for each item.

---

## 9. Exercises

- Design your own 8x8 font for numbers 0–9.
- Create a bitmap for a knob icon.
- Add bold/inverse support to your font renderer.

---

**Next:**  
*workstation_10_touchscreen_technologies_and_basics.md* — Touch input fundamentals for your workstation.

---