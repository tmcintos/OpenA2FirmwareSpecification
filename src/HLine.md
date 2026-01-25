### <a id="hline-f819"></a>HLine ($F819)

**Description:**

This routine draws a horizontal line of blocks on the Lo-Res graphics display. It does this by repeatedly calling [Plot](#plot-f800) (or [Plot1](#plot1-f80e)) for each block, starting from the given initial horizontal (Y) and vertical (A) coordinates, and continues until the horizontal position reaches the value specified in [H2](#h2). The color of the line is determined by the value in [COLOR](#color).

**Input:**

*   **Registers:**
    *   A: Vertical position of the blocks to plot ($00-$2F). This value is passed to [Plot](#plot-f800).
    *   X: N/A (preserved by this routine).
    *   Y: Initial horizontal position of the leftmost block ($00-$27). This value is passed to [Plot](#plot-f800) and then incremented internally.
*   **Memory:**
    *   [H2](#h2) (address $2C): Contains the target horizontal position (X-coordinate) for the end of the line.
    *   [COLOR](#color) (address $30): The current color value used for plotting, which is read by [Plot](#plot-f800).
    *   [GBASL/GBASH](#gbasl-gbash) (address $26-$27): The current low-resolution graphics base address, which is read and modified by [GBasCalc](#gbascalc-f847), a subroutine called by [Plot](#plot-f800).

**Output:**

*   **Registers:**
    *   A: Undefined (modified by internal calculations within [Plot](#plot-f800)).
    *   X: Preserved.
    *   Y: Modified (incremented during the line drawing loop).
    *   P: Flags affected by internal operations, including those of [Plot](#plot-f800).
*   **Memory:**
    *   Lo-Res graphics display memory is modified to draw the line.
    *   [GBASL/GBASH](#gbasl-gbash): Updated by calls to [GBasCalc](#gbascalc-f847) from [Plot](#plot-f800).

**Side Effects:**

*   Calls [Plot](#plot-f800) and [Plot1](#plot1-f80e) repeatedly to draw the horizontal line.
*   Modifies the Lo-Res graphics display memory.
*   The Y register is incremented during the line drawing process.

**See also:**

*   [Plot](#plot-f800)
*   [Plot1](#plot1-f80e)
*   [SetCol](#setcol-f864)
*   [H2](#h2)
*   [COLOR](#color)
*   [GBasCalc](#gbascalc-f847)
*   [GBASL/GBASH](#gbasl-gbash)