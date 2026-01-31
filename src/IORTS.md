### <a id="iorts-ff58"></a>IORTS ($FF58)

**Description:**

This address contains an `RTS` instruction.

Its primary purpose as a documented entry point is to support **slot-relative addressing** in peripheral ROM code: a peripheral ROM can `JSR $FF58`, then examine the return address pushed by the `JSR` to determine which `$Cnxx` page it is executing from.

#### Slot detection using IORTS

When a peripheral ROM is executing in slot *n* (at `$Cn00-$CnFF`), it can derive *n* by reading the return address high byte from the stack:

1. `JSR $FF58` pushes the return address (`$Cn..`) onto the stack.
2. `IORTS` immediately returns (`RTS`).
3. The peripheral ROM reads the return address high byte (`$Cn`) from the stack.
4. Shifting that high byte left 4 times yields the common “slot index” value `n << 4` used for indexed I/O accesses like `LDA $C080,X`.

**Example:**

```
        JSR     $FF58           ; Call IORTS (pushes return address onto stack)
        TSX                     ; X = stack pointer
        LDA     $0100,X         ; A = return address high byte ($Cn)
        ASL     A
        ASL     A
        ASL     A
        ASL     A
        TAX                     ; X = n << 4 (slot index)
```

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Preserved
*   **Memory:** None.

**Side Effects:**

*   Returns from a subroutine. Its primary purpose as an entry point is for peripheral card slot identification.

**See also:** None.