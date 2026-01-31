### <a id="memory-system"></a>Memory System

#### Overview

The Apple II memory architecture uses the 6502 processor's 64KB address space ($0000-$FFFF) to provide system RAM, peripheral I/O, and firmware ROM. Different models in the Apple II family have varying memory configurations, from 48KB in early systems to 128KB in later models with auxiliary memory support.

#### Memory Map

The complete 64KB address space is organized as follows:

| Address Range | Size | Purpose |
|---------------|------|---------|
| $0000-$00FF | 256 bytes | Zero-page memory (fast-access system variables) |
| $0100-$01FF | 256 bytes | 6502 stack (subroutine calls, interrupts) |
| $0200-$02FF | 256 bytes | Input buffer and system workspace |
| $0300-$03FF | 256 bytes | System vectors and additional workspace |
| $0400-$07FF | 1KB | Text/Low-Res Page 1 (primary display page) |
| $0800-$0BFF | 1KB | Text/Low-Res Page 2 (secondary display page) |
| $0C00-$1FFF | 5KB | Free RAM |
| $2000-$3FFF | 8KB | High-Resolution Graphics Page 1 |
| $4000-$5FFF | 8KB | High-Resolution Graphics Page 2 |
| $6000-$95FF | ~14KB | Free RAM |
| $9600-$BFFF | ~10KB | DOS/ProDOS or free RAM |
| $C000-$C0FF | 256 bytes | I/O soft switches and hardware registers |
| $C100-$C7FF | 1.75KB | Peripheral slot ROMs ($Cn00-$CnFF per slot) |
| $C800-$CFFF | 2KB | Peripheral ROM expansion area |
| $D000-$FFFF | 12KB | ROM or bank-switched RAM (language card) |

#### Main RAM Organization (48K)

**Apple II and II+ Standard Configuration:**

Basic systems provide 48KB of main RAM organized as:

**System Area ($0000-$03FF, 1KB):**

- Zero page ($00-$FF): System variables, pointers, temporary storage
- Stack ($0100-$01FF): Subroutine return addresses, interrupt state
- Input buffer ($0200-$02FF): Monitor and BASIC command input
- System vectors ($0300-$03FF): Interrupt vectors, system pointers

**Display Memory ($0400-$0BFF, 2KB):**

- Text/Low-Res Page 1 ($0400-$07FF): Primary text screen
- Text/Low-Res Page 2 ($0800-$0BFF): Secondary text screen

**Graphics Memory ($2000-$5FFF, 16KB):**

- Hi-Res Page 1 ($2000-$3FFF): 8KB primary graphics
- Hi-Res Page 2 ($4000-$5FFF): 8KB secondary graphics

**Program Area:**

- $0C00-$1FFF: 5KB available immediately after display memory
- $6000-$95FF: ~14KB mid-memory area
- $9600-$BFFF: ~10KB high memory (often used by DOS/ProDOS)

#### Auxiliary RAM (Apple IIe/IIc - 64K)

Apple IIe (with 128K) and all IIc models include 64KB of auxiliary RAM occupying the same address space as main RAM, accessed via soft switches.

**Memory Architecture:**

- 64KB main RAM at $0000-$BFFF (plus bank-switched $D000-$FFFF)
- 64KB auxiliary RAM at $0000-$BFFF (same addresses, different bank)
- Total: 128KB accessible via bank switching

**Dual Zero Page and Stack:**

- Main zero page: $0000-$00FF in main RAM
- Auxiliary zero page: $0000-$00FF in auxiliary RAM
- Main stack: $0100-$01FF in main RAM
- Auxiliary stack: $0100-$01FF in auxiliary RAM
- Selected via AUXZP soft switch ($C008/$C009)

**Display Memory Interleaving:**

For 80-column text and double high-resolution graphics, display memory is interleaved:

- Even columns/pixels: Auxiliary RAM
- Odd columns/pixels: Main RAM
- Hardware automatically interleaves during video generation

#### Bank-Switched Language Card (16K)

The language card provides 16KB of RAM in the $D000-$FFFF address space for loading alternate languages or user programs.

**Memory Organization:**

- $D000-$DFFF: Bank 1 or Bank 2 (4KB, selectable)
- $E000-$FFFF: Common area (12KB, same in both banks)
- Total: 16KB (two 4KB banks + one 12KB common)

**Banking Mechanism:**

Controlled via soft switches at $C080-$C08F. See [ROM Organization and Banking](#rom-organization-and-banking) for complete details.

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
- Built-in ROM banking ($C028)

**Apple IIe Card (1991):**

- 128KB standard (64KB main + 64KB auxiliary)
- Dual memory banks
- Emulates enhanced IIe

#### Address Range Details

**Zero Page ($0000-$00FF):**

Fast-access memory for system variables and temporary storage. Used extensively by:

- Monitor routines (pointers, counters)
- BASIC interpreter (variable storage)
- DOS/ProDOS (file system state)

See [Zero-Page Definitions](#zero-page-definitions) for complete variable reference.

**Stack ($0100-$01FF):**

Hardware stack used by 6502 processor for:

- JSR/RTS return addresses
- Interrupt state (processor status, PC)
- PHA/PLA temporary storage
- Local variables

Grows downward from $01FF. Stack overflow occurs if it wraps below $0100.

**Input Buffer ($0200-$02FF):**

Command-line input buffer used by Monitor for storing user-entered commands. Also used by:

- BASIC GET/INPUT statements
- DOS/ProDOS file operations
- Application input buffering

**System Vectors ($0300-$03FF):**

Contains interrupt vectors, system entry points, and control flags:

- SOFTEV ($03F2-$03F3): Warm start entry point
- PWREDUP ($03F4): Power-up detection byte
- BRKV ($03F0-$03F1): Break handler vector
- IRQLOC ($03FE-$03FF): IRQ handler vector

See [System Boot and Initialization](#system-boot-and-initialization) for vector usage.

**Display Pages ($0400-$0BFF):**

Two 1KB text/low-res pages supporting page flipping:

- Page 1 ($0400-$07FF): Default display page
- Page 2 ($0800-$0BFF): Alternate page

Each page organized as 24 rows of 40 bytes (960 bytes used, 64 bytes holes per page).

**Graphics Pages ($2000-$5FFF):**

Two 8KB high-resolution graphics pages:

- Page 1 ($2000-$3FFF): Primary hi-res graphics
- Page 2 ($4000-$5FFF): Secondary hi-res graphics

Each page: 192 scan lines, interleaved addressing pattern.

**Peripheral I/O ($C000-$C0FF):**

Memory-mapped I/O for hardware control:

- $C000-$C00F: Display mode soft switches
- $C010-$C01F: Status registers and additional switches
- $C020-$C02F: Cassette, speaker, and other I/O
- $C030-$C05F: Graphics mode switches
- $C060-$C06F: Paddle/joystick inputs and push buttons
- $C070-$C07F: Game controller timing
- $C080-$C08F: Language card control
- $C090-$C0FF: Peripheral card I/O (slot-specific)

See [I/O and Soft Switches](#io-and-soft-switches) for complete reference.

**Slot ROM Area ($C100-$CFFF):**

Peripheral expansion ROM space organized by slot:

- $Cn00-$CnFF: ROM for slot n (n = 1-7)
- $C800-$CFFF: 2KB expansion ROM area (bank-switched per slot)

IIe can switch between slot ROMs and internal ROMs via SLOTCXROM ($C006/$C007).

**ROM Area ($D000-$FFFF):**

System firmware ROM containing:

- $D000-$F7FF: BASIC interpreter (10KB; historically Integer BASIC or Applesoft BASIC depending on system/firmware)
- $F800-$FFFF: Monitor and system routines (2KB)

Can be shadowed by language card RAM on II/II+/IIe systems.

#### Memory System Implementation Notes

**For Clean-Room ROM Implementation:**

1. **Support Variable Memory Sizes:**
   - Detect installed RAM during boot
   - Set HIMEM appropriately
   - Handle both 48K and 64K configurations

2. **Initialize Memory Properly:**
   - Clear screen memory on cold start
   - Preserve user programs on warm start
   - Set system variables to known states

3. **Respect Memory Boundaries:**
   - Don't overwrite zero page during initialization
   - Protect stack area
   - Preserve user program area on RESET

4. **Document Memory Requirements:**
   - Minimum RAM for firmware operation
   - Which features require 128K
   - Language card vs. auxiliary RAM tradeoffs

**For Software Compatibility:**

1. **Detect Memory Configuration:**
   - Test for language card presence
   - Test for auxiliary memory
   - Don't assume 128K available

2. **Use Standard Memory Areas:**
   - Zero page locations as documented
   - Standard display pages
   - Input buffer conventions

3. **Handle Page Alignment:**
   - Display pages on 1KB boundaries
   - Graphics pages on 8KB boundaries
   - Slot ROM on 256-byte boundaries

#### See Also

- **[System Boot and Initialization](#system-boot-and-initialization)** - Boot-time memory initialization and configuration
- **[I/O and Soft Switches](#io-and-soft-switches)** - Auxiliary RAM mapping soft switches
- **[ROM Organization and Banking](#rom-organization-and-banking)** - ROM structure and language card
- **[Zero-Page Definitions](#zero-page-definitions)** - System variable reference
- **[Hardware Variants and Identification](#hardware-variants-and-identification)** - Model-specific memory configurations
