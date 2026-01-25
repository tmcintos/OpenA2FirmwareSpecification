### <a id="up-fc1a"></a>Up ($FC1A)

**Description:**

This routine decrements the [CV](#cv) value by 1, moving the cursor up one line, unless the cursor is already on the top line of the window (defined by [WNDTOP](#wndtop)).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CV](#cv) (address $25): Vertical position of cursor.
    *   [WNDTOP](#wndtop) (address $22): Upper boundary of the text window.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined
*   **Memory:**
    *   [CV](#cv): The vertical cursor position is decremented (if not at top of window).

**Side Effects:**

*   Moves the cursor up one line, unless at the top of the window.

**See also:**

*   [BS](#bs-fc10)
*   [CV](#cv)
*   [WNDTOP](#wndtop)