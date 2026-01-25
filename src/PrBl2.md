### <a id="prbl2-f94a"></a>PrBl2 ($F94A)

**Description:**

This routine prints a number of blank spaces to standard output, as specified by the value in the X register (1-256 spaces).

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: Number of blank spaces to print ($00-$FF).
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

*   Prints blank spaces to standard output.

**See also:**

*   [COUT](#cout-fded)