### <a id="setpwrc-fb6f"></a>SetPwrC ($FB6F)

**Description:**

This routine calculates a Validity-Check byte for the current reset vector and stores it in memory. This helps ensure the integrity of the reset process.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [User Reset Vector](#user-reset-vector) (address $03F2-$03F3): Pointer to the routine to be executed after a warm start.

**Output:**

*   **Registers:**
    *   A: Contains the calculated power-up byte (the value stored in [PWREDUP](#pwredup)).
    *   X: Preserved.
    *   Y: Preserved.
    *   P: Undefined.
*   **Memory:**
    *   [PWREDUP](#pwredup) (address $03F4): Stores the calculated power-up byte.

**Side Effects:**

*   Calculates and stores the Validity-Check byte in memory.

**See also:**

*   [Reset](#reset-fa62)
*   [PwrUp](#pwrup-faa6)
