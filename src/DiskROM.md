# Disk II Controller ROM Specification

## Overview

The Disk II Controller ROM is located at the slot-relative address $Cn00 (where n is the slot number, typically slot 6 giving $C600). This 256-byte ROM contains the boot loader ("BOOT0") that initializes disk operations and loads the secondary boot loader (BOOT1) from disk into memory.

**Source:** Disassembled from `C600ROM Disassembly.html` (AppleWin extraction)  
**Size:** 256 bytes ($C600-$C6FF)  
**Architecture:** 6502 assembly (Disk II controller boot code)  
**Primary Function:** Disk boot loader and initialization

---

## Architecture & Memory Layout

### ROM Address Space
- **Base Address:** $Cn00 (where n = slot number, 1-7)
- **Typical Slot:** 6 (address $C600)
- **Size:** 256 bytes ($C600-$C6FF)
- **Entry Point:** $C600 (when selected as boot ROM)

### Code Organization
```
$C600-$C602   Initialization & setup
$C603-$C650   6+2 decoder table generation
$C651-$C65B   Blind seek to track 0
$C65C-$C6D3   Read sector routine (core)
$C6D4-$C6FB   Decode 6+2 data & loop control
$C6FC-$C6FF   Spare bytes
```

---

## Hardware Interface

### IWM (Integrated Woz Machine) Registers

The Disk II controller uses the IWM chip for low-level disk operations. Access is via memory-mapped I/O in the slot I/O area ($C000-$C0FF).

#### Drive Control Registers

| Address | Slot-Relative | Name | Function |
|---------|----------------|------|----------|
| $C080 + n*$100 | $80 | IWM_PH0_OFF | Stepper motor phase 0 off |
| $C081 + n*$100 | $81 | IWM_PH0_ON | Stepper motor phase 0 on |
| $C082 + n*$100 | $82 | IWM_PH1_OFF | Stepper motor phase 1 off |
| $C083 + n*$100 | $83 | IWM_PH1_ON | Stepper motor phase 1 on |
| $C084 + n*$100 | $84 | IWM_PH2_OFF | Stepper motor phase 2 off |
| $C085 + n*$100 | $85 | IWM_PH2_ON | Stepper motor phase 2 on |
| $C086 + n*$100 | $86 | IWM_PH3_OFF | Stepper motor phase 3 off |
| $C087 + n*$100 | $87 | IWM_PH3_ON | Stepper motor phase 3 on |
| $C088 + n*$100 | $88 | IWM_MOTOR_OFF | Stop drive motor |
| $C089 + n*$100 | $89 | IWM_MOTOR_ON | Start drive motor |
| $C08A + n*$100 | $8A | IWM_SELECT_DRIVE_1 | Select drive 1 |
| $C08B + n*$100 | $8B | IWM_SELECT_DRIVE_2 | Select drive 2 |
| $C08C + n*$100 | $8C | IWM_Q6_OFF | Read mode (prepare data read) |
| $C08D + n*$100 | $8D | IWM_Q6_ON | Write mode (prepare write) |
| $C08E + n*$100 | $8E | IWM_Q7_OFF | Read Write-Protect / Read mode |
| $C08F + n*$100 | $8F | IWM_Q7_ON | Write mode / Write data |

**Slot-Relative Addressing Formula:**

The actual memory address for any IWM register depends on the disk controller's slot location:

```
Register Address = $C000 + (slot_number << 8) + register_offset
                 = $Cn00 + register_offset
```

Where:
- `slot_number` = Slot number (1-7, typically 6)
- `register_offset` = Register address offset ($80-$8F)

**Examples for common slots:**
- Slot 6 (typical): $C600 + $80 = $C680 (first phase control)
- Slot 5: $C500 + $80 = $C580
- Slot 1: $C100 + $80 = $C180

**Important:** ROM implementations must use indexed addressing to remain slot-independent:

```
; Assume X = (slot_number << 4), e.g., X = $60 for slot 6
LDA $C080,X     ; Load from appropriate slot's IWM register
STA $C089,X     ; Store to appropriate slot's motor-on register
```

This allows the ROM to work in any slot without hardcoding addresses. Absolute addressing (e.g., `LDA $C680`) would restrict the ROM to a specific slot.

### I/O Data Ports

| Address | Slot-Relative | Name | Direction | Function |
|---------|---|---|---|---|
| $C08C + n*$100 | $8C | DATA_IN | Read | Read data from disk (requires Q6=0, Q7=0) |
| $C08D + n*$100 | $8D | STATUS | Read/Write | Check write-protect (read); initialize Q6 (write) |
| $C08E + n*$100 | $8E | IWM_SEQUENCER | Read/Write | Reset state sequencer (read); write-protect check (read) |
| $C08F + n*$100 | $8F | DATA_OUT | Write | Write data to disk (requires indexed addressing) |

**Data Transfer:**
- **Reading:** Disk controller places bytes on data bus; 6502 reads via indexed addressing
- **Writing:** 6502 writes via indexed addressing; controller accepts only on synchronized clock pulses

### Logic State Sequencer (CRITICAL for Write Operations)

The disk controller includes a hardware-based **logic state sequencer** that must be synchronized with the software write loop. This is essential for correct disk write operations.

**State Sequencer Timing Constraint:**

The controller will accept write data ONLY on specific clock pulses:
1. The clock pulse immediately AFTER the one that started the sequencer
2. Then every fourth clock pulse thereafter

**CRITICAL - Addressing Mode Requirements for Write Operations:**

The addressing mode used for write operations is NOT a stylistic choice—it directly affects hardware synchronization:

**CORRECT (Indexed Addressing):**
```
STA $C080,X     ; X = slot_number << 4 (e.g., $60 for slot 6)
STA $C08F,X     ; Write data - uses indexed addressing
```

**Also Correct (Indirect Indexed):**
```
STA (ZP),Y      ; Indirect indexed (no page crossing)
```

**BROKEN (Absolute Addressing):**
```
STA $C08F       ; WILL NOT WORK - causes 1-clock desynchronization
                ; Controller will reject all write data
```

The indexed addressing mode takes an extra cycle that synchronizes the write operation with the state sequencer's 4-cycle timing. Absolute addressing executes one clock too soon, causing the controller to be out of sync.

**Write Protect Check and State Sequencer Reset Sequence:**

Before attempting write operations, the ROM must check write protection and reset the sequencer:

```
; X = $60 for slot 6 (or slot_number << 4)
LDA $C08D,X         ; Check write protect flag
LDA $C08E,X         ; Reset state sequencer to idle location
BMI WPROTECT        ; Branch if write protected (N flag set)
```

This sequence:
1. Checks if the disk is write-protected (returns with N flag set if protected)
2. Resets the sequencer to its idle state for the next operation
3. Prepares for the next read or write sequence

### Firmware ROM References

The DISK ROM calls or references:
- **$FCA8** [MON\_WAIT] - Delay routine for timing-critical operations
- **$FF58** [MON\_IORTS] - System identification / slot detection

### Slot Detection Using IORTS

The Disk II ROM does not require knowledge of which slot it occupies; instead, it can determine its slot at runtime by calling [IORTS](#iorts-ff58) ($FF58). This routine provides a generic mechanism for peripheral ROMs to identify their installed slot:

**Slot Detection Method:**

When a peripheral ROM is executing in slot n (at $Cn00-$CnFF), it can determine its slot number as follows:

1. **Call IORTS via JSR $FF58** - This calls a simple RTS instruction in main firmware
2. **The return address is pushed to the stack** - The return address ($Cn00 + offset within the ROM) is pushed by JSR
3. **Read return address high byte** - Extract the high byte from the stack using TSX and indexed addressing
4. **Convert to slot offset** - Multiply the high byte by 16 (via 4 left shifts) to get the slot offset for indexed I/O addressing

**Assembly Example:**

```
        JSR     $FF58           ; Call IORTS (pushes return address onto stack)
        TSX                     ; Transfer S register to X (X = stack offset)
        LDA     $0100,X         ; Read return address high byte ($Cn) from stack
        ASL     A               ; Shift left 4 times to convert $Cn to $Cn0
        ASL     A               ; (multiply by 16 for slot-relative addressing)
        ASL     A
        ASL     A
        TAX                     ; X now = slot_number << 4 (for indexed I/O access)
```

**Why This Works:**

When the firmware calls the peripheral ROM via `JMP (LOC0)` where LOC0 points to $Cn00, the ROM executes at address $Cn00-$CnFF. When the ROM calls `JSR $FF58` (IORTS):
- The return address ($Cn00 + offset) is automatically pushed onto the 6502 stack
- IORTS is just an RTS instruction that immediately returns
- The peripheral ROM can read its own return address from the stack to determine n (the slot number)
- Converting the high byte via 4 left shifts produces the slot index for use in indexed I/O operations

This elegant mechanism allows peripheral ROMs to be completely slot-independent; they don't need slot information passed in a register or stored in ROM—they determine their own slot by examining the return address on the stack.

---

## Memory Layout

### Data Buffers

| Address | Size | Name | Purpose |
|---------|------|------|---------|
| $0100-$01FF | 256 | STACK | 6502 stack (system-wide) |
| $0200-$02FF | 256 | (reserved) | General purpose RAM |
| $0300-$0355 | 86 | TWOS_BUFFER | 2-bit chunk buffer for 6+2 decoding |
| $0356-$03D5 | 128 | CONV_TAB | 6+2 conversion decoder table |
| $03D6-$07FF | ~1.5KB | (available) | General purpose RAM |
| $0800-$0BFF | 1024 | BOOT1 | Secondary boot loader code |

### Zero-Page Variables (DISK ROM use)

| Address | Name | Purpose |
|---------|------|---------|
| $26-$27 | data_ptr | Pointer to BOOT1 data buffer location |
| $2B | slot_index | Slot number << 4 (for IWM register addressing) |
| $3C | bits | Temporary storage for bit manipulation during 6+2 decoding |
| $3D | sector | Sector number being read |
| $40 | found_track | Track found during seek |
| $41 | track | Track to read |

---

## Entry Points

### ENTRY ($C600)

**Description:**

The main boot entry point. When invoked (typically via reset vector jumping to $Cn01, which relative-jumps to $C600), this routine initializes the Disk II controller and loads the bootstrap code (BOOT1).

**Execution Sequence:**

1. **Initialize Controller:**
   - Load slot index (X = $20, which expands to slot 6 << 4)
   - Set up data pointer to BOOT1 buffer ($0800)
   - Initialize sector counter to 0

2. **Generate 6+2 Decoder Table:**
   - Build lookup table in memory locations $0356-$03D5
   - Table allows decoding of 6+2 encoded disk data
   - Uses specific bit patterns that avoid sector header markers ($D5, $AA)

3. **Seek to Track 0:**
   - Perform blind seek (stepper motor pulse sequence)
   - Move disk head to outermost track position
   - Uses phase signals ($C080-$C087 equivalents)

4. **Read Disk Data:**
   - Read track 0, sector 0 (boot sector)
   - Call ReadSector to locate and read sector
   - Decode 6+2 encoded data into BOOT1 buffer
   - Continue reading additional sectors until BOOT1 is complete

5. **Transfer Control:**
   - Jump to $0801 (BOOT1 entry point)
   - BOOT1 continues system initialization

**Input:**

*   **Registers:** A, X, Y undefined
*   **Memory:** 
    - Stack must be available and initialized
    - RAM from $0300-$0BFF must be available
    - ROM selected in slot space

**Output:**

*   **Registers:** Undefined (transfers to BOOT1)
*   **Memory:**
    - TWOS_BUFFER ($0300-$0355): 6+2 conversion table generated
    - BOOT1 ($0800-$0BFF): Filled with bootstrap code from disk
    - Zero-page ($26, $2B, $3C-$41): Initialized for disk operations
*   **Transfer:** Control jumps to $0801 (BOOT1 code)

**Side Effects:**

*   IWM hardware registers accessed (stepper motor, drive motor)
*   Disk drive motor started and stopped
*   Disk head positioned to track 0
*   System memory modified ($0300-$0BFF range)
*   Interrupts may be affected by timing-critical operations

---

### ReadSector ($C65C)

**Description:**

Core disk read routine. Reads a single 256-byte sector from the currently selected track. The routine searches the disk for the requested sector by examining address mark patterns, then reads and decodes the sector data.

**Operation:**

1. **Find Address Mark:**
   - Scan disk data stream for address mark byte sequence ($D5 $AA $96)
   - Once found, extract track and sector numbers from address field

2. **Verify Track/Sector:**
   - Check that track number matches expected track
   - Check that sector number matches requested sector
   - If mismatch, continue scanning for next address mark

3. **Find Data Mark:**
   - Continue scanning for data mark sequence ($D5 $AA $AD)
   - Signals start of actual sector data

4. **Read & Decode:**
   - Read 342 bytes of 6+2 encoded data
   - Decode using CONV_TAB table into 256 bytes of actual data
   - Store in buffer pointed to by data_ptr

5. **Return:**
   - Return to caller with sector data decoded in buffer

**Input:**

*   **Registers:**
    - A: undefined
    - X: slot index (slot_number << 4) 
    - Y: undefined
*   **Memory:**
    - data_ptr ($26-$27): Must point to valid memory for 256 bytes
    - sector ($3D): Sector number to find and read (0-15)
    - track ($41): Track number being read
    - CONV_TAB ($0356-$03D5): Must be initialized with 6+2 decoder table
    - IWM registers accessible at $C000 + slot offset

**Output:**

*   **Registers:**
    - A: Undefined
    - X: Preserved (slot index still set)
    - Y: Incremented to 0 (after processing all 256 bytes)
*   **Memory:**
    - data_ptr+1 ($27): Incremented to next page
    - Sector data (256 bytes): Decoded and placed at address pointed by data_ptr
    - TWOS_BUFFER ($0300-$0355): May be partially modified during decoding

**Side Effects:**

*   IWM registers accessed for disk read
*   Timing-sensitive disk operations performed
*   Disk head may seek if sector not on current track
*   Memory access via indirect addressing (data_ptr)

---

## 6+2 Encoding & Decoding

### Why 6+2 Encoding?

The original Disk II drive hardware imposes constraints on allowable byte patterns:
- **Cannot have high bit clear:** All data bytes must have bit 7 set ($80-$FF range)
- **Cannot have consecutive zero bits:** Violates disk timing requirements
- **Special markers excluded:** Bytes $D5, $AA reserved for address/data marks

These constraints allow only 64 valid byte values from the 256-byte range. To encode 256 bytes of actual data, the Disk II uses **6+2 encoding:**

- Take 3 bytes of actual data = 24 bits
- Split into 6 bits + 6 bits + 6 bits + 2 bits (leftover 2 bits)
- Encode each 6-bit chunk as a valid disk byte
- Combine 2-bit chunk from last byte into its encoding
- Result: 4 bytes of encoded data from 3 bytes of actual data
- 256 bytes input → 342 bytes encoded output (256 × 4/3)

### Decoder Table Generation

The DISK ROM generates the decoder table at runtime (code $C603-$C650):

**Algorithm:**
1. For each value 0-63 (6-bit value):
   - Shift left and check for adjacent 1-bits
   - Combine with original, invert, and verify no three consecutive 0s
   - If valid: store at calculated table offset in $0356-$03D5

2. **Result:** Sparse lookup table with 64 valid entries among 128 possible positions

3. **Purpose:** Quickly decode 6-bit values from disk byte stream

---

## Boot Sequence

### Typical Boot Flow

```
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
```

### Sector Loading

The DISK ROM reads disk sectors and stores them in the BOOT1 buffer ($0800-$0BFF range):

- **Track:** Always 0 (boot sector is on track 0)
- **Sectors:** Read sequentially starting from sector 0
- **Stop Condition:** When sector number (in read data) exceeds first byte of BOOT1
  - BOOT1 code includes its own size as first byte
  - This allows variable-sized boot code

### IWM Timing

Critical timing operations use the MON\_WAIT routine ($FCA8):
- Provides delay for stepper motor settling
- Synchronizes with disk rotation
- Ensures reliable disk head positioning

---

## Slot Selection & Addressing

### Slot-Relative Addressing

The DISK ROM is slot-independent. When placed in slot n:
- Entry address: $Cn00 (not $C600)
- IWM registers accessed: $C080 + (n << 4)
- Invoked as: `JMP $Cn01` (relative jump to actual $C600 entry)

### Typical Slot 6 Configuration

- **ROM Address:** $C600-$C6FF
- **IWM Base:** $C600 (phasing registers at $C680-$C68F)
- **Slot Index (X register):** $60 (6 << 4)

### Multi-Slot Support

The Disk II controller can be placed in any slot (typically 6 or 5):
- Slot 5: ROM at $C500-$C5FF, IWM at $C580-$C58F
- Slot 6: ROM at $C600-$C6FF, IWM at $C680-$C68F
- Slot 7: ROM at $C700-$C7FF, IWM at $C780-$C78F

---

## Technical Implementation Notes

### 6502 Optimization Techniques

1. **Self-Modifying Code:** Some tight loops modify branch targets for efficiency
2. **Indexed Addressing:** Heavy use of `LDA addr,X` for slot-relative hardware access
3. **Indirect Addressing:** `LDA (data_ptr),Y` for buffer access
4. **Branch Optimization:** Careful branch placement to avoid page boundary crosses

### Disk Timing

- **Byte Timing:** ~32 microseconds per byte at 1MHz 6502
- **Seek Timing:** ~3ms per track (stepper motor speed)
- **Track 0 Seek:** Blind seek (~200ms worst case)
- **Sector Search:** Variable, depends on disk rotation

### Error Handling

The DISK ROM has minimal error handling:
- **Infinite Retry:** If sector not found, continues searching same track
- **No Timeout:** Will hang if disk has errors
- **No Reporting:** Failures are silent (user sees black screen)

---

## Cross-Reference

### Related Firmware Routines

- [MON\_WAIT] ($FCA8) - Delay routine (referenced by Disk II ROM)
- [MON\_IORTS] ($FF58) - Slot detection routine (referenced by Disk II ROM)
- **BOOT1** - Secondary bootstrap code (loaded by DISK ROM, not documented here)

### Related Documentation

- **IWM Hardware:** See Apple Disk II Technical Manual
- **6+2 Encoding:** See Beneath Apple ProDOS (Weiss & Luther)
- **Boot Sequence:** See AppleWin emulator documentation

### Memory Locations

- [TWOS_BUFFER] ($0300-$0355) - 2-bit chunk buffer
- [CONV_TAB] ($0356-$03D5) - 6+2 decoder table
- [BOOT1] ($0800-$0BFF) - Bootstrap code buffer

---

## Implementation Considerations

### For Emulator Development

Emulating the DISK ROM requires:
1. **IWM Hardware Emulation:** Stepper motor, drive motor, read/write head
2. **Disk Image Format:** Support for 140KB 5.25" disk images
3. **6+2 Encoding:** Decode sector data correctly
4. **Timing:** Approximate boot timing (~1-2 seconds)

### For Clean-Room Implementation

A clean-room DISK ROM would need:
1. **IWM Interface:** Understanding of each hardware register's function
2. **6+2 Algorithm:** Correct implementation of encoder/decoder
3. **Sector Format:** Track/sector/data layout on disk
4. **Timing:** Stepper motor stepping speed and settle time
5. **Compatibility:** Must work with standard 140KB disk images

---

## References

**Source File:** `C600ROM Disassembly.html` (in documentation directory)

**Extracted From:** AppleWin emulator source code

**Original Copyright:** Apple Computer Inc.

**Disassembly Tool:** 6502bench SourceGen v1.5 by Andy McFadden

---

## Notes

- This documentation covers the standard Disk II controller ROM found in Apple II, II+, IIe, and IIc systems
- Enhanced Disk II controllers (third-party) may have different ROM code
- Later Apple systems (IIgs) use different disk controllers (3.5" drives)
- This ROM is typically auto-detected when a Disk II controller is present in an expansion slot

