### <a id="scrn-f871"></a>Scrn ($F871)

**Description:**

This routine returns the 4-bit color value of a block on the Lo-Res graphics display at the given vertical (A) and horizontal (Y) positions.

**Input:**

*   **Registers:**
    *   A: The vertical position of the block on the Lo-Res graphics display ($00-$2F).
    *   X: N/A
    *   Y: The horizontal position of the block on the Lo-Res graphics display ($00-$27).
*   **Memory:** None.

**Output:**

*   **Registers:**
    *   A: Contains the 4-bit color value of the block ($00-$0F).
    *   X: Preserved
    *   Y: Preserved
    *   P: Flags affected by memory read.
*   **Memory:** None.

**Side Effects:**

*   Reads Lo-Res graphics display memory.

**See also:**

*   [Plot](#plot-f800)
*   [Plot1](#plot1-f80e)
*   [SetCol](#setcol-f864)
*   [COLOR](#color)