### <a id="bs-fc10"></a>BS ($FC10)

**Description:**

This routine performs a backspace operation. It decrements [CH](#ch). If the cursor reaches the left window boundary, it wraps to the rightmost edge, and calls [Up](#up-fc1a) to move the cursor up one line.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Current horizontal cursor position.
    *   [WNDLFT](#wndlft) (address $20): Left edge boundary of the text window.
    *   [WNDWDTH](#wndwdth) (address $21): Width of the text window.
    *   OURCH (address $58): 80-column horizontal cursor position (used in Apple IIc variant).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Flags affected by arithmetic and comparison operations.
*   **Memory:**
    *   [CH](#ch): Decremented; reset to [WNDWDTH](#wndwdth) if cursor wraps.
    *   [CV](#cv): May be altered if the [Up](#up-fc1a) routine is called.
    *   [BASL/BASH](#basl-bash): May be altered if the [Up](#up-fc1a) routine is called.

**Side Effects:**

*   Modifies the horizontal cursor position.
*   May modify vertical cursor position and display memory if [Up](#up-fc1a) is called.

**See also:**

*   [Up](#up-fc1a)
*   [CH](#ch)
*   [WNDLFT](#wndlft)
*   [WNDWDTH](#wndwdth)
*   [CV](#cv)
*   [BASL/BASH](#basl-bash)