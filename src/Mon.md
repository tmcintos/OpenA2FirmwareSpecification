### <a id="mon-ff65"></a>Mon ($FF65)

**Description:**

This routine prepares the processor to enter the System Monitor. It clears the processor's decimal mode flag, activates the speaker (generating a sound), and transfers control to the [MonZ](#monz-ff69) routine. It does not return to its caller.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Decimal mode flag is cleared.
*   **Memory:** None.

**Side Effects:**

*   Clears the processor's decimal mode flag.
*   Activates the system speaker.
*   Transfers control to [MonZ](#monz-ff69).

**See also:**

*   [MonZ](#monz-ff69)