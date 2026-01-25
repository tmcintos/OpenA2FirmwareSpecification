### <a id="restore-ff3f"></a>Restore ($FF3F)

**Description:**

This routine sets the A, X, Y, and P registers to the values stored in [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), and [STATUS](#status) respectively.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [A5H](#a5h) (address $45): Value to which the A register is to be set.
    *   [XREG](#xreg) (address $46): Value to which the X register is to be set.
    *   [YREG](#yreg) (address $47): Value to which the Y register is to be set.
    *   [STATUS](#status) (address $48): Value to which the P register is to be set.

**Output:**

*   **Registers:**
    *   A: Loaded with the value from [A5H](#a5h).
    *   X: Loaded with the value from [XREG](#xreg).
    *   Y: Loaded with the value from [YREG](#yreg).
    *   P: Loaded with the value from [STATUS](#status).
*   **Memory:** None.

**Side Effects:**

*   Restores CPU registers from stored memory locations.

**See also:**

*   [Save](#save-ff4a)
*   [Go](#go-feb6)
*   [A5H](#a5h)
*   [XREG](#xreg)
*   [YREG](#yreg)
*   [STATUS](#status)