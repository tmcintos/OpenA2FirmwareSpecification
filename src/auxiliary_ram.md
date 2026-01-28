## Auxiliary RAM and Memory Soft Switches

### Overview

Apple IIe and IIc computers include 128KB of total RAM: 64KB main memory and 64KB auxiliary memory. The auxiliary memory occupies the same address space as main memory but is accessed through memory-mapped soft switches in the $C000-$C01F I/O page. This extended memory enables 80-column text display, double high-resolution graphics, and expanded program storage.

### Memory Architecture

**Total Memory Configuration:**

- **Main RAM**: 64KB ($0000-$BFFF for 48KB + $D000-$FFFF bank-switched 16KB)
- **Auxiliary RAM**: 64KB (same address range, accessed via soft switches)
- **Total**: 128KB addressable memory

**Dual Zero Page and Stack:**

- Main zero page: $0000-$00FF (main RAM)
- Auxiliary zero page: $0000-$00FF (auxiliary RAM)
- Main stack: $0100-$01FF (main RAM)
- Auxiliary stack: $0100-$01FF (auxiliary RAM)

Both zero page and stack can be switched between main and auxiliary using the AUXZP soft switch.

### Memory Soft Switches

#### RAM Read/Write Control

**RAMRD - Read RAM Bank Selection ($C002/$C003):**

- **$C002 (49154) R/W**: RDMAINRAM - Read from main 48K RAM
- **$C003 (49155) R/W**: RDCARDRAM - Read from auxiliary 48K RAM
- **$C013 (49171) R**: Read RAMRD status; bit 7 = 1 if auxiliary, 0 if main

**RAMWRT - Write RAM Bank Selection ($C004/$C005):**

- **$C004 (49156) R/W**: WRMAINRAM - Write to main 48K RAM
- **$C005 (49157) R/W**: WRCARDRAM - Write to auxiliary 48K RAM
- **$C014 (49172) R**: Read RAMWRT status; bit 7 = 1 if auxiliary, 0 if main

**Usage:**

```
; Switch to auxiliary RAM for reading and writing
STA $C003    ; Read from auxiliary
STA $C005    ; Write to auxiliary
LDA ($3C),Y  ; Read from auxiliary RAM via pointer
STA ($3E),Y  ; Write to auxiliary RAM via pointer

; Return to main RAM
STA $C002    ; Read from main
STA $C004    ; Write from main
```

#### Zero Page and Stack Banking

**AUXZP - Zero Page/Stack Selection ($C008/$C009):**

- **$C008 (49160) W**: SETSTDZP - Use main RAM zero page ($00-$FF) and stack ($0100-$01FF)
- **$C009 (49161) W**: SETALTZP - Use auxiliary RAM zero page and stack
- **$C016 (49174) R**: Read AUXZP status; bit 7 = 1 if auxiliary, 0 if main

**Critical Notes:**

- Switching zero page/stack affects **all** zero-page addressing and stack operations
- Interrupt handlers must be aware of current zero page/stack selection
- Firmware typically switches to main zero page during interrupts for consistent system state

**Interrupt-Safe Stack Switching:**

```
; Save current stack pointer before switching
PHP              ; Save processor status
TSX              ; Transfer stack pointer to X
TXA              ; Transfer to accumulator
STA $0100        ; Store main stack pointer in auxiliary RAM location
STA $C009        ; Switch to auxiliary zero page/stack
; (Now using auxiliary stack)
```

#### 80STORE Mode

**80STORE - Display Page Override ($C000/$C001):**

- **$C000 (49152) W**: Turn OFF 80STORE
- **$C001 (49153) W**: Turn ON 80STORE
- **$C018 (49176) R**: Read 80STORE status; bit 7 = 1 if on, 0 if off

**Behavior When 80STORE is OFF:**

- RAMRD/RAMWRT soft switches control **all** memory access, including display pages
- PAGE2 switch affects display selection only (which page is visible on screen)
- Normal 40-column text mode operation

**Behavior When 80STORE is ON:**

- PAGE2 switch **overrides** RAMRD/RAMWRT for display memory addresses only
- Enables automatic interleaving for 80-column text and double high-resolution graphics
- Memory access to non-display areas still controlled by RAMRD/RAMWRT

#### PAGE2 - Display Page Selection

**PAGE2 - Select Display Page ($C054/$C055):**

- **$C054 (49236) R**: Turn OFF PAGE2 (display page 1)
- **$C055 (49237) R**: Turn ON PAGE2 (display page 2)
- **$C01C (49180) R**: Read PAGE2 status; bit 7 = 1 if on, 0 if off

**PAGE2 Interaction with 80STORE:**

| 80STORE | HiRes | PAGE2 | Display Content |
|---------|-------|-------|-----------------|
| OFF | X | OFF | Text/LoRes Page 1 (main RAM $0400-$07FF) |
| OFF | X | ON | Text/LoRes Page 2 (main RAM $0800-$0BFF) |
| ON | OFF | OFF | 80-column Text Page 1 (main + aux $0400-$07FF) |
| ON | OFF | ON | 80-column Text Page 2 (main + aux $0800-$0BFF) |
| ON | ON | OFF | Double Hi-Res Page 1 (main + aux $2000-$3FFF) |
| ON | ON | ON | Double Hi-Res Page 2 (main + aux $4000-$5FFF) |

#### HiRes Mode

**HiRes - Graphics Mode Selection ($C056/$C057):**

- **$C056 (49238) R**: Turn OFF HiRes (display text/low-resolution graphics)
- **$C057 (49239) R**: Turn ON HiRes (display high-resolution graphics)
- **$C01D (49181) R**: Read HiRes status; bit 7 = 1 if on, 0 if off

### 80-Column Text Display

#### Memory Organization

The 80-column text display uses **interleaved memory** from both main and auxiliary RAM:

**Text/LoRes Page 1 (addresses $0400-$07FF):**

- **Even columns (0, 2, 4, ... 78)**: Auxiliary RAM (TLP1X)
- **Odd columns (1, 3, 5, ... 79)**: Main RAM (TLP1)

**Display Characteristics:**

- **Resolution**: 80 columns × 24 rows
- **Character size**: 7 pixels wide × 8 pixels high
- **Total memory**: 1920 bytes (960 from main + 960 from auxiliary)
- **Video timing**: 14 MHz character clock (double the 40-column 7 MHz rate)

#### Video Hardware Interleaving

The video hardware automatically interleaves character data on every display cycle:

1. **PHI0 (Phase 0)**: Fetch character from auxiliary RAM (even column)
2. **PHI1 (Phase 1)**: Fetch character from main RAM (odd column)
3. **Shift register**: Output character pixels at doubled clock rate

This interleaving is transparent to software—firmware simply writes characters to appropriate memory locations based on column position.

#### Enabling 80-Column Mode

```
; Enable 80-column text display
STA $C001    ; Turn on 80STORE
STA $C056    ; Turn off HiRes (text mode)
STA $C054    ; Select PAGE2 OFF (page 1)

; Write to even column (column 0) - uses auxiliary RAM
STA $C005    ; Write to auxiliary RAM
LDA #'A'     ; Character to display
STA $0400    ; Write to screen position (row 0, column 0)

; Write to odd column (column 1) - uses main RAM  
STA $C004    ; Write to main RAM
LDA #'B'     ; Character to display
STA $0401    ; Write to next screen position (row 0, column 1)
```

**Screen Memory Layout (same as 40-column):**

- Each row occupies 128 bytes (80 used, 48 unused)
- Row addresses follow standard Apple II text screen mapping
- Holes at end of each row still present but unused in 80-column mode

### Double High-Resolution Graphics

Double high-resolution graphics uses the same interleaving mechanism as 80-column text:

**Resolution**: 560 pixels wide × 192 pixels high

**Memory Organization:**

- **Even columns**: Auxiliary RAM ($2000-$3FFF or $4000-$5FFF)
- **Odd columns**: Main RAM (same address range)
- **Total memory**: 16KB per page (8KB main + 8KB auxiliary)

**Enabling Double Hi-Res:**
```
STA $C001    ; Turn on 80STORE
STA $C057    ; Turn on HiRes mode
STA $C054    ; Select page 1 (or $C055 for page 2)
```

### Bank-Switched Language Card RAM

**Language Card Soft Switches ($C080-$C08F):**

The bank-switched RAM region ($D000-$FFFF, 16KB total) is divided into:
- **$D000-$DFFF**: Bank 1 or Bank 2 (4KB, selectable)
- **$E000-$FFFF**: Common area (12KB, same in both banks)

**Read Switches:**

- **$C080**: Read bank 2, no write
- **$C088**: Read bank 1, no write

**Write Switches (require two successive reads):**

- **$C081**: Read ROM, write bank 2 (RR - two reads required)
- **$C083**: Read RAM bank 2, write bank 2 (RR)
- **$C089**: Read ROM, write bank 1 (RR)
- **$C08B**: Read RAM bank 1, write bank 1 (RR)

**Status Switches:**

- **$C011 (49169) R**: Read BANK2 status; bit 7 = 1 if bank 2, 0 if bank 1
- **$C012 (49170) R**: Read LCRAMRD status; bit 7 = 1 if reading RAM, 0 if ROM

**Two-Read Requirement:**
The write-enable switches require **two successive reads** to the same address to enable RAM writing. This prevents accidental writes from indexed addressing that might touch these locations once.

```
; Enable reading and writing to language card bank 1
LDA $C08B    ; First read
LDA $C08B    ; Second read - now RAM is readable and writable
```

### Auxiliary RAM Detection

All Apple IIe and IIc systems include auxiliary RAM as standard. However, software can verify auxiliary RAM presence:

**Detection Method:**
```
; Test for auxiliary RAM
STA $C005    ; Write to auxiliary RAM
LDA #$55     ; Test pattern
STA $0800    ; Write to arbitrary location
STA $C004    ; Write to main RAM
LDA #$AA     ; Different pattern
STA $0800    ; Write same address in main
STA $C003    ; Read from auxiliary
LDA $0800    ; Read back
CMP #$55     ; Should be original pattern
BNE NO_AUX   ; If different, no auxiliary RAM
STA $C002    ; Read from main
LDA $0800    ; Read back
CMP #$AA     ; Should be second pattern
BNE NO_AUX   ; If different, no auxiliary RAM
; Auxiliary RAM confirmed present
```

### Memory State Encoding

During interrupt handling, the firmware preserves complete memory configuration state using a packed byte:

| Bit | Meaning |
|-----|---------|
| D7 | 1 if using auxiliary zero page/stack (AUXZP on) |
| D6 | 1 if 80STORE enabled and PAGE2 on |
| D5 | 1 if reading from auxiliary RAM (RAMRD) |
| D4 | 1 if writing to auxiliary RAM (RAMWRT) |
| D3 | 1 if language card RAM enabled |
| D2 | 1 if language card bank 1 selected |
| D1 | 1 if language card bank 2 selected |
| D0 | 1 if alternate ROM bank selected |

This encoding allows interrupt service routines to save and restore the complete memory configuration with minimal overhead.

### Interrupt Handling with Auxiliary Memory

**Interrupt Entry:**

1. Save memory configuration state on current stack
2. Switch to main zero page/stack ($C008)
3. Execute interrupt handler using main memory
4. Restore memory configuration state before RTI

**Stack Pointer Preservation:**

- Main stack pointer saved at $0100 (auxiliary RAM) when using auxiliary stack
- Auxiliary stack pointer saved at $0101 (auxiliary RAM) when using main stack
- Firmware switches to appropriate stack before saving SP value

### Reset Behavior

Upon hardware reset or power-up:

- **RAMRD**: Main RAM ($C002)
- **RAMWRT**: Main RAM ($C004)
- **AUXZP**: Main zero page/stack ($C008)
- **80STORE**: OFF ($C000)
- **PAGE2**: OFF ($C054)
- **HiRes**: OFF ($C056)
- **Language Card**: ROM enabled, no writes

Software must explicitly configure auxiliary memory soft switches as needed.

### Implementation Notes

**For Clean-Room ROM Implementation:**

1. **Default State:** Initialize all soft switches to default state on reset (main RAM, 40-column mode)
2. **Interrupt Safety:** Always switch to main zero page/stack during interrupts unless handling auxiliary-specific tasks
3. **Stack Preservation:** Save stack pointers when switching between main/auxiliary stacks
4. **Display Modes:** Document which routines require 80STORE mode (80-column text routines)
5. **Memory Configuration Tracking:** Maintain memory state encoding for interrupt context switching
6. **Double-Read Protection:** Ensure language card write switches properly implement two-read requirement

**Memory Requirements:**

- Auxiliary RAM support is **optional** for 4KB ROM implementations (II/II+ compatibility only)
- Required for **IIe/IIc** ROM implementations
- 80-column display routines **require** auxiliary RAM support

### See Also

- [RAM Initialization and Memory Detection](#ram-initialization-and-memory-detection) - Boot-time memory configuration
- [CHK80](#chk80) - Check if 80-column mode is enabled
- [Home](#home) - Clear screen (handles both 40 and 80-column modes)
- [Reset](#reset-fa62) - System reset and initialization
