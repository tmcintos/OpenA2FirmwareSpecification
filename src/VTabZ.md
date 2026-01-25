### <a id="vtabz-fc24"></a>VTABZ ($FC24)

**Description:**

This routine calculates the base address for the current text line and adjusts it based on the left edge of the text window and 80-column mode. It calls [BasCalc](#bascalc-fbc1) to get the initial base address using the A register (vertical line number), then adjusts [BASL](#basl) by adding [WNDLFT](#wndlft), potentially halved if in 80-column mode (checked via the `RD80VID` soft switch).

**Input:**

*   **Registers:**
    *   A: The vertical line number for which to calculate the base address (typically from [CV](#cv)).
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [BASL](#basl) (address $28): Lower byte of the text screen base address. Read and modified by this routine.
    *   [WNDLFT](#wndlft) (address $20): The left edge of the text window. Used to adjust the base address.
    *   `RD80VID ($C01F)`: A read-only soft switch that indicates if the system is in 80-column video mode. This influences how [WNDLFT](#wndlft) is applied.

**Output:**

*   **Registers:**
    *   A: Modified by internal calculations.
    *   X: Preserved.
    *   Y: Preserved.
    *   P: Flags affected by arithmetic and bitwise operations.
*   **Memory:**
    *   [BASL](#basl) (address $28): Updated with the adjusted base address.
    *   [BASH](#bash) (address $29): Updated by [BasCalc](#bascalc-fbc1).

**Side Effects:**

*   Calls [BasCalc](#bascalc-fbc1) to get the initial base address.
*   Reads the `RD80VID` soft switch.
*   Modifies [BASL](#basl) and [BASH](#bash).

**See also:**

*   [BasCalc](#bascalc-fbc1)
*   [WNDLFT](#wndlft)
*   [BASL/BASH](#basl-bash)
*   [CV](#cv)
*   `RD80VID` (soft switch)