### <a id="setgr-fb40"></a>SetGr ($FB40)

**Description:**

This routine sets the display to mixed graphics mode, clears the graphics portion of the screen, and sets the top of the text window to line 20. It also calls [BasCalc](#bascalc-fbc1) to calculate and store the base memory address ([BASL/BASH](#basl-bash)) for the last line of text.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the low byte of the calculated base address for the text line (for the four-line text window) ([BASL](#basl)).
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Graphics screen memory: Cleared.
    *   [WNDTOP](#wndtop) (address $22): Set to $14 (20 decimal).
    *   [BASL/BASH](#basl-bash) (address $28-$29): Updated with the base address for the text window.
    *   Video mode soft switches: Configured for mixed graphics mode.

**Side Effects:**

*   Changes display mode to mixed graphics.
*   Clears the graphics screen.
*   Sets the top boundary of the text window.
*   Updates [BASL/BASH](#basl-bash).

**See also:**

*   [BasCalc](#bascalc-fbc1)
*   [WNDTOP](#wndtop)
*   [BASL/BASH](#basl-bash)