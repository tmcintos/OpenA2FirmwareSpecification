### <a id="bell1_2-fbe2"></a>Bell1_2 ($FBE2)

**Description:**

This routine generates a brief 1 kHz tone via the system speaker for approximately 0.1 second. Unlike [Bell1](#bell1-fbdd), `Bell1_2` includes no preliminary delay.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Contains `$00`
    *   P: Flags affected by internal timing loops
*   **Memory:** None.

**Side Effects:**

*   Generates a speaker tone.

**See also:**

*   [Bell1](#bell1-fbdd)
*   [Bell2](#bell2-fbe4)
