### <a id="regdsp-fad7"></a>RegDsp ($FAD7)

**Description:**

This routine displays the contents of the microprocessor's registers and relevant system state information. It is primarily used by the Monitor for debugging and system inspection purposes. The displayed values typically include A, X, Y, and P registers.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:** N/A (displays current state from CPU registers and system zero-page locations).

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Screen: Displays the contents of the registers and system state information.

**Side Effects:**

*   Outputs register and system state information to the screen.

**See also:**

*   [Mon ($FF69)](#monz-ff69) (Monitor entry point)