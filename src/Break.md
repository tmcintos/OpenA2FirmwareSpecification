### <a id="break-fa4c"></a>Break ($FA4C)

**Description:**

This routine handles the processor's hardware break event. It saves CPU registers (A, X, Y, P, S) and the Program Counter (PC) into memory locations ([A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status), [SPNT](#spnt), [PCL/PCH](#pcl-pch)). Control then transfers to the user-defined break handler at [BRKV](#brkv) ($03F0-$03F1), or to [OldBrk](#oldbrk-fa59) by default. In the original Apple II ROM, the address `$FA4C` corresponds to a different routine and is not the 6502 break handler described here.

**Input:**

*   **Registers:**
    *   A: Current Accumulator value (saved)
    *   X: Current X-index register value (saved)
    *   Y: Current Y-index register value (saved)
*   **Memory:**
    *   [STATUS](#status) (address $48): The routine reads the current processor status.
    *   [BRKV](#brkv) (address $03F0-$03F1): The 16-bit address of the user's custom break handler routine.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   CPU registers are indirectly saved by this routine.

**Side Effects:**

*   Saves CPU registers and Program Counter.
*   Transfers control via the address in [BRKV](#brkv).
*   Modifies the CPU stack.

**See also:**

*   [OldBrk](#oldbrk-fa59)
*   [NewBrk](#newbrk-fa47)
*   [BRKV](#brkv)
*   [A5H](#a5h)
*   [XREG](#xreg)
*   [YREG](#yreg)
*   [STATUS](#status)
*   [SPNT](#spnt)
*   [PCL/PCH](#pcl-pch)