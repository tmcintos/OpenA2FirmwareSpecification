### <a id="io-and-soft-switches"></a>I/O and Soft Switches

#### Overview

The Apple II family uses memory-mapped I/O for all hardware control. Soft switches are memory locations in the $C000-$C0FF range that control system hardware features when accessed. Reading or writing these addresses changes hardware state without requiring special I/O instructions.

This section provides a comprehensive reference to all soft switches used in 8-bit Apple II systems.

#### Soft Switch Conventions

**Access Types:**

- **(R)**: Read to activate
- **(W)**: Write to activate (value doesn't matter)
- **(R/W)**: Read or write to activate
- **(R7)**: Read bit 7 for status (1=on, 0=off)

**Toggle Behavior:**

- Some switches have separate on/off addresses
- Others toggle state each time they're accessed
- Status switches return current state in bit 7

#### Memory Control Soft Switches (IIe/IIc)

**RAMRD - Read Bank Selection:**

- **$C002** (R/W): RDMAINRAM - Read from main 48K RAM
- **$C003** (R/W): RDCARDRAM - Read from auxiliary 48K RAM  
- **$C013** (R7): Read RAMRD status (bit 7: 1=aux, 0=main)

**RAMWRT - Write Bank Selection:**

- **$C004** (R/W): WRMAINRAM - Write to main 48K RAM
- **$C005** (R/W): WRCARDRAM - Write to auxiliary 48K RAM
- **$C014** (R7): Read RAMWRT status (bit 7: 1=aux, 0=main)

**AUXZP - Zero Page and Stack Banking:**

- **$C008** (W): SETSTDZP - Use main zero page and stack
- **$C009** (W): SETALTZP - Use auxiliary zero page and stack
- **$C016** (R7): Read AUXZP status (bit 7: 1=aux, 0=main)

**Usage Example:**
```
; Switch to auxiliary RAM
STA $C003    ; Read from auxiliary
STA $C005    ; Write to auxiliary
LDA ($3C),Y  ; Access auxiliary memory

; Return to main RAM
STA $C002    ; Read from main
STA $C004    ; Write to main
```

#### Display Control Soft Switches

**80STORE - Display Page Override (IIe/IIc):**

- **$C000** (W): Turn OFF 80STORE
- **$C001** (W): Turn ON 80STORE
- **$C018** (R7): Read 80STORE status

When ON, PAGE2 overrides RAMRD/RAMWRT for display memory only, enabling 80-column text and double hi-res graphics.

**PAGE2 - Display Page Selection:**

- **$C054** (R): Select Page 1 (primary display)
- **$C055** (R): Select Page 2 (alternate display)
- **$C01C** (R7): Read PAGE2 status

**TEXT - Text/Graphics Mode:**

- **$C050** (R): Select graphics mode
- **$C051** (R): Select text mode
- **$C01A** (R7): Read TEXT status

**MIXED - Mixed Mode:**

- **$C052** (R): Full screen mode
- **$C053** (R): Mixed mode (graphics + 4 text lines)
- **$C01B** (R7): Read MIXED status

**HIRES - Graphics Resolution:**

- **$C056** (R): Lo-Res graphics mode
- **$C057** (R): Hi-Res graphics mode
- **$C01D** (R7): Read HIRES status

**Display Mode Combinations:**

| TEXT | MIXED | HIRES | 80STORE | Result |
|------|-------|-------|---------|--------|
| 1 | x | x | 0 | 40-column text |
| 1 | x | x | 1 | 80-column text (IIe/IIc) |
| 0 | 0 | 0 | 0 | Full lo-res graphics |
| 0 | 1 | 0 | 0 | Lo-res + 4 text lines |
| 0 | 0 | 1 | 0 | Full hi-res graphics |
| 0 | 1 | 1 | 0 | Hi-res + 4 text lines |
| 0 | x | 1 | 1 | Double hi-res (IIe/IIc, 128K) |

#### Keyboard and Input

**KBD - Keyboard Data:**

- **$C000** (R7): Read last key pressed (bit 7=1, bits 6-0=ASCII)
- Data remains until KBDSTRB accessed

**KBDSTRB - Keyboard Strobe:**

- **$C010** (R/W): Clear keyboard strobe (clears bit 7 of KBD)

**RDBNK2 - Bank 2 Indicator (IIe):**

- **$C011** (R7): Read language card bank status (1=bank 2, 0=bank 1)

**RDLCRAM - Language Card RAM Read:**

- **$C012** (R7): Read LC RAM status (1=reading RAM, 0=reading ROM)

**Usage:**
```
LDA $C000    ; Read keyboard
BMI GOT_KEY  ; Branch if key pressed (bit 7=1)
; No key

GOT_KEY:
AND #$7F     ; Strip high bit to get ASCII
STA $C010    ; Clear strobe
```

#### Peripheral Slot I/O

**Slot-Specific I/O ($C0n0-$C0nF):**

Each peripheral slot has 16 bytes of I/O space:

- **$C0n0-$C0nF**: I/O space for slot n (n=1-7)

Examples:

- **$C060-$C06F**: Slot 6 (typically Disk II controller)
- **$C070-$C07F**: Slot 7

**Slot ROM Control (IIe):**

- **$C006** (W=0): SLOTCXROM - Use slot ROMs
- **$C007** (W=1): SLOTCXROM - Use internal ROM
- **$C00A** (W=0): SLOTC3ROM - Use slot 3 ROM
- **$C00B** (W=1): SLOTC3ROM - Use internal $C300 ROM

**Note:** On IIc, these switches have no effect (always uses internal ROM).

#### Speaker and Cassette (II/II+)

**SPKR - Speaker Toggle:**

- **$C030** (R/W): Toggle speaker state (creates click)

**CSSTOUT - Cassette Output:**

- **$C020** (R/W): Toggle cassette output (II/II+ only)

**TAPEIN - Cassette Input:**

- **$C060** (R7): Read cassette input (bit 7: tape signal)

**Note:** Cassette interface obsolete on IIe/IIc.

#### Game I/O

**Paddle Inputs:**

- **$C064** (R7): Paddle 0 trigger (button 0)
- **$C065** (R7): Paddle 1 trigger (button 1)
- **$C066** (R7): Paddle 2 trigger (button 2)
- **$C067** (R7): Paddle 3 trigger (button 3)

**Paddle Timing:**

- **$C070** (R/W): Trigger paddle timers (starts paddle read)

After triggering, read paddle values by timing how long bits stay high:
```
STA $C070    ; Trigger paddles
; Read loop counts until bit goes low
PDL_LOOP:
LDA $C064    ; Read paddle 0
BPL PDL_DONE ; When bit 7 clear, done
; Increment counter
JMP PDL_LOOP
PDL_DONE:
; Counter value proportional to paddle position
```

**Push Buttons:**

- **$C061** (R7): Push button 0 / Open-Apple key (IIe/IIc)
- **$C062** (R7): Push button 1 / Closed-Apple key (IIe/IIc)
- **$C063** (R7): Push button 2

#### Graphics Mode Switches

**AN0-AN3 - Annunciators/Graphics Control:**

- **$C058** (R): AN0 OFF
- **$C059** (R): AN0 ON
- **$C05A** (R): AN1 OFF
- **$C05B** (R): AN1 ON
- **$C05C** (R): AN2 OFF  
- **$C05D** (R): AN2 ON
- **$C05E** (R): AN3 OFF / DHIRES OFF (IIe/IIc)
- **$C05F** (R): AN3 ON / DHIRES ON (IIe/IIc)

On IIe/IIc, AN3 also controls double hi-res:

- $C05E: Disable double hi-res
- $C05F: Enable double hi-res (requires 80STORE and HIRES)

#### Language Card Soft Switches

The language card uses a two-read write-enable mechanism in the $C080-$C08F range:

**Bank 2 Switches:**

- **$C080** (R): Read RAM bank 2, write protected
- **$C081** (R,R): Read ROM, write RAM bank 2 (requires 2 reads)
- **$C082** (R): Read ROM, write protected
- **$C083** (R,R): Read/write RAM bank 2 (requires 2 reads)

**Bank 1 Switches:**

- **$C088** (R): Read RAM bank 1, write protected
- **$C089** (R,R): Read ROM, write RAM bank 1 (requires 2 reads)
- **$C08A** (R): Read ROM, write protected
- **$C08B** (R,R): Read/write RAM bank 1 (requires 2 reads)

**Two-Read Write-Enable:**

Write-enable switches require **two successive reads** to enable writing:
```
LDA $C08B    ; First read - bank 1, read-only
LDA $C08B    ; Second read - bank 1, read/write enabled
; Now can write to $D000-$FFFF
```

This prevents accidental writes from indexed addressing.

See [ROM Organization and Banking](#rom-organization-and-banking) for complete language card documentation.

#### IIc ROM Banking

**ROMBANK - IIc ROM Bank Toggle (IIc only):**

- **$C028** (W): Toggle between ROM banks

On IIc systems with 32KB ROM, any write to $C028 toggles between the two 16KB ROM banks. Value written doesn't matter.

**Usage:**
```
STA $C028    ; Switch to other ROM bank
; Now executing from alternate bank
STA $C028    ; Switch back
```

See [ROM Organization and Banking](#rom-organization-and-banking) for cross-bank calling mechanisms.

#### Status Soft Switches

**Read-Only Status Registers:**

| Address | Status | Bit 7 Meaning |
|---------|--------|---------------|
| $C010 | KBDSTRB | Clears keyboard strobe when accessed |
| $C011 | RDBNK2 | 1=language card bank 2, 0=bank 1 |
| $C012 | RDLCRAM | 1=reading LC RAM, 0=reading ROM |
| $C013 | RDRAMRD | 1=reading aux RAM, 0=reading main |
| $C014 | RDRAMWRT | 1=writing aux RAM, 0=writing main |
| $C015 | RDCXROM | 1=internal ROM, 0=slot ROM (IIe) |
| $C016 | RDALTZP | 1=aux zero page, 0=main zero page |
| $C017 | RDC3ROM | 1=internal $C300, 0=slot 3 ROM |
| $C018 | RD80STORE | 1=80STORE on, 0=off |
| $C019 | RDVBL | 1=vertical blank active |
| $C01A | RDTEXT | 1=text mode, 0=graphics |
| $C01B | RDMIXED | 1=mixed mode, 0=full screen |
| $C01C | RDPAGE2 | 1=page 2, 0=page 1 |
| $C01D | RDHIRES | 1=hi-res, 0=lo-res |
| $C01E | RDALTCH | 1=alt character set (IIe) |
| $C01F | RD80VID | 1=80-column mode (IIe/IIc) |

#### I/O and Soft Switches Implementation Notes

**For Clean-Room ROM Implementation:**

1. **Use Soft Switches Appropriately:**
   - Access soft switches at documented addresses for target model
   - Follow proper access sequences (e.g., two reads for language card write-enable)
   - Read status switches to determine current hardware state

2. **Initialize Switches on Reset:**
   - Set known default states during firmware initialization
   - TEXT mode, page 1, 40-column
   - Main RAM, main zero page
   - ROM enabled (language card)

3. **Preserve/Restore Switch State:**
   - Save memory configuration state in interrupt handlers
   - Restore configuration before returning from interrupts
   - Preserve state across firmware calls when required

4. **Handle Model Differences:**
   - IIc: Some switches have no effect (always uses internal ROM)
   - II/II+: No auxiliary memory or 80-column switches available
   - Detect hardware capabilities and adapt firmware behavior

**Note:** Soft switches are hardware features provided by the Apple II system. ROM firmware uses these switches but does not implement them. Hardware or emulator implementation is responsible for:

- Responding to soft switch reads/writes
- Implementing the actual hardware state changes
- Providing correct status register values

**For Software Compatibility:**

1. **Use Documented Addresses:**
   - Don't use undocumented soft switches
   - Check status switches before assuming state
   - Test for hardware presence before using features

2. **Preserve State When Needed:**
   - Save language card state before modifying
   - Save RAM bank selection in interrupt handlers
   - Restore state before returning

3. **Handle Missing Features:**
   - Test for auxiliary memory before using
   - Check for 80-column hardware
   - Gracefully degrade if features absent

#### See Also

- **[Display System](#display-system)** - Display modes and soft switch combinations
- **[Memory System](#memory-system)** - Memory organization
- **[Auxiliary RAM and Memory Soft Switches](#auxiliary-ram-and-memory-soft-switches)** - Extended memory details
- **[ROM Organization and Banking](#rom-organization-and-banking)** - Language card and ROM banking
- **[Hardware Variants and Identification](#hardware-variants-and-identification)** - Model-specific features
