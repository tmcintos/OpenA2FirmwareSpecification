## System Boot and Initialization Sequence

The Apple II boot process involves several stages of firmware execution, from initial hardware reset through system initialization and optional peripheral device boot loading. This section provides an overview of the boot sequence and explains the role of the ROM firmware.

### Boot Sequence Overview

The complete boot process follows this sequence:

1. **Hardware Reset** - Power-on or manual RESET button pressed
2. **6502 Reset Vector** - Processor loads reset vector from $FFFC-$FFFD
3. **Firmware Reset Routine** - Executes system initialization code
4. **System Initialization** - RAM test, I/O configuration, memory setup
5. **Slot Detection** - Firmware scans slots 1-7 for installed peripheral cards
6. **Peripheral Boot ROM Detection** - Checks for boot ROM at $Cn00 in each slot
7. **Peripheral Boot (Optional)** - If boot ROM found, executes it; otherwise continues
8. **Operating System Initialization** - Loads operating system (DOS/ProDOS) or returns to Monitor/BASIC

### Firmware Boot Initialization (Required)

The firmware reset routine executes essential system initialization that all Apple II systems require:

**From Reset ($FA62):**

- Initialize 6502 hardware state (clear flags, set stack pointer)
- Configure memory subsystem (RAM timing, address decoding)
- Initialize I/O subsystem (keyboard, display, speakers)
- Set display mode (text/graphics, 40/80 columns)
- Establish interrupt vectors (IRQ, NMI, BRK)
- Perform memory diagnostics (on first boot)
- Initialize system zero-page locations

**Warm-Start Detection (IIe and later):**

- Check PWREDUP magic byte at $03F4
- If SOFTEV and PWREDUP are consistent (SOFTEV XOR PWREDUP = $A5), treat as warm start
- Warm start skips full memory test and re-initialization; jumps to SOFTEV
- Cold start performs full initialization

### Peripheral Device Boot (Optional)

After firmware initialization, control may optionally transfer to a peripheral device's boot ROM. This allows disk drives, hard drives, networks, and other devices to load operating system code.

**Boot ROM Location:**

- **Address:** $Cn00 (where n = slot number, 1-7)
- **Size:** 256 bytes ($Cn00-$CnFF)
- **Example:** Disk II controller boot ROM in slot 6 = $C600-$C6FF

**Firmware Slot Detection:**
The firmware scans slots in order to find installed peripheral cards with boot capability:

```
FOR slot = 1 TO 7
    IF boot ROM present at $Cn00
        JUMP TO $Cn00
        (Boot ROM takes over from here)
    ENDIF
NEXT
```

**Important Notes:**

- **Slot Independence:** Boot ROMs should not assume a specific slot. Use indexed addressing or memory-mapped I/O with the slot number passed in a register.
- **Boot ROM is Optional:** A peripheral device's boot ROM is only executed if the device is installed AND the boot ROM location contains valid code.
- **Single Boot Device:** Firmware executes the first boot ROM it finds; subsequent slots are not checked.
- **Alternative Boot Devices:** Any peripheral card in any slot can provide a boot ROM. Common boot devices include:
  - Disk II controller (typically slot 6)
  - SmartPort hard drive controllers (typically slots 4-7)
  - Network cards (Ethernet controllers)
  - Other expansion devices
- **Slot Identification:** Peripheral ROMs can determine their installed slot by calling the [`IORTS`](#iorts-ff58) routine ($FF58). When executed, the return address pushed by JSR is examined to extract the high byte (the slot address $Cn), which reveals the slot number.

### Peripheral Boot ROM Responsibilities

When a peripheral device's boot ROM is executed, it typically:

1. **Initialize the Device:** Set up controller hardware, detect attached drives
2. **Load Operating System:** Read OS code from device into RAM (typically $0800-$BFFF range)
3. **Perform Sanity Checks:** Verify loaded code is valid (checksums, markers)
4. **Transfer Control:** Jump to loaded OS code or fail back to firmware

**Example: Disk II Boot Process**

The Disk II controller ROM ($C600) performs:

1. Initialize stepper motor and disk controller (IWM) hardware
2. Move disk head to track 0 (blind seek - no track detection)
3. Read sector 0 from track 0 (boot sector)
4. Decode 6+2 encoded data into memory at $0800-$0BFF (BOOT1)
5. Execute BOOT1 at $0801, which continues loading DOS from disk

### Reset Button Behavior

Pressing the RESET button performs the same initialization as power-on, with one critical difference:

**RESET Does NOT Destroy Existing Programs:**

- Existing BASIC programs remain in memory
- Existing machine language programs remain in memory
- System enters Monitor (command mode) without clearing RAM
- Programs can be resumed via Control-C or Monitor commands

This allows developers to debug and test code without losing their work.

### System Vectors and Hooks

The firmware initializes several interrupt and exit vectors that control system behavior:

| Address | Vector | Purpose | Default | Changeable |
|---------|--------|---------|---------|-----------|
| $03F8-$03F9 | USRADR | User exit/return address | Monitor | Yes |
| $03FB-$03FC | NMI | Non-maskable interrupt | Reserved | ROM-dependent |
| $03FE-$03FF | IRQLOC | Interrupt request handler | Firmware IRQ handler | Yes |
| $03F0-$03F1 | BRKV | Break (BRK) instruction handler | Monitor (IIe+) | Yes |
| $03F2-$03F3 | SOFTEV | Warm-start entry point | Reset routine (IIe+) | Yes |

Software can modify these vectors to customize system behavior, but ROM implementations must establish reasonable defaults.

### Clean-Room ROM Implementation Considerations

When implementing a compatible ROM:

1. **Always support Reset** - Initialize all required subsystems and establish interrupt vectors
2. **Support Warm-Start Detection (IIe+)** - Check PWREDUP/SOFTEV if targeting enhanced systems
3. **Enable Slot-Based Boot** - Scan slots for boot ROMs using slot-relative addressing
4. **Don't Assume Boot Device** - Don't hardcode dependencies on Disk II ROM; any device may provide boot
5. **Preserve Program Memory** - Ensure RESET doesn't clear user programs without consent
6. **Document Variant Behavior** - Note which vectors/features apply to which system variants
7. **Implement Boot ROM Identification** - For peripheral ROMs, implement appropriate ID bytes (see [Boot ROM Identification Protocols](#boot-rom-identification-protocols))

For detailed information on individual firmware routines that participate in boot (Reset, PwrUp, etc.), see the respective routine documentation.

