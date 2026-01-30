## <a id="system-boot-and-initialization"></a>System Boot and Initialization

### Overview

The Apple II boot process encompasses hardware reset, firmware initialization, memory configuration, and optional peripheral device boot loading. This section documents the complete boot sequence and initialization requirements for implementing compatible ROM firmware.

### Boot Sequence Overview

The complete boot process follows this sequence:

1. **Hardware Reset** - Power-on or manual RESET button pressed
2. **6502 Reset Vector** - Processor loads reset vector from $FFFC-$FFFD
3. **Firmware Reset Routine** - Executes system initialization code at vector address
4. **Memory Initialization** - Clear screen, detect RAM size, initialize variables
5. **Warm Start Detection** - Check if valid warm start signature present (IIe+)
6. **Peripheral Slot Scan** - Check slots 1-7 for boot ROMs (II/II+/IIe only)
7. **Peripheral Boot** - Execute first boot ROM found, if any
8. **Default Entry** - Enter Monitor or BASIC if no boot device found

### Hardware Reset

**Reset Trigger:**

- Power-on (cold start)
- RESET button pressed (warm start if signature valid)
- Watchdog timer (if present)
- Software-initiated reset

**Processor Behavior:**

- 6502 reads reset vector from $FFFC-$FFFD
- Jumps to address specified in vector
- Stack pointer undefined (firmware must initialize)
- Decimal mode undefined (firmware must clear)
- Interrupt disable flag set

### Firmware Reset Routine

The firmware reset entry point initializes the system and decides whether to perform a warm start or cold start. (The entry point address differs across ROM families; see [Reset ($FA62)](#reset-fa62) for the documented contract of the Reset routine in this specification.)

**Required Initialization Steps:**

1. **Initialize Processor State:**
   - Clear decimal mode (CLD instruction)
   - Set stack pointer to $FF (LDX #$FF, TXS)
   - Disable interrupts initially (SEI)

2. **Configure Memory:**
   - Switch in main ROM (if banked)
   - Set main RAM for reading/writing (IIe/IIc)
   - Initialize language card to ROM mode (if present)

3. **Initialize I/O:**
   - Set text mode, page 1 (display switches)
   - Clear keyboard strobe
   - Initialize speaker state

4. **Test for Warm Start:**
   - Check PWREDUP magic byte (IIe+)
   - If valid, jump to SOFTEV (skip full initialization)
   - If invalid, continue with cold start

5. **Clear Screen Memory:**
   - Fill $0400-$0BFF with spaces ($A0)
   - Or use efficient clearing routine
   - Preserve zero page and stack

6. **Detect RAM Configuration:**
   - Test for language card (II/II+)
   - Test for auxiliary memory (IIe)
   - Set HIMEM appropriately

7. **Initialize System Variables:**
   - Set input buffer pointers
   - Initialize monitor variables
   - Set default window bounds

8. **Establish Interrupt Vectors:**
   - Set BRKV (break handler)
   - Set SOFTEV (warm start entry)
   - Set IRQLOC (IRQ handler)

9. **Scan for Peripheral Boot:**
   - Check slots for boot signature
   - Jump to first boot ROM found
   - Fall through to Monitor/BASIC if none

### Memory Initialization

**Cold Start Memory Clearing:**

On a cold start, firmware should initialize memory and hardware into a predictable state suitable for the Monitor and for any BASIC ROM that may be present (e.g., a system pairing a historical BASIC ROM with a re-implemented system/monitor ROM).

A common historical baseline is:

- Clear text screen memory and display a “blank” text page (typically by filling text pages with the high-bit-set space character, `$A0`).
- Initialize the Monitor’s core low-memory workspace and vectors so that standard entry points (input, output, BRK/IRQ, warm start) behave consistently.

Cold-start initialization must avoid overwriting:

- Zero page ($00-$FF)
- The active stack page ($0100-$01FF)

**Recommendation (compatibility):**

If maximum compatibility with legacy software is desired, clear at least the standard text-page memory region ($0400-$0BFF) to `$A0` and ensure cursor/window state is initialized to a full-screen text window with the cursor at the upper-left.

**Implementation notes:**

- The specific clearing algorithm is an implementation choice, but the observable result should be a usable text display and a consistent initial Monitor/BASIC environment.
- For performance, historical ROMs typically use indexed addressing and page-oriented loops when clearing contiguous memory ranges.
- If the implementation supports auxiliary memory banking, it should also ensure the default display and memory mapping state is well-defined at the end of reset.

#### Recommended default low-memory and soft-switch state (cold start)

After cold-start initialization, a compatibility-focused ROM should establish at least the following defaults (exact values may vary by ROM family, but these are common expectations):

- **Text output/window state:**
  - `[WNDLFT](#wndlft) = 0`
  - `[WNDWDTH](#wndwdth) = 40` (or 80 only if the implementation enables and supports 80-column mode)
  - `[WNDTOP](#wndtop) = 0`
  - `[WNDBTM](#wndbtm) = 23`
  - `[CH](#ch) = 0`, `[CV](#cv) = 0`
  - `[INVFLG](#invflg)` set for normal text output

- **Standard I/O hooks:**
  - `[CSWL/CSWH](#cswl-cswh)` set to the standard screen output routine (see [SetVid](#setvid-fe93))
  - `[KSWL/KSWH](#kswl-kswh)` set to the standard keyboard input routine (see [SetKbd](#setkbd-fe89))

- **Vectors:**
  - `[BRKV](#brkv)` set to the default BRK/Break handler
  - `[IRQLOC](#irqloc)` set to the default IRQ handler (often an immediate `RTI`)
  - `[SOFTEV](#softev)` set to the default warm-start entry

- **Soft switches (common baseline):**
  - Text mode selected, page 1 selected, and mixed/graphics modes off unless intentionally entered via a graphics init routine
  - If auxiliary memory mapping exists, default to “main” mappings (main ZP/stack, main read/write) unless the ROM explicitly boots into an alternate mapping

### RAM Size Detection

**Apple II and II+:**

Early systems perform memory test to determine RAM size:

**Detection Algorithm:**

1. Write test pattern to memory location
2. Read back and verify pattern matches
3. Write complementary pattern
4. Read back and verify second pattern
5. If both patterns verify, RAM exists at that address
6. Continue testing upward until no RAM found
7. Set HIMEM to highest working address

**Test Patterns:**

- Pattern 1: Alternating bits (e.g., $55 = 01010101)
- Pattern 2: Inverted pattern (e.g., $AA = 10101010)
- Tests that RAM cells can hold both 0 and 1 values

**Apple IIe and IIc:**

Later systems have fixed memory configurations:

- IIe: 64K or 128K (detect auxiliary memory card)
- IIc: Always 128K (no detection needed)
- No runtime RAM size test required

**Auxiliary Memory Detection (IIe):**

Test for auxiliary memory presence:

1. Switch to auxiliary RAM ($C003/$C005)
2. Write test value to $0800
3. Switch to main RAM ($C002/$C004)
4. Write different value to $0800
5. Switch to auxiliary, read back
6. If original value present, auxiliary RAM exists
7. Use sparse memory test ($0800 vs $0C00) for reliability

**Language Card Detection (II/II+/IIe):**

Test for language card presence:

1. Enable LC bank 1 ($C08B, $C08B - two reads)
2. Save byte from $D000
3. Write test pattern to $D000
4. Read back and compare
5. Write complementary pattern
6. Read back and compare
7. If both match, language card present
8. Restore original byte

### Warm Start Detection

To avoid unnecessary re-initialization on RESET, firmware checks for warm start signature.

**Warm Start Mechanism:**

Magic bytes at fixed locations indicate valid warm start:

- **PWREDUP** ($03F4): Power-up detection byte
- **SOFTEV** ($03F2-$03F3): Warm start entry point vector

**Detection Algorithm:**

Check: `(SOFTEV_LOW XOR PWREDUP) = $A5`

If true:

- System was previously initialized
- Memory contents preserved
- Skip memory test and clearing
- Jump directly to SOFTEV address

If false:

- Perform full cold start initialization
- After initialization, set PWREDUP:
  - `PWREDUP = (SOFTEV_LOW XOR $A5)`

**Benefits:**

- RESET returns to Monitor/BASIC without clearing programs
- User programs remain in memory
- BASIC program text preserved
- Faster restart

### Peripheral Device Boot

After firmware initialization, control may transfer to peripheral device boot ROM.

**Boot ROM Location:**

- **Address:** $Cn00 (n = slot number, 1-7)
- **Size:** 256 bytes ($Cn00-$CnFF per slot)
- **Example:** Disk II controller in slot 6 = $C600-$C6FF

**Slot Scan Algorithm:**

Firmware scans slots sequentially:
```
FOR slot = 7 DOWN TO 1
    Check $Cn00 for boot signature
    IF valid signature THEN
        JSR $Cn00
        (Boot ROM executes)
    END IF
NEXT slot
```

**Boot ROM Requirements:**

- Must be slot-independent (don't assume specific slot)
- Should determine slot via return address examination
- Can use IORTS routine ($FF58) to get slot number
- Must preserve system state or completely replace it

**Single Boot Device:**

- Firmware executes first boot ROM found
- Subsequent slots not checked after successful boot
- Boot ROM can return control to continue slot scan

**Common Boot Devices:**

- Disk II controller (slot 6 typically)
- SmartPort hard drives (slots 4-7)
- Network cards
- Other mass storage

### System Vectors and Hooks

Firmware establishes interrupt and entry vectors during initialization:

| Address | Vector | Purpose | Default | Modifiable |
|---------|--------|---------|---------|------------|
| $03F0-$03F1 | BRKV | BRK instruction handler | Monitor | Yes |
| $03F2-$03F3 | SOFTEV | Warm start entry | Reset/Monitor | Yes |
| $03F4 | PWREDUP | Power-up detection | Magic byte | Firmware sets |
| $03FE-$03FF | IRQLOC | IRQ handler vector | Firmware IRQ | Yes |

**Vector Usage:**

Software can modify vectors to customize system behavior:

- Change BRKV to custom debugger
- Set SOFTEV to application entry point
- Hook IRQLOC for custom interrupt handling

Firmware must establish reasonable defaults and allow modification.

### Reset Button Behavior

RESET button behavior depends on warm start signature:

**Valid Warm Start:**

- Jump to SOFTEV without clearing memory
- Existing programs preserved
- BASIC programs remain loaded
- Can resume execution via Control-C or Monitor commands

**Invalid Signature (Cold Start):**

- Full initialization performed
- Memory cleared
- System variables reset
- Enter Monitor or BASIC from scratch

**This allows:**

- Developers to debug code without losing work
- Return to BASIC after program crash
- Test and retry without reloading

### Boot and Initialization Implementation Requirements

**For Clean-Room ROM Implementation:**

1. **Provide Reset Vector:**
   - Place reset routine address at $FFFC-$FFFD
   - Ensure routine accessible on power-up

2. **Initialize All Subsystems:**
   - Processor state (stack, flags)
   - Memory configuration
   - I/O and soft switches
   - System variables

3. **Detect Memory Configuration:**
   - Test for RAM size (II/II+ with variable RAM)
   - Detect auxiliary memory (IIe)
   - Detect language card
   - Set HIMEM/LOMEM appropriately

4. **Support Warm Start:**
   - Implement PWREDUP/SOFTEV check
   - Preserve programs on RESET
   - Set magic bytes after initialization

5. **Enable Peripheral Boot:**
   - Scan slots for boot ROMs
   - Execute first valid boot ROM
   - Provide IORTS for slot detection

6. **Establish Vectors:**
   - Set default interrupt handlers
   - Allow software modification
   - Document vector usage

**Memory Requirements:**

- Zero page: ~40 bytes for system variables
- Stack: Full 256-byte page ($0100-$01FF)
- Input buffer: 128 bytes ($0200-$027F)
- System vectors: ~32 bytes ($03E0-$03FF)

**Feature Scope Notes:**

- Full memory test optional (can assume fixed size)
- Auxiliary memory support optional (not in II/II+)
- Peripheral boot scanning optional (can boot from known slot)
- Warm start support recommended but not required for basic compatibility

### See Also

- **[Reset ($FA62)](#reset-fa62)** - Firmware reset entry point
- **[PwrUp](#pwrup-faa6)** - Power-up initialization routine
- **[Hardware Variants and Identification](#hardware-variants-and-identification)** - Model-specific boot behavior
- **[Memory System](#memory-system)** - Memory organization
- **[ROM Organization and Banking](#rom-organization-and-banking)** - ROM structure
- **[Peripheral Controller ROMs](#peripheral-controller-roms)** - Boot ROM protocols
