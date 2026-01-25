### <a id="save-ff4a"></a>Save ($FF4A)

**Description:**

This routine stores the current contents of the A, X, Y, P, and S registers into [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status), and [SPNT](#spnt) respectively. Afterwards, it clears the processor's decimal mode flag.

**Input:**

*   **Registers:**
    *   A: Current Accumulator value.
    *   X: Current X-index register value.
    *   Y: Current Y-index register value.
    *   P: Current Processor Status register value.
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Decimal mode flag is cleared.
*   **Memory:**
    *   [A5H](#a5h): Updated with the current value of the A register.
    *   [XREG](#xreg): Updated with the current value of the X-index register.
    *   [YREG](#yreg): Updated with the current value of the Y-index register.
    *   [STATUS](#status): Updated with the current value of the P register.
    *   [SPNT](#spnt): Updated with the current value of the S register.

**Side Effects:**

*   Stores CPU registers in memory.
*   Clears the decimal mode flag.

**See also:**

*   [Restore](#restore-ff3f)
*   [Break](#break-fa4c)
*   [A5H](#a5h)
*   [XREG](#xreg)
*   [YREG](#yreg)
*   [STATUS](#status)
*   [SPNT](#spnt)