### <a id="prntx-f944"></a>PrntX ($F944)

**Description:**

This routine prints the contents of the X register as a two-digit hexadecimal value to standard output.

**Input:**

*   **Registers:**
    *   A: N/A
    *   X: The 8-bit value from the X-index register to be printed in hexadecimal format.
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

*   Prints the hexadecimal value of the X register.

**See also:**

*   [PrByte](#prbyte-fdda)