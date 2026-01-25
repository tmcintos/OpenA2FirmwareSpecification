### <a id="vtab-fc22"></a>VTab ($FC22)

**Description:**

This routine performs a vertical tab to the line specified by [CV](#cv). It calls [BasCalc](#bascalc-fbc1) to store the base memory address ([BASL/BASH](#basl-bash)) for that line. `VTab` differs from [TabV](#tabv-fb5b) by not storing a new line number in [CV](#cv).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CV](#cv) (address $25): Vertical position of cursor.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Flags affected by [BasCalc](#bascalc-fbc1) execution.
*   **Memory:**
    *   [BASL/BASH](#basl-bash): Updated with the base memory address for the new text line.

**Side Effects:**

*   Performs a vertical tab.
*   Updates [BASL/BASH](#basl-bash).

**See also:**

*   [BasCalc](#bascalc-fbc1)
*   [TabV](#tabv-fb5b)
*   [VTabZ](#vtabz-fc24)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)