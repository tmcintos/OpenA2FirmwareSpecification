### <a id="bell1-fbdd"></a>Bell1 ($FBDD)

**Description:**

This routine generates a brief 1 kHz tone through the system speaker for approx. 0.1 second. A short 0.01-second pre-tone delay prevents distortion from rapid calls.

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
*   Introduces a brief execution delay.

**See also:**

*   [Bell1_2](#bell1-2-fbe2)
*   [Bell2](#bell2-fbe4)