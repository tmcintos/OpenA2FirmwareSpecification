### <a id="bell2-fbe4"></a>Bell2 ($FBE4)

**Description:**

This routine generates a 1 kHz square-wave tone by rapidly toggling the system speaker. The tone's duration is controlled by the Y register; e.g., Y = `$C0` (192 decimal) for approx. 0.1 second, or Y = `$00` to toggle 256 times.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: Number of times to activate the speaker (duration proportional to Y).
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Contains `$00`
    *   P: Flags affected by internal timing loops
*   **Memory:** None.

**Side Effects:**

*   Generates a speaker tone by repeatedly accessing the speaker soft switch at $C030.

**See also:**

*   [Bell1](#bell1-fbdd)
*   [Bell1_2](#bell1_2-fbe2)