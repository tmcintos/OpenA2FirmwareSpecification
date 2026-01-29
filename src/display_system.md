### Display System

#### Overview

The Apple II family provides multiple display modes for text and graphics output, all using memory-mapped video. The display system reads directly from RAM to generate the video signal, allowing programs to update the screen by writing to standard memory locations. Later models (IIe/IIc with 128K RAM) add 80-column text and double high-resolution graphics through memory interleaving.

#### Display Modes

**Text Modes:**

- **40-Column Text**: Standard text mode, 40 characters × 24 rows
- **80-Column Text**: Available on IIe/IIc with appropriate hardware, 80 characters × 24 rows

**Graphics Modes:**

- **Low-Resolution (Lo-Res)**: 40 × 48 pixels, 16 colors, uses text page memory
- **High-Resolution (Hi-Res)**: 280 × 192 pixels, 6 colors (with limitations)
- **Double High-Resolution**: 560 × 192 pixels (IIe/IIc with 128K only)

#### 40-Column Text Mode

**Characteristics:**

- 40 characters per line, 24 lines
- 7×8 character cells
- 96 printable characters (uppercase, numbers, symbols)
- Lowercase available on IIe/IIc
- Inverse, flash, and normal video attributes

**Memory Organization:**

- Page 1: $0400-$07FF (1KB)
- Page 2: $0800-$0BFF (1KB)
- Each page: 960 bytes used, 64 bytes unused (screen holes)

**Character Encoding:**

- Bit 7 determines display mode:
  - Bit 7=0, Bit 6=0: Inverse video
  - Bit 7=0, Bit 6=1: Flashing characters
  - Bit 7=1, Bit 6=x: Normal video

- Bits 5-0: Character code ($00-$3F for uppercase, $40-$5F for symbols, $60-$7F for lowercase on IIe+)

**Screen Memory Layout:**

Text memory is organized with a non-linear pattern:

- Rows 0-7: $0400-$047F, $0480-$04FF, ..., $0778-$07F7
- Rows 8-15: $0428-$04A7, $04A8-$0527, ..., $07A0-$081F
- Rows 16-23: $0450-$04CF, $04D0-$054F, ..., $07C8-$0847

Formula: `BASL = $0400 + (row & $07) << 7 + ((row & $18) << 2) + ((row & $18) << 4)`

#### 80-Column Text Mode

**Characteristics:**

- 80 characters per line, 24 lines
- 7×8 character cells (same as 40-column)
- Requires auxiliary memory (IIe with 80-column card or IIc)
- Double horizontal pixel clock (14 MHz vs. 7 MHz)

**Memory Organization:**

Memory is interleaved between main and auxiliary RAM:

- Even columns (0, 2, 4, ... 78): Auxiliary RAM
- Odd columns (1, 3, 5, ... 79): Main RAM
- Both use standard text page addresses ($0400-$07FF or $0800-$0BFF)

**Hardware Interleaving:**

The video hardware automatically fetches characters alternately:

1. PHI0 (Phase 0): Read character from auxiliary RAM (even column)
2. PHI1 (Phase 1): Read character from main RAM (odd column)
3. Shift register clocked at double rate (14 MHz)

**Enabling 80-Column Mode:**

Requires setting multiple soft switches:

- $C001 (80STORE): Enable 80-column store mode
- $C050 or $C051 (TEXT): Select text mode
- $C054 or $C055 (PAGE2): Select page 1 or page 2

#### Low-Resolution Graphics

**Characteristics:**

- 40 × 48 pixels (blocks)
- 16 colors
- Uses same memory as text pages
- Each character cell = two color blocks (top/bottom half)

**Memory Organization:**

- Page 1: $0400-$07FF
- Page 2: $0800-$0BFF
- Each byte = two pixels:
  - Low nibble (bits 3-0): Top half of character cell
  - High nibble (bits 7-4): Bottom half of character cell

**Color Values:**

| Value | Color |
|-------|-------|
| $0 | Black |
| $1 | Magenta |
| $2 | Dark Blue |
| $3 | Purple |
| $4 | Dark Green |
| $5 | Gray 1 |
| $6 | Medium Blue |
| $7 | Light Blue |
| $8 | Brown |
| $9 | Orange |
| $A | Gray 2 |
| $B | Pink |
| $C | Light Green |
| $D | Yellow |
| $E | Aqua |
| $F | White |

**Mixed Mode:**

Text and lo-res can be mixed: bottom 4 lines show text while top 20 lines show graphics.

- Controlled by MIXED soft switch ($C052/$C053)

#### High-Resolution Graphics

**Characteristics:**

- 280 × 192 pixels
- 6 displayable colors (with color fringing artifacts)
- Black and white always available
- Color depends on horizontal pixel position and byte pattern

**Memory Organization:**

- Page 1: $2000-$3FFF (8KB)
- Page 2: $4000-$5FFF (8KB)
- Interleaved scan-line addressing

**Scan Line Organization:**

Each scan line contains 40 bytes (280 pixels ÷ 7 bits/byte):

- Byte format: bit 7 = palette selector, bits 6-0 = pixel data
- Lines interleaved in groups of 8, then 64, then 128

**Color Generation:**

Colors produced by NTSC color artifacts:

- Bit 7=0 (even palette): Purple and Green
- Bit 7=1 (odd palette): Blue and Orange
- Adjacent pixels produce white
- Isolated pixels produce black or color depending on position

**Address Calculation:**

`Address = Base + (Y DIV 64) × $28 + (Y DIV 8 MOD 8) × $80 + (Y MOD 8) × $400 + (X DIV 7)`

Where Base = $2000 (page 1) or $4000 (page 2).

#### Double High-Resolution Graphics

**Characteristics:**

- 560 × 192 pixels
- 16 simultaneous colors
- Requires 128K RAM (auxiliary memory)
- IIe/IIc only

**Memory Organization:**

Memory interleaved between main and auxiliary RAM:

- Even columns: Auxiliary RAM ($2000-$3FFF or $4000-$5FFF)
- Odd columns: Main RAM (same addresses)
- Each byte = 4 pixels (2 bits per pixel with palette)

**Enabling Double Hi-Res:**

Requires:

- $C001 (80STORE): Enable 80-column store
- $C057 (HIRES): Enable hi-res mode  
- $C054/$C055 (PAGE2): Select page

**Color Encoding:**

Each byte contains 4 pixels:

- Bits 7-6: Pixel 3 color
- Bits 5-4: Pixel 2 color  
- Bits 3-2: Pixel 1 color
- Bits 1-0: Pixel 0 color

Palette selected by auxiliary bit in color control register.

#### Display Pages and Page Flipping

**Page Selection:**

All display modes support two pages for double-buffering:

- Page 1: Primary display (default)
- Page 2: Secondary display (alternate)

**PAGE2 Soft Switch ($C054/$C055):**

- $C054: Display page 1
- $C055: Display page 2

**Benefits:**

- Smooth animation (draw to hidden page, flip)
- Reduced flicker
- Double-buffered graphics

#### Display Soft Switches

**Mode Selection:**

| Switch | Address | Function |
|--------|---------|----------|
| TEXT | $C050/$C051 | Graphics ($C050) or Text ($C051) |
| MIXED | $C052/$C053 | Full screen ($C052) or Mixed ($C053) |
| PAGE2 | $C054/$C055 | Page 1 ($C054) or Page 2 ($C055) |
| HIRES | $C056/$C057 | Lo-Res ($C056) or Hi-Res ($C057) |
| 80STORE | $C000/$C001 | Off ($C000) or On ($C001) - IIe/IIc |

**Mode Combinations:**

| TEXT | MIXED | HIRES | Display Mode |
|------|-------|-------|--------------|
| 1 | x | x | 40-column text (or 80-column if 80STORE) |
| 0 | 0 | 0 | Full-screen lo-res graphics |
| 0 | 1 | 0 | Lo-res graphics + 4 text lines |
| 0 | 0 | 1 | Full-screen hi-res graphics |
| 0 | 1 | 1 | Hi-res graphics + 4 text lines |

See [I/O and Soft Switches](#io-and-soft-switches) for complete soft switch reference.

#### Display Hardware Timing

**Video Signal Generation:**

- Horizontal: 65 cycles per scan line (40.5 µs)
- Vertical: 262 scan lines per frame (NTSC)
- Refresh rate: ~60 Hz
- Pixel clock: 14.318 MHz (NTSC color burst)

**Display vs. System Timing:**

- CPU clock: 1.023 MHz (synchronized with video)
- Memory access: Interleaved with video refresh
- Some cycles lost to video DMA (display RAM access)

#### Display System Implementation Notes

**For Clean-Room ROM Implementation:**

1. **Initialize Display on Boot:**
   - Set default mode using soft switches (40-column text, page 1)
   - Clear screen memory during firmware initialization
   - Establish known default display state

2. **Use Soft Switches Correctly:**
   - Access PAGE2 switch to control page display
   - Access mode switches to change text/graphics modes

3. **Document Mode Requirements:**
   - Which modes require 128K RAM
   - 80-column requirements
   - Color limitations in hi-res

4. **Provide Screen Routines:**
   - Home (clear screen)
   - Scroll (move text up)
   - Cursor positioning
   - Character output

**For Software Compatibility:**

1. **Detect Display Capabilities:**
   - Test for 80-column hardware
   - Test for auxiliary memory (for double hi-res)
   - Don't assume features present

2. **Use Standard Memory Locations:**
   - Text pages at $0400 and $0800
   - Graphics pages at $2000 and $4000
   - Standard soft switch addresses

3. **Handle Mode Switching Properly:**
   - Set all required soft switches
   - Ensure page alignment
   - Clear screen when changing modes

#### See Also

- **[Auxiliary RAM and Memory Soft Switches](#auxiliary-ram-and-memory-soft-switches)** - 80-column and double hi-res details
- **[I/O and Soft Switches](#io-and-soft-switches)** - Display control switches
- **[Memory System](#memory-system)** - Display memory organization
- **[Home](#home)** - Clear screen routine
- **[SetTxt](#settxt)** - Set text mode
- **[SetGr](#setgr)** - Set graphics mode
