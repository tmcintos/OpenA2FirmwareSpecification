### <a id="advance-fbf4"></a>Advance ($FBF4)

**Description:**

This routine advances the text cursor's horizontal position by one character, incrementing [CH](#ch). If this causes the cursor to move beyond the [WNDWDTH](#wndwdth) (window width), it calls [LF](#lf-fc66) to perform a carriage return to the beginning of the next line. Otherwise, the updated horizontal position is saved back to [CH](#ch).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the text window.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by arithmetic and comparison operations.
*   **Memory:**
    *   [CH](#ch): Updated to new horizontal cursor position; reset to [WNDLFT](#wndlft) if carriage return occurs.
    *   [CV](#cv): May be incremented if a carriage return occurs.
    *   [BASL/BASH](#basl-bash): May be updated if a carriage return occurs.

**Side Effects:**

*   Moves the horizontal text cursor.
*   If the cursor reaches the window's right edge, the display may scroll.

**See also:**

*   [LF](#lf-fc66)
*   [COUT](#cout-fded)
*   [WNDLFT](#wndlft)
*   [WNDWDTH](#wndwdth)
*   [CH](#ch)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)