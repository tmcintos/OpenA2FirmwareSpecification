### <a id="oldbrk-fa59"></a>OldBrk ($FA59)

**Description:**

This routine serves as a break handler that prints information about the `BRK` instruction. It prints the values for the program counter and 6502 registers (A, X, Y, P, S) that are stored in zero page locations ([A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status), [SPNT](#spnt), [PCL/PCH](#pcl-pch)). After printing this information, it jumps to the Monitor. This routine is present in Apple II+, Apple //e, and Apple //c ROMs.

**Input:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
*   **Memory:**
    *   [A5H](#a5h) (address $45): The value in the A register before the break.
    *   [XREG](#xreg) (address $46): The value in the X register before the break.
    *   [YREG](#yreg) (address $47): The value in the Y register before the break.
    *   [STATUS](#status) (address $48): The value in the P register before the break.
    *   [SPNT](#spnt) (address $49): The value in the stack pointer before the break.
    *   [PCL/PCH](#pcl-pch) (address $3A-$3B): The address of the program counter before the break.

**Output:**

*   **Registers:**
    *   A: Undefined.
    *   X: Undefined.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Screen: Displays the contents of the program counter and registers.

**Side Effects:**

*   Prints program counter and register values to the screen.
*   Jumps to the Monitor.

**See also:**

*   [Break ($FA4C)](#break-fa4c) (Old 6502 break handler)
*   [Mon ($FF69)](#mon-ff69) (Monitor entry point)
*   [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), [STATUS](#status), [SPNT](#spnt)
*   [PCL/PCH](#pcl-pch)