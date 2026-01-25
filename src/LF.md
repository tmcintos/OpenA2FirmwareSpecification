### <a id="lf-fc66"></a>LF ($FC66)

**Description:**

This routine performs a line feed. It increments [CV](#cv). If [CV](#cv) exceeds [WNDBTM](#wndbtm), it calls [Scroll](#scroll-fc70) to scroll the window up, placing the cursor on the bottom line. It also calls [BasCalc](#bascalc-fbc1) to update [BASL/BASH](#basl-bash) for the new line.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CV](#cv) (address $25): Vertical position of cursor.
    *   [WNDBTM](#wndbtm) (address $23): Lower boundary of the text window.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [CV](#cv): Incremented vertical cursor position, or reset to [WNDBTM](#wndbtm) if scrolling occurred.
    *   [BASL/BASH](#basl-bash): Updated with the base memory address for the new text line.
*   **Memory:**
    *   Text memory may be scrolled upwards.

**Side Effects:**

*   Moves the vertical cursor.
*   May cause scrolling of the text window.
*   Updates [CV](#cv) and [BASL/BASH](#basl-bash).

**See also:**

*   [Scroll](#scroll-fc70)
*   [BasCalc](#bascalc-fbc1)
*   [CV](#cv)
*   [WNDBTM](#wndbtm)
*   [BASL/BASH](#basl-bash)