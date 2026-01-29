### <a id="hardware-variants-and-identification"></a>Hardware Variants and Identification

#### Overview

The Apple II family encompasses multiple 8-bit hardware variants spanning over a decade of evolution. Each variant has different capabilities, memory configurations, and peripheral support. Firmware and software can detect which hardware variant is present using standardized identification bytes stored in ROM at fixed addresses.

This section documents the official Apple hardware identification methods as specified in Apple II Miscellaneous Technical Notes #7 and #2.

**References:**

- Apple II Miscellaneous Technical Note #7: *Apple II Family Identification* (https://prodos8.com/docs/technote/misc/07/)
- Apple II Miscellaneous Technical Note #2: *Apple II Family Identification Routines 2.2* (https://prodos8.com/docs/technote/misc/02/)

#### Apple II Family Models (8-bit)

**Core Models:**

- **Apple II** (1977) - Original model, 6502 CPU @ 1 MHz, 4KB-48KB RAM, cassette interface
- **Apple II+** (1979) - 6502 CPU @ 1 MHz, enhanced ROM, Applesoft BASIC, auto-start ROM
- **Apple IIe** (1983) - 6502 or 65C02 CPU @ 1.023 MHz, 64K RAM or 128K RAM with auxiliary memory support (requires Extended 80-Column Card), lowercase, 80-column text capability (requires 80-Column Card)
- **Apple IIe Enhanced** (1985) - 65C02 CPU, enhanced ROM, improved monitor, additional routines
- **Apple IIc** (1984) - 65C02 CPU @ 1.023 MHz, integrated design, 128K RAM, built-in peripherals, ROM banking
- **Apple IIc Plus** (1988) - 65C02 CPU @ 4 MHz, final 8-bit model, accelerated processor, enhanced instruction set, cache memory

**Special Variants:**

- **Apple IIe Card** (1991) - IIe emulation card for Macintosh LC, 65C02 CPU
- **Apple ///** - 6502-based system with Apple II emulation mode

**Out of Scope:**

- **Apple IIgs** (16-bit, 65C816 CPU) - Can be detected via [IDRoutine](#idroutine-fe1f) but behavior not documented in this specification

**Processor Note:** The 65C02 is an enhanced version of the 6502 with additional instructions, bug fixes, and lower power consumption. The IIc Plus uses the 65C02 at 4 MHz (compared to ~1 MHz in other models), providing significantly faster performance while maintaining instruction-level compatibility.

#### Identification Byte Locations

Apple provides standardized ROM identification bytes that software can read to determine hardware type and ROM revision. All identification bytes reside in the main ROM bank and must be read with main ROM switched in.

**Primary Identification Bytes:**

| Address | Apple II | Apple II+ | Apple /// | IIe | IIe Enhanced | IIe Card | IIc |
|---------|----------|-----------|-----------|-----|--------------|----------|-----|
| **$FBB3** | $38 | $EA | $EA | $06 | $06 | $06 | $06 |
| **$FB1E** | - | $AD | $8A | - | - | - | - |
| **$FBC0** | - | - | - | $EA | $E0 | $E0 | $00 |
| **$FBDD** | - | - | - | - | - | $02 | - |

**ROM Revision Bytes:**

| Address | Purpose | Values |
|---------|---------|--------|
| **$FBBF** | IIc ROM revision | $FF = original, $00 = 3.5 ROM, $03 = Mem.Exp., $04 = Rev.Mem.Exp., $05 = IIc Plus |
| **$FBBE** | IIe Card version | $00 = first release |

**Note:** The Apple IIgs (16-bit system, out of scope) matches enhanced IIe identification bytes. Use the [IDRoutine](#idroutine-fe1f) at $FE1F to distinguish IIgs from 8-bit systems.

#### Hardware Detection Algorithm

To correctly identify an Apple II variant, use the following procedure:

**Step 1: Test for 16-bit System (Optional)**

If your software needs to distinguish 8-bit from 16-bit systems, call [IDRoutine](#idroutine-fe1f) at $FE1F:

```
SEC         ; Set carry flag
JSR $FE1F   ; Call IDRoutine
BCS IS_8BIT ; Carry still set = 8-bit system
; Carry clear = 16-bit system (IIgs, out of scope)
```

If targeting only 8-bit systems, this step may be skipped.

**Step 2: Identify 8-bit Model**

Read $FBB3 to determine basic model family:

- **$FBB3 = $38:** Apple II (original)
- **$FBB3 = $EA:** Apple II+ or Apple /// (check $FB1E to distinguish)
  - $FB1E = $AD: Apple II+
  - $FB1E = $8A: Apple /// emulation mode

- **$FBB3 = $06:** IIe family (IIe, IIc, or IIe Card)

**Step 3: Identify IIe Family Variant**

If $FBB3 = $06, read $FBC0:

- **$FBC0 = $EA:** Original (unenhanced) Apple IIe
- **$FBC0 = $00:** Apple IIc family (read $FBBF for specific model)
- **$FBC0 = $E0:** Enhanced IIe or IIe Card (check $FBDD to distinguish)
  - $FBDD = $02: Apple IIe Card
  - $FBDD ≠ $02: Enhanced Apple IIe

**Step 4: Determine ROM Revision**

Within a model family, read the revision byte:

- **IIc family:** Read $FBBF
  - $FF = Apple IIc (original ROM)
  - $00 = Apple IIc (3.5 ROM)
  - $03 = Apple IIc (Memory Expansion)
  - $04 = Apple IIc (Revised Memory Expansion)
  - $05 = Apple IIc Plus (65C02 @ 4 MHz)

- **IIe Card:** Read $FBBE
  - $00 = First release

- **Enhanced IIe:** Read $FBBF (implementation-defined)

#### Model Constants

For software portability, use these standard model identification constants:

| Constant | Value | Model |
|----------|-------|-------|
| UNKNOWN | $00 | Unknown or unidentified system |
| APPLE_II | $01 | Apple II (original) |
| APPLE_II_PLUS | $02 | Apple II+ |
| APPLE_III_EM | $03 | Apple /// in emulation mode |
| APPLE_IIE | $04 | Apple IIe (includes enhanced and original) |
| APPLE_IIC | $05 | Apple IIc (all variants) |
| APPLE_IIE_CARD | $06 | Apple IIe Card for Macintosh LC |

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
- **Apple IIe:** Adds 80-column text (with card), double hi-res (with 128K)
- **Apple IIc:** Built-in 80-column, double hi-res

**ROM Organization:**

- **Apple II/II+:** 8KB ROM (12KB with autostart, can be shadowed in language card $D000-$FFFF)
- **Apple IIe:** 16KB ROM (main and auxiliary/slot ROM areas)
- **Apple IIc:** 16KB or 32KB ROM (banked via $C028)

**Processor:**

- **Apple II/II+:** 6502 @ 1.023 MHz
- **Apple IIe (original):** 6502 @ 1.023 MHz
- **Apple IIe (enhanced):** 65C02 @ 1.023 MHz
- **Apple IIc family:** 65C02 @ 1.023 MHz
- **Apple IIc Plus:** 65C02 @ 4 MHz (accelerated)

#### Variant-Specific Behaviors

**SLOTCXROM ($C006/$C007) and SLOTC3ROM ($C00A/$C00B):**

These soft switches control ROM selection in the $C100-$CFFF peripheral ROM area:

- **Apple IIe:** Switches between slot ROM cards and internal ROM
  - $C006 write = 0: Use slot ROMs
  - $C007 write = 1: Use internal ROM
  - $C00A write = 0: Use internal $C300 ROM
  - $C00B write = 1: Use slot 3 ROM for $C300

- **Apple IIc:** No effect (always uses internal ROM, no physical slots)

**Internal $C3xx ROM Selection (IIe-specific):**

On the Apple IIe, accessing any address in page $C3 ($C300-$C3FF) automatically selects internal ROM for the $C800-$CFFF range. This internal ROM selection remains active until an address in $C1xx, $C2xx, $C4xx-$C7xx, or $CFFF is accessed.

This behavior does not apply to Apple IIc (which always uses internal ROM).

**Cassette Interface:**

- **Apple II/II+:** Hardware cassette interface, monitor commands for tape I/O
- **Apple IIe/IIc:** No cassette interface (use serial or disk)

**Built-in Peripherals:**

- **Apple II/II+/IIe:** All peripherals via expansion slots
- **Apple IIc:** Built-in disk controller, serial ports, mouse interface

#### Hardware Identification Implementation Requirements

**For Clean-Room ROM Implementation:**

1. **Provide Identification Bytes:** Place appropriate values at documented addresses ($FBB3, $FBC0, etc.) based on target system
2. **Implement IDRoutine:** 8-bit systems should provide a single RTS instruction at $FE1F
3. **Ensure Main ROM Access:** ID bytes must be readable from main ROM bank (not auxiliary or banked ROM)
4. **Choose Revision Values:** ROM revision bytes ($FBBF, $FBBE) can be implementation-defined within model family
5. **Document Variant Features:** Clearly mark which features are model-specific (e.g., "[IIc only]", "[IIe+]")

**For Software Compatibility:**

1. **Switch in Main ROM:** Ensure main ROM is selected before reading ID bytes
2. **Follow Check Order:** Use documented detection algorithm to avoid misidentification
3. **Don't Assume Features:** Verify capabilities based on detected model (don't assume 128K, 80-column, slots, etc.)
4. **Handle Missing Features Gracefully:** Software should degrade gracefully when optional features (80-column, auxiliary RAM) are absent

#### See Also

- **[IDRoutine ($FE1F)](#idroutine-fe1f)** - System identification entry point
- **[RAM Initialization and Memory Detection](#ram-initialization-and-memory-detection)** - Memory configuration details
- **[ROM Organization and Banking](#rom-organization-and-banking)** - ROM banking and structure
- **[I/O and Soft Switches](#io-and-soft-switches)** - Soft switch reference including SLOTCXROM/SLOTC3ROM
