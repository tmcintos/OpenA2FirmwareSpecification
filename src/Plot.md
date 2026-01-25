### <a id="plot-f800"></a>Plot ($F800)

**Description:**

This routine plots a single block of the color specified by [COLOR](#color) (set via [SetCol](#setcol-f864)) on the Lo-Res graphics display at the vertical (A) and horizontal (Y) positions.

**Input:**

*   **Registers:**
    *   A: The vertical position for plotting the block ($00-$2F).
    *   X: N/A
    *   Y: The horizontal position for plotting the block ($00-$27).
*   **Memory:**
    *   [COLOR](#color) (address $30): Color value for plotting, set by [SetCol](#setcol-f864).

**Output:**

*   **Registers:**
    *   A: Undefined
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags may be affected.
*   **Memory:**
    *   The Lo-Res graphics display memory is modified to include the plotted block.

**Side Effects:**

*   Modifies the Lo-Res graphics display.

**See also:**

*   [HLine](#hline-f819)
*   [VLine](#vline-f828)
*   [Plot1](#plot1-f80e)
*   [SetCol](#setcol-f864)
*   [COLOR](#color)