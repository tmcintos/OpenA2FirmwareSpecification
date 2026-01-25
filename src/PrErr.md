### <a id="prerr-ff2d"></a>PrErr ($FF2D)

**Description:**

This routine prints "ERR" to standard output and sends a bell character (`$87`) to standard output.

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
    *   P: Undefined
*   **Memory:**
    *   Standard output is used.

**Side Effects:**

*   Prints "ERR".
*   Outputs a bell character.

**See also:**

*   [COUT](#cout-fded)
*   [Bell](#bell-ff3a)