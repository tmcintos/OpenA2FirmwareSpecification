## <a id="interrupt-handling"></a>Interrupt Handling

### Overview

The Apple II firmware provides standardized interrupt handling for BRK, IRQ, and NMI interrupts. All 8-bit Apple II systems use vectored interrupts that software can customize by modifying system vectors in low memory.

This section documents interrupt mechanisms, memory state preservation requirements, and proper handling with bank-switched memory configurations.

### Interrupt Vectors

**System Interrupt Vectors:**

| Address | Vector | Interrupt Type | Default Handler | Software Modifiable |
|---------|--------|----------------|-----------------|---------------------|
| $03F0-$03F1 | BRKV | BRK instruction | Monitor BRK handler | Yes |
| $03F2-$03F3 | SOFTEV | Warm start/reset | Reset/Monitor entry | Yes |
| $03FE-$03FF | IRQLOC | IRQ hardware interrupt | Firmware IRQ handler | Yes |
| $FFFE-$FFFF | (ROM) | IRQ/BRK vector | Firmware dispatcher | No (ROM) |
| $FFFA-$FFFB | (ROM) | NMI vector | Firmware NMI handler | No (ROM) |

**Vector Usage:**

ROM interrupt vectors ($FFFA-$FFFF) point to firmware entry points. These dispatch through RAM vectors ($03F0-$03FF) that software can modify:

```
; ROM IRQ/BRK handler (fixed)
IRQBRK_ENTRY:
    ; Determine if IRQ or BRK
    ; Jump through RAM vector
    JMP (BRKV)  ; if BRK
    ; or
    JMP (IRQLOC) ; if IRQ
```

This allows software to hook interrupts by changing RAM vectors without modifying ROM.

### BRK Instruction Handling

**BRK Behavior:**

When BRK instruction executes:

1. Push PC+2 to stack (return address)
2. Push processor status with B flag set
3. Set interrupt disable flag
4. Jump through $FFFE-$FFFF vector

**Firmware BRK Handler:**

Default BRKV points to Monitor break handler:

1. Save all registers (A, X, Y, P, S)
2. Display register contents
3. Enter Monitor command mode
4. Allow user to examine/modify memory
5. Can resume with 'G' command

**Custom BRK Handlers:**

Software can install custom debuggers or error handlers:
```
LDA #<MY_HANDLER
STA BRKV
LDA #>MY_HANDLER
STA BRKV+1
```

Handler must preserve system state or provide own exit mechanism.

### IRQ Interrupt Handling

**IRQ Sources:**

Hardware interrupt requests can come from:

- Peripheral cards in slots
- Expansion hardware
- Timer circuits (if present)
- External interrupt signals

**Firmware IRQ Dispatcher:**

1. Determine interrupt source (peripheral polling)
2. Jump through IRQLOC vector
3. Default handler returns immediately (RTI)

**Custom IRQ Handlers:**

Software provides IRQ handling by setting IRQLOC:
```
LDA #<IRQ_HANDLER
STA IRQLOC
LDA #>IRQ_HANDLER
STA IRQLOC+1
```

**IRQ Handler Requirements:**

IRQ handlers must:

- Preserve all registers (push A,X,Y)
- Identify and service interrupt source
- Clear interrupt condition before RTI
- Restore all registers (pop Y,X,A)
- Exit with RTI instruction

**Simple IRQ Handler Example:**
```
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
```

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

When using bank-switched memory (language card, auxiliary RAM, ROM banking), interrupt handlers must preserve memory configuration.

**Challenge:**

Interrupt can occur with any memory configuration active:

- Auxiliary zero page/stack selected
- Language card RAM active
- Alternate ROM bank selected
- Auxiliary RAM mapped for read/write

Handler must:

1. Save current memory state
2. Switch to known configuration
3. Execute interrupt handler
4. Restore memory state before RTI

### Memory State Encoding

If the firmware supports bank-switched memory (auxiliary RAM, language card RAM, banked ROM, etc.), the interrupt entry/exit path must preserve the active memory mapping.

A common historical technique is to snapshot the active mapping into a compact state byte (often pushed on the stack) so it can be restored before `RTI`. The exact encoding is usually an internal implementation detail (not an externally visible API contract), but it is useful to enumerate what state commonly needs to be preserved.

#### Example historical state-byte encoding (illustrative)

Some implementations encode memory configuration using an 8-bit value along these lines:

| Bit | Meaning (example) |
|-----|--------------------|
| D7 | 1 if auxiliary zero page/stack is selected (ALTZP) |
| D6 | 1 if 80STORE is enabled and PAGE2 is selected |
| D5 | 1 if reads are mapped to auxiliary RAM (RAMRD) |
| D4 | 1 if writes are mapped to auxiliary RAM (RAMWRT) |
| D3 | 1 if language-card RAM is enabled for reading (vs ROM) |
| D2 | Language-card bank select (implementation-defined) |
| D1 | Language-card bank select (implementation-defined) |
| D0 | 1 if an alternate ROM bank is selected (banked ROM systems) |

**Notes:**

- Not all bits are meaningful on all models (e.g., an Apple II without auxiliary RAM has no ALTZP/RAMRD/RAMWRT to preserve).
- The *spec requirement* is to preserve and restore the effective mapping; the specific bit layout is an implementation choice unless exposed by a documented routine.

### Interrupt Entry with Auxiliary Memory

**Complete Interrupt Entry Sequence (conceptual):**

If an interrupt can occur while auxiliary/banked memory mappings are active, the ROM interrupt dispatcher should:

1. Save the current CPU state (PC and P are pushed by hardware)
2. Save enough information to restore the current memory mapping later
3. Switch to a known-safe mapping for executing the handler (commonly the default “main” mapping)
4. Run the handler (or dispatch through a RAM vector)
5. Restore the previous memory mapping and any affected stack state
6. Return via `RTI`

This ensures interrupt handlers work correctly regardless of which bank was active at the moment the interrupt occurred.

### Stack Pointer Preservation

If the firmware supports switching the active stack between banks (e.g., auxiliary vs main), the interrupt dispatcher must ensure that:

- Stack pushes/pulls during interrupt handling use the intended stack bank
- The pre-interrupt stack pointer state is restored before returning with `RTI`

#### Illustrative historical example (ALTZP active)

On systems where **ALTZP** moves zero page and the stack page ($0100-$01FF) into auxiliary RAM, a common historical approach is:

- On interrupt entry, snapshot the current **S** (stack pointer) and record whether the interrupt occurred with ALTZP enabled.
- If ALTZP was enabled, save **S** into a well-known location in the *auxiliary* stack page (commonly `$0101` in auxiliary RAM) so it can be restored later.
- Switch to a known-safe mapping for interrupt handling (commonly: main ZP/stack selected, main RAM read/write selected).
- Load a safe main-memory stack pointer value (commonly `$FF`) before running the handler or dispatching through a RAM vector.
- On interrupt exit, restore the pre-interrupt memory mapping and, if the interrupt occurred with ALTZP enabled, restore **S** from the saved auxiliary location before returning with `RTI`.

**Why this matters:** if the handler runs while ALTZP remains enabled, the interrupt’s automatic pushes (and any nested pushes/pulls) will use the auxiliary stack page. That can corrupt whatever the interrupted code was using the auxiliary stack for, and it can break handlers that assume monitor/firmware workspace is in main memory.

The exact save locations and switching sequence are implementation choices, but the externally observable requirement is the same: an interrupt must not leave the machine in a different effective mapping or with a different stack pointer than it had at the moment of interrupt entry.

### Language Card State Preservation

If the firmware supports a language card (or similar) where enabling RAM write access requires a specific access sequence, the interrupt dispatcher must restore that state correctly before returning.

In particular, restoring “current mapping” may require more than just replaying a single soft-switch selection; it may require repeating the same enable sequence that established the state (for example, write-enable that requires two successive accesses).

See also:

- **[ROM Organization and Banking](#rom-organization-and-banking)** — language card banking, write-enable sequence, and status reads
- **[I/O and Soft Switches](#io-and-soft-switches)** — language card soft switches and status locations

### ROM Banking State Preservation

If the firmware uses banked ROM, the interrupt entry path must ensure the interrupt dispatcher and any required helper routines are reachable when an interrupt occurs.

Implementations commonly address this by placing the dispatcher in a common region, mirroring it in all banks, or switching banks as part of interrupt entry/exit.

### Interrupt Handling Implementation Requirements

**For Clean-Room ROM Implementation:**

1. **Establish ROM Vectors:**
   - Place IRQ/BRK handler address at $FFFE-$FFFF
   - Place NMI handler address at $FFFA-$FFFB
   - Point to firmware dispatchers

2. **Initialize RAM Vectors:**
   - Set BRKV to Monitor break handler
   - Set IRQLOC to default IRQ return (RTI)
   - Set SOFTEV to warm start entry
   - Allow software modification

3. **Implement Dispatchers:**
   - Distinguish BRK from IRQ (check B flag)
   - Jump through appropriate RAM vector
   - Save/restore memory state if banking present

4. **Handle Memory Banking:**
   - Save memory configuration in interrupt entry
   - Switch to main memory for handler execution
   - Restore configuration before RTI
   - Preserve stack pointers correctly

5. **Support Custom Handlers:**
   - Document vector usage
   - Provide stable entry/exit protocol
   - Preserve registers and state

**For Software Using Interrupts:**

1. **Install Handlers Properly:**
   - Set RAM vectors, not ROM vectors
   - Provide complete handler (entry to RTI)
   - Test before enabling interrupts

2. **Preserve All State:**
   - Save all registers (A, X, Y)
   - Save memory configuration if using banking
   - Restore everything before RTI

3. **Clear Interrupt Source:**
   - Service interrupt condition
   - Clear hardware interrupt flag
   - Prevent infinite interrupt loop

4. **Minimize Handler Time:**
   - Interrupts block other interrupts
   - Defer complex work to main program
   - Use flags to signal main code

### See Also

- **[Break ($FA4C)](#break-fa4c)** - BRK instruction handler entry point
- **[System Vectors](#system-boot-and-initialization)** - Interrupt vector initialization
- **[Auxiliary RAM and Memory Soft Switches](#auxiliary-ram-and-memory-soft-switches)** - Memory state encoding
- **[ROM Organization and Banking](#rom-organization-and-banking)** - Language card and ROM banking state
