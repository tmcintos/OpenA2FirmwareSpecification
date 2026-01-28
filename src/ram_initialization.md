## RAM Initialization and Memory Detection

### Overview

Apple II firmware performs memory initialization during the boot sequence to establish the system's memory configuration. The initialization process varies by model, with later models (IIe/IIc) featuring fixed memory configurations and earlier models (II/II+) performing runtime detection.

### Memory Architecture by Model

**Apple II and II+ (Variable Configuration):**

- Minimum: 4KB (on motherboard)
- Typical: 48KB (4KB motherboard + 44KB expansion)
- Maximum: 64KB with language card (48KB + 16KB bank-switched)

**Apple IIe and IIc (Fixed Configuration):**

- Standard: 128KB total
  - 64KB main RAM ($0000-$BFFF and bank-switched $D000-$FFFF)
  - 64KB auxiliary RAM (same address range, accessed via soft switches)
- All models include auxiliary memory; detection not required

### Cold Start Memory Initialization

During cold start (power-on or hardware reset without valid warm-start signature), the firmware performs memory initialization to prepare the system for operation.

**COLDSTART Routine Behavior:**

The cold start initialization routine clears screen memory and initializes system variables:

1. **Clear screen memory** from upper memory (typically $BFXX) down to $0200
2. **Fill cleared area** with space characters ($A0 = ASCII space with high bit set)
3. **Preserve zero page** ($00-$FF) to avoid destroying firmware variables
4. **Preserve stack** ($0100-$01FF) to maintain execution context
5. **Initialize soft switches** (IIe/IIc) to default display mode
6. **Set system variables** to known states

**Implementation Approach (Pseudocode):**

```
procedure COLDSTART:
    for page from $BF down to $02:
        for offset from $FF down to $00:
            write $A0 (space character) to address page:offset
        end
    end
    initialize display soft switches to defaults
    set system variables to initial state
end
```

**Key Requirements:**

- Must not overwrite zero page or stack during clearing
- Should clear at least text screen memory ($0400-$07FF)
- May clear additional memory up to top of available RAM
- IIe/IIc implementations should initialize auxiliary memory soft switches

### Memory Size Storage Locations

The Apple II firmware does not maintain a dedicated "total RAM size" variable. Instead, memory bounds are tracked through:

**Key Memory Pointers:**

- **LOMEM** ($0800): Lowest address used by BASIC/programs (typically $0800 = 2048)
- **HIMEM**: Highest address available to BASIC/programs
  - 48KB systems: $9600 (38400 decimal)
  - 64KB systems with language card: $BF00 (48896 decimal)

**Zero-Page Temporaries:**

- **$3C-$3D (A1L/A1H)**: Monitor address pointer 1
- **$3E-$3F (A2L/A2H)**: Monitor address pointer 2
- **$4A-$4B (TEMPPTR)**: Temporary pointer (must be last two zero-page bytes available to Monitor)

### RAM Size Detection (Apple II/II+)

Early Apple II models perform a simple memory test during cold start to determine available RAM:

**Detection Algorithm (Behavioral Description):**

The firmware tests for RAM presence by writing and reading back test patterns at progressively higher addresses:

1. **Write test pattern** to a memory location
2. **Read back** and verify pattern matches
3. **Write complementary pattern** to same location
4. **Read back** and verify second pattern matches
5. If both patterns verify correctly, **RAM exists** at that address
6. **Repeat** for next higher address block
7. **Set HIMEM** to highest confirmed address with working RAM

**Typical Test Pattern Approach:**

The firmware uses complementary bit patterns to verify RAM cells can hold both 0 and 1 values:

- First pattern: Alternating bits (e.g., binary 01010101)
- Second pattern: Inverted bits (e.g., binary 10101010)

If a location fails to hold either pattern, it indicates:

- No RAM installed at that address, or
- Defective RAM that cannot reliably store data

The test continues until reaching maximum possible address ($BFFF for 48K systems) or detecting absence of RAM.

**Apple IIe/IIc (Fixed Memory):**

These models **do not perform RAM size detection** because memory configuration is fixed at 128KB. The firmware assumes:

- Main RAM: 64KB ($0000-$BFFF + bank-switched $D000-$FFFF)
- Auxiliary RAM: 64KB (same addresses, accessed via soft switches)

### Warm Start Detection

To avoid unnecessary re-initialization on RESET, the firmware checks for a warm-start signature indicating the system was previously initialized.

**Warm Start Magic Bytes:**

- **$03F4 (PWREDUP)**: Power-up detection byte
- **$03F2-$03F3 (SOFTEV)**: Soft-entry vector for warm start

**Detection Algorithm:**

The firmware computes: `SOFTEV XOR PWREDUP`

If the result equals `$A5`, the system recognizes a valid warm start:

- System was previously initialized
- Memory contents are preserved
- Skip memory test and clearing
- Jump directly to SOFTEV address (typically Monitor or BASIC)

If the result does not equal `$A5`, perform cold start:

- Complete system initialization required
- Perform memory test and clearing
- After initialization, set PWREDUP to establish warm-start signature:
  - `PWREDUP = (SOFTEV_LOW XOR $A5)`
- Continue with normal boot sequence

**Purpose:**

This mechanism allows the RESET button to return to Monitor/BASIC without destroying:

- User programs in memory
- BASIC program text
- System configuration
- Data in RAM

The warm-start signature establishes that the system is in a known-good state and doesn't require full re-initialization.

### Memory Configuration State

**Memory State Encoding (IIc/IIe):**

The system tracks memory configuration in a packed byte format used during interrupt handling:

| Bit | Meaning |
|-----|---------|
| D7 | 1 if using auxiliary zero page/stack |
| D6 | 1 if 80STORE enabled and PAGE2 on |
| D5 | 1 if reading from auxiliary RAM |
| D4 | 1 if writing to auxiliary RAM |
| D3 | 1 if language card RAM enabled |
| D2 | 1 if language card bank 1 selected |
| D1 | 1 if language card bank 2 selected |
| D0 | 1 if alternate ROM bank selected |

This encoding allows firmware to save and restore complete memory configuration across interrupt service routines.

### Address Ranges

**Main RAM (48KB accessible):**

- **$0000-$00FF**: Zero page (variables, pointers)
- **$0100-$01FF**: Stack page
- **$0200-$03FF**: Input buffer, system variables
- **$0400-$07FF**: Text/Low-Resolution Page 1
- **$0800-$0BFF**: Text/Low-Resolution Page 2
- **$0C00-$1FFF**: Free RAM
- **$2000-$3FFF**: High-Resolution Page 1
- **$4000-$5FFF**: High-Resolution Page 2
- **$6000-$95FF**: Free RAM
- **$9600-$BFFF**: DOS/ProDOS system area (or free RAM)

**Bank-Switched RAM ($D000-$FFFF, 16KB):**

- **$D000-$DFFF**: Bank 2 or Bank 1 (4KB, selectable)
- **$E000-$FFFF**: Fixed bank (12KB)

**Auxiliary RAM (IIe/IIc only):**

- Same address range as main RAM
- Accessed via soft switches at $C002-$C009
- Used for 80-column text display and additional program storage

### Implementation Notes

**For Clean-Room ROM Implementation:**

1. **Cold Start:** Always perform COLDSTART routine on power-up or when warm-start signature invalid
2. **Warm Start:** Check PWREDUP/SOFTEV; if valid, skip initialization and jump to SOFTEV
3. **Memory Clearing:** Clear only screen memory and essential system variables; avoid clearing entire RAM on RESET
4. **LOMEM/HIMEM:** Set appropriate defaults based on target system (4KB ROM can use simpler fixed values)
5. **Auxiliary RAM (IIe/IIc only):** Initialize soft switches to default state (auxiliary disabled, main RAM active)

**Memory Test Considerations:**

- Full memory test on every boot is slow and unnecessary for modern implementations
- Consider quick checksum verification instead of full pattern test
- Preserve user programs in RAM during RESET (only clear system variables)
- Language card RAM should be tested separately if implementing bank-switching support

### See Also

- [Reset](#reset-fa62) - System reset entry point
- [PwrUp](#pwrup-faa6) - Power-up initialization routine
- [Auxiliary RAM and Memory Soft Switches](#auxiliary-ram-and-memory-soft-switches) - Extended memory documentation for IIe/IIc
