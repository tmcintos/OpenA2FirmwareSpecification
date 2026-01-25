### <a id="prbyte-fdda"></a>PrByte ($FDDA)

**Description:**

This routine prints the contents of the A register (accumulator) in two-digit hexadecimal format to standard output.

**Input:**

*   **Registers:**
    *   A: The 8-bit value to be printed in hexadecimal format.
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

*   Prints the hexadecimal representation of the A register's content.

**See also:**

*   [PrHex](#prhex-fde3)
*   [COUT](#cout-fded)