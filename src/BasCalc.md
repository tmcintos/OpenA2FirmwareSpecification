### <a id="bascalc-fbc1"></a>BasCalc ($FBC1)

**Description:**

This routine computes and stores the 16-bit base memory address for a given text display line. The line number is provided in the A register ($00-$17). The calculated high and low bytes are stored in [BASL/BASH](#basl-bash).

**Input:**

*   **Registers:**
    *   A: Text line number ($00-$17, representing lines 0-23)
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by arithmetic and logical operations
*   **Memory:**
    *   [BASL/BASH](#basl-bash): Updated with the computed 16-bit base address.

**Side Effects:** None.

**See also:**

*   [BASL/BASH](#basl-bash)
*   [Init](#init-fb2f)
*   [LF](#lf-fc66)
*   [Scroll](#scroll-fc70)
*   [SetTxt](#settxt-fb39)
*   [SetWnd](#setwnd-fb4b)
*   [VTab](#vtab-fc22)
*   [VTabZ](#vtabz-fc24)