### <a id="vline-f828"></a>VLine ($F828)

**Description:**

This routine draws a vertical line of blocks on the Lo-Res graphics display. The block color is determined by [COLOR](#color) (set via [SetCol](#setcol-f864)). The A register specifies the vertical position of the topmost block ($00-$2F), and the Y register specifies the horizontal position of the line ($00-$27). The lowest extent is determined by [V2](#v2).

**Input:**

*   **Registers:**
    *   A: The vertical position of the topmost block in the line ($00-$2F).
    *   X: N/A
    *   Y: The horizontal position of the vertical line ($00-$27).
*   **Memory:**
    *   [COLOR](#color) (address $30): Block's color value.
    *   [V2](#v2) (address $2F): Vertical position of the bottommost block.

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags may be affected.
*   **Memory:**
    *   The Lo-Res graphics display memory is modified to draw the vertical line.

**Side Effects:**

*   Modifies the Lo-Res graphics display.

**See also:**

*   [Plot](#plot-f800)
*   [HLine](#hline-f819)
*   [SetCol](#setcol-f864)
*   [V2](#v2)
*   [COLOR](#color)