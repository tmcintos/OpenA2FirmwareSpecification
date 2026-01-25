### <a id="plot1-f80e"></a>Plot1 ($F80E)

**Description:**

This routine plots a single block of the color specified by [COLOR](#color) (set via [SetCol](#setcol-f864)) on the Lo-Res graphics display at the horizontal position (Y) on the current row (determined by [GBASL/GBASH](#gbasl-gbash)). Use [Plot](#plot-f800) for explicit vertical/horizontal positions, or [GBasCalc](#gbascalc-f847) to set [GBASL/GBASH](#gbasl-gbash).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: N/A
    *   Y: The horizontal position for plotting the block ($00-$27).
*   **Memory:** None.

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

*   [GBasCalc](#gbascalc-f847)
*   [Plot](#plot-f800)
*   [SetCol](#setcol-f864)
*   [GBASL/GBASH](#gbasl-gbash)
*   [COLOR](#color)