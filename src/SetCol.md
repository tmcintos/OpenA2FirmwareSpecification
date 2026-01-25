### <a id="setcol-f864"></a>SetCol ($F864)

**Description:**

This routine sets the color for Lo-Res graphics plotting. The A register must contain the desired 4-bit color value ($00-$0F).

**Input:**

*   **Registers:**
    *   A: The 4-bit color value ($00-$0F) to be set for Lo-Res graphics plotting.
    *   X: N/A
    *   Y: N/A
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Preserved
    *   X: Preserved
    *   Y: Preserved
    *   P: Undefined
*   **Memory:**
    *   [COLOR](#color): The zero-page location is updated with the new color value.

**Side Effects:**

*   Configures the current plotting color.

**See also:**

*   [Plot](#plot-f800)
*   [HLine](#hline-f819)
*   [VLine](#vline-f828)
*   [NxtCol](#nxtcol-f85f)
*   [COLOR](#color)