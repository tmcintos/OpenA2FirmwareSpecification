### <a id="setwnd-fb4b"></a>SetWnd ($FB4B)

**Description:**

This routine sets the text window to full screen width, with its bottom at the screen's bottom, and its top at the line specified in the A register. It calls [BasCalc](#bascalc-fbc1) to calculate and store the base memory address ([BASL/BASH](#basl-bash)) for the last text line in the window.

**Input:**

*   **Registers:**
    *   A: The line number designated for the top boundary of the window ($00-$17).
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address for the current line ([BASL](#basl)).
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   [WNDTOP](#wndtop) (address $22): Set to the value in A on entry.
    *   [WNDBTM](#wndbtm) (address $23): Set to $18 (24 decimal).
    *   [WNDLFT](#wndlft) (address $20): Set to $00.
    *   [WNDWDTH](#wndwdth) (address $21): Set to $28 (40 columns) or $50 (80 columns) depending on video mode.
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated with the base address for the current line.

**Side Effects:**

*   Configures the text window dimensions.
*   Updates [BASL/BASH](#basl-bash).

**See also:**

*   [BasCalc](#bascalc-fbc1)
*   [WNDTOP](#wndtop)
*   [WNDBTM](#wndbtm)
*   [WNDLFT](#wndlft)
*   [WNDWDTH](#wndwdth)
*   [BASL/BASH](#basl-bash)