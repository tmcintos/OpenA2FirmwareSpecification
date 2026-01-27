### <a id="tosub-ffbe"></a>TOSUB ($FFBE)

**Description:**

This routine serves as a dispatcher to execute other ROM subroutines whose entry points are listed in the [SUBTBL](#subtbl-ffe3) lookup table. It is typically invoked after identifying a command character via the monitor's command interpreter.

`TOSUB` works by:

1.  Pushing the high-order byte of the target subroutine's address (derived from `>GO`) onto the stack.
2.  Pushing the low-order byte of the target subroutine's address (retrieved from [SUBTBL](#subtbl-ffe3) indexed by the Y register) onto the stack.
3.  Saving the current [MODE](#mode) byte into the A register.
4.  Clearing the [MODE](#mode) byte (setting it to $00).
5.  Executing an `RTS` instruction. Since the target subroutine's address is now on top of the stack, the `RTS` effectively transfers control to that subroutine.

**Input:**

*   **Registers:**
    *   Y: An index (0-based) into the [SUBTBL](#subtbl-ffe3) table, specifying which subroutine to dispatch to.
    *   A: N/A (loaded internally).
    *   X: N/A (used internally for stack manipulation).
*   **Memory:**
    *   [MODE](#mode) (address $31): The current monitor mode byte. Its initial value is read.
    *   [SUBTBL](#subtbl-ffe3) (address $FFE0): A table of low-order subroutine entry point addresses.

**Output:**

*   **Registers:**
    *   A: Contains the original value of the [MODE](#mode) byte.
    *   X: Undefined (modified during stack operations).
    *   Y: Cleared to $00.
    *   P: Flags affected by various operations.
*   **Memory:**
    *   [MODE](#mode) (address $31): Cleared to $00.

**Side Effects:**

*   Modifies the stack by pushing a return address.
*   Transfers control to a subroutine specified by the Y register's index into [SUBTBL](#subtbl-ffe3).
*   Saves and clears the [MODE](#mode) byte.

**See also:**

*   [SUBTBL](#subtbl-ffe3) (table of dispatch addresses)
*   [MODE](#mode)
*   [MONZ](#monz-ff69) (Monitor entry points that use `TOSUB`)
*   [GO](#go-feb6) (Used as the high-order address for dispatch)