### <a id="tabv-fb5b"></a>TabV ($FB5B)

**Description:**

This routine performs a vertical tab to the line specified in the A register ($00-$17). It calls [BasCalc](#bascalc-fbc1) to calculate and store the base memory address ([BASL/BASH](#basl-bash)) for that line, and updates [CV](#cv) with the new line number.

**Input:**

*   **Registers:**
    *   A: The line number (from $00-$17) to which the vertical tab should occur.
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address for the text line ([BASL](#basl)).
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [CV](#cv) (address $25): Set to the value in A on entry.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated with the base address for the text line.

**Side Effects:**

*   Performs a vertical tab.
*   Updates [CV](#cv) and [BASL/BASH](#basl-bash).

**See also:**

*   [BasCalc](#bascalc-fbc1)
*   [VTab](#vtab-fc22)
*   [VTabZ](#vtabz-fc24)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)