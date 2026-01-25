### <a id="clrscr-f832"></a>ClrScr ($F832)

**Description:**

This routine clears the Lo-Res graphics display to black. If called in text mode, it fills the text screen with inverse at-sign (`@`) characters instead.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Undefined
    *   Y: Undefined
    *   P: Undefined
*   **Memory:**
    *   Lo-Res graphics display memory is cleared to black, or text screen memory is filled with inverse '@' characters.

**Side Effects:**

*   Modifies display memory; behavior is conditional on the current video mode.

**See also:** None.