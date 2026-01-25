### <a id="nxtcol-f85f"></a>NxtCol ($F85F)

**Description:**

This routine modifies the current color for Lo-Res graphics plotting by adding 3 to the value in the [COLOR](#color) zero-page location. Use [SetCol](#setcol-f864) for direct color setting.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected (e.g., Carry flag if [COLOR](#color) overflows).
*   **Memory:**
    *   [COLOR](#color): The stored color value is incremented by 3.

**Side Effects:**

*   Modifies [COLOR](#color).
*   Changes the active plotting color.

**See also:**

*   [SetCol](#setcol-f864)
*   [COLOR](#color)