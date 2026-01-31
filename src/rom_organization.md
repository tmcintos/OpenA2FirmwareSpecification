### <a id="rom-organization-and-banking"></a>ROM Organization and Banking

#### Overview

Apple II family ROMs are organized differently depending on the model, with varying sizes, banking mechanisms, and memory layouts. Understanding ROM organization is essential for implementing compatible firmware and for software that needs to work across different Apple II variants.

This section documents ROM memory organization, banking mechanisms, and execution models for 8-bit Apple II systems.

#### ROM Memory Map by Model

**Apple II and II+ ($D000-$FFFF window; ROM content varies by firmware revision):**

- **$D000-$FFFF**: 12KB address space reserved for firmware and/or bank-switched RAM
  - $F800-$FFFF: Monitor ROM (2KB)
  - $D000-$F7FF: BASIC interpreter and related routines (implementation- and revision-dependent)

**Note:** Although software sees a 12KB window at $D000-$FFFF, early Apple II firmware revisions may not populate the entire $D000-$F7FF range with ROM (some systems place Integer BASIC primarily in the upper portion of that range, and the lower portion may be unused or occupied by optional ROM).

- Language card (when installed) can shadow this area with RAM

**Apple IIe (16KB ROM):**

- **$C100-$C7FF**: Slot peripheral ROM area (can be switched to internal ROM)
- **$C800-$CFFF**: Internal ROM ($C800-$CFFF, 2KB)
- **$D000-$FFFF**: Main ROM bank (12KB)
  - $D000-$F7FF: BASIC interpreter (typically Applesoft BASIC on IIe)
  - $F800-$FFFF: Monitor and system routines

- Additional internal ROM overlays available via soft switches

**Apple IIc (16KB or 32KB ROM):**

- **16KB systems:**
  - $C100-$CFFF: Internal peripheral ROM (3.75KB)
  - $D000-$FFFF: Main ROM (12KB)

- **32KB systems:**
  - Two 16KB banks, selected via $C028 soft switch
  - Each bank organized as above
  - Cross-bank calling via jump tables at $C780-$C7FF

#### Language Card ROM (Apple II+ and IIe)

The language card is an expansion card that provides 16KB of RAM in the $D000-$FFFF address space, allowing:

1. Loading alternate programming languages (Pascal, FORTRAN, etc.) into RAM
2. Executing code from RAM instead of ROM
3. Bank-switching between two 4KB RAM banks at $D000-$DFFF

**Memory Organization:**

- **$D000-$DFFF**: Bank 1 or Bank 2 (4KB, selectable)
- **$E000-$FFFF**: Common area (12KB, shared between both banks)

**Soft Switches ($C080-$C08F):**

The language card uses soft switches in the $C080-$C08F range with a two-read write-enable mechanism:

| Address | Function |
|---------|----------|
| $C080 | Read RAM bank 2, write protected |
| $C081 | Read ROM, write RAM bank 2 (requires two reads) |
| $C082 | Read ROM, write protected |
| $C083 | Read/write RAM bank 2 (requires two reads) |
| $C088 | Read RAM bank 1, write protected |
| $C089 | Read ROM, write RAM bank 1 (requires two reads) |
| $C08A | Read ROM, write protected |
| $C08B | Read/write RAM bank 1 (requires two reads) |

**Two-Read Write-Enable Mechanism:**

Write enable switches ($C081, $C083, $C089, $C08B) require **two successive reads** to the same address to enable writing. This prevents accidental writes from indexed addressing that might touch these locations once.

Example of enabling bank 1 for reading and writing:
```
LDA $C08B    ; First read
LDA $C08B    ; Second read - now RAM is readable and writable
; Can now read from and write to $D000-$FFFF (bank 1)
```

**Status Soft Switches:**

- **$C011**: Read BANK2 status; bit 7 = 1 if bank 2, 0 if bank 1
- **$C012**: Read LCRAMRD status; bit 7 = 1 if reading RAM, 0 if ROM

**Default State:**

- After reset: Reading from ROM, writes disabled
- Bank selection: Undefined until explicitly set

#### IIc ROM Banking ($C028)

The Apple IIc with 32KB ROM uses a simple bank-switching mechanism controlled by $C028 (ROMBANK soft switch).

**Bank Organization:**

- **Bank 0**: Primary 16KB ROM
- **Bank 1**: Secondary 16KB ROM
- Both banks organized identically ($C100-$CFFF peripheral ROM, $D000-$FFFF main ROM)

**ROMBANK Soft Switch ($C028):**

- **Any write** to $C028 toggles between ROM banks
- No specific value required; the act of writing toggles the bank
- No read status available; software must track current bank

**Cross-Bank Calling:**

The IIc ROM provides jump table routines at $C780-$C7FF to facilitate cross-bank calls:

| Address | Function | Description |
|---------|----------|-------------|
| $C780 | SWRTI | RTI to other bank (switch bank, then RTI) |
| $C784 | SWRTS | RTS to other bank (switch bank, then RTS) |
| $C788+ | Various | Other cross-bank entry points |

**Example Cross-Bank Call:**

Routine in Bank 0 calling routine in Bank 1:
```
; In Bank 0:
JSR ROUTINE_IN_BANK1_ENTRY
; Control returns here in Bank 0

ROUTINE_IN_BANK1_ENTRY:
    STA $C028           ; Switch to Bank 1
    JSR ACTUAL_ROUTINE  ; Call routine in Bank 1
    STA $C028           ; Switch back to Bank 0
    RTS                 ; Return to caller
```

Using the jump table (preferred method):
```
; In Bank 0:
JSR $C784           ; SWRTS - will switch and return automatically
    .WORD TARGET    ; Address in Bank 1 to call
; Returns here in Bank 0
```

**Reset Behavior:**

- Default bank on reset: Bank 0 (primary)
- Software must explicitly switch to Bank 1 when needed

#### ROM Execution Considerations

**Code Location Constraints:**

1. **Interrupt Vectors ($FFFA-$FFFF):**
   - Must be present in all ROM banks or accessible via common mechanism
   - IIc: Both banks provide identical vectors
   - IIe: Single ROM, no banking issues

2. **Reset Vector ($FFFC-$FFFD):**
   - Must point to valid reset code in default ROM bank
   - Execution begins here after power-up or RESET

3. **Cross-Bank Dependencies:**
   - Code calling routines in other banks must handle banking
   - Use jump tables or explicit bank switching
   - Preserve bank state if required by caller

**Stack Considerations:**

When executing from language card RAM or banked ROM:

- Stack is always in main RAM ($0100-$01FF)
- JSR/RTS instructions work normally across ROM/RAM boundaries
- Bank switches during interrupt service routines must preserve state

**Interrupt Handling:**

Interrupts can occur during any bank configuration:

- Save current bank state (language card or ROM bank)
- Switch to known state for interrupt handler
- Restore bank state before RTI

#### Implementation Guidelines

**For Clean-Room ROM Implementation:**

1. **Use Banking Features:**
   - Language card systems: Access $C080-$C08F to control RAM banking
   - IIc 32KB ROM: Use $C028 to toggle ROM banks
   - Follow documented access sequences for language card write-enable

2. **Organize Code Appropriately:**
   - Place interrupt vectors in all banks (if banked)
   - Ensure reset code accessible from default bank
   - Provide cross-bank calling mechanism if using multiple banks

3. **Document Bank Usage:**
   - Which features are in which bank
   - Cross-bank dependencies
   - Entry points for bank-switched routines

4. **Handle Edge Cases:**
   - What happens if language card not present
   - Default bank selection on reset
   - Interrupt behavior during bank switching

**Note:** ROM banking and language card features are provided by hardware. The system firmware uses these features but does not implement them. Hardware or emulator implementation is responsible for:

- Responding to banking soft switch reads/writes
- Managing the actual bank switching logic
- Providing RAM overlay capabilities (language card)

**For Software Compatibility:**

1. **Detect Banking Capabilities:**
   - Test for language card presence (II/II+)
   - Identify ROM size from hardware detection
   - Don't assume banking available

2. **Preserve Bank State:**
   - Save language card/ROM bank state before modifying
   - Restore state before returning to caller
   - Particularly important for interrupt handlers

3. **Use Documented Entry Points:**
   - Use cross-bank jump tables when available
   - Don't rely on undocumented banking behavior
   - Test on multiple firmware revisions

#### ROM Banking State Bits

During interrupt handling, firmware must preserve and restore the effective memory mapping, which can include language-card state and banked-ROM state. Many implementations do this by encoding a compact state byte; see **[Memory State Encoding](#memory-state-encoding)** in the Interrupt Handling section for an illustrative historical example.

**ROM-banking related items commonly captured in such a state value include:**

- Whether language-card RAM is selected for reading (vs ROM)
- Which language-card bank is selected (if applicable)
- Whether an alternate ROM bank is selected (banked ROM systems)

#### See Also

- **[I/O and Soft Switches](#io-and-soft-switches)** - RAM banking and soft switches
- **[Memory System](#memory-system)** - Complete memory architecture
- **[Interrupt Handling](#interrupt-handling)** - Interrupt context preservation
- **[Hardware Variants and Identification](#hardware-variants-and-identification)** - Model-specific capabilities
