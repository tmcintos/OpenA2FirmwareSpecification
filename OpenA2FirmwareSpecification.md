---
author: Open A2 ROM Specification Contributors
date: January 2026
subtitle: Technical Reference Manual for Apple II Family ROM
title: Open A2 Firmware Specification
---

# Open A2 Firmware Specification

## Technical Reference Manual for 8-bit Apple II Family ROM

**Document Version:** 0.1.3 **Date:** January 2026  
**Status:** Technical Reference

------------------------------------------------------------------------

This document provides a detailed technical specification for 8-bit
system firmware in the 6502-based Apple II family. It is intended for
developers creating compatible software, implementing clean-room ROM
versions, or seeking to understand the documented firmware contract.

------------------------------------------------------------------------

**Legal Notice:** This specification uses descriptive references to
identify the systems and products it documents (referred to as “Apple II
family” or by variant names when necessary for clarity). Such references
acknowledge the trademark rights of Apple Inc.

**Open-Source Nature:** This is a clean-room technical specification
created through analysis and synthesis of published materials, intended
to document the behavioral contract that software depends on—not to
reproduce proprietary implementation details.

------------------------------------------------------------------------

## Introduction

### Purpose and Scope

This specification documents the application programming interface (API)
contract for the unified ROM implementation of 8-bit Apple II family
systems. It defines the behavior, entry points, memory locations, and
operational characteristics that software written for any Apple II
variant (Apple II, II+, IIe, IIc) can reliably depend upon.

The specification enables:

- Development of compatible ROMs in space-constrained configurations (4K
  minimum to full 32K banked)
- Understanding of the firmware contract without requiring access to
  proprietary Apple source code
- Clean-room implementation of ROM components
- Software compatibility verification

### How to Use This Document

This technical reference is organized to provide progressive
understanding, from high-level architecture to detailed specifications:

1.  **System Architecture Overview** - High-level introduction to Apple
    II hardware and firmware organization, including:
    - Hardware Variants and Identification
    - Memory System
    - Display System
    - I/O and Soft Switches
    - ROM Organization and Banking
2.  **System Boot and Initialization** - Reset handling, memory
    detection, warm start, peripheral boot protocols
3.  **Interrupt Handling** - BRK, IRQ, and NMI interrupts, memory state
    preservation, vector usage
4.  **Monitor User Interface** - Monitor commands, escape sequences,
    control characters, command dispatcher
5.  **Summary of Firmware Entry Points** - Quick reference table of all
    entry points with addresses
6.  **Detailed Firmware Entry Points** - Complete documentation of all
    system ROM routines with:
    - Input/output register contracts
    - Memory effects and side effects
    - Internal dependencies and call chains
    - Implementation requirements
7.  **Symbol Definitions** - Zero-page variables, system variables,
    hardware registers referenced throughout
8.  **Peripheral Controller ROMs** - Overview of peripheral ROM
    protocols and boot ROM identification
9.  **Disk II Controller ROM Specification** - Complete technical
    reference for the standard 5.25” disk controller

Within each routine entry, you will find:

- **Input Requirements** - Register and memory values expected on entry
- **Output Guarantees** - Register and memory values upon exit
- **Side Effects** - Other observable changes (calls to other routines,
  memory modifications)
- **Notes** - Implementation considerations and compatibility guidance

### Compatibility Philosophy

A correctly-implemented unified ROM following this specification should
run software from any Apple II variant without variant detection. If
variant-specific code paths are required, it indicates either:

1.  The specification is incomplete, or
2.  The implementation has diverged from the documented contract

This design principle enables clean, maintainable ROM implementations
suitable for modern reproduction systems.

## System Architecture Overview

The Apple II family represents a cohesive architecture that evolved over
more than a decade while maintaining backward compatibility. This
section provides a high-level overview of the system architecture common
to all 8-bit Apple II computers, establishing the foundation for
understanding the detailed specifications that follow.

### Design Philosophy

The Apple II architecture is characterized by:

- **Simplicity:** Minimal hardware complexity, maximum software
  flexibility
- **Expandability:** Slot-based peripheral architecture (except IIc)
- **Compatibility:** Each generation maintains compatibility with
  software from earlier models
- **Memory-Mapped I/O:** All hardware control through memory addresses,
  no special I/O instructions
- **Open Architecture:** Documented interfaces enable third-party
  hardware and software

### Core Components

**Processor:**

- 6502 microprocessor @ 1.023 MHz (original models)
- 65C02 @ 1.023 MHz (enhanced models) or @ 4 MHz (IIc Plus)
- 8-bit data bus, 16-bit address bus (64KB address space)

**Memory:**

- 48KB to 128KB RAM depending on model and configuration
- 8KB to 32KB ROM containing firmware and system software
- Bank-switched memory expansion (language card, auxiliary RAM)

**Display:**

- Text modes:
  - 40-column or
  - 80-column (IIe/IIc with appropriate hardware)
- Graphics modes:
  - Low-resolution (40×48),
  - High-resolution (280×192)
  - Double high-resolution (560×192) on IIe/IIc with 128K RAM
- Memory-mapped video with hardware support for page flipping

**I/O:**

- Memory-mapped soft switches (\$C000-\$C0FF)
- Slot-based peripheral cards (II/II+/IIe)
- Integrated peripherals (IIc)
- Standard keyboard and speaker

### Subsystem Overview

The following subsections detail major system components, providing the
architectural foundation for understanding Apple II firmware
implementation.

### Hardware Variants and Identification

#### Overview

The Apple II family encompasses multiple 8-bit hardware variants
spanning over a decade of evolution. Each variant has different
capabilities, memory configurations, and peripheral support. Firmware
and software can detect which hardware variant is present using
standardized identification bytes stored in ROM at fixed addresses.

This section documents the official Apple hardware identification
methods as specified in Apple II Miscellaneous Technical Notes \#7 and
\#2.

**References:**

- Apple II Miscellaneous Technical Note \#7: *Apple II Family
  Identification* (https://prodos8.com/docs/technote/misc/07/)
- Apple II Miscellaneous Technical Note \#2: *Apple II Family
  Identification Routines 2.2*
  (https://prodos8.com/docs/technote/misc/02/)

#### Apple II Family Models (8-bit)

**Core Models:**

- **Apple II** (1977) - Original model, 6502 CPU @ 1 MHz, 4KB-48KB RAM,
  cassette interface
- **Apple II+** (1979) - 6502 CPU @ 1 MHz, enhanced ROM, Applesoft
  BASIC, auto-start ROM
- **Apple IIe** (1983) - 6502 or 65C02 CPU @ 1.023 MHz, 64K-128K RAM,
  auxiliary memory support, lowercase, 80-column capability
- **Apple IIe Enhanced** (1985) - 65C02 CPU, enhanced ROM, improved
  monitor, additional routines
- **Apple IIc** (1984) - 65C02 CPU @ 1.023 MHz, integrated design, 128K
  RAM, built-in peripherals, ROM banking
- **Apple IIc Plus** (1988) - 65C02 CPU @ 4 MHz, final 8-bit model,
  accelerated processor, enhanced instruction set, cache memory

**Special Variants:**

- **Apple IIe Card** (1991) - IIe emulation card for Macintosh LC, 65C02
  CPU
- **Apple ///** - 6502-based system with Apple II emulation mode

**Out of Scope:**

- **Apple IIgs** (16-bit, 65C816 CPU) - Can be detected via
  [IDRoutine](#idroutine-fe1f) but behavior not documented in this
  specification

**Processor Note:** The 65C02 is an enhanced version of the 6502 with
additional instructions, bug fixes, and lower power consumption. The IIc
Plus uses the 65C02 at 4 MHz (compared to ~1 MHz in other models),
providing significantly faster performance while maintaining
instruction-level compatibility.

#### Identification Byte Locations

Apple provides standardized ROM identification bytes that software can
read to determine hardware type and ROM revision. All identification
bytes reside in the main ROM bank and must be read with main ROM
switched in.

**Primary Identification Bytes:**

| Address    | Apple II | Apple II+ | Apple /// | IIe  | IIe Enhanced | IIe Card | IIc  |
|------------|----------|-----------|-----------|------|--------------|----------|------|
| **\$FBB3** | \$38     | \$EA      | \$EA      | \$06 | \$06         | \$06     | \$06 |
| **\$FB1E** | \-       | \$AD      | \$8A      | \-   | \-           | \-       | \-   |
| **\$FBC0** | \-       | \-        | \-        | \$EA | \$E0         | \$E0     | \$00 |
| **\$FBDD** | \-       | \-        | \-        | \-   | \-           | \$02     | \-   |

**ROM Revision Bytes:**

| Address | Purpose | Values |
|----|----|----|
| **\$FBBF** | IIc ROM revision | \$FF = original, \$00 = 3.5 ROM, \$03 = Mem.Exp., \$04 = Rev.Mem.Exp., \$05 = IIc Plus |
| **\$FBBE** | IIe Card version | \$00 = first release |

**Note:** The Apple IIgs (16-bit system, out of scope) matches enhanced
IIe identification bytes. Use the [IDRoutine](#idroutine-fe1f) at \$FE1F
to distinguish IIgs from 8-bit systems.

#### Hardware Detection Algorithm

To correctly identify an Apple II variant, use the following procedure:

**Step 1: Test for 16-bit System (Optional)**

If your software needs to distinguish 8-bit from 16-bit systems, call
[IDRoutine](#idroutine-fe1f) at \$FE1F:

    SEC         ; Set carry flag
    JSR $FE1F   ; Call IDRoutine
    BCS IS_8BIT ; Carry still set = 8-bit system
    ; Carry clear = 16-bit system (IIgs, out of scope)

If targeting only 8-bit systems, this step may be skipped.

**Step 2: Identify 8-bit Model**

Read \$FBB3 to determine basic model family:

- **\$FBB3 = \$38:** Apple II (original)
- **\$FBB3 = \$EA:** Apple II+ or Apple /// (check \$FB1E to
  distinguish)
  - \$FB1E = \$AD: Apple II+
  - \$FB1E = \$8A: Apple /// emulation mode
- **\$FBB3 = \$06:** IIe family (IIe, IIc, or IIe Card)

**Step 3: Identify IIe Family Variant**

If \$FBB3 = \$06, read \$FBC0:

- **\$FBC0 = \$EA:** Original (unenhanced) Apple IIe
- **\$FBC0 = \$00:** Apple IIc family (read \$FBBF for specific model)
- **\$FBC0 = \$E0:** Enhanced IIe or IIe Card (check \$FBDD to
  distinguish)
  - \$FBDD = \$02: Apple IIe Card
  - \$FBDD ≠ \$02: Enhanced Apple IIe

**Step 4: Determine ROM Revision**

Within a model family, read the revision byte:

- **IIc family:** Read \$FBBF
  - \$FF = Apple IIc (original ROM)
  - \$00 = Apple IIc (3.5 ROM)
  - \$03 = Apple IIc (Memory Expansion)
  - \$04 = Apple IIc (Revised Memory Expansion)
  - \$05 = Apple IIc Plus (65C02 @ 4 MHz)
- **IIe Card:** Read \$FBBE
  - \$00 = First release
- **Enhanced IIe:** Read \$FBBF (implementation-defined)

#### Model Constants

For software portability, use these standard model identification
constants:

| Constant       | Value | Model                                      |
|----------------|-------|--------------------------------------------|
| UNKNOWN        | \$00  | Unknown or unidentified system             |
| APPLE_II       | \$01  | Apple II (original)                        |
| APPLE_II_PLUS  | \$02  | Apple II+                                  |
| APPLE_III_EM   | \$03  | Apple /// in emulation mode                |
| APPLE_IIE      | \$04  | Apple IIe (includes enhanced and original) |
| APPLE_IIC      | \$05  | Apple IIc (all variants)                   |
| APPLE_IIE_CARD | \$06  | Apple IIe Card for Macintosh LC            |

#### Hardware Capability Differences

**Memory Configuration:**

- **Apple II/II+:** 48K or 64K (with language card)
- **Apple IIe:** 64K or 128K (with auxiliary memory card)
- **Apple IIc family:** 128K standard (64K main + 64K auxiliary)
- **Apple IIe Card:** 128K standard

**Peripheral Architecture:**

- **Apple II/II+/IIe:** Slot-based expansion (8 slots)
- **Apple IIc:** Integrated peripherals (no expansion slots)
- **Apple IIe Card:** Limited slot emulation

**Display Capabilities:**

- **Apple II/II+:** 40-column text, Lo-Res, Hi-Res graphics
- **Apple IIe:** Adds 80-column text (with card), double hi-res (with
  128K)
- **Apple IIc:** Built-in 80-column, double hi-res

**ROM Organization:**

- **Apple II/II+:** 8KB ROM (12KB with autostart, can be shadowed in
  language card \$D000-\$FFFF)
- **Apple IIe:** 16KB ROM (main and auxiliary/slot ROM areas)
- **Apple IIc:** 16KB or 32KB ROM (banked via \$C028)

**Processor:**

- **Apple II/II+:** 6502 @ 1.023 MHz
- **Apple IIe (original):** 6502 @ 1.023 MHz
- **Apple IIe (enhanced):** 65C02 @ 1.023 MHz
- **Apple IIc family:** 65C02 @ 1.023 MHz
- **Apple IIc Plus:** 65C02 @ 4 MHz (accelerated)

#### Variant-Specific Behaviors

**SLOTCXROM (\$C006/\$C007) and SLOTC3ROM (\$C00A/\$C00B):**

These soft switches control ROM selection in the \$C100-\$CFFF
peripheral ROM area:

- **Apple IIe:** Switches between slot ROM cards and internal ROM
  - \$C006 write = 0: Use slot ROMs
  - \$C007 write = 1: Use internal ROM
  - \$C00A write = 0: Use internal \$C300 ROM
  - \$C00B write = 1: Use slot 3 ROM for \$C300
- **Apple IIc:** No effect (always uses internal ROM, no physical slots)

**Internal \$C3xx ROM Selection (IIe-specific):**

On the Apple IIe, accessing any address in page \$C3 (\$C300-\$C3FF)
automatically selects internal ROM for the \$C800-\$CFFF range. This
internal ROM selection remains active until an address in \$C1xx,
\$C2xx, \$C4xx-\$C7xx, or \$CFFF is accessed.

This behavior does not apply to Apple IIc (which always uses internal
ROM).

**Cassette Interface:**

- **Apple II/II+:** Hardware cassette interface, monitor commands for
  tape I/O
- **Apple IIe/IIc:** No cassette interface (use serial or disk)

**Built-in Peripherals:**

- **Apple II/II+/IIe:** All peripherals via expansion slots
- **Apple IIc:** Built-in disk controller, serial ports, mouse interface

#### Hardware Identification Implementation Requirements

**For Clean-Room ROM Implementation:**

1.  **Provide Identification Bytes:** Place appropriate values at
    documented addresses (\$FBB3, \$FBC0, etc.) based on target system
2.  **Implement IDRoutine:** 8-bit systems should provide a single RTS
    instruction at \$FE1F
3.  **Ensure Main ROM Access:** ID bytes must be readable from main ROM
    bank (not auxiliary or banked ROM)
4.  **Choose Revision Values:** ROM revision bytes (\$FBBF, \$FBBE) can
    be implementation-defined within model family
5.  **Document Variant Features:** Clearly mark which features are
    model-specific (e.g., “\[IIc only\]”, “\[IIe+\]”)

**For Software Compatibility:**

1.  **Switch in Main ROM:** Ensure main ROM is selected before reading
    ID bytes
2.  **Follow Check Order:** Use documented detection algorithm to avoid
    misidentification
3.  **Don’t Assume Features:** Verify capabilities based on detected
    model (don’t assume 128K, 80-column, slots, etc.)
4.  **Handle Missing Features Gracefully:** Software should degrade
    gracefully when optional features (80-column, auxiliary RAM) are
    absent

#### See Also

- **[IDRoutine (\$FE1F)](#idroutine-fe1f)** - System identification
  entry point
- **[RAM Initialization and Memory
  Detection](#ram-initialization-and-memory-detection)** - Memory
  configuration details
- **[ROM Organization and Banking](#rom-organization-and-banking)** -
  ROM banking and structure
- **[I/O and Soft Switches](#io-and-soft-switches)** - Soft switch
  reference including SLOTCXROM/SLOTC3ROM

### Memory System

#### Overview

The Apple II memory architecture uses the 6502 processor’s 64KB address
space (\$0000-\$FFFF) to provide system RAM, peripheral I/O, and
firmware ROM. Different models in the Apple II family have varying
memory configurations, from 48KB in early systems to 128KB in later
models with auxiliary memory support.

#### Memory Map

The complete 64KB address space is organized as follows:

| Address Range | Size      | Purpose                                         |
|---------------|-----------|-------------------------------------------------|
| \$0000-\$00FF | 256 bytes | Zero-page memory (fast-access system variables) |
| \$0100-\$01FF | 256 bytes | 6502 stack (subroutine calls, interrupts)       |
| \$0200-\$02FF | 256 bytes | Input buffer and system workspace               |
| \$0300-\$03FF | 256 bytes | System vectors and additional workspace         |
| \$0400-\$07FF | 1KB       | Text/Low-Res Page 1 (primary display page)      |
| \$0800-\$0BFF | 1KB       | Text/Low-Res Page 2 (secondary display page)    |
| \$0C00-\$1FFF | 5KB       | Free RAM                                        |
| \$2000-\$3FFF | 8KB       | High-Resolution Graphics Page 1                 |
| \$4000-\$5FFF | 8KB       | High-Resolution Graphics Page 2                 |
| \$6000-\$95FF | ~14KB     | Free RAM                                        |
| \$9600-\$BFFF | ~10KB     | DOS/ProDOS or free RAM                          |
| \$C000-\$C0FF | 256 bytes | I/O soft switches and hardware registers        |
| \$C100-\$C7FF | 1.75KB    | Peripheral slot ROMs (\$Cn00-\$CnFF per slot)   |
| \$C800-\$CFFF | 2KB       | Peripheral ROM expansion area                   |
| \$D000-\$FFFF | 12KB      | ROM or bank-switched RAM (language card)        |

#### Main RAM Organization (48K)

**Apple II and II+ Standard Configuration:**

Basic systems provide 48KB of main RAM organized as:

**System Area (\$0000-\$03FF, 1KB):**

- Zero page (\$00-\$FF): System variables, pointers, temporary storage
- Stack (\$0100-\$01FF): Subroutine return addresses, interrupt state
- Input buffer (\$0200-\$02FF): Monitor and BASIC command input
- System vectors (\$0300-\$03FF): Interrupt vectors, system pointers

**Display Memory (\$0400-\$0BFF, 2KB):**

- Text/Low-Res Page 1 (\$0400-\$07FF): Primary text screen
- Text/Low-Res Page 2 (\$0800-\$0BFF): Secondary text screen

**Graphics Memory (\$2000-\$5FFF, 16KB):**

- Hi-Res Page 1 (\$2000-\$3FFF): 8KB primary graphics
- Hi-Res Page 2 (\$4000-\$5FFF): 8KB secondary graphics

**Program Area:**

- \$0C00-\$1FFF: 5KB available immediately after display memory
- \$6000-\$95FF: ~14KB mid-memory area
- \$9600-\$BFFF: ~10KB high memory (often used by DOS/ProDOS)

#### Auxiliary RAM (Apple IIe/IIc - 64K)

Apple IIe (with 128K) and all IIc models include 64KB of auxiliary RAM
occupying the same address space as main RAM, accessed via soft
switches.

**Memory Architecture:**

- 64KB main RAM at \$0000-\$BFFF (plus bank-switched \$D000-\$FFFF)
- 64KB auxiliary RAM at \$0000-\$BFFF (same addresses, different bank)
- Total: 128KB accessible via bank switching

**Dual Zero Page and Stack:**

- Main zero page: \$0000-\$00FF in main RAM
- Auxiliary zero page: \$0000-\$00FF in auxiliary RAM
- Main stack: \$0100-\$01FF in main RAM
- Auxiliary stack: \$0100-\$01FF in auxiliary RAM
- Selected via AUXZP soft switch (\$C008/\$C009)

**Display Memory Interleaving:**

For 80-column text and double high-resolution graphics, display memory
is interleaved:

- Even columns/pixels: Auxiliary RAM
- Odd columns/pixels: Main RAM
- Hardware automatically interleaves during video generation

#### Bank-Switched Language Card (16K)

The language card provides 16KB of RAM in the \$D000-\$FFFF address
space for loading alternate languages or user programs.

**Memory Organization:**

- \$D000-\$DFFF: Bank 1 or Bank 2 (4KB, selectable)
- \$E000-\$FFFF: Common area (12KB, same in both banks)
- Total: 16KB (two 4KB banks + one 12KB common)

**Banking Mechanism:**

Controlled via soft switches at \$C080-\$C08F. See [ROM Organization and
Banking](#rom-organization-and-banking) for complete details.

**Purpose:**

- Load programming languages (Pascal, FORTRAN) into RAM
- Execute code from RAM instead of ROM
- Provide additional program space
- Two banks allow quick switching between programs

#### Memory Configuration by Model

**Apple II (1977):**

- 4KB minimum (expandable to 48KB)
- Optional language card for 64KB total
- Single memory bank

**Apple II+ (1979):**

- 48KB standard
- Optional language card for 64KB total
- Single memory bank

**Apple IIe (1983):**

- 64KB standard (main RAM only)
- Optional auxiliary memory card for 128KB total
- Supports language card
- Dual memory banks (main/auxiliary)

**Apple IIc (1984-1988):**

- 128KB standard (64KB main + 64KB auxiliary)
- No language card socket (ROM is banked instead)
- Dual memory banks always present
- Built-in ROM banking (\$C028)

**Apple IIe Card (1991):**

- 128KB standard (64KB main + 64KB auxiliary)
- Dual memory banks
- Emulates enhanced IIe

#### Address Range Details

**Zero Page (\$0000-\$00FF):**

Fast-access memory for system variables and temporary storage. Used
extensively by:

- Monitor routines (pointers, counters)
- BASIC interpreter (variable storage)
- DOS/ProDOS (file system state)

See [Zero-Page Definitions](#zero-page-definitions) for complete
variable reference.

**Stack (\$0100-\$01FF):**

Hardware stack used by 6502 processor for:

- JSR/RTS return addresses
- Interrupt state (processor status, PC)
- PHA/PLA temporary storage
- Local variables

Grows downward from \$01FF. Stack overflow occurs if it wraps below
\$0100.

**Input Buffer (\$0200-\$02FF):**

Command-line input buffer used by Monitor for storing user-entered
commands. Also used by:

- BASIC GET/INPUT statements
- DOS/ProDOS file operations
- Application input buffering

**System Vectors (\$0300-\$03FF):**

Contains interrupt vectors, system entry points, and control flags:

- SOFTEV (\$03F2-\$03F3): Warm start entry point
- PWREDUP (\$03F4): Power-up detection byte
- BRKV (\$03F0-\$03F1): Break handler vector
- IRQLOC (\$03FE-\$03FF): IRQ handler vector

See [System Boot and Initialization](#system-boot-and-initialization)
for vector usage.

**Display Pages (\$0400-\$0BFF):**

Two 1KB text/low-res pages supporting page flipping:

- Page 1 (\$0400-\$07FF): Default display page
- Page 2 (\$0800-\$0BFF): Alternate page

Each page organized as 24 rows of 40 bytes (960 bytes used, 64 bytes
holes per page).

**Graphics Pages (\$2000-\$5FFF):**

Two 8KB high-resolution graphics pages:

- Page 1 (\$2000-\$3FFF): Primary hi-res graphics
- Page 2 (\$4000-\$5FFF): Secondary hi-res graphics

Each page: 192 scan lines, interleaved addressing pattern.

**Peripheral I/O (\$C000-\$C0FF):**

Memory-mapped I/O for hardware control:

- \$C000-\$C00F: Display mode soft switches
- \$C010-\$C01F: Status registers and additional switches
- \$C020-\$C02F: Cassette, speaker, and other I/O
- \$C030-\$C05F: Graphics mode switches
- \$C060-\$C06F: Paddle/joystick inputs and push buttons
- \$C070-\$C07F: Game controller timing
- \$C080-\$C08F: Language card control
- \$C090-\$C0FF: Peripheral card I/O (slot-specific)

See [I/O and Soft Switches](#io-and-soft-switches) for complete
reference.

**Slot ROM Area (\$C100-\$CFFF):**

Peripheral expansion ROM space organized by slot:

- \$Cn00-\$CnFF: ROM for slot n (n = 1-7)
- \$C800-\$CFFF: 2KB expansion ROM area (bank-switched per slot)

IIe can switch between slot ROMs and internal ROMs via SLOTCXROM
(\$C006/\$C007).

**ROM Area (\$D000-\$FFFF):**

System firmware ROM containing:

- \$D000-\$F7FF: Applesoft BASIC interpreter (10KB)
- \$F800-\$FFFF: Monitor and system routines (2KB)

Can be shadowed by language card RAM on II/II+/IIe systems.

#### Memory System Implementation Notes

**For Clean-Room ROM Implementation:**

1.  **Support Variable Memory Sizes:**
    - Detect installed RAM during boot
    - Set HIMEM appropriately
    - Handle both 48K and 64K configurations
2.  **Initialize Memory Properly:**
    - Clear screen memory on cold start
    - Preserve user programs on warm start
    - Set system variables to known states
3.  **Respect Memory Boundaries:**
    - Don’t overwrite zero page during initialization
    - Protect stack area
    - Preserve user program area on RESET
4.  **Document Memory Requirements:**
    - Minimum RAM for firmware operation
    - Which features require 128K
    - Language card vs. auxiliary RAM tradeoffs

**For Software Compatibility:**

1.  **Detect Memory Configuration:**
    - Test for language card presence
    - Test for auxiliary memory
    - Don’t assume 128K available
2.  **Use Standard Memory Areas:**
    - Zero page locations as documented
    - Standard display pages
    - Input buffer conventions
3.  **Handle Page Alignment:**
    - Display pages on 1KB boundaries
    - Graphics pages on 8KB boundaries
    - Slot ROM on 256-byte boundaries

#### See Also

- **[RAM Initialization and Memory
  Detection](#ram-initialization-and-memory-detection)** - Boot-time
  memory configuration
- **[Auxiliary RAM and Memory Soft
  Switches](#auxiliary-ram-and-memory-soft-switches)** - Extended memory
  details
- **[ROM Organization and Banking](#rom-organization-and-banking)** -
  ROM structure and language card
- **[Zero-Page Definitions](#zero-page-definitions)** - System variable
  reference
- **[Hardware Variants and
  Identification](#hardware-variants-and-identification)** -
  Model-specific memory configurations

### Display System

#### Overview

The Apple II family provides multiple display modes for text and
graphics output, all using memory-mapped video. The display system reads
directly from RAM to generate the video signal, allowing programs to
update the screen by writing to standard memory locations. Later models
(IIe/IIc with 128K RAM) add 80-column text and double high-resolution
graphics through memory interleaving.

#### Display Modes

**Text Modes:**

- **40-Column Text**: Standard text mode, 40 characters × 24 rows
- **80-Column Text**: Available on IIe/IIc with appropriate hardware, 80
  characters × 24 rows

**Graphics Modes:**

- **Low-Resolution (Lo-Res)**: 40 × 48 pixels, 16 colors, uses text page
  memory
- **High-Resolution (Hi-Res)**: 280 × 192 pixels, 6 colors (with
  limitations)
- **Double High-Resolution**: 560 × 192 pixels (IIe/IIc with 128K only)

#### 40-Column Text Mode

**Characteristics:**

- 40 characters per line, 24 lines
- 7×8 character cells
- 96 printable characters (uppercase, numbers, symbols)
- Lowercase available on IIe/IIc
- Inverse, flash, and normal video attributes

**Memory Organization:**

- Page 1: \$0400-\$07FF (1KB)
- Page 2: \$0800-\$0BFF (1KB)
- Each page: 960 bytes used, 64 bytes unused (screen holes)

**Character Encoding:**

- Bit 7 determines display mode:
  - Bit 7=0, Bit 6=0: Inverse video
  - Bit 7=0, Bit 6=1: Flashing characters
  - Bit 7=1, Bit 6=x: Normal video
- Bits 5-0: Character code (\$00-\$3F for uppercase, \$40-\$5F for
  symbols, \$60-\$7F for lowercase on IIe+)

**Screen Memory Layout:**

Text memory is organized with a non-linear pattern:

- Rows 0-7: \$0400-\$047F, \$0480-\$04FF, …, \$0778-\$07F7
- Rows 8-15: \$0428-\$04A7, \$04A8-\$0527, …, \$07A0-\$081F
- Rows 16-23: \$0450-\$04CF, \$04D0-\$054F, …, \$07C8-\$0847

Formula:
`BASL = $0400 + (row & $07) << 7 + ((row & $18) << 2) + ((row & $18) << 4)`

#### 80-Column Text Mode

**Characteristics:**

- 80 characters per line, 24 lines
- 7×8 character cells (same as 40-column)
- Requires auxiliary memory (IIe with 80-column card or IIc)
- Double horizontal pixel clock (14 MHz vs. 7 MHz)

**Memory Organization:**

Memory is interleaved between main and auxiliary RAM:

- Even columns (0, 2, 4, … 78): Auxiliary RAM
- Odd columns (1, 3, 5, … 79): Main RAM
- Both use standard text page addresses (\$0400-\$07FF or \$0800-\$0BFF)

**Hardware Interleaving:**

The video hardware automatically fetches characters alternately:

1.  PHI0 (Phase 0): Read character from auxiliary RAM (even column)
2.  PHI1 (Phase 1): Read character from main RAM (odd column)
3.  Shift register clocked at double rate (14 MHz)

**Enabling 80-Column Mode:**

Requires setting multiple soft switches:

- \$C001 (80STORE): Enable 80-column store mode
- \$C050 or \$C051 (TEXT): Select text mode
- \$C054 or \$C055 (PAGE2): Select page 1 or page 2

#### Low-Resolution Graphics

**Characteristics:**

- 40 × 48 pixels (blocks)
- 16 colors
- Uses same memory as text pages
- Each character cell = two color blocks (top/bottom half)

**Memory Organization:**

- Page 1: \$0400-\$07FF
- Page 2: \$0800-\$0BFF
- Each byte = two pixels:
  - Low nibble (bits 3-0): Top half of character cell
  - High nibble (bits 7-4): Bottom half of character cell

**Color Values:**

| Value | Color       |
|-------|-------------|
| \$0   | Black       |
| \$1   | Magenta     |
| \$2   | Dark Blue   |
| \$3   | Purple      |
| \$4   | Dark Green  |
| \$5   | Gray 1      |
| \$6   | Medium Blue |
| \$7   | Light Blue  |
| \$8   | Brown       |
| \$9   | Orange      |
| \$A   | Gray 2      |
| \$B   | Pink        |
| \$C   | Light Green |
| \$D   | Yellow      |
| \$E   | Aqua        |
| \$F   | White       |

**Mixed Mode:**

Text and lo-res can be mixed: bottom 4 lines show text while top 20
lines show graphics.

- Controlled by MIXED soft switch (\$C052/\$C053)

#### High-Resolution Graphics

**Characteristics:**

- 280 × 192 pixels
- 6 displayable colors (with color fringing artifacts)
- Black and white always available
- Color depends on horizontal pixel position and byte pattern

**Memory Organization:**

- Page 1: \$2000-\$3FFF (8KB)
- Page 2: \$4000-\$5FFF (8KB)
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

Where Base = \$2000 (page 1) or \$4000 (page 2).

#### Double High-Resolution Graphics

**Characteristics:**

- 560 × 192 pixels
- 16 simultaneous colors
- Requires 128K RAM (auxiliary memory)
- IIe/IIc only

**Memory Organization:**

Memory interleaved between main and auxiliary RAM:

- Even columns: Auxiliary RAM (\$2000-\$3FFF or \$4000-\$5FFF)
- Odd columns: Main RAM (same addresses)
- Each byte = 4 pixels (2 bits per pixel with palette)

**Enabling Double Hi-Res:**

Requires:

- \$C001 (80STORE): Enable 80-column store
- \$C057 (HIRES): Enable hi-res mode  
- \$C054/\$C055 (PAGE2): Select page

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

**PAGE2 Soft Switch (\$C054/\$C055):**

- \$C054: Display page 1
- \$C055: Display page 2

**Benefits:**

- Smooth animation (draw to hidden page, flip)
- Reduced flicker
- Double-buffered graphics

#### Display Soft Switches

**Mode Selection:**

| Switch  | Address       | Function                               |
|---------|---------------|----------------------------------------|
| TEXT    | \$C050/\$C051 | Graphics (\$C050) or Text (\$C051)     |
| MIXED   | \$C052/\$C053 | Full screen (\$C052) or Mixed (\$C053) |
| PAGE2   | \$C054/\$C055 | Page 1 (\$C054) or Page 2 (\$C055)     |
| HIRES   | \$C056/\$C057 | Lo-Res (\$C056) or Hi-Res (\$C057)     |
| 80STORE | \$C000/\$C001 | Off (\$C000) or On (\$C001) - IIe/IIc  |

**Mode Combinations:**

| TEXT | MIXED | HIRES | Display Mode                             |
|------|-------|-------|------------------------------------------|
| 1    | x     | x     | 40-column text (or 80-column if 80STORE) |
| 0    | 0     | 0     | Full-screen lo-res graphics              |
| 0    | 1     | 0     | Lo-res graphics + 4 text lines           |
| 0    | 0     | 1     | Full-screen hi-res graphics              |
| 0    | 1     | 1     | Hi-res graphics + 4 text lines           |

See [I/O and Soft Switches](#io-and-soft-switches) for complete soft
switch reference.

#### Display Hardware Timing

**Video Signal Generation:**

- Horizontal: 65 cycles per scan line (40.5 µs)
- Vertical: 262 scan lines per frame (NTSC)
- Refresh rate: ~60 Hz
- Pixel clock: 14.318 MHz (NTSC color burst)

**Display vs. System Timing:**

- CPU clock: 1.023 MHz (synchronized with video)
- Memory access: Interleaved with video refresh
- Some cycles lost to video DMA (display RAM access)

#### Display System Implementation Notes

**For Clean-Room ROM Implementation:**

1.  **Initialize Display on Boot:**
    - Set default mode using soft switches (40-column text, page 1)
    - Clear screen memory during firmware initialization
    - Establish known default display state
2.  **Use Soft Switches Correctly:**
    - Access PAGE2 switch to control page display
    - Access mode switches to change text/graphics modes
3.  **Document Mode Requirements:**
    - Which modes require 128K RAM
    - 80-column requirements
    - Color limitations in hi-res
4.  **Provide Screen Routines:**
    - Home (clear screen)
    - Scroll (move text up)
    - Cursor positioning
    - Character output

**For Software Compatibility:**

1.  **Detect Display Capabilities:**
    - Test for 80-column hardware
    - Test for auxiliary memory (for double hi-res)
    - Don’t assume features present
2.  **Use Standard Memory Locations:**
    - Text pages at \$0400 and \$0800
    - Graphics pages at \$2000 and \$4000
    - Standard soft switch addresses
3.  **Handle Mode Switching Properly:**
    - Set all required soft switches
    - Ensure page alignment
    - Clear screen when changing modes

#### See Also

- **[Auxiliary RAM and Memory Soft
  Switches](#auxiliary-ram-and-memory-soft-switches)** - 80-column and
  double hi-res details
- **[I/O and Soft Switches](#io-and-soft-switches)** - Display control
  switches
- **[Memory System](#memory-system)** - Display memory organization
- **[Home](#home)** - Clear screen routine
- **[SetTxt](#settxt)** - Set text mode
- **[SetGr](#setgr)** - Set graphics mode

### I/O and Soft Switches

#### Overview

The Apple II family uses memory-mapped I/O for all hardware control.
Soft switches are memory locations in the \$C000-\$C0FF range that
control system hardware features when accessed. Reading or writing these
addresses changes hardware state without requiring special I/O
instructions.

This section provides a comprehensive reference to all soft switches
used in 8-bit Apple II systems.

#### Soft Switch Conventions

**Access Types:**

- **(R)**: Read to activate
- **(W)**: Write to activate (value doesn’t matter)
- **(R/W)**: Read or write to activate
- **(R7)**: Read bit 7 for status (1=on, 0=off)

**Toggle Behavior:**

- Some switches have separate on/off addresses
- Others toggle state each time they’re accessed
- Status switches return current state in bit 7

#### Memory Control Soft Switches (IIe/IIc)

**RAMRD - Read Bank Selection:**

- **\$C002** (R/W): RDMAINRAM - Read from main 48K RAM
- **\$C003** (R/W): RDCARDRAM - Read from auxiliary 48K RAM  
- **\$C013** (R7): Read RAMRD status (bit 7: 1=aux, 0=main)

**RAMWRT - Write Bank Selection:**

- **\$C004** (R/W): WRMAINRAM - Write to main 48K RAM
- **\$C005** (R/W): WRCARDRAM - Write to auxiliary 48K RAM
- **\$C014** (R7): Read RAMWRT status (bit 7: 1=aux, 0=main)

**AUXZP - Zero Page and Stack Banking:**

- **\$C008** (W): SETSTDZP - Use main zero page and stack
- **\$C009** (W): SETALTZP - Use auxiliary zero page and stack
- **\$C016** (R7): Read AUXZP status (bit 7: 1=aux, 0=main)

**Usage Example:**

    ; Switch to auxiliary RAM
    STA $C003    ; Read from auxiliary
    STA $C005    ; Write to auxiliary
    LDA ($3C),Y  ; Access auxiliary memory

    ; Return to main RAM
    STA $C002    ; Read from main
    STA $C004    ; Write to main

#### Display Control Soft Switches

**80STORE - Display Page Override (IIe/IIc):**

- **\$C000** (W): Turn OFF 80STORE
- **\$C001** (W): Turn ON 80STORE
- **\$C018** (R7): Read 80STORE status

When ON, PAGE2 overrides RAMRD/RAMWRT for display memory only, enabling
80-column text and double hi-res graphics.

**PAGE2 - Display Page Selection:**

- **\$C054** (R): Select Page 1 (primary display)
- **\$C055** (R): Select Page 2 (alternate display)
- **\$C01C** (R7): Read PAGE2 status

**TEXT - Text/Graphics Mode:**

- **\$C050** (R): Select graphics mode
- **\$C051** (R): Select text mode
- **\$C01A** (R7): Read TEXT status

**MIXED - Mixed Mode:**

- **\$C052** (R): Full screen mode
- **\$C053** (R): Mixed mode (graphics + 4 text lines)
- **\$C01B** (R7): Read MIXED status

**HIRES - Graphics Resolution:**

- **\$C056** (R): Lo-Res graphics mode
- **\$C057** (R): Hi-Res graphics mode
- **\$C01D** (R7): Read HIRES status

**Display Mode Combinations:**

| TEXT | MIXED | HIRES | 80STORE | Result                        |
|------|-------|-------|---------|-------------------------------|
| 1    | x     | x     | 0       | 40-column text                |
| 1    | x     | x     | 1       | 80-column text (IIe/IIc)      |
| 0    | 0     | 0     | 0       | Full lo-res graphics          |
| 0    | 1     | 0     | 0       | Lo-res + 4 text lines         |
| 0    | 0     | 1     | 0       | Full hi-res graphics          |
| 0    | 1     | 1     | 0       | Hi-res + 4 text lines         |
| 0    | x     | 1     | 1       | Double hi-res (IIe/IIc, 128K) |

#### Keyboard and Input

**KBD - Keyboard Data:**

- **\$C000** (R7): Read last key pressed (bit 7=1, bits 6-0=ASCII)
- Data remains until KBDSTRB accessed

**KBDSTRB - Keyboard Strobe:**

- **\$C010** (R/W): Clear keyboard strobe (clears bit 7 of KBD)

**RDBNK2 - Bank 2 Indicator (IIe):**

- **\$C011** (R7): Read language card bank status (1=bank 2, 0=bank 1)

**RDLCRAM - Language Card RAM Read:**

- **\$C012** (R7): Read LC RAM status (1=reading RAM, 0=reading ROM)

**Usage:**

    LDA $C000    ; Read keyboard
    BMI GOT_KEY  ; Branch if key pressed (bit 7=1)
    ; No key

    GOT_KEY:
    AND #$7F     ; Strip high bit to get ASCII
    STA $C010    ; Clear strobe

#### Peripheral Slot I/O

**Slot-Specific I/O (\$C0n0-\$C0nF):**

Each peripheral slot has 16 bytes of I/O space:

- **\$C0n0-\$C0nF**: I/O space for slot n (n=1-7)

Examples:

- **\$C060-\$C06F**: Slot 6 (typically Disk II controller)
- **\$C070-\$C07F**: Slot 7

**Slot ROM Control (IIe):**

- **\$C006** (W=0): SLOTCXROM - Use slot ROMs
- **\$C007** (W=1): SLOTCXROM - Use internal ROM
- **\$C00A** (W=0): SLOTC3ROM - Use slot 3 ROM
- **\$C00B** (W=1): SLOTC3ROM - Use internal \$C300 ROM

**Note:** On IIc, these switches have no effect (always uses internal
ROM).

#### Speaker and Cassette (II/II+)

**SPKR - Speaker Toggle:**

- **\$C030** (R/W): Toggle speaker state (creates click)

**CSSTOUT - Cassette Output:**

- **\$C020** (R/W): Toggle cassette output (II/II+ only)

**TAPEIN - Cassette Input:**

- **\$C060** (R7): Read cassette input (bit 7: tape signal)

**Note:** Cassette interface obsolete on IIe/IIc.

#### Game I/O

**Paddle Inputs:**

- **\$C064** (R7): Paddle 0 trigger (button 0)
- **\$C065** (R7): Paddle 1 trigger (button 1)
- **\$C066** (R7): Paddle 2 trigger (button 2)
- **\$C067** (R7): Paddle 3 trigger (button 3)

**Paddle Timing:**

- **\$C070** (R/W): Trigger paddle timers (starts paddle read)

After triggering, read paddle values by timing how long bits stay high:

    STA $C070    ; Trigger paddles
    ; Read loop counts until bit goes low
    PDL_LOOP:
    LDA $C064    ; Read paddle 0
    BPL PDL_DONE ; When bit 7 clear, done
    ; Increment counter
    JMP PDL_LOOP
    PDL_DONE:
    ; Counter value proportional to paddle position

**Push Buttons:**

- **\$C061** (R7): Push button 0 / Open-Apple key (IIe/IIc)
- **\$C062** (R7): Push button 1 / Closed-Apple key (IIe/IIc)
- **\$C063** (R7): Push button 2

#### Graphics Mode Switches

**AN0-AN3 - Annunciators/Graphics Control:**

- **\$C058** (R): AN0 OFF
- **\$C059** (R): AN0 ON
- **\$C05A** (R): AN1 OFF
- **\$C05B** (R): AN1 ON
- **\$C05C** (R): AN2 OFF  
- **\$C05D** (R): AN2 ON
- **\$C05E** (R): AN3 OFF / DHIRES OFF (IIe/IIc)
- **\$C05F** (R): AN3 ON / DHIRES ON (IIe/IIc)

On IIe/IIc, AN3 also controls double hi-res:

- \$C05E: Disable double hi-res
- \$C05F: Enable double hi-res (requires 80STORE and HIRES)

#### Language Card Soft Switches

The language card uses a two-read write-enable mechanism in the
\$C080-\$C08F range:

**Bank 2 Switches:**

- **\$C080** (R): Read RAM bank 2, write protected
- **\$C081** (R,R): Read ROM, write RAM bank 2 (requires 2 reads)
- **\$C082** (R): Read ROM, write protected
- **\$C083** (R,R): Read/write RAM bank 2 (requires 2 reads)

**Bank 1 Switches:**

- **\$C088** (R): Read RAM bank 1, write protected
- **\$C089** (R,R): Read ROM, write RAM bank 1 (requires 2 reads)
- **\$C08A** (R): Read ROM, write protected
- **\$C08B** (R,R): Read/write RAM bank 1 (requires 2 reads)

**Two-Read Write-Enable:**

Write-enable switches require **two successive reads** to enable
writing:

    LDA $C08B    ; First read - bank 1, read-only
    LDA $C08B    ; Second read - bank 1, read/write enabled
    ; Now can write to $D000-$FFFF

This prevents accidental writes from indexed addressing.

See [ROM Organization and Banking](#rom-organization-and-banking) for
complete language card documentation.

#### IIc ROM Banking

**ROMBANK - IIc ROM Bank Toggle (IIc only):**

- **\$C028** (W): Toggle between ROM banks

On IIc systems with 32KB ROM, any write to \$C028 toggles between the
two 16KB ROM banks. Value written doesn’t matter.

**Usage:**

    STA $C028    ; Switch to other ROM bank
    ; Now executing from alternate bank
    STA $C028    ; Switch back

See [ROM Organization and Banking](#rom-organization-and-banking) for
cross-bank calling mechanisms.

#### Status Soft Switches

**Read-Only Status Registers:**

| Address | Status    | Bit 7 Meaning                        |
|---------|-----------|--------------------------------------|
| \$C010  | KBDSTRB   | Clears keyboard strobe when accessed |
| \$C011  | RDBNK2    | 1=language card bank 2, 0=bank 1     |
| \$C012  | RDLCRAM   | 1=reading LC RAM, 0=reading ROM      |
| \$C013  | RDRAMRD   | 1=reading aux RAM, 0=reading main    |
| \$C014  | RDRAMWRT  | 1=writing aux RAM, 0=writing main    |
| \$C015  | RDCXROM   | 1=internal ROM, 0=slot ROM (IIe)     |
| \$C016  | RDALTZP   | 1=aux zero page, 0=main zero page    |
| \$C017  | RDC3ROM   | 1=internal \$C300, 0=slot 3 ROM      |
| \$C018  | RD80STORE | 1=80STORE on, 0=off                  |
| \$C019  | RDVBL     | 1=vertical blank active              |
| \$C01A  | RDTEXT    | 1=text mode, 0=graphics              |
| \$C01B  | RDMIXED   | 1=mixed mode, 0=full screen          |
| \$C01C  | RDPAGE2   | 1=page 2, 0=page 1                   |
| \$C01D  | RDHIRES   | 1=hi-res, 0=lo-res                   |
| \$C01E  | RDALTCH   | 1=alt character set (IIe)            |
| \$C01F  | RD80VID   | 1=80-column mode (IIe/IIc)           |

#### I/O and Soft Switches Implementation Notes

**For Clean-Room ROM Implementation:**

1.  **Use Soft Switches Appropriately:**
    - Access soft switches at documented addresses for target model
    - Follow proper access sequences (e.g., two reads for language card
      write-enable)
    - Read status switches to determine current hardware state
2.  **Initialize Switches on Reset:**
    - Set known default states during firmware initialization
    - TEXT mode, page 1, 40-column
    - Main RAM, main zero page
    - ROM enabled (language card)
3.  **Preserve/Restore Switch State:**
    - Save memory configuration state in interrupt handlers
    - Restore configuration before returning from interrupts
    - Preserve state across firmware calls when required
4.  **Handle Model Differences:**
    - IIc: Some switches have no effect (always uses internal ROM)
    - II/II+: No auxiliary memory or 80-column switches available
    - Detect hardware capabilities and adapt firmware behavior

**Note:** Soft switches are hardware features provided by the Apple II
system. ROM firmware uses these switches but does not implement them.
Hardware or emulator implementation is responsible for:

- Responding to soft switch reads/writes
- Implementing the actual hardware state changes
- Providing correct status register values

**For Software Compatibility:**

1.  **Use Documented Addresses:**
    - Don’t use undocumented soft switches
    - Check status switches before assuming state
    - Test for hardware presence before using features
2.  **Preserve State When Needed:**
    - Save language card state before modifying
    - Save RAM bank selection in interrupt handlers
    - Restore state before returning
3.  **Handle Missing Features:**
    - Test for auxiliary memory before using
    - Check for 80-column hardware
    - Gracefully degrade if features absent

#### See Also

- **[Display System](#display-system)** - Display modes and soft switch
  combinations
- **[Memory System](#memory-system)** - Memory organization
- **[Auxiliary RAM and Memory Soft
  Switches](#auxiliary-ram-and-memory-soft-switches)** - Extended memory
  details
- **[ROM Organization and Banking](#rom-organization-and-banking)** -
  Language card and ROM banking
- **[Hardware Variants and
  Identification](#hardware-variants-and-identification)** -
  Model-specific features

### ROM Organization and Banking

#### Overview

Apple II family ROMs are organized differently depending on the model,
with varying sizes, banking mechanisms, and memory layouts.
Understanding ROM organization is essential for implementing compatible
firmware and for software that needs to work across different Apple II
variants.

This section documents ROM memory organization, banking mechanisms, and
execution models for 8-bit Apple II systems.

#### ROM Memory Map by Model

**Apple II and II+ (8KB ROM):**

- **\$D000-\$FFFF**: 12KB address space
  - \$D000-\$F7FF: Integer BASIC ROM (II) or Applesoft BASIC ROM (II+)
  - \$F800-\$FFFF: Monitor ROM (2KB)
- ROM is read-only, occupies upper 12KB of 64KB address space
- Language card (when installed) can shadow this area with RAM

**Apple IIe (16KB ROM):**

- **\$C100-\$C7FF**: Slot peripheral ROM area (can be switched to
  internal ROM)
- **\$C800-\$CFFF**: Internal ROM (\$C800-\$CFFF, 2KB)
- **\$D000-\$FFFF**: Main ROM bank (12KB)
  - \$D000-\$F7FF: Applesoft BASIC
  - \$F800-\$FFFF: Monitor and system routines
- Additional internal ROM overlays available via soft switches

**Apple IIc (16KB or 32KB ROM):**

- **16KB systems:**
  - \$C100-\$CFFF: Internal peripheral ROM (3.75KB)
  - \$D000-\$FFFF: Main ROM (12KB)
- **32KB systems:**
  - Two 16KB banks, selected via \$C028 soft switch
  - Each bank organized as above
  - Cross-bank calling via jump tables at \$C780-\$C7FF

#### Language Card ROM (Apple II+ and IIe)

The language card is an expansion card that provides 16KB of RAM in the
\$D000-\$FFFF address space, allowing:

1.  Loading alternate programming languages (Pascal, FORTRAN, etc.) into
    RAM
2.  Executing code from RAM instead of ROM
3.  Bank-switching between two 4KB RAM banks at \$D000-\$DFFF

**Memory Organization:**

- **\$D000-\$DFFF**: Bank 1 or Bank 2 (4KB, selectable)
- **\$E000-\$FFFF**: Common area (12KB, shared between both banks)

**Soft Switches (\$C080-\$C08F):**

The language card uses soft switches in the \$C080-\$C08F range with a
two-read write-enable mechanism:

| Address | Function                                        |
|---------|-------------------------------------------------|
| \$C080  | Read RAM bank 2, write protected                |
| \$C081  | Read ROM, write RAM bank 2 (requires two reads) |
| \$C082  | Read ROM, write protected                       |
| \$C083  | Read/write RAM bank 2 (requires two reads)      |
| \$C088  | Read RAM bank 1, write protected                |
| \$C089  | Read ROM, write RAM bank 1 (requires two reads) |
| \$C08A  | Read ROM, write protected                       |
| \$C08B  | Read/write RAM bank 1 (requires two reads)      |

**Two-Read Write-Enable Mechanism:**

Write enable switches (\$C081, \$C083, \$C089, \$C08B) require **two
successive reads** to the same address to enable writing. This prevents
accidental writes from indexed addressing that might touch these
locations once.

Example of enabling bank 1 for reading and writing:

    LDA $C08B    ; First read
    LDA $C08B    ; Second read - now RAM is readable and writable
    ; Can now read from and write to $D000-$FFFF (bank 1)

**Status Soft Switches:**

- **\$C011**: Read BANK2 status; bit 7 = 1 if bank 2, 0 if bank 1
- **\$C012**: Read LCRAMRD status; bit 7 = 1 if reading RAM, 0 if ROM

**Default State:**

- After reset: Reading from ROM, writes disabled
- Bank selection: Undefined until explicitly set

#### IIc ROM Banking (\$C028)

The Apple IIc with 32KB ROM uses a simple bank-switching mechanism
controlled by \$C028 (ROMBANK soft switch).

**Bank Organization:**

- **Bank 0**: Primary 16KB ROM
- **Bank 1**: Secondary 16KB ROM
- Both banks organized identically (\$C100-\$CFFF peripheral ROM,
  \$D000-\$FFFF main ROM)

**ROMBANK Soft Switch (\$C028):**

- **Any write** to \$C028 toggles between ROM banks
- No specific value required; the act of writing toggles the bank
- No read status available; software must track current bank

**Cross-Bank Calling:**

The IIc ROM provides jump table routines at \$C780-\$C7FF to facilitate
cross-bank calls:

| Address | Function | Description                               |
|---------|----------|-------------------------------------------|
| \$C780  | SWRTI    | RTI to other bank (switch bank, then RTI) |
| \$C784  | SWRTS    | RTS to other bank (switch bank, then RTS) |
| \$C788+ | Various  | Other cross-bank entry points             |

**Example Cross-Bank Call:**

Routine in Bank 0 calling routine in Bank 1:

    ; In Bank 0:
    JSR ROUTINE_IN_BANK1_ENTRY
    ; Control returns here in Bank 0

    ROUTINE_IN_BANK1_ENTRY:
        STA $C028           ; Switch to Bank 1
        JSR ACTUAL_ROUTINE  ; Call routine in Bank 1
        STA $C028           ; Switch back to Bank 0
        RTS                 ; Return to caller

Using the jump table (preferred method):

    ; In Bank 0:
    JSR $C784           ; SWRTS - will switch and return automatically
        .WORD TARGET    ; Address in Bank 1 to call
    ; Returns here in Bank 0

**Reset Behavior:**

- Default bank on reset: Bank 0 (primary)
- Software must explicitly switch to Bank 1 when needed

#### ROM Execution Considerations

**Code Location Constraints:**

1.  **Interrupt Vectors (\$FFFA-\$FFFF):**
    - Must be present in all ROM banks or accessible via common
      mechanism
    - IIc: Both banks provide identical vectors
    - IIe: Single ROM, no banking issues
2.  **Reset Vector (\$FFFC-\$FFFD):**
    - Must point to valid reset code in default ROM bank
    - Execution begins here after power-up or RESET
3.  **Cross-Bank Dependencies:**
    - Code calling routines in other banks must handle banking
    - Use jump tables or explicit bank switching
    - Preserve bank state if required by caller

**Stack Considerations:**

When executing from language card RAM or banked ROM:

- Stack is always in main RAM (\$0100-\$01FF)
- JSR/RTS instructions work normally across ROM/RAM boundaries
- Bank switches during interrupt service routines must preserve state

**Interrupt Handling:**

Interrupts can occur during any bank configuration:

- Save current bank state (language card or ROM bank)
- Switch to known state for interrupt handler
- Restore bank state before RTI

#### Implementation Guidelines

**For Clean-Room ROM Implementation:**

1.  **Use Banking Features:**
    - Language card systems: Access \$C080-\$C08F to control RAM banking
    - IIc 32KB ROM: Use \$C028 to toggle ROM banks
    - Follow documented access sequences for language card write-enable
2.  **Organize Code Appropriately:**
    - Place interrupt vectors in all banks (if banked)
    - Ensure reset code accessible from default bank
    - Provide cross-bank calling mechanism if using multiple banks
3.  **Document Bank Usage:**
    - Which features are in which bank
    - Cross-bank dependencies
    - Entry points for bank-switched routines
4.  **Handle Edge Cases:**
    - What happens if language card not present
    - Default bank selection on reset
    - Interrupt behavior during bank switching

**Note:** ROM banking and language card features are provided by
hardware. The ROM firmware uses these features but does not implement
them. Hardware or emulator implementation is responsible for:

- Responding to banking soft switch reads/writes
- Managing the actual bank switching logic
- Providing RAM overlay capabilities (language card)

**For Software Compatibility:**

1.  **Detect Banking Capabilities:**
    - Test for language card presence (II/II+)
    - Identify ROM size from hardware detection
    - Don’t assume banking available
2.  **Preserve Bank State:**
    - Save language card/ROM bank state before modifying
    - Restore state before returning to caller
    - Particularly important for interrupt handlers
3.  **Use Documented Entry Points:**
    - Use cross-bank jump tables when available
    - Don’t rely on undocumented banking behavior
    - Test on multiple ROM versions

#### ROM Banking State Bits

During interrupt handling, the complete memory configuration state
(including ROM banking) is encoded for preservation. See **[Memory State
Encoding](#memory-state-encoding)** in the Interrupt Handling section
for the complete 8-bit encoding table.

**ROM banking state bits:**

- Bit D3: Language card RAM enabled
- Bit D2: Language card bank 1 selected
- Bit D1: Language card bank 2 selected
- Bit D0: Alternate ROM bank selected (IIc)

#### See Also

- **[Auxiliary RAM and Memory Soft
  Switches](#auxiliary-ram-and-memory-soft-switches)** - RAM banking and
  soft switches
- **[Memory System](#memory-system)** - Complete memory architecture
- **[Interrupt Handling](#interrupt-handling)** - Interrupt context
  preservation
- **[Hardware Variants and
  Identification](#hardware-variants-and-identification)** -
  Model-specific capabilities

## System Boot and Initialization

### Overview

The Apple II boot process encompasses hardware reset, firmware
initialization, memory configuration, and optional peripheral device
boot loading. This section documents the complete boot sequence and
initialization requirements for implementing compatible ROM firmware.

### Boot Sequence Overview

The complete boot process follows this sequence:

1.  **Hardware Reset** - Power-on or manual RESET button pressed
2.  **6502 Reset Vector** - Processor loads reset vector from
    \$FFFC-\$FFFD
3.  **Firmware Reset Routine** - Executes system initialization code at
    vector address
4.  **Memory Initialization** - Clear screen, detect RAM size,
    initialize variables
5.  **Warm Start Detection** - Check if valid warm start signature
    present (IIe+)
6.  **Peripheral Slot Scan** - Check slots 1-7 for boot ROMs (II/II+/IIe
    only)
7.  **Peripheral Boot** - Execute first boot ROM found, if any
8.  **Default Entry** - Enter Monitor or BASIC if no boot device found

### Hardware Reset

**Reset Trigger:**

- Power-on (cold start)
- RESET button pressed (warm start if signature valid)
- Watchdog timer (if present)
- Software-initiated reset

**Processor Behavior:**

- 6502 reads reset vector from \$FFFC-\$FFFD
- Jumps to address specified in vector
- Stack pointer undefined (firmware must initialize)
- Decimal mode undefined (firmware must clear)
- Interrupt disable flag set

### Firmware Reset Routine

The firmware reset entry point (typically \$FA62 on IIe/IIc) performs
essential initialization:

**Required Initialization Steps:**

1.  **Initialize Processor State:**
    - Clear decimal mode (CLD instruction)
    - Set stack pointer to \$FF (LDX \#\$FF, TXS)
    - Disable interrupts initially (SEI)
2.  **Configure Memory:**
    - Switch in main ROM (if banked)
    - Set main RAM for reading/writing (IIe/IIc)
    - Initialize language card to ROM mode (if present)
3.  **Initialize I/O:**
    - Set text mode, page 1 (display switches)
    - Clear keyboard strobe
    - Initialize speaker state
4.  **Test for Warm Start:**
    - Check PWREDUP magic byte (IIe+)
    - If valid, jump to SOFTEV (skip full initialization)
    - If invalid, continue with cold start
5.  **Clear Screen Memory:**
    - Fill \$0400-\$0BFF with spaces (\$A0)
    - Or use efficient clearing routine
    - Preserve zero page and stack
6.  **Detect RAM Configuration:**
    - Test for language card (II/II+)
    - Test for auxiliary memory (IIe)
    - Set HIMEM appropriately
7.  **Initialize System Variables:**
    - Set input buffer pointers
    - Initialize monitor variables
    - Set default window bounds
8.  **Establish Interrupt Vectors:**
    - Set BRKV (break handler)
    - Set SOFTEV (warm start entry)
    - Set IRQLOC (IRQ handler)
9.  **Scan for Peripheral Boot:**
    - Check slots for boot signature
    - Jump to first boot ROM found
    - Fall through to Monitor/BASIC if none

### Memory Initialization

**Cold Start Memory Clearing:**

The firmware clears screen memory and initializes system variables:

1.  Clear display memory from \$BFXX down to \$0200
2.  Fill with space characters (\$A0 = ASCII space with high bit set)
3.  Avoid overwriting zero page (\$00-\$FF) and stack (\$0100-\$01FF)
4.  Initialize soft switches to default state (IIe/IIc)
5.  Set system variables to known values

**Implementation approach:**

- Start from high memory, work down to low memory
- Use indexed addressing for efficiency
- Set 80-column switches if appropriate (IIc)
- Clear auxiliary memory if present (IIe/IIc with 128K)

### RAM Size Detection

**Apple II and II+:**

Early systems perform memory test to determine RAM size:

**Detection Algorithm:**

1.  Write test pattern to memory location
2.  Read back and verify pattern matches
3.  Write complementary pattern
4.  Read back and verify second pattern
5.  If both patterns verify, RAM exists at that address
6.  Continue testing upward until no RAM found
7.  Set HIMEM to highest working address

**Test Patterns:**

- Pattern 1: Alternating bits (e.g., \$55 = 01010101)
- Pattern 2: Inverted pattern (e.g., \$AA = 10101010)
- Tests that RAM cells can hold both 0 and 1 values

**Apple IIe and IIc:**

Later systems have fixed memory configurations:

- IIe: 64K or 128K (detect auxiliary memory card)
- IIc: Always 128K (no detection needed)
- No runtime RAM size test required

**Auxiliary Memory Detection (IIe):**

Test for auxiliary memory presence:

1.  Switch to auxiliary RAM (\$C003/\$C005)
2.  Write test value to \$0800
3.  Switch to main RAM (\$C002/\$C004)
4.  Write different value to \$0800
5.  Switch to auxiliary, read back
6.  If original value present, auxiliary RAM exists
7.  Use sparse memory test (\$0800 vs \$0C00) for reliability

**Language Card Detection (II/II+/IIe):**

Test for language card presence:

1.  Enable LC bank 1 (\$C08B, \$C08B - two reads)
2.  Save byte from \$D000
3.  Write test pattern to \$D000
4.  Read back and compare
5.  Write complementary pattern
6.  Read back and compare
7.  If both match, language card present
8.  Restore original byte

### Warm Start Detection

To avoid unnecessary re-initialization on RESET, firmware checks for
warm start signature.

**Warm Start Mechanism:**

Magic bytes at fixed locations indicate valid warm start:

- **PWREDUP** (\$03F4): Power-up detection byte
- **SOFTEV** (\$03F2-\$03F3): Warm start entry point vector

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

After firmware initialization, control may transfer to peripheral device
boot ROM.

**Boot ROM Location:**

- **Address:** \$Cn00 (n = slot number, 1-7)
- **Size:** 256 bytes (\$Cn00-\$CnFF per slot)
- **Example:** Disk II controller in slot 6 = \$C600-\$C6FF

**Slot Scan Algorithm:**

Firmware scans slots sequentially:

    FOR slot = 7 DOWN TO 1
        Check $Cn00 for boot signature
        IF valid signature THEN
            JSR $Cn00
            (Boot ROM executes)
        END IF
    NEXT slot

**Boot ROM Requirements:**

- Must be slot-independent (don’t assume specific slot)
- Should determine slot via return address examination
- Can use IORTS routine (\$FF58) to get slot number
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

| Address       | Vector  | Purpose                 | Default       | Modifiable    |
|---------------|---------|-------------------------|---------------|---------------|
| \$03F0-\$03F1 | BRKV    | BRK instruction handler | Monitor       | Yes           |
| \$03F2-\$03F3 | SOFTEV  | Warm start entry        | Reset/Monitor | Yes           |
| \$03F4        | PWREDUP | Power-up detection      | Magic byte    | Firmware sets |
| \$03FE-\$03FF | IRQLOC  | IRQ handler vector      | Firmware IRQ  | Yes           |

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

1.  **Provide Reset Vector:**
    - Place reset routine address at \$FFFC-\$FFFD
    - Ensure routine accessible on power-up
2.  **Initialize All Subsystems:**
    - Processor state (stack, flags)
    - Memory configuration
    - I/O and soft switches
    - System variables
3.  **Detect Memory Configuration:**
    - Test for RAM size (II/II+ with variable RAM)
    - Detect auxiliary memory (IIe)
    - Detect language card
    - Set HIMEM/LOMEM appropriately
4.  **Support Warm Start:**
    - Implement PWREDUP/SOFTEV check
    - Preserve programs on RESET
    - Set magic bytes after initialization
5.  **Enable Peripheral Boot:**
    - Scan slots for boot ROMs
    - Execute first valid boot ROM
    - Provide IORTS for slot detection
6.  **Establish Vectors:**
    - Set default interrupt handlers
    - Allow software modification
    - Document vector usage

**Memory Requirements:**

- Zero page: ~40 bytes for system variables
- Stack: Full 256-byte page (\$0100-\$01FF)
- Input buffer: 128 bytes (\$0200-\$027F)
- System vectors: ~32 bytes (\$03E0-\$03FF)

**Feature Scope Notes:**

- Full memory test optional (can assume fixed size)
- Auxiliary memory support optional (not in II/II+)
- Peripheral boot scanning optional (can boot from known slot)
- Warm start support recommended but not required for basic
  compatibility

### See Also

- **[Reset (\$FA62)](#reset-fa62)** - Firmware reset entry point
- **[PwrUp](#pwrup-faa6)** - Power-up initialization routine
- **[Hardware Variants and
  Identification](#hardware-variants-and-identification)** -
  Model-specific boot behavior
- **[Memory System](#memory-system)** - Memory organization
- **[ROM Organization and Banking](#rom-organization-and-banking)** -
  ROM structure
- **[Peripheral Controller ROMs](#peripheral-controller-roms)** - Boot
  ROM protocols

## Interrupt Handling

### Overview

The Apple II firmware provides standardized interrupt handling for BRK,
IRQ, and NMI interrupts. All 8-bit Apple II systems use vectored
interrupts that software can customize by modifying system vectors in
low memory.

This section documents interrupt mechanisms, memory state preservation
requirements, and proper handling with bank-switched memory
configurations.

### Interrupt Vectors

**System Interrupt Vectors:**

| Address | Vector | Interrupt Type | Default Handler | Software Modifiable |
|----|----|----|----|----|
| \$03F0-\$03F1 | BRKV | BRK instruction | Monitor BRK handler | Yes |
| \$03F2-\$03F3 | SOFTEV | Warm start/reset | Reset/Monitor entry | Yes |
| \$03FE-\$03FF | IRQLOC | IRQ hardware interrupt | Firmware IRQ handler | Yes |
| \$FFFE-\$FFFF | (ROM) | IRQ/BRK vector | Firmware dispatcher | No (ROM) |
| \$FFFA-\$FFFB | (ROM) | NMI vector | Firmware NMI handler | No (ROM) |

**Vector Usage:**

ROM interrupt vectors (\$FFFA-\$FFFF) point to firmware entry points.
These dispatch through RAM vectors (\$03F0-\$03FF) that software can
modify:

    ; ROM IRQ/BRK handler (fixed)
    IRQBRK_ENTRY:
        ; Determine if IRQ or BRK
        ; Jump through RAM vector
        JMP (BRKV)  ; if BRK
        ; or
        JMP (IRQLOC) ; if IRQ

This allows software to hook interrupts by changing RAM vectors without
modifying ROM.

### BRK Instruction Handling

**BRK Behavior:**

When BRK instruction executes:

1.  Push PC+2 to stack (return address)
2.  Push processor status with B flag set
3.  Set interrupt disable flag
4.  Jump through \$FFFE-\$FFFF vector

**Firmware BRK Handler:**

Default BRKV points to Monitor break handler:

1.  Save all registers (A, X, Y, P, S)
2.  Display register contents
3.  Enter Monitor command mode
4.  Allow user to examine/modify memory
5.  Can resume with ‘G’ command

**Custom BRK Handlers:**

Software can install custom debuggers or error handlers:

    LDA #<MY_HANDLER
    STA BRKV
    LDA #>MY_HANDLER
    STA BRKV+1

Handler must preserve system state or provide own exit mechanism.

### IRQ Interrupt Handling

**IRQ Sources:**

Hardware interrupt requests can come from:

- Peripheral cards in slots
- Expansion hardware
- Timer circuits (if present)
- External interrupt signals

**Firmware IRQ Dispatcher:**

1.  Determine interrupt source (peripheral polling)
2.  Jump through IRQLOC vector
3.  Default handler returns immediately (RTI)

**Custom IRQ Handlers:**

Software provides IRQ handling by setting IRQLOC:

    LDA #<IRQ_HANDLER
    STA IRQLOC
    LDA #>IRQ_HANDLER
    STA IRQLOC+1

**IRQ Handler Requirements:**

IRQ handlers must:

- Preserve all registers (push A,X,Y)
- Identify and service interrupt source
- Clear interrupt condition before RTI
- Restore all registers (pop Y,X,A)
- Exit with RTI instruction

**Simple IRQ Handler Example:**

    IRQ_HANDLER:
        PHA          ; Save A
        TXA
        PHA          ; Save X
        TYA
        PHA          ; Save Y
        
        ; Service interrupt
        ; (check source, handle, clear)
        
        PLA          ; Restore Y
        TAY
        PLA          ; Restore X
        TAX
        PLA          ; Restore A
        RTI          ; Return from interrupt

### NMI Interrupt Handling

**NMI Characteristics:**

Non-maskable interrupt (NMI):

- Cannot be disabled via interrupt disable flag
- Has highest priority
- Typically used for critical system events

**NMI Sources:**

Rare on standard Apple II systems:

- Power failure detection (if hardware present)
- Watchdog timers
- Hardware error conditions
- Some expansion cards

**Firmware NMI Handler:**

Default NMI handler typically:

- Saves system state
- Attempts graceful recovery or shutdown
- May enter debugger or halt system

### Interrupt Handling with Memory Banking

When using bank-switched memory (language card, auxiliary RAM, ROM
banking), interrupt handlers must preserve memory configuration.

**Challenge:**

Interrupt can occur with any memory configuration active:

- Auxiliary zero page/stack selected
- Language card RAM active
- Alternate ROM bank selected
- Auxiliary RAM mapped for read/write

Handler must:

1.  Save current memory state
2.  Switch to known configuration
3.  Execute interrupt handler
4.  Restore memory state before RTI

### Memory State Encoding

Firmware uses packed byte to save complete memory configuration:

| Bit | Meaning                                                |
|-----|--------------------------------------------------------|
| D7  | 1 if using auxiliary zero page/stack (ALTZP on)        |
| D6  | 1 if 80STORE enabled and PAGE2 on                      |
| D5  | 1 if reading from auxiliary RAM (RAMRD)                |
| D4  | 1 if writing to auxiliary RAM (RAMWRT)                 |
| D3  | 1 if language card RAM enabled for reading             |
| D2  | Language card bank selection (implementation-specific) |
| D1  | Language card bank selection (implementation-specific) |
| D0  | 1 if alternate ROM bank selected (IIc)                 |

**Purpose:**

Single-byte encoding minimizes stack usage and allows quick save/restore
during interrupt handling.

### Interrupt Entry with Auxiliary Memory

**Complete Interrupt Entry Sequence:**

When interrupt occurs with auxiliary memory configuration active:

1.  **Push Current PC and Status** (hardware automatic)

2.  **Read Current Memory State:**

    - Check all soft switch status registers
    - Encode into single state byte
    - Push state byte to stack

3.  **Switch to Main Memory:**

    - STA \$C008 ; main zero page/stack
    - STA \$C002 ; read main RAM
    - STA \$C004 ; write main RAM

4.  **Save Stack Pointer:**

    - If was using auxiliary stack, save SP to \$0100 (aux)
    - Switch to main stack

5.  **Execute Handler:**

    - All interrupt handler code uses main memory
    - Can safely modify main RAM
    - Can access peripherals normally

6.  **Restore Memory State:**

    - Pop state byte from stack
    - Decode bits and restore all soft switches
    - Restore stack pointer if needed

7.  **Return from Interrupt:**

    - RTI instruction
    - Hardware restores PC and status

**Why Main Memory for Handlers:**

Using main memory for interrupt handling:

- Avoids confusion about which bank contains handler
- Ensures stack operations access correct memory
- Prevents recursive bank switching issues
- Matches system initialization defaults

### Stack Pointer Preservation

**Problem:**

When ALTZP is on, zero page and stack are in auxiliary memory. Interrupt
switches to main zero page/stack, but we need to restore auxiliary stack
pointer on exit.

**Solution:**

Firmware uses stack pointer save locations:

- **\$0100** (aux RAM): Main stack pointer when using aux stack
- **\$0101** (aux RAM): Aux stack pointer when using main stack

**Procedure:**

Before switching stacks in interrupt:

    ; Currently using auxiliary stack
    STA $C005    ; Write to auxiliary RAM
    TSX          ; Get current stack pointer
    STX $0101    ; Save in aux $0101
    STA $C004    ; Write to main RAM
    LDX #$FF     ; Restore main SP
    TXS

On interrupt exit:

    STA $C005    ; Write to auxiliary RAM
    LDX $0101    ; Load saved aux SP
    TXS          ; Restore auxiliary stack
    STA $C004    ; Write to main RAM
    RTI

### Language Card State Preservation

**Language Card Complexity:**

Language card state requires two-read write-enable sequence. Simply
saving soft switch status isn’t enough—must recreate exact access
pattern.

**State Elements:**

- Which bank selected (1 or 2)
- RAM read enabled vs ROM
- RAM write enabled vs write-protected

**Restoration:**

Interrupt handler must:

1.  Save bank selection, read enable, write enable state
2.  Restore by accessing appropriate soft switches
3.  For write-enable, perform two reads if needed

**Example State Save:**

    ; Read LC state
    LDA $C011    ; RDBANK2 status
    ; bit 7 = 1 if bank 2
    LDA $C012    ; RDLCRAM status  
    ; bit 7 = 1 if reading RAM
    ; (write enable requires tracking or assumption)

**Example State Restore:**

    ; Restore bank 2, read/write
    LDA $C08B    ; First read
    LDA $C08B    ; Second read - enables write

### ROM Banking State Preservation (IIc)

**IIc ROM Bank Toggle:**

IIc systems with 32KB ROM use \$C028 to toggle banks. State preservation
requires:

1.  **Determine Current Bank:**
    - Test known addresses that differ between banks
    - Or maintain software bank tracking
2.  **Switch to Handler Bank:**
    - Ensure interrupt handler in current bank
    - Or switch to known bank containing handler
3.  **Restore Original Bank:**
    - Toggle back if changed
    - Maintain bank count (even=same, odd=opposite)

**Handler Bank Location:**

Interrupt handlers should be in:

- Common ROM area (present in both banks), or
- Both ROM banks at same address, or
- Bank 1 (default boot bank)

### Interrupt Handling Implementation Requirements

**For Clean-Room ROM Implementation:**

1.  **Establish ROM Vectors:**
    - Place IRQ/BRK handler address at \$FFFE-\$FFFF
    - Place NMI handler address at \$FFFA-\$FFFB
    - Point to firmware dispatchers
2.  **Initialize RAM Vectors:**
    - Set BRKV to Monitor break handler
    - Set IRQLOC to default IRQ return (RTI)
    - Set SOFTEV to warm start entry
    - Allow software modification
3.  **Implement Dispatchers:**
    - Distinguish BRK from IRQ (check B flag)
    - Jump through appropriate RAM vector
    - Save/restore memory state if banking present
4.  **Handle Memory Banking:**
    - Save memory configuration in interrupt entry
    - Switch to main memory for handler execution
    - Restore configuration before RTI
    - Preserve stack pointers correctly
5.  **Support Custom Handlers:**
    - Document vector usage
    - Provide stable entry/exit protocol
    - Preserve registers and state

**For Software Using Interrupts:**

1.  **Install Handlers Properly:**
    - Set RAM vectors, not ROM vectors
    - Provide complete handler (entry to RTI)
    - Test before enabling interrupts
2.  **Preserve All State:**
    - Save all registers (A, X, Y)
    - Save memory configuration if using banking
    - Restore everything before RTI
3.  **Clear Interrupt Source:**
    - Service interrupt condition
    - Clear hardware interrupt flag
    - Prevent infinite interrupt loop
4.  **Minimize Handler Time:**
    - Interrupts block other interrupts
    - Defer complex work to main program
    - Use flags to signal main code

### See Also

- **[BRK (\$FE75)](#brk-fe75)** - BRK instruction handler entry point
- **[System Vectors](#system-boot-and-initialization)** - Interrupt
  vector initialization
- **[Auxiliary RAM and Memory Soft
  Switches](#auxiliary-ram-and-memory-soft-switches)** - Memory state
  encoding
- **[ROM Organization and Banking](#rom-organization-and-banking)** -
  Language card and ROM banking state

## Monitor User Interface and Command Dispatcher

### Overview

The Apple II ROM includes a system monitor (accessed via `CALL -151` in
Applesoft BASIC or by entering the Monitor from the cold start
sequence). The Monitor provides a command-line interface for inspecting
and manipulating memory, running code, and performing system
diagnostics.

The Monitor command system uses a pair of lookup tables at fixed ROM
addresses to dispatch commands:

- **ASCII Command Table (CHRTBL)** at `$FFCC` — Contains the ASCII
  character codes for each supported command
- **Routine Offset Table (SUBTBL)** at `$FFE3` — Contains the 16-bit
  offsets to the routine that handles each command

### Monitor Entry Points

The Monitor is entered through the following entry points:

#### [Mon](#mon-ff65) (\$FF65)

Initialization routine that prepares the processor to enter the Monitor.
Clears the decimal mode flag, activates the speaker, and transfers
control to [MonZ](#monz-ff69).

#### [MonZ](#monz-ff69) (\$FF69)

Primary entry point for the System Monitor. Displays the prompt (`*`),
reads a command line from the user, and passes control to the Monitor’s
command-line parser.

#### [MonZ4](#monz4-ff70) (\$FF70)

Alternative entry point that bypasses the initial prompt display and
mode clearing, going directly to the command parser.

### Command Structure

The Monitor command system works as follows:

1.  **User Input:** The user types a command character at the Monitor
    prompt (`*`)
2.  **Command Lookup:** The [MonZ](#monz-ff69) routine reads the input
    via [GetLnZ](#getlnz-fd67)
3.  **Table Scan:** The command character is searched in the ASCII
    Command Table at `$FFCC`
4.  **Offset Retrieval:** If found, the matching index is used to look
    up the routine offset in the Offset Table at `$FFE3`
5.  **Routine Execution:** The offset is used to calculate the routine
    address, and control is transferred to that routine

### Lookup Tables (Fixed Addresses)

#### ASCII Command Table (\$FFCC)

This table contains the ASCII codes for each supported Monitor command.
Typical commands include:

- `G` — Go (execute code at specified address)
- `L` — List (display hex dump of memory)
- `M` — Modify memory
- `R` — Run (resume execution)
- `S` — Substitute (replace memory contents)
- `X` — Examine registers
- `A` — Assemble (6502 assembly input)
- Others as implemented by the ROM variant

**Format:** Each entry is a single byte containing the ASCII code of the
command character.

#### Routine Offset Table (\$FFE3)

This table contains 16-bit offsets corresponding to the routine that
handles each command. The index in this table matches the index found in
the ASCII Command Table.

**Format:** Each entry is a 16-bit offset (low byte, then high byte).

**Fixed Location:** This table **must** remain at `$FFE3` for
compatibility with external diagnostic tools and software that may
reference this address directly.

### Monitor Commands (Examples)

The following are typical commands found in Apple II ROMs (exact set
varies by variant):

| Command | ASCII | Function                                            |
|---------|-------|-----------------------------------------------------|
| G       | \$47  | **Go** — Execute code at specified address          |
| L       | \$4C  | **List** — Display hex dump of memory range         |
| M       | \$4D  | **Modify** — Change memory contents                 |
| R       | \$52  | **Run** — Resume execution from [PCL/PCH](#pcl-pch) |
| S       | \$53  | **Substitute** — Replace memory values              |
| X       | \$58  | **Examine** — Display saved CPU registers           |
| A       | \$41  | **Assemble** — Enter 6502 assembly instructions     |
| T       | \$54  | **Trace** — Execute single instruction with display |
| .       | \$2E  | **Full-stop** — Return to prompt (stop tracing)     |

### Escape Sequences and Control Characters

The Monitor supports escape sequences for advanced display and input
control. These are sequences that begin with the  ␛⃣  character (ASCII
\$1B) followed by a command character.  ⌃⃣  indicates a control
character.

### Table: Escape sequences

| Escape Sequence | Function |
|:---|:---|
| ␛⃣ , @⃣ | Clears the current window, homes the cursor (moves it to the upper-left corner of the screen), and exits escape mode. |
| ␛⃣ , A⃣ or ␛⃣ , a⃣ | Moves the cursor right one character position and exits escape mode. |
| ␛⃣ , B⃣ or ␛⃣ , b⃣ | Moves the cursor left one character position and exits escape mode. |
| ␛⃣ , C⃣ or ␛⃣ , c⃣ | Moves the cursor down one line and exits escape mode. |
| ␛⃣ , D⃣ or ␛⃣ , d⃣ | Moves the cursor up one line and exits escape mode. |
| ␛⃣ , E⃣ or ␛⃣ , e⃣ | Clears the current line from the cursor position to the end, then exits escape mode. |
| ␛⃣ , F⃣ or ␛⃣ , f⃣ | Clears the current window from the cursor position to the bottom, then exits escape mode. |
| ␛⃣ , I⃣ or ␛⃣ , i⃣ or ␛⃣ , ↑⃣ | Moves the cursor up one line and remains in escape mode. |
| ␛⃣ , J⃣ or ␛⃣ , j⃣ or ␛⃣ , ←⃣ | Moves the cursor left one character position and remains in escape mode. |
| ␛⃣ , K⃣ or ␛⃣ , k⃣ or ␛⃣ , →⃣ | Moves the cursor right one character position and remains in escape mode. |
| ␛⃣ , M⃣ or ␛⃣ , m⃣ or ␛⃣ , ↓⃣ | Moves the cursor down one line and remains in escape mode. |
| ␛⃣ , 4⃣ | Switches to 40-column text mode, sets the input/output links to `C3KeyIn` and `C3COut1`, restores the normal window size and then exits escape mode. |
| ␛⃣ , 8⃣ | Switches to 80-column text mode, sets the input/output links to `C3KeyIn` and `C3COut1`, restores the normal window size and then exits escape mode. |
| ␛⃣ , ⌃⃣ - D⃣ | Disables control characters, allowing only carriage return, linefeed, bell, and backspace to have an effect when printed. |
| ␛⃣ , ⌃⃣ - E⃣ | Reactivates control characters. |
| ␛⃣ , ⌃⃣ - Q⃣ | Deactivates the enhanced video firmware, sets the input/output links to `KeyIn` and `COut1`, restores the normal window size and then exits escape mode. |

*Note: The commands ␛⃣ 4⃣, ␛⃣ 8⃣, and ␛⃣ ⌃⃣ - Q⃣ only function when enhanced
video firmware is active.*

### Implementation Requirements for Clean-Room ROM

To implement a Monitor-compatible ROM:

1.  **Fixed Table Locations:** The ASCII Command Table MUST be at
    `$FFCC` and the Routine Offset Table MUST be at `$FFE3`. This is
    essential for external diagnostic tools that may have these
    addresses hard-coded.

2.  **Entry Point Availability:** The routines [Mon](#mon-ff65),
    [MonZ](#monz-ff69), and [MonZ4](#monz4-ff70) must be available at
    their documented addresses.

3.  **Command Dispatch Mechanism:** A command dispatcher (typically
    similar to [TOSUB](#tosub-ffbe)) must use the pair of tables to
    route command characters to their handler routines.

4.  **Register Preservation:** The Monitor should preserve CPU registers
    and provide mechanisms to inspect and modify them via the
    appropriate commands (typically the `X` command for examine).

5.  **Memory Interaction:** The Monitor must provide access to all
    addressable memory via commands like `L` (list) and `M` (modify) or
    `S` (substitute).

### Related Routines

- [TOSUB](#tosub-ffbe) — Generic subroutine dispatcher using table
  lookup
- [GetLnZ](#getlnz-fd67) — Reads a line from user input (used by
  Monitor)
- [MonZ4](#monz4-ff70) — Alternative Monitor entry point
- [INPRT](#inprt-fe8d), [OUTPRT](#outprt-fe97) — I/O port configuration
  for Monitor I/O

### Monitor Implementation Notes

- The Monitor is a critical system component and its command structure
  is relied upon by external diagnostic tools.
- The fixed table locations at `$FFCC` and `$FFE3` are essential for ROM
  compatibility.
- Different Apple II variants (II, II+, IIe, IIc) may have different
  sets of commands implemented, but the table structure remains
  consistent.

### See also

- [Mon](#mon-ff65) — Monitor initialization
- [MonZ](#monz-ff69) — Monitor entry point
- [SUBTBL](#subtbl-ffe3) — Routine offset table documentation
- [CHRTBL](#chrtbl-ffcc) — ASCII command table documentation
- [TOSUB](#tosub-ffbe) — Command dispatcher
- [INBUF](#inbuf) — Input buffer

## Summary of Firmware Entry Points

| Routine Name | Address | Function Summary |
|----|----|----|
| [A1PC](#a1pc-fe75) | \$FE75 | Conditionally copy A1L/A1H to PCL/PCH (Internal helper). |
| [Advance](#advance-fbf4) | \$FBF4 | Advances the text cursor’s horizontal position. |
| [AppleII](#appleii-fb60) | \$FB60 | Clears screen and displays machine ID. |
| [BasCalc](#bascalc-fbc1) | \$FBC1 | Calculates 16-bit base address for text display line. |
| [Bell](#bell-ff3a) | \$FF3A | Sends a bell character to standard output. |
| [Bell1](#bell1-fbdd) | \$FBDD | Produces a brief 1 kHz tone through the system speaker with delay. |
| [Bell1_2](#bell1_2-fbe2) | \$FBE2 | Produces a brief 1 kHz tone through the system speaker without delay. |
| [Bell2](#bell2-fbe4) | \$FBE4 | Generates a square-wave tone by toggling the system speaker for a duration. |
| [Break](#break-fa4c) | \$FA4C | Handles processor hardware break event, saves registers, and transfers control to user hook. |
| [BS](#bs-fc10) | \$FC10 | Performs a backspace operation, decrements CH, and moves cursor up if at left edge. |
| [ClrCH](#clrch-fee9) | \$FEE9 | Clear horizontal cursor positions (Internal helper). |
| [ClrEOL](#clreol-fc9c) | \$FC9C | Clears a line of text from the cursor’s current position to the right edge of the window. |
| [ClrEOLZ](#clreolz-fc9e) | \$FC9E | Clears a line of text from a specified column to the right edge of the window. |
| [ClrEOP](#clreop-fc42) | \$FC42 | Clears the text window from the current cursor position to the end of the window. |
| [ClrScr](#clrscr-f832) | \$F832 | Clears the Lo-Res graphics display or fills the text screen with inverse ‘@’. |
| [ClrTop](#clrtop-f836) | \$F836 | Clears the upper 40 lines of the Lo-Res graphics display to black. |
| [COut](#cout-fded) | \$FDED | Primary entry point for standard character output, indirect calls to active output routine. |
| [COut1](#cout1-fdf0) | \$FDF0 | Displays ASCII character at current cursor, advances cursor, handles control characters, applies inverse flag. |
| [COutZ](#coutz-fdf6) | \$FDF6 | Alternative entry point to COutl; identical functionality but does not apply inverse flag at start. |
| [CR](#cr-fc62) | \$FC62 | Executes a carriage return, moving cursor to left edge and then calling LF. |
| [CROut](#crout-fd8e) | \$FD8E | Initiates a carriage return by sending a CR character to standard output. |
| [CROut1](#crout1-fd8b) | \$FD8B | Clear to end of line and send carriage return to standard output,Y,-,Y,FALSE,Screen Output,,clear_to_eol |
| [Dig](#dig-ff8a) | \$FF8A | Converts ASCII hexadecimal digit to 4-bit numerical value. |
| [FD10](#fd10-fd10) | \$FD10 | Indirect jump for standard input, transfers control to routine in KSWL/KSWH. |
| [GBasCalc](#gbascalc-f847) | \$F847 | Calculates 16-bit base address for a specified Lo-Res graphics display row. |
| [GetCur2](#getcur2-ccad) | \$CCAD | Update zero-page horizontal cursor positions (Internal helper). |
| [GetLn](#getln-fd6a) | \$FD6A | Reads a complete line of input from standard input, with editing features. |
| [GetLn0](#getln0-fd6c) | \$FD6C | Display prompt in A register and read a line of text,Y,-,Y,FALSE,Standard Input,Print A + GetLn1, |
| [GetLn1](#getln1-fd6f) | \$FD6F | Alternate entry point to GetLn, reads line without displaying a prompt. |
| [GetLnZ](#getlnz-fd67) | \$FD67 | Sends a carriage return, then transfers control to GetLn. |
| [GetNum](#getnum-ffa7) | \$FFA7 | Scans Monitor’s input buffer for hex digits, converts to numerical values. |
| [Go](#go-feb6) | \$FEB6 | Restores A, X, Y, P registers from saved values and jumps to address in A1L/A1H. |
| [HeadR](#headr-fcc9) | \$FCC9 | Obsolete entry point, simply returns. |
| [HLine](#hline-f819) | \$F819 | Draws a horizontal line of blocks on the Lo-Res graphics display. |
| [Home](#home-fc58) | \$FC58 | Clears the active text window and positions cursor at upper-left corner. |
| [HomeCur](#homecur-cda5) | \$CDA5 | Move cursor to upper left corner of text window (Internal helper). |
| [IDRoutine](#idroutine-fe1f) | \$FE1F | Immediate return from subroutine (Internal helper). |
| [Init](#init-fb2f) | \$FB2F | Initializes text display to show text Page 1 and full-screen text window. |
| [InPort](#inport-fe8b) | \$FE8B | Configures system’s input links to a designated input port. |
| [InsDs1_2](#insds1_2-f88c) | \$F88C | Loads A with an opcode then calls InsDs2 to calculate its length. |
| [InsDs2](#insds2-f88e) | \$F88E | Determines length (minus 1) of 6502 instruction from opcode in A. |
| [InstDsp](#instdsp-f8d0) | \$F8D0 | Disassembles and prints instruction pointed to by PCL/PCH to standard output. |
| [IORTS](#iorts-ff58) | \$FF58 | Contains an RTS instruction, used by peripheral cards for slot identification. |
| [IRQ](#irq-fa40) | \$FA40 | Jumps to interrupt-handling routine in ROM, saves state, checks interrupts, calls user hook. |
| [KbdWait](#kbdwait-fb88) | \$FB88 | Pauses execution until a key is pressed; handles Control-C. |
| [KeyIn](#keyin-fd1b) | \$FD1B | Manages standard keyboard input, displays cursor, waits for keypress, updates RNDL/RNDH. |
| [KeyIn0](#keyin0-fd18) | \$FD18 | Alternate entry point for standard keyboard input, jumps to routine in KSWL/KSWH. |
| [LF](#lf-fc66) | \$FC66 | Executes a line feed, increments CV, and scrolls window up if needed. |
| [List](#list-fe5e) | \$FE5E | Disassembles and displays 20 6502 instructions to standard output. |
| [Mon](#mon-ff65) | \$FF65 | Prepares processor to enter System Monitor, clears decimal flag, activates speaker. |
| [MonZ](#monz-ff69) | \$FF69 | Primary entry point for System Monitor, displays prompt, reads input, clears mode flag. |
| [MonZ4](#monz4-ff70) | \$FF70 | Alternative entry point to System Monitor, bypasses initial prompt and mode clearing. |
| [Move](#move-fe2c) | \$FE2C | Copies a block of memory from source to destination. |
| [NewBrk](#newbrk-fa47) | \$FA47 | Stores A in MACSTAT, pulls Y, X, A from stack, then transfers to Break. |
| [NewVTabZ](#newvtabz-fc88) | \$FC88 | Update OURCV and transfer to VTABZ (Internal helper). |
| [NxtA1](#nxtal-fcba) | \$FCBA | Performs a 16-bit comparison of A1L/A1H with A2L/A2H, then increments A1L/A1H. |
| [NxtA4](#nxta4-fcb4) | \$FCB4 | Increments A4L/A4H, then calls NxtAl for comparison and A1L/A1H increment. |
| [NxtChr](#nxtchr-ffad) | \$FFAD | Inspects input buffer for hex numbers, converts them, handles case. |
| [NxtCol](#nxtcol-f85f) | \$F85F | Modifies current color for Lo-Res graphics plotting by adding 3. |
| [OldBrk](#oldbrk-fa59) | \$FA59 | Prints saved PC and register values, then transfers control to the Monitor. |
| [OldRst](#oldrst-ff59) | \$FF59 | Performs warm restart, initializes text screen, sets I/O hooks, enters Monitor. |
| [OutPort](#outport-fe95) | \$FE95 | Sets output hooks to ROM code for specified port. |
| [PCAdj](#pcadj-f953) | \$F953 | Reads Monitor’s program counter, loads into A/Y, increments based on LENGTH. |
| [Plot](#plot-f800) | \$F800 | Plots a single block of specified color on Lo-Res graphics display. |
| [Plot1](#plot1-f80e) | \$F80E | Plots a single block of specified color on Lo-Res graphics display at current row. |
| [PrA1](#pra1-fd92) | \$FD92 | Sends carriage return, prints A1L/A1H in hex, followed by a hyphen. |
| [PrBl2](#prbl2-f94a) | \$F94A | Prints a number of blank spaces to standard output. |
| [PrBlnk](#prblnk-f948) | \$F948 | Prints three blank spaces to standard output. |
| [PrByte](#prbyte-fdda) | \$FDDA | Prints contents of A register in hexadecimal format. |
| [PRead](#pread-fb1e) | \$FB1E | Returns dial position of hand control or mouse position. |
| [PRead4](#pread4-fb21) | \$FB21 | Alternate entry point of PRead. |
| [PrErr](#prerr-ff2d) | \$FF2D | Prints “ERR” and sends a bell character. |
| [PrHex](#prhex-fde3) | \$FDE3 | Prints lower nibble of A register in hexadecimal format. |
| [PrntAX](#prntax-f941) | \$F941 | Prints contents of A and X registers as a four-digit hex value. |
| [PrntX](#prntx-f944) | \$F944 | Prints contents of X register as a two-digit hex value. |
| [PrntYX](#prntyx-f940) | \$F940 | Prints contents of Y and X registers as a four-digit hex value. |
| [PwrUp](#pwrup-faa6) | \$FAA6 | Completes cold start initialization, sets soft switches, initializes RAM, transfers control. |
| [RdChar](#rdchar-fd35) | \$FD35 | Activates escape mode, then jumps to RdKey. |
| [RdKey](#rdkey-fd0c) | \$FD0C | Loads A with character at current cursor, passes control to FD10. |
| [Read](#read-fefd) | \$FEFD | Obsolete entry point, simply returns. |
| [RegDsp](#regdsp-fad7) | \$FAD7 | Displays memory state and saved A, X, Y, P, S register contents. |
| [Reset](#reset-fa62) | \$FA62 | Performs warm start initialization, checks for cold start, transfers control. |
| [Restore](#restore-ff3f) | \$FF3F | Sets A, X, Y, P registers to stored values. |
| [Save](#save-ff4a) | \$FF4A | Stores current A, X, Y, P, S registers, clears decimal mode flag. |
| [Scrn](#scrn-f871) | \$F871 | Returns color value of a single block on Lo-Res graphics display. |
| [Scroll](#scroll-fc70) | \$FC70 | Scrolls text window up by one line, updates BASL/BASH. |
| [SetCol](#setcol-f864) | \$F864 | Set the color used for plotting in the Lo-Res graphics mode. |
| [SetGr](#setgr-fb40) | \$FB40 | Sets display to mixed graphics, clears graphics screen, sets text window top. |
| [SetInv](#setinv-fe80) | \$FE80 | Sets INVFLG to \$3F for inverse text output. |
| [SetKbd](#setkbd-fe89) | \$FE89 | Sets input links to point to keyboard input routine KeyIn. |
| [SetNorm](#setnorm-fe84) | \$FE84 | Set inverse flag to display normal characters,Y,-,Y,FALSE,Text window,, |
| [SetPwrC](#setpwrc-fb6f) | \$FB6F | Calculates Validity-Check byte for reset vector and stores it. |
| [SetTxt](#settxt-fb39) | \$FB39 | Sets display to full-screen text window, updates BASL/BASH. |
| [SetVid](#setvid-fe93) | \$FE93 | Sets output links to point to screen display routine COut1. |
| [SetWnd](#setwnd-fb4b) | \$FB4B | Sets text window to full screen width, with top at specified line. |
| [StorAdv](#storadv-fbf0) | \$FBF0 | Places printable character on text screen, advances cursor, handles carriage return. |
| [TabV](#tabv-fb5b) | \$FB5B | Performs a vertical tab to the line specified in A, updates CV and BASL/BASH. |
| [Up](#up-fc1a) | \$FC1A | Decrements CV value, moving cursor up one line, unless at top of window. |
| [Verify](#verify-fe36) | \$FE36 | Compares contents of two memory ranges, reports mismatches. |
| [Version](#version-fbb3) | \$FBB3 | ROM identification byte, not a callable routine (value is \$06). |
| [VidOut](#vidout-fbfd) | \$FBFD | Sends printable characters to StorAdv, handles control characters. |
| [VidWait](#vidwait-fb78) | \$FB78 | Checks for carriage return, Control-S, handles output pausing and enhanced video. |
| [VLine](#vline-f828) | \$F828 | Draws a vertical line of blocks on the Lo-Res graphics display. |
| [VTab](#vtab-fc22) | \$FC22 | Performs vertical tab to line specified by CV, updates BASL/BASH. |
| [VTabZ](#vtabz-fc24) | \$FC24 | Vertical tab to line specified in A register (Internal helper). |
| [Wait](#wait-fca8) | \$FCA8 | Introduces a time delay determined by the value in A register. |
| [Write](#write-fecd) | \$FECD | Obsolete entry point, simply returns. |
| [ZIDByte](#zidbyte-fbc0) | \$FBC0 | ROM identification byte, not a callable routine (\$00 for Apple IIc). |
| [ZIDByte2](#zidbyte2-fbbf) | \$FBBF | ROM identification byte, not a callable routine (depends on Apple IIc version). |
| [ZMode](#zmode-ffc7) | \$FFC7 | Stores \$00 in Monitor’s Monitor Mode Byte to clear Monitor mode. |

## Detailed Firmware Entry Points

### A1PC (\$FE75)

**Description:**

This is an **internal helper routine** primarily used by other ROM
routines (e.g., [Go](#go-feb6)) to conditionally copy a 16-bit address
from the zero-page locations [A1L/A1H](#a1l-a1h) to the program counter
([PCL/PCH](#pcl-pch)). Its behavior is dependent on the initial value of
the X register. If the X register is zero on entry, the routine performs
no copy and returns immediately. If X is non-zero (typically \$01), it
copies the contents of [A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch).

**Input:**

- **Registers:**
  - X: Controls the copy operation. If X=\$00, no copy is performed. If
    X=\$01, both bytes of the 16-bit address are copied.
  - A: N/A
  - Y: N/A
- **Memory:**
  - [A1L/A1H](#a1l-a1h) (address \$3C-\$3D): The 16-bit source address
    that may be copied to the program counter. Its initial value is read
    during the copy operation.

**Output:**

- **Registers:**
  - A: Modified (contains the last byte copied or the value of X if no
    copy).
  - X: Modified (decremented during the copy loop if X was initially
    non-zero).
  - Y: Preserved.
  - P: Flags affected by `txa`, `beq`, `lda`, `sta`, and `dex`
    instructions.
- **Memory:**
  - [PCL/PCH](#pcl-pch) (address \$3A-\$3B): The 16-bit program counter
    address, updated with the value from [A1L/A1H](#a1l-a1h) if X was
    non-zero on entry.

**Side Effects:**

- Conditionally copies a 16-bit address from [A1L/A1H](#a1l-a1h) to
  [PCL/PCH](#pcl-pch).

**See also:**

- [Go](#go-feb6)
- [A1L/A1H](#a1l-a1h)
- [PCL/PCH](#pcl-pch)

### Advance (\$FBF4)

**Description:**

This routine advances the text cursor’s horizontal position by one
character, incrementing [CH](#ch). If this causes the cursor to move
beyond the [WNDWDTH](#wndwdth) (window width), it calls [LF](#lf-fc66)
to perform a carriage return to the beginning of the next line.
Otherwise, the updated horizontal position is saved back to [CH](#ch).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the text window.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by arithmetic and comparison operations.
- **Memory:**
  - [CH](#ch): Updated to new horizontal cursor position; reset to
    [WNDLFT](#wndlft) if carriage return occurs.
  - [CV](#cv): May be incremented if a carriage return occurs.
  - [BASL/BASH](#basl-bash): May be updated if a carriage return occurs.

**Side Effects:**

- Moves the horizontal text cursor.
- If the cursor reaches the window’s right edge, the display may scroll.

**See also:**

- [LF](#lf-fc66)
- [COUT](#cout-fded)
- [WNDLFT](#wndlft)
- [WNDWDTH](#wndwdth)
- [CH](#ch)
- [CV](#cv)
- [BASL/BASH](#basl-bash)

### AppleII (\$FB60)

**Description:**

This routine clears the text display and shows the machine’s “Apple II”
family identification string (e.g., “Apple //e”, “Apple IIGS”) on the
first line. It operates only in text modes and will not function in
graphics or mixed modes. Note that in some earlier Apple II ROMs, the
routine at this address (`$FB60`) was a multiplication routine (`MULPM`)
and not the `AppleII` display routine.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Flags affected
- **Memory:**
  - Text screen memory is modified to display the machine name.

**Side Effects:**

- Modifies the text screen display.
- Functionality depends on the display being in text mode.

**See also:**

- [Home](#home-fc58)
- [SetTxt](#settxt-fb39)
- [Mon (\$FF65)](#mon-ff65)

### BS (\$FC10)

**Description:**

This routine performs a backspace operation. It decrements [CH](#ch). If
the cursor reaches the left window boundary, it wraps to the rightmost
edge, and calls [Up](#up-fc1a) to move the cursor up one line.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [WNDLFT](#wndlft) (address \$20): Left edge boundary of the text
    window.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the text window.
  - OURCH (address \$58): 80-column horizontal cursor position (used in
    Apple IIc variant).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected by arithmetic and comparison operations.
- **Memory:**
  - [CH](#ch): Decremented; reset to [WNDWDTH](#wndwdth) if cursor
    wraps.
  - [CV](#cv): May be altered if the [Up](#up-fc1a) routine is called.
  - [BASL/BASH](#basl-bash): May be altered if the [Up](#up-fc1a)
    routine is called.

**Side Effects:**

- Modifies the horizontal cursor position.
- May modify vertical cursor position and display memory if
  [Up](#up-fc1a) is called.

**See also:**

- [Up](#up-fc1a)
- [CH](#ch)
- [WNDLFT](#wndlft)
- [WNDWDTH](#wndwdth)
- [CV](#cv)
- [BASL/BASH](#basl-bash)

### BasCalc (\$FBC1)

**Description:**

This routine computes and stores the 16-bit base memory address for a
given text display line. The line number is provided in the A register
(\$00-\$17). The calculated high and low bytes are stored in
[BASL/BASH](#basl-bash).

**Input:**

- **Registers:**
  - A: Text line number (\$00-\$17, representing lines 0-23)
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by arithmetic and logical operations
- **Memory:**
  - [BASL/BASH](#basl-bash): Updated with the computed 16-bit base
    address.

**Side Effects:** None.

**See also:**

- [BASL/BASH](#basl-bash)
- [Init](#init-fb2f)
- [LF](#lf-fc66)
- [Scroll](#scroll-fc70)
- [SetTxt](#settxt-fb39)
- [SetWnd](#setwnd-fb4b)
- [VTab](#vtab-fc22)
- [VTabZ](#vtabz-fc24)

### Bell (\$FF3A)

**Description:**

This routine transmits an ASCII bell character (`$87`) to the standard
output by loading the character into the A register and jumping to
[COut](#cout-fded), which handles the actual output operation. This
typically generates an audible tone when the output device supports bell
character handling.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the bell character `$87`
  - X: Preserved (by COut)
  - Y: Preserved (by COut)
  - P: Flags affected by output operations
- **Memory:** None.

**Side Effects:**

- Calls [COut](#cout-fded) to output the bell character.
- Generates an audible tone (or other bell response depending on output
  device).

**See also:**

- [Bell1](#bell1-fbdd)
- [Bell1_2](#bell1_2-fbe2)
- [Bell2](#bell2-fbe4)

### Bell1 (\$FBDD)

**Description:**

This routine generates a brief 1 kHz tone through the system speaker for
approx. 0.1 second. A short 0.01-second pre-tone delay prevents
distortion from rapid calls.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Contains `$00`
  - P: Flags affected by internal timing loops
- **Memory:** None.

**Side Effects:**

- Generates a speaker tone.
- Introduces a brief execution delay.

**See also:**

- [Bell1_2](#bell1_2-fbe2)
- [Bell2](#bell2-fbe4)

### Bell1_2 (\$FBE2)

**Description:**

This routine generates a brief 1 kHz tone via the system speaker for
approximately 0.1 second. Unlike [Bell1](#bell1-fbdd), `Bell1_2`
includes no preliminary delay.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Contains `$00`
  - P: Flags affected by internal timing loops
- **Memory:** None.

**Side Effects:**

- Generates a speaker tone.

**See also:**

- [Bell1](#bell1-fbdd)
- [Bell2](#bell2-fbe4)

### Bell2 (\$FBE4)

**Description:**

This routine generates a 1 kHz square-wave tone by rapidly toggling the
system speaker. The tone’s duration is controlled by the Y register;
e.g., Y = `$C0` (192 decimal) for approx. 0.1 second, or Y = `$00` to
toggle 256 times.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: Number of times to activate the speaker (duration proportional to
    Y).
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Contains `$00`
  - P: Flags affected by internal timing loops
- **Memory:** None.

**Side Effects:**

- Generates a speaker tone by repeatedly accessing the speaker soft
  switch at \$C030.

**See also:**

- [Bell1](#bell1-fbdd)
- [Bell1_2](#bell1_2-fbe2)

### Break (\$FA4C)

**Description:**

This routine handles the processor’s hardware break event. It saves CPU
registers (A, X, Y, P, S) and the Program Counter (PC) into memory
locations ([A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status),
[SPNT](#spnt), [PCL/PCH](#pcl-pch)). Control then transfers to the
user-defined break handler at [User Break Hook](#user-break-hook)
(\$03F0-\$03F1), or to [OldBrk](#oldbrk-fa59) by default. In the
original Apple II ROM, the address `$FA4C` corresponds to a different
routine and is not the 6502 break handler described here.

**Input:**

- **Registers:**
  - A: Current Accumulator value (saved)
  - X: Current X-index register value (saved)
  - Y: Current Y-index register value (saved)
- **Memory:**
  - [STATUS](#status) (address \$48): The routine reads the current
    processor status.
  - [User Break Hook](#user-break-hook) (address \$03F0-\$03F1): The
    16-bit address of the user’s custom break handler routine.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - CPU registers are indirectly saved by this routine.

**Side Effects:**

- Saves CPU registers and Program Counter.
- Transfers control via the [User Break Hook](#user-break-hook).
- Modifies the CPU stack.

**See also:**

- [OldBrk](#oldbrk-fa59)
- [NewBrk](#newbrk-fa47)
- [User Break Hook](#user-break-hook)
- [A5H](#a5h)
- [XREG](#xreg)
- [YREG](#yreg)
- [STATUS](#status)
- [SPNT](#spnt)
- [PCL/PCH](#pcl-pch)

### CHK80 (\$CDCD) (Internal)

**Description:**

This is an **internal helper routine** called during input/output setup
(e.g., as part of the `DOPR0` routine). Its purpose is to check if the
system is currently in 80-column video mode and, if so, to convert the
display to 40-column mode. If the system is already in 40-column mode,
it simply proceeds without modification.

The routine first checks the `RD80VID ($C01F)` soft switch. If it
indicates 40-column mode, it branches to [SETX](#setx-ce1a). If in
80-column mode, it then proceeds to configure a 40-column text window,
potentially manipulating [WNDTOP](#wndtop) and [WNDWDTH](#wndwdth) based
on `RDTEXT` soft switch.

**Input:**

- **Registers:** N/A (all register inputs are internal or passed to
  subroutines).
- **Memory:**
  - `RD80VID ($C01F)`: Read-only soft switch that determines if the
    system is currently in 80-column video mode.
  - `RDTEXT ($C01A)`: Read-only soft switch that indicates if the system
    is in text mode or graphics mode, used by [WIN0](#win0-cdd5).

**Output:**

- **Registers:**
  - A: Modified by various operations.
  - X: Modified by various operations.
  - Y: Modified by various operations.
  - P: Flags affected by bitwise and conditional operations.
- **Memory:**
  - [WNDTOP](#wndtop) (address \$22): May be written to by
    [WIN0](#win0-cdd5).
  - [WNDWDTH](#wndwdth) (address \$21): May be written to by
    [WIN0](#win0-cdd5).
  - `CLR80COL ($C000)`: Soft switch (written by [WIN0](#win0-cdd5)).
  - `CLR80VID ($C00C)`: Soft switch (written by [WIN0](#win0-cdd5)).

**Side Effects:**

- Reads the `RD80VID` soft switch.
- Conditionally branches to [SETX](#setx-ce1a).
- If in 80-column mode, it flows into [WIN40](#win40-cdd2), which then
  calls [WIN0](#win0-cdd5).
- May write to `CLR80COL` and `CLR80VID` soft switches (via
  [WIN0](#win0-cdd5)).
- Modifies zero-page locations [WNDTOP](#wndtop) and
  [WNDWDTH](#wndwdth).

**See also:**

- `DOPR0 ($FECE)` (internal routine)
- `RD80VID` (soft switch)
- [SETX](#setx-ce1a) (internal routine)
- [WIN40](#win40-cdd2) (internal routine)
- [WIN0](#win0-cdd5) (internal routine)
- [WNDTOP](#wndtop)
- [WNDWDTH](#wndwdth)
- `CLR80COL` (soft switch)
- `CLR80VID` (soft switch)

### CLRCH (\$FEE9) (Internal)

**Description:**

This is an **internal helper routine** called by routines like
[HOMECUR](#homecur-cda5) to clear the horizontal cursor positions. It
initializes a value in the A register and then calls
[GETCUR2](#getcur2-ccad) to perform the actual updates to [CH](#ch),
[OLDCH](#oldch), and [OURCH](#ourch). Before returning, it loads the
final value of [OURCH](#ourch) into the A register.

**Input:**

- **Registers:** N/A (the routine itself sets the initial value for A).
- **Memory:**
  - [OURCH](#ourch) (address \$057B): Its value is read just before
    returning, effectively making it an input to the A register output.

**Output:**

- **Registers:**
  - A: Contains the value of [OURCH](#ourch) on exit.
  - X: Modified by internal calls (specifically
    [GETCUR2](#getcur2-ccad)).
  - Y: Modified by internal calls (specifically
    [GETCUR2](#getcur2-ccad)).
  - P: Flags affected by internal operations.
- **Memory:**
  - [CH](#ch) (address \$24): Set by [GETCUR2](#getcur2-ccad) (to \$00
    if in 80-column mode, or based on the input Y to
    [GETCUR2](#getcur2-ccad)).
  - [OLDCH](#oldch) (address \$047B): Set by [GETCUR2](#getcur2-ccad).
  - [OURCH](#ourch) (address \$057B): Updated by
    [GETCUR2](#getcur2-ccad).

**Side Effects:**

- Calls [GETCUR2](#getcur2-ccad) to manage horizontal cursor positions.
- Sets [CH](#ch), [OLDCH](#oldch), and [OURCH](#ourch) based on
  80-column mode and the Y register value passed to
  [GETCUR2](#getcur2-ccad).

**See also:**

- [HOMECUR](#homecur-cda5)
- [GETCUR2](#getcur2-ccad)
- [CH](#ch)
- [OLDCH](#oldch)
- [OURCH](#ourch)

### COut (\$FDED)

**Description:**

This routine serves as the primary entry point for standard character
output. It indirectly calls the output routine whose 16-bit address is
in [CSWL/CSWH](#cswl-cswh). If enhanced video firmware is active, it
routes to `C3COutl`; otherwise, to [COut1](#cout1-fdf0).

**Input:**

- **Registers:**
  - A: The ASCII character intended for output.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): The address of the
    current character output routine.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined (flags may be affected by the ultimately called output
    routine).
- **Memory:**
  - The indirectly called output routine may modify display memory or
    transmit data.

**Side Effects:**

- Transfers control to the output routine designated by
  [CSWL/CSWH](#cswl-cswh).
- The ultimate output routine will display a character or execute
  control functions.

**See also:**

- [COut1](#cout1-fdf0)
- [COutZ](#coutz-fdf6)
- [CSWL/CSWH](#cswl-cswh)
- [SetVid](#setvid-fe93)
- [OutPort](#outport-fe95)

### COut1 (\$FDF0)

**Description:**

This routine displays the ASCII character in the A register at the
current cursor position, then advances the cursor. It processes control
characters such as carriage return (\$8D), line feed (\$8A), backspace
(\$88), and bell (\$87). Printable character display (normal or inverse)
is governed by [INVFLG](#invflg), unless the character is a control
character.

**Input:**

- **Registers:**
  - A: The ASCII character to be displayed.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [INVFLG](#invflg) (address \$32): Determines if the output character
    should be inverse.
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [CV](#cv) (address \$25): Current vertical cursor position.
  - [KSWL/KSWH](#kswl-kswh) (address \$36-\$37): Address of the keyboard
    input routine, used by subroutines.
  - VFACTV (address \$067B): Video firmware active flag (Apple IIc
    variant).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by internal operations.
- **Memory:**
  - Text memory at the current cursor position is updated.
  - [CH](#ch) and [CV](#cv) may be updated if the cursor advances or
    moves.

**Side Effects:**

- Displays a character.
- Advances the cursor.
- Handles specific control characters.

**See also:**

- [COut](#cout-fded)
- [COutZ](#coutz-fdf6)
- [INVFLG](#invflg)
- [CH](#ch)
- [CV](#cv)

### COutZ (\$FDF6)

**Description:**

This routine is an alternative entry point to [COut1](#cout1-fdf0). Its
functionality is identical, but `COutZ` bypasses the initial application
of [INVFLG](#invflg). This is useful for enhanced video firmware that
manages the inverse flag independently after processing control
characters, preventing redundant application.

**Input:**

- **Registers:**
  - A: The ASCII character to be displayed.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [CV](#cv) (address \$25): Current vertical cursor position.
  - [KSWL/KSWH](#kswl-kswh) (address \$36-\$37): Address of the keyboard
    input routine, used by subroutines.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by internal operations.
- **Memory:**
  - Text memory at current cursor position is modified.
  - [CH](#ch) and [CV](#cv) may be updated due to cursor advancement or
    control character processing.

**Side Effects:**

- Displays a character.
- Advances the cursor.
- Processes specific control characters.

**See also:**

- [COut](#cout-fded)
- [COut1](#cout1-fdf0)
- [INVFLG](#invflg)
- [CH](#ch)
- [CV](#cv)

### CPRT0 (\$FEC2) (Internal)

**Description:**

This is an **internal helper routine**, primarily branched to by the
`IPORT ($FE9B)` routine when handling certain input/output
configurations. It decrements the A register (intended to turn \$00 into
\$FF), stores this resulting value into the zero-page location
[CURSOR](#cursor), and then loads A with a constant value of `#$F7`.
Finally, it branches to the `DOPR0 ($FECE)` routine. This sequence
suggests it’s part of a process to set a “checkerboard” cursor and then
initiate a PR#0-like reset of video firmware.

**Input:**

- **Registers:**
  - A: Expected to be \$00 on entry, so that `dec A` results in \$FF.
  - X: N/A
  - Y: N/A
- **Memory:** N/A (the routine primarily acts on its A register input,
  which is a fixed value).

**Output:**

- **Registers:**
  - A: Modified (contains `#$F7` on transfer to `DOPR0`).
  - X: Preserved.
  - Y: Preserved.
  - P: Flags affected by `dec A`, `sta`, and `lda` operations.
- **Memory:**
  - [CURSOR](#cursor) (address \$07FB): Set to \$FF (checkerboard
    cursor).

**Side Effects:**

- Sets the [CURSOR](#cursor) to \$FF (representing a checkerboard
  cursor).
- Transfers control to the `DOPR0 ($FECE)` routine.

**See also:**

- `IPORT ($FE9B)` (internal routine)
- `DOPR0 ($FECE)` (internal routine)
- [CURSOR](#cursor)

### CR (\$FC62)

**Description:**

This routine executes a carriage return. It moves the horizontal cursor
to the leftmost edge of the current text window (defined by
[WNDLFT](#wndlft)), then calls [LF](#lf-fc66) to advance the cursor to
the beginning of the next line.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [WNDLFT](#wndlft) (address \$20): The left edge of the text window.
  - [CV](#cv) (address \$25): The current vertical cursor position.
  - [WNDBTM](#wndbtm) (address \$23): The bottom edge of the text
    window.
  - VARTIM (address \$0789): PASCAL 1.1 timing flag (used in Apple IIc
    variant).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Flags affected by internal operations.
- **Memory:**
  - [CH](#ch): Set to the value of [WNDLFT](#wndlft).
  - [CV](#cv): May be updated if [LF](#lf-fc66) causes vertical cursor
    movement.
  - [BASL/BASH](#basl-bash): May be updated if [LF](#lf-fc66) modifies
    the base address.

**Side Effects:**

- Repositions the horizontal cursor.
- May cause vertical cursor movement and display scrolling via
  [LF](#lf-fc66).
- May affect text memory.

**See also:**

- [LF](#lf-fc66)
- [WNDLFT](#wndlft)
- [CH](#ch)
- [CV](#cv)
- [BASL/BASH](#basl-bash)

### CROut (\$FD8E)

**Description:**

This routine initiates a carriage return by sending a carriage return
character to the standard output, typically repositioning the cursor to
the beginning of the next line.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): The address of the
    current character output routine.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by the underlying output routine.
- **Memory:**
  - Text memory at the current cursor position may be modified.
  - [CH](#ch) and [CV](#cv) may be updated, depending on the active
    output routine.

**Side Effects:**

- Outputs a carriage return.
- Modifies the cursor’s position.

**See also:**

- [COut](#cout-fded)
- [CR](#cr-fc62)
- [CSWL/CSWH](#cswl-cswh)
- [CH](#ch)
- [CV](#cv)

### CROut1 (\$FD8B)

**Description:**

This routine first calls [ClrEOL](#clreol-fc9c) to clear the current
text line from the cursor’s position to the right edge of the window. It
then loads the ASCII carriage return character (`$8D`) into the A
register and flows into the [COut](#cout-fded) routine to output this
character.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined (consumed by COut)
  - X: Preserved
  - Y: Undefined (may be altered by COut or its subroutines)
  - P: Flags affected by internal operations.
- **Memory:**
  - Text memory is modified due to the call to [ClrEOL](#clreol-fc9c).
  - Cursor position (horizontal and vertical) is modified by
    [COut](#cout-fded) and its subroutines.

**Side Effects:**

- Calls [ClrEOL](#clreol-fc9c) to clear a portion of the current text
  line.
- Flows into [COut](#cout-fded) to output a carriage return character,
  which repositions the cursor and may scroll the display.

**See also:**

- [CROut](#crout-fd8e)
- [ClrEOL](#clreol-fc9c)
- [WNDWDTH](#wndwdth)
- [CH](#ch)
- [BASL/BASH](#basl-bash)

### ClrEOL (\$FC9C)

**Description:**

This routine erases text on the current line within the active text
window, starting from the current horizontal cursor position ([CH](#ch))
and extending to the rightmost boundary of the window
([WNDWDTH](#wndwdth)).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the text window.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line.
  - [WNDLFT](#wndlft) (address \$20): Left edge of the text window.
  - [INVFLG](#invflg) (address \$32): Determines if the clear operation
    uses inverse or normal characters (Apple IIc variant).
  - OURCH (address \$057B): Used for 80-column display.
  - VFACTV (address \$067B): Video firmware active flag (Apple IIc
    variant).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Text memory is modified from [CH](#ch) to [WNDWDTH](#wndwdth) on the
    current line.

**Side Effects:**

- Clears a portion of the visible text on the current line.

**See also:**

- [WNDWDTH](#wndwdth)
- [CH](#ch)
- [BASL/BASH](#basl-bash)

### ClrEOLZ (\$FC9E)

**Description:**

This routine clears a segment of the current text line from the column
specified by the Y register to the rightmost edge of the active text
window ([WNDWDTH](#wndwdth)).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: Starting column position for clearing.
- **Memory:**
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the text window.
  - [INVFLG](#invflg) (address \$32): Determines if the clear operation
    uses inverse or normal characters (Apple IIc variant).
  - VFACTV (address \$067B): Video firmware active flag (Apple IIc
    variant).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags may be affected
- **Memory:**
  - Text memory is modified from the column specified by Y up to
    [WNDWDTH](#wndwdth) on the current line.

**Side Effects:**

- Clears a portion of the visible text on the current line.

**See also:**

- [WNDWDTH](#wndwdth)
- [WNDLFT](#wndlft)
- [BASL/BASH](#basl-bash)

### ClrEOP (\$FC42)

**Description:**

This routine clears the text window from the current cursor position to
the end of the current line, and from the current line down to the
bottom of the window. The cursor is then restored to its original
starting position.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [CV](#cv) (address \$25): Current vertical cursor position.
  - [WNDBTM](#wndbtm) (address \$23): Bottom edge of the text window.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the text window.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line.
  - [INVFLG](#invflg) (address \$32): Determines if the clear operation
    uses inverse or normal characters (Apple IIc variant).
  - VFACTV (address \$067B): Video firmware active flag (Apple IIc
    variant).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Flags may be affected
- **Memory:**
  - Text memory within the current window from the cursor position to
    the bottom of the window is cleared.

**Side Effects:**

- Clears text within the current window.
- Resets the cursor to its initial position.

**See also:**

- [WNDWDTH](#wndwdth)
- [CH](#ch)
- [CV](#cv)
- [BASL/BASH](#basl-bash)
- [WNDBTM](#wndbtm)

### ClrScr (\$F832)

**Description:**

This routine clears the Lo-Res graphics display to black. If called in
text mode, it fills the text screen with inverse at-sign (`@`)
characters instead.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - Lo-Res graphics display memory is cleared to black, or text screen
    memory is filled with inverse ‘@’ characters.

**Side Effects:**

- Modifies display memory; behavior is conditional on the current video
  mode.

**See also:** None.

### ClrTop (\$F836)

**Description:**

This routine clears the upper 40 lines of the Lo-Res graphics display to
black. This is particularly useful for clearing the graphics portion of
a mixed-mode screen.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - The top 40 lines of the Lo-Res graphics display memory are set to
    black.

**Side Effects:**

- Modifies the Lo-Res graphics display.

**See also:** None.

### DOPR0 (\$FECE) (Internal)

**Description:**

This is an **internal helper routine** branched to by `CPRT0 ($FEC2)` as
part of a “PR#0” (print to slot 0, usually meaning the screen)
operation. It sets the `VFACTV` flag to indicate that the video firmware
is inactive, switches the character set to normal, and modifies the
`VMODE` setting. It then saves the X and Y registers on the stack before
calling `CHK80 ($CDCD)` to conditionally switch to 40-column mode if the
system was previously in 80-column mode. Finally, it restores the X and
Y registers from the stack and flows into `IOPRT1 ($FEEE)`, which
continues the process of setting output hooks to the default video
output routine ([COUT1](#cout1-fdf0)).

**Input:**

- **Registers:** A (expected to contain `#$F7` from `CPRT0`, used to set
  `VFACTV` and `CLRALTCHAR`).
- **Memory:**
  - [VMODE](#vmode) (address \$04FB): Its current state is read and
    modified by `tsb VMODE`.
  - `RD80VID ($C01F)`: Soft switch read by [CHK80](#chk80-cdcd).
  - `RDTEXT ($C01A)`: Soft switch read by [WIN0](#win0-cdd5) (part of
    `CHK80`’s flow).

**Output:**

- **Registers:**
  - A: Modified (contains `>COUT1` before flowing to `IOPRT1`).
  - X: Preserved (pushed and pulled from stack).
  - Y: Preserved (pushed and pulled from stack).
  - P: Flags affected by various operations.
- **Memory:**
  - [VFACTV](#vfactv) (address \$067B): Set to the value of A
    (effectively `$F7`).
  - `CLRALTCHAR ($C00E)`: Soft switch, set to the value of A
    (effectively `$F7`).
  - [VMODE](#vmode) (address \$04FB): Modified by `tsb VMODE` (setting
    bit 2, which corresponds to M.CTL).
  - [WNDTOP](#wndtop) (address \$22): May be modified by
    [WIN0](#win0-cdd5) within `CHK80`.
  - [WNDWDTH](#wndwdth) (address \$21): May be modified by
    [WIN0](#win0-cdd5) within `CHK80`.
  - [KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh): Updated by
    `IOPRT2` (part of `IOPRT1`’s flow).

**Side Effects:**

- Sets `VFACTV` to indicate video firmware inactivity.
- Activates the normal character set (`CLRALTCHAR` soft switch).
- Sets the M.CTL bit in `VMODE`.
- Calls [CHK80](#chk80-cdcd) to handle column mode conversion.
- Flows into `IOPRT1 ($FEEE)` to set up output hooks, ultimately
  directing output to [COUT1](#cout1-fdf0).

**See also:**

- `CPRT0 ($FEC2)` (internal routine)
- [CHK80](#chk80-cdcd) (internal routine)
- [VFACTV](#vfactv)
- [CLRALTCHAR](#clraltchar) (soft switch)
- [VMODE](#vmode)
- [COUT1](#cout1-fdf0)
- `IOPRT1 ($FEEE)` (internal routine)
- `IOPRT2 ($FEAB)` (internal routine)
- [WNDTOP](#wndtop), [WNDWDTH](#wndwdth), [RDTEXT](#rdtext),
  [RD80VID](#rd80vid), [SETX](#setx) (accessed via [CHK80](#chk80-cdcd))

### Dig (\$FF8A)

**Description:**

This routine converts an ASCII code representing a hexadecimal digit
into its corresponding hexadecimal number. This process is initiated by
[NxtChr (\$FFAD)](#nxtchr-ffad), which preprocesses the ASCII code
(performing an exclusive OR with \$B0 and potentially adding \$88 for
characters A-F) before passing it in the A register to `Dig`. `Dig` then
shifts the conditioned character bit-by-bit into the zero-page locations
[A2L](#a2l-a2h) (\$3E) and [A2H](#a2l-a2h) (\$3F), effectively storing
the hexadecimal value. Control is then passed back to [NxtChr
(\$FFAD)](#nxtchr-ffad). This combination of [NxtChr
(\$FFAD)](#nxtchr-ffad) and `Dig` routines is essential for converting
user-entered ASCII digits into numerical values.

**Input:**

- **Registers:**
  - A: The ASCII code of a hexadecimal digit, after being conditioned by
    the [NxtChr (\$FFAD)](#nxtchr-ffad) routine (e.g., \$B0-\$BF for
    0-9, or \$C1-\$CF for A-F after processing).
  - X: Undefined.
  - Y: The offset into the input buffer (\$0200) for the next character
    to decode.
- **Memory:**
  - Input buffer (\$0200): The start of the Monitor’s input buffer.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: The offset into the input buffer for the next character to decode
    (same as input Y).
  - P: Undefined.
- **Memory:**
  - [A2L/A2H](#a2l-a2h) (addresses \$3E-\$3F): Stores the hexadecimal
    number decoded from the ASCII character.

**Side Effects:**

- Converts an ASCII hexadecimal digit to its numerical equivalent.
- Stores the result in [A2L/A2H](#a2l-a2h).
- Transfers control back to [NxtChr (\$FFAD)](#nxtchr-ffad).

**See also:**

- [NxtChr (\$FFAD)](#nxtchr-ffad)
- [A2L/A2H](#a2l-a2h)

### FD10 (\$FD10)

**Description:**

This routine executes an indirect jump for standard input. It transfers
control to the routine whose 16-bit address is in
[KSWL/KSWH](#kswl-kswh) (typically [KeyIn](#keyin-fd1b) or `C3KeyIn`).
It is functionally identical to [KeyIn0](#keyin0-fd18).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: Index register Y, used with BASL for memory access (older ROMs).
- **Memory:**
  - [KSWL/KSWH](#kswl-kswh) (address \$36-\$37): The 16-bit address of
    the currently active standard input routine.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line, used for indirect memory access (older ROMs).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected
- **Memory:**
  - Modifications depend on the called routine.

**Side Effects:**

- Transfers control to the input routine specified by
  [KSWL/KSWH](#kswl-kswh).
- Side effects are those of the called routine.

**See also:**

- [KeyIn](#keyin-fd1b)
- [KeyIn0](#keyin0-fd18)
- [C3KeyIn](#c3keyin)
- [KSWL/KSWH](#kswl-kswh)

### GBasCalc (\$F847)

**Description:**

This routine calculates the 16-bit base memory address for a Lo-Res
graphics display row (\$00-\$2F) provided in the A register. The
calculated address is stored in [GBASL/GBASH](#gbasl-gbash).

**Input:**

- **Registers:**
  - A: Lo-Res graphics row number (\$00-\$2F)
  - X: N/A
  - Y: N/A
- **Memory:**
  - [GBASL/GBASH](#gbasl-gbash) (address \$26-\$27): Current
    low-resolution graphics base address. The routine reads the initial
    value of GBASL as part of its calculation.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address.
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by arithmetic operations.
- **Memory:**
  - [GBASL/GBASH](#gbasl-gbash): Updated with the computed 16-bit base
    address.

**Side Effects:** None.

**See also:**

- [Plot](#plot-f800)
- [Plot1](#plot1-f80e)
- [GBASL/GBASH](#gbasl-gbash)

### GETCUR2 (\$CCAD) (Internal)

**Description:**

This is an **internal helper routine** called by [CLRCH](#clrch-fee9)
(and potentially other routines) to update the current horizontal cursor
positions stored in zero-page locations [CH](#ch), [OLDCH](#oldch), and
[OURCH](#ourch). It takes the desired horizontal cursor value in the Y
register. If the system is in 80-column video mode (checked via the
`RD80VID` soft switch), it pegs [CH](#ch) and [OLDCH](#oldch) to \$00,
effectively resetting the cursor to the far left, while [OURCH](#ourch)
is always updated with the Y register’s value.

**Input:**

- **Registers:**
  - Y: The desired horizontal cursor position to apply to
    [OURCH](#ourch), and potentially [CH](#ch) and [OLDCH](#oldch).
  - A: N/A
  - X: N/A
- **Memory:**
  - `RD80VID ($C01F)`: A read-only soft switch that determines if the
    system is currently in 80-column video mode. This value is used to
    conditionally set [CH](#ch) and [OLDCH](#oldch).

**Output:**

- **Registers:**
  - A: Contains the value of [OURCH](#ourch) on exit.
  - X: Preserved.
  - Y: Preserved.
  - P: Flags affected by `bit`, `sty`, and `lda` operations.
- **Memory:**
  - [OURCH](#ourch) (address \$057B): Always updated with the value of
    the Y register from entry.
  - [CH](#ch) (address \$24): Set to \$00 if in 80-column mode,
    otherwise set to the value of the Y register from entry.
  - [OLDCH](#oldch) (address \$047B): Set to \$00 if in 80-column mode,
    otherwise set to the value of the Y register from entry.

**Side Effects:**

- Reads the `RD80VID` soft switch.
- Updates zero-page locations [OURCH](#ourch), [CH](#ch), and
  [OLDCH](#oldch) based on the input Y register and the current video
  mode.

**See also:**

- [CLRCH](#clrch-fee9)
- [HOMECUR](#homecur-cda5)
- [CH](#ch)
- [OLDCH](#oldch)
- [OURCH](#ourch)
- `RD80VID` (soft switch)

### GetLn (\$FD6A)

**Description:**

This routine is a standard input subroutine for reading entire lines of
characters from the keyboard. It displays a prompt character (which must
be set at [PROMPT](#prompt) (\$33) by the calling program) and allows
the user to input a line of text, which is stored in an internal buffer.
The routine provides on-screen editing features before the line is
finalized by a carriage return.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:**
  - [PROMPT](#prompt) (address \$33): The character to be used as the
    prompt.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Contains the length of the input line (0-255).
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - Input buffer (\$0200-\$02FF): Contains the entered line of
    characters, terminated by a carriage return.

**Side Effects:**

- Displays a prompt character.
- Reads a line of input from the keyboard into the input buffer.
- Provides on-screen editing features.

**See also:**

- [GetLnZ (\$FD67)](#getlnz-fd67)
- [PROMPT](#prompt)

### GetLn0 (\$FD6C)

**Description:**

This routine displays a prompt character, whose ASCII code is provided
in the A register, by calling [COut](#cout-fded). After displaying the
prompt, it implicitly transfers control to the [GetLn1](#getln1-fd6f)
routine, which handles reading a line of text from the keyboard.

**Input:**

- **Registers:**
  - A: The ASCII code of the prompt character to be displayed.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): The 16-bit address of
    the currently active standard character output routine, used by
    [COut](#cout-fded).

**Output:**

- **Registers:**
  - A: Undefined (consumed by [COut](#cout-fded)).
  - X: Undefined (will be modified by [GetLn1](#getln1-fd6f)).
  - Y: Undefined (will be modified by [GetLn1](#getln1-fd6f)).
  - P: Flags affected by [COut](#cout-fded).
- **Memory:**
  - Screen memory: Modified by displaying the prompt character.
  - Memory locations modified by [GetLn1](#getln1-fd6f) (e.g.,
    [INBUF](#inbuf), [CH](#ch), [CV](#cv)).

**Side Effects:**

- Displays a character on the screen via [COut](#cout-fded).
- Transfers control to [GetLn1](#getln1-fd6f).

**See also:**

- [COut](#cout-fded)
- [GetLn1](#getln1-fd6f)
- [CSWL/CSWH](#cswl-cswh)

### GetLn1 (\$FD6F)

**Description:**

This routine serves as an entry point for keyboard input. It initializes
the X register with a value of \$01\$ and then flows into the [GetLnZ
(\$FD67)](#getlnz-fd67) routine to handle the actual line input. Unlike
[GetLn (\$FD6A)](#getln-fd6a), this entry point does not display an
initial prompt character.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Set to \$01\$.
  - Y: Undefined.
  - P: Undefined.
- **Memory:** None.

**Side Effects:**

- Initializes the X register to \$01\$.
- Transfers control to [GetLnZ (\$FD67)](#getlnz-fd67).

**See also:**

- [GetLn (\$FD6A)](#getln-fd6a)
- [GetLnZ (\$FD67)](#getlnz-fd67)

### GetLnZ (\$FD67)

**Description:**

This is the primary routine for reading a complete line of keyboard
input. It begins by calling [CROut](#crout-fd8e) to output a carriage
return. Subsequently, it displays a prompt character (if A is not N/A),
and then repeatedly calls [RdKey](#rdkey-fd0c) (with escape mode) to get
characters, storing them in [INBUF](#inbuf). It supports editing
features such as:

- Left Arrow (Control-H): Moves cursor left, places backspace (`$88`) in
  [INBUF](#inbuf).
- Control-X or backspace to column 1: Calls [GetLnZ](#getlnz-fd67) for
  carriage return and restarts `GetLnZ`, discarding current input.
  Prints backslash if Control-X pressed.
- Right Arrow (Control-U): Stores character at cursor position in
  [INBUF](#inbuf) instead of `$95`.

**Input:**

- **Registers:**
  - A: The ASCII code of the prompt character to be displayed. (If no
    prompt is desired, A should be N/A or a value that indicates no
    display).
  - X: N/A (initialized internally, or by calling routines like
    [GetLn](#getln1-fd6f) or [GetLn1](#getln1-fd6f)).
  - Y: N/A
- **Memory:**
  - [PROMPT](#prompt) (address \$33): The ASCII character to use as a
    prompt.
  - [INBUF](#inbuf) (address \$0200-\$02FF): The buffer where the input
    line is stored. Accessed for reading and writing during editing.
  - [KSWL/KSWH](#kswl-kswh) (address \$38-\$39): Address of the current
    key-in routine, used by [RdKey](#rdkey-fd0c).
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): Address of the current
    character output routine, used by internal display functions.
  - [CH](#ch) (address \$24): Current horizontal cursor position.
  - [CV](#cv) (address \$25): Current vertical cursor position.
  - [WNDLFT](#wndlft) (address \$20): Left edge of the text window.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the text window.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current text page, used for screen memory access.
  - [INVFLG](#invflg) (address \$32): Inverse flag, checked for
    character display.
  - [VFACTV](#vfactv) (address \$067B): Video active flag, checked for
    video mode.
  - Keyboard soft switches (\$C000-\$C0FF, specifically \$C000 for KBST
    and \$C010 for KBD).

**Output:**

- **Registers:**
  - A: Undefined (contains last character read or internal value).
  - X: Contains the length of the input line read (number of characters
    in [INBUF](#inbuf)).
  - Y: Undefined.
  - P: Flags affected by internal operations.
- **Memory:**
  - [INBUF](#inbuf): Contains the complete line of user input.
  - [CH](#ch): Updated to the final horizontal cursor position.
  - [CV](#cv): Updated to the final vertical cursor position.
  - Screen memory: Modified by displaying prompt, characters, and cursor
    movement.

**Side Effects:**

- Calls [CROut](#crout-fd8e) to output a carriage return.
- Displays a prompt character (if A is provided).
- Reads keyboard input from soft switches.
- Modifies [INBUF](#inbuf) with user input.
- Updates cursor position ([CH](#ch), [CV](#cv)).
- Performs screen memory writes for displaying characters.

**See also:**

- [CROut](#crout-fd8e)
- [RdKey](#rdkey-fd0c)
- [RdChar](#rdchar-fd35)
- [GetLn](#getln1-fd6f)
- [GetLn1](#getln1-fd6f)
- [INBUF](#inbuf)
- [PROMPT](#prompt)
- [CH](#ch)
- [CV](#cv)
- [KSWL/KSWH](#kswl-kswh)
- [CSWL/CSWH](#cswl-cswh)
- [WNDLFT](#wndlft)
- [WNDWDTH](#wndwdth)
- [BASL/BASH](#basl-bash)
- [INVFLG](#invflg)
- [VFACTV](#vfactv)

### GetNum (\$FFA7)

**Description:**

This routine scans the Monitor’s input buffer, starting at the offset
specified in the Y register. It decodes ASCII codes representing
hexadecimal numbers into their corresponding hexadecimal values and
stores them in the zero-page locations [A2L/A2H](#a2l-a2h) (\$3E/\$3F).
The scanning continues until it encounters an ASCII code that is not a
valid hexadecimal digit. `GetNum` relies on [NxtChr
(\$FFAD)](#nxtchr-ffad) to test, parse, and decode these hexadecimal
numbers.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: The offset into the input buffer (\$0200) where scanning for
    hexadecimal digits should begin.
- **Memory:**
  - Input buffer (\$0200): The start of the Monitor’s input buffer.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: The offset into the input buffer for the next character after the
    decoded hexadecimal number.
  - P: Undefined.
- **Memory:**
  - [A2L/A2H](#a2l-a2h) (addresses \$3E-\$3F): Stores the hexadecimal
    number decoded from the input buffer.

**Side Effects:**

- Reads and processes characters from the Monitor’s input buffer.
- Converts ASCII hexadecimal digits to their numerical equivalent.
- Stores the result in [A2L/A2H](#a2l-a2h).
- Updates the Y register to point to the next character in the input
  buffer.

**See also:**

- [NxtChr (\$FFAD)](#nxtchr-ffad)
- [A2L/A2H](#a2l-a2h)

### Go (\$FEB6)

**Description:**

This routine facilitates a jump to a user-specified subroutine address,
after optionally updating the program counter (PC) and restoring certain
meta-registers. It first calls the internal helper routine
[A1PC](#a1pc-fe75), which conditionally copies the 16-bit address from
[A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch) (Program Counter Low/High)
based on the initial value of the X register. Following this, it calls
the [Restore](#restore-ff3f) routine to set the A, X, Y, and P registers
from saved values in [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), and
[STATUS](#status) respectively. Finally, it performs an indirect jump to
the address contained in [PCL/PCH](#pcl-pch).

**Input:**

- **Registers:**
  - X: This register is an input to [A1PC](#a1pc-fe75). If X is non-zero
    (typically \$01), [A1PC](#a1pc-fe75) will copy the address from
    [A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch).
  - A: N/A
  - Y: N/A
- **Memory:**
  - [A1L/A1H](#a1l-a1h) (address \$3C-\$3D): The 16-bit address that may
    be copied to the program counter if [A1PC](#a1pc-fe75) is triggered.
  - [PCL/PCH](#pcl-pch) (address \$3A-\$3B): The 16-bit address of the
    user subroutine to jump to. This is read as the final jump target.
  - [A5H](#a5h) (address \$45): The value to which the A register will
    be set by [Restore](#restore-ff3f).
  - [XREG](#xreg) (address \$46): The value to which the X register will
    be set by [Restore](#restore-ff3f).
  - [YREG](#yreg) (address \$47): The value to which the Y register will
    be set by [Restore](#restore-ff3f).
  - [STATUS](#status) (address \$48): The value to which the P register
    (processor status flags) will be set by [Restore](#restore-ff3f).

**Output:**

- **Registers:**
  - A: Loaded with the value from [A5H](#a5h) by
    [Restore](#restore-ff3f).
  - X: Loaded with the value from [XREG](#xreg) by
    [Restore](#restore-ff3f).
  - Y: Loaded with the value from [YREG](#yreg) by
    [Restore](#restore-ff3f).
  - P: Loaded with the value from [STATUS](#status) by
    [Restore](#restore-ff3f).
- **Memory:**
  - [PCL/PCH](#pcl-pch): May be updated by [A1PC](#a1pc-fe75) if X was
    non-zero on entry. Program execution continues at this address.

**Side Effects:**

- Calls [A1PC](#a1pc-fe75) to conditionally set the program counter
  ([PCL/PCH](#pcl-pch)).
- Calls [Restore](#restore-ff3f) to restore CPU registers (A, X, Y, P)
  from predefined memory locations.
- Transfers program control to the address specified by
  [PCL/PCH](#pcl-pch).

**See also:**

- [A1PC](#a1pc-fe75)
- [Restore](#restore-ff3f)
- [A1L/A1H](#a1l-a1h)
- [PCL/PCH](#pcl-pch)
- [A5H](#a5h)
- [XREG](#xreg)
- [YREG](#yreg)
- [STATUS](#status)

### HLine (\$F819)

**Description:**

This routine draws a horizontal line of blocks on the Lo-Res graphics
display. It does this by repeatedly calling [Plot](#plot-f800) (or
[Plot1](#plot1-f80e)) for each block, starting from the given initial
horizontal (Y) and vertical (A) coordinates, and continues until the
horizontal position reaches the value specified in [H2](#h2). The color
of the line is determined by the value in [COLOR](#color).

**Input:**

- **Registers:**
  - A: Vertical position of the blocks to plot (\$00-\$2F). This value
    is passed to [Plot](#plot-f800).
  - X: N/A (preserved by this routine).
  - Y: Initial horizontal position of the leftmost block (\$00-\$27).
    This value is passed to [Plot](#plot-f800) and then incremented
    internally.
- **Memory:**
  - [H2](#h2) (address \$2C): Contains the target horizontal position
    (X-coordinate) for the end of the line.
  - [COLOR](#color) (address \$30): The current color value used for
    plotting, which is read by [Plot](#plot-f800).
  - [GBASL/GBASH](#gbasl-gbash) (address \$26-\$27): The current
    low-resolution graphics base address, which is read and modified by
    [GBasCalc](#gbascalc-f847), a subroutine called by
    [Plot](#plot-f800).

**Output:**

- **Registers:**
  - A: Undefined (modified by internal calculations within
    [Plot](#plot-f800)).
  - X: Preserved.
  - Y: Modified (incremented during the line drawing loop).
  - P: Flags affected by internal operations, including those of
    [Plot](#plot-f800).
- **Memory:**
  - Lo-Res graphics display memory is modified to draw the line.
  - [GBASL/GBASH](#gbasl-gbash): Updated by calls to
    [GBasCalc](#gbascalc-f847) from [Plot](#plot-f800).

**Side Effects:**

- Calls [Plot](#plot-f800) and [Plot1](#plot1-f80e) repeatedly to draw
  the horizontal line.
- Modifies the Lo-Res graphics display memory.
- The Y register is incremented during the line drawing process.

**See also:**

- [Plot](#plot-f800)
- [Plot1](#plot1-f80e)
- [SetCol](#setcol-f864)
- [H2](#h2)
- [COLOR](#color)
- [GBasCalc](#gbascalc-f847)
- [GBASL/GBASH](#gbasl-gbash)

### HOMECUR (\$CDA5) (Internal)

**Description:**

This is an **internal helper routine** used by [Home](#home-fc58) to
move the cursor to the upper-left corner of the current text window. It
achieves this by calling [CLRCH](#clrch-fee9) to set the horizontal
cursor indices, then setting the vertical cursor to the top of the
window as defined by [WNDTOP](#wndtop), and finally jumping to
[NEWVTABZ](#newvtabz-fc88) to set the screen base address and update the
vertical cursor’s zero-page location ([OURCV](#ourcv)).

**Input:**

- **Registers:** N/A
- **Memory:**
  - [WNDTOP](#wndtop) (address \$22): The top edge of the text window.
    Its value is read to set the vertical cursor position.

**Output:**

- **Registers:**
  - A: Modified by internal operations.
  - X: Modified by internal operations.
  - Y: Modified by internal operations (due to calls to
    [CLRCH](#clrch-fee9)).
  - P: Flags affected by internal operations.
- **Memory:**
  - [CH](#ch) (address \$24): Set to \$00 by [CLRCH](#clrch-fee9) (if in
    80-column mode) or a value derived from the input Y register.
  - [OLDCH](#oldch) (address \$047B): Set by [CLRCH](#clrch-fee9).
  - [OURCH](#ourch) (address \$057B): Set by [CLRCH](#clrch-fee9).
  - [CV](#cv) (address \$25): Set to the value of [WNDTOP](#wndtop).
  - [OURCV](#ourcv) (address \$05FB): Updated by
    [NEWVTABZ](#newvtabz-fc88).
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated by
    [NEWVTABZ](#newvtabz-fc88).
  - Screen memory: Potentially affected by subroutines that draw the
    cursor.

**Side Effects:**

- Calls [CLRCH](#clrch-fee9) to handle horizontal cursor positioning.
- Sets [CV](#cv) to the value of [WNDTOP](#wndtop).
- Transfers control to [NEWVTABZ](#newvtabz-fc88).
- Accesses [WNDTOP](#wndtop).

**See also:**

- [Home](#home-fc58)
- [CLRCH](#clrch-fee9)
- [NEWVTABZ](#newvtabz-fc88)
- [WNDTOP](#wndtop)
- [CV](#cv)
- [OURCV](#ourcv)

### HeadR (\$FCC9)

**Description:**

`HeadR ($FCC9)` in the Apple IIc ROM is an obsolete entry point that
consists solely of a return from subroutine (`RTS`) instruction. While
earlier ROM versions might have contained different or more extensive
code at this address, the IIc implementation makes it a non-functional
entry point that immediately returns control to the caller. The entry
point at this address is documented as referring to a “usable gap” of
memory of `0x0043` bytes.

**Input:**

- **Registers:** N/A
- **Memory:** N/A

**Output:**

- **Registers:**
  - A: Preserved.
  - X: Preserved.
  - Y: Preserved.
  - P: Preserved.
- **Memory:** N/A

**Side Effects:** None (other than returning to the caller).

**See also:** None.

### Home (\$FC58)

**Description:**

This routine effectively moves the text cursor to the upper-left corner
of the current text window and then clears the text display from that
position to the end of the current page. In the Apple IIc ROM, it
achieves this by first calling the internal helper routine
[HOMECUR](#homecur-cda5) to position the cursor, and then flowing into
the [CLREOP2](#clreop2-fc44) routine to clear the screen.

**Input:**

- **Registers:** N/A (all register inputs are handled by the called
  subroutines).
- **Memory:**
  - [WNDTOP](#wndtop) (address \$22): The top edge of the text window,
    read by [HOMECUR](#homecur-cda5).
  - [OURCH](#ourch) (address \$057B): Read by [CLRCH](#clrch-fee9),
    which is called by [HOMECUR](#homecur-cda5).
  - `RD80VID ($C01F)`: A soft switch read by [GETCUR2](#getcur2-ccad)
    (called by [CLRCH](#clrch-fee9)) and [VTABZ](#vtabz-fc24) (branched
    to by [NEWVTABZ](#newvtabz-fc88), called by
    [HOMECUR](#homecur-cda5)).
  - [WNDLFT](#wndlft) (address \$20): The left edge of the text window,
    read by [VTABZ](#vtabz-fc24).
  - [CV](#cv) (address \$25): The current vertical cursor position, read
    by [VTABZ](#vtabz-fc24) and [CLREOP2](#clreop2-fc44).
  - [WNDBTM](#wndbtm) (address \$23): The bottom edge of the text
    window, read by [CLREOP2](#clreop2-fc44).

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - [CV](#cv) (address \$25): Set to the value of [WNDTOP](#wndtop) by
    [HOMECUR](#homecur-cda5), and further modified by
    [CLREOP2](#clreop2-fc44).
  - [CH](#ch) (address \$24): Set to \$00 (if in 80-column mode) or a
    value derived from the input Y register to [GETCUR2](#getcur2-ccad).
  - [OLDCH](#oldch) (address \$047B): Set by [GETCUR2](#getcur2-ccad).
  - [OURCH](#ourch) (address \$057B): Set by [GETCUR2](#getcur2-ccad).
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated by
    [VTABZ](#vtabz-fc24) and [BASCALC](#bascalc-fbc1).
  - Screen memory: Text within the active window is cleared from the
    cursor position to the end of the page.

**Side Effects:**

- Calls [HOMECUR](#homecur-cda5) to move the cursor to the upper-left of
  the text window. This involves a chain of internal calls to
  [CLRCH](#clrch-fee9), [GETCUR2](#getcur2-ccad), and
  [NEWVTABZ](#newvtabz-fc88), which branches to [VTABZ](#vtabz-fc24),
  and finally calls [BasCalc](#bascalc-fbc1).
- Flows into [CLREOP2](#clreop2-fc44) to clear the screen from the new
  cursor position to the bottom of the window.
- Accesses the `RD80VID` soft switch.

**See also:**

- [HOMECUR](#homecur-cda5)
- [CLREOP2](#clreop2-fc44)
- [WNDTOP](#wndtop)
- [WNDLFT](#wndlft)
- [CV](#cv)
- [CH](#ch)
- [OLDCH](#oldch)
- [OURCH](#ourch)
- [BASL/BASH](#basl-bash)
- `RD80VID` (soft switch)

### IDRoutine (\$FE1F)

**Description:**

This routine is part of the documented Apple system identification
interface for distinguishing 8-bit Apple II systems from 16-bit systems
(Apple IIgs). On 8-bit Apple II family computers (Apple II through Apple
IIc), this location contains a single return from subroutine (`RTS`)
instruction. It immediately returns control to the caller without
performing any operations or modifying any registers or memory
locations.

**References:**

- Apple II Miscellaneous Technical Note \#7: *Apple II Family
  Identification* (https://prodos8.com/docs/technote/misc/07/)
- Apple II Miscellaneous Technical Note \#2: *Apple II Family
  Identification Routines 2.2*
  (https://prodos8.com/docs/technote/misc/02/)

**Calling Convention:**

Software should call IDRoutine with the Carry flag set:

    SEC         ; Set carry flag
    JSR $FE1F   ; Call IDRoutine
    BCS IS_8BIT ; If carry still set, 8-bit Apple II
    BCC IS_16BIT; If carry clear, 16-bit system (out of scope)

**Behavior on 8-bit Apple II:**

Since the 8-bit implementation is simply `RTS`, code calling IDRoutine
with Carry set will have the Carry flag remain set upon return (no
operation occurred to modify it), correctly indicating that the system
is an 8-bit Apple II variant.

**Behavior on 16-bit Systems:**

The Apple IIgs (out of scope for this specification) implements actual
identification logic at this address that clears the Carry flag and
returns system information in registers. This difference allows software
to detect the system type at runtime.

**Input:**

- **Registers:**
  - A: Undefined (may contain any value)
  - X: Undefined (may contain any value)
  - Y: Undefined (may contain any value)
  - **C (Carry flag): Must be set (=1) by the caller**
- **Memory:** N/A

**Output:**

- **Registers (8-bit Apple II):**
  - A: Unchanged (preserved)
  - X: Unchanged (preserved)
  - Y: Unchanged (preserved)
  - **C (Carry flag): Set (=1) — indicates 8-bit Apple II system**
- **Registers (16-bit systems, out of scope):**
  - **C (Carry flag): Clear (=0) — indicates 16-bit system (Apple
    IIgs)**
  - Register contents not documented (16-bit systems out of scope)
- **Memory:** No memory locations are modified.

**Side Effects:** None on 8-bit Apple II (instruction is just `RTS`).

**See also:**

- [Hardware Variants and
  Identification](#hardware-variants-and-identification) - Complete
  hardware detection methods
- [Hardware Identification Bytes](#identification-byte-locations) - ROM
  identification byte table

### INPRT (\$FE8D) (Internal)

**Description:**

This is an **internal helper routine** that is implicitly called by
[InPort](#inport-fe8b) and possibly other routines. Its primary function
is to initialize the X register with the address of [KSWL](#kswl-kswh)
and the Y register with the low byte of the address of
[KeyIn](#keyin-fd1b). It then unconditionally branches to the internal
`IOPRT ($FE9B)` routine. The actual logic for setting up the input hooks
is handled within `IOPRT`, which uses the value previously stored in
[A2L](#a2l-a2h) by [InPort](#inport-fe8b).

**Input:**

- **Registers:** N/A (registers X and Y are initialized internally).
- **Memory:**
  - [A2L](#a2l-a2h) (address \$3E): Contains the value (port number)
    that will be used by the subsequent `IOPRT` routine to determine
    which input routine to set.

**Output:**

- **Registers:**
  - A: Modified by `IOPRT`.
  - X: Initialized to `#<KSWL` (the low byte of the address of
    [KSWL](#kswl-kswh)), then modified by `IOPRT`.
  - Y: Initialized to `#<KEYIN` (the low byte of the address of
    [KeyIn](#keyin-fd1b)), then modified by `IOPRT`.
  - P: Flags affected.
- **Memory:**
  - [KSWL/KSWH](#kswl-kswh) (address \$38-\$39): Updated by the
    `IOPRT ($FE9B)` routine.

**Side Effects:**

- Initializes X and Y registers with pointer-related values.
- Transfers control to the internal `IOPRT ($FE9B)` routine.
- The system’s standard input hooks ([KSWL/KSWH](#kswl-kswh)) are
  modified by `IOPRT`.

**See also:**

- [InPort](#inport-fe8b)
- `IOPRT ($FE9B)` (internal routine)
- [KSWL/KSWH](#kswl-kswh)
- [KeyIn](#keyin-fd1b)
- [A2L](#a2l-a2h)

### IOPRT (\$FE9B) (Internal)

**Description:**

This is an **internal helper routine** responsible for setting the
system’s input/output vectors ([KSWL/KSWH](#kswl-kswh) or
[CSWL/CSWH](#cswl-cswh)). It is called by routines like
[INPRT](#inprt-fe8d) (for input) and [OutPort](#outport-fe95) (for
output). The behavior of this routine has evolved across ROM versions.

**In earlier ROMs (Apple II/IIe unenhanced):** This routine reads a
“port number” from [A2L](#a2l-a2h), masks it, and then either loads the
address of [COUT1](#cout1-fdf0) (if [A2L](#a2l-a2h) indicates slot 0 and
Y register, which is assumed to contain `<KEYIN` from
[INPRT](#inprt-fe8d), matches) or constructs an I/O address using
`IOADR` and the slot number. This address is then stored in
[LOC0](#loc0) and [LOC1](#loc1), which are subsequently used to update
the relevant I/O hooks.

**In the Apple IIc ROM:** This routine (identified by its entry point
address and functionality) also reads [A2L](#a2l-a2h) as its primary
input. Its logic is more complex, involving conditional branches based
on the value in [A2L](#a2l-a2h) (checking if it’s slot 0) and the Y
register (checking for a default routine like `KEYIN`). It may branch to
a routine that handles PR#0 functionality ([CPRT0
(\$FEC2)](#cprt0-fec2)) or to a routine that sets the I/O vectors
(internal routines `IOPRT1 ($FEEE)` and `IOPRT2 ($FEAB)`, which are
parts of the same flow). Ultimately, it also aims to update
[LOC0](#loc0) and [LOC1](#loc1) with the address of the selected
input/output routine.

**Input:**

- **Registers:**
  - X: Expected to contain `#<KSWL` (for input hooks) or `#<CSWL` (for
    output hooks).
  - Y: Expected to contain the low byte of the default routine address
    (e.g., `#<KEYIN` for input, `#<COUT1` for output).
  - A: N/A (loaded internally from memory).
- **Memory:**
  - [A2L](#a2l-a2h) (address \$3E): The “port number” or configuration
    value (0 for default, or slot number 1-7).
  - [KSWL/KSWH](#kswl-kswh) (address \$38-\$39): The 16-bit address of
    the current input routine. Modified if input hooks are being set.
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): The 16-bit address of
    the current output routine. Modified if output hooks are being set.

**Output:**

- **Registers:**
  - A: Modified by various `lda` and `ora` operations.
  - X: Preserved on return (after `IOPRT2`).
  - Y: Preserved on return (after `IOPRT2`).
  - P: Flags affected.
- **Memory:**
  - [LOC0](#loc0) (address \$00) and [LOC1](#loc1) (address \$01):
    Temporarily used to store the high byte of the target I/O routine
    address.
  - [KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh): Updated with the
    address of the selected input/output routine.

**Side Effects:**

- Determines the target input/output routine address based on
  [A2L](#a2l-a2h) and Y.
- Conditionally branches to [CPRT0 (\$FEC2)](#cprt0-fec2) (in Apple IIc)
  for specific handling related to PR#0.
- Updates either [KSWL/KSWH](#kswl-kswh) or [CSWL/CSWH](#cswl-cswh)
  (depending on whether it was called by [INPRT](#inprt-fe8d) or
  [OutPort](#outport-fe95)) with the address of the selected I/O
  routine.

**See also:**

- [INPRT](#inprt-fe8d)
- [OutPort](#outport-fe95)
- [A2L](#a2l-a2h)
- [KSWL/KSWH](#kswl-kswh)
- [CSWL/CSWH](#cswl-cswh)
- [KeyIn](#keyin-fd1b)
- [COUT1](#cout1-fdf0)
- [CPRT0 (\$FEC2)](#cprt0-fec2) (internal routine, Apple IIc specific
  behavior)
- `IOADR`
- [LOC0](#loc0), [LOC1](#loc1)
- `IOPRT1 ($FEEE)` (internal routine)
- `IOPRT2 ($FEAB)` (internal routine)

### IORTS (\$FF58)

**Description:**

This address contains an `RTS` instruction. On Apple II systems with
expansion slots, peripheral cards can use this to determine their slot.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Preserved
- **Memory:** None.

**Side Effects:**

- Returns from a subroutine. Its primary purpose as an entry point is
  for peripheral card slot identification.

**See also:** None.

### IRQ (\$FA40)

**Description:**

This routine serves as a jump to the system’s interrupt-handling
routines for IRQs (Interrupt ReQuests) and BRKs (Break instructions).
After the application’s installed interrupt routines complete and
perform an RTI (Return from Interrupt), all 6502 registers are restored
to their pre-interrupt state. Notably, unlike in earlier Apple II
models, location `$45` is specifically preserved, ensuring its value is
not inadvertently destroyed during interrupt processing.

**Note (Variant Difference):** In the Original Apple II ROM (OrigF8ROM),
the IRQ handler is located at \$FA86 rather than \$FA40. The Apple II+,
IIe, and IIc ROMs standardized on the \$FA40 address documented here.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A (The state of the system and registers are captured by
  the interrupt mechanism upon entry).

**Output:**

- **Registers:**
  - A: Preserved.
  - X: Preserved.
  - Y: Preserved.
  - P: Preserved.
- **Memory:** N/A.

**Side Effects:**

- Transfers control to interrupt-handling routines.
- Restores all 6502 registers after an RTI.
- Preserves the content of memory location `$45`.

**See also:**

- [User IRQ Hook](#user-irq-hook)

### InPort (\$FE8B)

**Description:**

This routine stores the value from the A register into the zero-page
location [A2L](#a2l-a2h). It then implicitly transfers control to the
internal `INPRT ($FE8D)` routine. The `INPRT` routine is responsible for
setting the system’s input hooks ([KSWL/KSWH](#kswl-kswh)) based on the
value found in [A2L](#a2l-a2h), effectively allowing the input source to
be directed to a specified port.

**Input:**

- **Registers:**
  - A: Contains the value (typically a port number, \$00 for keyboard)
    to be used for setting the input hooks.
  - X: N/A
  - Y: N/A
- **Memory:** N/A (the routine primarily acts on its A register input).

**Output:**

- **Registers:**
  - A: Preserved (after its value is stored, but later modified by
    subsequent calls from `INPRT`).
  - X: Modified by subsequent calls from `INPRT`.
  - Y: Modified by subsequent calls from `INPRT`.
  - P: Flags affected.
- **Memory:**
  - [A2L](#a2l-a2h) (address \$3E): Stored with the value from the A
    register.
  - [KSWL/KSWH](#kswl-kswh) (address \$38-\$39): Updated by the
    `INPRT ($FE8D)` routine.

**Side Effects:**

- Stores the input value from A to [A2L](#a2l-a2h).
- Transfers control to the internal `INPRT ($FE8D)` routine, which then
  modifies the system’s standard input hooks.

**See also:**

- `INPRT ($FE8D)` (internal routine)
- [KSWL/KSWH](#kswl-kswh)
- [A2L](#a2l-a2h)
- [SetKbd](#setkbd-fe89)

### Init (\$FB2F)

**Description:**

This routine initializes the system by clearing the [STATUS](#status)
zero-page location (often used for debugging). It then proceeds to read
the `LORES ($C056)` soft switch and the `TXTPAGE1 ($C054)` soft switch,
preparing for video mode configuration. Control then implicitly
transfers to the [SetTxt](#settxt-fb39) routine, which handles further
text screen initialization, including setting the text mode and defining
the full-screen window.

**Input:**

- **Registers:** N/A
- **Memory:**
  - `LORES ($C056)`: Read-only soft switch that determines if the system
    is in low-resolution graphics mode.
  - `TXTPAGE1 ($C054)`: Read-only soft switch that controls the
    activation of text page 1.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address for the text
    line ([BASL](#basl-bash)).
  - X: Undefined.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - [STATUS](#status) (address \$48): Set to \$00.
  - Memory locations modified by [SetTxt](#settxt-fb39) (e.g.,
    [WNDTOP](#wndtop), [WNDBTM](#wndbtm), [WNDWDTH](#wndwdth),
    [BASL/BASH](#basl-bash)).
  - Display settings are configured for text Page 1 and full-screen text
    window mode (through `SetTxt`).

**Side Effects:**

- Clears the [STATUS](#status) zero-page location.
- Reads the `LORES` and `TXTPAGE1` soft switches.
- Implicitly transfers control to [SetTxt](#settxt-fb39) for text screen
  initialization.
- Configures the screen for full window display and text Page 1 (via
  `SetTxt`).

**See also:**

- [SetTxt](#settxt-fb39)
- [STATUS](#status)
- `LORES` (soft switch)
- `TXTPAGE1` (soft switch)

### InsDs1_2 (\$F88C)

**Description:**

This routine loads the A register with an opcode from the memory
location pointed to by [PCL/PCH](#pcl-pch) (Program Counter Low/High),
indexed by the X register. It then falls into the [InsDs2](#insds2-f88e)
routine, which is responsible for determining the instruction’s length
and addressing mode.

**Input:**

- **Registers:**
  - A: Undefined (loaded internally).
  - X: The offset (relative to [PCL/PCH](#pcl-pch)) used to fetch the
    opcode from memory.
  - Y: Undefined.
- **Memory:**
  - [PCL/PCH](#pcl-pch) (address \$3A-\$3B): The Program Counter
    Low/High, providing the base address from which the opcode is
    fetched.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Contains \$00.
  - P: Undefined.
- **Memory:**
  - [LENGTH](#length) (address \$2F): Contains the calculated
    instruction length (minus one byte) for 6502 instructions, or \$00
    if not a recognized 6502 opcode (as set by [InsDs2](#insds2-f88e)).

**Side Effects:**

- Loads the A register with an opcode from memory.
- Transfers control to [InsDs2](#insds2-f88e).
- Calculates the length of a 6502 instruction and stores it in
  [LENGTH](#length) (via [InsDs2](#insds2-f88e)).

**See also:**

- [InsDs2](#insds2-f88e)
- [PCL/PCH](#pcl-pch)
- [LENGTH](#length)

### InsDs2 (\$F88E)

**Description:**

This routine determines the length of a 6502 instruction whose opcode is
provided in the A register. It returns the calculated instruction length
(minus one byte) for recognized 6502 opcodes. For any non-6502 opcode,
it returns a length of \$00. Notably, for compatibility reasons, the
`BRK` opcode also returns a length of \$00, not \$01 as might otherwise
be expected.

**Input:**

- **Registers:**
  - A: The opcode of the 6502 instruction for which the length is to be
    determined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Contains \$00.
  - P: Undefined.
- **Memory:**
  - [LENGTH](#length) (address \$2F): Contains the calculated
    instruction length (minus one byte) for 6502 instructions, or \$00
    if not a recognized 6502 opcode.

**Side Effects:**

- Calculates the length of a 6502 instruction and stores it in
  [LENGTH](#length).

**See also:**

- [InsDs1_2](#insds1_2-f88c)
- [LENGTH](#length)

### InstDsp (\$F8D0)

**Description:**

This routine disassembles and displays a single 6502 instruction. The
instruction to be disassembled is pointed to by the 16-bit address
stored in [PCL](#pcl-pch) and [PCH](#pcl-pch) (Program Counter Low and
High bytes) in bank \$00. The disassembled output is sent to the
standard output device (e.g., the screen).

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:**
  - [PCL](#pcl-pch) (address \$3A): Low byte of the program counter,
    pointing to the instruction to disassemble.
  - [PCH](#pcl-pch) (address \$3B): High byte of the program counter,
    pointing to the instruction to disassemble.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - Standard output device (e.g., screen) displays the disassembled
    instruction.

**Side Effects:**

- Outputs the disassembled instruction to the standard output device.

**See also:**

- [PCL](#pcl-pch)
- [PCH](#pcl-pch)
- [COUT](#cout-fded) (for outputting characters)
- [InsDs1_2](#insds1_2-f88c)
- [InsDs2](#insds2-f88e)

### KbdWait (\$FB88)

**Description:**

This routine pauses execution until a key is pressed. If the key is not
Control-C, the keyboard strobe is cleared, and the character is passed
to [VidOut](#vidout-fbfd). If Control-C is detected, clearing is
bypassed, and control transfers directly to [VidOut](#vidout-fbfd).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the ASCII code of the key pressed.
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by internal operations.
- **Memory:**
  - The keyboard strobe is cleared if the key pressed is not Control-C.

**Side Effects:**

- Pauses program execution until a key is pressed.
- Conditionally clears the keyboard strobe.
- Transfers control to [VidOut](#vidout-fbfd).

**See also:**

- [VidOut](#vidout-fbfd)
- [COUT](#cout-fded)
- [KeyIn](#keyin-fd1b)

### KEYIN (\$FD1B)

**Description:**

This routine is the primary keyboard input subroutine. It reads a
keypress directly from the Apple keyboard. Before returning, it
randomizes the random-number seed stored in [RNDL/RNDH](#rndl-rndh)
(\$4E/\$4F). When a key is pressed, it removes the cursor from the
display and returns the ASCII code of the pressed key in the A register.

**Input:**

- **Registers:**
  - A: The character currently below the cursor (this value is used
    internally for restoring the display after cursor removal).
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A.

**Output:**

- **Registers:**
  - A: The ASCII code of the key pressed.
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - [RNDL/RNDH](#rndl-rndh) (address \$4E-\$4F): Updated with a new
    random-number seed.
  - Screen: Cursor removed from display.

**Side Effects:**

- Reads a keypress from the keyboard.
- Randomizes the [RNDL/RNDH](#rndl-rndh) seed.
- Removes the cursor from the display.

**See also:**

- [RNDL/RNDH](#rndl-rndh)
- [RDKEY (\$FDC6)](#rdkey-fd0c)
- [FD10 (\$FD10)](#fd10-fd10)

### KeyIn0 (\$FD18)

**Description:**

This routine is an alternative entry point for standard keyboard input.
It unconditionally jumps to the routine whose 16-bit address is in
[KSWL/KSWH](#kswl-kswh) (typically [KeyIn](#keyin-fd1b) or `C3KeyIn`).
Functionally identical to [FD10](#fd10-fd10).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected
- **Memory:**
  - Modifications depend on the routine to which control is passed.

**Side Effects:**

- Transfers control to the input routine specified by
  [KSWL/KSWH](#kswl-kswh).
- Side effects are those of the called routine.

**See also:**

- [KeyIn](#keyin-fd1b)
- [FD10](#fd10-fd10)
- [C3KeyIn](#c3keyin)
- [KSWL/KSWH](#kswl-kswh)

### LF (\$FC66)

**Description:**

This routine performs a line feed. It increments [CV](#cv). If [CV](#cv)
exceeds [WNDBTM](#wndbtm), it calls [Scroll](#scroll-fc70) to scroll the
window up, placing the cursor on the bottom line. It also calls
[BasCalc](#bascalc-fbc1) to update [BASL/BASH](#basl-bash) for the new
line.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CV](#cv) (address \$25): Vertical position of cursor.
  - [WNDBTM](#wndbtm) (address \$23): Lower boundary of the text window.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Flags affected by internal operations.
- **Memory:**
  - [CV](#cv): Incremented vertical cursor position, or reset to
    [WNDBTM](#wndbtm) if scrolling occurred.
  - [BASL/BASH](#basl-bash): Updated with the base memory address for
    the new text line.
- **Memory:**
  - Text memory may be scrolled upwards.

**Side Effects:**

- Moves the vertical cursor.
- May cause scrolling of the text window.
- Updates [CV](#cv) and [BASL/BASH](#basl-bash).

**See also:**

- [Scroll](#scroll-fc70)
- [BasCalc](#bascalc-fbc1)
- [CV](#cv)
- [WNDBTM](#wndbtm)
- [BASL/BASH](#basl-bash)

### List (\$FE5E)

**Description:**

This routine disassembles and prints 20 6502 instructions to standard
output, starting from the address in [A1L/A1H](#a1l-a1h). After
processing, [A1L/A1H](#a1l-a1h) is updated to point to the instruction
after the last disassembled one. It calls internal routines like
[InstDsp](#instdsp-f8d0).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - Disassembled instructions are printed to standard output.
  - [A1L/A1H](#a1l-a1h): Updated to point to the instruction after the
    last disassembled instruction.

**Side Effects:**

- Prints disassembled instructions.
- Modifies the [A1L/A1H](#a1l-a1h) pointer.

**See also:**

- [InstDsp](#instdsp-f8d0)
- [A1L/A1H](#a1l-a1h)

### Mon (\$FF65)

**Description:**

This routine prepares the processor to enter the System Monitor. It
clears the processor’s decimal mode flag, activates the speaker
(generating a sound), and transfers control to the [MonZ](#monz-ff69)
routine.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Decimal mode flag is cleared.
- **Memory:** None.

**Side Effects:**

- Clears the processor’s decimal mode flag.
- Activates the system speaker.
- Transfers control to [MonZ](#monz-ff69).

**See also:**

- [MonZ](#monz-ff69)

### MonZ (\$FF69)

**Description:**

This routine is the primary entry point for the System Monitor, often
called via `CALL -151` in Applesoft BASIC. It calls
[GetLnZ](#getlnz-fd67) to display the asterisk (`*`) prompt and read
input, then invokes [ZMode](#zmode-ffc7) to clear the Monitor mode flag,
finally passing control to the Monitor’s command-line parser.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected by internal operations.
- **Memory:**
  - [INBUF](#inbuf): Contains the user’s input line.
  - [MODE](#mode): Cleared to `$00` by [ZMode](#zmode-ffc7).

**Side Effects:**

- Displays a Monitor prompt.
- Reads user command input.
- Clears the internal Monitor mode flag.
- Transfers control to the Monitor’s command-line parser.

**See also:**

- [GetLnZ](#getlnz-fd67)
- [ZMode](#zmode-ffc7)
- [INBUF](#inbuf)
- [PROMPT](#prompt)
- [MODE](#mode)

### MonZ4 (\$FF70)

**Description:**

This routine is an alternative entry point to the System Monitor,
similar to [MonZ](#monz-ff69). `MonZ4` does not automatically call
[GetLnZ](#getlnz-fd67) or [ZMode](#zmode-ffc7). Programs using `MonZ4`
must first read input and clear the Monitor mode flag before
transferring control.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected by Monitor operations.
- **Memory:**
  - Memory modifications depend on the commands parsed and executed by
    the Monitor.

**Side Effects:**

- Enters the System Monitor, bypassing initial prompt display and mode
  clearing.
- Processes commands already present in the Monitor’s input buffer.

**See also:**

- [MonZ](#monz-ff69)
- [GetLnZ](#getlnz-fd67)
- [ZMode](#zmode-ffc7)
- [INBUF](#inbuf)
- [MODE](#mode)

### Move (\$FE2C)

**Description:**

This routine copies a block of memory from a source ([A1L/A1H](#a1l-a1h)
to [A2L/A2H](#a2l-a2h)) to a destination ([A4L/A4H](#a4l-a4h))
byte-by-byte. It calls [NxtA4](#nxta4-fcb4) to increment pointers and
compare [A1L/A1H](#a1l-a1h) with [A2L/A2H](#a2l-a2h). Copying continues
as long as [A1L/A1H](#a1l-a1h) is less than or equal to
[A2L/A2H](#a2l-a2h).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: An offset for indexed addressing (preserved across main loop
    iterations, but modified by [NxtA4](#nxta4-fcb4)).
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined (modified by [NxtA4](#nxta4-fcb4)).
  - P: Flags affected by internal comparisons.
- **Memory:**
  - The destination memory block (starting at [A4L/A4H](#a4l-a4h))
    contains the copied data.
  - [A1L/A1H](#a1l-a1h) and [A4L/A4H](#a4l-a4h) are updated
    (incremented).

**Side Effects:**

- Copies data between specified memory ranges.
- Updates [A1L/A1H](#a1l-a1h) and [A4L/A4H](#a4l-a4h) memory locations.
- Affects CPU flags.

**See also:**

- [NxtA4](#nxta4-fcb4)
- [Verify](#verify-fe36)
- [A1L/A1H](#a1l-a1h)
- [A2L/A2H](#a2l-a2h)
- [A4L/A4H](#a4l-a4h)

### NEWVTABZ (\$FC88) (Internal)

**Description:**

This is an **internal helper routine** called by routines like
[HOMECUR](#homecur-cda5) and [LF](#lf-fc66). Its primary function is to
update the zero-page location [OURCV](#ourcv) with the current vertical
cursor position from [CV](#cv), and then to branch into the
[VTABZ](#vtabz-fc24) routine. [VTABZ](#vtabz-fc24) is responsible for
calculating and setting the base address of the current text line
([BASL/BASH](#basl-bash)).

**Input:**

- **Registers:** N/A
- **Memory:**
  - [CV](#cv) (address \$25): The current vertical cursor position,
    which is read and stored in [OURCV](#ourcv).

**Output:**

- **Registers:**
  - A: Modified by internal calls (specifically [VTABZ](#vtabz-fc24) and
    [BASCALC](#bascalc-fbc1)).
  - X: Modified by internal calls.
  - Y: Modified by internal calls.
  - P: Flags affected by internal operations.
- **Memory:**
  - [OURCV](#ourcv) (address \$05FB): Updated with the value from
    [CV](#cv).
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated by
    [VTABZ](#vtabz-fc24).

**Side Effects:**

- Updates [OURCV](#ourcv) with the current vertical cursor position.
- Transfers control to [VTABZ](#vtabz-fc24).

**See also:**

- [HOMECUR](#homecur-cda5)
- [LF](#lf-fc66)
- [VTABZ](#vtabz-fc24)
- [CV](#cv)
- [OURCV](#ourcv)
- [BASL/BASH](#basl-bash)

### NewBrk (\$FA47)

**Description:**

This routine stores the A register in [MACSTAT](#macstat), then pulls Y,
X, and A registers from the stack before transferring control to the
[Break](#break-fa4c) routine.

**Input:**

- **Registers:**
  - A: Current Accumulator value.
  - X: Current X-index register value.
  - Y: Current Y-index register value.
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the value pulled from the CPU stack.
  - X: Contains the value pulled from the CPU stack.
  - Y: Contains the value pulled from the CPU stack.
  - P: Undefined
- **Memory:**
  - [MACSTAT](#macstat): Contains the value of A register before
    [Break](#break-fa4c).
  - The CPU stack is modified.

**Side Effects:**

- Stores A register.
- Restores Y, X, and A from stack.
- Transfers control to [Break](#break-fa4c).

**See also:**

- [Break](#break-fa4c)
- [MACSTAT](#macstat)
- [User Break Hook](#user-break-hook)

### NxtA1 (\$FCBA)

**Description:**

This routine performs a 16-bit comparison of [A1L/A1H](#a1l-a1h) with
[A2L/A2H](#a2l-a2h), then increments [A1L/A1H](#a1l-a1h) by 1. `NxtAl`
is an alternate entry point to [NxtA4](#nxta4-fcb4); it does not
increment [A4L/A4H](#a4l-a4h), but is otherwise identical to
[NxtA4](#nxta4-fcb4).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [A1L/A1H](#a1l-a1h): Initial value of the 16-bit address that is
    compared and incremented.
  - [A2L/A2H](#a2l-a2h): The 16-bit address used for comparison with
    A1L/A1H.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags affected (reflects comparison: Carry set if
    [A1L/A1H](#a1l-a1h) \> [A2L/A2H](#a2l-a2h), Carry clear if \<, Zero
    set if =).
- **Memory:**
  - [A1L/A1H](#a1l-a1h) is incremented by 1.

**Side Effects:**

- Performs a 16-bit comparison and sets CPU flags.
- Increments [A1L/A1H](#a1l-a1h).

**See also:**

- [NxtA4](#nxta4-fcb4)
- [Move](#move-fe2c)
- [Verify](#verify-fe36)
- [A1L/A1H](#a1l-a1h)
- [A2L/A2H](#a2l-a2h)

### NxtA4 (\$FCB4)

**Description:**

This routine increments [A4L/A4H](#a4l-a4h) by 1, then calls
[NxtA1](#nxta1-fcba). [NxtA1](#nxta1-fcba) performs a 16-bit comparison
of [A1L/A1H](#a1l-a1h) with [A2L/A2H](#a2l-a2h) and increments
[A1L/A1H](#a1l-a1h) by 1. `NxtA4` is called repeatedly by
[Move](#move-fe2c) and [Verify](#verify-fe36) as long as
[A1L/A1H](#a1l-a1h) \<= [A2L/A2H](#a2l-a2h).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [A1L/A1H](#a1l-a1h): Initial value of the 16-bit address that is
    compared and incremented.
  - [A2L/A2H](#a2l-a2h): The 16-bit address used for comparison with
    A1L/A2H.
  - [A4L/A4H](#a4l-a4h): Initial value of the 16-bit address that is
    incremented.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Flags affected (reflects [NxtA1](#nxta1-fcba) comparison).
- **Memory:**
  - [A4L/A4H](#a4l-a4h) is incremented by 1.
  - [A1L/A1H](#a1l-a1h) is incremented by 1.

**Side Effects:**

- Increments memory pointers [A4L/A4H](#a4l-a4h) and
  [A1L/A1H](#a1l-a1h).
- Performs a comparison and sets CPU flags.

**See also:**

- [NxtA1](#nxta1-fcba)
- [Move](#move-fe2c)
- [Verify](#verify-fe36)
- [A1L/A1H](#a1l-a1h)
- [A2L/A2H](#a2l-a2h)
- [A4L/A4H](#a4l-a4h)

### NxtChr (\$FFAD)

**Description:**

This routine plays a crucial role in parsing hexadecimal input from the
Monitor’s input buffer. It tests each character (starting from the
offset in the Y register) to determine if it is an ASCII code for a
hexadecimal digit (0-9, A-F). If a valid hexadecimal character is found,
`NxtChr` preprocesses it (including converting lowercase to uppercase)
and then calls the [Dig (\$FF8A)](#dig-ff8a) routine to decode the ASCII
value into its corresponding hexadecimal number, which is stored in
[A2L/A2H](#a2l-a2h). `NxtChr` then continues to the next character in
the buffer.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: The offset into the input buffer (\$0200) for the character to
    test.
- **Memory:**
  - Input buffer (\$0200): The start of the Monitor’s input buffer.

**Output:**

- **Registers:**
  - A: Contains the ASCII character of the next non-hexadecimal digit
    encountered, or the current character if it was not a hexadecimal
    digit.
  - X: Undefined.
  - Y: The offset into the input buffer for the next character after the
    tested/decoded character.
  - P: Undefined.
- **Memory:**
  - [A2L/A2H](#a2l-a2h) (addresses \$3E-\$3F): Stores the hexadecimal
    number decoded from the ASCII character (set by [Dig
    (\$FF8A)](#dig-ff8a)).

**Side Effects:**

- Processes characters from the Monitor’s input buffer.
- Converts lowercase hexadecimal ASCII to uppercase.
- Calls [Dig (\$FF8A)](#dig-ff8a) to decode hexadecimal digits.
- Stores decoded hexadecimal numbers in [A2L/A2H](#a2l-a2h).
- Updates the Y register to point to the next character in the input
  buffer.

**See also:**

- [Dig (\$FF8A)](#dig-ff8a)
- [GetNum (\$FFA7)](#getnum-ffa7)
- [A2L/A2H](#a2l-a2h)

### NxtCol (\$F85F)

**Description:**

This routine modifies the current color for Lo-Res graphics plotting by
adding 3 to the value in the [COLOR](#color) zero-page location. Use
[SetCol](#setcol-f864) for direct color setting.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags affected (e.g., Carry flag if [COLOR](#color) overflows).
- **Memory:**
  - [COLOR](#color): The stored color value is incremented by 3.

**Side Effects:**

- Modifies [COLOR](#color).
- Changes the active plotting color.

**See also:**

- [SetCol](#setcol-f864)
- [COLOR](#color)

### OUTPRT (\$FE97) (Internal)

**Description:**

This is an **internal helper routine** that is implicitly called by
[OutPort](#outport-fe95) and possibly other routines. Its primary
function is to initialize the X register with the address of
[CSWL](#cswl-cswh) and the Y register with the low byte of the address
of [COut1](#cout1-fdf0). It then unconditionally falls through to the
internal `IOPRT ($FE9B)` routine. The actual logic for setting up the
output hooks is handled within `IOPRT`, which uses the value previously
stored in [A2L](#a2l-a2h) by [OutPort](#outport-fe95).

**Input:**

- **Registers:**
  - A: N/A (routine does not use A on entry)
  - X: N/A
  - Y: N/A
- **Memory:**
  - [A2L](#a2l-a2h): Should contain the port number (set by
    [OutPort](#outport-fe95)).

**Output:**

- **Registers:**
  - A: Undefined (modified by subsequent calls in `IOPRT`).
  - X: Set to the address of [CSWL](#cswl-cswh) (\$36).
  - Y: Set to the low byte of [COut1](#cout1-fdf0) address.
  - P: Flags affected.
- **Memory:**
  - [CSWL/CSWH](#cswl-cswh): Updated by the `IOPRT` routine based on the
    port number in [A2L](#a2l-a2h).

**Side Effects:**

- Initializes X and Y registers for use by `IOPRT`.
- Falls through to `IOPRT ($FE9B)` which sets the output character
  hooks.

**Notes:**

- This is an internal entry point not typically called directly by user
  programs.
- Part of the I/O redirection infrastructure used by the Monitor.

**See also:**

- [OutPort](#outport-fe95)
- [IOPRT](#ioprt-fe9b)
- [CSWL/CSWH](#cswl-cswh)
- [A2L](#a2l-a2h)
- [INPRT](#inprt-fe8d)

### OldBrk (\$FA59)

**Description:**

This routine serves as a break handler that prints information about the
`BRK` instruction. It prints the values for the program counter and 6502
registers (A, X, Y, P, S) that are stored in zero page locations
([A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status),
[SPNT](#spnt), [PCL/PCH](#pcl-pch)). After printing this information, it
jumps to the Monitor. This routine is present in Apple II+, Apple IIe,
and Apple //c ROMs.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:**
  - [A5H](#a5h) (address \$45): The value in the A register before the
    break.
  - [XREG](#xreg) (address \$46): The value in the X register before the
    break.
  - [YREG](#yreg) (address \$47): The value in the Y register before the
    break.
  - [STATUS](#status) (address \$48): The value in the P register before
    the break.
  - [SPNT](#spnt) (address \$49): The value in the stack pointer before
    the break.
  - [PCL/PCH](#pcl-pch) (address \$3A-\$3B): The address of the program
    counter before the break.

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - Screen: Displays the contents of the program counter and registers.

**Side Effects:**

- Prints program counter and register values to the screen.
- Jumps to the Monitor.

**See also:**

- [Break (\$FA4C)](#break-fa4c) (Old 6502 break handler)
- [Mon (\$FF69)](#monz-ff69) (Monitor entry point)
- [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status),
  [SPNT](#spnt)
- [PCL/PCH](#pcl-pch)

### OldRst (\$FF59)

**Description:**

This routine performs a warm restart, typically after a `RESET` or `MON`
command. It initializes the text display to normal characters, clears
the screen, and sets the input and output hooks. Specifically, it
configures [CSWL/CSWH](#cswl-cswh) to point to [COut1](#cout1-fdf0) (the
screen display routine) and [KSWL/KSWH](#kswl-kswh) to point to
[KeyIn](#keyin-fd1b) (the keyboard input routine). After these setups,
it passes control to the Monitor entry point [Mon (\$FF65)](#mon-ff65),
which then clears the 6502 processor’s decimal mode flag, sounds the
speaker, and fully enters the Monitor. This routine does not return to
its caller.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A.

**Output:**

- **Registers:** None (does not return to the calling program).
- **Memory:**
  - [INVFLG](#invflg) (address \$32): Set to \$FF (normal display).
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated with the base
    address of the last line in the window.
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): Set to point to
    [COut1](#cout1-fdf0).
  - [KSWL/KSWH](#kswl-kswh) (address \$38-\$39): Set to point to
    [KeyIn](#keyin-fd1b).
  - Text screen: Initialized and cleared.

**Side Effects:**

- Initializes the text display to normal characters.
- Initializes the text screen.
- Sets standard input and output hooks.
- Clears the 6502 decimal mode flag (via [Mon (\$FF65)](#mon-ff65)).
- Sounds the speaker (via [Mon (\$FF65)](#mon-ff65)).
- Transfers control to the Monitor ([Mon (\$FF65)](#mon-ff65)).
- Does not return to the calling program.

**See also:**

- [SelNorm (\$FE84)](#setnorm-fe84)
- [Init (\$FB2F)](#init-fb2f)
- [SetVid (\$FE93)](#setvid-fe93)
- [SetKbd (\$FE89)](#setkbd-fe89)
- [Mon (\$FF65)](#mon-ff65)
- [COut1 (\$FDF0)](#cout1-fdf0)
- [KeyIn (\$FD1B)](#keyin-fd1b)
- [INVFLG](#invflg)
- [BASL/BASH](#basl-bash)
- [CSWL/CSWH](#cswl-cswh)
- [KSWL/KSWH](#kswl-kswh)

### OutPort (\$FE95)

**Description:**

This routine stores the value from the A register into the zero-page
location [A2L](#a2l-a2h). It then falls through to the internal
`OUTPRT ($FE97)` routine. The `OUTPRT` routine is responsible for
setting the system’s output hooks ([CSWL/CSWH](#cswl-cswh)) based on the
value found in [A2L](#a2l-a2h), effectively allowing the output
destination to be directed to a specified port. Calling with A = `$00`
(screen display) is equivalent to calling the [SetVid](#setvid-fe93)
routine.

**Input:**

- **Registers:**
  - A: Contains the value (typically a port number, \$00 for screen
    display) to be used for setting the output hooks.
  - X: N/A
  - Y: N/A
- **Memory:** N/A (the routine primarily acts on its A register input).

**Output:**

- **Registers:**
  - A: Undefined (modified by subsequent calls from `OUTPRT`).
  - X: Undefined (modified by subsequent calls from `OUTPRT`).
  - Y: Undefined (modified by subsequent calls from `OUTPRT`).
  - P: Flags affected.
- **Memory:**
  - [A2L](#a2l-a2h) (address \$3E): Stored with the value from the A
    register.
  - [CSWL/CSWH](#cswl-cswh) (address \$36-\$37): Updated by the
    `OUTPRT ($FE97)` routine.

**Side Effects:**

- Stores the input value from A to [A2L](#a2l-a2h).
- Transfers control to the internal `OUTPRT ($FE97)` routine, which then
  modifies the system’s standard output hooks.

**See also:**

- `OUTPRT ($FE97)` (internal routine)
- [SetVid](#setvid-fe93)
- [CSWL/CSWH](#cswl-cswh)
- [A2L](#a2l-a2h)

### PCAdj (\$F953)

**Description:**

This routine adjusts the Monitor’s program counter
([PCL/PCH](#pcl-pch)). It loads [PCL](#pcl-pch) into A and
[PCH](#pcl-pch) into Y, then increments A and Y by a value (1-4).
[LENGTH](#length) stores 1 less than the increment amount. The adjusted
PC value is stored back into [PCL/PCH](#pcl-pch).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the incremented [PCL](#pcl-pch).
  - X: Preserved
  - Y: Contains the incremented [PCH](#pcl-pch).
  - P: Flags affected by arithmetic additions.
- **Memory:**
  - [PCL/PCH](#pcl-pch): Updated with the incremented value.

**Side Effects:**

- Increments the Monitor’s program counter ([PCL/PCH](#pcl-pch)).

**See also:**

- [LENGTH](#length)
- [PCL/PCH](#pcl-pch)

### PRead (\$FB1E)

**Description:**

This routine returns the dial position of a hand control or mouse axis
(\$00-\$FF) in the Y register. The X register specifies the hand control
(\$00 or \$01) or mouse axis (\$00 for X, \$01 for Y). If a mouse is
connected and in transparent mode, `PRead` prioritizes reading the mouse
position.

**Input:**

- **Registers:**
  - A: N/A
  - X: Specifies the hand control number (\$00 or \$01) or the mouse
    axis to read (\$00 for X-position, \$01 for Y-position).
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Contains the position (\$00-\$FF).
  - P: Flags affected by internal input operations.
- **Memory:** None.

**Side Effects:**

- Reads input from hand control or mouse.

**See also:**

- [PRead4](#pread4-fb21)

### PRead4 (\$FB21)

**Description:**

This routine is identical to [PRead](#pread-fb1e), except it does not
read the mouse position if connected. It exclusively acquires input from
the hand control (game paddles).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Contains the position of the specified hand control’s dial
    (\$00-\$FF).
  - P: Flags affected by internal input operations.
- **Memory:** None.

**Side Effects:**

- Reads input exclusively from the hand control.

**See also:**

- [PRead](#pread-fb1e)

### Plot (\$F800)

**Description:**

This routine plots a single block of the color specified by
[COLOR](#color) (set via [SetCol](#setcol-f864)) on the Lo-Res graphics
display at the vertical (A) and horizontal (Y) positions.

**Input:**

- **Registers:**
  - A: The vertical position for plotting the block (\$00-\$2F).
  - X: N/A
  - Y: The horizontal position for plotting the block (\$00-\$27).
- **Memory:**
  - [COLOR](#color) (address \$30): Color value for plotting, set by
    [SetCol](#setcol-f864).

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags may be affected.
- **Memory:**
  - The Lo-Res graphics display memory is modified to include the
    plotted block.

**Side Effects:**

- Modifies the Lo-Res graphics display.

**See also:**

- [HLine](#hline-f819)
- [VLine](#vline-f828)
- [Plot1](#plot1-f80e)
- [SetCol](#setcol-f864)
- [COLOR](#color)

### Plot1 (\$F80E)

**Description:**

This routine plots a single block of the color specified by
[COLOR](#color) (set via [SetCol](#setcol-f864)) on the Lo-Res graphics
display at the horizontal position (Y) on the current row (determined by
[GBASL/GBASH](#gbasl-gbash)). Use [Plot](#plot-f800) for explicit
vertical/horizontal positions, or [GBasCalc](#gbascalc-f847) to set
[GBASL/GBASH](#gbasl-gbash).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: The horizontal position for plotting the block (\$00-\$27).
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags may be affected.
- **Memory:**
  - The Lo-Res graphics display memory is modified to include the
    plotted block.

**Side Effects:**

- Modifies the Lo-Res graphics display.

**See also:**

- [GBasCalc](#gbascalc-f847)
- [Plot](#plot-f800)
- [SetCol](#setcol-f864)
- [GBASL/GBASH](#gbasl-gbash)
- [COLOR](#color)

### PrA1 (\$FD92)

**Description:**

This routine sends a carriage return to standard output, then prints the
contents of [A1L/A1H](#a1l-a1h) in hexadecimal, followed by a hyphen
(-). The [Verify](#verify-fe36) routine uses `PrA1` with
[PrByte](#prbyte-fdda) to print addresses and values during memory
comparisons.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Outputs a carriage return.
- Prints hex value of [A1L/A1H](#a1l-a1h) and a hyphen.

**See also:**

- [PrByte](#prbyte-fdda)
- [Verify](#verify-fe36)
- [A1L/A1H](#a1l-a1h)

### PrBl2 (\$F94A)

**Description:**

This routine prints a number of blank spaces to standard output, as
specified by the value in the X register (1-256 spaces).

**Input:**

- **Registers:**
  - A: N/A
  - X: Number of blank spaces to print (\$00-\$FF).
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints blank spaces to standard output.

**See also:**

- [COUT](#cout-fded)

### PrBlnk (\$F948)

**Description:**

This routine prints three blank spaces to standard output.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints three blank spaces to standard output.

**See also:**

- [COUT](#cout-fded)
- [PrBl2](#prbl2-f94a)

### PrByte (\$FDDA)

**Description:**

This routine prints the contents of the A register (accumulator) in
two-digit hexadecimal format to standard output.

**Input:**

- **Registers:**
  - A: The 8-bit value to be printed in hexadecimal format.
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints the hexadecimal representation of the A register’s content.

**See also:**

- [PrHex](#prhex-fde3)
- [COUT](#cout-fded)

### PrErr (\$FF2D)

**Description:**

This routine prints “ERR” to standard output and sends a bell character
(`$87`) to standard output.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints “ERR”.
- Outputs a bell character.

**See also:**

- [COUT](#cout-fded)
- [Bell](#bell-ff3a)

### PrHex (\$FDE3)

**Description:**

This routine prints the lower nibble of the A register (accumulator) as
a single hexadecimal digit to standard output.

**Input:**

- **Registers:**
  - A: The value whose lower nibble is to be printed as a hexadecimal
    digit.
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Outputs a hexadecimal character.

**See also:**

- [PrByte](#prbyte-fdda)
- [COUT](#cout-fded)

### PrntAX (\$F941)

**Description:**

This routine prints the contents of the A (high byte) and X (low byte)
registers as a four-digit hexadecimal value to standard output.

**Input:**

- **Registers:**
  - A: Contains the high byte of the 16-bit value to be printed.
  - X: Contains the low byte of the 16-bit value to be printed.
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints a four-digit hexadecimal value to standard output.

**See also:**

- [PrByte](#prbyte-fdda)
- [PrHex](#prhex-fde3)

### PrntX (\$F944)

**Description:**

This routine prints the contents of the X register as a two-digit
hexadecimal value to standard output.

**Input:**

- **Registers:**
  - A: N/A
  - X: The 8-bit value from the X-index register to be printed in
    hexadecimal format.
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints the hexadecimal value of the X register.

**See also:**

- [PrByte](#prbyte-fdda)

### PrntYX (\$F940)

**Description:**

This routine prints the contents of the Y (high byte) and X (low byte)
registers as a four-digit hexadecimal value to standard output. This is
achieved by internally calling [PrByte](#prbyte-fdda).

**Input:**

- **Registers:**
  - A: N/A
  - X: Contains the low byte of the 16-bit value to be printed.
  - Y: Contains the high byte of the 16-bit value to be printed.
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - Standard output is used.

**Side Effects:**

- Prints a four-digit hexadecimal value.

**See also:**

- [PrByte](#prbyte-fdda)

- [PrntAX](#prntax-f941)

- **Description:**

This routine, present in Apple IIe and later ROMs, performs a cold start
of the system, including a partial system reset. It may perform partial
or complete initialization of the main memory range between `$0200` and
`$BEFF`. The specific range and method of initialization can vary
between ROM variants. The routine then attempts to start the system via
a disk drive or AppleTalk. If no startup device is available, the
message “Check startup Device” appears on the screen. This routine does
not return to the calling program.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A.

**Output:**

- **Registers:** None (does not return to calling program).
- **Memory:**
  - Main memory, addresses `$0200-$BEFF`: May be partially or completely
    initialized.
  - Screen: May display “Check startup Device”.

**Side Effects:**

- Performs a partial system reset.
- May perform partial or complete initialization of the main memory
  range between `$0200-$BEFF`.
- Attempts to boot from a disk drive or AppleTalk.
- Does not return to the calling program.

**See also:**

- [Reset (\$FA62)](#reset-fa62) (for full system reset)
- [SLOOP (\$FABA)](#sloop-faba) (startup device search loop)

### RdChar (\$FD35)

**Description:**

This routine activates escape mode and then jumps to the
[RdKey](#rdkey-fd0c) routine to read a character from the keyboard.

- **Memory:**
  - [CH](#ch) (address \$24): Horizontal position of the cursor.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line. **Output:**
- **Registers:**
  - A: Contains the ASCII code of the key pressed.
  - X: Preserved
  - Y: Undefined
  - P: Flags affected.
- **Memory:** None.

**Side Effects:**

- Activates escape mode.
- Transfers control to [RdKey](#rdkey-fd0c).

**See also:**

- [RdKey](#rdkey-fd0c)
- [KeyIn](#keyin-fd1b)
- [Escape Sequences with RdChar](#escape-sequences-with-rdchar)

### RdKey (\$FD0C)

**Description:**

This routine loads the A register with the character at the current
cursor position and transfers control to the [FD10](#fd10-fd10) routine.
[FD10](#fd10-fd10) then indirectly jumps to the configured input routine
(e.g., [KeyIn](#keyin-fd1b) or `C3KeyIn`). Effects like updating
[RNDL/RNDH](#rndl-rndh) occur via the called input routine.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Horizontal position of the cursor.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:** None.

**Side Effects:**

- Loads A with the current cursor character.
- Transfers control to [FD10](#fd10-fd10).

**See also:**

- [FD10](#fd10-fd10)
- [KeyIn](#keyin-fd1b)
- [RdChar](#rdchar-fd35)
- [C3KeyIn](#c3keyin)
- [RNDL/RNDH](#rndl-rndh)

### Read (\$FEFD)

**Description:**

This is an obsolete entry point. It simply returns to the calling
routine via an `RTS` instruction, performing no other actions.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Preserved
- **Memory:** None.

**Side Effects:**

- Returns from a subroutine. Its primary purpose as an entry point is
  for peripheral card slot identification.

**See also:**

- [Write](#write-fecd)

### RegDsp (\$FAD7)

**Description:**

This routine displays the contents of the microprocessor’s registers and
relevant system state information. It is primarily used by the Monitor
for debugging and system inspection purposes. The displayed values
typically include A, X, Y, and P registers.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A (displays current state from CPU registers and system
  zero-page locations).

**Output:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - Screen: Displays the contents of the registers and system state
    information.

**Side Effects:**

- Outputs register and system state information to the screen.

**See also:**

- [Mon (\$FF69)](#monz-ff69) (Monitor entry point)

### Reset (\$FA62)

**Description:**

This routine, called by the processor’s reset vector, initializes the
system and determines whether to perform a warm or cold start. It
performs the following initialization sequence:

1.  **Core Initialization (all variants):**
    - Calls [SetNorm](#setnorm-fe84) to clear the decimal mode flag and
      set standard mode
    - Calls [Init](#init-fb2f) to clear the STATUS register and
      configure the video mode switches
2.  **Video and Input Configuration (variant-specific):**
    - **Apple II+/IIe variants**: Calls [SetVid](#setvid-fe93) and
      [SetKbd](#setkbd-fe89) separately, then configures analog input
      ports (AN0-AN3)
    - **Apple IIc variant**: Calls ZZQUIT (which combines video and
      keyboard setup), initializes the mouse, clears port configuration,
      and calls RESET_X to handle additional device initialization and
      button detection
3.  **Warm/Cold Start Decision:**
    - Clears the keyboard strobe register
    - Calls [Bell](#bell-ff3a) (delay to account for key bounces)
    - Checks the SOFTEV soft entry vector (\$03F2-\$03F3) and PWREDUP
      validity byte (\$03F4) to determine if a cold start is needed
    - For IIc variant: RESET_X additionally checks the open apple and
      closed apple buttons; if both are pressed, enters exerciser mode;
      if only open apple is pressed, forces cold start
4.  **Transfer Control:**
    - If cold start is required: Jumps to [PwrUp](#pwrup-faa6)
    - If warm start: Jumps to the [User Reset
      Vector](#user-reset-vector) at (\$03F2-\$03F3)

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [SOFTEV](#user-reset-vector) (address \$03F2-\$03F3): User soft
    entry vector; checked to determine warm vs cold start
  - [PWREDUP](#validity-check-byte) (address \$03F4): Validity byte;
    used to verify SOFTEV integrity

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - System memory initialized:
    - [STATUS](#status) (\$48): Cleared
    - [BASL/BASH](#basl-bash) (\$28-\$29): Set to display line base
      address
    - [CH/CV](#ch) (\$24-\$25): Cursor position set to home
    - Video mode configured per system type
    - Keyboard input configured
  - Analog input ports configured (Apple II+/IIe)
  - IIc-specific: Mouse initialized, port configuration cleared, VMODE
    setup

**Side Effects:**

- Clears [KBDSTRB](#kbdstrb-c010) to acknowledge any pending keyboard
  input
- Calls [Bell](#bell-ff3a) to sound system bell (aids in detecting key
  bounces during reset)
- May transfer control to [PwrUp](#pwrup-faa6) for cold start, or to the
  [User Reset Vector](#user-reset-vector)
- IIc variant: Checks button state (BUTN0, BUTN1) to enable exerciser
  mode if both apple keys are pressed
- Calls variant-specific initialization routines
  ([SetVid](#setvid-fe93), [SetKbd](#setkbd-fe89), or ZZQUIT)

**Hardware Registers and Soft Switches Accessed:**

During execution and through its subroutine calls, Reset accesses the
following hardware locations (actual accesses depend on variant):

- **Video Mode Soft Switches (through [Init](#init-fb2f) and
  [SetTxt](#settxt-fb39)):**
  - `LORES` (\$C056): Read to detect low-resolution graphics mode
  - `TXTPAGE1` (\$C054): Read to detect text page 1 status
  - `TXTSET` (\$C051): Read to set text mode
  - `TXTCLR` (\$C050): Read to clear text mode for graphics
  - `MIXSET` (\$C053): Read to enable mixed graphics/text display
- **Keyboard (through [SetKbd](#setkbd-fe89) or ZZQUIT):**
  - `KBDSTRB` (\$C010): Write (\$00) to clear keyboard strobe and
    acknowledge input
- **Analog Inputs (Apple II+/IIe):**
  - `AN0` (\$C064): Analog input 0 configuration
  - `AN1` (\$C065): Analog input 1 configuration  
  - `AN2` (\$C066): Analog input 2 configuration
  - `AN3` (\$C067): Read via `SETAN3` soft switch (sets AN3 to TTL high)
- **Slot and I/O Configuration:**
  - Slot-based I/O addresses are configured through
    [SetVid](#setvid-fe93) and [SetKbd](#setkbd-fe89) (or ZZQUIT)
- **IIc-Specific Registers (only in Apple IIc variant):**
  - `BUTN0`/`BUTN1`: Button inputs checked by RESET_X for exerciser mode
    detection
  - Mouse hardware initialized (MPADDLE, etc.)
  - Serial/comm port registers cleared by CLRPORT

See the documentation for called routines ([SetNorm](#setnorm-fe84),
[Init](#init-fb2f), [SetVid](#setvid-fe93), [SetKbd](#setkbd-fe89)) for
detailed memory location modifications.

**See also:**

- [PwrUp](#pwrup-faa6)
- [User Reset Vector](#user-reset-vector)
- [SetNorm](#setnorm-fe84)
- [Init](#init-fb2f)
- [SetVid](#setvid-fe93)
- [SetKbd](#setkbd-fe89)
- [Bell](#bell-ff3a)

### Restore (\$FF3F)

**Description:**

This routine sets the A, X, Y, and P registers to the values stored in
[A5H](#a5h), [XREG](#xreg), [YREG](#yreg), and [STATUS](#status)
respectively.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [A5H](#a5h) (address \$45): Value to which the A register is to be
    set.
  - [XREG](#xreg) (address \$46): Value to which the X register is to be
    set.
  - [YREG](#yreg) (address \$47): Value to which the Y register is to be
    set.
  - [STATUS](#status) (address \$48): Value to which the P register is
    to be set.

**Output:**

- **Registers:**
  - A: Loaded with the value from [A5H](#a5h).
  - X: Loaded with the value from [XREG](#xreg).
  - Y: Loaded with the value from [YREG](#yreg).
  - P: Loaded with the value from [STATUS](#status).
- **Memory:** None.

**Side Effects:**

- Restores CPU registers from stored memory locations.

**See also:**

- [Save](#save-ff4a)
- [Go](#go-feb6)
- [A5H](#a5h)
- [XREG](#xreg)
- [YREG](#yreg)
- [STATUS](#status)

### SETX (\$CE1A) (Internal)

**Description:**

This is an **internal helper routine** that consists solely of a return
from subroutine (`RTS`) instruction. It immediately returns control to
the caller without performing any operations or modifying any registers
or memory locations. In the context of routines like
[CHK80](#chk80-cdcd), it serves as an exit point when no column mode
conversion is necessary.

**Input:**

- **Registers:** N/A
- **Memory:** N/A

**Output:**

- **Registers:** All registers are preserved.
- **Memory:** No memory locations are modified.

**Side Effects:** None.

**See also:**

- [CHK80](#chk80-cdcd)

### SLOOP (\$FABA)

**Description:**

This routine implements the disk controller slot search loop,
responsible for finding and booting from a startup device. It searches
for a disk controller beginning at the peripheral ROM space (if RAM
disk, ROM disk, or AppleTalk has not been selected via the Control Panel
as the startup device). It also considers SmartPort code for RAM/ROM
disk or AppleTalk boot code in slot 7, depending on Control Panel
settings. If a startup device is found, it transfers execution to that
device’s ROM space. If no startup device is found, the message “Check
Startup Device” appears on the screen. This routine does not return to
the calling program.

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:**
  - [LOC0](#loc0) (address \$00): Expected to be \$00 for startup to
    occur.
  - [LOC1](#loc1) (address \$01): Contains `$Cn`, where `n` is the next
    slot number to test for a startup device.

**Output:**

- **Registers:** None (does not return to calling program).
- **Memory:**
  - Screen: May display “Check Startup Device”.

**Side Effects:**

- Searches for a disk controller or other startup device.
- Transfers execution to the ROM space of the found startup device.
- May display “Check Startup Device” if no device is found.
- Does not return to the calling program.

**See also:**

- [PwrUp (\$FAA6)](#pwrup-faa6) (system cold-start routine, calls SLOOP)
- [Reset (\$FA62)](#reset-fa62) (hardware reset handler, calls SLOOP)
- [LOC0](#loc0)
- [LOC1](#loc1)

### SUBTBL (\$FFE3)

**Description:**

This is the **Monitor Routine Offset Table** used by the Monitor command
dispatcher. It contains a series of 16-bit offsets corresponding to each
command character in the ASCII Command Table ([CHRTBL](#chrtbl-ffcc) at
\$FFCC). When a user enters a Monitor command, the character is looked
up in CHRTBL to find its index, then that same index is used to retrieve
the corresponding offset from SUBTBL, which is used to dispatch to the
appropriate handler routine.

This table is located at a fixed address (\$FFE3) to ensure
compatibility with external diagnostic tools and to maintain consistent
command dispatch behavior across Apple II ROM variants.

**Structure:**

The table consists of 16-bit offset values (low byte, then high byte).
Each offset corresponds to a routine that handles the associated command
from CHRTBL.

**Fixed Address:** This table **must** remain at `$FFE3` for
compatibility with external diagnostic tools and software that may
reference this address directly.

**Input:** N/A (this is a data table, not a routine).

**Output:** N/A

**Side Effects:** N/A

**See also:**

- [CHRTBL](#chrtbl-ffcc) — ASCII Command Table at \$FFCC (paired with
  SUBTBL)
- [MonZ](#monz-ff69) — Monitor entry point that uses these tables
- [TOSUB](#tosub-ffbe) — Generic subroutine dispatcher
- [monitor_user_interface](#monitor-user-interface) — Documentation of
  Monitor command structure

### Save (\$FF4A)

**Description:**

This routine stores the current contents of the A, X, Y, P, and S
registers into [A5H](#a5h), [XREG](#xreg), [YREG](#yreg),
[STATUS](#status), and [SPNT](#spnt) respectively. Afterwards, it clears
the processor’s decimal mode flag.

**Input:**

- **Registers:**
  - A: Current Accumulator value.
  - X: Current X-index register value.
  - Y: Current Y-index register value.
  - P: Current Processor Status register value.
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Decimal mode flag is cleared.
- **Memory:**
  - [A5H](#a5h): Updated with the current value of the A register.
  - [XREG](#xreg): Updated with the current value of the X-index
    register.
  - [YREG](#yreg): Updated with the current value of the Y-index
    register.
  - [STATUS](#status): Updated with the current value of the P register.
  - [SPNT](#spnt): Updated with the current value of the S register.

**Side Effects:**

- Stores CPU registers in memory.
- Clears the decimal mode flag.

**See also:**

- [Restore](#restore-ff3f)
- [Break](#break-fa4c)
- [A5H](#a5h)
- [XREG](#xreg)
- [YREG](#yreg)
- [STATUS](#status)
- [SPNT](#spnt)

### Scrn (\$F871)

**Description:**

This routine returns the 4-bit color value of a block on the Lo-Res
graphics display at the given vertical (A) and horizontal (Y) positions.

**Input:**

- **Registers:**
  - A: The vertical position of the block on the Lo-Res graphics display
    (\$00-\$2F).
  - X: N/A
  - Y: The horizontal position of the block on the Lo-Res graphics
    display (\$00-\$27).
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the 4-bit color value of the block (\$00-\$0F).
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by memory read.
- **Memory:** None.

**Side Effects:**

- Reads Lo-Res graphics display memory.

**See also:**

- [Plot](#plot-f800)
- [Plot1](#plot1-f80e)
- [SetCol](#setcol-f864)
- [COLOR](#color)

### Scroll (\$FC70)

**Description:**

This routine scrolls the text window up by one line, moving all
characters upwards. The cursor’s absolute position remains unchanged. It
calls [BasCalc](#bascalc-fbc1) to update [BASL/BASH](#basl-bash) for the
new line.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [WNDTOP](#wndtop) (address \$22): Upper boundary of the text window.
  - [WNDBTM](#wndbtm) (address \$23): Lower boundary of the text window.
  - [CH](#ch) (address \$24): Horizontal position of the cursor.
  - [CV](#cv) (address \$25): Vertical position of the cursor.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of the
    current line.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - Text memory within the active window is scrolled upwards.

**Side Effects:**

- Scrolls the displayed text.
- Updates [BASL/BASH](#basl-bash).

**See also:**

- [BasCalc](#bascalc-fbc1)
- [WNDTOP](#wndtop)
- [WNDBTM](#wndbtm)
- [CH](#ch)
- [CV](#cv)
- [BASL/BASH](#basl-bash)

### SetCol (\$F864)

**Description:**

This routine sets the color for Lo-Res graphics plotting. The A register
must contain the desired 4-bit color value (\$00-\$0F).

**Input:**

- **Registers:**
  - A: The 4-bit color value (\$00-\$0F) to be set for Lo-Res graphics
    plotting.
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [COLOR](#color): The zero-page location is updated with the new
    color value.

**Side Effects:**

- Configures the current plotting color.

**See also:**

- [Plot](#plot-f800)
- [HLine](#hline-f819)
- [VLine](#vline-f828)
- [NxtCol](#nxtcol-f85f)
- [COLOR](#color)

### SetGr (\$FB40)

**Description:**

This routine sets the display to mixed graphics mode, clears the
graphics portion of the screen, and sets the top of the text window to
line 20. It also calls [BasCalc](#bascalc-fbc1) to calculate and store
the base memory address ([BASL/BASH](#basl-bash)) for the last line of
text.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address for the text
    line (for the four-line text window) ([BASL](#basl-bash)).
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - Graphics screen memory: Cleared.
  - [WNDTOP](#wndtop) (address \$22): Set to \$14 (20 decimal).
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated with the base
    address for the text window.
  - Video mode soft switches: Configured for mixed graphics mode.

**Side Effects:**

- Changes display mode to mixed graphics.
- Clears the graphics screen.
- Sets the top boundary of the text window.
- Updates [BASL/BASH](#basl-bash).

**See also:**

- [BasCalc](#bascalc-fbc1)
- [WNDTOP](#wndtop)
- [BASL/BASH](#basl-bash)

### SetInv (\$FE80)

**Description:**

This routine sets [INVFLG](#invflg) to `$3F` so that subsequent text
output through [COut1](#cout1-fdf0) will be displayed as inverse
characters.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [INVFLG](#invflg): The inverse flag is set to `$3F`.

**Side Effects:**

- Sets [INVFLG](#invflg) to enable inverse text display.

**See also:**

- [SetNorm](#setnorm-fe84)
- [COut1](#cout1-fdf0)
- [INVFLG](#invflg)

### SetKbd (\$FE89)

**Description:**

This routine sets the input links [KSWL/KSWH](#kswl-kswh) to point to
the keyboard input routine, [KeyIn](#keyin-fd1b). It effectively
redirects all subsequent standard input operations to the keyboard
rather than an expansion slot device.

**Hardware Details:** This routine internally sets [A2L](#a2l-a2h) to
\$00 and calls [InPort](#inport-fe8b) to configure the input hooks. The
effect is to reset standard input to ROM-based keyboard input.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [KSWL/KSWH](#kswl-kswh): Updated to contain the 16-bit address of
    the [KeyIn](#keyin-fd1b) routine.

**Side Effects:**

- Modifies the system’s standard input hooks.
- Redirects subsequent standard input operations to
  [KeyIn](#keyin-fd1b).

**See also:**

- [KeyIn](#keyin-fd1b)
- [InPort](#inport-fe8b)
- [KSWL/KSWH](#kswl-kswh)

### SetNorm (\$FE84)

**Description:**

This routine sets [INVFLG](#invflg) to `$FF` so that subsequent text
output through [COut1](#cout1-fdf0) will be displayed as normal
characters.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [INVFLG](#invflg): The inverse flag is set to `$FF`.

**Side Effects:**

- Sets [INVFLG](#invflg) to enable normal text display.

**See also:**

- [SetInv](#setinv-fe80)
- [COut1](#cout1-fdf0)
- [INVFLG](#invflg)

### SetPwrC (\$FB6F)

**Description:**

This routine calculates a Validity-Check byte for the current reset
vector and stores it in memory. This helps ensure the integrity of the
reset process.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [User Reset Vector](#user-reset-vector) (address \$03F2-\$03F3):
    Pointer to the routine to be executed after a warm start.

**Output:**

- **Registers:**
  - A: Contains the calculated power-up byte (the value stored in
    [PWREDUP](#pwredup)).
  - X: Preserved.
  - Y: Preserved.
  - P: Undefined.
- **Memory:**
  - [PWREDUP](#pwredup) (address \$03F4): Stores the calculated power-up
    byte.

**Side Effects:**

- Calculates and stores the Validity-Check byte in memory.

**See also:**

- [Reset](#reset-fa62)
- [PwrUp](#pwrup-faa6)

### SetTxt (\$FB39)

**Description:**

This routine configures the display for a full text window. It reads the
current video mode soft switches to determine the display configuration,
then sets window parameters and configures the display for full-screen
text mode.

**Hardware Details:** During execution, SetTxt reads the following
hardware soft switches (memory-mapped I/O locations):

- `TXTSET` (\$C051): Reads to set text mode (any read action enables
  text mode)
- `TXTCLR` (\$C050): Reads to clear text mode for graphics (any read
  action disables text mode)
- `MIXSET` (\$C053): Reads to enable mixed graphics/text display
- Window width is determined via the [WNDREST](#wndrest) internal call,
  which detects 40/80 column mode

**Input:**

- **Registers:**
  - A: Undefined.
  - X: Undefined.
  - Y: Undefined.
- **Memory:** N/A.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address for the text
    line ([BASL](#basl-bash)).
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - [BASL/BASH](#basl-bash): Updated with the base memory address for
    the last line of text.
  - Display mode is set to full-screen text window.

**Side Effects:**

- Configures the screen for a full text window.
- Updates [BASL/BASH](#basl-bash) by calculating the base address for
  the text line.

**See also:**

- [Init (\$FB2F)](#init-fb2f)
- [BasCalc (\$FBC1)](#bascalc-fbc1)
- [BASL/BASH](#basl-bash)

### SetVid (\$FE93)

**Description:**

This routine sets the output links [CSWL/CSWH](#cswl-cswh) to point to
the screen display routine [COut1](#cout1-fdf0). It effectively
redirects all subsequent standard output operations to the video display
rather than an expansion slot device.

**Hardware Details:** This routine internally sets [A2L](#a2l-a2h) to
\$00 and calls [OutPort](#outport-fe95) to configure the output hooks.
The effect is to reset standard output to ROM-based screen display.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [CSWL/CSWH](#cswl-cswh): Updated with the 16-bit address of the
    [COut1](#cout1-fdf0) routine.

**Side Effects:**

- Modifies the system’s standard output hooks.
- Redirects subsequent standard output operations to the screen display.

**See also:**

- [COut1](#cout1-fdf0)
- [OutPort](#outport-fe95)
- [CSWL/CSWH](#cswl-cswh)

### SetWnd (\$FB4B)

**Description:**

This routine sets the text window to full screen width, with its bottom
at the screen’s bottom, and its top at the line specified in the A
register. It calls [BasCalc](#bascalc-fbc1) to calculate and store the
base memory address ([BASL/BASH](#basl-bash)) for the last text line in
the window.

**Input:**

- **Registers:**
  - A: The line number designated for the top boundary of the window
    (\$00-\$17).
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address for the
    current line ([BASL](#basl-bash)).
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - [WNDTOP](#wndtop) (address \$22): Set to the value in A on entry.
  - [WNDBTM](#wndbtm) (address \$23): Set to \$18 (24 decimal).
  - [WNDLFT](#wndlft) (address \$20): Set to \$00.
  - [WNDWDTH](#wndwdth) (address \$21): Set to \$28 (40 columns) or \$50
    (80 columns) depending on video mode.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated with the base
    address for the current line.

**Side Effects:**

- Configures the text window dimensions.
- Updates [BASL/BASH](#basl-bash).

**See also:**

- [BasCalc](#bascalc-fbc1)
- [WNDTOP](#wndtop)
- [WNDBTM](#wndbtm)
- [WNDLFT](#wndlft)
- [WNDWDTH](#wndwdth)
- [BASL/BASH](#basl-bash)

### StorAdv (\$FBF0)

**Description:**

This routine places a printable character (from the A register) on the
text screen at the line determined by [BASL/BASH](#basl-bash) and
horizontal position by [CH](#ch). After printing, `StorAdv` increments
[CH](#ch). If [CH](#ch) + 1 exceeds [WNDWDTH](#wndwdth), it executes a
carriage return.

**Input:**

- **Registers:**
  - A: The printable ASCII character to be displayed on the screen.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Horizontal position of cursor.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Base address of current
    line.
  - [WNDWDTH](#wndwdth) (address \$21): Width of the current text
    window.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - Text memory at ([BASL/BASH](#basl-bash) + [CH](#ch)) is modified.
  - [CH](#ch): The horizontal cursor position is incremented.

**Side Effects:**

- Displays a character.
- Advances the horizontal cursor position.
- May trigger a carriage return.

**See also:**

- [Advance](#advance-fbf4)
- [COUT](#cout-fded)
- [BASL/BASH](#basl-bash)
- [CH](#ch)
- [WNDWDTH](#wndwdth)
- [CV](#cv)

### TOSUB (\$FFBE)

**Description:**

This routine serves as a dispatcher to execute other ROM subroutines
whose entry points are listed in the [SUBTBL](#subtbl-ffe3) lookup
table. It is typically invoked after identifying a command character via
the monitor’s command interpreter.

`TOSUB` works by:

1.  Pushing the high-order byte of the target subroutine’s address
    (derived from `>GO`) onto the stack.
2.  Pushing the low-order byte of the target subroutine’s address
    (retrieved from [SUBTBL](#subtbl-ffe3) indexed by the Y register)
    onto the stack.
3.  Saving the current [MODE](#mode) byte into the A register.
4.  Clearing the [MODE](#mode) byte (setting it to \$00).
5.  Executing an `RTS` instruction. Since the target subroutine’s
    address is now on top of the stack, the `RTS` effectively transfers
    control to that subroutine.

**Input:**

- **Registers:**
  - Y: An index (0-based) into the [SUBTBL](#subtbl-ffe3) table,
    specifying which subroutine to dispatch to.
  - A: N/A (loaded internally).
  - X: N/A (used internally for stack manipulation).
- **Memory:**
  - [MODE](#mode) (address \$31): The current monitor mode byte. Its
    initial value is read.
  - [SUBTBL](#subtbl-ffe3) (address \$FFE0): A table of low-order
    subroutine entry point addresses.

**Output:**

- **Registers:**
  - A: Contains the original value of the [MODE](#mode) byte.
  - X: Undefined (modified during stack operations).
  - Y: Cleared to \$00.
  - P: Flags affected by various operations.
- **Memory:**
  - [MODE](#mode) (address \$31): Cleared to \$00.

**Side Effects:**

- Modifies the stack by pushing a return address.
- Transfers control to a subroutine specified by the Y register’s index
  into [SUBTBL](#subtbl-ffe3).
- Saves and clears the [MODE](#mode) byte.

**See also:**

- [SUBTBL](#subtbl-ffe3) (table of dispatch addresses)
- [MODE](#mode)
- [MONZ](#monz-ff69) (Monitor entry points that use `TOSUB`)
- [GO](#go-feb6) (Used as the high-order address for dispatch)

### TabV (\$FB5B)

**Description:**

This routine performs a vertical tab to the line specified in the A
register (\$00-\$17). It calls [BasCalc](#bascalc-fbc1) to calculate and
store the base memory address ([BASL/BASH](#basl-bash)) for that line,
and updates [CV](#cv) with the new line number.

**Input:**

- **Registers:**
  - A: The line number (from \$00-\$17) to which the vertical tab should
    occur.
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Contains the low byte of the calculated base address for the text
    line ([BASL](#basl-bash)).
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - [CV](#cv) (address \$25): Set to the value in A on entry.
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated with the base
    address for the text line.

**Side Effects:**

- Performs a vertical tab.
- Updates [CV](#cv) and [BASL/BASH](#basl-bash).

**See also:**

- [BasCalc](#bascalc-fbc1)
- [VTab](#vtab-fc22)
- [VTabZ](#vtabz-fc24)
- [CV](#cv)
- [BASL/BASH](#basl-bash)

### Up (\$FC1A)

**Description:**

This routine decrements the [CV](#cv) value by 1, moving the cursor up
one line, unless the cursor is already on the top line of the window
(defined by [WNDTOP](#wndtop)).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CV](#cv) (address \$25): Vertical position of cursor.
  - [WNDTOP](#wndtop) (address \$22): Upper boundary of the text window.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [CV](#cv): The vertical cursor position is decremented (if not at
    top of window).

**Side Effects:**

- Moves the cursor up one line, unless at the top of the window.

**See also:**

- [BS](#bs-fc10)
- [CV](#cv)
- [WNDTOP](#wndtop)

### VLine (\$F828)

**Description:**

This routine draws a vertical line of blocks on the Lo-Res graphics
display. The block color is determined by [COLOR](#color) (set via
[SetCol](#setcol-f864)). The A register specifies the vertical position
of the topmost block (\$00-\$2F), and the Y register specifies the
horizontal position of the line (\$00-\$27). The lowest extent is
determined by [V2](#v2).

**Input:**

- **Registers:**
  - A: The vertical position of the topmost block in the line
    (\$00-\$2F).
  - X: N/A
  - Y: The horizontal position of the vertical line (\$00-\$27).
- **Memory:**
  - [COLOR](#color) (address \$30): Block’s color value.
  - [V2](#v2) (address \$2F): Vertical position of the bottommost block.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved
  - Y: Preserved
  - P: Flags may be affected.
- **Memory:**
  - The Lo-Res graphics display memory is modified to draw the vertical
    line.

**Side Effects:**

- Modifies the Lo-Res graphics display.

**See also:**

- [Plot](#plot-f800)
- [HLine](#hline-f819)
- [SetCol](#setcol-f864)
- [V2](#v2)
- [COLOR](#color)

### VTab (\$FC22)

**Description:**

This routine performs a vertical tab to the line specified by [CV](#cv).
It calls [BasCalc](#bascalc-fbc1) to store the base memory address
([BASL/BASH](#basl-bash)) for that line. `VTab` differs from
[TabV](#tabv-fb5b) by not storing a new line number in [CV](#cv).

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CV](#cv) (address \$25): Vertical position of cursor.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected by [BasCalc](#bascalc-fbc1) execution.
- **Memory:**
  - [BASL/BASH](#basl-bash): Updated with the base memory address for
    the new text line.

**Side Effects:**

- Performs a vertical tab.
- Updates [BASL/BASH](#basl-bash).

**See also:**

- [BasCalc](#bascalc-fbc1)
- [TabV](#tabv-fb5b)
- [VTabZ](#vtabz-fc24)
- [CV](#cv)
- [BASL/BASH](#basl-bash)

### VTABZ (\$FC24)

**Description:**

This routine calculates the base address for the current text line and
adjusts it based on the left edge of the text window and 80-column mode.
It calls [BasCalc](#bascalc-fbc1) to get the initial base address using
the A register (vertical line number), then adjusts [BASL](#basl-bash)
by adding [WNDLFT](#wndlft), potentially halved if in 80-column mode
(checked via the `RD80VID` soft switch).

**Input:**

- **Registers:**
  - A: The vertical line number for which to calculate the base address
    (typically from [CV](#cv)).
  - X: N/A
  - Y: N/A
- **Memory:**
  - [BASL](#basl-bash) (address \$28): Lower byte of the text screen
    base address. Read and modified by this routine.
  - [WNDLFT](#wndlft) (address \$20): The left edge of the text window.
    Used to adjust the base address.
  - `RD80VID ($C01F)`: A read-only soft switch that indicates if the
    system is in 80-column video mode. This influences how
    [WNDLFT](#wndlft) is applied.

**Output:**

- **Registers:**
  - A: Modified by internal calculations.
  - X: Preserved.
  - Y: Preserved.
  - P: Flags affected by arithmetic and bitwise operations.
- **Memory:**
  - [BASL](#basl-bash) (address \$28): Updated with the adjusted base
    address.
  - [BASH](#basl-bash) (address \$29): Updated by
    [BasCalc](#bascalc-fbc1).

**Side Effects:**

- Calls [BasCalc](#bascalc-fbc1) to get the initial base address.
- Reads the `RD80VID` soft switch.
- Modifies [BASL](#basl-bash) and [BASH](#basl-bash).

**See also:**

- [BasCalc](#bascalc-fbc1)
- [WNDLFT](#wndlft)
- [BASL/BASH](#basl-bash)
- [CV](#cv)
- `RD80VID` (soft switch)

### Verify (\$FE36)

**Description:**

This routine compares the contents of two memory ranges. It reads from
the first block (pointed to by [A1L/A1H](#a1l-a1h) + Y), then from the
second ([A4L/A4H](#a4l-a4h) + Y), comparing until [A2L/A2H](#a2l-a2h).
If bytes mismatch, it prints the address, a hyphen, the first byte, and
(in parentheses) the second byte.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: An offset used for indexed addressing.
- **Memory:**
  - [A1L/A1H](#a1l-a1h) (address \$3C-\$3D): Beginning address of the
    first block.
  - [A2L/A2H](#a2l-a2h) (address \$3E-\$3F): Ending address of the first
    block.
  - [A4L/A4H](#a4l-a4h) (address \$40-\$41): Beginning address of the
    second block.

**Output:**

- **Registers:**
  - A: Undefined
  - X: Undefined
  - Y: Undefined
  - P: Flags affected by internal comparisons.
- **Memory:**
  - Detected mismatches are reported to standard output.

**Side Effects:**

- Compares memory ranges.
- Reports mismatches to standard output.
- Affects CPU flags.

**See also:**

- [Move](#move-fe2c)
- [NxtA4](#nxta4-fcb4)
- [PrA1](#pra1-fd92)
- [A1L/A1H](#a1l-a1h)
- [A2L/A2H](#a2l-a2h)
- [A4L/A4H](#a4l-a4h)

### Version (\$FBB3)

**Description:**

This is one of the Monitor ROM’s main identification bytes, a fixed
hexadecimal value (`$06`) located in the ROM. It serves to indicate
whether the system is an Apple IIe or a later model. This byte’s value
is consistent across the Apple IIe, enhanced Apple IIe, and Apple IIGS,
providing a way for software to determine the basic system type. This is
not a callable routine.

**Input:** None. (This is a data location, not a routine).

**Output:** None. (This is a data location, not a routine).

**Side Effects:** None. (This is a data location, not a routine).

**See also:**

- [ZIDByte](#zidbyte-fbc0)
- [ZIDByte2](#zidbyte2-fbbf)

### VidOut (\$FBFD)

**Description:**

This routine sends printable characters (from the A register) to
[StorAdv](#storadv-fbf0). It checks for carriage return, line feed,
backspace, and bell characters (Control-G), branching to their handlers
if found. Other control characters are ignored.

**Input:**

- **Registers:**
  - A: The character (printable or control) to be processed.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [CH](#ch) (address \$24): Horizontal position of cursor.
  - [CV](#cv) (address \$25): Vertical position of cursor.

**Output:**

- **Registers:**
  - A: Contains the character that was output (same as input A).
  - X: Preserved.
  - Y: Undefined.
  - P: Undefined.
- **Memory:**
  - Screen memory: Modified to display characters or as a result of
    control codes.
  - Cursor position (zero-page locations [CH](#ch) and [CV](#cv)):
    Advanced or modified.

**Side Effects:**

- Sends characters for display.
- Processes and handles specific control characters.
- Modifies text memory and cursor position.

**See also:**

- [StorAdv](#storadv-fbf0)
- [CR](#cr-fc62)
- [LF](#lf-fc66)
- [BS](#bs-fc10)
- [Bell](#bell-ff3a)
- [CH](#ch)
- [CV](#cv)

### VidWait (\$FB78)

**Description:**

This routine checks the A register for carriage return (`$8D`). If
found, it checks for Control-S (`$93`) on the keyboard. If Control-S is
pressed, the keyboard strobe is cleared, and control passes to
[KbdWait](#kbdwait-fb88) to pause output. Otherwise, if enhanced video
is inactive, control passes to [VidOut](#vidout-fbfd) for standard
output. If enhanced video is active, it routes to an internal handler.
All keyboard input except Control-S is ignored.

**Input:**

- **Registers:**
  - A: The character being processed.
  - X: N/A
  - Y: N/A
- **Memory:**
  - [KSWL/KSWH](#kswl-kswh) (address \$36-\$37): Address of the keyboard
    input routine.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Undefined
  - Y: Undefined
  - P: Undefined
- **Memory:**
  - Keyboard strobe is cleared if Control-S found.
  - Display output may occur.

**Side Effects:**

- Checks for Control-S for output pausing.
- Processes carriage return.
- Transfers control to [KbdWait](#kbdwait-fb88) or
  [VidOut](#vidout-fbfd) based on conditions.

**See also:**

- [KbdWait](#kbdwait-fb88)
- [VidOut](#vidout-fbfd)
- [COUT](#cout-fded)
- [CH](#ch)
- [CV](#cv)

### WIN0 (\$CDD5) (Internal)

**Description:**

This is an **internal helper routine** responsible for setting up the
initial text window configuration, typically used during mode changes
(e.g., from 80-column to 40-column mode or vice-versa) or when
re-initializing video. It is called by routines like
[CHK80](#chk80-cdcd).

The routine first clears [WNDTOP](#wndtop) to \$00. It then reads the
`RDTEXT ($C01A)` soft switch to determine if it should set
[WNDTOP](#wndtop) to 20 (for mixed mode). It then checks the
`RD80VID ($C01F)` soft switch to see if the system is currently in
80-column mode and proceeds with necessary screen conversions (calling
`SCRN84 ($CE53)` for 80-to-40, or `SCRN48 ($CE80)` for 40-to-80).
Finally, it calls [GETCUR](#getcur2-ccad), [SETCUR](#setcur-ecfe), and
[BASCALC](#bascalc-fbc1) to update cursor positions and base addresses.

**Input:**

- **Registers:** N/A (inputs are primarily from zero-page locations and
  soft switches).
- **Memory:**
  - `RDTEXT ($C01A)`: Read-only soft switch that indicates if the system
    is in text mode or graphics mode.
  - `RD80VID ($C01F)`: Read-only soft switch that determines if the
    system is currently in 80-column video mode.
  - [WNDLFT](#wndlft) (address \$20): The left edge of the text window,
    used for cursor positioning calculations.
  - [CV](#cv) (address \$25): The current vertical cursor position, used
    for base address calculations.

**Output:**

- **Registers:**
  - A: Modified by various operations and internal calls.
  - X: Modified by internal calls.
  - Y: Modified by internal calls.
  - P: Flags affected by various operations.
- **Memory:**
  - [WNDTOP](#wndtop) (address \$22): Set to \$00 or \$14 (20 decimal),
    depending on `RDTEXT`.
  - [WNDWDTH](#wndwdth) (address \$21): May be modified by screen
    conversion routines ([SCRN84](#scrn84-ce53) or
    [SCRN48](#scrn48-ce80)).
  - [CH](#ch) (address \$24): Updated by [GETCUR](#getcur2-ccad) and
    [SETCUR](#setcur-ecfe).
  - [CV](#cv) (address \$25): Read and potentially updated by
    [BASCALC](#bascalc-fbc1) via [SETCUR](#setcur-ecfe).
  - [BASL/BASH](#basl-bash) (address \$28-\$29): Updated by
    [BASCALC](#bascalc-fbc1).
  - Screen memory: Modified by column conversion routines
    ([SCRN84](#scrn84-ce53) or [SCRN48](#scrn48-ce80)).
  - `CLR80COL ($C000)`, `CLR80VID ($C00C)`, `SET80COL ($C001)`,
    `SET80VID ($C00D)` soft switches: Potentially modified by screen
    conversion routines.

**Side Effects:**

- Clears or sets [WNDTOP](#wndtop).
- Reads `RDTEXT` and `RD80VID` soft switches.
- Calls screen conversion routines: `SCRN84 ($CE53)` (80-to-40) or
  `SCRN48 ($CE80)` (40-to-80).
- Calls [GETCUR](#getcur2-ccad) and [SETCUR](#setcur-ecfe) to update
  cursor positions.
- Calls [BASCALC](#bascalc-fbc1) to calculate base screen addresses.
- Modifies various soft switches related to video mode.

**See also:**

- [CHK80](#chk80-cdcd)
- [WNDTOP](#wndtop)
- [WNDWDTH](#wndwdth)
- [CH](#ch)
- [CV](#cv)
- [BASL/BASH](#basl-bash)
- `RDTEXT` (soft switch)
- `RD80VID` (soft switch)
- `SCRN84 ($CE53)` (internal routine)
- `SCRN48 ($CE80)` (internal routine)
- [GETCUR](#getcur2-ccad) (internal routine)
- [SETCUR](#setcur-ecfe) (internal routine)
- [BASCALC](#bascalc-fbc1)

### Wait (\$FCA8)

**Description:**

This routine introduces a time delay determined by the value in the A
register (\$00-\$FF). The delay calculation varies by Apple IIc model:

- **Apple IIc**: `0.5 * (26 + 27A + 5A^2)` cycles
  (`0.488889 * (26 + 27A + 5A^2)` microseconds).
- **Apple IIc Plus**: `0.5 * (50 + 25A + 3A^2) + 29` cycles
  (`0.488889 * (50 + 25A + 5A^2) + 16.711114` microseconds).

**Input:**

- **Registers:**
  - A: The delay value (\$00-\$FF).
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Flags affected by internal timing loops.
- **Memory:** None.

**Side Effects:**

- Introduces a time delay.

**See also:** None.

### Write (\$FECD)

**Description:**

This is an obsolete entry point. It simply returns to the calling
routine via an `RTS` instruction, performing no other actions.

**Input:**

- **Registers:**
  - A: N/A
  - X: N/A
  - Y: N/A
- **Memory:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Preserved
- **Memory:** None.

**Side Effects:**

- Returns from a subroutine. Its primary purpose as an entry point is
  for peripheral card slot identification.

**See also:**

- [Read](#read-fefd)

### ZIDByte (\$FBC0)

**Description:**

This is one of the Monitor ROM’s main identification bytes, a fixed
hexadecimal value (`$E0`) located in the ROM. It serves to indicate that
the system is an enhanced Apple IIe or a later model. This is not a
callable routine.

**Input:** None.

**Output:** None.

**Side Effects:** None.

**See also:**

- [Version](#version-fbb3)
- [ZIDByte2](#zidbyte2-fbbf)

### ZIDByte2 (\$FBBF)

**Description:**

This is one of the Monitor ROM’s main identification bytes, a fixed
hexadecimal value (`$00`) located in the ROM. It serves to indicate that
the system is an enhanced Apple IIe or a later model. This is not a
callable routine.

**Input:** None.

**Output:** None.

**Side Effects:** None.

**See also:**

- [Version](#version-fbb3)
- [ZIDByte](#zidbyte-fbc0)

### ZMode (\$FFC7)

**Description:**

This routine clears the System Monitor’s operational mode flag by
storing `$00` into the [MODE](#mode). This byte dictates how the Monitor
interprets hexadecimal numbers in input.

**Input:** None.

**Output:**

- **Registers:**
  - A: Preserved
  - X: Preserved
  - Y: Preserved
  - P: Undefined
- **Memory:**
  - [MODE](#mode): The Monitor’s mode flag is set to `$00`.

**Side Effects:**

- Clears the Monitor’s operational mode.

**See also:**

- [MonZ](#monz-ff69)
- [MODE](#mode)

## Symbol Definitions

This section documents the memory locations, variables, and hardware
registers used by the Apple II firmware. These symbols are referenced
throughout the firmware entry point specifications and provide the
standard interface between firmware and software.

The symbols are organized into two categories:

- **Zero-Page Definitions** - Variables stored in the fast-access
  zero-page memory (\$0000-\$00FF)
- **Other Definitions** - System variables, hardware registers, and
  memory buffers located elsewhere in the address space

Understanding these symbols is essential for implementing compatible
firmware or writing software that interacts directly with the ROM
routines.

### Zero-Page Definitions

| Address | Label(s) | Description | Usage |
|----|----|----|----|
| \$00 | <a id="loc0"></a>LOC0 | I/O Vector Low Byte. | Used by PR#n routines for I/O port selection; part of autostart vector from disk. |
| \$01 | <a id="loc1"></a>LOC1 | I/O Vector High Byte. | Pair with LOC0 to form 16-bit I/O routing vector. |
| \$20 | <a id="wndlft"></a>WNDLFT | Left edge of the text window. | Horizontal start of the active text display area. |
| \$21 | <a id="wndwdth"></a>WNDWDTH | Width of the text window. | Number of character columns in the active text display area. |
| \$22 | <a id="wndtop"></a>WNDTOP | Top line of the text window. | Vertical start of the active text display area. |
| \$23 | <a id="wndbtm"></a>WNDBTM | Bottom line of the text window. | Vertical end of the active text display area. |
| \$24 | <a id="ch"></a>CH | Current Horizontal Cursor Position. | Current column number of the text cursor within the window. |
| \$25 | <a id="cv"></a>CV | Current Vertical Cursor Position. | Current row number of the text cursor within the window. |
| \$26-\$27 | <a id="gbasl-gbash"></a>GBASL/GBASH | Lo-Res Graphics Base Address. | 16-bit pointer to the start of a Lo-Res graphics display row. |
| \$28-\$29 | <a id="basl-bash"></a>BASL/BASH | Text Screen Base Address. | 16-bit pointer to the start of a text display line. |
| \$2A-\$2B | <a id="a2l-a2h"></a>A2L/A2H | General-purpose 16-bit Address/Value 2. | General-purpose 16-bit register for temporary storage, comparisons, or loop bounds. |
| \$2C | <a id="h2"></a>H2 | HLine Rightmost Horizontal Position. | Used by the HLine routine to determine the rightmost horizontal position to plot. |
| \$2D | <a id="v2"></a>V2 | VLine Bottommost Vertical Position. | Used by the VLine routine to determine the bottommost vertical position to plot. |
| \$2F | <a id="length"></a>LENGTH | Length/Amount for Operations. | Defines an increment amount (e.g., for PCAdj, it is 1 less than the actual increment). |
| \$30 | <a id="color"></a>COLOR | Current Lo-Res Graphics Color. | Stores the 4-bit color value (\$00-\$0F) for Lo-Res graphics plotting. |
| \$31 | <a id="mode"></a>MODE | Monitor Mode Byte. | Tracks the current Monitor mode; used internally to determine program execution context and input handling. |
| \$32 | <a id="invflg"></a>INVFLG | Inverse Text Flag. | Controls whether subsequent text output is displayed in normal or inverse video. \$3F = inverse, \$FF = normal. |
| \$33 | <a id="prompt"></a>PROMPT | Prompt Character ASCII Code. | Stores the ASCII code (high bit set) for the command prompt character. |
| \$36-\$37 | <a id="cswl-cswh"></a>CSWL/CSWH | Current Standard Output Hook. | Low (\$36) and high (\$37) bytes of a 16-bit pointer to the currently active standard output routine. |
| \$38-\$39 | <a id="kswl-kswh"></a>KSWL/KSWH | Current Standard Input Hook. | Low (\$38) and high (\$39) bytes of a 16-bit pointer to the currently active standard input routine. |
| \$3A-\$3B | <a id="pcl-pch"></a>PCL/PCH | Program Counter Low/High. | Low (\$3A) and high (\$3B) bytes of the 6502 Program Counter; used by Monitor routines. |
| \$3C-\$3D | <a id="a1l-a1h"></a>A1L/A1H | 16-bit Address/Value 1. | General-purpose 16-bit register, often used as a source address pointer. |
| \$3E-\$3F | <a id="a4l-a4h"></a>A4L/A4H | 16-bit Address/Value 4. | General-purpose 16-bit register, often used as a destination address pointer. |
| \$45 | <a id="a5h"></a>A5H | Accumulator (A) Register copy. | Stores a copy of the 6502 Accumulator (A) register for preservation or restoration. |
| \$46 | <a id="xreg"></a>XREG | X Register copy. | Stores a copy of the 6502 X-index register for preservation or restoration. |
| \$47 | <a id="yreg"></a>YREG | Y Register copy. | Stores a copy of the 6502 Y-index register for preservation or restoration. |
| \$48 | <a id="status"></a>STATUS | Processor Status (P) Register copy. | Stores a copy of the 6502 Processor Status (P) register for preservation or restoration. |
| \$49 | <a id="spnt"></a>SPNT | Stack Pointer (S) Register copy. | Stores a copy of the 6502 Stack Pointer (S) register for preservation or restoration. |
| \$4E-\$4F | <a id="rndl-rndh"></a>RNDL/RNDH | Random Number Low/High. | Low (\$4E) and high (\$4F) bytes of a 16-bit seed used for random number generation. |

### Other Definitions

| Address | Label(s) | Description | Usage |
|----|----|----|----|
| \$0200 | <a id="inbuf"></a>INBUF | Monitor Input Buffer. | 128-byte buffer for storing user input lines, typically in the Monitor or command-line input routines. |
| \$03F0-\$03F1 | BRKV | Break Instruction Vector (IIe+). | 16-bit pointer executed when BRK (\$00) instruction is encountered. Default points to Monitor Break handler. Used for debugging and system break handling. Added in Apple IIe; not present in original Apple II/II+. |
| \$03F2-\$03F3 | SOFTEV | Warm Start / Soft Power-On Vector (IIe+). | 16-bit pointer to warm-start routine. Executed on RESET if \[SOFTEV XOR (SOFTEV+1) = PWREDUP\], indicating a clean shutdown. Default points to firmware initialization. Added in Apple IIe. |
| \$03F4 | PWREDUP | Power-Up Detection Byte (IIe+). | Single byte containing magic value for warm-start detection. Valid value = SOFTEV+1 XOR \$A5 (complement of high byte). If this value matches, RESET is treated as warm start instead of cold start. Added in Apple IIe. |
| \$03F8-\$03F9 | USRADR | User Address / Applesoft Exit Vector. | 16-bit pointer executed by `POP` instruction (simulated via stack manipulation) or Applesoft END statement. Default points to Monitor. Used for returning from user programs. Present in all Apple II variants. |
| \$03FB-\$03FC | NMI | Non-Maskable Interrupt Handler Vector. | 16-bit pointer executed when NMI (non-maskable interrupt) signal is asserted. Used for system-critical interrupt handling. Present in all Apple II variants. |
| \$03FE-\$03FF | IRQLOC | Interrupt Request Handler Vector. | 16-bit pointer executed when IRQ (maskable interrupt) signal is asserted. Default points to firmware IRQ handler. Present in all Apple II variants. |
| \$047B | <a id="oldch"></a>OLDCH | Old Horizontal Cursor Position. | Stores the previous horizontal cursor position; used in 80-column mode to track cursor movement. |
| \$04FB | <a id="vmode"></a>VMODE | Video Mode Byte. | 80-column mode flag; used internally to track whether 80-column mode is enabled. |
| \$057B | <a id="ourch"></a>OURCH | Our Horizontal Cursor Position. | Stores the current horizontal cursor position in 80-column mode; used internally by 80-column display routines. |
| \$05FB | <a id="ourcv"></a>OURCV | Our Vertical Cursor Position. | Stores the current vertical cursor position in 80-column mode; updated by NEWVTABZ and related routines. |
| \$067B | <a id="vfactv"></a>VFACTV | Video Firmware Active Flag. | Bit 7 = 0 when video firmware is inactive; used to test if 80-column card is active. |
| \$07FB | <a id="cursor"></a>CURSOR | Cursor type and status. | Defines the type of cursor displayed by input routines (e.g., block, checkerboard). |
| \$C000 | KBD | Keyboard Data Register. | Read: Returns last key pressed, with bit 7 set (\$80 |
| \$C010 | KBDSTRB | Keyboard Strobe Register. | Read/Write: Reading clears the keyboard interrupt. Must be read to acknowledge keyboard input. |
| \$C01A | <a id="rdtext"></a>RDTEXT | Read Text Mode Soft Switch. | Software switch; reads as non-zero (\$FF) if in text mode, zero if in graphics mode. Used to check current display mode. |
| \$FFCC | CHRTBL | Monitor ASCII Command Table. | Table of ASCII characters corresponding to Monitor commands (e.g., ‘G’, ‘X’, ‘A’, ‘L’, ‘S’). Located at fixed address for compatibility with external tools. |

## Peripheral Controller ROMs

### Disk II Controller ROM

In addition to the main system firmware documented in previous sections,
Apple II computers often include expansion cards for disk drive control.
The most common is the **Disk II Controller Card** (pronounced “Disk
Two”), which includes a 256-byte boot loader ROM.

**Location:** Slot-relative address \$Cn00 (where n is the slot number,
typically \$C600 for slot 6)

**Purpose:** Initializes the Disk II drive controller and loads the
secondary boot loader (BOOT1) from disk into system memory at \$0800.

**Key Functions:**

- Initialize disk controller (IWM - Integrated Woz Machine) hardware
- Generate 6+2 encoding decoder table for disk data
- Seek disk head to track 0
- Read track 0, sector 0 (boot sector) from disk
- Decode 6+2 encoded data and store in \$0800-\$0BFF
- Jump to BOOT1 code at \$0801 for continued system initialization

**Entry Points:**

- **\$Cn00 (typically \$C600):** Main boot entry point - reads boot
  sector from disk and jumps to BOOT1
- **\$Cn5C (typically \$C65C):** ReadSector routine - reads a single
  disk sector (internal use)

**Hardware Accessed:**

- IWM Control Registers (\$C080-\$C08F range) - Stepper motor and drive
  control
- System RAM (\$0300-\$0BFF) - Decoder tables and data buffers

**Memory Usage:**

- \$0300-\$0355: 2-bit chunk buffer for 6+2 decoding
- \$0356-\$03D5: 6+2 decoder lookup table
- \$0800-\$0BFF: BOOT1 code loaded from disk
- Zero-page: \$26-\$27, \$2B, \$3C-\$41

**Special Features:**

- Slot-independent design allows placement in any slot
- Blind seek algorithm doesn’t require track detection
- 6+2 encoding provides error detection via specific bit patterns
- Auto-detects boot sector size from first byte of BOOT1

**Typical Boot Sequence:**

1.  System reset vector jumps to firmware initialization
2.  Slot detection determines which controller cards are installed
3.  Disk II ROM entry (\$C600) selected if drive controller present
4.  Boot ROM reads track 0, sector 0 from disk
5.  BOOT1 code loaded into memory at \$0800
6.  Control transfers to BOOT1 at \$0801
7.  BOOT1 continues initialization and loads main program/operating
    system

------------------------------------------------------------------------

**For detailed technical specification of the Disk II ROM, see [Disk II
Controller ROM Specification](#disk-ii-controller-rom-specification)
below.**

### Boot ROM Identification Protocols

Peripheral ROM devices must be properly identified by the system
firmware and operating systems to be recognized as boot devices. This
section documents the identification protocols used across different
Apple II systems and operating environments.

#### Overview

The Apple II family has used three primary boot ROM identification
schemes:

1.  **Original Apple II DOS** (minimal/none) - Simple presence detection
    at \$Cn00
2.  **Pascal 1.1 Firmware Protocol** - ID bytes at specific addresses
    for device classification
3.  **ProDOS Block Device Protocol** - Extended ID byte structure for
    block devices and SmartPort

The protocol used depends on the target operating system and system
generation.

#### Protocol 1: Original Apple II DOS

##### Identification Method

**DOS 3.2 and 3.3** do not implement a standardized identification
protocol. Boot detection is based simply on the presence of executable
code at the slot’s boot ROM address.

##### Boot ROM Requirements

- Code must be present and executable at **\$Cn00-\$CnFF** (where n =
  slot number)
- No specific ID bytes required
- Firmware scans slots 1-7 and executes the first boot ROM found
- First boot ROM to load successfully takes control of the system

##### Protocol 1 Target Systems

- Apple II
- Apple II+
- Some early Apple IIe configurations

------------------------------------------------------------------------

#### Protocol 2: Pascal 1.1 Firmware Protocol

##### Protocol 2 ID Byte Structure

Cards following the Pascal 1.1 Firmware Protocol can be identified by ID
bytes at the following addresses (where n is the slot number):

| Address | Value | Definition                                              |
|---------|-------|---------------------------------------------------------|
| \$Cn05  | \$38  | ID byte (from Pascal 1.0)                               |
| \$Cn07  | \$18  | ID byte (from Pascal 1.0)                               |
| \$Cn0B  | \$01  | Generic signature of cards with Pascal 1.1 Protocol     |
| \$Cn0C  | \$c:i | Device signature byte (c = device type, i = identifier) |

##### Device Type Encodings (\$Cn0C High Nibble)

| Value | Device Type                 |
|-------|-----------------------------|
| \$3x  | Serial port                 |
| \$8x  | 80-column display           |
| \$2x  | Mouse                       |
| Other | Reserved or vendor-specific |

##### Important Warning

**Do NOT use Pascal 1.1 ID bytes to identify devices that do not follow
this protocol.** This includes:

- Disk II controllers
- SmartPort devices
- SCSI controllers
- Memory expansion cards
- Most modern peripheral cards

Using these bytes to identify such devices can produce incorrect results
and may cause system failures.

##### Apple II Peripheral Cards Using Pascal 1.1 Protocol

| Card                 | \$Cn05 | \$Cn07 | \$Cn0B | \$Cn0C |
|----------------------|--------|--------|--------|--------|
| Super Serial Card    | \$38   | \$18   | \$01   | \$31   |
| Apple 80 Column Card | \$38   | \$18   | \$01   | \$88   |
| Apple II Mouse Card  | \$38   | \$18   | \$01   | \$20   |

##### Apple IIc Built-in Ports

The IIc includes built-in ports that follow the Pascal 1.1 protocol.
Different ROM versions identified by the Version byte at \$FBBF:

**IIc ROM 1st version** (\$FBBF = \$FF):

- Slot 1: Serial Port (\$31)
- Slot 2: Serial Port (\$31)
- Slot 3: 80-Column (\$88)
- Slot 4: Mouse (\$20)

**IIc ROM 2nd version** (\$FBBF = \$00):

- Slots 1-2: Serial Ports (\$31)
- Slot 3: 80-Column (\$88)
- Slot 4: Mouse (\$20)
- Slot 7: AppleTalk (\$31)

**IIc ROM 3rd-5th versions** (\$FBBF = \$03-\$05):

- Slots 1-2: Serial Ports (\$31)
- Slot 3: 80-Column (\$88)
- Slot 7: Mouse (\$20) or AppleTalk (\$31)

##### Protocol 2 Target Systems

- Apple II Pascal
- Some Apple IIe Pascal configurations
- Early Apple IIc systems

------------------------------------------------------------------------

#### Protocol 3: ProDOS Block Device Protocol

##### Protocol 3 Overview

ProDOS introduced a standardized identification protocol for block
devices (disk controllers) and SmartPort expansion devices. This
protocol is used by:

- ProDOS 1.x and 2.x
- Apple IIe with ProDOS
- Apple IIc (native)
- Apple IIGS

##### Protocol 3 ID Byte Structure

ProDOS block devices and SmartPort devices are identified by ID bytes at
the following addresses:

| Address | Field | Description |
|----|----|----|
| \$Cn01 | Device ID | \$20 for ProDOS block devices; \$20 for SmartPort |
| \$Cn03 | Reserved | \$00 (must be zero for ProDOS block devices) |
| \$Cn05 | General Code | \$03 for ProDOS block devices; \$03 for SmartPort |
| \$Cn07 | Unit Number / Protocol | \$00 for SmartPort; varies for other block devices |

##### Identification Algorithm

To identify a device in slot n:


    1. Read $Cn01
    2. If NOT $20, device does not follow ProDOS protocol; skip this slot
    3. Read $Cn03
    4. If NOT $00, device does not follow ProDOS protocol; skip this slot
    5. Read $Cn05
    6. If NOT $03, device does not follow ProDOS protocol; skip this slot
    7. Read $Cn07
    8. If $00, device follows SmartPort protocol (see SmartPort section below)
    9. If $xx (non-zero), device is a traditional ProDOS block device

##### ProDOS Block Device

A ProDOS block device presents a traditional block storage interface:

- Single \$Cn00 entry point for boot
- Block read/write via standard Disk II-compatible mechanism
- Examples: Disk II controller, some RAM disk cards, some hard drive
  controllers

**ID Bytes:**

- \$Cn01 = \$20
- \$Cn03 = \$00
- \$Cn05 = \$03
- \$Cn07 = varies (device-specific)

##### SmartPort Protocol

SmartPort is an extended protocol providing:

- Multiple logical units (drives) per slot
- Standardized status and control commands
- Support for variable block sizes
- Unified interface for diverse device types (hard drives, networks,
  etc.)

**ID Bytes:**

- \$Cn01 = \$20
- \$Cn03 = \$00
- \$Cn05 = \$03
- \$Cn07 = \$00

**Important:** SmartPort devices require protocol-specific STATUS and
CONTROL commands for device identification and configuration. Full
SmartPort specification details are beyond the scope of this document.

**Reference:** See [ProDOS 8
Organization](https://prodos8.com/docs/technote/15/) for complete
SmartPort protocol documentation.

##### Protocol 3 Target Systems

- Apple IIe with ProDOS
- Apple IIc (native ProDOS support)
- Apple IIGS with ProDOS 8
- Modern emulators and compatible systems

------------------------------------------------------------------------

#### Target System and Protocol Mapping

| System | Primary Protocol | Secondary Protocol | Boot ROM Required |
|----|----|----|----|
| Apple II | Original DOS | None | Yes (simple presence) |
| Apple II+ | Original DOS | None | Yes (simple presence) |
| Apple IIe | ProDOS Block Device | Pascal 1.1 (for built-ins) | Yes (ProDOS ID bytes) |
| Apple IIc | ProDOS Block Device / SmartPort | Pascal 1.1 (for built-ins) | Yes (ProDOS ID bytes) |
| Apple IIGS | ProDOS Block Device / SmartPort | None | Yes (ProDOS ID bytes) |

------------------------------------------------------------------------

#### Boot ROM Implementation Guidelines

##### For Original Apple II / II+

- No specific ID bytes needed
- Code must be present and executable at \$Cn00
- Firmware calls via `JMP (LOC0)` where LOC0 = \$Cn00
- First boot ROM found takes control

##### For Apple IIe with ProDOS

- Implement ProDOS Block Device ID bytes (\$Cn01, \$Cn03, \$Cn05,
  \$Cn07)
- Boot ROM at \$Cn00 should follow traditional Disk II protocol
- ProDOS will scan for devices during boot and load ProDOS drivers
- Pascal-based systems will look for Pascal 1.1 ID bytes if present

##### For Apple IIc / IIGS

- Implement ProDOS Block Device or SmartPort ID bytes
- Boot ROM follows ProDOS block device protocol
- System firmware expects ProDOS-compatible device
- SmartPort devices require additional protocol implementation

##### For Multi-Device Compatibility

- Implement all three protocols if targeting multiple systems:
  - Pascal 1.1 ID bytes for compatibility with Pascal systems
  - ProDOS ID bytes for ProDOS systems
  - Executable code at \$Cn00 for original DOS systems
- Do NOT use Pascal 1.1 bytes if device is SmartPort-only
- Do NOT implement SmartPort without full protocol support

------------------------------------------------------------------------

#### References

- **Apple II Technical Note \#008: Pascal 1.1 Firmware Protocol ID
  Bytes**  
  https://mirrors.apple2.org.za/Apple%20II%20Documentation%20Project/Computers/Apple%20II/Apple%20II/Documentation/Misc%20%23008%20Pascal%20Protocol%20ID.pdf

- **ProDOS 8 Organization - SmartPort and Block Device Protocols**  
  https://prodos8.com/docs/technote/15/

- **Apple IIc Technical Reference Manual** - Boot sequence and firmware
  protocol documentation

------------------------------------------------------------------------

## Disk II Controller ROM Specification

### Overview

The Disk II Controller ROM is located at the slot-relative address
\$Cn00 (where n is the slot number, typically slot 6 giving \$C600).
This 256-byte ROM contains the boot loader (“BOOT0”) that initializes
disk operations and loads the secondary boot loader (BOOT1) from disk
into memory.

**Size:** 256 bytes (\$C600-\$C6FF)  
**Architecture:** 6502 assembly (Disk II controller boot code)  
**Primary Function:** Disk boot loader and initialization

------------------------------------------------------------------------

### Architecture & Memory Layout

#### ROM Address Space

- **Base Address:** \$Cn00 (where n = slot number, 1-7)
- **Typical Slot:** 6 (address \$C600)
- **Size:** 256 bytes (\$C600-\$C6FF)
- **Entry Point:** \$C600 (when selected as boot ROM)

#### Code Organization

    $C600-$C602   Initialization & setup
    $C603-$C650   6+2 decoder table generation
    $C651-$C65B   Blind seek to track 0
    $C65C-$C6D3   Read sector routine (core)
    $C6D4-$C6FB   Decode 6+2 data & loop control
    $C6FC-$C6FF   Spare bytes

------------------------------------------------------------------------

### Hardware Interface

#### IWM (Integrated Woz Machine) Registers

The Disk II controller uses the IWM chip for low-level disk operations.
Access is via memory-mapped I/O in the slot I/O area (\$C000-\$C0FF).

#### Drive Control Registers

| Address | Slot-Relative | Name | Function |
|----|----|----|----|
| \$C080 + n\*\$100 | \$80 | IWM_PH0_OFF | Stepper motor phase 0 off |
| \$C081 + n\*\$100 | \$81 | IWM_PH0_ON | Stepper motor phase 0 on |
| \$C082 + n\*\$100 | \$82 | IWM_PH1_OFF | Stepper motor phase 1 off |
| \$C083 + n\*\$100 | \$83 | IWM_PH1_ON | Stepper motor phase 1 on |
| \$C084 + n\*\$100 | \$84 | IWM_PH2_OFF | Stepper motor phase 2 off |
| \$C085 + n\*\$100 | \$85 | IWM_PH2_ON | Stepper motor phase 2 on |
| \$C086 + n\*\$100 | \$86 | IWM_PH3_OFF | Stepper motor phase 3 off |
| \$C087 + n\*\$100 | \$87 | IWM_PH3_ON | Stepper motor phase 3 on |
| \$C088 + n\*\$100 | \$88 | IWM_MOTOR_OFF | Stop drive motor |
| \$C089 + n\*\$100 | \$89 | IWM_MOTOR_ON | Start drive motor |
| \$C08A + n\*\$100 | \$8A | IWM_SELECT_DRIVE_1 | Select drive 1 |
| \$C08B + n\*\$100 | \$8B | IWM_SELECT_DRIVE_2 | Select drive 2 |
| \$C08C + n\*\$100 | \$8C | IWM_Q6_OFF | Read mode (prepare data read) |
| \$C08D + n\*\$100 | \$8D | IWM_Q6_ON | Write mode (prepare write) |
| \$C08E + n\*\$100 | \$8E | IWM_Q7_OFF | Read Write-Protect / Read mode |
| \$C08F + n\*\$100 | \$8F | IWM_Q7_ON | Write mode / Write data |

**Slot-Relative Addressing Formula:**

The actual memory address for any IWM register depends on the disk
controller’s slot location:

    Register Address = $C000 + (slot_number << 8) + register_offset
                     = $Cn00 + register_offset

Where:

- `slot_number` = Slot number (1-7, typically 6)
- `register_offset` = Register address offset (\$80-\$8F)

**Examples for common slots:**

- Slot 6 (typical): \$C600 + \$80 = \$C680 (first phase control)
- Slot 5: \$C500 + \$80 = \$C580
- Slot 1: \$C100 + \$80 = \$C180

**Important:** ROM implementations must use indexed addressing to remain
slot-independent:

    ; Assume X = (slot_number << 4), e.g., X = $60 for slot 6
    LDA $C080,X     ; Load from appropriate slot's IWM register
    STA $C089,X     ; Store to appropriate slot's motor-on register

This allows the ROM to work in any slot without hardcoding addresses.
Absolute addressing (e.g., `LDA $C680`) would restrict the ROM to a
specific slot.

#### I/O Data Ports

| Address | Slot-Relative | Name | Direction | Function |
|----|----|----|----|----|
| \$C08C + n\*\$100 | \$8C | DATA_IN | Read | Read data from disk (requires Q6=0, Q7=0) |
| \$C08D + n\*\$100 | \$8D | STATUS | Read/Write | Check write-protect (read); initialize Q6 (write) |
| \$C08E + n\*\$100 | \$8E | IWM_SEQUENCER | Read/Write | Reset state sequencer (read); write-protect check (read) |
| \$C08F + n\*\$100 | \$8F | DATA_OUT | Write | Write data to disk (requires indexed addressing) |

**Data Transfer:**

- **Reading:** Disk controller places bytes on data bus; 6502 reads via
  indexed addressing
- **Writing:** 6502 writes via indexed addressing; controller accepts
  only on synchronized clock pulses

#### Logic State Sequencer (CRITICAL for Write Operations)

The disk controller includes a hardware-based **logic state sequencer**
that must be synchronized with the software write loop. This is
essential for correct disk write operations.

**State Sequencer Timing Constraint:**

The controller will accept write data ONLY on specific clock pulses:

1.  The clock pulse immediately AFTER the one that started the sequencer
2.  Then every fourth clock pulse thereafter

**CRITICAL - Addressing Mode Requirements for Write Operations:**

The addressing mode used for write operations is NOT a stylistic
choice—it directly affects hardware synchronization:

**CORRECT (Indexed Addressing):**

    STA $C080,X     ; X = slot_number << 4 (e.g., $60 for slot 6)
    STA $C08F,X     ; Write data - uses indexed addressing

**Also Correct (Indirect Indexed):**

    STA (ZP),Y      ; Indirect indexed (no page crossing)

**BROKEN (Absolute Addressing):**

    STA $C08F       ; WILL NOT WORK - causes 1-clock desynchronization
                    ; Controller will reject all write data

The indexed addressing mode takes an extra cycle that synchronizes the
write operation with the state sequencer’s 4-cycle timing. Absolute
addressing executes one clock too soon, causing the controller to be out
of sync.

**Write Protect Check and State Sequencer Reset Sequence:**

Before attempting write operations, the ROM must check write protection
and reset the sequencer:

    ; X = $60 for slot 6 (or slot_number << 4)
    LDA $C08D,X         ; Check write protect flag
    LDA $C08E,X         ; Reset state sequencer to idle location
    BMI WPROTECT        ; Branch if write protected (N flag set)

This sequence:

1.  Checks if the disk is write-protected (returns with N flag set if
    protected)
2.  Resets the sequencer to its idle state for the next operation
3.  Prepares for the next read or write sequence

#### Firmware ROM References

The DISK ROM calls or references:

- **\$FCA8** \[MON_WAIT\] - Delay routine for timing-critical operations
- **\$FF58** \[MON_IORTS\] - System identification / slot detection

#### Slot Detection Using IORTS

The Disk II ROM does not require knowledge of which slot it occupies;
instead, it can determine its slot at runtime by calling
[IORTS](#iorts-ff58) (\$FF58). This routine provides a generic mechanism
for peripheral ROMs to identify their installed slot:

**Slot Detection Method:**

When a peripheral ROM is executing in slot n (at \$Cn00-\$CnFF), it can
determine its slot number as follows:

1.  **Call IORTS via JSR \$FF58** - This calls a simple RTS instruction
    in main firmware
2.  **The return address is pushed to the stack** - The return address
    (\$Cn00 + offset within the ROM) is pushed by JSR
3.  **Read return address high byte** - Extract the high byte from the
    stack using TSX and indexed addressing
4.  **Convert to slot offset** - Multiply the high byte by 16 (via 4
    left shifts) to get the slot offset for indexed I/O addressing

**Assembly Example:**

            JSR     $FF58           ; Call IORTS (pushes return address onto stack)
            TSX                     ; Transfer S register to X (X = stack offset)
            LDA     $0100,X         ; Read return address high byte ($Cn) from stack
            ASL     A               ; Shift left 4 times to convert $Cn to $Cn0
            ASL     A               ; (multiply by 16 for slot-relative addressing)
            ASL     A
            ASL     A
            TAX                     ; X now = slot_number << 4 (for indexed I/O access)

**Why This Works:**

When the firmware calls the peripheral ROM via `JMP (LOC0)` where LOC0
points to \$Cn00, the ROM executes at address \$Cn00-\$CnFF. When the
ROM calls `JSR $FF58` (IORTS):

- The return address (\$Cn00 + offset) is automatically pushed onto the
  6502 stack
- IORTS is just an RTS instruction that immediately returns
- The peripheral ROM can read its own return address from the stack to
  determine n (the slot number)
- Converting the high byte via 4 left shifts produces the slot index for
  use in indexed I/O operations

This elegant mechanism allows peripheral ROMs to be completely
slot-independent; they don’t need slot information passed in a register
or stored in ROM—they determine their own slot by examining the return
address on the stack.

------------------------------------------------------------------------

### Memory Layout

#### Data Buffers

| Address       | Size   | Name        | Purpose                             |
|---------------|--------|-------------|-------------------------------------|
| \$0100-\$01FF | 256    | STACK       | 6502 stack (system-wide)            |
| \$0200-\$02FF | 256    | (reserved)  | General purpose RAM                 |
| \$0300-\$0355 | 86     | TWOS_BUFFER | 2-bit chunk buffer for 6+2 decoding |
| \$0356-\$03D5 | 128    | CONV_TAB    | 6+2 conversion decoder table        |
| \$03D6-\$07FF | ~1.5KB | (available) | General purpose RAM                 |
| \$0800-\$0BFF | 1024   | BOOT1       | Secondary boot loader code          |

#### Zero-Page Variables (DISK ROM use)

| Address | Name | Purpose |
|----|----|----|
| \$26-\$27 | data_ptr | Pointer to BOOT1 data buffer location |
| \$2B | slot_index | Slot number \<\< 4 (for IWM register addressing) |
| \$3C | bits | Temporary storage for bit manipulation during 6+2 decoding |
| \$3D | sector | Sector number being read |
| \$40 | found_track | Track found during seek |
| \$41 | track | Track to read |

------------------------------------------------------------------------

### Disk II ROM Entry Points

#### ENTRY (\$C600)

**Description:**

The main boot entry point. When invoked (typically via reset vector
jumping to \$Cn01, which relative-jumps to \$C600), this routine
initializes the Disk II controller and loads the bootstrap code (BOOT1).

**Execution Sequence:**

1.  **Initialize Controller:**
    - Load slot index (X = \$20, which expands to slot 6 \<\< 4)
    - Set up data pointer to BOOT1 buffer (\$0800)
    - Initialize sector counter to 0
2.  **Generate 6+2 Decoder Table:**
    - Build lookup table in memory locations \$0356-\$03D5
    - Table allows decoding of 6+2 encoded disk data
    - Uses specific bit patterns that avoid sector header markers (\$D5,
      \$AA)
3.  **Seek to Track 0:**
    - Perform blind seek (stepper motor pulse sequence)
    - Move disk head to outermost track position
    - Uses phase signals (\$C080-\$C087 equivalents)
4.  **Read Disk Data:**
    - Read track 0, sector 0 (boot sector)
    - Call ReadSector to locate and read sector
    - Decode 6+2 encoded data into BOOT1 buffer
    - Continue reading additional sectors until BOOT1 is complete
5.  **Transfer Control:**
    - Jump to \$0801 (BOOT1 entry point)
    - BOOT1 continues system initialization

**Input:**

- **Registers:** A, X, Y undefined
- **Memory:**
  - Stack must be available and initialized
  - RAM from \$0300-\$0BFF must be available
  - ROM selected in slot space

**Output:**

- **Registers:** Undefined (transfers to BOOT1)
- **Memory:**
  - TWOS_BUFFER (\$0300-\$0355): 6+2 conversion table generated
  - BOOT1 (\$0800-\$0BFF): Filled with bootstrap code from disk
  - Zero-page (\$26, \$2B, \$3C-\$41): Initialized for disk operations
- **Transfer:** Control jumps to \$0801 (BOOT1 code)

**Side Effects:**

- IWM hardware registers accessed (stepper motor, drive motor)
- Disk drive motor started and stopped
- Disk head positioned to track 0
- System memory modified (\$0300-\$0BFF range)
- Interrupts may be affected by timing-critical operations

------------------------------------------------------------------------

#### ReadSector (\$C65C)

**Description:**

Core disk read routine. Reads a single 256-byte sector from the
currently selected track. The routine searches the disk for the
requested sector by examining address mark patterns, then reads and
decodes the sector data.

**Operation:**

1.  **Find Address Mark:**
    - Scan disk data stream for address mark byte sequence (\$D5 \$AA
      \$96)
    - Once found, extract track and sector numbers from address field
2.  **Verify Track/Sector:**
    - Check that track number matches expected track
    - Check that sector number matches requested sector
    - If mismatch, continue scanning for next address mark
3.  **Find Data Mark:**
    - Continue scanning for data mark sequence (\$D5 \$AA \$AD)
    - Signals start of actual sector data
4.  **Read & Decode:**
    - Read 342 bytes of 6+2 encoded data
    - Decode using CONV_TAB table into 256 bytes of actual data
    - Store in buffer pointed to by data_ptr
5.  **Return:**
    - Return to caller with sector data decoded in buffer

**Input:**

- **Registers:**
  - A: undefined
  - X: slot index (slot_number \<\< 4)
  - Y: undefined
- **Memory:**
  - data_ptr (\$26-\$27): Must point to valid memory for 256 bytes
  - sector (\$3D): Sector number to find and read (0-15)
  - track (\$41): Track number being read
  - CONV_TAB (\$0356-\$03D5): Must be initialized with 6+2 decoder table
  - IWM registers accessible at \$C000 + slot offset

**Output:**

- **Registers:**
  - A: Undefined
  - X: Preserved (slot index still set)
  - Y: Incremented to 0 (after processing all 256 bytes)
- **Memory:**
  - data_ptr+1 (\$27): Incremented to next page
  - Sector data (256 bytes): Decoded and placed at address pointed by
    data_ptr
  - TWOS_BUFFER (\$0300-\$0355): May be partially modified during
    decoding

**Side Effects:**

- IWM registers accessed for disk read
- Timing-sensitive disk operations performed
- Disk head may seek if sector not on current track
- Memory access via indirect addressing (data_ptr)

------------------------------------------------------------------------

### 6+2 Encoding & Decoding

#### Why 6+2 Encoding?

The original Disk II drive hardware imposes constraints on allowable
byte patterns:

- **Cannot have high bit clear:** All data bytes must have bit 7 set
  (\$80-\$FF range)
- **Cannot have consecutive zero bits:** Violates disk timing
  requirements
- **Special markers excluded:** Bytes \$D5, \$AA reserved for
  address/data marks

These constraints allow only 64 valid byte values from the 256-byte
range. To encode 256 bytes of actual data, the Disk II uses **6+2
encoding:**

- Take 3 bytes of actual data = 24 bits
- Split into 6 bits + 6 bits + 6 bits + 2 bits (leftover 2 bits)
- Encode each 6-bit chunk as a valid disk byte
- Combine 2-bit chunk from last byte into its encoding
- Result: 4 bytes of encoded data from 3 bytes of actual data
- 256 bytes input → 342 bytes encoded output (256 × 4/3)

#### Decoder Table Generation

The DISK ROM generates the decoder table at runtime (code
\$C603-\$C650):

**Algorithm:**

1.  For each value 0-63 (6-bit value):

    - Shift left and check for adjacent 1-bits
    - Combine with original, invert, and verify no three consecutive 0s
    - If valid: store at calculated table offset in \$0356-\$03D5

2.  **Result:** Sparse lookup table with 64 valid entries among 128
    possible positions

3.  **Purpose:** Quickly decode 6-bit values from disk byte stream

------------------------------------------------------------------------

### Boot Sequence

#### Typical Boot Flow

    System Power-On
        ↓
    Reset Vector ($FFFC-$FFFD) points to ROM startup
        ↓
    ROM Initialization Code
        ↓
    Slot Detection & Boot ROM Selection
        ↓
    DISK ROM Entry ($C600) called via relative jump ($Cn01)
        ↓
    [ENTRY routine - as documented above]
        ├── Initialize IWM hardware
        ├── Generate 6+2 decoder table
        ├── Seek to track 0
        ├── Read track 0, sector 0 (boot sector)
        ├── Decode 6+2 data into $0800
        ├── Continue reading sectors until complete
        └── Jump to $0801
        ↓
    BOOT1 Code Execution
        ├── Additional bootstrap code
        ├── Program loader setup
        └── Transfer to main program or monitor

#### Sector Loading

The DISK ROM reads disk sectors and stores them in the BOOT1 buffer
(\$0800-\$0BFF range):

- **Track:** Always 0 (boot sector is on track 0)
- **Sectors:** Read sequentially starting from sector 0
- **Stop Condition:** When sector number (in read data) exceeds first
  byte of BOOT1
  - BOOT1 code includes its own size as first byte
  - This allows variable-sized boot code

#### IWM Timing

Critical timing operations use the MON_WAIT routine (\$FCA8):

- Provides delay for stepper motor settling
- Synchronizes with disk rotation
- Ensures reliable disk head positioning

------------------------------------------------------------------------

### Slot Selection & Addressing

#### Slot-Relative Addressing

The DISK ROM is slot-independent. When placed in slot n:

- Entry address: \$Cn00 (not \$C600)
- IWM registers accessed: \$C080 + (n \<\< 4)
- Invoked as: `JMP $Cn01` (relative jump to actual \$C600 entry)

#### Typical Slot 6 Configuration

- **ROM Address:** \$C600-\$C6FF
- **IWM Base:** \$C600 (phasing registers at \$C680-\$C68F)
- **Slot Index (X register):** \$60 (6 \<\< 4)

#### Multi-Slot Support

The Disk II controller can be placed in any slot (typically 6 or 5):

- Slot 5: ROM at \$C500-\$C5FF, IWM at \$C580-\$C58F
- Slot 6: ROM at \$C600-\$C6FF, IWM at \$C680-\$C68F
- Slot 7: ROM at \$C700-\$C7FF, IWM at \$C780-\$C78F

------------------------------------------------------------------------

### Technical Implementation Notes

#### 6502 Optimization Techniques

1.  **Self-Modifying Code:** Some tight loops modify branch targets for
    efficiency
2.  **Indexed Addressing:** Heavy use of `LDA addr,X` for slot-relative
    hardware access
3.  **Indirect Addressing:** `LDA (data_ptr),Y` for buffer access
4.  **Branch Optimization:** Careful branch placement to avoid page
    boundary crosses

#### Disk Timing

- **Byte Timing:** ~32 microseconds per byte at 1MHz 6502
- **Seek Timing:** ~3ms per track (stepper motor speed)
- **Track 0 Seek:** Blind seek (~200ms worst case)
- **Sector Search:** Variable, depends on disk rotation

#### Error Handling

The DISK ROM has minimal error handling:

- **Infinite Retry:** If sector not found, continues searching same
  track
- **No Timeout:** Will hang if disk has errors
- **No Reporting:** Failures are silent (user sees black screen)

------------------------------------------------------------------------

### Cross-Reference

#### Related Firmware Routines

- \[MON_WAIT\] (\$FCA8) - Delay routine (referenced by Disk II ROM)
- \[MON_IORTS\] (\$FF58) - Slot detection routine (referenced by Disk II
  ROM)
- **BOOT1** - Secondary bootstrap code (loaded by DISK ROM, not
  documented here)

#### Related Documentation

- **IWM Hardware:** See Apple Disk II Technical Manual
- **6+2 Encoding:** See Beneath Apple ProDOS (Weiss & Luther)
- **Boot Sequence:** See AppleWin emulator documentation

#### Memory Locations

- \[TWOS_BUFFER\] (\$0300-\$0355) - 2-bit chunk buffer
- \[CONV_TAB\] (\$0356-\$03D5) - 6+2 decoder table
- \[BOOT1\] (\$0800-\$0BFF) - Bootstrap code buffer

------------------------------------------------------------------------

### Implementation Considerations

#### For Emulator Development

Emulating the DISK ROM requires:

1.  **IWM Hardware Emulation:** Stepper motor, drive motor, read/write
    head
2.  **Disk Image Format:** Support for 140KB 5.25” disk images
3.  **6+2 Encoding:** Decode sector data correctly
4.  **Timing:** Approximate boot timing (~1-2 seconds)

#### For Clean-Room Implementation

A clean-room DISK ROM would need:

1.  **IWM Interface:** Understanding of each hardware register’s
    function
2.  **6+2 Algorithm:** Correct implementation of encoder/decoder
3.  **Sector Format:** Track/sector/data layout on disk
4.  **Timing:** Stepper motor stepping speed and settle time
5.  **Compatibility:** Must work with standard 140KB disk images

------------------------------------------------------------------------

### Disk II ROM References

### Disk II ROM References

**Documentation Sources:**

- ProDOS 8 Technical Note \#15 - SmartPort and block device protocols

------------------------------------------------------------------------

### Disk II ROM Notes

- This documentation covers the standard Disk II controller ROM found in
  Apple II, II+, IIe, and IIc systems
- Enhanced Disk II controllers (third-party) may have variations in
  implementation
- Later Apple systems (IIgs) use different disk controllers (3.5”
  drives)
- This ROM is typically auto-detected when a Disk II controller is
  present in an expansion slot
