### <a id="cr-fc62"></a>CR ($FC62)

**Description:**

This routine executes a carriage return. It moves the horizontal cursor to the leftmost edge of the current text window (defined by [WNDLFT](#wndlft)), then calls [LF](#lf-fc66) to advance the cursor to the beginning of the next line.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [WNDLFT](#wndlft) (address $20): The left edge of the text window.
    *   [CV](#cv) (address $25): The current vertical cursor position.
    *   [WNDBTM](#wndbtm) (address $23): The bottom edge of the text window.
    *   VARTIM (address $0789): PASCAL 1.1 timing flag (used in Apple IIc variant).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Undefined
    *   P: Flags affected by internal operations.
*   **Memory:**
    *   [CH](#ch): Set to the value of [WNDLFT](#wndlft).
    *   [CV](#cv): May be updated if [LF](#lf-fc66) causes vertical cursor movement.
    *   [BASL/BASH](#basl-bash): May be updated if [LF](#lf-fc66) modifies the base address.

**Side Effects:**

*   Repositions the horizontal cursor.
*   May cause vertical cursor movement and display scrolling via [LF](#lf-fc66).
*   May affect text memory.

**See also:**

*   [LF](#lf-fc66)
*   [WNDLFT](#wndlft)
*   [CH](#ch)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)