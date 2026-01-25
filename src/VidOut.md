### <a id="vidout-fbfd"></a>VidOut ($FBFD)

**Description:**

This routine sends printable characters (from the A register) to [StorAdv](#storadv-fbf0). It checks for carriage return, line feed, backspace, and bell characters (Control-G), branching to their handlers if found. Other control characters are ignored.

**Input:**

*   **Registers:**
    *   A: The character (printable or control) to be processed.
    *   X: N/A
    *   Y: N/A
*   **Memory:**
    *   [CH](#ch) (address $24): Horizontal position of cursor.
    *   [CV](#cv) (address $25): Vertical position of cursor.

**Output:**

*   **Registers:**
    *   A: Contains the character that was output (same as input A).
    *   X: Preserved.
    *   Y: Undefined.
    *   P: Undefined.
*   **Memory:**
    *   Screen memory: Modified to display characters or as a result of control codes.
    *   Cursor position (zero-page locations [CH](#ch) and [CV](#cv)): Advanced or modified.

**Side Effects:**

*   Sends characters for display.
*   Processes and handles specific control characters.
*   Modifies text memory and cursor position.

**See also:**

*   [StorAdv](#storadv-fbf0)
*   [CR](#cr-fc62)
*   [LF](#lf-fc66)
*   [BS](#bs-fc10)
*   [Bell](#bell-ff3a)
*   [CH](#ch)
*   [CV](#cv)