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

Firmware uses packed byte to save complete memory configuration:

| Bit | Meaning |
|-----|---------|
| D7 | 1 if using auxiliary zero page/stack (ALTZP on) |
| D6 | 1 if 80STORE enabled and PAGE2 on |
| D5 | 1 if reading from auxiliary RAM (RAMRD) |
| D4 | 1 if writing to auxiliary RAM (RAMWRT) |
| D3 | 1 if language card RAM enabled for reading |
| D2 | Language card bank selection (implementation-specific) |
| D1 | Language card bank selection (implementation-specific) |
| D0 | 1 if alternate ROM bank selected (IIc) |

**Purpose:**

Single-byte encoding minimizes stack usage and allows quick save/restore during interrupt handling.

### Interrupt Entry with Auxiliary Memory

**Complete Interrupt Entry Sequence:**

When interrupt occurs with auxiliary memory configuration active:

1. **Push Current PC and Status** (hardware automatic)

2. **Read Current Memory State:**
   - Check all soft switch status registers
   - Encode into single state byte
   - Push state byte to stack

3. **Switch to Main Memory:**
   - STA $C008 ; main zero page/stack
   - STA $C002 ; read main RAM
   - STA $C004 ; write main RAM

4. **Save Stack Pointer:**
   - If was using auxiliary stack, save SP to $0100 (aux)
   - Switch to main stack

5. **Execute Handler:**
   - All interrupt handler code uses main memory
   - Can safely modify main RAM
   - Can access peripherals normally

6. **Restore Memory State:**
   - Pop state byte from stack
   - Decode bits and restore all soft switches
   - Restore stack pointer if needed

7. **Return from Interrupt:**
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

When ALTZP is on, zero page and stack are in auxiliary memory. Interrupt switches to main zero page/stack, but we need to restore auxiliary stack pointer on exit.

**Solution:**

Firmware uses stack pointer save locations:

- **$0100** (aux RAM): Main stack pointer when using aux stack
- **$0101** (aux RAM): Aux stack pointer when using main stack

**Procedure:**

Before switching stacks in interrupt:
```
; Currently using auxiliary stack
STA $C005    ; Write to auxiliary RAM
TSX          ; Get current stack pointer
STX $0101    ; Save in aux $0101
STA $C004    ; Write to main RAM
LDX #$FF     ; Restore main SP
TXS
```

On interrupt exit:
```
STA $C005    ; Write to auxiliary RAM
LDX $0101    ; Load saved aux SP
TXS          ; Restore auxiliary stack
STA $C004    ; Write to main RAM
RTI
```

### Language Card State Preservation

**Language Card Complexity:**

Language card state requires two-read write-enable sequence. Simply saving soft switch status isn't enough—must recreate exact access pattern.

**State Elements:**

- Which bank selected (1 or 2)
- RAM read enabled vs ROM
- RAM write enabled vs write-protected

**Restoration:**

Interrupt handler must:

1. Save bank selection, read enable, write enable state
2. Restore by accessing appropriate soft switches
3. For write-enable, perform two reads if needed

**Example State Save:**
```
; Read LC state
LDA $C011    ; RDBANK2 status
; bit 7 = 1 if bank 2
LDA $C012    ; RDLCRAM status  
; bit 7 = 1 if reading RAM
; (write enable requires tracking or assumption)
```

**Example State Restore:**
```
; Restore bank 2, read/write
LDA $C08B    ; First read
LDA $C08B    ; Second read - enables write
```

### ROM Banking State Preservation (IIc)

**IIc ROM Bank Toggle:**

IIc systems with 32KB ROM use $C028 to toggle banks. State preservation requires:

1. **Determine Current Bank:**
   - Test known addresses that differ between banks
   - Or maintain software bank tracking

2. **Switch to Handler Bank:**
   - Ensure interrupt handler in current bank
   - Or switch to known bank containing handler

3. **Restore Original Bank:**
   - Toggle back if changed
   - Maintain bank count (even=same, odd=opposite)

**Handler Bank Location:**

Interrupt handlers should be in:

- Common ROM area (present in both banks), or
- Both ROM banks at same address, or
- Bank 1 (default boot bank)

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
