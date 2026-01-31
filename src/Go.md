### <a id="go-feb6"></a>Go ($FEB6)

**Description:**

This routine facilitates a jump to a user-specified subroutine address, after optionally updating the program counter (PC) and restoring certain meta-registers. It first calls the internal helper routine [A1PC](#a1pc-fe75), which conditionally copies the 16-bit address from [A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch) (Program Counter Low/High) based on the initial value of the X register. Following this, it calls the [Restore](#restore-ff3f) routine to set the A, X, Y, and P registers from saved values in [A5H](#a5h), [XREG](#xreg), [YREG](#yreg), and [STATUS](#status) respectively. Finally, it performs an indirect jump to the address contained in [PCL/PCH](#pcl-pch) and does not return to its caller.

**Input:**

*   **Registers:**
    *   X: This register is an input to [A1PC](#a1pc-fe75). If X is non-zero (typically $01), [A1PC](#a1pc-fe75) will copy the address from [A1L/A1H](#a1l-a1h) to [PCL/PCH](#pcl-pch).
    *   A: N/A
    *   Y: N/A
*   **Memory:**
    *   [A1L/A1H](#a1l-a1h) (address $3C-$3D): The 16-bit address that may be copied to the program counter if [A1PC](#a1pc-fe75) is triggered.
    *   [PCL/PCH](#pcl-pch) (address $3A-$3B): The 16-bit address of the user subroutine to jump to. This is read as the final jump target.
    *   [A5H](#a5h) (address $45): The value to which the A register will be set by [Restore](#restore-ff3f).
    *   [XREG](#xreg) (address $46): The value to which the X register will be set by [Restore](#restore-ff3f).
    *   [YREG](#yreg) (address $47): The value to which the Y register will be set by [Restore](#restore-ff3f).
    *   [STATUS](#status) (address $48): The value to which the P register (processor status flags) will be set by [Restore](#restore-ff3f).

**Output:**

*   **Registers:**
    *   A: Loaded with the value from [A5H](#a5h) by [Restore](#restore-ff3f).
    *   X: Loaded with the value from [XREG](#xreg) by [Restore](#restore-ff3f).
    *   Y: Loaded with the value from [YREG](#yreg) by [Restore](#restore-ff3f).
    *   P: Loaded with the value from [STATUS](#status) by [Restore](#restore-ff3f).
*   **Memory:**
    *   [PCL/PCH](#pcl-pch): May be updated by [A1PC](#a1pc-fe75) if X was non-zero on entry. Program execution continues at this address.

**Side Effects:**

*   Calls [A1PC](#a1pc-fe75) to conditionally set the program counter ([PCL/PCH](#pcl-pch)).
*   Calls [Restore](#restore-ff3f) to restore CPU registers (A, X, Y, P) from predefined memory locations.
*   Transfers program control to the address specified by [PCL/PCH](#pcl-pch).

**See also:**

*   [A1PC](#a1pc-fe75)
*   [Restore](#restore-ff3f)
*   [A1L/A1H](#a1l-a1h)
*   [PCL/PCH](#pcl-pch)
*   [A5H](#a5h)
*   [XREG](#xreg)
*   [YREG](#yreg)
*   [STATUS](#status)